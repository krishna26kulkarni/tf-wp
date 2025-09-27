resource "aws_iam_role" "prometheus_irsa" {
  for_each = var.regions
  provider = aws.${each.key}
  name = "${var.environment}-${each.value}-prometheus-irsa"
  assume_role_policy = data.aws_iam_policy_document.irsa_assume[each.key].json
  tags = { Environment = var.environment }
}

data "aws_iam_policy_document" "irsa_assume" {
  for_each = var.regions
  statement {
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
    condition {
      test = "StringEquals"
      values = ["system:serviceaccount:monitoring:prometheus-k8s"]
      variable = "kubernetes.io/serviceaccount/arn"
    }
  }
}

resource "aws_iam_role_policy_attachment" "prom_attach" {
  for_each = var.regions
  provider = aws.${each.key}
  role = aws_iam_role.prometheus_irsa[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy" # example
}
