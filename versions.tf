terraform {
  required_version = ">= 1.9"

  required_providers {
    vercel = {
      source  = "vercel/vercel"
      version = "~> 3.0"
    }
    neon = {
      source  = "kislerdm/neon"
      version = "~> 0.7"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "vercel" {
  api_token = var.vercel_api_token
  team      = var.vercel_team_id
}

provider "neon" {}

provider "github" {
  owner = var.github_owner
}
