# Use phusion/baseimage (https://github.com/phusion/baseimage-docker) as base image so that
# we have a proper Unix init system (see http://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/)
FROM ubuntu:16.04
LABEL maintainer "Petrik van der Velde (@petrikvdvelde)"

RUN mkdir -p /etc/consul/conf.d
COPY consul_client_location.json /etc/consul/conf.d
COPY consul_client_secrets.json /etc/consul/conf.d
