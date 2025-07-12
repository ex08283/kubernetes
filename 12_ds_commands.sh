# This script provides commands to manage DaemonSets in Kubernetes.

# Get all DaemonSets in the current namespace with wide output
k get ds

# Get all DaemonSets in the current namespace
k get ds -A

# Get all DaemonSets in a specific namespace
k get ds -n <namespace>

# Get all DaemonSets in a specific namespace with wide output
k get ds -n <namespace> -o wide

k delete ds <daemonset-name>
# Delete all DaemonSets in the current namespace
k delete ds --all   
# Delete all DaemonSets in a specific namespace
k delete ds --all -n <namespace>    
# Delete a specific DaemonSet in a specific namespace
k delete ds <daemonset-name> -n <namespace> 
# Describe a specific DaemonSet
k describe ds <daemonset-name>