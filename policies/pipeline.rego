package main

is_ci_workflow {
  input.name == "Online Book Store CI"
}

is_kubernetes_deploy_workflow {
  input.name == "Kubernetes Deploy"
}

is_resilience_workflow {
  input.name == "Kubernetes Resilience Check"
}

has_need(job, dependency) {
  input.jobs[job].needs[_] == dependency
}

has_need(job, dependency) {
  input.jobs[job].needs == dependency
}

ci_has_required_jobs {
  input.jobs.gitleaks
  input.jobs.trivy
  input.jobs.opa
  input.jobs["code-quality"]
}

ci_publish_is_gated {
  has_need("publish-images", "gitleaks")
  has_need("publish-images", "trivy")
  has_need("publish-images", "opa")
  has_need("publish-images", "code-quality")
  has_need("publish-images", "kubernetes-manifest")
}

kubernetes_deploy_has_approval {
  input.jobs.approval.environment == "${{ inputs.environment }}"
  has_need("deploy", "approval")
}

kubernetes_deploy_requires_image_tag {
  input.on.workflow_dispatch.inputs.image_tag.required == true
}

resilience_has_staging_approval {
  input.jobs.approval.environment == "staging"
  has_need("check", "approval")
}

resilience_requires_image_sha {
  input.on.workflow_dispatch.inputs.expected_image_sha.required == true
}

deny[msg] {
  is_ci_workflow
  not ci_has_required_jobs
  msg := "CI must include Gitleaks, Trivy, OPA, and Ruff code-quality jobs"
}

deny[msg] {
  is_ci_workflow
  not ci_publish_is_gated
  msg := "image publication must depend on manifest, code-quality, Gitleaks, Trivy, and OPA gates"
}

deny[msg] {
  is_kubernetes_deploy_workflow
  not kubernetes_deploy_requires_image_tag
  msg := "Kubernetes deployment must require an immutable image_tag input"
}

deny[msg] {
  is_kubernetes_deploy_workflow
  not kubernetes_deploy_has_approval
  msg := "Kubernetes deployment must pass through the target environment approval job"
}

deny[msg] {
  is_resilience_workflow
  not resilience_requires_image_sha
  msg := "resilience check must require the expected image SHA"
}

deny[msg] {
  is_resilience_workflow
  not resilience_has_staging_approval
  msg := "resilience check must be fixed to the staging approval environment"
}
