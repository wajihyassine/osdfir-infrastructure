{{/*
Init Container for when a Timesketch pod starts. To prevent duplicate code,
this file has been created which then applies to both the Timesketch Web and
Worker pod upon startup.
*/}}
{{- define "timesketch.initContainer" -}}
- name: init-timesketch
  image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
  command: ['sh', '-c', '/init/init-timesketch.sh']
  env:
    - name: TIMESKETCH_SECRET
      valueFrom:
        secretKeyRef:
          name: {{ .Release.Name }}-timesketch-secret
          key: timesketch-secret
    - name: REDIS_PASSWORD
      valueFrom:
        secretKeyRef:
          name: {{ .Release.Name }}-timesketch-secret
          key: redis-user
    - name: POSTGRES_PASSWORD
      valueFrom:
        secretKeyRef:
          name: {{ .Release.Name }}-timesketch-secret
          key: postgres-user
    {{- if and .Values.global.yeti.enabled .Values.global.yeti.apiKeySecret }}
    - name: YETI_API_KEY
      valueFrom:
        secretKeyRef:
          name: {{ .Values.global.yeti.apiKeySecret | quote }}
          key: "yeti-api"
    {{- end }}
    {{- if .Values.global.hashr.enabled }}
    - name: HASHR_POSTGRES_KEY
      valueFrom:
        secretKeyRef:
          name: {{ printf "%s-hashr-secret" .Release.Name }}
          key: "postgres-user"
    {{- end }}
    {{- if and .Values.config.oidc.enabled .Values.config.oidc.existingSecret }}
    - name: OIDC_CLIENT_ID
      valueFrom:
        secretKeyRef:
          name: {{ .Values.config.oidc.existingSecret | quote }}
          key: "client-id"
    - name: OIDC_CLIENT_SECRET
      valueFrom:
        secretKeyRef:
          name: {{ .Values.config.oidc.existingSecret | quote }}
          key: "client-secret"
    - name: OIDC_CLIENT_ID_NATIVE
      valueFrom:
        secretKeyRef:
          name: {{ .Values.config.oidc.existingSecret | quote }}
          key: "client-id-native"
          optional: true
    {{- end }}
  volumeMounts:
    - mountPath: /init
      name: init-timesketch
    - mountPath: /etc/timesketch
      name: timesketch-configs
    {{- if .Values.config.existingConfigMap }}
    - mountPath: /tmp/timesketch
      name: uploaded-configs
    {{- end }}
    {{- if .Values.config.oidc.authenticatedEmailsFile.enabled }}
    - name: authenticated-emails
      mountPath: /init/authenticated-emails
      readOnly: true
    {{- end }}
{{- end }}
