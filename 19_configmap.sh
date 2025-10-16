k create cm app-config --from-literal=FIRST_NAME=Delawar 
\--from-literal=LAST_NAME=Khan
# This command creates a ConfigMap named 'app-config' with two key-value pairs:

k get cm
# This command lists all ConfigMaps in the current namespace, showing their names and other details.

k describe cm app-config
# This command provides detailed information about the 'app-config' ConfigMap, including its data and metadata.

k exec -it app-pod -- sh
# This command opens an interactive shell session inside the 'app-pod' Pod, allowing you to run commands within the container.

    env:                # environment variables for the app container
    - name: firstname
      valueFrom:
        configMapKeyRef:
          name: app-config       # name of the ConfigMap
          key: FIRST_NAME           # key in the ConfigMap to use
# use the above snippet in the pod.yaml file to reference the ConfigMap in a Pod



k create cm app-config --from-file=app-config.properties
# Imperative way to create a ConfigMap from a file
# This command creates a ConfigMap named 'app-config' using key-value pairs defined in the
# 'app-config.properties' file. Each line in the file should be in the format 'key=value'.

k create cm cm-yaml --from-literal=FIRST_NAME=Delawar --from-literal=LAST_NAME=Khan  --dry-run=client -o yaml > configmap.yaml
# This command generates a YAML manifest for a ConfigMap named 'app-config' with two key
# value pairs, but does not create it in the cluster. The output is saved to 'configmap.yaml'.
# The --dry-run=client flag indicates that the command should not be executed against the cluster,
# and -o yaml specifies that the output should be in YAML format.

k apply -f configmap.yaml
# This command applies the configuration defined in 'configmap.yaml' to the cluster,

