{{/* vim: set filetype=mustache: */}}

{{- define "publication.secret.keys" -}}
{{- if (include "is.iv" .) }}
    DB_ADM_PWD_KEY: {{ .Values.global.dbSecretKey }}
    PITHOS_PWD_KEY: {{ .Values.global.ivDbSecretKey }}
    PUBLICATION_CLIENT_SECRET_KEY: {{ .Values.clientSecretKey }}
    MONITORING_CLIENT_SECRET_KEY: {{ .Values.monitoring.clientSecretKey }}
    AJIRA_PWD_KEY: {{ .Values.global.amqp.pwdKey }}
{{- end }}
{{- end -}}
