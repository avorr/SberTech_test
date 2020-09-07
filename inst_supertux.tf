resource "aws_security_group" "Supertux" { 
    provisioner "remote-exec" {
    inline = [
      "git clone https://gitlab.com/s.vorr/supertux2 /srv/salt/base/",
      "salt 'Minion' state.sls supertux"
    ]
    connection {
      type        = "ssh"
      host        = var.ip_master
      user        = "root"
      private_key = file("/home/avorr/.ssh/id_rsa")
      timeout     = "3m"
    }
  }
  depends_on = [aws_instance.Master_d, aws_instance.Minion_d]
}