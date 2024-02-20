#################################################################################################################
sudo kubeadm init --apiserver-advertise-address=192.168.56.102 --pod-network-cidr=10.244.0.0/16
#################################################################################################################

#########################################################################
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
##################################################################

#####################################################################################################
# Install Flannel CNI, the pod network cidr shall be 10.244.0.0/16
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
#####################################################################################################

#####################################################################################################################################
# install Calico pod network addon the pod network cidr shall be 192.168.0.0/24
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/tigera-operator.yaml 
#####################################################################################################################################
##############################################################################################################################################
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/custom-resources.yaml
#####################################################################################################################################



#################################                                                                        ############################
#################################Below are the diagnosis commands that i use when the kubectl shows error############################
#################################                                                                        ############################

sudo systemctl restart kubelet
sudo systemctl restart kubelet.service
sudo systemctl status kubelet
sudo systemctl status kubelet.service


##################################################
# kubelet requires swap off
sudo -i
swapoff -a
exit
##############################################

##########################################################
# keep swap off after reboot
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
###################################################


###############################################################
export KUBECONFIG=/etc/kubernetes/admin.conf
##################################################################

##################################################################
sudo stat -c %a /etc/kubernetes/admin.conf
##################################################################

################################################
sudo chmod 644 /etc/kubernetes/admin.conf
################################################

#######################How do you know if your k8s cluster has Roll-Based Access Control (RBAC)?#############################
kubectl api-versions ## or 
kubectl api-versions | grep rbac.authorization.k8s.io/v1
###########################################################################################################