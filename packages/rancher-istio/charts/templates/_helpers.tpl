{{/* Ensure namespace is set the same everywhere */}}
{{- define "istio.namespace" -}}
  {{- .Release.Namespace | default "istio-system" -}}
{{- end -}}

{{- define "system_default_registry" -}}
{{- if .Values.global.systemDefaultRegistry -}}
{{- printf "%s/" .Values.global.systemDefaultRegistry -}}
{{- else -}}
{{- "" -}}
{{- end -}}
{{- end -}}

{{- define "app.name" -}}
{{- default .Chart.Name .Values.nameOverride -}}
{{- end -}}

{{- define "app.version" -}}
{{- $name := include "app.name" . -}}
{{- $version := .Chart.Version | replace "+" "_" -}}
{{- printf "%s-%s" $name $version -}}
{{- end -}}

{{- define "app.fullname" -}}
{{- $name := include "app.name" . -}}
{{- printf "%s-%s" $name .Release.Name -}}
{{- end -}}
