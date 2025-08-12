###############################
# RUN install-kubnode.sh BEFORE
# 
# #!/bin/bash
# #############################

##################################################
# RUN THIS ON CONTROL PLANE TO INITIALIZE CLUSTER
######################3###########################
# Initialize the cluster for Cilium
sudo kubeadm init --pod-network-cidr=10.217.0.0/16

# Enable kubectl
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


# Install cilium CLI
# FROM: https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}

# Install Cilium
cilium install
# Check status
cilium status
kubectl get pods -o wide -n kube-system

# Install metrics server
# In order to avoid unsigned TLS certificates related issue
# use metrics-server.yaml to install metrics server
kubectl apply -f metrics-server.yaml
kubectl get pods -o wide -n kube-system

# Longhorn installation
# Add a second disk to all nodes in the cluster, keep it raw and unmounted
# e.g. nodename-longhorn.vdi

# Install longhornctl


kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.9.1/deploy/longhorn.yaml
