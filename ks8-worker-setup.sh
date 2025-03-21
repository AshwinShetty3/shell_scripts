#!/bin/bash

# Exit on any error
set -e

echo "[STEP 1] System Updates and Prerequisites"
apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common

echo "[STEP 2] Install containerd"
apt-get install -y containerd
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
systemctl restart containerd

echo "[STEP 3] Configure System Settings"
cat <<EOF > /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system

echo "[STEP 4] Install Kubernetes Components"
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

echo "Worker node setup completed!"
echo "Now copy and run the join command from the master node"