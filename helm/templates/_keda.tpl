{{ define "devops.keda" }}
apiVersion: keda.sh/v1alpha1
kind: ScaledJob
metadata:
  name: {{ include "devops.fullname" . }}
  namespace: {{ .Values.namespace }}
spec:
  pollingInterval: {{ .Values.pollingInterval }} 
  maxReplicaCount: {{ .Values.maxReplicaCount }} 
  successfulJobsHistoryLimit: {{ .Values.successfulJobsHistoryLimit }} 
  failedJobsHistoryLimit: {{ .Values.failedJobsHistoryLimit }}
  jobTargetRef:
    backoffLimit: {{ .Values.backoffLimit }}
    template:
      spec:
        {{- with .Values.imagePullSecrets }}
        imagePullSecrets:
          {{- toYaml . | nindent 12 }}
        {{- end }}
        containers:
        - name: {{ .Chart.Name }}
          securityContext:
            {{- toYaml .Values.securityContext | nindent 14 }}
          image: "{{ .Values.image.repository }}:{{ .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          command:
            {{- toYaml .Values.image.command | nindent 14 }}
          resources:
            {{- toYaml .Values.resources | nindent 14 }}
          {{- with .Values.volumeMounts }}
          volumeMounts:
            {{- toYaml . | nindent 14}}
          {{- end }}
        restartPolicy: Never
        {{- with .Values.volumes }}
        volumes:
          {{- toYaml . | nindent 10 }}
        {{- end }}
        {{- with .Values.nodeSelector }}
        nodeSelector:
          {{- toYaml . | nindent 10 }}
        {{- end }}
        {{- with .Values.tolerations }}
        tolerations:
          {{- toYaml . | nindent 10 }}
        {{- end }}
        {{- with .Values.affinity }}
        affinity:
          {{- toYaml . | nindent 10}}
        {{- end }}
  {{- with .Values.rollout }}
  rollout:
  {{ toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.scalingStrategy }}
  scalingStrategy:
  {{ toYaml . | nindent 4 }}
  {{- end }}
  triggers:
  - type: rabbitmq
    metadata:
      queueName: {{ .Values.queueName }}
      queueLength: {{ .Values.queueLength | quote }}
    authenticationRef:
      name: {{ include "devops.fullname" . }}-trigger
---
apiVersion: keda.sh/v1alpha1
kind: TriggerAuthentication
metadata:
  name: {{ include "devops.fullname" . }}-trigger
  namespace: {{ .Values.namespace }}
spec:
  {{- with .Values.secretTargetRef }}
  secretTargetRef:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}  