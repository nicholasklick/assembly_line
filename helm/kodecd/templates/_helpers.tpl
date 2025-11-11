{{/*
Expand the name of the chart.
*/}}
{{- define "kodecd.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "kodecd.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "kodecd.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "kodecd.labels" -}}
helm.sh/chart: {{ include "kodecd.chart" . }}
{{ include "kodecd.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "kodecd.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kodecd.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "kodecd.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "kodecd.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
PostgreSQL host
*/}}
{{- define "kodecd.postgresql.host" -}}
{{- if .Values.postgresql.enabled }}
{{- printf "%s-postgresql" (include "kodecd.fullname" .) }}
{{- else }}
{{- .Values.postgresql.external.host }}
{{- end }}
{{- end }}

{{/*
PostgreSQL port
*/}}
{{- define "kodecd.postgresql.port" -}}
{{- if .Values.postgresql.enabled }}
{{- 5432 }}
{{- else }}
{{- .Values.postgresql.external.port }}
{{- end }}
{{- end }}

{{/*
Redis host
*/}}
{{- define "kodecd.redis.host" -}}
{{- if .Values.redis.enabled }}
{{- printf "%s-redis-master" (include "kodecd.fullname" .) }}
{{- else }}
{{- .Values.redis.external.host }}
{{- end }}
{{- end }}

{{/*
Redis port
*/}}
{{- define "kodecd.redis.port" -}}
{{- if .Values.redis.enabled }}
{{- 6379 }}
{{- else }}
{{- .Values.redis.external.port }}
{{- end }}
{{- end }}

{{/*
External URL
*/}}
{{- define "kodecd.externalUrl" -}}
{{- if .Values.config.externalUrl }}
{{- .Values.config.externalUrl }}
{{- else }}
{{- printf "%s://%s" .Values.global.protocol .Values.global.domain }}
{{- end }}
{{- end }}

{{/*
Database URL
*/}}
{{- define "kodecd.databaseUrl" -}}
{{- $user := .Values.postgresql.auth.username }}
{{- $pass := .Values.postgresql.auth.password }}
{{- $host := include "kodecd.postgresql.host" . }}
{{- $port := include "kodecd.postgresql.port" . }}
{{- $db := .Values.postgresql.auth.database }}
{{- printf "postgresql://%s:%s@%s:%v/%s" $user $pass $host $port $db }}
{{- end }}

{{/*
Redis URL
*/}}
{{- define "kodecd.redisUrl" -}}
{{- $host := include "kodecd.redis.host" . }}
{{- $port := include "kodecd.redis.port" . }}
{{- if .Values.redis.auth.enabled }}
{{- printf "redis://:%s@%s:%v/0" .Values.redis.auth.password $host $port }}
{{- else }}
{{- printf "redis://%s:%v/0" $host $port }}
{{- end }}
{{- end }}
