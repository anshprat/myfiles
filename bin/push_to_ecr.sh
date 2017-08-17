#!/bin/bash
sudo aws ecr get-login --no-include-email --region ap-southeast-1 
sudo docker push ${@}