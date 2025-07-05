#creates pods as specified in the rc.yaml file
kubectl.exe apply -f rc.yaml

#get replication controllers
kubectl.exe get rc

#get the pods details such as replication controller, node, events, etc.
kubectl.exe describe pod nginx-rc-hnx9l

#delete the replication controller
# This will delete the replication controller and all its pods
kubectl.exe delete rc/nginx-rc

#create a replica set from the rs.yaml file     
kubectl.exe apply -f rs.yaml 

kubectl.exe get rs

#edit the replica set to change the number of replicas
# This will open the replica set in the default editor (usually vim or nano)
kubectl.exe edit rs/nginx-rs

#alternative way of scaling, scale the replica set to 10 replicas
kubectl.exe scale --replicas=10 rs/nginx-rs

#delete the replica set
kubectl.exe delete rs/nginx-rs

#  create a deployment from the deployment.yaml file
# a deployment manages a set of replicas and provides declarative updates to them
# this allows you to change the number of replicas, update the image, and roll back to previous versions
kubectl.exe apply -f deployment.yaml

# get the deployments
kubectl.exe get deploy

# get all objects in cluster
# This will show all resources in the cluster, including pods, services, deployments, etc.
kubectl.exe get all

# describe the deployment
kubectl.exe describe deploy/nginx-deploy

# set the image of the deployment to a specific version
kubectl.exe set image deploy/nginx-deploy nginx=nginx:1.9.1

# describe the deployment
kubectl.exe describe deploy/nginx-deploy

# This will show the history of the deployment, including revisions and changes made
kubectl.exe rollout history deploy/nginx-deploy

# This will undo the last rollout of the deployment, reverting to the previous version
kubectl.exe rollout undo deploy/nginx-deploy

# This will create a deployment named nginx-deploy with the nginx image, but it won't actually create it
kubectl.exe create deploy deploy/nginx-deploy --dry-run=client --image=nginx

# This will create a deployment named nginx-deploy with the nginx image and output the YAML to a file
kubectl.exe create deploy deploy/nginx-deploy --image=nginx --dry-run=client -o yaml > deployment.yaml