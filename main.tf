provider "aws" {
  profile = "oguz"
  region  = "eu-west-1"
}

#Ubuntu IMAGE
/*
resource "aws_instance" "jenkins" {
  ami             = var.ubuntuimage
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.jenkins-sg.name]
  key_name        = var.pemfile

  provisioner "remote-exec" {
    inline = [
      "wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -",
      "sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'",
      "sudo apt update -qq",
      "sudo apt install -y default-jre",
      "sudo apt install -y jenkins",
      "sudo systemctl start jenkins",
      "sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080",
      "sudo sh -c \"iptables-save > /etc/iptables.rules\"",
      "echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections",
      "echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections",
      "sudo apt-get -y install iptables-persistent",
      "sudo ufw allow 8080",
    ]
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("./oguz.pem")
  }


  
  tags = {

    "Name"      = "oguz-JenkinsCI"
    "Terraform" = "true",
    "Project Owner" = "SCM"    
  }
}
*/

resource "aws_instance" "jenkins" {
  ami             = var.awslinux
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.jenkins-sg.name]
  key_name        = var.pemfile

  provisioner "remote-exec" {
    inline = [
        "sudo yum update -y",
        "sudo yum install java-1.8.0-openjdk-devel -y",
        "sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo",
        "sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key",
        "sudo yum install jenkins -y",
        "sudo systemctl start jenkins",
        "sudo systemctl enable jenkins",
        "sudo systemctl status jenkins",
        "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
        "echo Install EKSCTL"
        "curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp",
        "sudo mv /tmp/eksctl /usr/local/bin"
        "echo Install KUBECTL",
        "curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.18.9/2020-11-02/bin/linux/amd64/kubectl",
        "chmod +x ./kubectl"
        "mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin",
        "kubectl version --short --client",
        "Install awsIamAuthenticator",
        "curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.18.9/2020-11-02/bin/linux/amd64/aws-iam-authenticator",
        "chmod +x ./aws-iam-authenticator",
        "mkdir -p $HOME/bin && cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$PATH:$HOME/bin",
        "echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc"

    ]
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file("./oguz.pem")
  }


  
  tags = {

    "Name"      = "oguz-JenkinsCI"
    "Terraform" = "true",
    "Project Owner" = "SCM"    
  }
}


#Create new SG
resource "aws_security_group" "jenkins-sg" {
  name        = "Jenkins SG"
  description = "Jenkins SG"

  dynamic "ingress" {
    iterator = port
    for_each = var.ingressrules
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Terraform" = "true"
  }
}
