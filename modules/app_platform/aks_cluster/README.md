aks_cluster/README.md

# Module: app_platform/aks_cluster

Creates an AKS cluster with Azure CNI networking, system-assigned managed
identity, AGIC add-on, workload identity, OMS agent, and control plane
diagnostic settings.

## Resources Created
- `azurerm_resource_group`
- `azurerm_kubernetes_cluster`
- `azurerm_monitor_diagnostic_setting` (optional)

## Usage
```hcl
module "aks" {
  source = "../../../modules/app_platform/aks_cluster"

  resource_group_name = "rg-aks-dev"
  location            = "eastus"
  cluster_name        = "aks-devsocket-dev"
  dns_prefix          = "devsocket-dev"
  kubernetes_version  = null
  sku_tier            = "Free"

  node_pool_name  = "systempool"
  node_count      = 1
  vm_size         = "Standard_B2s"
  os_disk_size_gb = 30
  max_pods        = 30

  vnet_subnet_id = "<aks-spoke-subnet-id>"
  network_plugin = "azure"
  network_policy = "azure"
  service_cidr   = "172.16.0.0/16"
  dns_service_ip = "172.16.0.10"

  enable_agic    = true
  app_gateway_id = "<app-gateway-resource-id>"

  enable_workload_identity   = true
  log_analytics_workspace_id = "<log-analytics-workspace-id>"

  tags = {
    environment = "dev"
    managed_by  = "terraform"
    project     = "devsocket-landing-zone"
    layer       = "app-platform"
  }
}
```

## Two-Pass Deployment Pattern

AKS has circular dependencies with ACR, Key Vault and App Gateway:
- AKS needs App Gateway ID for AGIC
- ACR needs AKS kubelet identity for AcrPull role
- Key Vault needs AKS kubelet identity for Secrets User role

### Pass 1 — Deploy App Gateway first, then AKS
```
1. Deploy App Gateway → get app_gateway_id
2. Deploy AKS with app_gateway_id → get kubelet_identity_object_id
```

### Pass 2 — Wire up role assignments
```
3. Update ACR caller — set enable_aks_pull_access = true
4. Update Key Vault caller — add role_assignments entry
5. Re-apply both
```

## Post-Deploy — Get kubeconfig
```bash
az aks get-credentials \
  --resource-group rg-aks-dev \
  --name aks-devsocket-dev \
  --overwrite-existing
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| resource_group_name | string | — | Resource group name |
| location | string | — | Azure region |
| cluster_name | string | — | AKS cluster name |
| dns_prefix | string | — | DNS prefix for cluster FQDN |
| kubernetes_version | string | null | K8s version, null = latest |
| sku_tier | string | "Free" | Free or Standard |
| node_pool_name | string | "systempool" | Default node pool name |
| node_count | number | 1 | Node count |
| vm_size | string | "Standard_B2s" | Node VM size |
| os_disk_size_gb | number | 30 | OS disk size GB |
| max_pods | number | 30 | Max pods per node |
| vnet_subnet_id | string | — | AKS subnet ID |
| network_plugin | string | "azure" | azure or kubenet |
| network_policy | string | "azure" | azure or calico |
| service_cidr | string | "172.16.0.0/16" | K8s service CIDR |
| dns_service_ip | string | "172.16.0.10" | K8s DNS service IP |
| enable_agic | bool | true | Enable AGIC add-on |
| app_gateway_id | string | null | App Gateway resource ID |
| enable_workload_identity | bool | true | Enable workload identity |
| log_analytics_workspace_id | string | null | Log Analytics workspace ID |
| tags | map(string) | {} | Resource tags |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | AKS cluster resource ID |
| cluster_name | AKS cluster name |
| resource_group_name | Resource group name |
| kube_config_raw | Raw kubeconfig (sensitive) |
| host | API server endpoint (sensitive) |
| cluster_identity_principal_id | Cluster system identity — for VNet RBAC |
| kubelet_identity_object_id | Kubelet identity — for ACR + Key Vault RBAC |
| kubelet_identity_client_id | Kubelet client ID — for workload identity |
| oidc_issuer_url | OIDC issuer URL for workload identity federation |
| agic_identity_object_id | AGIC identity — needs Contributor on App GW RG |
| node_resource_group | Auto-generated node infrastructure resource group |

## Notes
- Deploy App Gateway before AKS — AGIC add-on needs the gateway ID at cluster creation
- `cluster_identity` and `kubelet_identity` are different — assign roles to both correctly
- AGIC identity needs `Contributor` on the App Gateway resource group after deploy
- `azure_policy_enabled` is hardcoded true — no variable, always on
- `service_cidr` must not overlap with hub (10.0.0.0/16) or spoke (10.1.0.0/16)