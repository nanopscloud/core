######################
# REMOVE BEFORE FLIGHT
#  #!/bin/bash
######################

# Allocate minimum or 2 vCPU for installation, could downscale later
# Allocate 8G RAM for installation (minimum of 2G RAM, could be 4G for light workloads)
# 64 GB system disk
# Each node with additional 256 GB Longhorn raw disk
# Oracle Linux 10 as a base OS

# Enable cockpit http://<IP>:9090
sudo systemctl enable --now cockpit.socket

# Disable SELinux
# sudo nano /etc/selinux/config
# SELINUX=disabled
sudo grubby --update-kernel ALL --args selinux=0 
sudo reboot

# Disable firewall
sudo systemctl stop firewalld
sudo systemctl disable firewalld

# Tweak /etc/hosts when not having DNS
sudo nano /etc/hosts
# Add the kubernetes IP series manually on every host
192.168.88.80 kub0
192.168.88.81 kub1
192.168.88.82 kub2
192.168.88.83 kub3
192.168.88.84 kub4
192.168.88.85 kub5 
192.168.88.86 kub6
192.168.88.87 kub7
192.168.88.88 kub8
192.168.88.89 kub9

# Install nfs-utils
sudo dnf install nfs-utils

# Installing containerd
sudo dnf install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install containerd.io
sudo systemctl enable containerd
sudo systemctl start containerd
sudo systemctl status containerd

# Configure containerd
sudo mkdir -p /etc/containerd
sudo systemctl restart containerd
sudo systemctl status containerd
containerd config default | sudo tee /etc/containerd/config.toml

# Edit the config
sudo dnf install nano
sudo nano /etc/containerd/config.toml
# CHECK THAT plugins are not disabled - SHOULD BE: disabled_plugins = []
# SET SystemdCgroup = true UNDER [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
sudo systemctl restart containerd
sudo systemctl status containerd

# INSTALLING KUBERBETES
# Swap off
sudo swapoff -a
sudo sed -i.bak '/ swap / s/^/#/' /etc/fstab
sudo nano /etc/yum.repos.d/kubernetes.repo

# Add below to enable kubernetes repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.33/rpm/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.33/rpm/repodata/repomd.xml.key

sudo dnf install -y kubelet kubeadm kubectl
sudo sysctl -w net.ipv4.ip_forward=1
echo 'net.ipv4.ip_forward=1' | sudo tee /etc/sysctl.d/99-kubernetes-ip-forward.conf
sudo sysctl --system
sudo systemctl enable --now kubelet
sudo systemctl restart kubelet
sudo systemctl status kubelet

####################################################################################################
# RUN THIS ON CONTROL NODE TO GET A NEW JOIN COMMAND TO JOIN THE NODE TO CLUSTER
# sudo kubeadm token create --print-join-command
# - Take the command output (with a new certificate in it) and run with sudo + command on added node
####################################################################################################
sudo kubeadm token create --print-join-command
kubectl get nodes -o wide # Verify that the all nodes are 'Ready'