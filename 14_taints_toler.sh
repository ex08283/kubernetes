#Scheduling Pods with Taints and Tolerations in Kubernetes
# This script demonstrates how to use taints and tolerations in Kubernetes to control pod scheduling.
# taints are applied to nodes to prevent pods from being scheduled on them unless the pods have matching tolerations.
# tolerations are applied to pods to allow them to be scheduled on nodes with specific taints.
# further scheduling control can be achieved using node selectors.
# by applying labels to nodes and using node selectors in pods, you can control which nodes a pod can be scheduled on.
# if the pod has the required node selector, but not the required tolerations, it will not be scheduled on the tainted node.
#  if the pod has the required tolerations but not the required node selector, it will still be scheduled on the tainted node.
# both the tolerations and node selectors must be satisfied for the pod to be scheduled on a tainted node.

##summary
# Toleration alone (no node selector): Pod can schedule on matching tainted nodes OR untainted nodes
# Toleration + wrong node selector: Pod is blocked from that node (fails node selector check)
# Toleration + correct node selector: Pod MUST go to that specific node

k get nodes
# kubectl get pods --all-namespaces -o wide

k taint nodes cka-cluster2-worker gpu=true:NoSchedule
# tainting the node to prevent scheduling of pods 
# that do not tolerate this taint with key 'gpu' and effect 'NoSchedule'

k taint node cka-cluster2-worker2 gpu=true:NoSchedule
# tainting another node with the same taint


k describe node cka-cluster2-worker | grep -i taint
# checking the taints on the node
# now all nodes are tainted


k run nginx --image=nginx
# creating a pod without any tolerations
k get pods
# checking the status of the pod
k describe pod nginx
# describing the pod to see if it was scheduled or not, it should be in pending state because all nodes are tainted



k run redis --image=redis --dry-run=client -o yaml > 14_taints_tols/redis.yaml
# creating a pod with tolerations
k apply -f 14_taints_tols/redis.yaml
# applying the pod with tolerations

k get pods -o wide
# checking the status of the pod with tolerations, node it is scheduled on
# it should be in running state because it has tolerations for the taint on the nodes

k taint node cka-cluster2-worker gpu:NoSchedule-  
# removing the taint from one of the node with key 'gpu' and effect 'NoSchedule'

k get pods -o wide
# checking the status of the pod without tolerations again , to see if it sscheduled
# now the nginx pod should be in running state because one node is untainted

k describe pod redis

k run nginx-new --image=nginx --dry-run=client -o yaml > newnginx.yaml  
# creating a new pod with node selector to avoid GPU nodes

k apply -f newnginx.yaml
# applying the new pod with node selector with nodeSelector:  -> gpu: "false"

k get pods -o wide
# checking the status of the new pod with node selector
# pod in pending state if no node matches the selector

k label node cka-cluster2-worker2 gpu=true
# labeling the second worker node with a label 'gpu=true'

k get pods -o wide
# checking the status of the new pod with node selector again
# pod still pending because the labeled node has taint and the pod does not tolerate it

k label node cka-cluster2-worker gpu=true
# labeling the first worker node, which is untainted, with a label 'gpu=true'

k label node cka-cluster2-worker gpu=false --overwrite=true
# overwriting the label on the first worker node to 'gpu=false'
# now the first worker node has label 'gpu=false' and no taint so the new nginx pod should be scheduled on it