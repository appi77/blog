{{/*
Validation of values provided by an existing Kubernetes secret
*/}}

{{- $secretlink_enabled := false }}
{{- if eq .Values.global.secretlink.enabled  true }}
    {{- $secretlink_enabled = true }}
{{- else if eq .Values.global.otcs.enabled  true}}
    {{- if eq (default false .Values.otcs.secretlink.enabled) true }}
        {{- $secretlink_enabled = true }}
    {{- end}}
{{- end}}

{{-  if (eq $secretlink_enabled false) }}
    {{- $secret_object := lookup "v1" "Secret" .Release.Namespace .Values.global.existingSecret }}
    {{- if and (ne .Values.global.existingSecret "otxecm-default-secrets") $secret_object }}
        {{- if not $secret_object.data }}
            {{- fail "\n\nError: keys from the existing secret set at .Values.global.existingSecret must be defined under the data section.\n" }}
        {{- end }}
        {{- $secrets := $secret_object.data }}
        {{- if eq .Values.global.otcs.enabled true }}
            {{- if not $secrets.DATA_ENCRYPTION_KEY }}
                {{- fail "\n\nError: existing secret from .Values.global.existingSecret must set a DATA_ENCRYPTION_KEY.\n" }}
            {{- else if not $secrets.ADMIN_USER_PASSWORD }}
                {{- fail "\n\nError: existing secret from global.existingSecret must set an ADMIN_USER_PASSWORD since global.otcs.enabled is true.\n" }}
            {{- else if not $secrets.ADMIN_SERVER_PASSWORD }}
                {{- fail "\n\nError: existing secret from global.existingSecret must set an ADMIN_SERVER_PASSWORD since global.otcs.enabled is true.\n" }}
            {{- else if not $secrets.AUTO_SYS_ADMIN_PASSWORD }}
                {{- fail "\n\nError: existing secret from global.existingSecret must set an AUTO_SYS_ADMIN_PASSWORD since global.otcs.enabled is true.\n" }}
            {{- else if not $secrets.SYS_SUPPORT_PASSWORD }}
                {{- fail "\n\nError: existing secret from global.existingSecret must set a SYS_SUPPORT_PASSWORD since global.otcs.enabled is true.\n" }}
            {{- else if not $secrets.ALFILTER_USER_PASSWORD }}
                {{- fail "\n\nError: existing secret from global.existingSecret must set an ALFILTER_USER_PASSWORD since global.otcs.enabled is true.\n" }}
            {{- else if not $secrets.OTCS_DB_ADMIN_PASSWORD }}
                {{- fail "\n\nError: existing secret from global.existingSecret must set a OTCS_DB_ADMIN_PASSWORD since global.otcs.enabled is true.\n" }}
            {{- else if not $secrets.DB_PASSWORD }}
                {{- fail "\n\nError: existing secret from global.existingSecret must set a DB_PASSWORD since global.otcs.enabled is true.\n" }}
            {{- else if and (eq .Values.otcs.config.documentStorage.type "otacc") (not $secrets.AC_CORE_PASSWORD) }}
                {{- fail "\n\nError: existing secret from global.existingSecret must set a AC_CORE_PASSWORD since OTCS is set to use OTACC.\n" }}
            {{- else if and (eq .Values.otcs.config.createAppMonitorUser true) (not $secrets.APPMONITOR_PASSWORD) }}
                {{- fail "\n\nError: existing secret from global.existingSecret must set a APPMONITOR_PASSWORD since otcs.config.createAppMonitorUser is true.\n" }}
            {{- else if and (eq .Values.otcs.config.enableSynchronizedPartition true) ( not $secrets.LDAP_BIND_PASSWORD )}}
                {{- fail "\n\nError: existing secret from global.existingSecret must set a LDAP_BIND_PASSWORD since otcs.config.enableSynchronizedPartition is true.\n" }}
            {{- else if and (eq .Values.otcs.config.llm.enabled true) (or (not $secrets.LLM_CLIENT_ID) (not $secrets.LLM_CLIENT_SECRET)) }}
                {{- fail "\n\nError: existing secret from global.existingSecret must set a LLM_CLIENT_ID and LLM_CLIENT_SECRET since otcs.config.llm.enabled is true.\n" }}
            {{- else if and (not (empty .Values.otcs.config.proxy.username)) (not $secrets.PROXY_PASSWORD) }}
                {{- fail "\n\nError: existing secret from global.existingSecret must set a PROXY_PASSWORD since otcs.config.proxy.username is provided " }}
            {{- else if (eq .Values.otcs.config.documentStorage.type "aws") }}
                {{- if not $secrets.AWS_SECRET_KEY }}
                    {{- fail "\n\nError: existing secret from global.existingSecret must set a AWS_SECRET_KEY since otcs.config.documentStorage.type is aws " }}
                {{- end }}
                {{- if not $secrets.AWS_ACCESS_ID }}
                    {{- fail "\n\nError: existing secret from global.existingSecret must set a AWS_ACCESS_ID since otcs.config.documentStorage.type is aws " }}
                {{- end }}
            {{- else if (eq .Values.otcs.config.documentStorage.type "gcp") }}
                {{- if not $secrets.gcp_service_account_json }}
                    {{- fail "\n\nError: existing secret from global.existingSecret must set a gcp_service_account_json since otcs.config.documentStorage.type is gcp.\n" }}
                {{- end }}
            {{- end }}
        {{- end }}
        {{- if eq .Values.global.otac.enabled true }}
            {{- if not $secrets.TARGET_DB_PASSWORD }}
                {{- fail "\n\nError: existing secret from .Values.global.existingSecret must set a TARGET_DB_PASSWORD since .Values.global.otac.enabled is true.\n" }}
            {{- else if not $secrets.OTAC_DB_ADMIN_PASSWORD }}
                {{- fail "\n\nError: existing secret from .Values.global.existingSecret must set a OTAC_DB_ADMIN_PASSWORD since .Values.global.otac.enabled is true.\n" }}
            {{- else if not $secrets.OTDS_PASS }}
                {{- fail "\n\nError: existing secret from .Values.global.existingSecret must set an OTDS_PASS since .Values.global.otac.enabled is true.\n" }}
            {{- end }}
            {{- if eq .Values.otac.otkm.enabled true }}
                {{- if not $secrets.OTAC_OTKM_USER_PASS }}
                    {{- fail "\n\nError: existing secret from .Values.global.existingSecret must set a OTAC_OTKM_USER_PASS since .Values.otac.otkm.enabled is true.\n" }}
                {{- end }}
            {{- end }}
            {{- if eq .Values.otac.ilm.enabled true }}
                {{- if not $secrets.OTAC_BA_USER_PASSWORD }}
                    {{- fail "\n\nError: existing secret from .Values.global.existingSecret must set a OTAC_BA_USER_PASSWORD since .Values.otac.ilm.enabled is true.\n" }}
                {{- end }}
                {{- if not $secrets.OTAC_ILM_USER_PASSWORD }}
                    {{- fail "\n\nError: existing secret from .Values.global.existingSecret must set a OTAC_ILM_USER_PASSWORD since .Values.otac.ilm.enabled is true.\n" }}
                {{- end }}
            {{- end }}
            {{- if and (.Values.otac.config.storageDevices.s3.enable) (not (.Values.otac.config.storageDevices.s3.userolebasedauth)) }}
                {{- if not $secrets.OTAC_S3_SECRETKEY }}
                    {{- fail "\n\nError: existing secret from .Values.global.existingSecret must set a OTAC_S3_SECRETKEY since Values.otac.config.storageDevices.s3.enable is true and .Values.otac.config.storageDevices.s3.userolebasedauth is false.\n" }}
                {{- end }}
            {{- end }}
            {{- if eq .Values.otac.config.storageDevices.azure.enable true }}
                {{- if not $secrets.OTAC_AZURE_ACCESSKEY }}
                    {{- fail "\n\nError: existing secret from .Values.global.existingSecret must set a OTAC_AZURE_ACCESSKEY since .Values.otac.config.storageDevices.azure.enable is true.\n" }}
                {{- end }}
            {{- end }}
        {{- end }}
        {{- if eq .Values.global.otacc.enabled true }}
            {{- if not $secrets.BA_PASSWORD }}
                {{- fail "\n\nError: existing secret from .Values.global.existingSecret must set a BA_PASSWORD since .Values.global.otacc.enabled is true.\n" }}
            {{- else if not $secrets.CONNECTOR_PASSWORD }}
                {{- fail "\n\nError: existing secret from .Values.global.existingSecret must set a CONNECTOR_PASSWORD since .Values.global.otacc.enabled is true.\n" }}
            {{- end }}
        {{- end }}
        {{- if eq .Values.global.otds.enabled true }}
            {{- if not $secrets.OTDS_JAKARTA_PERSISTENCE_JDBC_USER }}
                {{- fail "\n\nError: existing secret from .Values.global.existingSecret must set a OTDS_JAKARTA_PERSISTENCE_JDBC_USER since .Values.global.otds.enabled is true.\n" }}
            {{- else if not $secrets.OTDS_JAKARTA_PERSISTENCE_JDBC_PASSWORD }}
                {{- fail "\n\nError: existing secret from .Values.global.existingSecret must set a OTDS_JAKARTA_PERSISTENCE_JDBC_PASSWORD since .Values.global.otds.enabled is true.\n" }}
            {{- end }}
        {{- end }}
        {{- if eq .Values.global.otpd.enabled true }}
            {{- if eq .Values.otpd.otcs.enabled true }}
                {{- if not $secrets.OTCS_ADMIN_PASSWORD }}
                    {{- fail "\n\nError: existing secret from .Values.global.existingSecret must set a OTCS_ADMIN_PASSWORD since .Values.otpd.otcs.enabled is true.\n" }}
                {{- else if ne $secrets.ADMIN_USER_PASSWORD $secrets.OTCS_ADMIN_PASSWORD }}
                    {{- fail "\n\nError: existing secret from .Values.global.existingSecret must have the same values for ADMIN_USER_PASSWORD and OTCS_ADMIN_PASSWORD.\n" }}
                {{- end }}
            {{- end}}
            {{- if eq .Values.otpd.emailServerSettings.enabled true }}
                {{- if and (.Values.otpd.emailServerSettings.user) (not $secrets.EMAIL_SERVER_PASSWORD) }}
                    {{- fail "\n\nError: existing secret from .Values.global.existingSecret must set an EMAIL_SERVER_PASSWORD since .Values.otpd.emailServerSettings.enabled is set to true and .Values.otpd.emailServerSettings.user has a value set.\n" }}
                {{- end }}
                {{- if and (empty .Values.otpd.emailServerSettings.user) ($secrets.EMAIL_SERVER_PASSWORD) }}
                    {{- fail "\n\nError: existing secret from .Values.global.existingSecret must not set an EMAIL_SERVER_PASSWORD since .Values.otpd.emailServerSettings.enabled is set to true but .Values.otpd.emailServerSettings.user has no value set.\n" }}
                {{- end }}
            {{- end}}
            {{- if not $secrets.OTPD_ADMIN_PASSWORD}}
                {{- fail "\n\nError: existing secret from .Values.global.existingSecret must set a OTPD_ADMIN_PASSWORD since global.otpd.enabled is true.\n" }}
            {{- else if not $secrets.OTPD_USER_PASSWORD }}
                {{- fail "\n\nError: existing secret from .Values.global.existingSecret must set a OTPD_USER_PASSWORD since global.otpd.enabled is true.\n" }}
            {{- else if not $secrets.OTPD_MONITOR_USER_PASSWORD }}
                {{- fail "\n\nError: existing secret from .Values.global.existingSecret must set a OTPD_MONITOR_USER_PASSWORD since global.otpd.enabled is true.\n" }}
            {{- else if not $secrets.OTPD_API_USER_PASSWORD }}
                {{- fail "\n\nError: existing secret from .Values.global.existingSecret must set a OTPD_API_USER_PASSWORD since global.otpd.enabled is true.\n" }}
            {{- else if not $secrets.OTPD_TECHNICAL_USER_PASSWORD }}
                {{- fail "\n\nError: existing secret from .Values.global.existingSecret must set a OTPD_TECHNICAL_USER_PASSWORD since global.otpd.enabled is true.\n" }}
            {{- else if not $secrets.OTDS_PASSWORD }}
                {{- fail "\n\nError: existing secret from .Values.global.existingSecret must set a OTDS_PASSWORD since global.otpd.enabled is true.\n" }}
            {{- else if not $secrets.OTPD_DB_ADMIN_PASSWORD }}
                {{- fail "\n\nError: existing secret from .Values.global.existingSecret must set a OTPD_DB_ADMIN_PASSWORD since global.otpd.enabled is true.\n" }}
            {{- else if not $secrets.OTPD_DB_PASSWORD }}
                {{- fail "\n\nError: existing secret from .Values.global.existingSecret must set a OTPD_DB_PASSWORD since global.otpd.enabled is true.\n" }}
            {{- end }}
        {{- end }}
        {{- if eq .Values.global.otiv.enabled true }}
            {{- if eq .Values.otiv.amqp.enabled true}}
                {{- if not (index $secrets "rabbitmq-password") }}
                    {{- fail "\n\nError: existing secret from .Values.global.existingSecret must set rabbitmq-password since .Values.global.otiv.enabled is true" }}
                {{- end }}
            {{- end }}
            {{- if not $secrets.OTIV_DB_ADMIN_PASSWORD }}
                {{- fail "\n\nError: existing secret from .Values.global.existingSecret must set a OTIV_DB_ADMIN_PASSWORD since .Values.global.otiv.enabled is true.\n" }}
            {{- else if not $secrets.OTIV_DB_PASSWORD }}
                {{- fail "\n\nError: existing secret from .Values.global.existingSecret must set a OTIV_DB_PASSWORD since .Values.global.otiv.enabled is true.\n" }}
            {{- else if not $secrets.ADMIN_USER_PASSWORD }}
                {{- fail "\n\nError: existing secret from .Values.global.existingSecret must set a ADMIN_USER_PASSWORD since .Values.global.otiv.enabled is true.\n" }}
            {{- else if not $secrets.OTIV_HIGHLIGHT_CLIENT_SECRET }}
                {{- fail "\n\nError: existing secret from .Values.global.existingSecret must set a OTIV_HIGHLIGHT_CLIENT_SECRET since .Values.global.otiv.enabled is true.\n" }}
            {{- else if not $secrets.OTIV_MONITOR_CLIENT_SECRET }}
                {{- fail "\n\nError: existing secret from .Values.global.existingSecret must set a OTIV_MONITOR_CLIENT_SECRET since .Values.global.otiv.enabled is true.\n" }}
            {{- else if not $secrets.OTIV_PUBLICATION_CLIENT_SECRET }}
                {{- fail "\n\nError: existing secret from .Values.global.existingSecret must set a OTIV_PUBLICATION_CLIENT_SECRET since .Values.global.otiv.enabled is true.\n" }}
            {{- else if not $secrets.OTIV_PUBLISHER_CLIENT_SECRET }}
                {{- fail "\n\nError: existing secret from .Values.global.existingSecret must set a OTIV_PUBLISHER_CLIENT_SECRET since .Values.global.otiv.enabled is true.\n" }}
            {{- else if not $secrets.OTIV_CS_CLIENT_SECRET }}
                {{- fail "\n\nError: existing secret from .Values.global.existingSecret must set a OTIV_CS_CLIENT_SECRET since .Values.global.otiv.enabled is true.\n" }}
            {{- end }}
        {{- end }}
        {{/*
        Ensure password synchronization between OTCS, OTDS and OTAC. 
        */}}
        {{- if and (eq .Values.global.otcs.enabled true) (eq .Values.global.otds.enabled true) }}
            {{- if ne $secrets.ADMIN_USER_PASSWORD $secrets.OTDS_DIRECTORY_BOOTSTRAP_INITIALPASSWORD }}
                {{- fail "\n\nError: existing secret from .Values.global.existingSecret must have the same values for ADMIN_USER_PASSWORD and OTDS_DIRECTORY_BOOTSTRAP_INITIALPASSWORD.\n" }}
            {{- end }}
        {{- end }}
        {{- if and (eq .Values.global.otac.enabled true) (eq .Values.global.otds.enabled true) }}
            {{- if ne $secrets.OTDS_PASS $secrets.OTDS_DIRECTORY_BOOTSTRAP_INITIALPASSWORD }}
                {{- fail "\n\nError: existing secret from .Values.global.existingSecret must have the same values for OTDS_PASS and OTDS_DIRECTORY_BOOTSTRAP_INITIALPASSWORD.\n" }}
            {{- end }}
        {{- end }}
        {{- if and (eq .Values.global.otcs.enabled true) (eq .Values.global.otac.enabled true) }}
            {{- if ne $secrets.ADMIN_USER_PASSWORD $secrets.OTDS_PASS }}
                {{- fail "\n\nError: existing secret from .Values.global.existingSecret must have the same values for ADMIN_USER_PASSWORD and OTDS_PASS.\n" }}
            {{- end }}
        {{- end }}
    {{- else if and (ne .Values.global.existingSecret "otxecm-default-secrets") (not $secret_object) }}
        {{- if (eq .Values.otcs.config.contentProtection.enabled false) }}
            {{- fail "\n\nError: existing secret defined at .Values.global.existingSecret not found.\n" }}
        {{- end }}
    {{- end }}
{{- else }}
    {{/*
    Check for the type Validation
    */}}
    {{- if or (.Values.global.secretlink.vault.address) (.Values.global.secretlink.vault.mountpoint) (.Values.global.secretlink.vault.path) (.Values.global.secretlink.vault.namespace) (.Values.global.secretlink.vault.authpath) (.Values.global.secretlink.vault.role) }}
        {{- if or (not (kindIs "string" .Values.global.secretlink.vault.address)) (not (kindIs "string" .Values.global.secretlink.vault.mountpoint )) (not (kindIs "string" .Values.global.secretlink.vault.path)) (not (or (kindIs "string" .Values.global.secretlink.vault.namespace) (not (kindIs "string" .Values.global.secretlink.vault.namespace)))) (not (kindIs "string" .Values.global.secretlink.vault.authpath)) (not (or (kindIs "string" .Values.global.secretlink.vault.role) (not (kindIs "string" .Values.global.secretlink.vault.role)))) }}
            {{- fail "Please check that the following value need to set as string .Values.global.secretlink.vault.address, .Values.global.secretlink.vault.mountpoint, .Values.global.secretlink.vault.path, .Values.global.secretlink.vault.namespace, .Values.global.secretlink.vault.authpath, .Values.global.secretlink.vault.role" }}
        {{- end }}
    {{- end }}
	{{/*
    Validation of values when secretlink is enabled. It checks for all the secretlink values are not empty
	*/}}
    {{- if eq .Values.global.otcs.enabled true }}
        {{- if or (default .Values.global.secretlink.vault.address .Values.otcs.secretlink.vault.address | empty) (default .Values.global.secretlink.vault.mountpoint .Values.otcs.secretlink.vault.mountpoint | empty) (default .Values.global.secretlink.vault.path .Values.otcs.secretlink.vault.path | empty) (default .Values.global.secretlink.vault.namespace .Values.otcs.secretlink.vault.namespace | empty) (default .Values.global.secretlink.vault.authpath .Values.otcs.secretlink.vault.authpath | empty) (default .Values.global.secretlink.vault.role .Values.otcs.secretlink.vault.role | empty) }}
            {{- fail ".Values.otcs.secretlink.vault.address, .Values.otcs.secretlink.vault.mountpoint, .Values.otcs.secretlink.vault.path, .Values.otcs.secretlink.vault.namespace, .Values.otcs.secretlink.vault.authpath, .Values.otcs.secretlink.vault.role must be set since secretlink is enabled" }}
        {{- end }}
    {{- else }}
        {{- if or (.Values.global.secretlink.vault.address | empty) (.Values.global.secretlink.vault.mountpoint | empty) (.Values.global.secretlink.vault.path  | empty) (.Values.global.secretlink.vault.namespace | empty) (.Values.global.secretlink.vault.authpath | empty) (.Values.global.secretlink.vault.role | empty) }}
            {{- fail ".Values.global.secretlink.vault.address, .Values.global.secretlink.vault.mountpoint, .Values.global.secretlink.vault.path, .Values.global.secretlink.vault.namespace, .Values.global.secretlink.vault.authpath, .Values.global.secretlink.vault.role must be set since secretlink is enabled" }}
        {{- end }}
    {{- end }}
{{- end }}
{{- if eq .Values.global.otcs.enabled true }}
    {{/*
    Ensure oracle database has the correct values.
    */}}
    {{- if and (ne .Values.otcs.config.database.type "oracle") (ne .Values.otcs.config.database.type "postgres") (ne .Values.otcs.config.database.type "mssql")}}
        {{- fail "otcs.config.database.type must be either postgres, mssql, or oracle" }}
    {{- end}}
    {{- if eq .Values.otcs.config.database.type "oracle" }}
        {{- if and (eq .Values.otcs.config.database.oracle.loadTnsnames.enabled true) (not .Values.otcs.config.database.oracle.tnsnamesConnectionAlias )}}
            {{- fail "otcs.config.database.oracle.tnsnamesConnectionAlias must be set to the connection alias to be used from the tnsnames file if otcs.config.database.oracle.loadTnsnames.enabled true" }}
        {{- end}}
        {{- if and (eq .Values.otcs.config.database.oracle.loadTnsnames.enabled false) (not .Values.otcs.config.database.oracle.serviceName )}}
            {{- fail "otcs.config.database.oracle.serviceName must be set to the pluggable database to use if otcs.config.database.oracle.loadTnsnames.enabled false" }}
        {{- end}}
        {{if (eq .Values.otcs.config.database.adminUsername "sys")}}
            {{- fail ".Values.otcs.config.database.adminUsername do not use sys user, instead use system."}}
        {{- end}}
    {{- end}}
    {{/*
    Ensure mssql database has the correct values.
    */}}
    {{- if eq .Values.otcs.config.database.type "mssql" }}
        {{- if or (empty .Values.otcs.config.database.mssql.dbDataFileSpec) (empty .Values.otcs.config.database.mssql.dbLogFileSpec) }}
            {{- fail "otcs.config.database.mssql.dbDataFileSpec and otcs.config.database.mssql.dbLogFileSpec must be set" }}
        {{- end}}
        {{- if and (empty .Values.otcs.config.database.adminUsername) (eq .Values.global.database.adminUsername "postgres") }}
            {{- fail "otcs.config.database.adminUsername has been left empty and the global.database.adminUsername is the default 'postgres' while using mssql" }}
        {{- end }}
    {{- end}}

    {{- if eq .Values.global.otds.enabled true }}
        {{- if ne (int (.Values.otcs.config.otds.port)) (int (.Values.otds.otdsws.port)) }}
            {{- fail "otcs.config.otds.port and otds.otdsws.port do not match. The port must be the same." }}
        {{- end }}
    {{- end }}

    {{- if eq .Values.otcs.config.syndication.enabled true }}
        {{/*
        Validation of values when syndication is enabled. It checks for all the syndication values are empty
        */}}
        {{- if (empty .Values.otcs.config.syndication.sitename)  }}
            {{- fail ".Values.otcs.config.syndication.sitename must be set since syndication is enabled." }}
        {{- end }}
        {{- if and (empty .Values.otcs.config.syndication.siteid) (ne (int (.Values.otcs.config.syndication.siteid)) 0) }}
            {{- fail ".Values.otcs.config.syndication.siteid must be set since syndication is enabled." }}
        {{- end }}
        {{/*
        If primary is true,checks for siteid is zero
        */}}
        {{- if eq .Values.otcs.config.syndication.isPrimary true }}
            {{- if ne (int (.Values.otcs.config.syndication.siteid)) 0 }}
                {{- fail ".Values.otcs.config.syndication.siteid must be zero." }}
            {{- end }}
        {{/*
        If primary is false,checks for siteid is not zero
        */}}
        {{ else }}
            {{- if eq (int (.Values.otcs.config.syndication.siteid)) 0 }}
                {{- fail ".Values.otcs.config.syndication.siteid must not be zero." }}
            {{- end }}
        {{- end }}
    {{- end }}

    {{- if (eq .Values.otcs.config.contentProtection.enabled true) }}
        {{- if or (empty .Values.otcs.config.contentProtection.storage) (empty .Values.otcs.config.contentProtection.path) }}
            {{- fail ".Values.otcs.config.contentProtection.storage and .Values.otcs.config.contentProtection.path should be set"  }}
        {{- end }}
    {{- end }}

    {{- if (eq .Values.otcs.config.storageProviderCache.enabled true) }}
        {{- if (eq .Values.otcs.config.contentProtection.enabled false) }}
            {{- fail ".Values.otcs.config.contentProtection.enabled should be enabled since storageProviderCache is enabled" }}
        {{- end }}
        {{- if (empty .Values.otcs.config.storageProviderCache.dmtshost) }}
            {{- fail ".Values.otcs.config.storageProviderCache.dmtshost should be set since storageProviderCache is enabled"  }}
        {{- end }}
    {{- end }}


    {{- if (eq .Values.otcs.config.proxy.enabled true) }}
        {{- if or (empty .Values.otcs.config.proxy.host) (empty .Values.otcs.config.proxy.port) }}
            {{- fail ".Values.otcs.config.proxy.host, .Values.otcs.config.proxy.port, must be set since proxy is enabled" }}
        {{- end }}
        {{- if and (eq .Values.global.existingSecret "otxecm-default-secrets") (not (empty .Values.otcs.config.proxy.username)) }}
            {{- if empty .Values.otcs.passwords.proxyPassword }}
                {{- fail ".Values.otcs.passwords.proxyPassword must be set since otcs.config.proxy.username is provided" }}
            {{- end }}
        {{- end }}
    {{- end }}


    {{- if (eq .Values.otcs.config.documentStorage.type "aws") }}
        {{- if or (empty .Values.otcs.config.awsStorageProvider.region) (empty .Values.otcs.config.awsStorageProvider.bucketName) }}
            {{- fail ".Values.otcs.config.awsStorageProvider.region, .Values.otcs.config.awsStorageProvider.bucketName must be set since documentStorage type is aws " }}
        {{- end }}
        {{- if eq .Values.global.existingSecret "otxecm-default-secrets" }}
            {{- if empty .Values.otcs.passwords.awsSecretKey }}
                {{- fail ".Values.otcs.passwords.awsSecretKey must be set since otcs.config.documentStorage.type is aws" }}
            {{- end }}
            {{- if empty .Values.otcs.passwords.awsAccessId }}
                {{- fail ".Values.otcs.passwords.awsAccessId must be set since otcs.config.documentStorage.type is aws" }}
            {{- end }}
        {{- end }}
    {{- end }}

    {{- if (eq .Values.otcs.config.documentStorage.type "gcp") }}
        {{- if (empty .Values.otcs.config.gcpStorageProvider.bucketName) }}
            {{- fail "\n\nError: .Values.otcs.config.gcpStorageProvider.bucketName must be set since documentStorage type is gcp.\n" }}
        {{- end }}
        {{- if eq .Values.global.existingSecret "otxecm-default-secrets" }}
            {{- if (empty .Values.otcs.config.gcpStorageProvider.serviceAccountJson) }}
                {{- fail "\n\nError: .Values.otcs.config.gcpStorageProvider.serviceAccountJson must be set since documentStorage type is gcp.\n" }}
            {{- end }}
            {{- $gcpServiceAccountJson := .Values.otcs.config.gcpStorageProvider.serviceAccountJson }}
            {{- $fileContent := .Files.Get $gcpServiceAccountJson }}
            {{- if not $fileContent }}
                {{- fail (printf "\n\nError: File %s not found or is empty.\n" $gcpServiceAccountJson) }}
            {{- end }}
        {{- end }}
    {{- end }}

    # Validation for license secret
    {{- if .Values.global.existingLicenseSecret }}
        {{- $license_secret := lookup "v1" "Secret" .Release.Namespace .Values.global.existingLicenseSecret }}
        {{- if and $license_secret $license_secret.data }}
            {{- if and (eq .Values.otcs.loadLicense.enabled true) (not (index $license_secret.data .Values.otcs.loadLicense.filename )) }}
                {{- fail ".Values.otcs.loadLicense.filename not found in license secret"}}
            {{- end }}
        {{- else }}	
            {{- fail ".Values.global.existingLicenseSecret does not exist or doesn't have data"}}
        {{- end }}
    {{- end }}

    # Validation for otac certificate secret
    {{- if .Values.otcs.config.otac.certSecret }}
        {{- $otac_secret := lookup "v1" "Secret" .Release.Namespace .Values.otcs.config.otac.certSecret }}
        {{- if and $otac_secret $otac_secret.data }}
            {{- if not (index $otac_secret.data .Values.otcs.config.otac.certFilename )}}
                {{- fail ".Values.otcs.config.otac.certFilename not found in certificate secret"}}
            {{- end }}
        {{- else }}	
            {{- fail ".Values.otcs.config.otac.certSecret does not exist or does not have data"}}
        {{- end }}
    {{- end }}

    # Validation for otacc certificate secret
    {{- if .Values.otcs.config.otacc.certSecret }}
        {{- $otacc_secret := lookup "v1" "Secret" .Release.Namespace .Values.otcs.config.otacc.certSecret }}
        {{- if and $otacc_secret $otacc_secret.data }}
            {{- if not (index $otacc_secret.data .Values.otcs.config.otacc.certFilename )}}
                {{- fail ".Values.otcs.config.otacc.certFilename not found in certificate secret"}}
            {{- end }}
        {{- else }}
            {{- fail ".Values.otcs.config.otacc.certSecret does not exist or does not have data"}}
        {{- end }}
    {{- end }}
    
    # Validation for UAL certificate secret
    {{- if .Values.otcs.config.ual.certSecret }}
        {{- $ual_secret := lookup "v1" "Secret" .Release.Namespace .Values.otcs.config.ual.certSecret }}
        {{- if and $ual_secret $ual_secret.data }}
            {{- if not (index $ual_secret.data .Values.otcs.config.ual.certFilename )}}
                {{- fail ".Values.otcs.config.ual.certFilename not found in certificate secret"}}
            {{- end }}
        {{- else }}
            {{- fail ".Values.otcs.config.ual.certSecret does not exist or does not have data"}}
        {{- end }}
    {{- end }}

    # Validation for pre-existing adminsettings configmaps
    {{- if and (.Values.otcs.loadAdminSettings.enabled) (.Values.otcs.loadAdminSettings.initialConfigmap)}}
        {{- $initial_configmap := lookup "v1" "ConfigMap" .Release.Namespace .Values.otcs.loadAdminSettings.initialConfigmap }}
        {{- if not ($initial_configmap) }}
            {{- fail ".Values.otcs.loadAdminSettings.initialConfigmap does not exist"}}
        {{- end }}
    {{- end }}

    {{- if and (.Values.otcs.loadAdminSettings.enabled) (.Values.otcs.loadAdminSettings.recurrentConfigmap)}}
        {{- $recurrent_configmap := lookup "v1" "ConfigMap" .Release.Namespace .Values.otcs.loadAdminSettings.recurrentConfigmap }}
        {{- if not ($recurrent_configmap) }}
            {{- fail ".Values.otcs.loadAdminSettings.recurrentConfigmap does not exist"}}
        {{- end }}
    {{- end }}
    {{- if and (eq .Values.global.otcs.enabled true) (eq .Values.otcs.config.deployBusinessScenarios true) }}
        {{- if eq .Values.global.otxecmctrl.enabled false  }}
            {{- fail ".Values.global.otxecmctrl.enabled must be enabled when .Values.otcs.config.deployBusinessScenarios is enabled" }}
        {{- end }}
    {{- end }}
    {{- if eq .Values.otcs.fluentbit.enabled true}}
        {{- if eq .Values.otcs.fluentbit.proxy.enabled true }}
            {{- if or (not .Values.otcs.fluentbit.proxy.host) (not .Values.otcs.fluentbit.proxy.port) }}
                {{- fail "otcs.fluentbit.proxy.host and otcs.fluentbit.proxy.port need to be set since otcs.fluentbit.proxy.enabled is set to true."}}
            {{- end }}
            {{- if eq .Values.otcs.fluentbit.proxy.enableauthentication true}}
                {{- if or (not .Values.otcs.fluentbit.proxy.username) (not .Values.otcs.fluentbit.proxy.password)}}
                    {{- fail "otcs.fluentbit.proxy.username and otcs.fluentbit.proxy.password need to be set since otcs.fluentbit.proxy.enableauthentication is set to true." }}
                {{- end }}
            {{- end }}
        {{- end }}
    {{- end }}
    {{- if eq .Values.otcs.config.ual.enabled true }}
        {{- if or (eq .Values.otcs.config.documentStorage.type "database") (eq .Values.otcs.config.documentStorage.type "efs") }}
            {{- fail "otcs.config.documentStorage.type cannot be database or efs since UAL is enabled" }}
        {{- end }}
        {{- if and (not .Values.otcs.config.ual.certSecret) (or .Values.otcs.config.otac.certSecret .Values.otcs.config.otacc.certSecret) }}
            {{- fail "otcs.config.ual.certSecret needs to be provided when UAL is enabled if you are using certSecret for OTAC/OTACC" }}
        {{- end }}
    {{- end }}
{{- end }}
{{- if and (eq .Values.global.otac.enabled true) (eq .Values.global.otds.enabled true) }}
    {{- if ne (int (.Values.otac.otds.port)) (int (.Values.otds.otdsws.port)) }}
        {{- fail ".Values.otac.otds.port and .Values.otds.otdsws.port do not match. The port must be the same." }}
    {{- end }}
{{- end }}

{{/*
    Validation of otac userPasswordVal. This parameter must not be empty if otkm is enabled, and secrets not set
*/}}
{{- if and (eq .Values.global.otac.enabled true) (eq .Values.otac.otkm.enabled true) }}
    {{- if (eq .Values.global.existingSecret "otxecm-default-secrets") }}
        {{- if eq (default .Values.global.secretlink.enabled .Values.otac.secretlink.enabled) false }}
            {{- if empty .Values.otac.encryption.otkm.userPasswordVal }}
                {{- fail "\n\nError: .Values.otac.encryption.otkm.userPasswordVal must be set since .Values.otac.otkm.enabled is true.\n" }}
            {{- end }}
        {{- end }}
    {{- end }}
{{- end }}

{{/*
    Validation of otac ilm user passwords. ba and ilm passwords are mandatory in the helm if ilm is enabled
*/}}
{{- if and (eq .Values.global.otac.enabled true) (eq .Values.otac.ilm.enabled true) }}
    {{- if (eq .Values.global.existingSecret "otxecm-default-secrets") }}
        {{-  if eq (default .Values.global.secretlink.enabled .Values.otac.secretlink.enabled) false }}
            {{- if empty .Values.otac.ilm.users.ba.password }}
                {{- fail "\n\nError: .Values.otac.ilm.users.ba.password must be set since .Values.otac.ilm.enabled is true.\n" }}
            {{- end }}
            {{- if empty .Values.otac.ilm.users.ilm.password }}
                {{- fail "\n\nError: .Values.otac.ilm.users.ilm.password must be set since .Values.otac.ilm.enabled is true.\n" }}
            {{- end }}
        {{- end }}
    {{- end }}
{{- end }}

{{/*
    Validation of standard user passwords. Provided password must contain at least 8 characters.
*/}}
{{- if (eq .Values.global.otac.enabled true) }}
    {{- if (eq .Values.global.existingSecret "otxecm-default-secrets") }}
        {{-  if eq (default .Values.global.secretlink.enabled .Values.otac.secretlink.enabled) false }}
            {{- if and (not (empty .Values.otac.standardUserPasswords.dsadmin)) (lt (len .Values.otac.standardUserPasswords.dsadmin) 8) }}
                {{- fail "\n\nError: .Values.otac.standardUserPasswords.dsadmin must contain at least 8 characters.\n" }}
            {{- end }}
            {{- if and (not (empty .Values.otac.standardUserPasswords.dpadmin)) (lt (len .Values.otac.standardUserPasswords.dpadmin) 8) }}
                {{- fail "\n\nError: .Values.otac.standardUserPasswords.dpadmin must contain at least 8 characters.\n" }}
            {{- end }}
            {{- if and (not (empty .Values.otac.standardUserPasswords.dpuser)) (lt (len .Values.otac.standardUserPasswords.dpuser) 8) }}
                {{- fail "\n\nError: .Values.otac.standardUserPasswords.dpuser must contain at least 8 characters.\n" }}
            {{- end }}
        {{- end }}
    {{- end }}
{{- end }}

{{/*
    Validation of s3 storage device secret key and azure storage device access key
*/}}
{{- if (eq .Values.global.otac.enabled true) }}
    {{- if (eq .Values.global.existingSecret "otxecm-default-secrets") }}
        {{-  if eq (default .Values.global.secretlink.enabled .Values.otac.secretlink.enabled) false }}
            {{- if and (.Values.otac.config.storageDevices.s3.enable) (not (.Values.otac.config.storageDevices.s3.userolebasedauth)) (empty .Values.otac.config.storageDevices.s3.secretkey) }}
                {{- fail "\n\nError: .Values.otac.config.storageDevices.s3.secretkey must be set since Values.otac.config.storageDevices.s3.enable is true and .Values.otac.config.storageDevices.s3.userolebasedauth is false.\n" }}
            {{- end }}
            {{- if and (eq .Values.otac.config.storageDevices.azure.enable true) (empty .Values.otac.config.storageDevices.azure.accesskey) }}
                {{- fail "\n\nError: .Values.otac.config.storageDevices.azure.accesskey must be set since .Values.otac.config.storageDevices.azure.enable is true.\n" }}
            {{- end }}
        {{- end }}
    {{- end }}
{{- end }}

# Ensure PowerDocs charts has the correct values.
{{- if eq .Values.global.otpd.enabled true }}
    {{- if ne .Values.global.otcs.enabled .Values.otpd.otcs.enabled }}
        {{- fail ".Values.global.otcs.enabled and .Values.otpd.otcs.enabled must be set to same value." }}
    {{- end }}
    {{- if eq .Values.otpd.emailServerSettings.enabled true }}
        {{/*
        Validation of values when Email Server Setting is enabled.
        */}}
        {{- if or (empty .Values.otpd.emailServerSettings.server) (empty .Values.otpd.emailServerSettings.port) }}
            {{- fail ".Values.otpd.emailServerSettings.server and .Values.otpd.emailServerSettings.port must be set since .Values.otpd.emailServerSettings.enabled is set to true." }}
        {{- end }}
        {{-  if (eq $secretlink_enabled false) }}
            {{- if eq .Values.global.existingSecret "otxecm-default-secrets" }}
                {{- if and (empty .Values.otpd.emailServerSettings.user) (.Values.otpd.emailServerSettings.password) }}
                    {{- fail "Cannot leave .Values.otpd.emailServerSettings.user empty since .Values.otpd.emailServerSettings.password is set." }}
                {{- end }}
                {{- if and (.Values.otpd.emailServerSettings.user) (empty .Values.otpd.emailServerSettings.password) }}
                    {{- fail "Cannot leave .Values.otpd.emailServerSettings.password empty since .Values.otpd.emailServerSettings.user is set." }}
                {{- end }}
            {{- end }}
        {{- end }}
    {{- end }}
    {{-  if (eq $secretlink_enabled false) }}
        {{- if (eq .Values.global.existingSecret "otxecm-default-secrets") }}
            {{- if or (not .Values.otpd.technicalUserPassword) (empty .Values.otpd.technicalUserPassword) }}
                {{- fail "\n\nError: Cannot leave .Values.otpd.technicalUserPassword empty since global.otpd.enabled is true.\n" }}
            {{- end }}
        {{- end }}
    {{- end }}    
    {{- if and (eq .Values.otpd.importCustomRootCA true) (eq .Values.otpd.sslEnabledDB false) }}
        {{- fail "\n\nError: .Values.otpd.sslEnabledDB must set to true since .Values.otpd.importCustomRootCA is set to true.\n" }}
    {{- end}}
    {{- if and (ne .Values.otpd.database.type "oracle") (ne .Values.otpd.database.type "postgres") (ne .Values.otpd.database.type "mssql")}}
        {{- fail ".Values.otpd.database.type must be either postgres, oracle or mssql" }}
    {{- end}}
    {{- if eq .Values.otpd.database.type "oracle"}}
        {{if (eq .Values.otpd.database.adminUsername "sys")}}
            {{- fail ".Values.otpd.database.adminUsername do not use sys user, instead use system."}}
        {{- end}}
    {{- end}}
{{- end }}
