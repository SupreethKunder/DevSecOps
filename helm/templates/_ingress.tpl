{{ define "devops.ingress" }}
{{- if .Values.ingress.enabled -}}
{{- $fullName := include "devops.fullname" . -}}
{{- $ingName := .Values.ingressName -}}
{{- $svcPort := .Values.service.port -}}
{{- if semverCompare ">=1.14-0" .Capabilities.KubeVersion.GitVersion -}}
apiVersion: networking.k8s.io/v1
{{- end }}
kind: Ingress
metadata:
  name: {{ $fullName }}
  labels:
    {{- include "devops.labels" . | nindent 4 }}
  {{- with .Values.ingress.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
    app.kubernetes.io/name: {{ include "devops.name" . }}
spec:
  ingressClassName: {{ .Values.ingressClassName }}
  tls: 
    - secretName: {{ $fullName }}-tls
      hosts:
        -  {{ if eq .Values.env "prod" }}"{{ $ingName }}.sirpi.co.in"{{ else }}"{{ $ingName }}-{{ .Values.env }}.sirpi.co.in"{{ end }}
  rules:
    - host: {{ if eq .Values.env "prod" }}"{{ $ingName }}.sirpi.co.in"{{ else }}"{{ $ingName }}-{{ .Values.env }}.sirpi.co.in"{{ end }}
      http:
        paths:
          {{- toYaml .Values.ingress.paths | nindent 10 }}
{{- end }}
{{- end }}