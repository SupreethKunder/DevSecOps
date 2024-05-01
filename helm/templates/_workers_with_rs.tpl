{{ define "devops.workerswithrs" }}
{{- if $.Values.workers.enabled -}}
{{- range $cmd := $.Values.workers.command }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ $cmd.id }}-{{ $.Values.env }}
  labels:
    app.kubernetes.io/name: {{ $cmd.id }}-{{ $.Values.env }}
    {{- include "devops.workerlabels" $ | nindent 4 }}
spec:
  replicas: {{ $.Values.workers.replicaCount }}
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app.kubernetes.io/name: {{ $cmd.id }}-{{ $.Values.env }}
      app.kubernetes.io/instance: {{ $.Release.Name }}
  template:
    metadata:
      {{- with $.Values.podAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      labels:
        app.kubernetes.io/name: {{ $cmd.id }}-{{ $.Values.env }}
        app.kubernetes.io/instance: {{ $.Release.Name }}
    spec:
      {{- with $.Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ $cmd.id }}-{{ $.Values.env }}
      securityContext:
        {{- toYaml $.Values.podSecurityContext | nindent 8 }}
      containers:
        - name: {{ $.Chart.Name }}
          securityContext:
            {{- toYaml $.Values.securityContext | nindent 12 }}
          args: 
            {{- toYaml $.Values.image.args | nindent 12 }}
          command: 
            - {{ $cmd.entrypoint }}
          image: "{{ $.Values.image.repository }}:{{ $.Chart.AppVersion }}"
          imagePullPolicy: {{ $.Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: {{ $.Values.image.port }}
              protocol: TCP
          resources:
            {{- toYaml $cmd.resources | nindent 12 }}
          volumeMounts:
            {{- toYaml $.Values.volumeMounts | nindent 12 }}  
      {{- with $.Values.volumes }}
      volumes:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $.Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $.Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $.Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
---
{{- if $.Values.serviceAccount.create -}}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ $cmd.id }}-{{ $.Values.env }}
  labels:
    app.kubernetes.io/name: {{ $cmd.id }}-{{ $.Values.env }}
    {{- include "devops.workerlabels" $ | nindent 4 }}
  {{- with $.Values.serviceAccount.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}      
{{- end }}
{{- end }}
{{- end }}
{{- end }}