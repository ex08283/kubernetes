# get the labels of the pods so it can be used in the seletor of the service
kubectl.exe get pod --show-labels

#create a service of type NodePort
# This will create a service named nginx-svc that selects pods with the label env=demo
kubectl.exe create -f nodeport.yaml

# get the services
kubectl.exe get svc

# describe the service
# This will show the details of the service, including the selector, ports, and endpoints
kubectl.exe describe service nginx-svc

# check if the service is accessible
# This will access the service on port 30001 on localhost on kind cluster
# If you are using a different cluster, replace localhost with the IP of the control plane node
curl localhost:30001

#get the ip of the control plane node
kubectl.exe get nodes -o wide


# A ClusterIP service in Kubernetes is the default type of service that exposes a set of Pods 
# to other services within the cluster. It is not accessible from outside the cluster.
# This will create a service named clusterip-svc that selects pods with the label env=demo
# Endpoints are the IP addresses of the Pods that are selected by the service.
kubectl.exe apply -f clusterip.yaml


# lb.yaml is a LoadBalancer service
# This will create a service named lb-svc that selects pods with the label env=demo
# A LoadBalancer service in Kubernetes is used to expose a set of Pods to external traffic
kubectl.exe apply -f lb.yaml

# A random port will be assigned to the service
# This will show the details of the service, including the selector, ports, and endpoints
kubectl.exe get svc --field-selector spec.type=LoadBalancer

# To delete the service, use the following command
k delete svc lb-svc

# Creating the load balancer service imperatively
# This will create a service named lb-svc that selects pods with the label env=demo
# Lets the deployment figure out the selector automatically
kubectl.exe expose deployment nginx-deploy --type=LoadBalancer --name=lb-svc --port=80

# To get the YAML of the service
k get service lb-svc -o yaml > lb-svc.yaml