# this installation is for k8s v1.29 on ubuntu jammy
# Go to k8s documentation and fearch for installing kubeadm


# Install container runtime (CRI) first....CRI-O, containerd...etc. I choose containerd
# Install and configure prerequisites 

# Step-1: Forwarding IPv4 and letting iptables see bridged traffic

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter
# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
# Apply sysctl params without reboot
sudo sysctl --system

# Step-2: Verify that the br_netfilter, overlay modules are loaded by running the following commands

lsmod | grep br_netfilter
lsmod | grep overlay

# Step-3: Verify that the net.bridge.bridge-nf-call-iptables, net.bridge.bridge-nf-call-ip6tables, and net.ipv4.ip_forward system variables are set to 1

sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward

# Step-4: Install containerd

# A).  Set up Docker's apt repository
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# B). Install the latest version of containerd

sudo apt-get install containerd.io

# Step-5: If you experience container crash loops after the initial cluster installation or after installing a CNI do this (create default configuration)

#sudo mkdir -p /etc/containerd
sudo containerd config default | sed 's/SystemdCgroup = false/SystemdCgroup = true/' | sudo tee /etc/containerd/config.toml
# and restart containerd
sudo systemctl restart containerd

# Step-6: These instructions are for Kubernetes 1.29.
   # A). Update the apt package index and install packages needed to use the Kubernetes apt repository:
      sudo apt-get update
      # apt-transport-https may be a dummy package; if so, you can skip that package
      sudo apt-get install -y apt-transport-https ca-certificates curl gpg
   # B). Download the public signing key for the Kubernetes package repositories
      # If the folder `/etc/apt/keyrings` does not exist, it should be created before the curl command, read the note below.
      # sudo mkdir -p -m 755 /etc/apt/keyrings
      sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
   # C). Add the appropriate Kubernetes apt repository. Please note that this repository have packages only for Kubernetes 1.29.
      # This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
      sudo echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
   # D). Update the apt package index, install kubelet, kubeadm and kubectl, and pin their version
      sudo apt-get update
      sudo apt-get install -y kubelet kubeadm kubectl
      sudo apt-mark hold kubelet kubeadm kubectl

