output "app_gateway_id" {
  description = "Resource ID of the app gateway. pass to AKS module as app_gateway_id for AGIC addon"
  value = azurerm_application_gateway.this.id
}

output "app_gateway_name" {
  description = "Name of the application gateway. Useful for tagging consistency and reference in documentation."
  value = azurerm_application_gateway.this.name
}

output "resource_group_name" {
  description = "Name of the resource group to which the app gateway belongs."
  value = azurerm_resource_group.this.name
}

output "resouce_group_id" {
  description = "Resource ID of the App Gateway resource group. Used for AGIC contributor role assignment scope"
  value = azurerm_resouce_group.this.id
}

# Public IP
output "public_ip_address" {
    description = "Public IP address of the Gateway frontend. point DNS record here"
    value = azurerm_public_ip.this.ip_address
}
output "public_ip_id" {
    description = "Resource ID of the public IP"
    value = azurerm_public_ip.this.id
}

# WAF Policy
output "waf_policy_id" {
  description = "Resource ID of the WAF policy. Used for reference in documentation and AGIC configuration"
    value = azurerm_web_application_firewall_policy.this.id
}

output "waf_policy_name" {
    description = "Name of the WAF policy. Useful for tagging consistency and reference in documentation."
    value = azurerm_web_application_firewall_policy.this.name
}