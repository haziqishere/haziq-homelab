# haziq-homelab

A GitOps-managed Kubernetes homelab built on k3s, purpose-built for data/ML workloads and personal media.

---

## Hardware

### Control Plane

| Component | Spec |
|-----------|------|
| CPU | Intel i5 |
| GPU | NVIDIA GTX 1060 3GB |
| RAM | 16GB |
| Boot | 250GB SSD (`/`) |
| Storage | 500GB HDD (`/mnt/obj-storage`) |
| OS | Arch Linux |
| Network | Tailscale VPN + Wake-on-LAN |

### Worker Node (Raspberry PI)

| Component | Spec |
|-----------|------|
| RAM | 4GB |
| OS | RapberryOS |
| Role | k3s agent — Persistent light-weight load |

### Worker Node (Gaming PC)

| Component | Spec |
|-----------|------|
| GPU | NVIDIA RTX 3060 12GB |
| Memory | 32GB |
| OS | Arch Linux |
| Role | k3s agent — GPU/Memory-heavy ML workloads |

---

## Architecture

All cluster state is managed via ArgoCD — the only manual steps are one-time bootstrapping (ArgoCD install + secrets). After that, every change is via git and PR.

```
MacBook (write manifests + run bootstrap)
        │
        ├── git push → GitHub → ArgoCD watches → applies to k3s
        │
        └── kubectl (over Tailscale) → k3s directly
```

### Access

| Service | External | Internal |
|---------|----------|----------|
| Jellyfin | `https://jellyfin.haziqhakimi.online` (Cloudflare Tunnel) | Traefik ingress `/jellyfin` |
| Immich | `https://immich.haziqhakimi.online` (Cloudflare Tunnel) | NodePort `:30283` |
| ArgoCD | — | Tailscale only |
| Grafana | — | Tailscale only |
| Kubeflow | — | Tailscale only |
| Filebrowser | — | Tailscale only |
| Komga | — | Tailscale only |
| Minecraft | Cloudflare Tunnel (public) | — |

---

## Running Applications

| Application | Namespace | Path |
|-------------|-----------|------|
| argocd | argocd | `infrastructure/argocd` |
| cloudflare-tunnel | cloudflare | `infrastructure/cloudflare-tunnel` |
| gpu-operator | gpu-operator | `infrastructure/nvidia-gpu-operator` |
| nfs-csi | kube-system | `infrastructure/nfs-csi` |
| traefik | kube-system | `infrastructure/traefik` |
| kubeflow-crds | kubeflow | `platform/kubeflow` |
| kubeflow-pipelines | kubeflow | `platform/kubeflow/kubeflow-pipeline` |
| spark-operator | spark | `platform/spark-operator` |
| prefect | prefect | `platform/prefect` |
| vault | vault | `platform/vault` |
| nas (nfs-server) | nas | `workload/nas` |
| minecraft | minecraft | `workload/minecraft` |
| jellyfin | jellyfin | `workload/jellyfin` |
| immich | immich | `workload/immich` |
| filebrowser | filebrowser | `workload/filebrowser` |
| plex | plex | `workload/plex` |
| stirling-pdf | stirling-pdf | `workload/stirling-pdf` |
| komga | komga | `workload/komga` |

---

## Repo Structure

```
haziq-homelab/
├── bootstrap/                  # One-time setup scripts (run from MacBook)
│   ├── install-argocd.sh
│   └── apply-secrets.sh
│
├── infrastructure/             # Core cluster components (ArgoCD managed)
│   ├── argocd/
│   ├── cloudflare-tunnel/
│   ├── nfs-csi/
│   ├── nvidia-gpu-operator/
│   └── traefik/
│
├── platform/                   # Data/ML platform operators
│   ├── kubeflow/
│   ├── prefect/
│   ├── spark-operator/
│   └── vault/
│
├── workload/                   # Application workloads
│   ├── filebrowser/
│   ├── immich/
│   ├── jellyfin/
│   ├── komga/
│   ├── minecraft/
│   ├── nas/
│   ├── plex/
│   ├── stirling-pdf/
│   └── spark-jobs/
│
├── secrets/                    # Templates only — no real values committed
└── docs/
```

---

## Bootstrap (Fresh Cluster Setup)

```bash
# 1. Install ArgoCD
kubectl apply -k infrastructure/argocd/

# 2. Apply secrets (one-time)
bash bootstrap/apply-secrets.sh

# 3. Create ArgoCD applications pointing at this repo
#    ArgoCD will reconcile everything else automatically
```

---

## Roadmap

### Phase 1 — Core Platform
- [x] k3s single-node control plane
- [x] k3s multi-node (gaming PC as agent)
- [x] kubectl access from MacBook over Tailscale
- [x] ArgoCD (GitOps)
- [x] Cloudflare Tunnel
- [x] NVIDIA GPU operator (GTX 1060 / CUDA + time-slicing)
- [x] NFS CSI driver

### Phase 2 — Data Platform
- [x] Kubeflow Pipelines (lightweight install)
- [x] Spark Operator
- [x] Prefect (self-hosted)
- [x] Vault

### Phase 3 — Media & Personal Workloads
- [x] Minecraft (public via Cloudflare Tunnel)
- [x] Jellyfin (GPU transcoding via NVENC)
- [x] Plex
- [x] Immich (photo management, ML on GPU)
- [x] Filebrowser
- [x] Stirling PDF
- [x] Komga (manga/comic/book server)
- [ ] TODO: Add mechanism to backup photos to S3

### Phase 4 — Observability
- [x] Grafana + Prometheus
- [ ] OpenTelemetry collector
- [ ] Loki for log aggregation

---

## Secrets Strategy

All secrets are managed as Kubernetes Secrets, **never committed to git**.

| Secret | How |
|--------|-----|
| AWS IAM credentials | `kubectl create secret generic aws-creds --from-literal=...` |
| Cloudflare Tunnel token | `kubectl create secret generic cloudflare-token --from-literal=...` |
| ArgoCD admin password | Auto-generated on install |
| ghcr.io pull secret | `kubectl create secret docker-registry ghcr-secret ...` |

`secrets/` contains example templates only. Real values are applied manually via `bootstrap/apply-secrets.sh`.
