package main

import (
	"bufio"
	"encoding/binary"
	"errors"
	"fmt"
	"net"
	"os"
	"strconv"
	"strings"
)

var dnsTypes = map[string]uint16{"A": 1, "NS": 2, "CNAME": 5, "PTR": 12, "MX": 15, "TXT": 16, "AAAA": 28}

func dnsTypeName(t uint16) string {
	for k, v := range dnsTypes {
		if v == t {
			return k
		}
	}
	return "TYPE" + strconv.Itoa(int(t))
}

type rr struct {
	name  string
	ttl   uint32
	typ   uint16
	rdata []byte
}

// loadZone reads lines of the form `name [ttl] TYPE value`; `;` starts a comment.
func loadZone(path string) (map[string][]rr, error) {
	f, err := os.Open(path)
	if err != nil {
		return nil, err
	}
	defer f.Close()
	zone := map[string][]rr{}
	sc := bufio.NewScanner(f)
	for n := 1; sc.Scan(); n++ {
		line := sc.Text()
		if i := strings.IndexByte(line, ';'); i >= 0 && !strings.Contains(line[:i], `"`) {
			line = line[:i]
		}
		fields := strings.Fields(line)
		if len(fields) == 0 {
			continue
		}
		r := rr{name: canon(fields[0]), ttl: 300}
		fields = fields[1:]
		if len(fields) > 0 {
			if t, err := strconv.ParseUint(fields[0], 10, 32); err == nil {
				r.ttl, fields = uint32(t), fields[1:]
			}
		}
		if len(fields) < 2 {
			return nil, fmt.Errorf("%s:%d: want `name [ttl] TYPE value`", path, n)
		}
		typ, ok := dnsTypes[strings.ToUpper(fields[0])]
		if !ok {
			return nil, fmt.Errorf("%s:%d: unknown type %s", path, n, fields[0])
		}
		r.typ = typ
		if r.rdata, err = encodeRdata(typ, fields[1:], line); err != nil {
			return nil, fmt.Errorf("%s:%d: %v", path, n, err)
		}
		zone[r.name] = append(zone[r.name], r)
	}
	return zone, sc.Err()
}

func canon(name string) string { return strings.ToLower(strings.TrimSuffix(name, ".")) }

func encodeRdata(typ uint16, args []string, line string) ([]byte, error) {
	switch typ {
	case 1, 28:
		ip := net.ParseIP(args[0])
		if ip == nil {
			return nil, fmt.Errorf("bad address %q", args[0])
		}
		if typ == 1 {
			if ip.To4() == nil {
				return nil, errors.New("A needs an IPv4 address")
			}
			return ip.To4(), nil
		}
		return ip.To16(), nil
	case 2, 5, 12:
		return encodeName(canon(args[0])), nil
	case 15:
		if len(args) < 2 {
			return nil, errors.New("MX wants `preference host`")
		}
		pref, err := strconv.ParseUint(args[0], 10, 16)
		if err != nil {
			return nil, err
		}
		return append(binary.BigEndian.AppendUint16(nil, uint16(pref)), encodeName(canon(args[1]))...), nil
	case 16:
		text := strings.Join(args, " ")
		if i, j := strings.IndexByte(line, '"'), strings.LastIndexByte(line, '"'); i >= 0 && j > i {
			text = line[i+1 : j]
		}
		var out []byte
		for len(text) > 255 {
			out = append(append(out, 255), text[:255]...)
			text = text[255:]
		}
		return append(append(out, byte(len(text))), text...), nil
	}
	return nil, errors.New("unsupported type")
}

func encodeName(name string) []byte {
	var out []byte
	if name != "" {
		for label := range strings.SplitSeq(name, ".") {
			out = append(append(out, byte(len(label))), label...)
		}
	}
	return append(out, 0)
}

// parseQuestion returns the first question's name, type and the offset just past it.
func parseQuestion(msg []byte) (string, uint16, int, error) {
	if len(msg) < 12 || binary.BigEndian.Uint16(msg[4:]) < 1 {
		return "", 0, 0, errors.New("no question")
	}
	var labels []string
	i := 12
	for {
		if i >= len(msg) {
			return "", 0, 0, errors.New("truncated name")
		}
		l := int(msg[i])
		i++
		if l == 0 {
			break
		}
		if l&0xC0 != 0 || i+l > len(msg) {
			return "", 0, 0, errors.New("bad label")
		}
		labels = append(labels, string(msg[i:i+l]))
		i += l
	}
	if i+4 > len(msg) {
		return "", 0, 0, errors.New("truncated question")
	}
	return canon(strings.Join(labels, ".")), binary.BigEndian.Uint16(msg[i:]), i + 4, nil
}

func answer(zone map[string][]rr, query []byte) ([]byte, string) {
	name, qtype, end, err := parseQuestion(query)
	if err != nil {
		return nil, ""
	}
	var answers []rr
	rcode := 0
	cur := name
	for range 8 {
		recs, ok := zone[cur]
		if !ok {
			if len(answers) == 0 {
				rcode = 3 // NXDOMAIN
			}
			break
		}
		var cname *rr
		for _, r := range recs {
			if r.typ == qtype {
				answers = append(answers, r)
			} else if r.typ == 5 {
				cname = &r
			}
		}
		if cname == nil || qtype == 5 {
			break
		}
		answers = append(answers, *cname)
		cur = decodeSimpleName(cname.rdata)
	}
	resp := make([]byte, 12, 512)
	copy(resp, query[:2])
	flags := uint16(0x8000|0x0400|0x0080) | binary.BigEndian.Uint16(query[2:])&0x7900 | uint16(rcode)
	binary.BigEndian.PutUint16(resp[2:], flags)
	binary.BigEndian.PutUint16(resp[4:], 1)
	binary.BigEndian.PutUint16(resp[6:], uint16(len(answers)))
	resp = append(resp, query[12:end]...)
	for _, r := range answers {
		resp = append(resp, encodeName(r.name)...)
		resp = binary.BigEndian.AppendUint16(resp, r.typ)
		resp = binary.BigEndian.AppendUint16(resp, 1)
		resp = binary.BigEndian.AppendUint32(resp, r.ttl)
		resp = binary.BigEndian.AppendUint16(resp, uint16(len(r.rdata)))
		resp = append(resp, r.rdata...)
	}
	status := "NOERROR"
	if rcode == 3 {
		status = "NXDOMAIN"
	}
	return resp, fmt.Sprintf("%s %s %s %d", name, dnsTypeName(qtype), status, len(answers))
}

func decodeSimpleName(b []byte) string {
	var labels []string
	for i := 0; i < len(b) && b[i] != 0; i += int(b[i]) + 1 {
		labels = append(labels, string(b[i+1:i+1+int(b[i])]))
	}
	return strings.Join(labels, ".")
}

func serveDNS(addr, zonePath, logPath string) error {
	zone, err := loadZone(zonePath)
	if err != nil {
		return err
	}
	pc, err := net.ListenPacket("udp", addr)
	if err != nil {
		return err
	}
	var logF *os.File
	if logPath != "" {
		if logF, err = os.OpenFile(logPath, os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0o644); err != nil {
			return err
		}
		defer logF.Close()
	}
	buf := make([]byte, 4096)
	for {
		n, from, err := pc.ReadFrom(buf)
		if err != nil {
			return err
		}
		resp, summary := answer(zone, buf[:n])
		if resp == nil {
			continue
		}
		pc.WriteTo(resp, from)
		if logF != nil {
			fmt.Fprintf(logF, "%s %s\n", from, summary)
		}
	}
}
