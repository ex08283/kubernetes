#!/bin/bash

# Step 1: Create a new Kubernetes cluster using kind (Kubernetes IN Docker)
kind create cluster \
  --image kindest/node:v1.32.5@sha256:e3b2327e3a5ab8c76f5ece68936e4cafaa82edf58486b769727ab0b3b97a5b0d \
  --name cka-cluster1

kind create cluster \
  --image kindest/node:v1.32.5@sha256:e3b2327e3a5ab8c76f5ece68936e4cafaa82edf58486b769727ab0b3b97a5b0d \
  --name cka-cluster2
  --config cluster_config.yaml

kind delete cluster --name cka-cluster2

# Step 2: Get nodes
kubectl.exe get nodes

# Step 3: Show contexts
kubectl.exe config get-contexts

# Step 4: Use the correct context
kubectl.exe config use-context kind-cka-cluster1

# Step 5: List Docker containers
docker ps -a

# Step 6: Start existing kind cluster containers
docker start cka-cluster2-control-plane cka-cluster2-worker cka-cluster2-worker2

# Step 7: Create an nginx pod
kubectl.exe run nginx-pod --image=nginx:latest

# Step 8: Get pods
kubectl.exe get pods

# Step 9: Create resources from a YAML manifest
kubectl.exe create -f day07-yaml.yaml

# Step 10: Get pods (wide output)
kubectl.exe get pods -o wide

# Step 11: Get nodes (wide output)
kubectl.exe get nodes -o wide

# Step 12: Describe a specific pod
kubectl.exe describe pod nginx-pod2

# Step 13: Show labels of a specific pod
kubectl.exe get pods nginx-pod2 --show-labels

# Step 14: Delete a pod
kubectl.exe delete pod nginx-pod

# Step 15: Apply a manifest (idempotent)
kubectl.exe apply -f day07-yaml.yaml

# Step 16: Simulate creating a pod (dry-run only, no actual creation)
kubectl.exe run nginx --image=nginx --dry-run=client

# Step 17: Output the pod definition as YAML and save to file
kubectl.exe run nginx --image=nginx --dry-run=client -o yaml > pod-new.yaml

# Step 18: Output the pod definition as JSON and save to file
kubectl.exe run nginx --image=nginx --dry-run=client -o json > pod-new.json

# Step 19: Export the full YAML definition of an existing pod to a file
# Useful for editing and recreating the pod later
kubectl.exe get pod nginx-pod3 -o yaml > nginx-pod.yaml
