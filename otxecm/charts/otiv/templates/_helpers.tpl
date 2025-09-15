{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "brava.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "brava.fullname" -}}
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
{{- define "brava.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Base Name used for naming most resources
*/}}
{{- define "base.resource.name" -}}
{{- if .Values.global.cssFqdn -}}
cvt-{{ .Chart.Name }}
{{- else -}}
otiv-{{ .Chart.Name }}
{{- end -}}
{{- end -}}

{{/*
Base Name used for naming most resources
*/}}
{{- define "base.resource.name.svc" -}}
{{- $svc := .svc -}}
{{- if $svc | empty -}}
{{- $svc = .Chart.Name -}}
{{- end -}}
{{- if .Values.global.cssFqdn -}}
{{- $baseSuffix := (hasSuffix "-dev-qa" .Release.Namespace) | ternary "-qa" "" -}}
{{- printf "cvt-%s%s" $svc $baseSuffix -}}
{{- else -}}
otiv-{{ $svc }}
{{- end -}}
{{- end -}}

{{/*
OTDS External URL path
*/}}
{{- define "otds.public.url" -}}
{{- if .Values.global.otdsPublicUrl -}}
{{- if not (regexFind "^http(s?)://" .Values.global.otdsPublicUrl ) -}}
{{- fail "A valid .Values.global.otdsPublicUrl value with http(s)://domain is required" -}}
{{- end -}}
{{ .Values.global.otdsPublicUrl }}
{{- else -}}
{{ .Values.global.otdsWebProtocol }}://otds{{ template "ingress.suffix" .}}
{{- end -}}
{{- end -}}

{{/*
OTDS Service Name
*/}}
{{- define "otds.service.name" -}}
{{- if .Values.global.otdsUseReleaseName }}
{{- printf "%s-%s" .Release.Name .Values.global.otdsServiceName -}}
{{- else }}
{{- printf "%s" .Values.global.otdsServiceName -}}
{{- end }}
{{- end -}}

{{/*
OTDS URL path
*/}}
{{- define "otds.url" -}}
{{- if .Values.global.otdsInCluster -}}
{{- if .Values.global.otdsPrivateUrl -}}
{{ .Values.global.otdsPrivateUrl }}
{{- else -}}
http://{{ template "otds.service.name" . }}
{{- end -}}
{{- else -}}
{{ template "otds.public.url" . }}
{{- end -}}
{{- end -}}

{{/*
OTDS API URL path
*/}}
{{- define "otds.api.url" -}}
{{- if .Values.global.cssFqdn -}}
{{ template "otds.url" . }}
{{- else -}}
{{- if .Values.otdsTenantID -}}
{{ template "otds.url" . }}/otdstenant/{{ .Values.otdsTenantID }}/otdsws
{{- else -}}
{{ template "otds.url" . }}/otdsws
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
OTDS Ingress URL path
*/}}
{{- define "otds.admin.url" -}}
{{ template "otds.public.url" . }}/otds-admin
{{- end -}}

{{/*
Image source path for the init-otds image including repo and tag
*/}}
{{- define "otiv.init.image.path" -}}
{{- $imageSource := default .Values.global.imageSource .Values.initialization.image.source | trimSuffix "/" -}}
{{ printf "%s/%s" $imageSource .Values.initialization.image.name }}:{{ .Values.initialization.image.tag }}
{{- end -}}

{{/*
Image source path including repo and tag
*/}}
{{- define "image.source.path" -}}
{{- $imageSource := default .Values.global.imageSource .Values.image.source | trimSuffix "/" -}}
{{ printf "%s/%s" $imageSource .Values.image.name }}:{{ .Values.image.tag }}
{{- end -}}

{{/*
Image pull policy
*/}}
{{- define "image.pull.policy" -}}
{{- if .Values.image -}}
{{ default .Values.global.imagePullPolicy .Values.image.pullPolicy }}
{{- else -}}
{{ .Values.global.imagePullPolicy }}
{{- end -}}
{{- end -}}

{{/*
The version
*/}}
{{- define "version.stamp" -}}
{{- if .Values.image.tag -}}
{{- .Values.image.tag -}}
{{- else -}}
{{- now | printf "%s" | trunc 19 -}}
{{- end -}}
{{- end -}}

{{- define "ingress.suffix" -}}
{{- if .Values.global.ingressIncludeNamespace -}}
-{{ .Release.Namespace }}.{{ .Values.global.ingressDomainName }}
{{- else -}}
.{{ .Values.global.ingressDomainName }}
{{- end -}}
{{- end -}}

{{/*
Ingress URL path
*/}}
{{- define "ingress.fqdn" -}}
{{ template "base.resource.name" . }}{{ template "ingress.suffix" .}}
{{- end -}}

{{/*
OTDS Ingress FQDN
*/}}
{{- define "ingress.fqdn.otds" -}}
{{ regexReplaceAllLiteral "^http(s?)://" ( include "otds.public.url" . ) "" | regexFind "[^:]+" | required "A valid .Values.global.otdsPublicUrl value with http(s)://domain is required" }}
{{- end -}}

{{/*
Asset Ingress URL path
*/}}
{{- define "ingress.fqdn.asset" -}}
{{- if .Values.global.ingressOtivAsset -}}
{{- if contains "." .Values.global.ingressOtivAsset -}}
{{ .Values.global.ingressOtivAsset }}
{{- else -}}
{{ .Values.global.ingressOtivAsset }}{{ template "ingress.suffix" $}}
{{- end -}}
{{- else -}}
{{- $data := dict "svc" "asset" "Values" .Values "Release" $.Release "Chart" .Chart  -}}
{{ template "base.resource.name.svc" $data }}{{ template "ingress.suffix" .}}
{{- end -}}
{{- end -}}

{{/*
Config Ingress URL path
*/}}
{{- define "ingress.fqdn.config" -}}
{{- if .Values.global.ingressOtivConfig -}}
{{- if contains "." .Values.global.ingressOtivConfig -}}
{{ .Values.global.ingressOtivConfig }}
{{- else -}}
{{ .Values.global.ingressOtivConfig }}{{ template "ingress.suffix" .}}
{{- end -}}
{{- else -}}
{{- $data := dict "svc" "config" "Values" .Values "Release" $.Release "Chart" .Chart  -}}
{{ template "base.resource.name.svc" $data }}{{ template "ingress.suffix" .}}
{{- end -}}
{{- end -}}

{{/*
Highlight Ingress URL path
*/}}
{{- define "ingress.fqdn.highlight" -}}
{{- if .Values.global.ingressOtivHighlight -}}
{{- if contains "." .Values.global.ingressOtivHighlight -}}
{{ .Values.global.ingressOtivHighlight }}
{{- else -}}
{{ .Values.global.ingressOtivHighlight }}{{ template "ingress.suffix" .}}
{{- end -}}
{{- else -}}
{{- $data := dict "svc" "highlight" "Values" .Values "Release" $.Release "Chart" .Chart  -}}
{{ template "base.resource.name.svc" $data }}{{ template "ingress.suffix" .}}
{{- end -}}
{{- end -}}

{{/*
Markup Ingress URL path
*/}}
{{- define "ingress.fqdn.markup" -}}
{{- if .Values.global.ingressOtivMarkup -}}
{{- if contains "." .Values.global.ingressOtivMarkup -}}
{{ .Values.global.ingressOtivMarkup }}
{{- else -}}
{{ .Values.global.ingressOtivMarkup }}{{ template "ingress.suffix" .}}
{{- end -}}
{{- else -}}
{{- $data := dict "svc" "markup" "Values" .Values "Release" $.Release "Chart" .Chart  -}}
{{ template "base.resource.name.svc" $data }}{{ template "ingress.suffix" .}}
{{- end -}}
{{- end -}}

{{/*
Metis Ingress URL path
*/}}
{{- define "ingress.fqdn.metis" -}}
{{- if .Values.global.ingressOtivMetis -}}
{{- if contains "." .Values.global.ingressOtivMetis -}}
{{ .Values.global.ingressOtivMetis }}
{{- else -}}
{{ .Values.global.ingressOtivMetis }}{{ template "ingress.suffix" .}}
{{- end -}}
{{- else -}}
{{- $data := dict "svc" "metis" "Values" .Values "Release" $.Release "Chart" .Chart  -}}
{{ template "base.resource.name.svc" $data }}{{ template "ingress.suffix" .}}
{{- end -}}
{{- end -}}

{{/*
Publication Ingress URL path
*/}}
{{- define "ingress.fqdn.publication" -}}
{{- if .Values.global.ingressOtivPublication -}}
{{- if contains "." .Values.global.ingressOtivPublication -}}
{{ .Values.global.ingressOtivPublication }}
{{- else -}}
{{ .Values.global.ingressOtivPublication }}{{ template "ingress.suffix" .}}
{{- end -}}
{{- else -}}
{{- $data := dict "svc" "publication" "Values" .Values "Release" $.Release "Chart" $.Chart  -}}
{{ template "base.resource.name.svc" $data }}{{ template "ingress.suffix" .}}
{{- end -}}
{{- end -}}

{{/*
Viewer Ingress URL path
*/}}
{{- define "ingress.fqdn.viewer" -}}
{{- if .Values.global.ingressOtivViewer -}}
{{- if contains "." .Values.global.ingressOtivViewer -}}
{{ .Values.global.ingressOtivViewer }}
{{- else -}}
{{ .Values.global.ingressOtivViewer }}{{ template "ingress.suffix" .}}
{{- end -}}
{{- else -}}
{{- $data := dict "svc" "viewer" "Values" .Values "Release" $.Release "Chart" $.Chart  -}}
{{ template "base.resource.name.svc" $data }}{{ template "ingress.suffix" .}}
{{- end -}}
{{- end -}}

{{- define "env.resource" -}}
{{- if .Values.global.cssFqdn -}}
          - name: RESOURCE
            value: 
{{- end -}}
{{- end -}}

{{/*
Returns a prefix of "otiv" or "cvt" depending on the target env
*/}}
{{- define "iv-cvt.product.prefix" -}}
{{- $prefix := "otiv" -}}
{{- if .Values.global.cssFqdn -}}
{{- $prefix = "cvt" -}}
{{- end -}}
{{- print $prefix -}}
{{- end -}}

{{- define "ocp.service.account" -}}
{{- if .Values.global.cssFqdn }}
      serviceAccountName: {{ default ( include "base.resource.name" . ) .Values.global.ocpServiceAccount }}
{{- end }}
{{- end -}}

{{/*
Outputs the yaml that extracts the secret for the service, plus the name of the env vars.
Placed within the env section of the deployment descriptor.
The argument is the service name, i.e. "publication"
*/}}
{{- define "env.secrets" -}}
{{- if .Values.global.cssFqdn -}}
          - name: AUTH_CLIENT_ID
{{- if eq .Chart.Name "highlight" }}
            value: brava-highlight-service
          - name: AUTH_CLIENT_SECRET
            value: placeHolder
{{- else if eq .Chart.Name "publication" }}
            value: blazon-publication-service
          - name: AUTH_CLIENT_SECRET
            value: placeHolder
{{- else if eq .Chart.Name "publisher" }}
            value: blazon-publisher
          - name: AUTH_CLIENT_SECRET
            value: placeHolder
{{- else if eq .Chart.Name "metis" }}
            value: brava-tester
          - name: AUTH_CLIENT_SECRET
            value: 
{{- end }}
{{- end -}}
{{- end -}}

{{- define "secretlink.container" -}}
{{- if .Values.global.secretlink.enabled }}
        - name: secretlink
          image: {{ default .Values.global.imageSource .Values.global.secretlink.image.source | trimSuffix "/" }}/{{ .Values.global.secretlink.image.name }}:{{ .Values.global.secretlink.image.tag }}
          env:
          {{- if .Values.global.secretlink.devMode }}
          - name: SL_DEV_MODE
            value: '{{ .Values.global.secretlink.devMode }}'
          - name: SL_DEV_PASSWORD
            value: '{{ .Values.global.secretlink.devPassword }}'
          - name: SL_DEV_KEYS
            value: '{{ .Values.global.secretlink.devKeys }}'
          {{- end }}
          - name: SL_LOGLEVEL
            value: {{ .Values.global.secretlink.loglevel }}
          - name: SL_VAULT_ADDR
            value: {{ .Values.global.secretlink.vault.address }}
          - name: SL_VAULT_MOUNTPOINT
            value: {{ .Values.global.secretlink.vault.mountpoint }}
          - name: SL_VAULT_PATH
            value: {{ .Values.global.secretlink.vault.path }}
          - name: SL_VAULT_NAMESPACE
            value: {{ .Values.global.secretlink.vault.namespace }}
          - name: SL_VAULT_AUTH_PATH
            value: {{ .Values.global.secretlink.vault.authpath }}
          - name: SL_VAULT_ROLE
            value: {{ .Values.global.secretlink.vault.role }}
          - name: SL_SEVERSHUTDOWNKEY
            value: ShutDownKey
          securityContext:
            runAsUser: 10001
          ports:
          - containerPort: 8000
          resources:
            requests:
              cpu: 50m
              memory: 64Mi
            limits:
              cpu: 250m
              memory: 128Mi
{{- end }}
{{- end -}}

{{- define "cloud.sql.proxy.container" -}}
{{- if .Values.global.database.gcpHostname -}}
        - name: cloud-sql-proxy
          # It is recommended to use the latest version of the Cloud SQL proxy
          # Make sure to update on a regular schedule!
          image: gcr.io/cloudsql-docker/gce-proxy:{{ .Values.global.cloudsqlproxy.image.tag }}
          command:
            - "/cloud_sql_proxy"
            - "-log_debug_stdout"
            - "-instances={{ .Values.global.database.gcpHostname }}=tcp:5432"
          securityContext:
            # The default Cloud SQL proxy image runs as the
            # "nonroot" user and group (uid: 65532) by default.
            runAsNonRoot: true
          resources:
            requests:
              cpu: {{ .Values.global.cloudsqlproxy.resources.requests.cpu }}
              memory: {{ .Values.global.cloudsqlproxy.resources.requests.memory }}
            limits:
              cpu: {{ .Values.global.cloudsqlproxy.resources.limits.cpu }}
              memory: {{ .Values.global.cloudsqlproxy.resources.limits.memory }}
{{- end -}}
{{- end -}}

{{/*
Amqp Port
*/}}
{{- define "amqp.port" -}}
{{- $amqpPort := default (.Values.global.amqp.ssl | ternary 5671 5672) .Values.global.amqp.port | int }}
{{- printf "'%d'" $amqpPort -}}
{{- end -}}

{{/*
Outputs the yaml that sets the env var for the postresql password
*/}}
{{- define "pg.env.password" -}}
{{- if .Values.global.ocp }}
          {{ template "gsm.project.number" . }}
          {{ template "gsm.sql.name" . }}
{{- end -}}
{{- end -}}


{{/*
Outputs the yaml that sets the env var for the rabbitmq password
*/}}
{{- define "rb.env.password" -}}
{{- if .Values.global.ocp -}}
          {{ template "gsm.amqp.name" . }}
{{- end -}}
{{- end -}}

{{/*
Outputs the yaml that sets the env vars for the postgresql and rabbitmq passwords
*/}}
{{- define "pg.rb.env.passwords" -}}
          {{ template "pg.env.password" . }}
          {{ template "rb.env.password" . }}
{{- end -}}



{{/*
Calcs checksum value based on the configmap and secret for passed in sub-chart
*/}}
{{- define "config.secret.checksum" -}}
{{- $configChecksum := include (print $.Template.BasePath "/configMap.yaml") . | sha256sum -}}
{{- printf "%s" $configChecksum -}}
{{- end -}}

{{/*
{{- define "iv-cvt.configmap" -}}
otiv-configmap
{{- end -}}
{{- $topConfigChecksum := include ("iv-cvt.configmap") . | sha256sum -}}
{{- printf "%s-%s" $configChecksum $topConfigChecksum -}}
*/}}

{{/*
Returns true if an OCP deployment
*/}}
{{- define "is.ocp" -}}
{{- if .Values.global.cssFqdn -}}
true
{{- else -}}
{{- end -}}
{{- end -}}


{{/*
Returns true if an IV deployment
*/}}
{{- define "is.iv" -}}
{{- if .Values.global.cssFqdn -}}
{{- else -}}
true
{{- end -}}
{{- end -}}

{{/*
Outputs the yaml that sets the env var for the OCP GCP project
*/}}
{{- define "gsm.project.number" -}}
          - name: OCP_PROJECT_NUMBER
            value: '{{ .Values.global.ocp.projectNumber }}'
{{- end -}}

{{/*
Outputs the yaml that sets the env var for the GSM AMQP secret name
*/}}
{{- define "gsm.amqp.name" -}}
          - name: OCP_AMQP_SECRET_NAME
            value: {{ .Values.global.ocp.gsmAmqpName }}
{{- end -}}

{{/*
Outputs the yaml that sets the env var for the GSM SQL secret name
*/}}
{{- define "gsm.sql.name" -}}
{{- if .Values.global.ocp -}}
          - name: OCP_SQL_SECRET_NAME
            value: {{ .Values.global.ocp.gsmSqlName }}
{{- end -}}
{{- end -}}

{{- define "timezone" -}}
{{- if .Values.global.timeZone }}
    TZ: {{ .Values.global.timeZone }}
{{- end }}
{{- end -}}

{{- define "node.forwarding" -}}
    DISABLE_FORWARDING: '{{ .Values.global.enableForwarding | ternary false true }}'
{{- end -}}

{{- define "cors.config" -}}
    ENFORCE_CORS_ORIGINS: '{{ hasKey .Values "enforceCorsOrigins" | ternary .Values.enforceCorsOrigins .Values.global.enforceCorsOrigins }}'
{{- if or .Values.global.corsOriginsList .Values.corsOriginsList }}
    CORS_ORIGINS_LIST: {{ default .Values.global.corsOriginsList .Values.corsOriginsList }}
{{- end }}
{{- if or .Values.global.corsOriginsRegex .Values.corsOriginsRegex }}
    CORS_ORIGINS_REGEX: '{{ default .Values.global.corsOriginsRegex .Values.corsOriginsRegex }}'
{{- end }}
{{- end }}

{{- define "forwarded.config" -}}
    ENFORCE_FORWARDED_HOSTS: '{{ hasKey .Values "enforceForwardedHosts" | ternary .Values.enforceForwardedHosts .Values.global.enforceForwardedHosts }}'
{{- if or .Values.global.forwardedHostsList .Values.forwardedHostsList }}
    FORWARDED_HOSTS_LIST: {{ default .Values.global.forwardedHostsList .Values.forwardedHostsList }}
{{- end }}
{{- if or .Values.global.forwardedHostsRegex .Values.forwardedHostsRegex }}
    FORWARDED_HOSTS_REGEX: '{{ default .Values.global.forwardedHostsRegex .Values.forwardedHostsRegex }}'
{{- end }}
{{- end }}

{{- define "new.relic.transform.config" -}}
{{- if .Values.global.newRelic.licenseKey }}
    RUNTIME_ENVIRONMENT: {{ hasKey .Values.global "cssFqdn" | ternary "cfar-ot2" "cfcr-iv" }}
    NEWRELIC_APP_NAME: {{ default .Values.global.ingressDomainName .Values.global.newRelic.baseAppName }}-{{ .Chart.Name }}
    NEWRELIC_KEY: {{ .Values.global.newRelic.licenseKey }}
    ENABLE_NEWRELIC: 'true'
{{- if .Values.global.newRelic.host }}
    NEWRELIC_HOST: {{ .Values.global.newRelic.host }}
    NEWRELIC_PORT: '{{ .Values.global.newRelic.port }}'
{{- end }}
{{- end }}
{{- end }}

{{- define "new.relic.viewing.config" -}}
{{- if .Values.global.newRelic.licenseKey }}
    NEW_RELIC_APP_NAME: {{ default .Values.global.ingressDomainName .Values.global.newRelic.baseAppName }}-{{ .Chart.Name }}
    NEW_RELIC_LICENSE_KEY: {{ .Values.global.newRelic.licenseKey }}
    NEW_RELIC_LOG_LEVEL: {{ .Values.newRelic.loglevel }}
{{- if .Values.global.newRelic.host }}
    NEW_RELIC_PROXY_URL: http://{{ .Values.global.newRelic.host }}:{{ .Values.global.newRelic.port }}
{{- end }}
{{- end }}
{{- end }}

{{- define "proxy.url.params" -}}
{{- if and .Values.global.proxy.host .Values.global.proxy.port }}
{{- if .Values.global.cssFqdn }}
    CVT_HTTP_PROXY:  http://{{ .Values.global.proxy.host }}:{{ .Values.global.proxy.port }}
    CVT_HTTPS_PROXY: http://{{ .Values.global.proxy.host }}:{{ .Values.global.proxy.port }}
    CVT_NO_PROXY: '{{ .Values.global.proxy.excludes | replace "|" "," }}'
{{- else }}
    http_proxy:  http://{{ .Values.global.proxy.host }}:{{ .Values.global.proxy.port }}
    https_proxy: http://{{ .Values.global.proxy.host }}:{{ .Values.global.proxy.port }}
    no_proxy: '{{ .Values.global.proxy.excludes | replace "|" "," }}'
{{- end }}
{{- end }}
{{- end }}

{{- define "proxy.params" -}}
{{- if .Values.global.proxy.host }}
    PROXY_HOST: {{ .Values.global.proxy.host }}
    PROXY_PORT: '{{ .Values.global.proxy.port }}'
    no_proxy: '{{ .Values.global.proxy.excludes | replace "," "|" }}'
{{- end }}
{{- end }}

{{- define "trusted.source.origins" -}}
{{- if and .Values.global.cssFqdn .Values.global.trustedSourceOrigins }}
    TRUSTED_SOURCE_ORIGINS: {{ .Values.global.trustedSourceOrigins }},{{ .Values.global.cssProtocol }}://{{ .Values.global.cssFqdn }},http://{{ include "iv-cvt.product.prefix" . }}-metis{{ template "ingress.suffix" . }},https://{{ include "iv-cvt.product.prefix" . }}-metis{{ template "ingress.suffix" . }},http://{{ include "iv-cvt.product.prefix" . }}-metis
{{- else if .Values.global.cssFqdn }}
    TRUSTED_SOURCE_ORIGINS: {{ .Values.global.cssProtocol }}://{{ .Values.global.cssFqdn }},http://{{ include "iv-cvt.product.prefix" . }}-metis{{ template "ingress.suffix" . }},https://{{ include "iv-cvt.product.prefix" . }}-metis{{ template "ingress.suffix" . }},http://{{ include "iv-cvt.product.prefix" . }}-metis
{{- else if .Values.global.trustedSourceOrigins }}
    TRUSTED_SOURCE_ORIGINS: {{ .Values.global.trustedSourceOrigins }}
{{- end }}
{{- if .Values.global.trustedSourceOriginsAnonymous }}
    TRUSTED_SOURCE_ORIGINS_ANONYMOUS: {{ .Values.global.trustedSourceOriginsAnonymous }}
{{- end }}
{{- end }}

{{- define "otiv.secret.env" -}}
{{- if (include "is.iv" .) }}
{{- if .Values.global.secretlink.enabled }}
    SECRET_MANAGER_TYPE: SecretLink
    SECRET_NAME: 'otiv-resource-secret'
{{- else }}
    SECRET_MANAGER_TYPE: k8s
{{- if .Values.global.otivSecretProviderClass.enabled }}
    SECRET_NAME: 'otiv-spc-secrets'
{{- else }}
    SECRET_NAME: '{{ .Values.existingSecret | default .Values.global.existingSecret | default "otiv-base-secrets" }}'
{{- end }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Additional labels for otiv pods
*/}}
{{- define "otiv.custom.labels" -}}
{{- if .Values.global.otivPodLabels }}
{{- toYaml .Values.global.otivPodLabels | trim | nindent 8 }}
{{- end }}
{{- if .Values.podLabels }}
{{- toYaml .Values.podLabels | trim | nindent 8 }}
{{- end }}
{{- end }}

{{/*
Sets service annotations
*/}}
{{- define "otiv.service.annotations" -}}
  {{- if or .Values.service.annotations .Values.global.service.annotations }}
  annotations:
  {{- end }}
  {{- if .Values.global.service.annotations }}
    {{- range .Values.global.service.annotations }}
    {{ . }}
    {{- end }}
  {{- end }}
  {{- if .Values.service.annotations }}
    {{- range .Values.service.annotations }}
    {{ . }}
    {{- end }}
  {{- end }}
{{- end }}

{{- define "cvt.probes" -}}
{{- $uriComponent := (eq .Chart.Name "highlight") | ternary "search" .Chart.Name -}}
        {{- if .Values.livenessProbe.enabled }}
          livenessProbe:
            httpGet:
              path: /{{ $uriComponent }}/api/v1/health/live
              port: http
            initialDelaySeconds:  {{ hasKey .Values.global "otcs" | ternary .Values.livenessProbe.initialDelaySecondsCS .Values.livenessProbe.initialDelaySeconds }}
            timeoutSeconds: {{ .Values.livenessProbe.timeoutSeconds }}
            periodSeconds: {{ .Values.livenessProbe.periodSeconds }}
            failureThreshold: {{ .Values.livenessProbe.failureThreshold }}
        {{- end }}
        {{- if .Values.readinessProbe.enabled }}
          readinessProbe:
            httpGet:
              path: /{{ $uriComponent }}/api/v1/health/ready
              port: http
            initialDelaySeconds: {{ .Values.readinessProbe.initialDelaySeconds }}
            timeoutSeconds: {{ .Values.readinessProbe.timeoutSeconds }}
            periodSeconds: {{ .Values.readinessProbe.periodSeconds }}
            failureThreshold: {{ .Values.readinessProbe.failureThreshold }}
        {{- end }}
        {{- if .Values.startupProbe.enabled }}
          startupProbe:
            httpGet:
              path: /{{ $uriComponent }}/api/v1/health/live
              port: http
            initialDelaySeconds:  {{ .Values.startupProbe.initialDelaySeconds }}
            timeoutSeconds: {{ .Values.startupProbe.timeoutSeconds }}
            periodSeconds: {{ .Values.startupProbe.periodSeconds }}
            failureThreshold: {{ hasKey .Values.global "otcs" | ternary .Values.startupProbe.failureThresholdCS .Values.startupProbe.failureThreshold }}
        {{- end }}
{{- end }}

{{/*
Sets terminationGracePeriodSeconds property in the transformation pods
*/}}
{{- define "transformation.grace.period" -}}
    {{- if .Values.global.transformationTerminantionGracePeriod }}
      terminationGracePeriodSeconds: {{ .Values.global.transformationTerminantionGracePeriod }}
    {{- end }}
{{- end }}

{{- define "topology.spread" -}}
{{- if .Values.global.topologyScheduling }}
      topologySpreadConstraints:
        - maxSkew: 1
          topologyKey: kubernetes.io/hostname
          whenUnsatisfiable: {{ .Values.global.topologyScheduling }}
          labelSelector:
            matchLabels:
              app.kubernetes.io/name: {{ .Chart.Name }}
              app.kubernetes.io/instance: {{ include "base.resource.name" . }}
            {{- if .Values.global.cssFqdn }}
              opentext.com/chart-hash: '{{ printf "%063d" 0 }}'
            {{- end }}
        - maxSkew: 1
          topologyKey: topology.kubernetes.io/zone
          whenUnsatisfiable: {{ .Values.global.topologyScheduling }}
          labelSelector:
            matchLabels:
              app.kubernetes.io/name: {{ .Chart.Name }}
              app.kubernetes.io/instance: {{ include "base.resource.name" . }}
            {{- if .Values.global.cssFqdn }}
              opentext.com/chart-hash: '{{ printf "%063d" 0 }}'
            {{- end }}
{{- end }}
{{- end }}

{{- define "otiv.cert.volume" -}}
{{- if .Values.global.enableOtivCustomizedTruststore }}
        - name: otiv-certs
          secret:
            secretName:  {{ default "otiv-certs" .Values.global.existingOtivCustomizedCertSecret }}
{{- else if .Values.global.otivSecretProviderClassCerts.enabled }}
        - name: otiv-certs
          csi:
            driver: secrets-store.csi.k8s.io
            readOnly: true
            volumeAttributes:
              secretProviderClass: otiv-spc-certs
{{- end }}
{{- end }}

{{- define "otiv.cert.volume.mount" -}}
{{- if or .Values.global.enableOtivCustomizedTruststore .Values.global.otivSecretProviderClassCerts.enabled }}
            - mountPath: /tmp/certs
              name: otiv-certs
{{- end }}
{{- end }}

{{- define "resources.cpu.memory" -}}
{{- if .Values.resources.enabled }}
          resources:
            {{- if .Values.resources.limits }}
            limits:
            {{- if .Values.resources.limits.cpu }}
              cpu: {{ .Values.resources.limits.cpu }}
            {{- end }}
            {{- if .Values.resources.limits.memory }}
              memory: {{ .Values.resources.limits.memory }}
            {{- end }}
            {{- end }}
            requests:
            {{- if .Values.resources.requests }}
            {{- if .Values.resources.requests.cpu }}
              cpu: {{ .Values.resources.requests.cpu }}
            {{- end }}
            {{- if .Values.resources.requests.memory }}
              memory: {{ .Values.resources.requests.memory }}
            {{- end }}
            {{- end }}
{{- end }}
{{- end }}

{{- define "ingress-otiv.host.svc" -}}
{{- $svc := .svc -}}
{{- $fqdnTemplate :=  printf "ingress.fqdn.%s" $svc -}}
{{- $subchartObj := index .Values $svc -}}
{{- $fqdnArg := dict "Values" .Values "Release" .Release -}}
  {{- if and $subchartObj.enabled $subchartObj.ingress -}}
  {{- if or $subchartObj.ingress.enabled (eq $svc "otds") }}
      - {{ include $fqdnTemplate $fqdnArg }}
 {{- end }}
 {{- end -}}
{{- end -}}

{{- define "ingress-otiv.rule.svc" -}}
{{- $svc := .svc -}}
{{- $fqdnTemplate :=  printf "ingress.fqdn.%s" $svc -}}
{{- $subchartObj := index .Values $svc -}}
{{- $fqdnArg := dict "Values" .Values "Release" .Release -}}
  {{- if and $subchartObj.enabled $subchartObj.ingress -}}
  {{- if or $subchartObj.ingress.enabled (eq $svc "otds") }}
  - host: {{ include $fqdnTemplate $fqdnArg }}
    http:
      paths:
      {{- if not .isV1ApiSupported }}
      - backend:
          {{- if eq $svc "otds" }}
          serviceName: {{ template "otds.service.name" $fqdnArg }}
          {{- else }}
          serviceName: {{ .chartName }}-{{ $svc }}
          {{- end }}
          servicePort: http
      {{- else }}
      - backend:
          service:
            {{- if eq $svc "otds" }}
            name:  {{ template "otds.service.name" $fqdnArg }}
            {{- else }}
            name: {{ .chartName }}-{{ $svc }}
            {{- end }}
            port:
              name: http
        path: /
        pathType: Prefix
      {{- end }}
  {{- end }}
  {{- end -}}
{{- end -}}

{{- define "hpa.target" -}}
    - type: ContainerResource
      containerResource:
        container: {{ include "base.resource.name" . }}
        name: cpu
        target:
{{- if eq (default .Values.global.hpa.targetType .Values.hpa.targetType) "utilization" }}
          type: Utilization
          averageUtilization: {{ .Values.hpa.utilization.cpu }}
{{- else }}
          type: AverageValue
          averageValue: {{ .Values.hpa.averageValue.cpu }}
{{- end }}
    - type: ContainerResource
      containerResource:
        container: {{ include "base.resource.name" . }}
        name: memory
        target:
{{- if eq (default .Values.global.hpa.targetType .Values.hpa.targetType) "utilization" }}
          type: Utilization
          averageUtilization: {{ .Values.hpa.utilization.memory }}
{{- else }}
          type: AverageValue
          averageValue: {{ .Values.hpa.averageValue.memory }}
{{- end }}
{{- end -}}


{{- define "onRootMismatch.policy" -}}
{{- if semverCompare ">=1.20-0" .Capabilities.KubeVersion.GitVersion }}
        fsGroupChangePolicy: "OnRootMismatch"
{{- end }}
{{- end -}}

{{- define "supportsAppProtocol" -}}
{{- if semverCompare ">=1.19-0" .Capabilities.KubeVersion.GitVersion -}}
{{- true -}}
{{- end -}}
{{- end -}}


{{- define "hazelcast.namespace" -}}
{{- if .Values.global.includeHazelcastNamespace }}
      hazelcastNS: {{ .Release.Namespace }}
{{- end }}
{{- end -}}

{{- define "hazelcast.namespace.deploy" -}}
{{- if .Values.global.includeHazelcastNamespace }}
        hazelcastNS: {{ .Release.Namespace }}
{{- end }}
{{- end -}}

{{- define "metadata.namespace" -}}
{{- if .Values.global.ocp }}
  namespace: {{ .Release.Namespace }}
{{- end }}
{{- end -}}

{{- define "dev-qa.node.pool" -}}
      {{- if hasSuffix "-dev-qa" .Release.Namespace }}
      # place on this nodepool with this label
      nodeSelector:
        type: dev-qa
      # allow on nodepool that have this taint
      tolerations:
        - key: dev-qa
          operator: Equal
          value: enabled
          effect: NoSchedule
      {{- end }}
{{- end -}}

