#!/bin/bash
terraform apply -auto-approve \
        -target=aws_instance.Master_d \

mkdir -p out
: >out/ip_private.txt
: >out/ip_public.txt
echo $(terraform output ip_Master_d_private) >> out/ip_private.txt
echo $(terraform output ip_Master_d_public) >> out/ip_public.txt

: >out/variables.tf
echo 'variable "ip_master" {' > variables.tf  
echo '  type = string' >> variables.tf
echo "  default = $(cat out/ip_public.txt)" >> variables.tf 
echo '}' >> variables.tf 

terraform apply -auto-approve \
        -target=aws_instance.Minion_d
./key_add.py $(terraform output ip_Master_d_public) $(terraform output ip_Minion_d_public) $(realpath $HOME/.ssh/id_rsa)

terraform apply -auto-approve \
        -target=aws_security_group.Supertux
