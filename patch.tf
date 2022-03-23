resource "kubernetes_job_v1" "aws_auth_patch" {
  count = var.patch ? 1 : 0

  metadata {
    name      = "aws-auth-patch"
    namespace = "kube-system"
    labels    = local.k8s_labels
  }

  spec {
    template {
      metadata {}
      spec {
        service_account_name = kubernetes_service_account_v1.aws_auth.metadata[0].name
        container {
          name    = "aws-auth-patch"
          image   = local.aws_auth_image
          command = ["/bin/sh", "-c", "kubectl patch configmap/aws-auth --patch \"${local.aws_auth_configmap_yaml}\" -n kube-system"]
        }
        restart_policy = "Never"
      }
    }
  }

  wait_for_completion = true

  timeouts {
    create = "10m"
    update = "10m"
  }
}
