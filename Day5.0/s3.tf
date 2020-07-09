

/*
https://medium.com/@devopslearning/aws-iam-ec2-instance-role-using-terraform-fa2b21488536
*/
# AWS, S3 Bucket
resource "aws_s3_bucket" "App-S3-All" {
  bucket = "cloudgurus-s3-applications-all"
  acl    = "public-read-write"

  tags = {
    Name        = "App-S3-All"
    Environment = "Production"
  }
}

# Step 1
/*
Create a file s3.tf
Create an IAM role by copy-paste the content of a below-mentioned link
assume_role_policy — (Required) The policy that grants an entity permission to assume the role.
*/

resource "aws_iam_role" "EC2-To-S3-Access" {
  name = "EC2-To-S3-Access"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags = {
    Name = "EC2-To-S3-Access"
  }
}

# Step 2
/*
Create EC2 Instance Profile
*/
resource "aws_iam_instance_profile" "EC2_To_S3_Profile" {
  name       = "EC2_To_S3_Profile"
  role       = aws_iam_role.EC2-To-S3-Access.name
  depends_on = [aws_iam_role.EC2-To-S3-Access]
}

/*
Now if we execute the above code, we have Role and Instance Profile but with no permission.
Next step is to add IAM Policies which allows EC2 instance to execute specific commands for eg: access to S3 Bucket
*/

# Step 3
/*
Adding IAM Policies
To give full access to S3 Bucket
*/

resource "aws_iam_role_policy" "EC2_To_S3_Policy" {
  name       = "EC2_To_S3_Policy"
  role       = aws_iam_role.EC2-To-S3-Access.id
  depends_on = [aws_iam_role.EC2-To-S3-Access]

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# Step 4
/* Attach this role to EC2 instance
iam_instance_profile = aws_iam_instance_profile.EC2_To_S3_Profile.name
*/

/*
IAM Role - EC2-To-S3-Access
IAM Instance Profile - EC2_To_S3_Profile
IAM Role Policy - EC2_To_S3_Policy
*/

/*
AWS VPC Endpoint 
https://www.terraform.io/docs/providers/aws/r/vpc_endpoint.html
https://docs.aws.amazon.com/vpc/latest/userguide/endpoint-service.html
*/