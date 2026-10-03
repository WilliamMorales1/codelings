// streams2: client streaming
//
// `rpc Upload(stream Chunk) returns (UploadSummary)`: the client sends many
// messages, the server answers once. Server side:
//
//	for {
//	    chunk, err := stream.Recv()
//	    // io.EOF here means the client called CloseSend: it is done sending.
//	}
//	... then stream.SendAndClose(summary) sends the single response.
//
// Client side (Send below, already correct): stream.Send(...) repeatedly,
// then stream.CloseAndRecv() to half-close and wait for the answer.
//
// Task: fix Server.Upload. Right now every upload fails with
// "code = Unknown desc = EOF".
package streams2

import (
	"context"
	"crypto/sha256"

	"google.golang.org/grpc"
)

// Server accepts uploads and reports their size and hash.
type Server struct {
	UnimplementedFileServiceServer
}

func (Server) Upload(stream grpc.ClientStreamingServer[Chunk, UploadSummary]) error {
	h := sha256.New()
	var size int64
	for {
		chunk, err := stream.Recv()
		// TODO: once the client is done, answer with the size and
		// hex.EncodeToString(h.Sum(nil)).
		if err != nil {
			return err
		}
		h.Write(chunk.GetData())
		size += int64(len(chunk.GetData()))
	}
}

// Send uploads data in chunks of at most chunkSize bytes.
func Send(ctx context.Context, c FileServiceClient, data []byte, chunkSize int) (*UploadSummary, error) {
	stream, err := c.Upload(ctx)
	if err != nil {
		return nil, err
	}
	for len(data) > 0 {
		n := min(chunkSize, len(data))
		if err := stream.Send(&Chunk{Data: data[:n]}); err != nil {
			return nil, err
		}
		data = data[n:]
	}
	return stream.CloseAndRecv()
}
