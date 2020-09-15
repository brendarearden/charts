# Rancher
{{- define "system_default_registry" -}}
{{- if .Values.global.cattle.systemDefaultRegistry -}}
{{- printf "%s/" .Values.global.cattle.systemDefaultRegistry -}}
{{- end -}}
{{- end -}}

# Special Exporters
{{- define "exporter.kubeEtcd.enabled" -}}
{{- if or .Values.kubeEtcd.enabled .Values.rkeEtcd.enabled .Values.kubeAdmEtcd.enabled .Values.rke2Etcd.enabled -}}
"true"
{{- end -}}
{{- end }}

{{- define "exporter.kubeControllerManager.enabled" -}}
{{- if or .Values.kubeControllerManager.enabled .Values.rkeControllerManager.enabled .Values.k3sControllerManager.enabled .Values.kubeAdmControllerManager.enabled .Values.rke2ControllerManager.enabled -}}
"true"
{{- end -}}
{{- end }}

{{- define "exporter.kubeScheduler.enabled" -}}
{{- if or .Values.kubeScheduler.enabled .Values.rkeScheduler.enabled .Values.k3sScheduler.enabled .Values.kubeAdmScheduler.enabled .Values.rke2Scheduler.enabled -}}
"true"
{{- end -}}
{{- end }}

{{- define "exporter.kubeProxy.enabled" -}}
{{- if or .Values.kubeProxy.enabled .Values.rkeProxy.enabled .Values.k3sProxy.enabled .Values.kubeAdmProxy.enabled .Values.rke2Proxy.enabled -}}
"true"
{{- end -}}
{{- end }}

# Prometheus Operator

{{/* vim: set filetype=mustache: */}}
{{/* Expand the name of the chart. This is suffixed with -alertmanager, which means subtract 13 from longest 63 available */}}
{{- define "prometheus-operator.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 50 | trimSuffix "-" -}}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
The components in this chart create additional resources that expand the longest created name strings.
The longest name that gets created adds and extra 37 characters, so truncation should be 63-35=26.
*/}}
{{- define "prometheus-operator.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 26 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 26 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 26 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* Fullname suffixed with operator */}}
{{- define "prometheus-operator.operator.fullname" -}}
{{- printf "%s-operator" (include "prometheus-operator.fullname" .) -}}
{{- end }}

{{/* Fullname suffixed with prometheus */}}
{{- define "prometheus-operator.prometheus.fullname" -}}
{{- printf "%s-prometheus" (include "prometheus-operator.fullname" .) -}}
{{- end }}

{{/* Fullname suffixed with alertmanager */}}
{{- define "prometheus-operator.alertmanager.fullname" -}}
{{- printf "%s-alertmanager" (include "prometheus-operator.fullname" .) -}}
{{- end }}

{{/* Create chart name and version as used by the chart label. */}}
{{- define "prometheus-operator.chartref" -}}
{{- replace "+" "_" .Chart.Version | printf "%s-%s" .Chart.Name -}}
{{- end }}

{{/* Generate basic labels */}}
{{- define "prometheus-operator.labels" }}
chart: {{ template "prometheus-operator.chartref" . }}
release: {{ $.Release.Name | quote }}
heritage: {{ $.Release.Service | quote }}
{{- if .Values.commonLabels}}
{{ toYaml .Values.commonLabels }}
{{- end }}
{{- end }}

{{/* Create the name of prometheus-operator service account to use */}}
{{- define "prometheus-operator.operator.serviceAccountName" -}}
{{- if .Values.prometheusOperator.serviceAccount.create -}}
    {{ default (include "prometheus-operator.operator.fullname" .) .Values.prometheusOperator.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.prometheusOperator.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/* Create the name of prometheus service account to use */}}
{{- define "prometheus-operator.prometheus.serviceAccountName" -}}
{{- if .Values.prometheus.serviceAccount.create -}}
    {{ default (include "prometheus-operator.prometheus.fullname" .) .Values.prometheus.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.prometheus.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/* Create the name of alertmanager service account to use */}}
{{- define "prometheus-operator.alertmanager.serviceAccountName" -}}
{{- if .Values.alertmanager.serviceAccount.create -}}
    {{ default (include "prometheus-operator.alertmanager.fullname" .) .Values.alertmanager.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.alertmanager.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Allow the release namespace to be overridden for multi-namespace deployments in combined charts
*/}}
{{- define "prometheus-operator.namespace" -}}
  {{- if .Values.namespaceOverride -}}
    {{- .Values.namespaceOverride -}}
  {{- else -}}
    {{- .Release.Namespace -}}
  {{- end -}}
{{- end -}}

{{- define "prometheus_proxy_url" -}}
{{- $url := "https://brendar.do.rancher.space" -}}
{{- $clusterId := required "Rancher Cluster ID required to construct proxy URL" .Values.global.cattle.clusterId -}}
{{- $proxyURLFmt := "%s/k8s/clusters/%s/api/v1/namespaces/%s/services/http:%s-prometheus:%.0f/proxy" -}}
{{- printf $proxyURLFmt $url $clusterId (include "prometheus-operator.namespace" .) (include "prometheus-operator.fullname" .) .Values.prometheus.service.port -}}
{{- end -}}

{{- define "alertmanager_proxy_url" -}}
{{- $url := "https://brendar.do.rancher.space" -}}
{{- $clusterId := required "Rancher Cluster ID required to construct proxy URL" .Values.global.cattle.clusterId -}}
{{- $proxyURLFmt := "%s/k8s/clusters/%s/api/v1/namespaces/%s/services/http:%s-alertmanager:%.0f/proxy" -}}
{{- printf $proxyURLFmt $url $clusterId (include "prometheus-operator.namespace" .) (include "prometheus-operator.fullname" .) .Values.alertmanager.service.port -}}
{{- end -}}