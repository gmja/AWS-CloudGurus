

provider "aws" {
  region  = var.aws_region
    version = "~>2.60"
  # version = ">=2.60"
  # version = "<=2.60"
  # version = ">=2.50,<=2.70"
}
