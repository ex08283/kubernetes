k autoscale deployment php-apache --cpu=50% --min=1 --max=10
# This command creates an HPA that will scale the 'php-apache' deployment based on CPU usage.
# The HPA will attempt to maintain an average CPU utilization of 50% across all Pods
# in the deployment. If the average CPU usage exceeds 50%, the HPA will increase the number of replicas.
# Conversely, if the average CPU usage falls below 50%, the HPA will decrease the number of replicas.
# The HPA will ensure that the number of replicas stays within the specified range of 1 to 10.
# You can adjust the --min and --max values to set the desired range for scaling.
# You can monitor the status of the HPA using:
kubectl get hpa
# This will show you the current number of replicas, the target CPU utilization, and the current CPU utilization.
# To stop the autoscaling, you can delete the HPA using:
kubectl delete hpa php-apache
# This will remove the HPA and stop any automatic scaling of the 'php-apache' deployment.
# Note: Ensure that your Pods have resource requests and limits set for CPU to enable proper autoscaling.
# You can define these in your deployment YAML file under the container's resources section.


#see how the autoscaler reacts to increased load. 
#To do this, you'll start a different Pod to act as a client.
# The container within the client Pod runs in an infinite loop, 
#sending queries to the php-apache service.
# Run this in a separate terminal
# so that the load generation continues and you can carry on with the rest of the steps
kubectl run -i --tty load-generator --rm --image=busybox:1.28 --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://php-apache; done"


k get hpa
#To see the load getting inceased

k get hpa -w
#To watch the load getting increased and the autoscaler reacting to it

# we can see the number of replicas increasing as the CPU usage goes up
# $ k get pods
# NAME                          READY   STATUS    RESTARTS   AGE
# load-generator                1/1     Running   0          2m10s
# php-apache-6487c65df8-75mdq   1/1     Running   0          96s
# php-apache-6487c65df8-8jhg8   1/1     Running   0          81s
# php-apache-6487c65df8-8qxbl   1/1     Running   0          50s
# php-apache-6487c65df8-cn5x6   1/1     Running   0          96s
# php-apache-6487c65df8-nv7g2   1/1     Running   0          23m
# php-apache-6487c65df8-sqr25   1/1     Running   0          50s
# php-apache-6487c65df8-wcdh7   1/1     Running   0          96s