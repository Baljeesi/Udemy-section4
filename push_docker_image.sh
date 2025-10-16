#!/bin/bash
sudo docker build -t ci-cd-deployment .
#create a docker hub account before pushing image to docker hub
#make sure you did docker login with docker command "sudo docker login"
sudo docker tag ci-cd-deployment baljeesi/ci-cd-deployment
sudo docker push baljeesi/ci-cd-deployment
