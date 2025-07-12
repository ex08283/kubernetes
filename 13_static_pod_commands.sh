#This script demonstrates how to manage static pods in a Kubernetes cluster, particularly focusing on the kube-scheduler.
# It includes commands to disable the kube-scheduler, create a pod without it, and then re-enable the kube-scheduler.
# it als show manual scheduling of a pod to a specific node.

k get pod -n kube-system
# Get all pods in the kube-system namespace
k get pod -n kube-system -o wide
# Get all pods in the kube-system namespace with wide output
k get pod -n kube-system | grep sched
# Filter pods in the kube-system namespace for those related to scheduling

docker exec -it cka-cluster2-control-plane sh
# Enter the control plane container shell

ps -ef | grep kubelet
# List all processes related to kubelet in the control plane container

cd /etc/kubernetes/manifests
# Change directory to where kubelet manifests are stored

mv scheduler.yaml /tmp
# Move the scheduler manifest to /tmp to disable it

k run nginx-pod --image=nginx 
# Create a new pod named nginx-pod with the nginx image,  it will not be scheduled due to the missing kube-scheduler

k get pod -n kube-system | grep scheduler
# Check if the kube-scheduler pod is still running

mv /tmp/scheduler.yaml /etc/kubernetes/manifests
# Restore the scheduler manifest to re-enable scheduling

k run nginx --image=nginx -o yaml > 13_static_pods/pod.yaml  
# Create a new nginx pod manifest and save it to a file. 
# add nodename to the pod spec to ensure it runs on a specific node

k delete pod nginx
# Delete the nginx pod to ensure it is not running

docker exec -it cka-cluster2-control-plane bash
# Enter the control plane container shell again

cd /etc/kubernetes/manifests/  
# Change directory to the manifests folder again                                      

mv kube-scheduler.yaml /tmp
# Move the kube-scheduler manifest to /tmp to disable it

k apply -f 13_static_pods/pod.yaml
# Apply the nginx pod manifest to create the pod without the kube-scheduler, on specified node

k get pods -o wide
# List all pods with wide output to see the node assignment

mv /tmp/kube-scheduler.yaml /etc/kubernetes/manifests
# Restore the kube-scheduler manifest to re-enable scheduling

k get pods -n kube-system | grep kube-scheduler
# Check if the kube-scheduler pod is running again

#now we will apply new labels to the pod and create a new pod with different labels

k apply -f 13_static_pods/pod.yaml --force
# add labels to the existing pod by reapplying the manifest with --force

k get pods --showlabels
# List all pods with labels to see the applied labels

cd 13_static_pods/
touch pod2.yaml
k apply -f pod2.yaml
# Create a new pod with a different configuration

k get pods --selector tier=frontend
# List pods with the label tier=frontend
k get pods --selector tier=backend
# List pods with the label tier=backend
k edit pod nginx
# shows annotations and labels of the nginx pod for editing

