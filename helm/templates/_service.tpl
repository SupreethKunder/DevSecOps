{{ define "devops.service" }}
{{- if .Values.service.enabled -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "devops.fullname" . }}
  labels:
    {{- include "devops.labels" . | nindent 4 }}
spec:
  type: {{ .Values.service.type }}
  ports:
    {{- toYaml .Values.service.ports | nindent 4 }}
  selector:
    {{- include "devops.selectorLabels" . | nindent 4 }}
{{- end }}
{{- end }}
