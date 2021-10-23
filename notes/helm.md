Helm - bundle together kubernetes primitives.
helm install wordpress
helm upgrade wordpress
helm rollback wordpress
helm uninstall wordpress
helm list
helm pull --untar bitnami/wordpress

Install helm:
sudo snap install helm --classic
https://helm.sh/docs/intro/install/

Concepts:
- variables are defined in templates `{{ .Values.storage }}` or `{{ .Values.passwordEncoded }}`
- later those values are stored in `values.yaml` file
like:
```yaml
storage: 20Gi
passwordEncoded: cd403C2ff31hYDaff4w
```
- Chart.yaml is metadata file

- charts = values.yaml + [list of templates] + Chart.yaml
- https://artifacthub.io/ - repository that stores Helm charts
- helm search hub wordpress
- helm repo add bitnami https://charts.bitnami.com/bitnami
- helm install [release-name] [chart-name(path)]