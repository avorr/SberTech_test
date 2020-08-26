#!/bin/bash
git pull
terraform apply -auto-approve \
	        -target=aws_instance.Master_d \
