#!/bin/sh

#####
# Simple script that selects the correct kubectl version for the target API server
# 
# This is done by making a pre-flight request with the latest kubectl version to get
# the API server version in the hope that it works despite any version skew, being
# the simplest possible API request... :fingerscrossed:
#####

KUBECONFIG_ARG=
KUBECTL_ARGS=

while :; do
    case $1 in
        --kubeconfig)
            KUBECONFIG_ARG="$1 $2"
            shift
            ;;
        --kubeconfig=?*)
            KUBECONFIG_ARG="$1"
            ;;
        ?*)
            KUBECTL_ARGS="$KUBECTL_ARGS $1"
            ;;
        *)
            break
    esac
    shift
done

set -eo pipefail

# Use the latest version of kubectl to detect the server version
kubectl_exe=kubectl-$KUBECTL_VN_LATEST
server_version="$($kubectl_exe $KUBECONFIG_ARG version -o json | jq -r '"v" + .serverVersion.major + "." + .serverVersion.minor')"
# Account for the case where we don't have the correct kubectl version by falling back to using the latest
which "kubectl-$server_version" > /dev/null && kubectl_exe="kubectl-$server_version"
exec $kubectl_exe $KUBECONFIG_ARG $KUBECTL_ARGS