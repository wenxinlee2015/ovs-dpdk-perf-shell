#!/bin/bash
set -x

mkdir -p /root/rpms/
cd /root/rpms/
wget https://repo.fedoralinux.ir/pub/epel/7/x86_64/e/epel-release-7-9.noarch.rpm
rpm -ivh /root/rpms/epel-release-7-9.noarch.rpm
yum install -y vnstat

wget https://iperf.fr/download/fedora/iperf3-3.1.3-1.fc24.x86_64.rpm
rpm -ivh /root/iperf3*

yum install -y iproute
