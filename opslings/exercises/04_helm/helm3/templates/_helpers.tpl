{{/*
Common labels, stamped on every object of the release.
*/}}
{{- define "web.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels: the subset that identifies the Pods. These must never
change between releases, because Deployment selectors are immutable.
TODO: define "web.selectorLabels" here.
*/}}
