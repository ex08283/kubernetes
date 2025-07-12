k get namespaces
# List all namespaces

k get ns
# List all namespaces with short form

k get all --namespace=kube-system
# List all resources in the kube-system namespace

k get all -n kube-system
# List all resources in the kube-system namespace with short form

k get all -n kube-public
# List all resources in the kube-public namespace

k get all -n default
# List all resources in the default namespace

 k get all
# List all resources in the current namespace, the same as default namespace

k apply -f ns.yaml
# Create a namespace from the ns.yaml file

k delete ns demo
# Delete the demo namespace

k create deployment nginx-demo --image=nginx -n demo
k create deployment nginx-demo2 --image=nginx --namespace=demo
# Create a deployment named nginx in the demo namespace

k create deployment nginx-demo2 --image=nginx
# Create a deployment named nginx-demo2 in the default namespace

k get deployment -n demo
# List deployments in the demo namespace

k get delete deployment nginx-demo2 -n demo
# Delete the nginx-demo2 deployment in the demo namespace

k scale deployment nginx-demo --replicas=3 -n demo
# Scale the nginx-demo deployment to 3 replicas in the demo namespace

k expose deploy nginx-demo --name=svc-demo --port=80 -n demo
# Expose the nginx-demo deployment as a service named svc-demo on port 80 in the demo namespace

k exec -it  nginx-demo-<pod-id>  -- sh
# Execute a bash shell in the nginx-demo pod in the default namespace

cat /etc/resolv.conf
# Check the DNS configuration in the container

curl curl svc-demo.demo.svc.cluster.local
# Test the service by curling the service URL
# curl to the service "svc-demo" in the demo namespaces needs the service name, namespace, and cluster domain
# The default cluster domain is "svc.cluster.local"
