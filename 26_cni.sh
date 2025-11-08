#Topic: Recreating a Kubernetes cluster with a new CNI plugin
#Purpose:
#We can't change the configuration of the existing cluster, so we need to recreate it. The default CNI (Container Network Interface) that comes with the cluster is not suitable for our use. Therefore, we delete the old cluster, create a new one, and install a new CNI plugin (Weave Net) to enable proper pod networking.

# Check all pods in the kube-system namespace and filter for those related to kind
k get pods -n kube-system | grep kind
# (Used to verify which kind-related pods are running)

# List all DaemonSets across all namespaces and filter for kind
k get ds -A | grep kind
# (Used to check for any kind-related DaemonSets running in the system)

# Delete the existing kind cluster named 'cka'
kind delete cluster --name cka
# (Removes the old cluster configuration completely)

# Create a new kind cluster using a custom configuration file named kind.yaml
kind create cluster --config kind.yaml --name cka-new
# (Recreates the cluster with updated settings suitable for CNI installation)

# Check node description to confirm that the CNI plugin has not yet been initialized
k describe node cka-new-control-plane | grep "CNI plugin not initialized"
# (Used to verify that networking setup is incomplete before installing a new CNI)

# Install the Weave Net CNI plugin by applying its DaemonSet manifest
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.31.0/manifests/calico.yaml

# Check DaemonSets in kube-system to ensure the Weave CNI was created
k get ds -n kube-system | grep calico
# (Verifies that the Weave DaemonSet is running correctly)

# Check all pods in kube-system and filter for weave-related components
k get pods -n kube-system | grep weave
# (Confirms that the Weave pods are up and running successfully)

# Apply any additional manifests needed for the cluster setup
k apply -f manifest.yaml
# pod/frontend created
# service/frontend created
# pod/backend created
# service/backend created
# service/db created
# pod/mysql created

k get svc
# (Lists all services to verify their creation and status)

k exec frontend it -- bash
# (Enters the frontend pod to test connectivity)

curl backend:80
# (Tests if the frontend pod can reach the backend service)

apt-get update && apt-get install telnet -y
# (Installs telnet in the frontend pod for further connectivity test the db service)

telnet db 3306
# (Tests connectivity from the frontend pod to the MySQL service on port 3306)
# we want to restrict the access to the db service only from the backend pod
# for this we will be creating network policies in the next section


k apply -f netpolicy.yaml
# networkpolicy.networking.k8s.io/db-policy created

k get netpol
# (Lists all network policies to verify their creation)

k exec frontend it -- bash
# (Enters the frontend pod again to test connectivity after applying network policies)

telnet db 3306
# (Tests connectivity from the frontend pod to the MySQL service on port 3306, which should now be blocked by the network policy)   

k exec backend it -- bash
# (Enters the backend pod to test connectivity to the db service)

telnet db 3306
# (Tests connectivity from the backend pod to the MySQL service on port 3306, which should be allowed by the network policy)








