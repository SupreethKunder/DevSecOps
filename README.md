# Library Charts

## Algorithm

### Versioning

- Increment the chart version in Chart.yaml based on Semantic Versioning.
- Package the helm charts to create a bundle.tgz for that new release with this cmd `helm package devops/`
- Index the new version in index.yaml with this cmd `helm repo index .`

### Adding Repo to Helm

`helm repo add devops --username "$PAT_TOKEN" --password "$PAT_TOKEN" "https://raw.githubusercontent.com/SupreethKunder/DevSecOps/common-charts/"`

### Verification

- List all repos via `helm repo list`
- If already configured, do `helm repo update`
- Check if the charts are updated with the new release via `helm search repo devops --devel`
