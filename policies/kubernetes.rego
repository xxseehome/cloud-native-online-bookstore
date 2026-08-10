package main

is_deployment {
	input.kind == "Deployment"
}

has_immutable_application_image(container) {
	re_match(
		"^crpi-[a-z0-9-]+\\.cn-hangzhou\\.personal\\.cr\\.aliyuncs\\.com/online-bookstore/bookstore-(backend|frontend):[0-9a-f]{40}$",
		container.image,
	)
}

has_all_capability_drop(container) {
	some index
	container.securityContext.capabilities.drop[index] == "ALL"
}

has_resource_budget(container) {
	container.resources.requests.cpu
	container.resources.requests.memory
	container.resources.limits.cpu
	container.resources.limits.memory
}

has_runtime_default_seccomp {
	input.spec.template.spec.securityContext.seccompProfile.type == "RuntimeDefault"
}

deny[msg] {
	is_deployment
	container := input.spec.template.spec.containers[_]
	not has_immutable_application_image(container)
	msg := sprintf("%s/%s must use a full 40-character SHA image from the Hangzhou ACR repository", [input.metadata.namespace, input.metadata.name])
}

deny[msg] {
	is_deployment
	container := input.spec.template.spec.containers[_]
	endswith(container.image, ":latest")
	msg := sprintf("%s/%s must not use the latest image tag", [input.metadata.namespace, input.metadata.name])
}

deny[msg] {
	is_deployment
	container := input.spec.template.spec.containers[_]
	container.securityContext.allowPrivilegeEscalation != false
	msg := sprintf("%s/%s must disable privilege escalation", [input.metadata.namespace, input.metadata.name])
}

deny[msg] {
	is_deployment
	container := input.spec.template.spec.containers[_]
	container.securityContext.runAsNonRoot != true
	msg := sprintf("%s/%s must run as a non-root user", [input.metadata.namespace, input.metadata.name])
}

deny[msg] {
	is_deployment
	container := input.spec.template.spec.containers[_]
	not has_all_capability_drop(container)
	msg := sprintf("%s/%s must drop all Linux capabilities", [input.metadata.namespace, input.metadata.name])
}

deny[msg] {
	is_deployment
	container := input.spec.template.spec.containers[_]
	not has_resource_budget(container)
	msg := sprintf("%s/%s must define CPU and memory requests and limits", [input.metadata.namespace, input.metadata.name])
}

deny[msg] {
	is_deployment
	not has_runtime_default_seccomp
	msg := sprintf("%s/%s must use the RuntimeDefault seccomp profile", [input.metadata.namespace, input.metadata.name])
}

deny[msg] {
	input.kind == "Namespace"
	input.metadata.labels["app.kubernetes.io/part-of"] != "online-bookstore"
	msg := sprintf("namespace %s must identify the online-bookstore application", [input.metadata.name])
}

deny[msg] {
	input.kind == "Ingress"
	input.spec.ingressClassName != "traefik"
	msg := sprintf("ingress %s must use the managed Traefik ingress class", [input.metadata.name])
}
