# First thing to check is for CoreDNS to work is calico is installed and running properly

k apply -f manifests.yaml
# apply the manifests to create the Pods and Services

k exec -it nginx -- curl -s nginx1
# Error from server (BadRequest): pod nginx does not have a host assigned 
# execute a curl command from the nginx Pod to access the nginx1 Service

k get deployments.apps -n=kube-system
# verify that CoreDNS deployment is created in the kube-system namespace

k scale deployment coredns -n=kube-system --replicas=2
# scale the CoreDNS deployment to have 2 replicas

k get pods -n=kube-system 
# verify that there are now 2 CoreDNS pods running

k exec -it nginx -- curl -s nginx1
# execute a curl command from the nginx Pod to access the nginx1 Service again

k get svc -n=kube-system
# list all services in the kube-system namespace to see the CoreDNS service details
# kube-dns is service with respect to CoreDNS
# ClusterIP is the internal IP address of the CoreDNS service within the cluster
# When execed into a pod, this IP is used by the pod to query DNS records
# cat /etc/resolv.conf inside any pod to see the DNS configuration
# cat /etc/hosts inside any pod to see the static hostname to IP mappings

k get pods -n=kube-system | grep coredns
# get the list of CoreDNS pods in the kube-system namespace

k describe pod <coredns-pod-name> -n=kube-system
# will show moutnts section where ConfigMap is mounted as a volume
# check the name of the ConfigMap used by CoreDNS

k get configmap coredns -n=kube-system -o yaml
# get the CoreDNS ConfigMap in yaml format to see its configuration details
k describe configmap coredns -n=kube-system
# describe the CoreDNS ConfigMap to see its details
# this is an important file when it comes to coredns configuration
# You can modify this ConfigMap to change DNS behavior in the cluster
# After modifying the ConfigMap, you need to restart the CoreDNS pods for changes to take effect
# You can delete the CoreDNS pods, and the deployment will recreate them automatically


k get ds -n=calico-system
# get the DaemonSet details for calico-node in calico-system namespace

k describe ds calico-node -n=calico-system
# describe the calico-node DaemonSet to see its details