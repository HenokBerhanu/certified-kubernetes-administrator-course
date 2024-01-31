# {
# POD_CIDR=10.244.0.0/16
# SERVICE_CIDR=10.96.0.0/16

# kubeadm init --pod-network-cidr $POD_CIDR --service-cidr $SERVICE_CIDR --apiserver-advertise-address $INTERNAL_IP

# kubectl --kubeconfig /etc/kubernetes/admin.conf \
#     apply -f "https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s-1.11.yaml"

# }

# I use only this command on the master node
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.56.11

# The output of the following command looks like,

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.56.11:6443 --token 3p1v60.sw7xnadhibqd4wp3 \
	--discovery-token-ca-cert-hash sha256:5888f82686ee57b643fcf4e7cb6929681fba5f770efe6a749d0e2e7012ca8100

# Follow the above instruction (coppying the above three kube config commands on the master node) and after that before installing CNI, do this on the master node

# run this command to verify that the permission is 644 or above
stat -c %a /etc/kubernetes/admin.conf
# If not 644, run the followinf command,
chmod 644 /etc/kubernetes/admin.conf
# After that do this to swapoff 

sudo -i
swapoff -a
exit 
strace -eopenat kubectl version

# Now you can install CNI

# I choose calico for my cluster

# Install the Tigera Calico operator and custom resource definitions
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/tigera-operator.yaml >/dev/null
# Install Calico by creating the necessary custom resource
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/custom-resources.yaml >/dev/null
# Confirm that all of the pods are running with the following command
watch kubectl get pods -n calico-system
