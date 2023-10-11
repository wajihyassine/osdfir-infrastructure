{{/*
Expand the name of the chart.
*/}}
{{- define "osdfir.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "osdfir.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Return the proper persistence volume claim name
*/}}
{{- define "osdfir.pvc.name" -}}
{{- $pvcName := .Values.persistence.name -}}
{{- if .Values.global -}}
    {{- if .Values.global.existingPVC -}}
        {{- $pvcName = .Values.global.existingPVC -}}
    {{- end -}}
{{- printf "%s-%s" $pvcName "claim" }}
{{- end -}}
{{- end -}}

{{/*
Return the proper Storage Class
*/}}
{{- define "osdfir.storage.class" -}}
{{- $storageClass := .Values.persistence.storageClass -}}
{{- if .Values.global -}}
    {{- if .Values.global.storageClass -}}
        {{- $storageClass = .Values.global.storageClass -}}
    {{- end -}}
{{- end -}}
{{- if $storageClass -}}
  {{- if (eq "-" $storageClass) -}}
      {{- printf "storageClassName: \"\"" -}}
  {{- else }}
      {{- printf "storageClassName: %s" $storageClass -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Turbinia common labels
*/}}
{{- define "turbinia.labels" -}}
helm.sh/chart: {{ include "osdfir.chart" . }}
{{ include "turbinia.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
date: "{{ now | htmlDate }}"
{{- end }}

{{/*
Turbinia Selector labels
*/}}
{{- define "turbinia.selectorLabels" -}}
app.kubernetes.io/name: turbinia
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
GCP Project ID validation
*/}}
{{- define "turbinia.gcp.project" -}}
{{- if and .Values.turbinia.gcp.projectID .Values.turbinia.gcp.enabled -}}
{{- printf "%s" .Values.turbinia.gcp.projectID -}}
{{- else -}}
{{ fail "A valid .Values.turbinia.gcp.projectID entry is required!" }}
{{- end -}}
{{- end -}}

{{/*
GCP Project region validation
*/}}
{{- define "turbinia.gcp.region" -}}
{{- if and .Values.turbinia.gcp.projectRegion .Values.turbinia.gcp.enabled -}}
{{- printf "%s" .Values.turbinia.gcp.projectRegion -}}
{{- else -}}
{{ fail "A valid .Values.turbinia.gcp.projectRegion entry is required!" }}
{{- end -}}
{{- end -}}

{{/*
GCP Project zone validation
*/}}
{{- define "turbinia.gcp.zone" -}}
{{- if and .Values.turbinia.gcp.projectZone .Values.turbinia.gcp.enabled -}}
{{- printf "%s" .Values.turbinia.gcp.projectZone -}}
{{- else -}}
{{ fail "A valid .Values.turbinia.gcp.projectZone entry is required!" }}
{{- end -}}
{{- end -}}

{{/*
Redis subcharts connection url
*/}}
{{- define "turbinia.redis.url" -}}
{{- if .Values.redis.enabled -}}
{{- $name := include "common.names.fullname" (dict "Chart" (dict "Name" "redis") "Release" .Release "Values" .Values.redis) -}}
{{- $port := .Values.redis.master.service.ports.redis -}}
{{- if .Values.redis.auth.enabled -}}
{{- printf "redis://default:'$REDIS_PASSWORD'@%s-master:%.0f" $name $port -}}
{{- else -}}
{{- printf "redis://%s-master:%.0f" $name $port -}}
{{- end -}}
{{- else -}}
{{ fail "Attempting to use Redis, but the subchart is not enabled. This will lead to misconfiguration" }}
{{- end -}}
{{- end -}}

{{/*
Redis subcharts host url
*/}}
{{- define "turbinia.redis.url.noport" -}}
{{- if .Values.redis.enabled -}}
{{- $name := include "common.names.fullname" (dict "Chart" (dict "Name" "redis") "Release" .Release "Values" .Values.redis) -}}
{{- if .Values.redis.auth.enabled -}}
{{- printf "%s-master" $name -}}
{{- else -}}
{{- printf "%s-master" $name -}}
{{- end -}}
{{- else -}}
{{ fail "Attempting to use Redis, but the subchart is not enabled. This will lead to misconfiguration" }}
{{- end -}}
{{- end -}}

{{/*
Timesketch Common labels
*/}}
{{- define "timesketch.labels" -}}
helm.sh/chart: {{ include "osdfir.chart" . }}
{{ include "timesketch.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
date: "{{ now | htmlDate }}"
{{- end }}

{{/*
Timesketch Selector labels
*/}}
{{- define "timesketch.selectorLabels" -}}
app.kubernetes.io/name: timesketch
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the upload path.
*/}}
{{- define "timesketch.uploadPath" -}}
{{- $pvcName := .Values.persistence.name -}}
{{- printf "/mnt/%s/upload" $pvcName }}
{{- end }}

{{/*
Redis subcharts connection url
*/}}
{{- define "timesketch.redis.url" -}}
{{- if .Values.redis.enabled -}}
{{- $name := include "common.names.fullname" (dict "Chart" (dict "Name" "redis") "Release" .Release "Values" .Values.redis) -}}
{{- $port := .Values.redis.master.service.ports.redis -}}
{{- if .Values.redis.auth.enabled -}}
{{- printf "redis://default:'$REDIS_PASSWORD'@%s-master:%.0f" $name $port -}}
{{- else -}}
{{- printf "redis://%s-master:%.0f" $name $port -}}
{{- end -}}
{{- else -}}
{{ fail "Attempting to use Redis, but the subchart is not enabled. This will lead to misconfiguration" }}
{{- end -}}
{{- end -}}

{{/*
Postgresql subcharts connection url
*/}}
{{- define "timesketch.postgresql.url" -}}
{{- if .Values.postgresql.enabled -}}
{{- $name := include "common.names.fullname" (dict "Chart" (dict "Name" "postgresql") "Release" .Release "Values" .Values.postgresql) -}}
{{- $port := .Values.postgresql.primary.service.ports.postgresql -}}
{{- $username := .Values.postgresql.auth.username -}}
{{- $database := .Values.postgresql.auth.database -}}
{{- printf "postgresql://%s:'$POSTGRES_PASSWORD'@%s:%.0f/%s" $username $name $port $database -}}
{{- else -}}
{{ fail "Attempting to use Postgresql, but the subchart is not enabled. This will lead to misconfiguration" }}
{{- end -}}
{{- end -}}

{{/*
Opensearch subcharts host name
*/}}
{{- define "timesketch.opensearch.host" -}}
{{- if .Values.opensearch.enabled -}}
{{- printf "%s" .Values.opensearch.masterService -}}
{{- else -}}
{{ fail "Attempting to use Opensearch, but the subchart is not enabled. This will lead to misconfiguration" }}
{{- end -}}
{{- end -}}

{{/*
Opensearch subcharts port
*/}}
{{- define "timesketch.opensearch.port" -}}
{{- if .Values.opensearch.enabled -}}
{{- printf "%.0f" .Values.opensearch.httpPort -}}
{{- else -}}
{{ printf "Attempting to use Opensearch, but the subchart is not enabled. This will lead to misconfiguration" }}
{{- end -}}
{{- end -}}