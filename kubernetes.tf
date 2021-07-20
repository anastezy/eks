resource "helm_release" "nginx-ingress" {
  name               = "nginx-ingress-controller"
  repository         = "https://charts.bitnami.com/bitnami"
  chart              = "nginx-ingress-controller"
  namespace          = "ingress-nginx"
  create_namespace   = true

  set {
    name  = "service.annotations"
    value = "service.beta.kubernetes.io/aws-load-balancer-type : nlb"
  }
}

resource "helm_release" "nginx" {
  name       = "nginx"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx"
  namespace          = "test-nginx"
  create_namespace   = true
//  values = [
//    file("${path.module}/values.yaml")
//  ]
  set {
    name  = "replicaCount"
    value = 2
  }
  set {
    name  = "ingress.enabled"
    value = "true"
  }
  set {
    name  = "ingress.hostname"
    value = "test.host.com"
  }
  set {
    name  = "service.type"
    value = "ClusterIP"
  }
}