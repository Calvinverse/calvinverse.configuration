#!/bin/bash

# Wait for consul to start and connect. Once it has connected count the number
# of nomad clients in the environment and then configure the docker ipvlan settings
# Create the ipvlan network. Link to ETH0. Do this at provisioning time because we need to set the
# IP-address range to be 192.168.x.0/24 where x depends on the host
sudo docker network create -d ipvlan -subnet=192.168.100.0/24 -o parent=eth0 -o ipvlan_mode=l3 docker_ipvlan
