

## Instructions
I have included reference Sites and Notes between codes (Resource Blocks etc) for your references. Hope these will help you to understand what I have done 
and clear-out the doubts. 

## How to configure Credentials for AWS
  * Static credentials declared in provider section of code

      provider "aws" { 

      region     = "YOUR-AWS-REGION"

      access_key = "YOUR-ACCESS-KEY"

      secret_key = "YOUR-SECRET-KEY"

      }

  * Export as environment variables

      export AWS_ACCESS_KEY="access_key"

      export AWS_SECTRET_KEY="secret_access_key"

      export AWS_DEFAULT_REGION="your_aws_region"

  * Shared credentials (~/.aws/credentials) - Use "aws configure"

  * EC2 Role (such as Jenkins build server or any EC2 Instance used for resource provisioning)

## Tasks - Day 1
* VPC - 1 (Two Availability Zones)
* Subnets - 8 (Across within two Availability Zones (4 each))
* Internet Gateway

## Tasks - Day 2
* Route Tables - Public (Associate Public Subnets & IGW)
                 Private (Associate Private Subnets)
* Security Groups
  SG1 - Bastion Hosts - Opening SSH
  SG2 - Web Servers - Http , SSH (Opened for Bastion Host SG)
  SG3 - Application Servers - Http (Opened for Web Servers SG , SSH (Opened for Bastion Hosts SG)

## Tasks - Day 3
* 2 Bastion Hosts - Public IP, Security Group - Bastion-Hosts-SG
* 2 Web Servers, Security Group - Web-Servers-SG
* 2 Application Servers, Security Group - App-Servers-SG

## Tasks - Day 4
* NAT Gateways for Private Subnets (WebServers, AppServers, DBServers), Route Table - PrivateRT

## Tasks - Day 5.0
* S3 - Bucket - Allow Web Servers, App Servers and DB Servers access to S3 Bucket using Roles
* Load Balancer for Web Servers (External), Without Autoscaling Group
* Load Balancer for App Servers (Internal), Without Autoscaling Group

## Tasks - Day 5.1
* Classic Load Balancer for Web Servers (External), With Autoscaling Group

## Tasks - Day 5.2
* Application Load Balancer for Web Servers (External), With Autoscaling Group and Target Group
  Single Target Group and Single Listener
  
  - ALB can't be used with Autoscaling Group without using Target Groups.
  - ELB can be used with Autoscaling without Target Group.
 
* Using Launch Templates instead of Launch Configurations

## Tasks - Day 5.3
* Application Load Balancer for 2x Web Server Groups (External), With Autoscaling Groups and Target Groups
  Two Target Groups and Two Listeners (Using diffrent Ports for Listners and Target Groups having same Port)
* Create a Seperate Security Group for ALB, It was using the same Secuirty Group as Web Servers
* VPC Endpoint to Access S3 Bucket via AWS PrivateLink for Private Subnets