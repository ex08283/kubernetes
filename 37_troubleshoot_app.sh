# first fork this repo https://github.com/piyushsachdeva/example-voting-app.git
# clone it to your local machine
git clone https://github.com/piyushsachdeva/example-voting-app.git

once the repo is cloned, copy it over to the master node of your k8s cluster

# this will clone it to the current directory
cd ~/37_troubleshoot_app/k8s-specifications

k apply -f .
# this will deploy the voting app to the cluster

k get svc
NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
db           ClusterIP   10.107.57.20   <none>        5432/TCP         16m       
kubernetes   ClusterIP   10.96.0.1      <none>        443/TCP          16d       
redis        ClusterIP   10.111.13.71   <none>        6379/TCP         16m       
result       NodePort    10.98.208.30   <none>        5001:31001/TCP   16m       
vote         NodePort    10.97.201.14   <none>        5000:31000/TCP   16m  

# go to the browser and access the voting app using the node IP and node port
# for example http://172.166.136.252:31000
# this does not work, so we need to troubleshoot

k get deploy vote -o yaml
    spec:
      containers:
      - image: dockersamples/examplevotingapp_vote
        imagePullPolicy: Always
        name: vote
        ports:
        - containerPort: 80

# we can see that the container port is 80 but the service is targeting port 8080

k describe svc vote
# check if the service is correctly configured

k get svc vote -o yaml
spec:
  clusterIP: 10.97.201.14
  clusterIPs:
  - 10.97.201.14
  externalTrafficPolicy: Cluster
  internalTrafficPolicy: Cluster
  ipFamilies:
  - IPv4
  ipFamilyPolicy: SingleStack
  ports:
  - name: vote-service
    nodePort: 31000
    port: 5000
    protocol: TCP
    targetPort: 8080
  selector:
    app: vote   # this means that the service is selecting pods with label app=vote
  sessionAffinity: None
  type: NodePort
status:
  loadBalancer: {}

# lets edit the svc to target port 80
k edit svc vote
# change targetPort from 8080 to 80

k get pods -l app=vote
#or
k get pods --show-labels

 k get ep
NAME         ENDPOINTS              AGE
db           192.168.126.174:5432   26m
kubernetes   10.240.0.4:6443        16d
redis        192.168.126.175:6379   26m
result       <none>                 26m
vote         192.168.126.176:8080   26m
# check the endpoints, we can see the result service has no endpoints, we will have to check the service and deployment for result app

k get svc result -o yaml
spec:
  clusterIP: 10.98.208.30
  clusterIPs:
  - 10.98.208.30
  externalTrafficPolicy: Cluster
  internalTrafficPolicy: Cluster
  ipFamilies:
  - IPv4
  ipFamilyPolicy: SingleStack
  ports:
  - name: result-service
    nodePort: 31001
    port: 5001
    protocol: TCP
    targetPort: 80
  selector:      # this means that the service is selecting pods with label
    app: results   


k get pods --show-labels
NAME                     READY   STATUS    RESTARTS   AGE   LABELS
db-597b4ff8d7-5gqwv      1/1     Running   0          36m   app=db,pod-template-hash=597b4ff8d7
redis-796dc594bb-rnrrv   1/1     Running   0          36m   app=redis,pod-template-hash=796dc594bb
result-d8c4c69b8-njsvh   1/1     Running   0          36m   app=result,pod-template-hash=d8c4c69b8
vote-69cb46f6fb-lvlfx    1/1     Running   0          36m   app=vote,pod-template-hash=69cb46f6fb

# we can see that there are pods with the label app=vote app=result, so we need to edit the service to select the correct label
k edit svc result
# change selector from app=result to app=results


#lets troubleshot redis not working by checking network policies
k get networkpolicy
No resources found in default namespace.
# we can see there are no network policies applied, so network policies are not blocking the traffic

 k apply -f networkpolicy.yaml
error: error validating "networkpolicy.yaml": error validating data: apiVersion not set; if you choose to ignore these errors, turn validation off with --validate=false
# we get an error while applying the network policy, so we need to check the yaml file for errors

cat networkpolicy.yaml
kind: NetworkPolicy
metadata:
  name: access-redis
spec:
  podSelector:
    matchLabels:
      app: redis
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: "frontend"
# we missed apiVersion field in the yaml file
k edit networkpolicy.yaml
# add the following line at the top

# also we need to change label app: "frontend" to app: "vote" as our vote app has label app=vote
k apply -f networkpolicy.yaml

k get netpol  
NAME           POD-SELECTOR   AGE
access-redis   app=redis      35s

k describe netpol access-redis
Name:         access-redis
Namespace:    default
Created on:   2025-12-01 20:49:05 +0000 UTC
Labels:       <none>
Annotations:  <none>
Spec:
  PodSelector:     app=redis
  Allowing ingress traffic:
    To Port: <any> (traffic allowed to all ports)
    From:
      PodSelector: app=vote
  Not affecting egress traffic
  Policy Types: Ingress

  # now this means that only pods with label app=vote can access redis pod