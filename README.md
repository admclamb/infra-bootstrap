# infra-bootstrap

Reusable Terraform for the GitHub/Vercel/Neon environment and CD setup built for stack-duel.

## Layout

```
terraform/
  modules/
    project-bootstrap/   Shared module: GitHub repo + ruleset + Actions
                          config, Vercel project wired for manual-promotion
                          blue-green deploys, Neon project with isolated
                          Production/Preview branches. One module, used by
                          every project below.
  projects/
    stack-duel/           This app. Calls the module with stack-duel's
                          values, plus its own provider config and secrets.
```

Each project directory is its own root Terraform config (own state, own provider setup) — adding a new app means adding a new directory under `projects/`, not a new environment tier. There's no dev/staging/prod split here; each project is a single environment with manual production promotion, matching how stack-duel itself is set up.

## What the module does NOT manage (do these manually, once per project)

1. **Clerk.** No mature Terraform provider exists for it. Run `clerk init` in the new project's repo — it creates a development instance and writes local env vars. Pass those dev-instance keys into the project's `clerk_publishable_key` / `clerk_secret_key` variables. When the app is ready to go live, create a Clerk **production** instance by hand (requires domain verification — you'll need to add a CNAME subdomain it gives you), then set the `clerk_production_*` variables and re-apply.
2. **Per-PR ephemeral Neon branches.** The module gives every PR a single shared `preview` branch — good enough for most projects, but not isolated-DB-per-PR. That behavior comes from installing Neon's **Vercel Marketplace integration** by hand (Vercel → Integrations → Neon → connect to the project, enable "create a branch per preview deployment", parent = `preview`). It's a UI-driven OAuth connection, not something Terraform can express.
3. **DNS records.** Whatever registrar the domain is on — Terraform can't manage that. Point the domain's A/CNAME records at what Vercel's dashboard shows after `apply` creates the domain resources.
4. **Neon branch expiration.** Not exposed by the Neon Terraform provider. If ephemeral preview branches pile up against your plan's branch limit, that's a manual per-branch (or Vercel integration) setting.
5. **Pipeline files.** `templates/workflows/*.yml` (working examples for `Build`, post-merge `E2E and Promote`, and pre-merge `Auth E2E (Preview)`, copied from stack-duel) and `templates/dependabot.yml` are plain copy-paste files, not something Terraform writes into the target repo. Copy them into the new repo's `.github/` (workflows into `.github/workflows/`, dependabot into `.github/dependabot.yml`) and adjust the app-specific steps (test commands, env vars) — they assume the secret names the module creates. The module only manages the *setting* that dependabot.yml depends on (`github_repository_dependabot_security_updates`, i.e. "Dependabot alerts are on"), not the file's content.

## Setup

Each project directory needs its own credentials, supplied via a `secret.tfvars` file (gitignored — never commit one; see that project's `variables.tf` for the full list) plus two environment variables for the providers that read from env: `NEON_API_KEY` and `GITHUB_TOKEN` (needs repo-admin scope).

### stack-duel

```bash
cd terraform/projects/stack-duel
terraform init
terraform plan -var-file="secret.tfvars"
terraform apply -var-file="secret.tfvars"
```

`stack-duel`'s GitHub repo and Neon project already exist (built by hand before this module existed) — `imports.tf` covers those two. The Vercel project, its domains/env vars, and the GitHub ruleset/secrets also already exist manually and are **not yet imported**; expect `terraform plan` to show conflicts on those until each is either imported (see the relevant resource's Import section in its provider docs) or removed from the manual setup first.

### Adding a new project

1. Copy `terraform/projects/stack-duel/` to `terraform/projects/<name>/`.
2. Update `main.tf`'s literal values (`project_name`, `production_domain`, etc.) — everything specific to this project stays hardcoded here, only secrets go through variables.
3. Drop `imports.tf` entirely — a new project has nothing to adopt.
4. `terraform apply` (creates the GitHub repo, Vercel project, Neon project).
5. Copy `templates/workflows/*.yml` into the new repo's `.github/workflows/`, and `templates/dependabot.yml` into `.github/dependabot.yml`.
6. Follow the Clerk / DNS / Neon-integration manual steps above.
