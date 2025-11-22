# In this file we will probvide a step-by-step guide to upgrade a multi node Kubernetes cluster with kubeadm.
# This script assumes you have already backed up your cluster and have access to all nodes.
# Always upgrade one minor version at a time (e.g., 1.29 → 1.30 → 1.31).

#determine which version to upgrade to
sudo apt update
sudo apt-cache madison kubeadm
   kubeadm | 1.29.15-1.1 | https://pkgs.k8s.io/core:/stable:/v1.29/deb  Packages
   kubeadm | 1.29.14-1.1 | https://pkgs.k8s.io/core:/stable:/v1.29/deb  Packages
   kubeadm | 1.29.13-1.1 | https://pkgs.k8s.io/core:/stable:/v1.29/deb  Packages
   kubeadm | 1.29.12-1.1 | https://pkgs.k8s.io/core:/stable:/v1.29/deb  Packages
   kubeadm | 1.29.11-1.1 | https://pkgs.k8s.io/core:/stable:/v1.29/deb  Packages
   kubeadm | 1.29.10-1.1 | https://pkgs.k8s.io/core:/stable:/v1.29/deb  Packages
   kubeadm | 1.29.9-1.1 | https://pkgs.k8s.io/core:/stable:/v1.29/deb  Packages
   kubeadm | 1.29.8-1.1 | https://pkgs.k8s.io/core:/stable:/v1.29/deb  Packages
   kubeadm | 1.29.7-1.1 | https://pkgs.k8s.io/core:/stable:/v1.29/deb  Packages
   kubeadm | 1.29.6-1.1 | https://pkgs.k8s.io/core:/stable:/v1.29/deb  Packages
   kubeadm | 1.29.5-1.1 | https://pkgs.k8s.io/core:/stable:/v1.29/deb  Packages
   kubeadm | 1.29.4-2.1 | https://pkgs.k8s.io/core:/stable:/v1.29/deb  Packages
   kubeadm | 1.29.3-1.1 | https://pkgs.k8s.io/core:/stable:/v1.29/deb  Packages
   kubeadm | 1.29.2-1.1 | https://pkgs.k8s.io/core:/stable:/v1.29/deb  Packages
   kubeadm | 1.29.1-1.1 | https://pkgs.k8s.io/core:/stable:/v1.29/deb  Packages
   kubeadm | 1.29.0-1.1 | https://pkgs.k8s.io/core:/stable:/v1.29/deb  Packages
# this will list all available versions of kubeadm

# current versions
kubeadm version   # check kubeadm version on control plane node
kubelet --version # check kubelet version on all nodes
kubectl get nodes -o wide # check kubectl version on all nodes
# we are on version 1.29.6 for all three components

# verifying if the kubernetes package repositoy is used
cat /etc/apt/sources.list.d/kubernetes.list
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /
# We can see we are using the v1.29 repository

#Change the version in the URL to the next available minor release, for example: v1.30
sudo vim /etc/apt/sources.list.d/kubernetes.list

sudo apt update
sudo apt-cache madison kubeadm
   kubeadm | 1.30.14-1.1 | https://pkgs.k8s.io/core:/stable:/v1.30/deb  Packages
   kubeadm | 1.30.13-1.1 | https://pkgs.k8s.io/core:/stable:/v1.30/deb  Packages
   kubeadm | 1.30.12-1.1 | https://pkgs.k8s.io/core:/stable:/v1.30/deb  Packages
   kubeadm | 1.30.11-1.1 | https://pkgs.k8s.io/core:/stable:/v1.30/deb  Packages
   kubeadm | 1.30.10-1.1 | https://pkgs.k8s.io/core:/stable:/v1.30/deb  Packages
   kubeadm | 1.30.9-1.1 | https://pkgs.k8s.io/core:/stable:/v1.30/deb  Packages
   kubeadm | 1.30.8-1.1 | https://pkgs.k8s.io/core:/stable:/v1.30/deb  Packages
   kubeadm | 1.30.7-1.1 | https://pkgs.k8s.io/core:/stable:/v1.30/deb  Packages
   kubeadm | 1.30.6-1.1 | https://pkgs.k8s.io/core:/stable:/v1.30/deb  Packages
   kubeadm | 1.30.5-1.1 | https://pkgs.k8s.io/core:/stable:/v1.30/deb  Packages
   kubeadm | 1.30.4-1.1 | https://pkgs.k8s.io/core:/stable:/v1.30/deb  Packages
   kubeadm | 1.30.3-1.1 | https://pkgs.k8s.io/core:/stable:/v1.30/deb  Packages
   kubeadm | 1.30.2-1.1 | https://pkgs.k8s.io/core:/stable:/v1.30/deb  Packages
   kubeadm | 1.30.1-1.1 | https://pkgs.k8s.io/core:/stable:/v1.30/deb  Packages
   kubeadm | 1.30.0-1.1 | https://pkgs.k8s.io/core:/stable:/v1.30/deb  Packages
# this will list all available versions of kubeadm for the new minor version

# now upgrade kubeadm to the desired version, top of the list above, e.g., 1.30.0
sudo apt-mark unhold kubeadm && sudo apt install -y kubeadm=1.30.14-1.1 && sudo apt-mark hold kubeadm

#verify the kubeadm version
kubeadm version
kubeadm version: &version.Info{Major:"1", Minor:"30", GitVersion:"v1.30.14", GitCommit:"9e18483918821121abdf9aa82bc14d66df5d68cd", GitTreeState:"clean", BuildDate:"2025-06-17T18:34:53Z", GoVersion:"go1.23.10", Compiler:"gc", Platform:"linux/amd64"}

# verify the upgrade plan
sudo kubeadm upgrade plan
[preflight] Running pre-flight checks.
[upgrade/config] Reading configuration from the cluster...
[upgrade/config] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
[upgrade] Running cluster health checks
[upgrade] Fetching available versions to upgrade to
[upgrade/versions] Cluster version: 1.29.15
[upgrade/versions] kubeadm version: v1.30.14
I1122 16:27:46.413160   12852 version.go:256] remote version is much newer: v1.34.2; falling back to: stable-1.30
[upgrade/versions] Target version: v1.30.14
[upgrade/versions] Latest version in the v1.29 series: v1.29.15

Components that must be upgraded manually after you have upgraded the control plane with 'kubeadm upgrade apply':
COMPONENT   NODE              CURRENT   TARGET
kubelet     k8s-lab-worker1   v1.29.6   v1.30.14
kubelet     k8s-lab-worker2   v1.29.6   v1.30.14
kubelet     master            v1.29.6   v1.30.14

Upgrade to the latest stable version:

COMPONENT                 NODE      CURRENT    TARGET
kube-apiserver            master    v1.29.15   v1.30.14
kube-controller-manager   master    v1.29.15   v1.30.14
kube-scheduler            master    v1.29.15   v1.30.14
kube-proxy                          1.29.15    v1.30.14
CoreDNS                             v1.11.1    v1.11.3
etcd                      master    3.5.12-0   3.5.15-0

You can now apply the upgrade by executing the following command:

kubeadm upgrade apply v1.30.14
# If the plan looks good, proceed with the upgrade
sudo kubeadm upgrade apply v1.30.14

[upgrade/successful] SUCCESS! Your cluster was upgraded to "v1.30.14". Enjoy!

#before upgrading kubelet and kubectl we have to drain the node, --ignore-daemonsets is required to avoid evicting daemonset pods. Becaus we have calico installed as a daemonset, we need this flag to avoid network disruption.
kubectl drain master --ignore-daemonsets
node/master cordoned
Warning: ignoring DaemonSet-managed Pods: calico-system/calico-node-5qmjd, calico-system/csi-node-driver-dbb7q, kube-system/kube-proxy-l47p5
evicting pod tigera-operator/tigera-operator-76c4974c85-g8rd6
evicting pod calico-apiserver/calico-apiserver-74d89b46c7-7bm8r
evicting pod calico-apiserver/calico-apiserver-74d89b46c7-mv6mn
evicting pod calico-system/calico-kube-controllers-58fb8cbddc-d578l
evicting pod calico-system/calico-typha-8f6587b45-cmr8n
pod/tigera-operator-76c4974c85-g8rd6 evicted
pod/calico-apiserver-74d89b46c7-7bm8r evicted
pod/calico-kube-controllers-58fb8cbddc-d578l evicted
pod/calico-apiserver-74d89b46c7-mv6mn evicted
pod/calico-typha-8f6587b45-cmr8n evicted
node/master drained

k get nodes
NAME              STATUS                     ROLES           AGE   VERSION
k8s-lab-worker1   Ready                      <none>          13d   v1.29.6
k8s-lab-worker2   Ready                      <none>          13d   v1.29.6
master            Ready,SchedulingDisabled   control-plane   13d   v1.29.6
# We can see that the master node is drained

# now upgrade kubelet and kubectl on the control plane node
# replace x in 1.34.x-* with the latest patch version
sudo apt-mark unhold kubelet kubectl && \
sudo apt-get update && sudo apt-get install -y kubelet='1.30.14-1.1' kubectl='1.30.14-1.1*' && \
sudo apt-mark hold kubelet kubectl

systemctl status kubelet
# Verify kubelet is running properly

#restart kubelet to pick up the new 
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# current versions
kubeadm version   # check kubeadm version on control plane node
kubelet --version # check kubelet version on all nodes
kubectl get nodes -o wide # check kubectl version on all nodes
kubeadm version: &version.Info{Major:"1", Minor:"30", GitVersion:"v1.30.14", GitCommit:"9e18483918821121abdf9aa82bc14d66df5d68cd", GitTreeState:"clean", BuildDate:"2025-06-17T18:34:53Z", GoVersion:"go1.23.10", Compiler:"gc", Platform:"linux/amd64"}
Kubernetes v1.30.14
NAME              STATUS                     ROLES           AGE   VERSION    INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
k8s-lab-worker1   Ready                      <none>          13d   v1.29.6    10.240.0.6    <none>        Ubuntu 22.04.5 LTS   6.8.0-1041-azure   containerd://1.7.14
k8s-lab-worker2   Ready                      <none>          13d   v1.29.6    10.240.0.5    <none>        Ubuntu 22.04.5 LTS   6.8.0-1041-azure   containerd://1.7.14
master            Ready,SchedulingDisabled   control-plane   13d   v1.30.14   10.240.0.4    <none>        Ubuntu 22.04.5 LTS   6.8.0-1041-azure   containerd://1.7.14

# We can see master has been upgraded to 1.30.14, worker nodes are still on 1.29.6

# next uncordon the master node
kubectl uncordon master

# Next we have to upgrade each worker node one at a time

# first we get the ip of the worker node
az vm list -g k8s-lab-rg -d -o table
Name             ResourceGroup    PowerState    PublicIps        Fqdns    Location    Zones
---------------  ---------------  ------------  ---------------  -------  ----------  -------
k8s-lab-master   k8s-lab-rg       VM running    172.167.212.95            uksouth  
k8s-lab-worker1  k8s-lab-rg       VM running    172.167.124.93            uksouth  
k8s-lab-worker2  k8s-lab-rg       VM running    172.166.136.252           uksouth  


# First we ssh into the worker node
ssh azureuser@172.167.124.93

# check package repository
dudo vim /etc/apt/sources.list.d/kubernetes.list

# now we upgrade kubeadm on the worker node as previously
# by installing the desired version first
sudo apt-mark unhold kubeadm && sudo apt-get update && sudo apt-get install -y kubeadm=1.30.14-1.1 && sudo apt-mark hold kubeadm

# then we run the upgrade now from the worker node
sudo kubeadm upgrade node

# next we drain the worker node
kubectl drain k8s-lab-worker1 --ignore-daemonsets

# then we upgrade kubelet and kubectl on the worker node
sudo apt-mark unhold kubelet kubectl && \
sudo apt-get update && sudo apt-get install -y kubelet='1.30.14-1.1' kubectl='1.30.14-1.1' && \
sudo apt-mark hold kubelet kubectl

# restart kubelet   
sudo systemctl daemon-reload
sudo systemctl restart kubelet  

# next we uncordon the worker node
    kubectl uncordon k8s-lab-worker1

# check node versions
kubectl get nodes -o wide

#next run everything from line 166 on worker node 2

#final check of all versions
azureuser@k8s-lab-master:~$ kubeadm version   # check kubeadm version on control plane node
kubelet --version # check kubelet version on all nodes
kubectl get nodes -o wide # check kubectl version on all nodes
kubeadm version: &version.Info{Major:"1", Minor:"30", GitVersion:"v1.30.14", GitCommit:"9e18483918821121abdf9aa82bc14d66df5d68cd", GitTreeState:"clean", BuildDate:"2025-06-17T18:34:53Z", GoVersion:"go1.23.10", Compiler:"gc", Platform:"linux/amd64"}
Kubernetes v1.30.14
NAME              STATUS                     ROLES           AGE   VERSION    INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
k8s-lab-worker1   Ready                      <none>          13d   v1.30.14   10.240.0.6    <none>        Ubuntu 22.04.5 LTS   6.8.0-1041-azure   containerd://1.7.14
k8s-lab-worker2   Ready,SchedulingDisabled   <none>          13d   v1.30.14   10.240.0.5    <none>        Ubuntu 22.04.5 LTS   6.8.0-1041-azure   containerd://1.7.14
master            Ready                      control-plane   13d   v1.30.14   10.240.0.4    <none>        Ubuntu 22.04.5 LTS   6.8.0-1041-azure   containerd://1.7.14
