# First run pre-flight checks
sudo kubeadm reset phase preflight

# If checks pass, perform full reset
sudo kubeadm reset -f

# Clean up additional resources
sudo rm -rf /etc/cni/net.d/*
sudo ipvsadm --clear

# Additional cleanup
sudo rm -rf $HOME/.kube
sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F && sudo iptables -X
sudo systemctl restart kubelet
