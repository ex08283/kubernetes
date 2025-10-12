
k apply -f metric-server.yaml
#a yaml that displays memory usage of pods and nodes
# applying the metric server configuration

k get pods -n kube-system
# checking the status of the metric server pods
# pod is sheduled and running

k top node
# checking the resource usage of nodes

k create ns mem-example
# creating a namespace for memory example

touch within_limits.yaml


k apply -f within_limits.yaml
# applying the metric server configuration. 
# Where mempory consumed is within limits

k top pod memory-demo -n mem-example
# OOMKilled status

touch above-limits.yaml


k apply -f above-limits.yaml
# applying the memory request configuration
# Where memory consumed is above limits

k get pods -n mem-example

k describe pod memory-demo2 -n mem-example


k apply -f insuficient-memory.yaml
# applying the memory request configuration
# Where memory requested is more than available memory

k describe pod memory-demo3 -n mem-example
# Pod is in pending state
# because the requested memory is more than available memory
#     resources:
    #   requests:
    #     memory: "1000Gi" # requesting 1000Gi of memory, more than node capacity
    #   limits:
    #     memory: "1000Gi" # requesting 1000Gi of memory, more than node capacity

k delete pod memory-demo -n mem-example
k delete pod memory-demo2 -n mem-example

