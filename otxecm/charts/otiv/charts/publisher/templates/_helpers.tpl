{{/* vim: set filetype=mustache: */}}

{{- define "log.output" -}}
{{- if .Values.logOutput -}}
{{- .Values.logOutput  -}}
{{- else if .Values.global.logOutput -}}
{{- if eq .Values.global.logOutput "rolling" -}}
rolling-agent
{{- else -}}
{{- .Values.global.logOutput -}}
{{- end -}}
{{- else -}}
stdout
{{- end -}}
{{- end -}}

{{/*
Define CSS whitelist domain names
*/}}
{{- define "css.whitelist" -}}
{{- if .Values.global.trustedSourceOrigins -}}
{{ .Values.global.cssFqdn }},{{ regexReplaceAllLiteral "^http(s?)://" .Values.global.trustedSourceOrigins  "" }}
{{- else -}}
{{ .Values.global.cssFqdn }}
{{- end -}}
{{- end -}}


{{- define "publisher.secret.keys" -}}
{{- if (include "is.iv" .) }}
    DB_ADM_PWD_KEY: {{ .Values.global.dbSecretKey }}
    PITHOS_PWD_KEY: {{ .Values.global.ivDbSecretKey }}
    PUBLISHER_CLIENT_SECRET_KEY: {{ .Values.clientSecretKey }}
    AJIRA_PWD_KEY: {{ .Values.global.amqp.pwdKey }}
{{- end }}
{{- end -}}
