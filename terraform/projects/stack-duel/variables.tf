variable "vercel_api_token" {
  type      = string
  sensitive = true
}

variable "clerk_publishable_key" {
  type      = string
  default   = null
  sensitive = true
}

variable "clerk_secret_key" {
  type      = string
  default   = null
  sensitive = true
}

variable "clerk_webhook_signing_secret" {
  type      = string
  default   = null
  sensitive = true
}

variable "clerk_production_publishable_key" {
  type      = string
  default   = null
  sensitive = true
}

variable "clerk_production_secret_key" {
  type      = string
  default   = null
  sensitive = true
}

variable "clerk_production_webhook_signing_secret" {
  type      = string
  default   = null
  sensitive = true
}
