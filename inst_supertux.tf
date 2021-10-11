resource "aws_security_group" "Supertux" { 
    provisioner "remote-exec" {
    inline = [
      "git clone git@github.com:avorr/supertux-deploy.git /srv/salt/base/",
      "salt 'Minion' state.sls supertux"
    ]
    connection {
      type        = "ssh"
      host        = var.ip_master
      user        = "root"
      private_key = file("~/.ssh/id_rsa")
      timeout     = "3m"
    }
  }
  depends_on = [aws_instance.Master_d, aws_instance.Minion_d]
}
