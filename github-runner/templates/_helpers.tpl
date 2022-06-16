{{/*
Expand the name of the chart.
*/}}
{{- define "github-runner.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "github-runner.fullname" -}}
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
{{- define "github-runner.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "github-runner.labels" -}}
helm.sh/chart: {{ include "github-runner.chart" .context }}
{{ include "github-runner.selectorLabels" (dict "context" .context "component" .component "name" .name) }}
app.kubernetes.io/managed-by: {{ .context.Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "github-runner.selectorLabels" -}}
{{- if .name -}}
app.kubernetes.io/name: {{ .name }}
{{ end -}}
app.kubernetes.io/instance: {{ .context.Release.Name }}
{{- if .component }}
app.kubernetes.io/component: {{ .component }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "github-runner.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "github-runner.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Generate runner environments
*/}}
{{- define "github-runner.config" -}}
{{- if.Values.dind.enabled }}
- name: DOCKER_HOST
  value: tcp://localhost:2375
{{- end }}
{{- if .Values.config.org }}
- name: RUNNER_SCOPE
  value: org
- name: ORG_NAME
  value: {{ .Values.config.orgName }}
{{- else }}
- name: RUNNER_SCOPE
  value: repo
- name: REPO_NAME
  value: {{ .Values.config.repoName }}
- name: REPO_OWNER
  value: {{ .Values.config.repoOwner }}
{{- end }}
- name: GITHUB_TOKEN
  valueFrom:
    secretKeyRef:
      name: {{ include "github-runner.fullname" . }}
      key: gh_token
- name: LABELS
  value: {{ join "," .Values.config.labels }}
{{- end }}

{{/*
Generate node selector. Default: default-pool (GKE)
*/}}
{{- define "github-runner.nodeSelector" -}}
{{- if .Values.nodeSelector }}
{{ toYaml .Values.nodeSelector }}
{{- else }}
cloud.google.com/gke-nodepool: default-pool
{{- end }}
{{- end }}
