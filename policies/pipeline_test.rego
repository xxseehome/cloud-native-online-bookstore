package main

test_ci_workflow_has_required_security_jobs {
  ci_has_required_jobs with input as {
    "name": "Online Book Store CI",
    "jobs": {
      "gitleaks": {},
      "trivy": {},
      "opa": {},
      "code-quality": {}
    }
  }
}

test_ci_workflow_requires_all_gates_for_publication {
  ci_publish_is_gated with input as {
    "jobs": {
      "publish-images": {
        "needs": [
          "container-build",
          "gitleaks",
          "trivy",
          "opa",
          "code-quality",
          "kubernetes-manifest"
        ]
      }
    }
  }
}

test_kubernetes_workflow_requires_environment_approval {
  kubernetes_deploy_has_approval with input as {
    "jobs": {
      "approval": {"environment": "${{ inputs.environment }}"},
      "deploy": {"needs": "approval"}
    }
  }
}

test_ci_workflow_rejects_missing_gate {
  not ci_has_required_jobs with input as {
    "name": "Online Book Store CI",
    "jobs": {
      "gitleaks": {},
      "trivy": {},
      "opa": {}
    }
  }
}

test_kubernetes_workflow_rejects_missing_approval {
  not kubernetes_deploy_has_approval with input as {
    "jobs": {
      "approval": {"environment": "staging"},
      "deploy": {"needs": "build"}
    }
  }
}

test_resilience_workflow_requires_staging_approval {
  resilience_has_staging_approval with input as {
    "jobs": {
      "approval": {"environment": "staging"},
      "check": {"needs": "approval"}
    }
  }
}
