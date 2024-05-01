{{ define "devops.cronjobwithrs" }}
{{- if $.Values.crons.enabled -}}
{{- range $cmd := $.Values.crons.command }}
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: {{ $cmd.id }}-{{ $.Values.env }}
  labels:
    app.kubernetes.io/name: {{ $cmd.id }}-{{ $.Values.env }}
    app.kubernetes.io/instance: {{ $.Release.Name }}
    app.kubernetes.io/version: {{ $.Chart.AppVersion | quote }}
    app.kubernetes.io/managed-by: {{ $.Release.Service }}
spec:
  successfulJobsHistoryLimit: {{ $.Values.successfulJobsHistoryLimit }}
  failedJobsHistoryLimit: {{ $.Values.failedJobsHistoryLimit }}
  schedule: {{ $cmd.schedule | quote }}
  jobTemplate:
    spec:
      completions: {{ $.Values.completions }}
      parallelism: {{ $.Values.parallelism }} 
      template:
        spec:
          {{- with $.Values.imagePullSecrets }}
          imagePullSecrets:
            {{- toYaml . | nindent 16 }}
          {{- end }}
          serviceAccountName: {{ $cmd.id }}-{{ $.Values.env }}
          securityContext:
            {{- toYaml $.Values.podSecurityContext | nindent 16 }}
          containers:
            - name: {{ $.Chart.Name }}
              securityContext:
                {{- toYaml $.Values.securityContext | nindent 20 }}
              args: 
                {{- toYaml $.Values.image.args | nindent 20 }}
              command: 
                - {{ $cmd.entrypoint }}
              image: "{{ $.Values.image.repository }}:{{ $.Chart.AppVersion }}"
              imagePullPolicy: {{ $.Values.image.pullPolicy }}
              {{- with $cmd.resources }}
              resources:
                {{- toYaml $cmd.resources | nindent 20 }}
              {{- end }}    
              volumeMounts:
                {{- toYaml $.Values.volumeMounts | nindent 20 }}  
          {{- with $.Values.volumes }}
          restartPolicy: OnFailure
          volumes:
            {{- toYaml . | nindent 16 }}
          {{- end }}
          {{- with $.Values.nodeSelector }}
          nodeSelector:
            {{- toYaml . | nindent 16 }}
          {{- end }}
          {{- with $.Values.affinity }}
          affinity:
            {{- toYaml . | nindent 16 }}
          {{- end }}
          {{- with $.Values.tolerations }}
          tolerations:
            {{- toYaml . | nindent 16 }}
          {{- end }}
---
{{- if $.Values.serviceAccount.create -}}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ $cmd.id }}-{{ $.Values.env }}
  labels:
    app.kubernetes.io/name: {{ $cmd.id }}-{{ $.Values.env }}
    app.kubernetes.io/instance: {{ $.Release.Name }}
    app.kubernetes.io/version: {{ $.Chart.AppVersion | quote }}
    app.kubernetes.io/managed-by: {{ $.Release.Service }}
  {{- with $.Values.serviceAccount.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}      
{{- end }}
{{- end }}
{{- end }}
{{- end }}