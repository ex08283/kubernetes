k auth can-i get pods
# to check if the current user can get pods

k auth whoami
# to see the current user

$ k auth whoami --as=adam
# to see who adam is

# There are core groups and named groups in Kubernetes RBAC.
# Core groups include system:masters, system:nodes, and system:authenticated.
# Named groups are user-defined groups created using RoleBindings or ClusterRoleBindings.   
kubectl auth can-i get pods --as=adam --namespace=default
# Check if the user adam can get pods in the default namespace

k apply -f role.yaml
# Apply the RBAC role configuration from the rbac-role.yaml file

k get role
# List all Roles in the current namespace

k describe role pod-reader
# Describe the pod-reader Role to see its permissions

k apply -f role_binding.yaml
# Apply the RBAC role binding configuration from the rbac-rolebinding.yaml file

k get rolebinding
# List all RoleBindings in the current namespace

k describe rolebinding read-pods-binding
# Describe the read-pods-binding RoleBinding to see its details


k auth can-i get pods --as=adam --namespace=default
# Check again if the user adam can get pods in the default namespace after applying the Role and

k get role -A --no-headers | wc -l
# Count the total number of Roles across all namespaces

k config set-credentials adam  \
--client-certificate=./adam.crt \
--client-key=./adam.key \
--embed-certs=true
# Set the credentials for the user adam in the kubeconfig file using the provided certificate and key
# here adam is the username in the kubeconfig file


k config set-context adam-context --cluster=kind-cka-cluster2 --user=adam
# a new context will be created for the user  adam


k config use-context adam-context
# Set a new context named adam-context using the cka-cluster2 cluster and the adam user

k config view
# View the current kubeconfig settings to verify the context switch

k config delete-context adam-context


curl -k https://localhost:64418/api/v1/namespaces/kube-system/pods \
--cert ./adam.crt --key ./adam.key

# to get ca.crt from control plane node
docker exec -it cka-control-plane cat /etc/kubernetes/pki/ca.crt > ca.crt


