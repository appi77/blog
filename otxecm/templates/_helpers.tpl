{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "otxecm.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "otxecm.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "otxecm.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "otxecm.labels" -}}
app.kubernetes.io/name: {{ include "otxecm.name" . }}
helm.sh/chart: {{ include "otxecm.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Determine the ingress annotations to use
*/}}
{{- define "otxecm.ingress.annotations" -}}
{{- $ingressDict := .Values.global.ingressAnnotations }}
{{- if .Values.global.ingressAnnotationsCustom }}
{{- $ingressDict = .Values.global.ingressAnnotationsCustom }}
{{- end }}
{{- range $key, $value := $ingressDict }}
    {{ $key }}: {{ $value | squote }}
{{- end }}
{{- end -}}

{{/*
Determine the otds service name depending on whether a custom value has been used for these values:
global.otdsUseReleaseName
global.otds.otdsws.serviceName
*/}}
{{- define "otxecm.otdsServiceName" -}}
{{- if .Values.global.otdsUseReleaseName }}
{{- printf "%s-%s" .Release.Name .Values.global.otdsServiceName | quote -}}
{{- else }}
{{- printf "%s" .Values.global.otdsServiceName | quote -}}
{{- end }}
{{- end -}}

{{/*
OTIV Ingress Suffix
*/}}
{{- define "otiv.ingress.suffix" -}}
{{- if .Values.global.ingressIncludeNamespace -}}
-{{ .Release.Namespace }}.{{ .Values.global.ingressDomainName }}
{{- else -}}
.{{ .Values.global.ingressDomainName }}
{{- end -}}
{{- end -}}

{{/*
otxecm-default-secrets password synchronization validation
*/}}
{{- define "password.synchronization.validation" -}}
 {{- if or (and (empty .value1) .value2 (ne (.value2 | toString) (.value3 | toString))) (and (empty .value2) .value1 (ne (.value1 | toString) (.value3 | toString))) (and .value1 .value2 (ne (.value1 | toString) (.value2 | toString)))}}
     {{- print "\n\nError: " .msg " do not match. These passwords must be the same \n" | fail  }}
  {{- end }}
{{- end -}}

