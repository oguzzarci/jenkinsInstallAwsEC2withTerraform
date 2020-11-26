#SG
variable "ingressrules" {
  type        = list(number)
  default     = [80, 443, 22, 8080]
  description = "Jenkins ingress port"
}

variable "pemfile" {
    type         = string
    default      = "oguz"
    description  = "EC2 pem file"
}

variable "ubuntuimage" {
  type = string
  default = "ami-0dc8d444ee2a42d8a"
  description = "Amazon Ubuntu Server 18.04 LTS (64-bit x86)"
}

variable "awslinux" {
  type = string
  default = "ami-014ce76919b528bff"
  description = "Amazon Linux 2 AMI (64-bit x86)"
}