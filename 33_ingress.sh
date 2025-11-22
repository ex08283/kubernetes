ssh azureuser@172.167.212.95
# ssh into the master VM

cd ingress/Flask
# Navigate to the Flask application directory

sudo apt install docker.io -y
# Install Docker if not already installed

sudo systemctl start docker
# Start the Docker service

sudo usermod -aG docker azureuser
# Add the azureuser to the docker group to run docker without sudo

logout
# Logout to apply group changes

ssh azureuser@172.167.212.95

cd ingress/Flask
# Navigate back to the Flask application directory

docker build -t ex08283/cka-ingress:v1 .
# Build the Docker image and tag it

dcoker images
# Verify the image is built

docker login -u ex08283
# Login to Docker Hub

docker push ex08283/cka-ingress:v1
# Push the image to Docker Hub

cd /home/azureuser/ingress/k8s
# Navigate to the Kubernetes manifests directory

vim deployment.yaml
# Edit the deployment manifest to use the new image and add the image in the spec/containers section:
# image: ex08283/cka-ingress:v1
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-world
  labels:
    app: hello-world
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hello-world
  template:
    metadata:
      labels:
        app: hello-world  # Label attaached to the pod
    spec:
      containers:
      - name: hello-world
        image: ex08283/cka-ingress:v1
        ports:
        - containerPort: 80



k apply -f deployment.yaml
# Apply the deployment manifest to update the application

vim service.yaml
# Edit the service manifest to ensure it exposes the correct port (80) and type (Node
apiVersion: v1
kind: Service
metadata:
  name: hello-world
spec:
  selector:
    app: hello-world # Must match the label attached to the pod
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80

k apply -f service.yaml
# Apply the service manifest to update the service

k get svc
# Verify the service is running and note the NodePort assigned
NAME          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
hello-world   ClusterIP   10.104.174.70   <none>        80/TCP    30s
kubernetes    ClusterIP   10.96.0.1       <none>        443/TCP   2d1h

curl 10.104.174.70
# Test the service using the ClusterIP

#Right now, your app is accessible only inside the cluster. To access it from outside (browser), you must create: 
# a NodePort service

vim service.yaml
# Edit the service manifest to change the service type to NodePort

apiVersion: v1
kind: Service
metadata:
  name: hello-world   
spec:
  type: NodePort          # Change service type to NodePort
  selector:
    app: hello-world     # Must match the label attached to the pod
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
      nodePort: 30080     # Specify a NodePort within the valid range (300

k apply -f service.yaml
k get svc
# Apply the updated service manifest and verify the service

azureuser@k8s-lab-master:~/ingress/Flask/k8s$ k get pods -owide
NAME                           READY   STATUS    RESTARTS      AGE   IP                NODE              NOMINATED NODE   READINESS GATES
hello-world-6c6b455d57-9bnjp   1/1     Running   1 (40m ago)   27h   192.168.126.141   k8s-lab-worker2   <none>           <none>
# Hello-world pod is running on worker2


azureuser@k8s-lab-master:~/ingress/Flask/k8s$ k get nodes -owide
NAME              STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
k8s-lab-worker1   Ready    <none>          9d    v1.29.6   10.240.0.6    <none>        Ubuntu 22.04.5 LTS   6.8.0-1041-azure   containerd://1.7.14
k8s-lab-worker2   Ready    <none>          9d    v1.29.6   10.240.0.5    <none>        Ubuntu 22.04.5 LTS   6.8.0-1041-azure   containerd://1.7.14
master            Ready    control-plane   9d    v1.29.6   10.240.0.4    <none>        Ubuntu 22.04.5 LTS   6.8.0-1041-azure   containerd://1.7.14
# ip of worker2 is 10.240.0.5

azureuser@k8s-lab-master:~/ingress/Flask/k8s$ curl http://10.240.0.5:30080
Hello, World!
# Test the NodePort service using the worker2 node IP and NodePort

# we want to learn ingress next so we will delete the NodePort service and create a ClusterIP service again
# comment out the type and nodePort lines in service.yaml and apply again
k apply -f service.yaml
# This will revert the service back to ClusterIP type
azureuser@k8s-lab-master:~/ingress/Flask/k8s$ curl http://10.240.0.5:30080
curl: (7) Failed to connect to 10.240.0.5 port 30080 after 1 ms: Connection refused
# Test the NodePort service again, it should fail now


azureuser@k8s-lab-master:~/ingress/Flask/k8s$ cat ingress.yaml 
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: hello-world
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx # Ensure this matches your Ingress Controller's class name
  rules:
  - host: "example.com"   # You can set this to your desired domain or leave it out for default
    http:
      paths:
      - path: /  #
        pathType: Prefix # Match all paths
        backend:
          service:
            name: hello-world  # Name of the service to route traffic to
            port:
              number: 80

k apply -f ingress.yaml
# Apply the ingress manifest to create the ingress resource

k get ingress
NAME          CLASS   HOSTS         ADDRESS   PORTS   AGE
hello-world   nginx   example.com             80      43h
# the address is empty because the cloud controller manager is not present in this cluster
# In a managed Kubernetes service, this would typically be populated with the external IP of the load balancer

# go tot https://kubernetes.github.io/ingress-nginx/deploy/
# and follow the instructions to port-forward the ingress controller service to your local machine

#run the below
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.14.0/deploy/static/provider/cloud/deploy.yaml
# This deploys the NGINX Ingress Controller in your cluster

k logs ingress-nginx-controller-9fb5dddf7-hxz4g -n ingress-nginx
# Check the logs of the Ingress Controller to ensure it's processing the ingress resource correctly

k get pods -A | grep ingress-nginx
# Verify the Ingress Controller pods are running
# here -A lists all namespaces

k edit pod ingress-nginx-controller-9fb5dddf7-hxz4g -n ingress-nginx
# we can see the ingress class name here too, :q! to exit


k get svc -n ingress-nginx
NAME                                 TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx-controller             LoadBalancer   10.102.204.133   <pending>     80:30740/TCP,443:31974/TCP   11m
ingress-nginx-controller-admission   ClusterIP      10.98.99.95      <none>        443/TCP                      11m


k get svc -n ingress-nginx
NAME                                 TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx-controller             LoadBalancer   10.102.204.133   <pending>     80:30740/TCP,443:31974/TCP   11m
ingress-nginx-controller-admission   ClusterIP      10.98.99.95      <none>        443/TCP                      11m
# Get the services in the ingress-nginx namespace to find the ingress controller service
# we an see the ingress-nginx-controller service is of type LoadBalancer and the ip is pending

# We will edit the svc of the ingress-nginx-controller to type NodePort for testing purposes
k edit svc ingress-nginx-controller -n ingress-nginx
# Change type from LoadBalancer to NodePort and save
# then it will start working and assigned an external IP for ingress resource above
 k get svc -n ingress-nginx
NAME                                 TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx-controller             NodePort    10.102.204.133   <none>        80:30740/TCP,443:31974/TCP   19m
ingress-nginx-controller-admission   ClusterIP   10.98.99.95      <none>        443/TCP                      19m

k get ing
NAME          CLASS   HOSTS         ADDRESS          PORTS   AGE
hello-world   nginx   example.com   10.102.204.133   80      43h
# Check the ingress resource again to see if it has an address now
# We can see the address is now populated with the cluster IP of the ingress controller service

kubectl get nodes -o wide
# Get the internal IP of any node in the cluster
AME              STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
k8s-lab-worker1   Ready    <none>          11d   v1.29.6   10.240.0.6    <none>        Ubuntu 22.04.5 LTS   6.8.0-1041-azure   containerd://1.7.14
k8s-lab-worker2   Ready    <none>          11d   v1.29.6   10.240.0.5    <none>        Ubuntu 22.04.5 LTS   6.8.0-1041-azure   containerd://1.7.14
master            Ready    control-plane   11d   v1.29.6   10.240.0.4    <none>        Ubuntu 22.04.5 LTS   6.8.0-1041-azure   containerd://1.7.14

curl http://10.240.0.5:30740
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx</center>
</body>
</html>


# Test the ingress resource using the ingress controller's cluster IP
# This wil return a 404 because we have not mapped example.com to this IP yet
# because we have to resolve example.com to the ingress controller IP

azureuser@k8s-lab-master:~/ingress/Flask/k8s$ curl -H "Host: example.com" http://10.240.0.5:30150
Hello, World!
# NodePort of ingress-nginx-controller is 30150 here works, finally!
# By adding the Host header, we simulate a request to example.com, which the ingress resource is configured to handle
# here we are usign the private ip of worker2 where the ingress controller pod is running

# After adding to /etc/hosts on local machine, we can access via browser too
# Add the following line to your local machine's /etc/hosts file:
172.166.136.252 example.com

curl example.com:30150
Hello, World!

$ curl 172.166.136.252:30150
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx</center>
</body>
</html>




