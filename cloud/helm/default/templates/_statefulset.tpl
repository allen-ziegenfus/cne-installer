{{- define "liferay.statefulset" -}}
{{- $suffix := ternary "" (printf "-%s" .name) (eq .name "") }}
apiVersion: apps/v1
kind: StatefulSet
metadata:
    {{- with .statefulset.annotations }}
    annotations:
        {{- toYaml . | nindent 8 }}
    {{- end }}
    # checkov:skip=CKV_K8S_21:Namespace is set dynamically by Helm/ArgoCD
    # checkov:skip=CKV_K8S_38:Service account token mounting is optional
    # checkov:skip=CKV_K8S_13:Resource limits are configurable by user
    # checkov:skip=CKV_K8S_43:Image digest is not required for this template
    # checkov:skip=CKV_K8S_20:Allow privilege escalation is configurable
    # checkov:skip=CKV_K8S_22:Read-only root filesystem is optional
    # checkov:skip=CKV_K8S_31:Seccomp profile is configurable
    # checkov:skip=CKV_K8S_11:CPU limits are configurable
    # checkov:skip=CKV_K8S_30:Security context is configurable
    # checkov:skip=CKV_K8S_40:User UID is configurable
    # checkov:skip=CKV_K8S_10:CPU requests are configurable
    # checkov:skip=CKV_K8S_35:Secrets as env vars are allowed for Liferay
    # checkov:skip=CKV_K8S_14:Image tag is configurable
    # checkov:skip=CKV_K8S_28:NET_RAW capability is allowed if needed
    # checkov:skip=CKV_K8S_37:Capabilities are configurable
    # checkov:skip=CKV_K8S_12:Memory requests are configurable
    # checkov:skip=CKV_K8S_29:Security context is configurable
    # checkov:skip=CKV2_K8S_6:NetworkPolicy is optional
    labels:
        app: {{ include "liferay.name" .root }}{{ $suffix }}
        {{- include "liferay.labels" .root | nindent 8 }}
    name: {{ include "liferay.name" .root }}{{ $suffix }}
    namespace: {{ include "liferay.namespace" .root }}
spec:
    replicas: {{ .statefulset.replicaCount }}
    selector:
        matchLabels:
            app: {{ include "liferay.name" .root }}{{ $suffix }}
            {{- include "liferay.selectorLabels" .root | nindent 12 }}
    serviceName: {{ include "liferay.name" .root }}{{ $suffix }}
    template:
        metadata:
            annotations:
                checksum/config: {{ include (print .root.Template.BasePath "/configmap.yaml") .root | sha256sum }}
                {{- with .statefulset.podAnnotations }}
                {{- toYaml . | nindent 16 }}
                {{- end }}
            labels:
                app: {{ include "liferay.name" .root }}{{ $suffix }}
                {{- include "liferay.labels" .root | nindent 16 }}
        spec:
            {{- with .statefulset.affinity }}
            affinity:
                {{- toYaml . | nindent 16 }}
            {{- end }}
            containers:
                -   #
                    {{- if or .statefulset.env .statefulset.customEnv }}
                    env:
                        {{- with .statefulset.env }}
                        {{- toYaml . | nindent 22 }}
                        {{- end }}
                        {{- range $k, $v := .statefulset.customEnv }}
                        {{- toYaml $v | nindent 22 }}
                        {{- end }}
                    {{- end }}
                    {{- if or .statefulset.envFrom .statefulset.customEnvFrom }}
                    envFrom:
                        {{- with .statefulset.envFrom }}
                        {{- toYaml . | nindent 22 }}
                        {{- end }}
                        {{- range $k, $v := .statefulset.customEnvFrom }}
                        {{- toYaml $v | nindent 22 }}
                        {{- end }}
                    {{- end }}
                    image: {{ printf "%s:%s" .statefulset.image.repository (.statefulset.image.tag | toString) }}
                    imagePullPolicy: {{ .statefulset.image.pullPolicy }}
                    {{- with .statefulset.livenessProbe }}
                    livenessProbe:
                        {{- toYaml . | nindent 22 }}
                    {{- end }}
                    name: {{ include "liferay.name" .root }}{{ $suffix }}
                    {{- if or .statefulset.ports .statefulset.customPorts }}
                    ports:
                        {{- with .statefulset.ports }}
                        {{- toYaml . | nindent 22 }}
                        {{- end }}
                        {{- range $k, $v := .statefulset.customPorts }}
                        {{- toYaml $v | nindent 22 }}
                        {{- end }}
                    {{- end }}
                    {{- with .statefulset.readinessProbe }}
                    readinessProbe:
                        {{- toYaml . | nindent 22 }}
                    {{- end }}
                    {{- with .statefulset.resources }}
                    resources:
                        {{- toYaml . | nindent 22 }}
                    {{- end }}
                    {{- with .statefulset.securityContext }}
                    securityContext:
                        {{- toYaml . | nindent 22 }}
                    {{- end }}
                    {{- with .statefulset.startupProbe }}
                    startupProbe:
                        {{- toYaml . | nindent 22 }}
                    {{- end }}
                    {{- if or .statefulset.volumeMounts .statefulset.customVolumeMounts}}
                    volumeMounts:
                        {{- with .statefulset.volumeMounts }}
                        {{- toYaml . | nindent 22 }}
                        {{- end }}
                        {{- range $k, $v := .statefulset.customVolumeMounts }}
                        {{- toYaml $v | nindent 22 }}
                        {{- end }}
                    {{- end }}
            {{- if or .statefulset.pullSecrets .statefulset.customPullSecrets}}
            imagePullSecrets:
                {{- with .statefulset.pullSecrets }}
                {{- toYaml . | nindent 16 }}
                {{- end }}
                {{- range $k, $v := .statefulset.customPullSecrets }}
                {{- toYaml $v | nindent 16 }}
                {{- end }}
            {{- end }}
            {{- if or .statefulset.initContainers .statefulset.customInitContainers }}
            {{- $statefulset := merge .statefulset (dict "liferayname" (include "liferay.name" .root)) }}
            initContainers:
                {{- range .statefulset.initContainers }}
                {{- if .containerTemplate }}
                {{- tpl .containerTemplate $statefulset | nindent 16 }}
                {{- else }}
                -   #
                    {{- toYaml . | nindent 18 }}
                {{- end }}
                {{- end }}
                {{- range $k, $v := .statefulset.customInitContainers }}
                {{- range $entry := $v }}
                {{- if $entry.containerTemplate }}
                {{- tpl $entry.containerTemplate $statefulset | nindent 16 }}
                {{- else }}
                -   #
                    {{- toYaml $entry | nindent 18 }}
                {{- end }}
                {{- end }}
                {{- end }}
            {{- end }}
            {{- with .statefulset.nodeSelector }}
            nodeSelector:
                {{- toYaml . | nindent 16 }}
            {{- end }}
            {{- with .statefulset.schedulingGates }}
            schedulingGates:
                {{- toYaml . | nindent 16 }}
            {{- end }}
            {{- with .statefulset.podSecurityContext }}
            securityContext:
                {{- toYaml . | nindent 16 }}
            {{- end }}
            serviceAccountName: {{ include "liferay.serviceAccountName" .root }}
            {{- with .statefulset.tolerations }}
            tolerations:
            {{- toYaml . | nindent 12 }}
            {{- end }}
            {{- if or .statefulset.volumes .statefulset.customVolumes }}
            volumes:
                {{- with .statefulset.volumes }}
                {{- toYaml . | nindent 16 }}
                {{- end }}
                {{- if and .statefulset.overlay .statefulset.overlay.enabled }}
                -   name: {{ .statefulset.overlay.bucketName }}
                    persistentVolumeClaim:
                        claimName: {{ .statefulset.overlay.bucketName }}
                {{- end }}
                {{- range $k, $v := .statefulset.customVolumes }}
                {{- toYaml $v | nindent 16 }}
                {{- end }}
            {{- end }}
    {{- with .statefulset.updateStrategy }}
    updateStrategy:
        {{- toYaml . | nindent 8 }}
    {{- end }}
    {{- if or .statefulset.volumeClaimTemplates .statefulset.customVolumeClaimTemplates }}
    volumeClaimTemplates:
        {{- with .statefulset.volumeClaimTemplates }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
        {{- range $k, $v := .statefulset.customVolumeClaimTemplates }}
        {{- toYaml $v | nindent 8 }}
        {{- end }}
    {{- end }}
---
apiVersion: v1
kind: Service
metadata:
    {{- with .statefulset.service.annotations }}
    annotations:
        {{- toYaml . | nindent 8 }}
    {{- end }}
    # checkov:skip=CKV_K8S_21:Namespace is set dynamically by Helm/ArgoCD
    labels:
        app: {{ include "liferay.name" .root }}{{ $suffix }}
        {{- include "liferay.labels" .root | nindent 8 }}
    name: {{ include "liferay.name" .root }}{{ $suffix }}
    namespace: {{ include "liferay.namespace" .root }}
spec:
    {{- if or .statefulset.service.ports .statefulset.customServicePorts }}
    ports:
    {{- with .statefulset.service.ports }}
        {{- toYaml . | nindent 8 }}
    {{- end }}
    {{- range $k, $v := .statefulset.customServicePorts }}
        {{- toYaml $v | nindent 8 }}
    {{- end }}
    {{- end }}
    selector:
        app: {{ include "liferay.name" .root }}{{ $suffix }}
        {{- include "liferay.selectorLabels" .root | nindent 8 }}
    type: {{ .statefulset.service.type }}
---
apiVersion: v1
kind: Service
metadata:
    {{- with .statefulset.service.annotations }}
    annotations:
        {{- toYaml . | nindent 8 }}
    {{- end }}
    # checkov:skip=CKV_K8S_21:Namespace is set dynamically by Helm/ArgoCD
    labels:
        app: {{ include "liferay.name" .root }}{{ $suffix }}
        {{- include "liferay.labels" .root | nindent 8 }}
    name: {{ include "liferay.name" .root }}{{ $suffix }}-headless
    namespace: {{ include "liferay.namespace" .root }}
spec:
    clusterIP: None
    {{- with .statefulset.service.ports }}
    ports:
        {{- toYaml . | nindent 8 }}
    {{- end }}
    selector:
        app: {{ include "liferay.name" .root }}{{ $suffix }}
        {{- include "liferay.selectorLabels" .root | nindent 8 }}
    type: ClusterIP
{{- if and .statefulset.ingress .statefulset.ingress.enabled }}
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
    {{- with .statefulset.ingress.annotations }}
    annotations:
        {{- toYaml . | nindent 8 }}
    {{- end }}
    labels:
        app: {{ include "liferay.name" .root }}{{ $suffix }}
        {{- include "liferay.labels" .root | nindent 8 }}
    name: {{ include "liferay.name" .root }}{{ $suffix }}
    namespace: {{ include "liferay.namespace" .root }}
spec:
    {{- with .statefulset.ingress.className }}
    ingressClassName: {{ . }}
    {{- end }}
    rules:
        {{- with .statefulset.ingress.rules }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
    {{- with .statefulset.ingress.tls }}
    tls:
        {{- range $tls := . }}
        -   hosts:
            {{- toYaml $tls.hosts | nindent 12 }}
            secretName: {{ $tls.secretName }}
        {{- end }}
    {{- end }}
{{- end }}
{{- end -}}