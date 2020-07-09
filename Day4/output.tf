

# Bastion Hosts IPs
# Public and Private IPs of Bastion Hosts, PublicSub-BastionHosts1
output "Bastion_Host_Public_IP_PublicSub-BastionHosts1_BastionHost-Dev-Primary" {
  value = aws_instance.Bastion-Hosts[0].public_ip
}
output "Bastion_Host_Private_IP_PublicSub-BastionHosts1_BastionHost-Dev-Primary" {
  value = aws_instance.Bastion-Hosts[0].private_ip
}

# Public IPs of Bastion Hosts, PublicSub-BastionHost2
output "Bastion_Host_Public_IP_PublicSub-BastionHosts2_BastionHost-Pro-Primary" {
  value = aws_instance.Bastion-Hosts[1].public_ip
}
output "Bastion_Host_Private_IP_PublicSub-BastionHosts2_BastionHost-Pro-Primary" {
  value = aws_instance.Bastion-Hosts[1].private_ip
}

# WebServers' Private IPs
# Private IPs of WebServers, PrivateSub-WebServers1
output "WebServer_Private_IP_PrivateSub-WebServers1" {
  value = aws_instance.WebServers[0].private_ip
}

# Private IPs of WebServers, PrivateSub-WebServers2
output "WebServer_Private_IP_PrivateSub-WebServers2" {
  value = aws_instance.WebServers[1].private_ip
}

# AppServers' Private IPs 
# Private IPs of AppServers, PrivateSub-AppServers1
output "AppServer_Private_IP_PrivateSub-AppServers1" {
  value = aws_instance.AppServers[0].private_ip
}

# Private IPs of AppServers, PrivateSub-AppServers2
output "AppServer_Private_IP_PrivateSub-AppServers2" {
  value = aws_instance.AppServers[1].private_ip
}

# DBServers' Private IPs 
# Private IPs of DBServers, PrivateSub-DBServers1
output "DBServer_Private_IP_PrivateSub-DBServers1" {
  value = aws_instance.DBServers[0].private_ip
}

# Private IPs of DBServers, PrivateSub-DBServers2
output "DBServer_Private_IP_PrivateSub-DBServers2" {
  value = aws_instance.DBServers[1].private_ip
}

