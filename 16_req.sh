
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

touch mem-request.yaml


k apply -f mem-request.yaml
# applying the metric server configuration. 
# Where mempory consumed is within limits

k top pod memory-demo -n mem-example
# OOMKilled status

touch mem-req2.yaml


k apply -f mem-req2.yaml
# applying the memory request configuration
# Where memory consumed is above limits

k get pods -n mem-example

