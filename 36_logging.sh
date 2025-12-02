# this is notebook file for logging on k8s cluster
# we will cover logging in kubernetes cluster

k apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
# first we will deploy metrics server in the cluster to collect resource usage data

k get pods -n kube-system
NAME                              READY   STATUS    RESTARTS         AGE
coredns-55cb58b774-6q4qx          1/1     Running   10 (6m50s ago)   7d4h
coredns-55cb58b774-82f6q          1/1     Running   3 (6m25s ago)    7d4h
etcd-master                       1/1     Running   1 (6m50s ago)    3d7h
kube-apiserver-master             1/1     Running   6 (6m50s ago)    7d5h
kube-controller-manager-master    1/1     Running   5 (6m50s ago)    7d5h
kube-proxy-czp8v                  1/1     Running   3 (5m40s ago)    7d5h
kube-proxy-gdmhh                  1/1     Running   3 (6m25s ago)    7d5h
kube-proxy-l47p5                  1/1     Running   1 (6m50s ago)    7d5h
kube-scheduler-master             1/1     Running   5 (6m50s ago)    7d5h
metrics-server-7bb66479db-lbnsh   0/1     Running   0                15s
# we can see the metrics server pod is not ready yet, we will wait for a while and check again

k describe pod metrics-server-7bb66479db-lbnsh -n kube-system
Warning  Unhealthy  7s (x6 over 57s)  kubelet            Readiness probe failed: HTTP probe failed with statuscode: 500
# we can see error 500 in the readiness probe, this is because the metrics server is not able to communicate with the kube-apiserver due to missing flags
# we will fix this by adding the necessary flags to the kube-apiserver manifest file


k logs -n kube-system metrics-server-7bb66479db-lbnsh
# we keep seeing certificate errors in the logs, we will fix this by adding the necessary flags to the kube-apiserver manifest file
E1129 21:51:47.687124       1 scraper.go:149] "Failed to scrape node" err="Get \"https://10.240.0.6:10250/metrics/resource\": tls: failed to verify certificate: x509: cannot validate certificate for 10.240.0.6 because it doesn't contain any IP SANs" node="k8s-lab-worker1"

# we will edit deployment for the metric server
k edit deployment metrics-server -n kube-system
# we will add the following args to the metrics-server container
      - --kubelet-insecure-tls

k get deploy -n kube-system
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
coredns          2/2     2            2           21d
metrics-server   1/1     1            1           8m17s
# now we can see the metrics-server deployment is updated and the pod is running

k get pods -n kube-system
metrics-server-86d5cc455c-nn7zj   1/1     Running   0              66s
# we can see 1/1 containers are running in the metrics-server pod

# now we can check the resource usage of the nodes and pods
k top nodes

# how do we do troubeleshooting when docker is not available
# from kubernetes v1.24 the default container runtime is containerd and docker is deprecated
# we can use crictl to troubleshoot the containerd runtime
# so we do not use docker ps but use crictl ps to list the running containers
sudo crictl ps
CONTAINER           IMAGE               CREATED             STATE               NAME                        ATTEMPT             POD ID              POD
98a95542c4806       0f80feca743f4       19 minutes ago      Running             csi-node-driver-registrar   11                  83ade7af02249       csi-node-driver-dbb7q
2e5c0bbd1503d       1a094aeaf1521       19 minutes ago      Running             calico-csi                  11                  83ade7af02249       csi-node-driver-dbb7q
975641b70e3e6       6c07591fd1cfa       19 minutes ago      Running             calico-apiserver            4                   f9626c420b09a       calico-apiserver-74d89b46c7-xfh8d 
5494004b94a59       c69fa2e9cbf5f       20 minutes ago      Running             coredns                     10                  bd28ad773e279       coredns-55cb58b774-6q4qx
57fe0c557b222       4e42b6f329bc1       20 minutes ago      Running             calico-node                 1                   b25ddff4a5e89       calico-node-5qmjd
1592f8a1be298       709bcab73020c       20 minutes ago      Running             kube-proxy                  1                   26ca46b147445       kube-proxy-l47p5
f85ab84674236       2e96e5913fc06       20 minutes ago      Running             etcd                        1                   6ee6ac65f4e76       etcd-master
db2fab5254d4c       097a9f9514c71       20 minutes ago      Running             kube-controller-manager     5                   f05eacfd6ed4d       kube-controller-manager-master    
539921af94750       c1f0d1cc8af40       20 minutes ago      Running             kube-scheduler              5                   539f48dbe533a       kube-scheduler-master
46e4a682e1e30       07d562355feda       20 minutes ago      Running             kube-apiserver              6                   1ebb56d5cc7a7       kube-apiserver-master

sudo crictl ps -a
# we can use crictl ps -a to list all containers including stopped ones

# lets say you're api server not responding, you can check the logs using crictl logs command
# lets do this my moving the api server yaml file temporarily
sudo mv /etc/kubernetes/manifests/kube-apiserver.yaml /tmp/

# you will not be able to use kubectl commands now as the api server is down
k get pods -n kube-system

The connection to the server 10.240.0.4:6443 was refused - did you specify the right host or port?
# we can see the kube-apiserver pod is not running
sudo crictl ps | grep kube-apiserver
# we will get empty output as the kube-apiserver container is not running

sudo mv /tmp/kube-apiserver.yaml /etc/kubernetes/manifests/
# move the kube-apiserver manifest file back to its original location

 sudo crictl ps | grep kube-apiserver
727c15d29ea7f       07d562355feda       18 seconds ago      Running             kube-apiserver              0                   8c3b764329f49       kube-apiserver-master

# You will be in a situation where it is not able to pull an image from a registy
# in such cases you can try an manual pull using crictl
sudo crictl pull nginx
Image is up to date for nginx
# if the image pull is successful then you know its not a network issue

crictl pods
# we can use crictl pods to list all the pods running in the node

crictl images
# we can use crictl images to list all the images present in the node

# we can also get the logs of a container using crictl logs command, you will need the id of the container using ps command
sudo crictl logs 727c15d29ea7f

# you can create a pod config using a json file and create a pod using crictl runp command
# create a pod.json file with the following content
{  "metadata": {
    "name": "nginx-container",
    "namespace": "default",
    "attempt": 1
    "uid": "12345678-1234-1234-1234-123456789012"
  },
  "log_directory": "/tmp",
  "linux": {}
}

sudo crictl runp pod.json
# this will create a pod sandbox

# you can create a container inside the pod sandbox using crictl create command
crictl pull busybox

# create configs for the pod and container
{  "metadata": {
    "name": "nginx-container",
    "namespace": "default",
    "attempt": 1
    "uid": "12345678-1234-1234-1234-123456789012"
  },
  "log_directory": "/tmp",
  "linux": {}
}

# this will return a pod id
POD_ID=$(sudo crictl runp pod.json)

# create container config
{  "metadata": {
    "name": "busybox-container",
    "attempt": 1
  },
  "image": {
    "image": "busybox"
  },
  "command": [
    "top"
],
  "linux": {}
}

# then you can create the container inside the pod
CONTAINER_ID=$(sudo crictl create $POD_ID container.json pod.json)


