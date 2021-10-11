resource "aws_key_pair" "ssh-key_master" {
  key_name   = "ssh-key_master"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "Master_d" {
  ami = "ami-0bcc094591f354be2"
#  ami = "ami-0758470213bdd23b1" 
  key_name = aws_key_pair.ssh-key_master.id
  instance_type = "t3.small"
  vpc_security_group_ids = [aws_security_group.Master_d.id]
  tags = {
    Name = "Master"
    Owner = "Vorobyev_Alexander"
    Project = "Supertux2"
  }
  
  provisioner "remote-exec" {
    inline = [
      "sudo cp ~/.ssh/authorized_keys /root/.ssh/."
    ]
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      timeout     = "3m"
    }
  }  

  provisioner "remote-exec" {
    inline = [
      "apt-get update",
      "export PATH=$PATH:/usr/bin",
      "wget https://bootstrap.pypa.io/get-pip.py",
      "apt-get update",
      "apt install python3-pip -y",
      "pip3 install salt",
      "mkdir /etc/salt",
      "mkdir /etc/salt/master.d /etc/salt/minion.d",
      "echo 'file_roots:' >> /etc/salt/master.d/roots.conf",
      "echo '  base:' >> /etc/salt/master.d/roots.conf",
      "echo '    - /srv/salt/base' >> /etc/salt/master.d/roots.conf",
      "mkdir -p /srv/salt/base",
      "echo 'master: localhost' > /etc/salt/minion.d/master.conf",
      "echo 'Master-Minion' > /etc/salt/minion_id",
      "salt-master -d",
      "salt-minion -d",
      "mkdir MASTER"
    ]
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "root"
      private_key = file("~/.ssh/id_rsa")
      timeout     = "3m"
    }
  }  
}

resource "aws_security_group" "Master_d" {
  name = "Security Group for SaltMaster"
  description = "Security_group_SaltMaster"
  ingress {
    from_port = 4505
    to_port = 4506
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "ip_Master_d_private" {
  value = aws_instance.Master_d.private_ip  
}

output "ip_Master_d_public" {
  value = aws_instance.Master_d.public_ip  
}
