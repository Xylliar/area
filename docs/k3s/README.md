# Area - Microservices Automation and Orchestration with K3s

## Introduction

In this guide, we will cover how **Area** utilizes K3s for microservices orchestration and automation. **K3s** is a lightweight Kubernetes distribution that simplifies the management of containerized applications by orchestrating Docker images based on system load and resource requirements. With its minimal footprint, K3s is ideal for environments where resources are constrained, making it an excellent choice for both small-scale and production deployments.

## Prerequisites

Before installing K3s, ensure you have access to at least two nodes (either virtual or physical) running a Debian-based operating system. The minimum requirements for each node are as follows:

- **vCPUs**: 2 (1 vcpu + 1 vcpu shared is possible)
- **RAM**: 2 GB
- **Disk space**: 8 GB

At least one node should act as the **master** node, responsible for managing the other **worker** nodes.

## Installing K3s

To begin the installation, follow these steps:

### Step 1: Installing K3s on the Master Node

On the **master node**, run the following command to install K3s:

```bash
curl -sfL https://get.k3s.io | sh -
```

After initiating the command, K3s will download and install the required components. You should see output similar to the following:

```bash
[INFO]  Finding release for channel stable
[INFO]  Using v1.30.4+k3s1 as release
[INFO]  Downloading hash https://github.com/k3s-io/k3s/releases/download/v1.30.4+k3s1/sha256sum-amd64.txt
[INFO]  Downloading binary https://github.com/k3s-io/k3s/releases/download/v1.30.4+k3s1/k3s
[INFO]  Verifying binary download
[INFO]  Installing k3s to /usr/local/bin/k3s
[INFO]  Skipping installation of SELinux RPM
[INFO]  Skipping /usr/local/bin/kubectl symlink to k3s, already exists
[INFO]  Creating /usr/local/bin/crictl symlink to k3s
[INFO]  Creating /usr/local/bin/ctr symlink to k3s
[INFO]  Creating killall script /usr/local/bin/k3s-killall.sh
[INFO]  Creating uninstall script /usr/local/bin/k3s-uninstall.sh
[INFO]  env: Creating environment file /etc/systemd/system/k3s.service.env
[INFO]  systemd: Creating service file /etc/systemd/system/k3s.service
[INFO]  systemd: Enabling k3s unit
Created symlink /etc/systemd/system/multi-user.target.wants/k3s.service → /etc/systemd/system/k3s.service.
[INFO]  systemd: Starting k3s
```

### Step 2: Verifying K3s Installation

Once the installation is complete, you can check if the K3s service is running by executing:

```bash
sudo systemctl status k3s
```

You should see the service listed as `active (running)`:

```bash
● k3s.service - Lightweight Kubernetes
     Loaded: loaded (/etc/systemd/system/k3s.service; enabled; vendor preset: enabled)
     Active: active (running) since Sat 2024-09-21 16:52:09 UTC; 7h ago
       Docs: https://k3s.io
    Process: 114755 ExecStartPre=/bin/sh -xc ! /usr/bin/systemctl is-enabled --quiet nm-cloud-setup.service 2>/dev/null (code=exited, status=0/SUCCESS)
    Main PID: 114759 (k3s-server)
```

At this point, your master node is running K3s and ready to manage other worker nodes.

### Step 3: Retrieving the Cluster Join Token

To allow worker nodes to join the cluster, you need the **node token** from the master node. Retrieve it by running the following command:

```bash
sudo cat /var/lib/rancher/k3s/server/node-token
```

This will output a unique token. Copy it for use in the next step.

### Step 4: Joining Worker Nodes to the Cluster

On each worker node, run the following command to join the cluster, replacing `<MASTER_IP>` with the master node’s IP address and `<NODE_TOKEN>` with the token you copied:

```bash
curl -sfL https://get.k3s.io | K3S_URL=https://<MASTER_IP>:6443 K3S_TOKEN=<NODE_TOKEN> sh -
```

This command will install K3s on the worker node and automatically join it to the master node’s cluster.

### Step 5: Verifying Cluster Nodes

After all worker nodes have joined the cluster, verify their status on the **master node** by running:

```bash
sudo k3s kubectl get nodes
```

You should see a list of nodes that includes both the master and worker nodes, each with their respective statuses.

## Deploying Area on K3s

With K3s installed and the cluster set up, you can now deploy Area to the cluster. To do this, follow these steps:

### Step 1: Cloning the Area Repository
> **Warning:** Deprecated, going to be handled with gh actions

On your local machine, clone the Area repository from GitHub:

```bash
git clone https://github.com/EpitechPromo2027/B-DEV-500-PAR-5-1-area-tom.facon
```

### Step 2: Deploying Area to the Cluster

Give execute permissions to the deployment script:

```bash
chmod +x scripts/deploy.sh
```

Then run the deployment script:

```bash
./scripts/deploy.sh
```

This script will create the necessary Kubernetes resources to deploy Area to the cluster.