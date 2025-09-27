output "kubeconfig_paths" {
  value = {
    for r, m in module.eks : r => module.eks[r].kubeconfig_filename
  }
  description = "Paths to generated kubeconfig files per region"
}
