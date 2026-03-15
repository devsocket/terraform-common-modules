# terraform-common-modules

> **Reusable, composable Terraform modules for Azure Landing Zone patterns.**  
> Designed for platform engineering teams building consistent, governed Azure infrastructure at scale.  
> Consumed by [`terraform-landing-zone-demo`](https://github.com/devsocket/terraform-landing-zone-demo) and intended for use across multiple Azure environments.

-------

## 📐 Design Philosophy

This library follows **platform engineering principles** — centralise infrastructure patterns once, consume them everywhere:

- **Single responsibility**: each module provisions one logical Azure resource group with clean input/output contracts
- **Version-pinned providers**: every module pins `azurerm` and related providers to avoid drift
- **Composable**: modules are designed to be called from Landing Zone configurations or standalone pipelines without modification
- **Opinionated defaults**: sensible security defaults baked in (private endpoints, RBAC, diagnostic settings) — overridable via variables
- **Environment promotion**: same module code deploys to dev, staging, and production — environment differences expressed through variable inputs only

-------

## 🗂️ Module Catalogue

```
modules/
├── app_platform/
│   ├── acr/                    # Azure Container Registry + private endpoint
│   └── keyvault/               # App-level Key Vault + private endpoint + RBAC
│
├── connectivity/
│   ├── hub_vnet/               # Hub VNet + subnets + route tables (hub-spoke topology)
│   ├── spoke_vnet/             # Spoke VNet + subnets + peering + UDR
│   └── private_dns/            # Private DNS zones + VNet links
│
└── management/
    └── log_analytics/          # Log Analytics workspace + solutions + retention policy
```

> **Roadmap modules** *(in progress / planned)*:
> `governance/policy_set`, `governance/role_assignments`, `identity/workload_identity`,
> `connectivity/peering`, `connectivity/bastion`, `app_platform/aks_cluster`,
> `app_platform/app_gateway_waf_agic`, `app_platform/storage`, `monitoring/diagnostic_settings`, `monitoring/alerts`

------

## 🚀 Usage

### Reference locally during development

```hcl
module "log_analytics" {
  source = "../../terraform-common-modules/modules/management/log_analytics"

  workspace_name      = "law-platform-prod-001"
  resource_group_name = azurerm_resource_group.mgmt.name
  location            = var.location
  retention_days      = 90
  tags                = var.tags
}
```

### Reference via GitHub (pinned release)

```hcl
module "hub_vnet" {
  source = "github.com/devsocket/terraform-common-modules//modules/connectivity/hub_vnet?ref=v1.0.0"

  vnet_name           = "vnet-hub-prod-001"
  resource_group_name = azurerm_resource_group.connectivity.name
  location            = var.location
  address_space       = ["10.0.0.0/16"]
  subnets             = var.hub_subnets
  tags                = var.tags
}
```

------

## ⚙️ Requirements

| Dependency | Version |
|---|---|
| Terraform | `>= 1.6.0` |
| AzureRM provider | `>= 3.90.0, < 4.0.0` |
| AzureAD provider | `>= 2.0.0` |

-------

## 🔑 Key Architecture Decisions

**Private endpoints by default**  
All data-plane services (ACR, Key Vault) are provisioned with private endpoints enabled. Public network access is disabled by default. This is a deliberate tradeoff: slightly higher complexity at deployment time in exchange for a significantly reduced attack surface — critical for regulated workloads.

**Hub-spoke network topology**  
The `hub_vnet` and `spoke_vnet` modules are designed to work together via VNet peering. All spoke egress routes via the hub, enabling centralised firewall inspection and consistent network policy enforcement across workloads.

**Log Analytics as the observability backbone**  
The `log_analytics` module is designed to be deployed once per platform and referenced by all other modules via its workspace ID output. This avoids diagnostic log fragmentation across multiple workspaces and reduces cost through consolidated retention policies.

**Separation of naming from provisioning**  
Naming conventions are enforced via the `global/naming.tf` configuration in the Landing Zone repo, not inside individual modules. This keeps modules portable and naming strategy centralised.

-------

## 📦 Versioning Strategy

Modules are versioned via Git tags using semantic versioning:

```bash
git tag v1.0.0
git push origin v1.0.0
```

- **Patch** (`v1.0.x`): bug fixes, variable description updates
- **Minor** (`v1.x.0`): new optional variables, new output values
- **Major** (`vx.0.0`): breaking changes to input/output contracts

Always pin to a specific tag in production. Never reference `master` directly.

------

## 🔗 Related

- [terraform-landing-zone-demo](https://github.com/devsocket/terraform-landing-zone-demo) — Enterprise Azure Landing Zone consuming these modules
- [Microsoft Cloud Adoption Framework](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/) — Design principles this library aligns with
- [Azure Landing Zone Terraform Accelerator](https://github.com/Azure/alz-terraform-accelerator) — Microsoft's reference implementation

-------

## 👤 Author

**V Sudheer Kumar K** — Senior Technical Lead | Azure Solutions Architect (AZ-104, AZ-305)  
[GitHub](https://github.com/devsocket) | [LinkedIn](https://linkedin.com/in/sudheer44)
