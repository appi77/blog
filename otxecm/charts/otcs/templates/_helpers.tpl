{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "otcs.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "otcs.fullname" -}}
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
{{- define "otcs.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "otcs.labels" -}}
app.kubernetes.io/name: {{ include "otcs.name" . }}
helm.sh/chart: {{ include "otcs.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Image source path including repo and tag
*/}}
{{- define "kubectl.image.source.path" -}}
{{- $imageSource := default .Values.global.imageSourcePublic .Values.kubectl.image.source | trimSuffix "/" -}}
{{ printf "%s/%s" $imageSource .Values.kubectl.image.name }}:{{ .Values.kubectl.image.tag }}
{{- end -}}

{{- define "otcs.statefulset" -}}
kind: StatefulSet
apiVersion: apps/v1
metadata:
  name: {{ .Chart.Name }}-{{ .pod_type }}
  labels:
    app.kubernetes.io/component: {{ .Chart.Name }}-{{ .pod_type }}
    {{- include (printf "%s%s" .Chart.Name ".labels" ) . | nindent 4 }}
spec:
  serviceName: {{ .Chart.Name }}-{{ .pod_type }}
  {{- if eq .pod_type "admin" }}
  replicas: {{ .Values.contentServerAdmin.replicas }}
  podManagementPolicy: {{ .Values.contentServerAdmin.podManagementPolicy | quote }}
  {{- else if eq .pod_type "da" }}
  replicas: {{ .Values.contentServerDa.replicas }}
  podManagementPolicy: {{ .Values.contentServerDa.podManagementPolicy | quote }}
  {{- else if eq .pod_type "frontend" }}
  replicas: {{ .Values.contentServerFrontend.replicas }}
  podManagementPolicy: {{ .Values.contentServerFrontend.podManagementPolicy | quote }}
  {{- else if eq .pod_type "backend-search" }}
  replicas: {{ .Values.contentServerBackendSearch.replicas }}
  podManagementPolicy: {{ .Values.contentServerBackendSearch.podManagementPolicy | quote }}
  {{- else }}
  {{- printf "Unsupported pod_type of %s" .pod_type }}
  {{- fail }}
  {{- end }}
  selector:
    matchLabels:
      app.kubernetes.io/component: {{ .Chart.Name }}-{{ .pod_type }}
      app.kubernetes.io/instance: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app.kubernetes.io/component: {{ .Chart.Name }}-{{ .pod_type }}
        app.kubernetes.io/instance: {{ .Release.Name }}
      {{- if .Values.podLabels }}
{{ toYaml .Values.podLabels | indent 8 }}
      {{- end }}
      {{- if .Values.podAnnotations }}
      annotations:
{{ toYaml .Values.podAnnotations | indent 8 }}
      {{- end }}
    spec:
      {{- if eq .Values.global.priorityClasses.enabled true }}
      {{- if eq .pod_type "admin" }}
      priorityClassName: {{ .Release.Name  }}-{{ .Release.Namespace }}-1
      {{- else if or (eq .pod_type "da") (eq .pod_type "frontend") (eq .pod_type "backend-search") }}
      priorityClassName: {{ .Release.Name  }}-{{ .Release.Namespace }}-2
      {{- end }}
      {{- end }}
      securityContext:
        # Since fsGroup is specified, all processes of the container are also part of the
        # supplementary group ID. The owner for volumes and any files created in the volume will
        # be Group ID 1000, which is otuser.
        fsGroup: 1000
        runAsUser: 1000
        {{- if or (and (eq .Capabilities.KubeVersion.Major "1") (ge .Capabilities.KubeVersion.Minor "23")) (gt .Capabilities.KubeVersion.Major "1") }}
        fsGroupChangePolicy: "OnRootMismatch"
        {{- end }}
      ## serviceAccountName defines the name of the service account the
      ## pods are running under. Normally that is 'default'
      serviceAccountName: {{ default .Values.global.serviceAccountName .Values.serviceAccountName }}
      terminationGracePeriodSeconds: 60
{{- if eq .pod_type "admin" }}
{{- if .Values.contentServerAdmin.nodeSelector }}
      nodeSelector:
{{- toYaml .Values.contentServerAdmin.nodeSelector | nindent 8 }}
{{- end }}
{{- if .Values.contentServerAdmin.affinity }}
      affinity:
{{- toYaml .Values.contentServerAdmin.affinity | nindent 8 }}
{{- end }}
{{- if .Values.contentServerAdmin.tolerations }}
      tolerations:
{{- toYaml .Values.contentServerAdmin.tolerations | nindent 8 }}
{{- end }}
{{- else if eq .pod_type "da" }}
{{- if .Values.contentServerDa.nodeSelector }}
      nodeSelector:
{{- toYaml .Values.contentServerDa.nodeSelector | nindent 8 }}
{{- end }}
{{- if .Values.contentServerDa.affinity }}
      affinity:
{{- toYaml .Values.contentServerDa.affinity | nindent 8 }}
{{- end }}
{{- if .Values.contentServerDa.tolerations }}
      tolerations:
{{- toYaml .Values.contentServerDa.tolerations | nindent 8 }}
{{- end }}
{{- else if eq .pod_type "frontend" }}
{{- if .Values.contentServerFrontend.nodeSelector }}
      nodeSelector:
{{- toYaml .Values.contentServerFrontend.nodeSelector | nindent 8 }}
{{- end }}
{{- if .Values.contentServerFrontend.affinity }}
      affinity:
{{- toYaml .Values.contentServerFrontend.affinity | nindent 8 }}
{{- end }}
{{- if .Values.contentServerFrontend.tolerations }}
      tolerations:
{{- toYaml .Values.contentServerFrontend.tolerations | nindent 8 }}
{{- end }}
{{- else if eq .pod_type "backend-search" }}
{{- if .Values.contentServerBackendSearch.nodeSelector }}
      nodeSelector:
{{- toYaml .Values.contentServerBackendSearch.nodeSelector | nindent 8 }}
{{- end }}
{{- if .Values.contentServerBackendSearch.affinity }}
      affinity:
{{- toYaml .Values.contentServerBackendSearch.affinity | nindent 8 }}
{{- end }}
{{- if .Values.contentServerBackendSearch.tolerations }}
      tolerations:
{{- toYaml .Values.contentServerBackendSearch.tolerations | nindent 8 }}
{{- end }}
{{- else }}
{{- end }}
    {{- $length := len .Values.initContainers }}
    {{- if gt $length 0 }}
      initContainers:
      {{- range .Values.initContainers }}
        - name: {{ .name }}
        {{- if ( regexFind "\\/$" .image.source ) }}
          image: "{{ default $.Values.global.imageSource .image.source }}{{ .image.name }}:{{ .image.tag }}"
        {{- else }}
          image: "{{ default $.Values.global.imageSource .image.source }}/{{ .image.name }}:{{ .image.tag }}"
        {{- end }}
          command: ['sh', '-c', 'cp -R /opt/extensions/backup/* /opt/extensions/mount || cp -R /opt/customizations/backup/* /opt/extensions/mount'] 
          imagePullPolicy: {{ default $.Values.global.imagePullPolicy $.Values.image.pullPolicy }}
          securityContext:
            allowPrivilegeEscalation: false
          volumeMounts:
            - mountPath: "/opt/extensions/mount"
              name: extensions-volume-mount
        {{- end }}
      {{- end }}
  {{- if eq $length 0 }}
      initContainers:
  {{- end }}
        {{- if eq .Values.rootSquashNFS.enabled true }}
        - name: perms-init
        {{- if ( regexFind "\\/$"  (default .Values.global.imageSourcePublic .Values.rootSquashNFS.image.source)  ) }}
          image: "{{ default .Values.global.imageSourcePublic .Values.rootSquashNFS.image.source  }}{{ .Values.rootSquashNFS.image.name }}:{{ .Values.rootSquashNFS.image.tag }}"
        {{- else }}
          image: "{{ default .Values.global.imageSourcePublic .Values.rootSquashNFS.image.source  }}/{{ .Values.rootSquashNFS.image.name }}:{{ .Values.rootSquashNFS.image.tag }}"
        {{- end }}
          command: ["sh", "-c", "chown -R 1000:1000 /opt/opentext/*"]
          imagePullPolicy: {{ default .Values.global.imagePullPolicy .Values.image.pullPolicy }}
          securityContext:
            runAsUser: 0
          volumeMounts:
            - mountPath: "/opt/opentext/extensions"
              name: extensions-volume-mount
            - mountPath: "/opt/opentext/cs_persist"
              name: cs-persist
            - mountPath: "/opt/opentext/multifile"
              name: {{ .Chart.Name }}-multifile
            {{- if or ( eq .pod_type "admin" ) ( eq .pod_type "backend-search" ) }}
            {{- if eq .Values.config.search.localSearch.enabled true }}
            - mountPath: "/opt/opentext/cs_index"
              name: {{ .Chart.Name }}-admin-index
            {{- end }}
            {{- if eq .Values.config.search.sharedSearch.enabled true }}
            - mountPath: "/opt/opentext/cs_index_shared"
              name: {{ .Chart.Name }}-admin-index-shared
            {{- end }}
            {{- end }}
            {{- if (eq .Values.objectimporter.enabled true) }}
            - mountPath: "/opt/opentext/sftp"
              name: sftp-volume
            {{- end }}
            {{- if eq .Values.config.contentProtection.enabled true }}
            - mountPath: "/opt/opentext/{{ .Values.config.contentProtection.path}}"
              name: {{ .Chart.Name }}-contentprotection
            {{- end }}
            {{- if eq .Values.config.storageProviderCache.enabled true }}
            - mountPath: "/opt/opentext/sp-cache"
              name: {{ .Chart.Name }}-storageprovidercache
            {{- end }}
            {{- range $volume := .Values.additionalVolumes }}
            - name: {{ $volume.name }} 
              mountPath: {{ $volume.mountPath }}
              {{- if ne $volume.mountOptions nil }}
              {{- toYaml $volume.mountOptions | nindent 14 }}
              {{- end }}
            {{- end }}
        {{- end }}
      containers:
{{- if eq .Values.fluentbit.enabled true }}
      - name: fluentbit-container
{{- if not (regexFind "\\/$" ( default .Values.global.imageSourcePublic .Values.fluentbit.image.source  ) ) }}
        image: {{ default .Values.global.imageSourcePublic .Values.fluentbit.image.source }}/{{ .Values.fluentbit.image.name }}:{{ .Values.fluentbit.image.tag }}
{{- else }}
        image: {{ default .Values.global.imageSourcePublic .Values.fluentbit.image.source }}{{ .Values.fluentbit.image.name }}:{{ .Values.fluentbit.image.tag }}
{{- end }}
        imagePullPolicy: {{ default .Values.global.imagePullPolicy .Values.image.pullPolicy }}
        env:
        - name: NAMESPACE
          value: {{ .Release.Namespace }}
        - name: VERSION
          value: {{ .Chart.Version }}
{{- if (eq .Values.fluentbit.proxy.enabled true)}}
{{- if (eq .Values.fluentbit.proxy.enableauthentication true)}}
        - name: HTTP_PROXY
          value: http://{{ .Values.fluentbit.proxy.username }}:{{ .Values.fluentbit.proxy.password }}@{{.Values.fluentbit.proxy.host}}:{{.Values.fluentbit.proxy.port}}
{{- end }}
{{- if (eq .Values.fluentbit.proxy.enableauthentication false)}}
        - name: HTTP_PROXY
          value: http://{{.Values.fluentbit.proxy.host}}:{{.Values.fluentbit.proxy.port}}
{{- end }}
{{- end }}
{{- if eq .Values.fluentbit.readinessProbe.enabled true }}
        readinessProbe:
          httpGet:
            path: /
            port: 2020
          initialDelaySeconds: {{ .Values.fluentbit.readinessProbe.initialDelaySeconds }}
          timeoutSeconds: {{ .Values.fluentbit.readinessProbe.timeoutSeconds }}
          periodSeconds: {{ .Values.fluentbit.readinessProbe.periodSeconds }}
{{- end }}
{{- if eq .Values.fluentbit.livenessProbe.enabled true }}
        livenessProbe:
          httpGet:
            path: /
            port: 2020
          initialDelaySeconds: {{ .Values.fluentbit.livenessProbe.initialDelaySeconds }}
          timeoutSeconds: {{ .Values.fluentbit.livenessProbe.timeoutSeconds }}
          periodSeconds: {{ .Values.fluentbit.livenessProbe.periodSeconds }}
          failureThreshold: {{ .Values.fluentbit.livenessProbe.failureThreshold }}
{{- end }}
        resources:
          limits:
            cpu: 300m
            memory: 200Mi
          requests:
            cpu: 100m
            memory: 100Mi
        ports:
        # fluent-bit port:
        - containerPort: 2020
        volumeMounts:
        - mountPath: "/opt/opentext/cs/logs"
          name: logs
        - mountPath:  /fluent-bit/etc/
          name: fluentbit-config
        - mountPath: /fluent-bit/scripts/
          name: fluentbitlua-config
{{- end }}
      - name: {{ .Chart.Name }}-{{ .pod_type }}-container
{{- if not (regexFind "\\/$" ( default .Values.global.imageSource .Values.image.source ) ) }}
        image: {{ default .Values.global.imageSource .Values.image.source }}/{{ .Values.image.name }}:{{ .Values.image.tag }}
{{- else }}
        image: {{ default .Values.global.imageSource .Values.image.source }}{{ .Values.image.name }}:{{ .Values.image.tag }}
{{- end }}
        imagePullPolicy: {{ default .Values.global.imagePullPolicy .Values.image.pullPolicy }}
{{- if eq (default .Values.global.secretlink.enabled .Values.secretlink.enabled) false }}
        command: ['sh', '-c', 'until [ "$(curl -s -w ''%{http_code}'' -o /dev/null http://localhost:8000/readyz)" -eq 200 ]; do echo "Waiting for Kubernetes API to be ready"; sleep 10; done; /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf']
{{- end }}
        env:
        - name: OTCS_BACKEND_SEARCH_REPLICAS
          value: {{ .Values.contentServerBackendSearch.replicas | quote }}
        - name: OTCS_FRONTEND_REPLICAS
          value: {{ .Values.contentServerFrontend.replicas | quote }}
        - name: OTCS_TYPE
          {{- if eq .pod_type "admin" }}
          value: primary
          {{- else }}
          value: secondary
          {{- end }}
        - name: OTCS_CONTAINER_LOG_LEVEL
          value: {{ .Values.containerLogLevel }}
        - name: OTCS_ROLE
          value: {{ .pod_type }}
          {{- if (.Values.global.otds.enabled) }}
        - name: OTDS_SERVICE_NAME
          value: {{ include "otxecm.otdsServiceName" . }}
          {{- end }}
        - name: SHARED_ADDRESS_SPACE_NAT
          value: {{ .Values.sharedAddressSpaceNat.enabled | quote }}
        - name: TZ
          value: {{ default .Values.global.timeZone .Values.config.timeZone }}
        - name: PGHOST
          value: {{ default .Values.global.database.hostname .Values.config.database.hostname | quote  }}
        - name: PGPORT
          value: {{ default .Values.global.database.port .Values.config.database.port | quote }}
        - name: PGUSER
          value: {{ default .Values.global.database.adminUsername .Values.config.database.adminUsername | quote }}
        - name: PGDATABASE
          value: {{ default .Values.global.database.adminDatabase .Values.config.database.adminDatabase | quote }}
        - name: MAX_THREAD_LIFESPAN
          value: {{ .Values.livenessProbe.maxThreadLifespan | quote }}
        - name: OTXECM_SECRET_NAME
          value: {{ .Values.global.existingSecret }}
        - name: UALEnabled
          value: {{ .Values.config.ual.enabled | quote}}
        - name: RESTART_AUTOMATION_TIME
          value: {{ .Values.config.restartAutomationTime | quote }}
{{- if eq .Values.readinessProbe.enabled true }}
        readinessProbe:
            exec:
              command:
                - "/opt/opentext/container_files/bash/check_cs_readiness.sh"
            initialDelaySeconds: {{ .Values.readinessProbe.initialDelaySeconds }}
            timeoutSeconds: {{ .Values.readinessProbe.timeoutSeconds }}
            periodSeconds: {{ .Values.readinessProbe.periodSeconds }}
{{- end }}
{{- if eq .Values.livenessProbe.enabled true }}
        livenessProbe:
            exec:
              command:
                - "/opt/opentext/container_files/bash/check_cs_liveness.sh"
            initialDelaySeconds: {{ .Values.livenessProbe.initialDelaySeconds }}
            timeoutSeconds: {{ .Values.livenessProbe.timeoutSeconds }}
            periodSeconds: {{ .Values.livenessProbe.periodSeconds }}
            failureThreshold: {{ .Values.livenessProbe.failureThreshold }}
{{- end }}
{{- if eq .pod_type "admin" }}
    {{- if or (eq ( default .Values.global.resourceRequirements .Values.contentServerAdmin.resources.enabled) true) }}
        resources:
          limits:
            cpu: {{ .Values.contentServerAdmin.resources.limits.cpu }}
            memory: {{ .Values.contentServerAdmin.resources.limits.memory }}
          requests:
            cpu: {{ .Values.contentServerAdmin.resources.requests.cpu }}
            memory: {{ .Values.contentServerAdmin.resources.requests.memory }}
    {{- end }}
{{- else if eq .pod_type "da" }}
    {{- if (eq ( default .Values.global.resourceRequirements .Values.contentServerDa.resources.enabled) true) }}
        resources:
          limits:
            cpu: {{ .Values.contentServerDa.resources.limits.cpu }}
            memory: {{ .Values.contentServerDa.resources.limits.memory }}
          requests:
            cpu: {{ .Values.contentServerDa.resources.requests.cpu }}
            memory: {{ .Values.contentServerDa.resources.requests.memory }}
    {{- end }}
{{- else if eq .pod_type "frontend" }}
    {{- if (eq ( default .Values.global.resourceRequirements .Values.contentServerFrontend.resources.enabled) true) }}
        resources:
          limits:
            cpu: {{ .Values.contentServerFrontend.resources.limits.cpu }}
            memory: {{ .Values.contentServerFrontend.resources.limits.memory }}
          requests:
            cpu: {{ .Values.contentServerFrontend.resources.requests.cpu }}
            memory: {{ .Values.contentServerFrontend.resources.requests.memory }}
    {{- end }}
{{- else if eq .pod_type "backend-search" }}
    {{- if  (eq ( default .Values.global.resourceRequirements .Values.contentServerBackendSearch.resources.enabled ) true) }}
        resources:
          limits:
            cpu: {{ .Values.contentServerBackendSearch.resources.limits.cpu }}
            memory: {{ .Values.contentServerBackendSearch.resources.limits.memory }}
          requests:
            cpu: {{ .Values.contentServerBackendSearch.resources.requests.cpu }}
            memory: {{ .Values.contentServerBackendSearch.resources.requests.memory }}
    {{- end }}
{{- else }}
    {{- printf "Unsupported pod_type of %s" .pod_type }}
    {{- fail }}
{{- end }}
        ports:
        # Content Server ports:
        - containerPort: 2099
        {{- if or (eq .pod_type "admin") (eq .pod_type "backend-search") }}
        # admin-server
        - containerPort: 5858
        {{- end }}
        # Tomcat port:
        - containerPort: 8080
        volumeMounts:
        - mountPath: "/opt/opentext/extensions"
          name: extensions-volume-mount
        - mountPath: "/opt/opentext/cs_persist"
          name: cs-persist
        - mountPath: "/opt/opentext/multifile"
          name: {{ .Chart.Name }}-multifile
        - mountPath: "/opt/opentext/cs/logs"
          name: logs
{{- if (eq .Values.objectimporter.enabled true) }}
        - mountPath: "/opt/opentext/sftp"
          name: sftp-volume
{{- end }}
{{- if eq .Values.config.contentProtection.enabled true }}
        - mountPath: "/opt/opentext/{{ .Values.config.contentProtection.path}}"
          name: {{ .Chart.Name }}-contentprotection
{{- end }}
{{- if eq .Values.config.storageProviderCache.enabled true }}
        - mountPath: "/opt/opentext/sp-cache"
          name: {{ .Chart.Name }}-storageprovidercache
{{- end }}
        - mountPath: "/opt/opentext/container_files/custom_config/config.yaml"
          name: config
          subPath: config.yaml
        {{- if or (eq .pod_type "admin") (eq .pod_type "backend-search") }}
        {{- if not (or (eq .Values.config.search.localSearch.enabled true) (eq .Values.config.search.sharedSearch.enabled true))}}
          {{- fail "You must enable at least one of otcs.config.search.localSearch.enabled or otcs.config.search.sharedSearch.enabled" }}
        {{- end }}
        {{- if eq .Values.config.search.localSearch.enabled true }}
        - mountPath: "/opt/opentext/cs_index"
          name: {{ .Chart.Name }}-admin-index
        {{- end }}
        {{- if eq .Values.config.search.sharedSearch.enabled true }}
        - mountPath: "/opt/opentext/cs_index_shared"
          name: {{ .Chart.Name }}-admin-index-shared
        {{- end }}
        {{- end }}
{{- if eq .Values.config.documentStorage.type "efs" }}
        - mountPath: {{ .Values.config.documentStorage.efsPath | quote }}
          name: {{ .Chart.Name }}-efs
{{- end }}
{{- if eq .Values.config.ual.enabled true }}
    {{- if .Values.config.ual.certSecret }}
        - mountPath: "/opt/opentext/container_files/custom_config/{{ .Values.config.ual.certFilename }}"
          name: {{ .Chart.Name }}-archive-cert
          subPath: {{ .Values.config.ual.certFilename }}
    {{- else }}
        - mountPath: "/opt/opentext/container_files/custom_config/{{ .Values.config.ual.certFilename }}"
          name: {{ .Chart.Name }}-archive-cert-configmap
          subPath: {{ .Values.config.ual.certFilename }}
    {{- end }}
{{- else }}
  {{- if eq .Values.config.documentStorage.type "otac"}}
    {{- if .Values.config.otac.certSecret }}
        - mountPath: "/opt/opentext/container_files/custom_config/{{ .Values.config.otac.certFilename }}"
          name: {{ .Chart.Name }}-archive-cert
          subPath: {{ .Values.config.otac.certFilename }}
    {{- else }}
        - mountPath: "/opt/opentext/container_files/custom_config/{{ .Values.config.otac.certFilename }}"
          name: {{ .Chart.Name }}-archive-cert-configmap
          subPath: {{ .Values.config.otac.certFilename }}
    {{- end }}
  {{- else if eq .Values.config.documentStorage.type "otacc"}}
    {{- if .Values.config.otacc.certSecret }}
        - mountPath: "/opt/opentext/container_files/custom_config/{{ .Values.config.otacc.certFilename }}"
          name: {{ .Chart.Name }}-archive-cert
          subPath: {{ .Values.config.otacc.certFilename }}
    {{- else }}
        - mountPath: "/opt/opentext/container_files/custom_config/{{ .Values.config.otacc.certFilename }}"
          name: {{ .Chart.Name }}-archive-cert-configmap
          subPath: {{ .Values.config.otacc.certFilename }}
    {{- end }}
  {{- end }}
{{- end }}
{{- range $volume := .Values.additionalVolumes }}
        - name: {{ $volume.name }}
          mountPath: {{ $volume.mountPath }}
          {{- if ne $volume.mountOptions nil }}
          {{- toYaml $volume.mountOptions | nindent 10 }}
          {{- end }}
{{- end }}

{{- if eq .Values.loadAdminSettings.enabled true }}
        # This is an XML file containing admin settings to be
        # applied to Content Server on initial container start. There is a
        # corresponding configmap with the name
        # '{{ .Chart.Name }}-adminsettings-initial-configmap' in the file otcs-configmaps.yaml
        - mountPath: "/opt/opentext/container_files/custom_config/admin_settings/initial"
          name: {{ .Chart.Name }}-adminsettings-initial-configmap
        # This is an XML file containing admin settings to be
        # applied to Content Server on every container start. There is a
        # corresponding configmap with the name
        # '{{ .Chart.Name }}-adminsettings-recurrent-configmap' in the file otcs-configmaps.yaml
        - mountPath: "/opt/opentext/container_files/custom_config/admin_settings/recurrent"
          name: {{ .Chart.Name }}-adminsettings-recurrent-configmap
{{- end }}
{{- if eq .Values.loadLicense.enabled true }}
  {{- if .Values.global.existingLicenseSecret }}
        - mountPath: "/opt/opentext/container_files/custom_config/{{ .Values.loadLicense.filename }}"
          name: license-secrets
          subPath: {{ .Values.loadLicense.filename }}
  {{- else }}
        # This is an XML file containing a Content Server license to be
        # applied to Content Server on first container start.
        - mountPath: "/opt/opentext/container_files/custom_config/{{ .Values.loadLicense.filename }}"
          name: {{ .Chart.Name }}-license-configmap
          subPath: {{ .Values.loadLicense.filename }}
  {{- end }}
{{- end }}
{{- if eq .Values.config.database.oracle.loadTnsnames.enabled true }}
        - mountPath: "/opt/oracle/tnsnames.ora"
          name: {{ .Chart.Name }}-tnsnames-configmap
          subPath: {{ .Values.config.database.oracle.loadTnsnames.filename }}
{{- end }}
{{- if eq .Values.fluentbit.enabled true }}
        - mountPath:  /opt/opentext/fluentbit/
          name: fluentbit-config
        - mountPath: /opt/opentext/fluentbit/scripts/
          name: fluentbitlua-config
{{- end }}
        securityContext:
          allowPrivilegeEscalation: false
          runAsNonRoot: true
{{- if eq (default .Values.global.secretlink.enabled .Values.secretlink.enabled) true }}
      - name: secretlink-container
{{- if not (regexFind "\\/$" ( default .Values.global.imageSource (default .Values.global.secretlink.image.source .Values.secretlink.image.source) ) ) }}
        image: {{ default .Values.global.imageSource (default .Values.global.secretlink.image.source .Values.secretlink.image.source) }}/{{ default .Values.global.secretlink.image.name .Values.secretlink.image.name }}:{{ default .Values.global.secretlink.image.tag .Values.secretlink.image.tag }}
{{- else }}
        image: {{ default .Values.global.imageSource (default .Values.global.secretlink.image.source .Values.secretlink.image.source) }}{{ default .Values.global.secretlink.image.name .Values.secretlink.image.name }}:{{ default .Values.global.secretlink.image.tag .Values.secretlink.image.tag }}
{{- end }}
        imagePullPolicy: {{ default .Values.global.imagePullPolicy .Values.image.pullPolicy }}
        securityContext:
          runAsUser: 10001
        env:
        - name: SL_LOGLEVEL
          value: {{ default .Values.global.secretlink.loglevel .Values.secretlink.loglevel }}
        - name: SL_VAULT_ADDR
          value: {{ default .Values.global.secretlink.vault.address .Values.secretlink.vault.address }}
        - name: SL_VAULT_MOUNTPOINT
          value: {{ default .Values.global.secretlink.vault.mountpoint .Values.secretlink.vault.mountpoint }}
        - name: SL_VAULT_PATH
          value: {{ default .Values.global.secretlink.vault.path .Values.secretlink.vault.path }}
        - name: SL_VAULT_NAMESPACE
          value: {{ default .Values.global.secretlink.vault.namespace .Values.secretlink.vault.namespace | quote}}
        - name: SL_VAULT_AUTH_PATH
          value: {{ default .Values.global.secretlink.vault.authpath .Values.secretlink.vault.authpath }}
        - name: SL_VAULT_ROLE
          value: {{ default .Values.global.secretlink.vault.role .Values.secretlink.vault.role | quote}}
        resources:
          requests:
            cpu: 50m
            memory: 64Mi
          limits:
            cpu: 250m
            memory: 128Mi
{{- end }}
{{- if eq (default .Values.global.secretlink.enabled .Values.secretlink.enabled) false }}
      - name: kubectl-proxy
        image: {{ include "kubectl.image.source.path" . }}
        imagePullPolicy: {{ default .Values.global.imagePullPolicy .Values.image.pullPolicy }}
        command: ['sh', '-c']
        args:
        - |
          kubectl proxy --port=8000 --address=127.0.0.1 &
          kubectl proxy --port=8000 --address=[::1] &
          wait
        ports:
            - containerPort: 8000
{{- end }}
      volumes:
        {{- range $volume := .Values.additionalVolumes }}
        - name: {{ $volume.name }}
          {{- if ne $volume.volumeOptions nil }}
          {{- toYaml $volume.volumeOptions | nindent 10 }}
          {{- end }}
        {{- end }}
        - name: extensions-volume-mount
          emptyDir: {}
        - name: config
          configMap:
{{- if eq .pod_type "admin" }}
            name: {{ .Chart.Name }}-admin-configmap
{{- else if eq .pod_type "da" }}
            name: {{ .Chart.Name }}-da-configmap
{{- else if eq .pod_type "frontend" }}
            name: {{ .Chart.Name }}-frontend-configmap
{{- else if eq .pod_type "backend-search" }}
            name: {{ .Chart.Name }}-backend-search-configmap
{{- else }}
           {{- printf "Unsupported pod_type of %s" .pod_type }}
           {{- fail }}
{{- end }}
{{- if eq .Values.loadLicense.enabled true }}
  {{- if .Values.global.existingLicenseSecret }}
        - name: license-secrets
          secret:
            secretName: {{ .Values.global.existingLicenseSecret }}
            items:
            - key: {{ .Values.loadLicense.filename }}
              path: {{ .Values.loadLicense.filename }}
  {{- else }}
        # Used for Content Server license
        - name: {{ .Chart.Name }}-license-configmap
          configMap:
            name: {{ .Chart.Name }}-license-configmap
  {{- end }}
{{- end }}
{{- if eq  .Values.config.ual.enabled true }}
  {{- if .Values.config.ual.certSecret }}
        - name: {{ .Chart.Name }}-archive-cert
          secret:
            secretName: {{ .Values.config.ual.certSecret }}
            items:
            - key: {{ .Values.config.ual.certFilename }}
              path: {{ .Values.config.ual.certFilename }}
  {{- else }}
      # Used for Archive Center certificate file:
        - name: {{ .Chart.Name }}-archive-cert-configmap
          configMap:
            name: {{ .Chart.Name }}-archive-cert-configmap
  {{- end }}
{{- else }}
  {{- if or (eq .Values.config.documentStorage.type "otac") (eq .Values.config.documentStorage.type "otacc") }}
    {{- if .Values.config.otac.certSecret }}
        - name: {{ .Chart.Name }}-archive-cert
          secret:
            secretName: {{ .Values.config.otac.certSecret }}
            items:
            - key: {{ .Values.config.otac.certFilename }}
              path: {{ .Values.config.otac.certFilename }}
    {{- else if .Values.config.otacc.certSecret }}
        - name: {{ .Chart.Name }}-archive-cert
          secret:
            secretName: {{ .Values.config.otacc.certSecret }}
            items:
            - key: {{ .Values.config.otacc.certFilename }}
              path: {{ .Values.config.otacc.certFilename }}
    {{- else }}
        # Used for Archive Center certificate file:
        - name: {{ .Chart.Name }}-archive-cert-configmap
          configMap:
            name: {{ .Chart.Name }}-archive-cert-configmap
    {{- end }}
  {{- end }}
{{- end }}
{{- if (eq .Values.objectimporter.enabled true) }}
        - name: sftp-volume
          persistentVolumeClaim:
            claimName: sftp-volume
{{- end }}
{{- if eq .Values.config.contentProtection.enabled true }}
        - name: {{ .Chart.Name }}-contentprotection
          persistentVolumeClaim:
            claimName: {{ .Chart.Name }}-contentprotection
{{- end }}
{{- if eq .Values.config.storageProviderCache.enabled true }}
        - name: {{ .Chart.Name }}-storageprovidercache
          persistentVolumeClaim:
            claimName: {{ .Chart.Name }}-storageprovidercache
{{- end }}
{{- if eq .Values.config.database.oracle.loadTnsnames.enabled true }}
        # Used for oracle tnsnames.ora
        - name: {{ .Chart.Name }}-tnsnames-configmap
          configMap:
            name: {{ .Chart.Name }}-tnsnames-configmap
{{- end }}
{{- if eq .Values.loadAdminSettings.enabled true }}
        # Used for custom admin settings (llconfig):
        - name: {{ .Chart.Name }}-adminsettings-initial-configmap
          configMap:
            name: {{ default ( printf "%s-adminsettings-initial-configmap" .Chart.Name ) .Values.loadAdminSettings.initialConfigmap }}
        # Used for custom admin settings (llconfig):
        - name: {{ .Chart.Name }}-adminsettings-recurrent-configmap
          configMap:
            name: {{ default ( printf "%s-adminsettings-recurrent-configmap" .Chart.Name ) .Values.loadAdminSettings.recurrentConfigmap }}
{{- end }}
{{- if eq .Values.config.search.sharedSearch.enabled true }}
        - name: {{ .Chart.Name }}-admin-index-shared
          persistentVolumeClaim:
            claimName: {{ .Chart.Name }}-admin-index-shared
{{- end }}
{{- if eq .Values.config.documentStorage.type "efs" }}
        # Used for shared EFS (External File System for Document Storage):
        - name: {{ .Chart.Name }}-efs
          persistentVolumeClaim:
            claimName: {{ .Chart.Name }}-efs
{{- end }}
        - name: {{ .Chart.Name }}-multifile
          emptyDir:
            sizeLimit: {{ .Values.multifileStorage }}
{{- if eq .Values.fluentbit.enabled true }}
        - name: fluentbit-config
          configMap:
            name: {{ .Chart.Name }}-fluentbit-configmap
            items:
            - key: fluent-bit.conf
              path: fluent-bit.conf
            - key: cs-parsers.conf
              path: cs-parsers.conf
            - key: connect-logs-filter.conf
              path: connect-logs-filter.conf
            - key: dcs-logs-filter.conf
              path: dcs-logs-filter.conf
            - key: search-logs-filter.conf
              path: search-logs-filter.conf
            - key: security-logs-filter.conf
              path: security-logs-filter.conf
            - key: system-monitoring-logs.conf
              path: system-monitoring-logs.conf
            - key: thread-logs-filter.conf
              path: thread-logs-filter.conf
            - key: timings-logs-filter.conf
              path: timings-logs-filter.conf
            - key: include.conf
              path: include.conf
        - name: fluentbitlua-config
          configMap:
            name: {{ .Chart.Name }}-fluentbit-lua-configmap
{{- end }}
{{- if or .Values.image.pullSecret .Values.global.imagePullSecret }}
      imagePullSecrets:
      - name: {{ default .Values.global.imagePullSecret .Values.image.pullSecret }}
{{- end }}
  volumeClaimTemplates:
  - metadata:
      name: cs-persist
      {{- if .Values.pvc.csPersist.labels }}
      labels:
        {{- range .Values.pvc.csPersist.labels }}
        {{ . }}
        {{- end }}
      {{- end }}
    spec:
      accessModes:
        - ReadWriteOnce
{{- if or .Values.global.storageClassName .Values.storageClassName }}
      storageClassName: {{ default .Values.global.storageClassName .Values.storageClassName | quote}}
{{- end }}
      resources:
        requests:
          storage: {{ .Values.csPersist.storage }}
  - metadata:
      name: logs
      {{- if .Values.pvc.logs.labels }}
      labels:
        {{- range .Values.pvc.logs.labels }}
        {{ . }}
        {{- end }}
      {{- end }}
    spec:
      accessModes:
        - ReadWriteOnce
{{-  if .Values.csPersist.logStorageClassName }}
      storageClassName: {{ .Values.csPersist.logStorageClassName | quote }}
{{- else if or .Values.global.storageClassName .Values.storageClassName }}
      storageClassName: {{ default .Values.global.storageClassName .Values.storageClassName | quote }}
{{- end }}
      resources:
        requests:
          storage: {{ .Values.csPersist.logStorage }}
{{- if or (eq .pod_type "admin") (eq .pod_type "backend-search") }}
{{- if eq .Values.config.search.localSearch.enabled true }}
  - metadata:
      name: {{ .Chart.Name }}-admin-index
    spec:
      accessModes:
        - ReadWriteOnce
{{- if or .Values.global.storageClassName .Values.storageClassName }}
      storageClassName: {{ default .Values.global.storageClassName .Values.storageClassName | quote  }}
{{- end }}
      resources:
        requests:
          storage: {{ .Values.config.search.localSearch.storage }}
{{- end }}
{{- end }}
---
{{- end }}
