# kubernetes
## ToDo:
1. https://kubernetes.io/docs/setup/production-environment/container-runtimes/#cri-o
    - Update configuration to use pillar to specify versions for all packages, kubelet, kubeadm, kubectl, cri-o as well as repository files

## Calico Installation
1. ```kubeadm config images pull```
2. ```sudo kubeadm init --pod-network-cidr=10.50.0.0/16```
3. ```mkdir -p $HOME/.kube```
4. ```sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config```
5. ```sudo chown $(id -u):$(id -g) $HOME/.kube/config```
6. ```kubectl create -f https://docs.projectcalico.org/manifests/tigera-operator.yaml```
7. ```kubectl create -f https://docs.projectcalico.org/manifests/custom-resources.yaml```

```
# This section includes base Calico installation configuration.
# For more information, see: https://docs.projectcalico.org/v3.20/reference/installation/api#operator.tigera.io/v1.Installation
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  # Configures Calico networking.
  calicoNetwork:
    # Note: The ipPools section cannot be modified post-install.
    ipPools:
    - blockSize: 26
      cidr: 10.50.0.0/16
      encapsulation: VXLANCrossSubnet
      natOutgoing: Enabled
      nodeSelector: all()
---
# This section configures the Calico API server.
# For more information, see: https://docs.projectcalico.org/v3.20/reference/installation/api#operator.tigera.io/v1.APIServer
apiVersion: operator.tigera.io/v1
kind: APIServer 
metadata: 
  name: default 
spec: {}

```
    - Before creating this manifest, read its contents and make sure its settings are correct for your environment. For example, you may need to change the default IP pool CIDR to match your pod network CIDR.
7. ```watch kubectl get pods -n calico-system```
8. ```kubectl taint nodes --all node-role.kubernetes.io/master-```
9. ```kubectl get nodes -o wide```

## kubeadm output
```
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.110.190:6443 --token 2nwc4e.xnhcry50h2ab8bq3 \
        --discovery-token-ca-cert-hash sha256:64d446990784bb78c5c97d8a17f436670d7d6db13ac92f06a8a01c4b2cc5acbd
```

## Label Worker Nodes:
```
kubectl label nodes k8swnode1dc1.jittersolutions.com node-role.kubernetes.io/worker=
kubectl label nodes k8swnode2dc1.jittersolutions.com node-role.kubernetes.io/worker=
kubectl label nodes k8swnode3dc1.jittersolutions.com node-role.kubernetes.io/worker=
```