## Deploy Prometheus Stack Helm Chart

```bash
helm repo add prometheus-community \
https://prometheus-community.github.io/helm-charts
```
```bash
helm repo update
```

### Install Prometheus

```bash
kubectl apply -f kubernetes-manifests/0-namespace.yaml
```

```bash
helm upgrade -i monitoring \
prometheus-community/kube-prometheus-stack \
--values helm-values/prometheus-values.yaml \
--version 84.5.0 \
--namespace monitoring
```

### Check application status
```bash
watch kubectl get all -n monitoring
```

### Install network connection

```bash
kubectl apply -f ingresses/
```
