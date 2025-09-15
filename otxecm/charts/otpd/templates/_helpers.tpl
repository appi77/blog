{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "otpd.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "otpd.fullname" -}}
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
{{- define "otpd.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "otpd.labels" -}}
app.kubernetes.io/name: {{ include "otpd.name" . }}
helm.sh/chart: {{ include "otpd.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
  otpd.port uses the port defined in .Values.global.otpdPublicUrl, by default.
  if .Values.global.otpdPublicUrl is not available, port defined in .Values.publicHostname is considered.
  If no port is provided above and,
    1. if public Url uses http, port 80 will be used.
    2. if public Url uses https, port 443 will be used.
  In case of LoadBalancer scenario, port 80 will be used.
*/}}
{{- define "otpd.port" }}
    {{- if ne (default .Values.global.otpdPublicUrl .Values.publicHostname) "" }}
      {{- $publicProtocol := regexFind "^http(s?)" (default .Values.global.otpdPublicUrl .Values.publicHostname) }}
      {{- if regexFind ":([0-9]+)" (default .Values.global.otpdPublicUrl .Values.publicHostname) }}
        {{- $publicHostPort := regexFind ":([0-9]+)" (default .Values.global.otpdPublicUrl .Values.publicHostname) }}
        {{- printf $publicHostPort | trimPrefix ":" | quote }}
      {{- else if eq $publicProtocol "http" }}
        {{- printf "80" | quote }}
      {{- else if eq $publicProtocol "https" }}
        {{- printf "443" | quote }}
      {{- end }}
    {{- else }}
      {{- printf "80" | quote }}
    {{- end }}
{{- end }}

{{/*
  otpd.protocol uses the protocol defined in .Values.global.otpdPublicUrl, by default.
  if .Values.global.otpdPublicUrl is not available, protocol defined in .Values.publicHostname is considered.
  In case of LoadBalancer scenario, 'http' is used.
*/}}
{{- define "otpd.protocol" }}
  {{- if ne (default .Values.global.otpdPublicUrl .Values.publicHostname) "" }}
    {{- $publicProtocol := regexFind "^http(s?)" (default .Values.global.otpdPublicUrl .Values.publicHostname) }}
    {{- printf $publicProtocol }}
  {{- else }}
    {{- printf "http" }}
  {{- end }}
{{- end }}

{{/*
  otpd.otcsEnabled uses true, if otcs available otherwise false
*/}}
{{- define "otpd.otcsEnabled" }}
  {{-  if eq .Values.otcs.enabled true }}
    {{- printf "true" | quote }}
  {{- else }}
    {{- printf "false" | quote }}
  {{- end }}
{{- end }}

{{/*
  otds.publicProtocol uses the protocol defined in otds.publicHostname.
  'http' is used in case of LoadBalancer scenario
*/}}
{{- define "otds.publicProtocol" }}
  {{- if ne (default .Values.global.otdsPublicUrl .Values.otds.publicHostname) "" }}
    {{- $publicProtocol := regexFind "^http(s?)" (default .Values.global.otdsPublicUrl .Values.otds.publicHostname) }}
    {{- printf $publicProtocol }}
  {{- else }}
    {{- printf "http" }}
  {{- end }}
{{- end }}

{{/*
  otds.publicPort uses the port defined in otds.publicHostname.
  If no port is provided, 80 will be used if public hostname uses http.
  443 will be used if public hostname uses https.
  80 is used in case of LoadBalancer scenario
*/}}
{{- define "otds.publicPort" }}
  {{- if ne (default .Values.global.otdsPublicUrl .Values.otds.publicHostname) "" }}
    {{- $publicProtocol := regexFind "^http(s?)" (default .Values.global.otdsPublicUrl .Values.otds.publicHostname) }}
    {{- if regexFind ":([0-9]+)" (default .Values.global.otdsPublicUrl .Values.otds.publicHostname) }}
      {{- $publicHostPort := regexFind ":([0-9]+)" (default .Values.global.otdsPublicUrl .Values.otds.publicHostname) }}
      {{- printf $publicHostPort | trimPrefix ":" | quote }}
    {{- else if eq $publicProtocol "http" }}
      {{- printf "80" | quote }}
    {{- else if eq $publicProtocol "https" }}
      {{- printf "443" | quote }}
    {{- end }}
  {{- else }}
    {{- printf "80" | quote }}
  {{- end }}
{{- end }}

{{/*
  otpd.emailServerSettingsEnabled uses true, if provided. Otherwise, false.
*/}}
{{- define "otpd.emailServerSettingsEnabled" }}
  {{-  if eq .Values.emailServerSettings.enabled true }}
    {{- printf "true" | quote }}
  {{- else }}
    {{- printf "false" | quote }}
  {{- end }}
{{- end }}

{{/*
  otpd.emailServer uses value from helm cmd, if provided. Otherwise, empty value is sent.
*/}}
{{- define "otpd.emailServer" }}
  {{- if .Values.emailServerSettings.server }}
    {{- printf .Values.emailServerSettings.server }}
  {{- else }}
    {{- printf "" | quote }}
  {{- end }}
{{- end }}

{{/*
  otpd.emailPort uses value from helm cmd, if provided. Otherwise, empty value is sent.
*/}}
{{- define "otpd.emailPort" }}
  {{- if .Values.emailServerSettings.port }}
    {{- $emailServerPort := .Values.emailServerSettings.port | quote }}
    {{- printf $emailServerPort }}
  {{- else }}
    {{- printf "" | quote }}
  {{- end }}
{{- end }}

{{/*
  otpd.emailUser uses value from helm cmd, if provided. Otherwise, empty value is sent.
*/}}
{{- define "otpd.emailUser" }}
  {{- if .Values.emailServerSettings.user }}
    {{- printf .Values.emailServerSettings.user }}
  {{- else }}
    {{- printf "" | quote }}
  {{- end }}
{{- end }}

{{/*
  otpd.secretlink.vaultAddress uses value from helm cmd, if provided. Otherwise, empty value is sent.
*/}}
{{- define "otpd.secretlink.vaultAddress" }}
  {{- if (default .Values.global.secretlink.vault.address .Values.secretlink.vault.address) }}
    {{- printf (default .Values.global.secretlink.vault.address .Values.secretlink.vault.address) }}
  {{- else }}
    {{- printf "" | quote }}
  {{- end }}
{{- end }}

{{/*
  otpd.secretlink.vaultMountPoint uses value from helm cmd, if provided. Otherwise, empty value is sent.
*/}}
{{- define "otpd.secretlink.vaultMountPoint" }}
  {{- if (default .Values.global.secretlink.vault.mountpoint .Values.secretlink.vault.mountpoint) }}
    {{- printf (default .Values.global.secretlink.vault.mountpoint .Values.secretlink.vault.mountpoint) }}
  {{- else }}
    {{- printf "" | quote }}
  {{- end }}
{{- end }}

{{/*
  otpd.secretlink.vaultPath uses value from helm cmd, if provided. Otherwise, empty value is sent.
*/}}
{{- define "otpd.secretlink.vaultPath" }}
  {{- if (default .Values.global.secretlink.vault.path .Values.secretlink.vault.path) }}
    {{- printf (default .Values.global.secretlink.vault.path .Values.secretlink.vault.path) }}
  {{- else }}
    {{- printf "" | quote }}
  {{- end }}
{{- end }}

{{/*
  otpd.secretlink.vaultNamespace uses value from helm cmd, if provided. Otherwise, empty value is sent.
*/}}
{{- define "otpd.secretlink.vaultNamespace" }}
  {{- if (default .Values.global.secretlink.vault.namespace .Values.secretlink.vault.namespace) }}
    {{- printf (default .Values.global.secretlink.vault.namespace .Values.secretlink.vault.namespace) | quote }}
  {{- else }}
    {{- printf "" | quote }}
  {{- end }}
{{- end }}

{{/*
  otpd.secretlink.vaultAuthPath uses value from helm cmd, if provided. Otherwise, empty value is sent.
*/}}
{{- define "otpd.secretlink.vaultAuthPath" }}
  {{- if (default .Values.global.secretlink.vault.authpath .Values.secretlink.vault.authpath) }}
    {{- printf (default .Values.global.secretlink.vault.authpath .Values.secretlink.vault.authpath) }}
  {{- else }}
    {{- printf "" | quote }}
  {{- end }}
{{- end }}

{{/*
  otpd.secretlink.vaultRole uses value from helm cmd, if provided. Otherwise, empty value is sent.
*/}}
{{- define "otpd.secretlink.vaultRole" }}
  {{- if (default .Values.global.secretlink.vault.role .Values.secretlink.vault.role) }}
    {{- printf (default .Values.global.secretlink.vault.role .Values.secretlink.vault.role) | quote }}
  {{- else }}
    {{- printf "" | quote }}
  {{- end }}
{{- end }}

