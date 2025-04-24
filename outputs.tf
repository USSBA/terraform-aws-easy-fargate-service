output "task_definition" {
  value = aws_ecs_task_definition.fargate
}
output "service" {
  value = aws_ecs_service.fargate
}
output "task_role" {
  value = aws_iam_role.ecs_task
}
output "task_execution_role" {
  value = aws_iam_role.ecs_execution
}
output "alb_dns" {
  value = aws_lb.alb.dns_name
}
output "alb" {
  value = aws_lb.alb
}
output "security_group_id" {
  value = aws_security_group.fargate.id
}
