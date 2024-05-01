{{ define "devops.serviceaccount" }}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "devops.serviceAccountName" . }}
  labels:
    {{- include "devops.labels" . | nindent 4 }}
  {{- with .Values.serviceAccount.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
