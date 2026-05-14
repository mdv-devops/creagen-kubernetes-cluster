# Hetzner Kubernetes Autoscaler

Components:
- Prometheus alerts
- Alertmanager webhooks
- Jenkins pipelines
- Terraform worker scaling

Required Jenkins plugins:
- Generic Webhook Trigger
- Lockable Resources
- Git
- Pipeline

Required tools in Jenkins agent:
- terraform
- kubectl
- jq
- git
