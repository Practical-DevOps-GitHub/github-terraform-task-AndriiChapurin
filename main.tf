provider "github" {
  token        = "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"
  owner = "AndriiChapurin"
}

resource "github_actions_secret" "example_secret" {
  repository      = github_repository.example.name
  secret_name     = "PAT"
  plaintext_value = "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"
}


resource "github_repository" "example" {
  name       = "github-terraform-task-AndriiChapurin"
  auto_init  = true
}

resource "github_branch" "develop" {
  repository = github_repository.example.name
  branch     = "develop"
}

resource "github_branch_default" "default" {
  repository = github_repository.example.name
  branch     = github_branch.develop.branch
}

resource "github_branch_protection" "main" {
  repository_id  = github_repository.example.node_id
  pattern        = "main"
  enforce_admins = true

  required_status_checks {
    strict   = true
    contexts = ["ci/test"]
  }

required_pull_request_reviews {
    dismiss_stale_reviews          = true
    require_code_owner_reviews     = true
    dismissal_restrictions = ["users", "teams"]
  }
}

resource "github_branch_protection" "develop" {
  repository_id  = github_repository.example.node_id
  pattern        = "develop"
  enforce_admins = false

  required_status_checks {
    strict   = true
    contexts = ["ci/test"]
  }

  required_pull_request_reviews {
    dismiss_stale_reviews          = false
    require_code_owner_reviews     = true
    required_approving_review_count = 2
  }
}

resource "github_repository_collaborator" "collaborator" {
  repository = github_repository.example.name
  username   = "softservedata"
  permission = "push"
}

resource "github_repository_file" "codeowners" {
  repository = github_repository.example.name
  file       = "CODEOWNERS"
  content    = "* @softservedata"
  branch     = "main"
}
resource "github_repository_deploy_key" "deploy_key" {
  repository = github_repository.example.name
  key        = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD5Y7Y4SStWqRxgqP0qc5bfWsB3Cji5vRtQMT+ZQNkKfz8YBqZ9IID/9OHCegdGrHAwPVAPuA2jES5pWxQCnPhM7rhKFcguFfPB3ZXDRTDwrhrWY4XfD7Q7g0ObCq6JsxBmNlMwEWOWcTG33LVN8uS96MpC9y8DjP1cYyk6nom+g85XvdX34/YffGav+98AucXybFfrnldigDdyXzLLk8QMrAoREaMbyvlRADr/altWDJ1KdTM4f4JVsyV+ze7zJs8zOCPcEy1gfNB9hU5DmP9Fvpg/OiGozQwDXos0yZ+3dnBzgpdKDnW/njsOloZZIhn7Xtsti7ITbyzKACLWfsaJ Andrii@macs-MacBook-Pro.local"
  title      = "DEPLOY_KEY"
  read_only  = false
}

resource "github_repository_file" "pr_template" {
  repository = github_repository.example.name
  file       = ".github/pull_request_template.md"
  content    = <<-EOF
  # Describe your changes
  Issue ticket number and link
  Checklist before requesting a review
  - [ ] I have performed a self-review of my code
  - [ ] If it is a core feature, I have added thorough tests
  - [ ] Do we need to implement analytics?
  - [ ] Will this be part of a product update? If yes, please write one phrase about this update
  EOF

  branch     = "main"
}
