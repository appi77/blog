{{/* vim: set filetype=mustache: */}}

{{- define "markup.secret.keys" -}}
{{- if (include "is.iv" .) }}
    DB_ADM_PWD_KEY: {{ .Values.global.dbSecretKey }}
    PITHOS_PWD_KEY: {{ .Values.global.ivDbSecretKey }}
    MARKUP_DB_PWD_KEY: {{ .Values.global.ivDbSecretKey }}
{{- end }}
{{- end -}}
