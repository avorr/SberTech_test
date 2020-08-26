#!/bin/bash

terraform apply -auto-approve \
	        -target=aws_instance.Minion_d \
