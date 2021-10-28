# kubernetes
## ToDo:
1. https://kubernetes.io/docs/setup/production-environment/container-runtimes/#cri-o
    - Update configuration to use pillar to specify versions for all packages, kubelet, kubeadm, kubectl, cri-o as well as repository files

## Calico Installation
1. ```sudo kubeadm init --pod-network-cidr=192.168.0.0/16```
2. ```mkdir -p $HOME/.kube```
3. ```sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config```
4. ```sudo chown $(id -u):$(id -g) $HOME/.kube/config```
5. ```kubectl create -f https://docs.projectcalico.org/manifests/tigera-operator.yaml```
6. ```kubectl create -f https://docs.projectcalico.org/manifests/custom-resources.yaml```
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

kubeadm join 192.168.110.170:6443 --token fb52pu.yja2q3x798htqh77 \
  --discovery-token-ca-cert-hash sha256:40454599060e51ac2c66781218ceb4a77369333d94f4f8556a82d1715af9f077
```

## Label Worker Nodes:
```
kubectl label nodes k8swnode4dc1.jittersolutions.com node-role.kubernetes.io/worker=
kubectl label nodes k8swnode5dc1.jittersolutions.com node-role.kubernetes.io/worker=
kubectl label nodes k8swnode6dc1.jittersolutions.com node-role.kubernetes.io/worker=
```