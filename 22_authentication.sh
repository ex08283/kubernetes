docker ps
# Check for control plane node container name

docker exec -it cka-cluster2-control-plane bash
# Access the control plane node container

cd /etc/kubernetes/pki
# Navigate to the Kubernetes PKI directory
# This directory contains the certificates and keys used by the Kubernetes control plane components.



cd etc/kubernetes/manifests
# Navigate to the Kubernetes manifests directory

cat kube-apiserver.yaml
# View the kube-apiserver manifest file to check for RBAC settings

