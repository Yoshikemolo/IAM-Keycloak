{{/*
==========================================================================
_helpers.tpl -- Shared template helpers for the xiam-keycloak Helm chart
==========================================================================
These helpers follow the Helm best-practice naming conventions and are
referenced throughout every other template in this chart.
*/}}

{{/*
Expand the name of the chart.
Truncated to 63 characters because Kubernetes name fields are limited to
this length by the DNS naming specification (RFC 1123).
*/}}
{{- define "xiam-keycloak.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified application name.
We truncate at 63 chars because some Kubernetes name fields are limited
to this (by the DNS naming spec).  If the release name already contains
the chart name it will not be duplicated.
*/}}
{{- define "xiam-keycloak.fullname" -}}
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
{{- define "xiam-keycloak.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels applied to every resource managed by this chart.
Includes the Helm-standard recommended labels plus app.kubernetes.io
labels for consistent identification.
*/}}
{{- define "xiam-keycloak.labels" -}}
helm.sh/chart: {{ include "xiam-keycloak.chart" . }}
{{ include "xiam-keycloak.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: xiam-platform
{{- end }}

{{/*
Selector labels -- the minimal set used in spec.selector.matchLabels and
in Service selectors.  These MUST NOT change between upgrades.
*/}}
{{- define "xiam-keycloak.selectorLabels" -}}
app.kubernetes.io/name: {{ include "xiam-keycloak.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Return the name of the ServiceAccount to use.
If serviceAccount.create is true, use the generated fullname; otherwise
fall back to the explicitly provided name or "default".
*/}}
{{- define "xiam-keycloak.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "xiam-keycloak.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Return the name of the Secret that holds database credentials.
If an existing secret is specified, use it; otherwise fall back to the
chart-generated secret "<fullname>-db".
*/}}
{{- define "xiam-keycloak.dbSecretName" -}}
{{- if .Values.keycloak.database.existingSecret }}
{{- .Values.keycloak.database.existingSecret }}
{{- else }}
{{- printf "%s-db" (include "xiam-keycloak.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Return the name of the Secret that holds admin credentials.
If an existing secret is specified, use it; otherwise fall back to the
chart-generated secret "<fullname>-admin".
*/}}
{{- define "xiam-keycloak.adminSecretName" -}}
{{- if .Values.keycloak.admin.existingSecret }}
{{- .Values.keycloak.admin.existingSecret }}
{{- else }}
{{- printf "%s-admin" (include "xiam-keycloak.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Render the image reference in the form repository:tag.
*/}}
{{- define "xiam-keycloak.image" -}}
{{- printf "%s:%s" .Values.image.repository (.Values.image.tag | default .Chart.AppVersion) }}
{{- end }}
