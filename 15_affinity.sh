# This script demonstrates how to use Kubernetes affinity rules to control pod scheduling based on node labels.
# Affinity rules allow you to specify which nodes a pod can be scheduled on based on node labels.
# This can be useful for ensuring that pods run on nodes with specific characteristics, such as hardware capabilities or performance requirements.
# Affinity rules can be used in conjunction with node selectors and taints/tolerations for more granular control over pod scheduling.
# unlike node selectors, affinity rules can specify preferences for node labels, allowing for more flexible scheduling. 
# Affinity rules can be defined in the pod specification under the `affinity` field.    

#If a node does not have a taint at all, the pod with any tolerations can be scheduled on that node.
# However if we add a label to that node, we can prevet a pod from being scheduled on that node by using affinity rules.

k apply -f affinity.yaml
# applying the affinity rules defined in the affinity.yaml file
# requiredDuringSchedulingIgnoredDuringExecution specifies that the pod must be scheduled on nodes that match the specified node labels.

k get pods
# we can see the pod is not scheduled yet because no nodes match the required affinity rules.

kubectl label node cka-cluster2-worker disktype=ssd
# labeling the worker node with a label 'disktype=ssd', to match the affinity rule in the pod specification

k get pods
# we can see the pod is now scheduled on the node with the label 'disktype=ssd'

k delete pods --all
# deleting all pods to start fresh

k label node cka-cluster2-worker disktype-
# removing the label from the worker node to see how it affects pod scheduling


k apply -f affinity_preferred.yaml
# applying the affinity rules defined in the affinity_preferred.yaml file
# preferredDuringSchedulingIgnoredDuringExecution specifies that the pod prefers to be scheduled on nodes that match the specified node labels, but it is not required.
# if no nodes match the preferred rules, the pod can still be scheduled on other nodes.

k get pods
# we can see the pod is scheduled even though no nodes match the preferred affinity rules, because it is not a strict requirement.

k label node cka-cluster2-worker disktype-
# removing the label from the worker node again

k label node cka-cluster2-worker disktype=
# re-labeling the worker node with a label 'disktype=' to match the preferred affinity rule in the pod specification
# to test the behavior when the label exists but has no specific value

k apply -f affinity_exists.yaml
# applying the affinity rules defined in the affinity_exists.yaml file
# this pod will only be scheduled on nodes that have the disktype label, regardless of its value.
# if no nodes have the disktype label, the pod will not be scheduled   

k get pods
# we can see the pod is scheduled on the node with the label 'disktype=', even though it has no specific value.
