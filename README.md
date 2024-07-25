# AWS-Kubernetes
Set host name for instance
```
sudo hostnamectl set-hostname <HOSTNAME>
```


## Set up LB On LB instances
Using this content
```
stream {
    upstream kubernetes {
        server 13.212.240.104:6443 max_fails=3 fail_timeout=30s;
    }
server {
        listen 6443;
        proxy_pass kubernetes;
    }
}
```


```
cd /etc/nginx/
mkdir k8s-lb.d
vi apiserver.conf
```
After that, include apiserver.conf in nginx.conf

## Install Docker, Containerd and Kubeadm, Kubelet, Kubectl on nodes

## Init cluster
```
kubeadm init --control-plane-endpoint=apiserver.lb:6443 --upload-certs --pod-network-cidr=10.0.0.0/8
```

## Install CNI - need to enable coredns
```
helm repo add cilium https://helm.cilium.io/
helm install cilium cilium/cilium --version 1.11.6 --namespace kube-system
```

### 1. Join Master
```
kubeadm join apiserver.lb:6443 --token okkjo9.a5n40m3xs4xojah4 \
	--discovery-token-ca-cert-hash sha256:f8a64eabcb9154f31ab95e825639ef37f68584acdf339f85f374722759f89303 \
	--control-plane --certificate-key c304ae18549cddc0c247fccd27e6fe833a886cec0357e03b4c5208ab22546088
```
### 2. Join worker
```
kubeadm join apiserver.lb:6443 --token okkjo9.a5n40m3xs4xojah4 \
	--discovery-token-ca-cert-hash sha256:f8a64eabcb9154f31ab95e825639ef37f68584acdf339f85f374722759f89303
```
### 3. Re-generate token
```
kubeadm create token
```
### 4. Re-generate discovery token ca cert
```
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | \
openssl dgst -sha256 -hex | sed 's/^.* //'
```
### 5. Re-generate certificate key
```
kubeadm init phase upload-certs --upload-certs
```

## Note
Need to open port 6443 on inbound rules