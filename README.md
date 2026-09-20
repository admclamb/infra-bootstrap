# infra-bootstrap

Reusable Terraform module that reproduces the environment/CD setup built for stack-duel: a GitHub repo with a hardened branch ruleset and Actions config, a Vercel project wired for manual-promotion blue-green deploys, and a Neon Postgres project with isolated Production/Preview branches.

## What this manages

- **GitHub**: repository, branch ruleset on `main` (PR required, status checks required, no bypass — including for the repo owner), Actions restricted to GitHub-owned actions with SHA-pinning enforced, Dependabot enabled, a `Production` environment with required-reviewer approval, CODEOWNERS.
- **Vercel**: project connected to the GitHub repo, `auto_assign_custom_domains` disabled (deployments build but don't go live until promoted), Vercel Authentication on Standard Protection, a protection-bypass secret for CI, the production domain + www redirect, and `DATABASE_URL`/`DATABASE_URL_UNPOOLED` wired per environment.
- **Neon**: one project, `main` branch (Production) plus a persistent `preview` branch shared across PR previews.

## What this does NOT manage (do these manually, once per new project)

1. **Clerk.** No mature Terraform provider exists for it. Run `clerk init` in the new project's repo — it creates a development instance and writes local env vars. Pass those dev-instance keys into `clerk_publishable_key` / `clerk_secret_key` here. When the app is ready to go live, create a Clerk **production** instance by hand (requires domain verification — you'll need to add a CNAME subdomain it gives you), then set `clerk_production_*` variables and re-apply.
2. **Per-PR ephemeral Neon branches.** This module gives every PR a single shared `preview` branch — good enough for most projects, but not the isolated-DB-per-PR behavior stack-duel eventually got. That specific behavior comes from installing Neon's **Vercel Marketplace integration** by hand (Vercel → Integrations → Neon → connect to this project, enable "create a branch per preview deployment", parent = `preview`). It's a UI-driven OAuth connection, not something Terraform can express.
3. **DNS records.** Whatever registrar the domain is on (this module assumes you already own `production_domain`) — Terraform can't manage Squarespace DNS. Point the domain's A/CNAME records at what Vercel's dashboard shows after `terraform apply` creates the domain resources.
4. **Neon branch expiration.** Not exposed by the Neon Terraform provider. If ephemeral preview branches start piling up against your plan's branch limit, that's a manual per-branch (or Vercel integration) setting, not something this module sets.
5. **Workflow files.** `templates/workflows/*.yml` are working examples (copied from stack-duel) for `Build`, post-merge `E2E and Promote`, and pre-merge `Auth E2E (Preview)` — copy them into the new repo's `.github/workflows/` and adjust the app-specific steps (test commands, env vars). They assume the secret names this module creates.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars

export TF_VAR_vercel_api_token="..."   # Vercel account token — never put this in a file
export NEON_API_KEY="..."
export GITHUB_TOKEN="..."              # needs repo-admin scope

terraform init
terraform plan
terraform apply
```

After apply:
1. Copy `templates/workflows/*.yml` into the new repo's `.github/workflows/`.
2. Add the `templates/workflows` secret names required beyond what this module already creates — check each workflow's `env:` blocks.
3. Add the required status check names (`Build`, `Vercel`) to the ruleset once they've each run at least once on a real PR — GitHub only lets you select a check after it's appeared.
4. Run `clerk init` and follow the Clerk section above.
5. Point DNS at Vercel for `production_domain`.
6. Install the Neon Vercel Marketplace integration if per-PR DB isolation matters for this project.

## Adopting an existing repo/project instead of creating new ones

If the GitHub repo, Vercel project, or Neon project already exist (as with stack-duel), `terraform import` each resource before running `apply`, rather than letting Terraform try to create duplicates. See each resource's `Import` section in its provider docs.
