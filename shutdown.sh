#!/usr/bin/env bash

# get list of VMs on the node
VMIDs=$(/usr/sbin/qm list| awk '/[0-9]/ {print $1}')

# ask them to shutdown
for VM in $VMIDs
do
    /usr/sbin/qm shutdown $VM
done


#wait until they're done (and down)
for VM in $VMIDs
do
    while [[ $(/usr/sbin/qm status $VM) =~ running ]] ; do
        sleep 1
    done
done

PCTIDs=$(/usr/sbin/pct list| awk '/[0-9]/ {print $1}')

# ask them to shutdown
for PCT in $PCTIDs
do
    /usr/sbin/pct stop $PCT
done


#wait until they're done (and down)
for PCT in $PCTIDs
do
    while [[ $(/usr/sbin/pct status $PCT) =~ running ]] ; do
        sleep 1
    done
done

## do the reboot
/usr/sbin/shutdown -h now