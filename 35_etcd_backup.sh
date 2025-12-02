# this file will be a step-by-step guide on how to back up etcd data

# ssh onto controller node
ssh azureuser@172.167.212.95

cd /etc/kubernetes/manifests   
# navigate to the directory containing the etcd manifest file

ls -lrt
# list the files to confirm the presence of etcd manifest   

cat etcd.yaml
# view the etcd manifest file to find the data directory path

 - --data-dir=/var/lib/etcd
 # this is the directory where etcd data is stored

   - --listen-client-urls=https://127.0.0.1:2379,https://10.240.0.4:2379
# this is the client URL where etcd listens for requests, the api server is the client in this case requesting data

- --key-file=/etc/kubernetes/pki/etcd/server.key
# which is the key file for etcd server authentication

- --cert-file=/etc/kubernetes/pki/etcd/server.crt
# which is the public certificate for etcd server authentication

    volumeMounts:
    - mountPath: /var/lib/etcd
      name: etcd-data
    - mountPath: /etc/kubernetes/pki/etcd
      name: etcd-certs

# then we have volume mounts for etcd data and etcd certificates
# two volumes are attached to the etcd pod that correspond to the above mounts

azureuser@k8s-lab-master:/etc/kubernetes/manifests$ sudo ls /var/lib/etcd/
member
azureuser@k8s-lab-master:/etc/kubernetes/manifests$ sudo ls /etc/kubernetes/pki/etcd/
ca.crt  healthcheck-client.crt  peer.crt  server.crt
ca.key  healthcheck-client.key  peer.key  server.key

# now these location are mounted inside the etcd pod, locally on the host machine we can see the data and certs

# now we can back up the etcd data using etcdctl command
# first we need to set environment variables for etcdctl to connect to the etcd server  

etcdctl
Command 'etcdctl' not found, but can be installed with:
sudo snap install etcd         # version 3.4.36, or
sudo apt  install etcd-client  # version 3.3.25+dfsg-7ubuntu0.22.04.2
See 'snap info etcd' for additional versions.

# etcdctl is not installed, so we will install etcd-client package
sudo apt-get update
sudo apt-get install -y etcd-client

ETCDCTL_API=3 etcdctl snapshot
# set the etcdctl api version to 3

export ETCDCTL_API=3
# export the variable so that it is available in the shell

cat /etc/kubernetes/manifests/etcd.yaml | grep "listen-client-urls"
    - --listen-client-urls=https://

etcdctl --endpoints==https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \  # trusted CA certificate
  --cert=/etc/kubernetes/pki/etcd/server.crt \ #certificate file
  --key=/etc/kubernetes/pki/etcd/server.key \ # key file
  snapshot save /tmp/etcd-backup.db

sudo ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save /tmp/etcd-backup.db
2025-11-26 13:43:55.001293 I | clientv3: opened snapshot stream; downloading
2025-11-26 13:43:55.283397 I | clientv3: completed snapshot read; closing
Snapshot saved at /tmp/etcd-backup.db

# the above command connects to the etcd server using the specified endpoints and certificates, and saves a snapshot of the etcd data to /tmp/etcd-backup.db

#chek the size of the backup file
du -h /tmp/etcd-backup.db

# below depicts the usafge of etcdctl snapshot commands
etcdctl --write-out=table snapshot status /tmp/etcd-backup.db

k get all
NAME                               READY   STATUS    RESTARTS      AGE
pod/hello-world-757d6f94d6-5jq8z   1/1     Running   2 (80m ago)   3d20h

NAME                  TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/hello-world   ClusterIP   10.104.174.70   <none>        80/TCP    9d
service/kubernetes    ClusterIP   10.96.0.1       <none>        443/TCP   11d

NAME                          READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/hello-world   1/1     1            1           9d

NAME                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/hello-world-6c6b455d57   0         0         0       9d
replicaset.apps/hello-world-757d6f94d6   1         1         1       5d21h

# lets delete the hello-world deployment to simulate data loss
k delete deployment hello-world
deployment.apps "hello-world" deleted

# now lets restore the etcd data from the backup file
sudo ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot restore /tmp/etcd-backup.db \
  --data-dir=/var/lib/etcd-restored

cd /etc/kubernetes/manifests
sudo vi etcd.yaml
# edit the etcd manifest file to point to the restored data directory
 - --data-dir=/var/lib/etcd-restored
# change the data-dir to /var/lib/etcd-restored and save the file

# lets restart the api server to pick up the changes
sudo systemctl restart kubelet
Error from server (Forbidden): pods is forbidden: User "kubernetes-admin" cannot list resource "pods" in API group "" in the namespace "default"

# we forgot to change the mount path in the etcd manifest file, so we will change it now
sudo vi etcd.yaml
    - mountPath: /var/lib/etcd-restored
      name: etcd-data
    - hostPath: /var/lib/etcd-restored
      name: etcd-data
# change the mount path to /var/lib/etcd-restored and save the file

# restart the kubelet service again
sudo systemctl restart kubelet

k get pods -n kube-system
k describe pod etcd-master -n kube-system