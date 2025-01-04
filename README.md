# Grass

My own cloud

###

```mermaid

graph TB
    subgraph External_Access["External Access"]
        direction TB
        subgraph API_Access["API Access"]
            VIP["Talos Virtual IP\n(Built-in HA for API)"]
        end
    end

    subgraph Network["Network Layer"]
        CIL["Cilium Multi-Layer Networking\n- L3/L4: IP & Port based routing\n- L7: Application aware routing\n- CNI: Pod networking\n- Load Balancing\n- Network Policies"]
    end

    subgraph Control_Plane["Control Plane"]
        CP["Multiple Control Plane Nodes"]
    end

    subgraph Worker_Nodes["Worker Nodes"]
        subgraph Worker_Group_1["Application Workloads"]
            WG1["Multiple General\nPurpose Nodes"]
        end

        subgraph Worker_Group_2["Storage Workloads"]
            WG2["Multiple Storage\nOptimized Nodes"]
        end
    end

    subgraph Storage["Storage Layer"]
        S1["Distributed Storage\n(e.g., Rook/Ceph)"]
    end

    %% Connections
    VIP --> CP

    CP -.-> CIL
    WG1 -.-> CIL
    WG2 -.-> CIL

    WG2 --- S1

    %% External traffic flow
    Traffic["External Traffic"] --> CIL

```

### local docker setup

we use the `cp-base.yaml` patch as base configuration patch when creating and we also turn o k8s node ready check as this will fail as we are turning of CNI

    talosctl cluster create --config-patch @cp-base.yaml --skip-k8s-node-readiness-check

then we only need to install cilium

    helm install cilium \
    cilium/cilium \
    --version 1.16.5 \
    --namespace kube-system \
    --set ipam.mode=kubernetes \
    --set kubeProxyReplacement=false \
    --set securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" \
    --set securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" \
    --set cgroup.autoMount.enabled=false \
    --set cgroup.hostRoot=/sys/fs/cgroup \
    --set k8sServiceHost=localhost \
    --set k8sServicePort=7445

check if pods are running:

    kubectl -n kube-system get pods
