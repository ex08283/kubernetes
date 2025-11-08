# a cluser role is a set of permissions that can be applied across the entire cluster
# It is not namespaced, meaning it applies to all namespaces in the cluster
# Cluster roles are used to define permissions for resources that are not namespaced, such as nodes and persistent volumes, or to grant the same permissions across all namespaces.

k api-resources --namespaced=true
# List all namespaced resources
# resources like pods, services, and deployments are namespaced

 k api-resources --namespaced=false
# List all non-namespaced resources, at cluster level
# resources like nodes, persistent volumes, and cluster roles are non-namespaced

k auth can-i get nodes --as adam
# Check if user 'adam' can get nodes (a namespaced resource)

k create clusterrole --help
# Get help on creating a ClusterRole
j
k create clusterrole node-reader-dj --verb=get,list,watch --resource=nodes
# Create a ClusterRole named node-reader-dj that allows get, list, and watch verbs on nodes

k get clusterrole
# List all ClusterRoles in the cluster

k describe clusterrole node-reader-dj
# Describe the node-reader-dj ClusterRole to see its permissions

k create clusterrolebinding clusterbinding --clusterrole=node-reader-dj --user=Adam
# Create a ClusterRoleBinding named clusterbinding that binds the node-reader-dj ClusterRole to user 'Adam'
# Use capital A in Adam to match the user in kubeconfig
# how to get the user in kubeconfig

$ k auth can-i get nodes --as=adam
# Check if user 'adam' can get nodes after the ClusterRoleBinding has been created



