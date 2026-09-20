provider "vercel" {
  api_token = var.vercel_api_token
}

provider "neon" {}

provider "github" {
  owner = "admclamb"
}
