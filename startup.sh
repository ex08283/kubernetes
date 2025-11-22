#!/bin/bash

# ─────────────────────────────────────────────
# CONFIG - UPDATE THESE WITH YOUR DETAILS
# ─────────────────────────────────────────────
RESOURCE_GROUP="k8s-lab-rg"
NETSKOPE_SERVICE="stAgentSvc"
# ─────────────────────────────────────────────

command=$1


# Get all VM names in the resource group into an array
get_vm_list() {
    mapfile -t VMS < <(az vm list --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv)
}

start_docker_desktop() {
    echo "Starting Docker Desktop..."
    powershell.exe -Command "Start-Process 'C:\\Program Files\\Docker\\Docker\\Docker Desktop.exe'" >/dev/null 2>&1
}

stop_netskope() {
    echo "Stopping Netskope service ($NETSKOPE_SERVICE)..."
    powershell.exe -Command "Stop-Service -Name '$NETSKOPE_SERVICE' -Force" >/dev/null 2>&1
}

start_azure_vms() {
    echo "Fetching VM list from Azure..."
    get_vm_list
    echo "VMs to start: ${VMS[@]}"  
    echo

    for vm in "${VMS[@]}"; do
        vm_clean=$(echo "$vm" | tr -d '\r')
        # Get current VM state
        status=$(az vm get-instance-view -n "$vm_clean" -g "$RESOURCE_GROUP" --query "instanceView.statuses[?starts_with(code,'PowerState/')].displayStatus" -o tsv)
        if [[ "$status" == "VM running" ]]; then
            echo "$vm_clean is already running. Skipping."
        else
            echo "Starting VM: $vm_clean"
            az vm start -n "$vm_clean" -g "$RESOURCE_GROUP"
        fi
    done
}

stop_azure_vms() {
    echo "Fetching VM list from Azure..."
    get_vm_list
    echo "VMs to stop (deallocate): ${VMS[@]}"
    echo

    for vm in "${VMS[@]}"; do
        vm_clean=$(echo "$vm" | tr -d '\r')
        # Get current VM state
        status=$(az vm get-instance-view -n "$vm_clean" -g "$RESOURCE_GROUP" --query "instanceView.statuses[?starts_with(code,'PowerState/')].displayStatus" -o tsv)
        if [[ "$status" == "VM deallocated" ]]; then
            echo "$vm_clean is already deallocated. Skipping."
        else
            echo "Stopping VM (deallocate): $vm_clean"
            az vm deallocate -n "$vm_clean" -g "$RESOURCE_GROUP"
        fi
    done
}


case $command in

    start)
        echo "=== START TASKS ==="
        start_docker_desktop
        stop_netskope
        start_azure_vms
        echo "All start tasks done."
        ;;

    stop)
        echo "=== STOP TASKS ==="
        stop_azure_vms
        echo "All stop tasks done."
        ;;

    *)
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac
