#!/bin/bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

DOCKER_REGISTRY="julesreyn/area"
KUBERNETES_DEPLOYMENTS_DIR="services/kubernetes/deployments"
KUBERNETES_SERVICES_DIR="services/kubernetes/services"
KUBERNETES_HPA_DIR="services/kubernetes/hpa"
KUBERNETES_INGRESS_FILE="services/kubernetes/networking/ingress.yaml"
HPA_TEMPLATE_FILE="$KUBERNETES_HPA_DIR/hpa-template.yaml"
SERVICE_TEMPLATE_FILE="$KUBERNETES_SERVICES_DIR/service-template.yaml"

DEFAULT_PORT=80
DEFAULT_TARGET_PORT=8000

print_header() {
    echo -e "${BLUE}"
    echo "###############################################"
    echo "#     Area - K3s Service Management           #"
    echo "###############################################"
    echo -e "${NC}"
}

detect_services() {
    echo -e "${YELLOW}Detecting services...${NC}"
    SERVICES=()
    for dir in "$KUBERNETES_DEPLOYMENTS_DIR"/*/; do
        service=$(basename "$dir")
        SERVICES+=("$service")
    done
    if [ ${#SERVICES[@]} -eq 0 ]; then
        echo -e "${RED}No services detected in $KUBERNETES_DEPLOYMENTS_DIR.${NC}"
        exit 1
    fi
}

list_services() {
    echo -e "${YELLOW}Detected services:${NC}\n"
    for service in "${SERVICES[@]}"; do
        echo -e "   -> ${service^}"
    done
    echo ""
}

build_and_push_images() {
    echo -e "${YELLOW}Logging into Docker registry...${NC}"
    {
        echo "$DOCKER_PASSWORD" | sudo docker login -u "$DOCKER_USERNAME" --password-stdin
        echo -e "   ${GREEN}✔ Logged into Docker successfully.${NC}"
    } || {
        echo -e "   ${RED}✖ Failed to log into Docker registry.${NC}"
        exit 1
    }

    echo -e "${YELLOW}Building and pushing Docker images...${NC}"
    for service in "${SERVICES[@]}"; do
        echo -e "   [+] Building Docker image for ${service^}..."
        {
            sudo docker build -t "$DOCKER_REGISTRY:$service" "./services/images/$service" >/dev/null 2>&1
            echo -e "       ${GREEN}✔ Image built: $DOCKER_REGISTRY:$service${NC}"
        } || {
            echo -e "       ${RED}✖ Failed to build image for $service${NC}"
            exit 1
        }

        echo -e "   [+] Pushing Docker image for ${service^}..."
        {
            sudo docker push "$DOCKER_REGISTRY:$service" >/dev/null 2>&1
            echo -e "       ${GREEN}✔ Image pushed: $DOCKER_REGISTRY:$service${NC}"
        } || {
            echo -e "       ${RED}✖ Failed to push image for $service${NC}"
            exit 1
        }
    done
    echo ""
}


generate_hpa() {
    echo -e "${YELLOW}Generating HPA configurations...${NC}"
    for service in "${SERVICES[@]}"; do
        HPA_FILE="$KUBERNETES_HPA_DIR/${service}-hpa.yaml"
        sed "s/{{service}}/$service/g" "$HPA_TEMPLATE_FILE" > "$HPA_FILE"
        echo -e "   [+] Generated HPA for ${service^}"
    done
    echo ""
}

generate_services() {
    echo -e "${YELLOW}Generating Service configurations...${NC}"
    for service in "${SERVICES[@]}"; do
        SERVICE_DIR="$KUBERNETES_SERVICES_DIR/$service"
        mkdir -p "$SERVICE_DIR"

        SERVICE_FILE="$SERVICE_DIR/${service}-service.yaml"
        sed -e "s/{{service}}/$service/g" \
            -e "s/{{port}}/$DEFAULT_PORT/g" \
            -e "s/{{targetPort}}/$DEFAULT_TARGET_PORT/g" \
            "$SERVICE_TEMPLATE_FILE" > "$SERVICE_FILE"

        echo -e "   [+] Generated Service YAML for ${service^}"
    done
    echo ""
}

cleanup_old_resources() {
    echo -e "${YELLOW}Cleaning up old Kubernetes resources...${NC}"
    for service in "${SERVICES[@]}"; do
        echo -e "   [-] Cleaning resources for ${service^}..."

        kubectl delete deployment "${service}-deployment" >/dev/null 2>&1 || echo -e "       ${YELLOW}Deployment ${service}-deployment does not exist, skipping...${NC}"
        kubectl delete service "${service}-service" >/dev/null 2>&1 || echo -e "       ${YELLOW}Service ${service}-service does not exist, skipping...${NC}"
        kubectl delete hpa "${service}-hpa" >/dev/null 2>&1 || echo -e "       ${YELLOW}HPA ${service}-hpa does not exist, skipping...${NC}"
    done
    echo ""
}

deploy_kubernetes() {
    echo -e "${YELLOW}Deploying Kubernetes resources...${NC}"
    for service in "${SERVICES[@]}"; do
        echo -e "   [+] Deploying ${service^} resources..."

        DEPLOYMENT_FILE="$KUBERNETES_DEPLOYMENTS_DIR/$service/${service}-deployment.yaml"
        if [ -f "$DEPLOYMENT_FILE" ]; then
            sudo kubectl apply -f "$DEPLOYMENT_FILE" >/dev/null 2>&1
            echo -e "       ${GREEN}✔ Deployment applied.${NC}"
        else
            echo -e "       ${RED}✖ Deployment file for $service not found!${NC}"
        fi

        SERVICE_FILE="$KUBERNETES_SERVICES_DIR/$service/${service}-service.yaml"
        if [ -f "$SERVICE_FILE" ]; then
            sudo kubectl apply -f "$SERVICE_FILE" >/dev/null 2>&1
            echo -e "       ${GREEN}✔ Service applied.${NC}"
        else
            echo -e "       ${RED}✖ Service file for $service not found!${NC}"
        fi

        HPA_FILE="$KUBERNETES_HPA_DIR/${service}-hpa.yaml"
        if [ -f "$HPA_FILE" ]; then
            sudo kubectl apply -f "$HPA_FILE" >/dev/null 2>&1
            echo -e "       ${GREEN}✔ HPA applied.${NC}"
        else
            echo -e "       ${RED}✖ HPA file for $service not found!${NC}"
        fi

        echo -e "   [+] Restarting ${service^} deployment to pull the latest image..."
        sudo kubectl rollout restart deployment "${service}-deployment" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo -e "       ${GREEN}✔ Deployment restarted successfully.${NC}"
        else
            echo -e "       ${RED}✖ Failed to restart deployment for $service!${NC}"
        fi
    done

    echo -e "   [+] Applying Ingress configuration..."
    sudo kubectl apply -f "$KUBERNETES_INGRESS_FILE" >/dev/null 2>&1
    echo -e "       ${GREEN}✔ Ingress configuration applied.${NC}"
    echo ""
}

pull_updates() {
    echo -e "${YELLOW}Pulling latest updates from Git...${NC}"
    git pull >/dev/null 2>&1
    echo -e "   ${GREEN}✔ Latest updates pulled.${NC}"
    echo ""
}

print_repository_info() {
    echo -e "${YELLOW}   + GitHub Repository: https://github.com/julesreyn/area${NC}\n"
}

main() {
    print_header
    print_repository_info

    echo -e "${YELLOW}Starting deployment process...${NC}"
    pull_updates
    detect_services
    list_services
    build_and_push_images
    generate_hpa
    generate_services
    cleanup_old_resources
    deploy_kubernetes

    echo -e "${GREEN}Deployment completed successfully!${NC}"
}

main