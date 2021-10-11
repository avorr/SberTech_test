resource "aws_key_pair" "ssh-key_minion" {
  key_name   = "ssh-key_minion"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "Minion_d" {
  ami = "ami-0bcc094591f354be2"
  key_name = aws_key_pair.ssh-key_minion.id
  instance_type = "t3.small"
  vpc_security_group_ids = [aws_security_group.Minion_d.id]
  tags = {
    Name = "Minion"
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

  provisioner "file" {
    source      = "out/ip_private.txt"
    destination = "~/ip.txt"
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "root"
      private_key = file("~/.ssh/id_rsa")
      timeout     = "3m"
    }
  }
   
  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      "apt-get update",
      "wget https://bootstrap.pypa.io/get-pip.py",
      "apt-get update",
      "apt install python3-pip -y",
      "pip3 install salt",
      "mkdir /etc/salt",
      "mkdir -p /etc/salt/minion.d",
      "echo 'Minion' > /etc/salt/minion_id",
      "echo \"master: $(cat ~/ip.txt)\" > /etc/salt/minion.d/master.conf",
      "salt-minion -d",
      "sleep 10",
      "mkdir MINION"
    ]
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "root"
      private_key = file("~/.ssh/id_rsa")
      timeout     = "3m"
    }
  }

  provisioner "remote-exec" {
    inline = [
    "salt-key",
    "sleep 10",
    "salt-key -A -y"
    ]
    connection {
      type        = "ssh"
      host        = var.ip_master
      user        = "root"
      private_key = file("~/.ssh/id_rsa")
      timeout     = "3m"
    }
  }
  depends_on = [aws_instance.Master_d] 
}


resource "aws_security_group" "Minion_d" {
  name = "Security Group for SaltMinion"
  description = "Security_group_SaltMinion"

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
  depends_on = [aws_instance.Master_d]
}

output "ip_Minion_d_private" {
  value = aws_instance.Minion_d.private_ip    
}
output "ip_Minion_d_public" {
  value = aws_instance.Minion_d.public_ip    
}
