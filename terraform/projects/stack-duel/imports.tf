import {
  to = module.stack_duel.github_repository.app
  id = "stack-duel"
}

import {
  to = module.stack_duel.neon_project.app
  id = "empty-smoke-33404791"
}

# The Vercel project, its domains, env vars, and the GitHub ruleset/secrets
# already exist too (built by hand this session) but aren't imported here —
# their exact resource IDs weren't captured along the way. Expect
# `terraform plan` to show these as conflicts on first run; import each
# (see the provider docs' Import section) or delete the manual copy before
# applying, one resource at a time.
