output "instance_ips" {
  value = { for k , v in aws_instance.k8s_nodes : k => v.public_ip}
}

output "instance_ids" {
  value = { for k , v in aws_instance.k8s_nodes : k => v.id}
}