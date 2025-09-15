{{/* vim: set filetype=mustache: */}}

{{- define "highlight.secret.keys" -}}
{{- if (include "is.iv" .) }}
    HIGHLIGHT_CLIENT_SECRET_KEY: {{ .Values.clientSecretKey }}
{{- end }}
{{- end -}}
