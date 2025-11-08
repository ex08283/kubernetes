k get sa
# List all ServiceAccounts in the current namespace

k get sa -A | grep default
# List all default ServiceAccounts in all namespaces

k describe sa default
# Describe the default ServiceAccount in the current namespace

k get sa default -o yaml
# Get the YAML representation of the default ServiceAccount in the current namespace

k create sa sa-dj
# Create a new ServiceAccount named sa-dj in the current namespace

k apply -f 24-servaccount/secret.yaml
# Apply the secret configuration from the specified YAML file to create a secret associated with the service account

k get secret
# List all secrets in the current namespace, including the one associated with the service account sa-d

k describe secret dj-secret
# Describe the secret named dj-secret to see its details

# we can create an image pull secret and link it to the service account
k create secret docker-registry my-registry-secret --docker-server=<your-registry-server> --docker-username=<your-username> --docker-password=<your-password> --docker-email=<your-email>

k get pods --as sa-dj
# Try to get pods using the service account sa-dj, it may fail if the sa does not have permissions

k auth can i get pods --as sa-dj
# Check if the service account sa-dj can get pods, it may return 'no'

k create role builder-role --verb=get,list,watch --resource=pods
# Create a Role named builder-role that allows get, list, and watch verbs on pods in the current namespace

k create rolebinding builder-rolebinding --role=builder-role --serviceaccount=<namespace>:sa-dj
# Create a RoleBinding named builder-rolebinding that binds the builder-role to the service account sa

$ k auth can-i get pods --as system:serviceaccount:default:sa-dj
# Check if the service account sa-dj can get pods after the RoleBinding has been created

k create rolebinding builder-rolebinding --role=builder-role --user=sa-dj
# Alternative way to create a RoleBinding named builder-rolebinding that binds the builder-role to the service account sa-dj
# this way is less preferred
k auth can-i get pods --as sa-dj
# Check if the service account sa-dj can get pods after the RoleBinding has been created



# we can use the sa and the image pull secret in a pod yaml file
# or use the image pull secret and the sa to get pods by calling the api using below command
k get pods --as=system:serviceaccount:<namespace>:sa-dj
# Replace <namespace> with the actual namespace where the service account sa-dj is created

