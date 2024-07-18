## Create private key
```
openssl genrsa -out "private.key" 2048
```
## Create CSR
```
openssl req -new -key "private.key" -out "private.csr" -subj /CN=khant/O=devops (user - group)
```

## Get certificate key Using 'yq'
```
snap install yq
kubectl get csr khant  -o yaml | yq e '.status.certificate'
```

Get private key
```
cat private.key | base64 | tr -d '\n'
```

## Send scr to K8S
```
cat <<EOF | kubectl create -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: khant
spec:
  groups:
  - system:authenticated
  request: $(cat "private.csr" | base64 | tr -d '\n')
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF
```

## Approve
```
kubectl certificate approve "khant"
```

## RBAC
```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: readonly
rules:
- apiGroups: [""]
  resources: ["*"]
  verbs: ["get", "watch", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: readonly-binding
subjects:
- kind: User
  name: khant
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: readonly
  apiGroup: rbac.authorization.k8s.io
```

## Note:
Using KUBECONFIG=/etc/kubernetes/admin.conf to apply rbac file