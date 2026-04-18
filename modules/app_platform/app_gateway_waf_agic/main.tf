resource "azurerm_resource_group" "this" {
  location = var.location
  name     = var.resource_group_name
  tags     = var.tags
}

# Public IP
# App Gateway WAF_v2 requires Standard SKU public IP
# Basic SKU public IP is not supported with v2 gateways
# Static allocation required — Dynamic is not supported with Standard SKU

resource "azurerm_public_ip" "this" {
  name                = var.public_ip
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = []

  tags = var.tags
}

# WAF Policy
# Standalone WAF policy resource — attached to gateway via firewall_policy_id
# Separation allows the policy to be updated independently of the gateway

resource "azurerm_web_application_firewall_policy" "this" {
  name                = var.waf_policy_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  tags                = var.tags

  policy_settings {
    enabled                     = true
    mode                        = var.waf_policy_mode
    request_body_check          = true
    file_upload_limit_in_mb     = 10
    max_request_body_size_in_kb = 128
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = var.waf_rule_set_version
    }
  }
}

# Application Gateway
# Minimal configuration — AGIC manages listeners, rules and backend pools
# Required blocks: gateway_ip_configuration, frontend_port, frontend_ip_configuration,
# backend_address_pool, backend_http_settings, http_listener, request_routing_rule
# These are skeleton values — AGIC overwrites them after AKS connects to the gateway

resource "azurerm_application_gateway" "this" {
  name                = var.app_gateway_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  # Link WAF policy to the gateway
  firewall_policy_id = azurerm_web_application_firewall_policy.this.id

  sku {
    name     = var.sku_name
    tier     = var.sku_tier
    capacity = var.capacity
  }

  # Gateway IP configuration block with reference to the subnet in the spoke VNet
  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = var.subnet_id
  }

  # Frongend IP configuration block with reference to the public IP resource
  # Port 80 skeletal value, AGIC creates listeners on demand when Ingress resources are created in the cluster
  frontend_ip_configuration {
    name                 = "appgw-frontend-ip"
    public_ip_address_id = azurerm_public_ip.this.id
  }

  frontend_port {
    name = "appgw-frontend-port"
    port = 80
  }
  backend_address_pool {
    name = "appgw-backend-pool"
  }

  backend_http_settings {
    name                  = "appgw-backend-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
  }

  # Skeleton HTTP listener, AGIC creates listeners on demand based on Ingress resources in the cluster
  http_listener {
    name                           = "appgw-http-listener"
    frontend_ip_configuration_name = "appgw-frontend-ip"
    frontend_port_name             = "appgw-frontend-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "appgw-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "appgw-http-listener"
    backend_address_pool_name  = "appgw-backend-pool"
    backend_http_settings_name = "appgw-backend-http-settings"
    priority                   = 100
  }
  ssl_policy {
      policy_type = "Predefined"
      policy_name = "AppGwSslPolicy20220101"
  }

  # Lifecycle ignore — AGIC continuously modifies listeners, rules and pools
  # Without this, every terraform plan would show changes made by AGIC
  # as Terraform drift and try to revert them
  lifecycle {
    ignore_changes = [
      frontend_ip_configuration,
      frontend_port,
      backend_address_pool,
      backend_http_settings,
      http_listener,
      request_routing_rule,
      probe,
      ssl_certificate,
      tags
    ]
  }

  tags = var.tags

}

# Diagnostic settings for Application Gateway
# Send logs to Log Analytics workspace for monitoring and alerting

resource "azurerm_monitor_diagnostic_setting" "this" {
  name                       = "diag-${var.app_gateway_name}"
  target_resource_id         = azurerm_application_gateway.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "ApplicationGatewayAccessLog"
  }

  enabled_log {
    category = "ApplicationGatewayPerformanceLog"
  }

  enabled_log {
    category = "ApplicationGatewayFirewallLog"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}