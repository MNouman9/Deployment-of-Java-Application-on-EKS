#!/bin/bash

set -euo pipefail

log() {
    echo -e "\033[1;34m[INFO]\033[0m $1"
}

error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1" >&2
    exit 1
}

check_dependencies() {
    for cmd in aws kubectl helm; do
        command -v $cmd >/dev/null 2>&1 || error "$cmd is not installed. Please install it before running the script."
    done
}

prompt_user_input() {
    read -rp "Enter EKS Cluster Name: " CLUSTER_NAME
    read -rp "Enter AWS Region (e.g., us-east-1): " REGION
    read -rp "Enter Namespace: " NAMESPACE
    read -rp "Enter Helm Release Name: " RELEASE_NAME
    read -rp "Enter Helm Chart Path (e.g., ./helm-charts/my-app): " CHART_PATH
    read -rp "Enter Values File Path (e.g., ./helm-charts/my-app/values.yaml): " VALUES_FILE
    read -rp "Do you want to run in dry-run mode? (y/n): " DRYRUN_INPUT

    if [[ "$DRYRUN_INPUT" =~ ^[Yy]$ ]]; then
        DRY_RUN="--dry-run"
    else
        DRY_RUN=""
    fi
}

switch_context() {
    log "Switching context to EKS cluster: $CLUSTER_NAME"
    aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER_NAME" >/dev/null
    CURRENT_CONTEXT=$(kubectl config current-context)
    log "Current context set to: $CURRENT_CONTEXT"
}

create_namespace_if_missing() {
    if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
        log "Namespace '$NAMESPACE' does not exist. Creating it..."
        kubectl create namespace "$NAMESPACE"
    else
        log "Namespace '$NAMESPACE' already exists."
    fi
}

deploy_chart() {
    if helm ls -n "$NAMESPACE" | grep -q "$RELEASE_NAME"; then
        log "Upgrading existing Helm release: $RELEASE_NAME"
        helm upgrade "$RELEASE_NAME" "$CHART_PATH" \
            --namespace "$NAMESPACE" \
            --values "$VALUES_FILE" \
            --timeout 5m \
            --atomic \
            $DRY_RUN
    else
        log "Installing new Helm release: $RELEASE_NAME"
        helm install "$RELEASE_NAME" "$CHART_PATH" \
            --namespace "$NAMESPACE" \
            --values "$VALUES_FILE" \
            --timeout 5m \
            --create-namespace \
            --atomic \
            $DRY_RUN
    fi
}



log "🔧 Starting Helm deployment script..."

check_dependencies
prompt_user_input
switch_context
create_namespace_if_missing
deploy_chart

log "✅ Deployment completed."
