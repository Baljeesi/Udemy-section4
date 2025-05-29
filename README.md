# 🚀 Deploy React App Using MicroK8s on AWS EC2

This guide walks you through deploying a React application using MicroK8s (a lightweight Kubernetes distribution) on an AWS EC2 instance.


## 📦 Setting Up MicroK8s on AWS EC2

We are using **MicroK8s** as a lightweight alternative to full Kubernetes for this project.

### 🛠 Install MicroK8s

```bash
sudo snap install microk8s --classic
sudo usermod -a -G microk8s ubuntu
mkdir ~/.kube
sudo microk8s kubectl config view --raw > ~/.kube/config

# Sign out and sign in again
sudo su - root
sudo su - ubuntu

microk8s kubectl get all --all-namespaces
alias kubectl="microk8s kubectl"
````

---

## 🚧 Kubernetes Deployment of React App

We will create the following manifest files:

* `react-deployment.yaml`
* `react-service.yaml`
* `react-ingress.yaml`

---

## ✅ Step 1: Create Namespace

```bash
kubectl create ns react-microk8s
```

---

## 📄 Step 2: Deployment Manifest

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: react-deployment
  namespace: react-microk8s
  labels:
    app: react-demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: react-demo
  template:
    metadata:
      labels:
        app: react-demo
    spec:
      containers:
        - name: react-demo
          image: sagarkakkalasworld/kubernetes-deployment
          ports:
            - containerPort: 80
```

If using a specific tag:

```yaml
image: sagarkakkalasworld/kubernetes-deployment:1.2
```

Apply the deployment:

```bash
kubectl apply -f react-deployment.yaml
kubectl get pods -n react-microk8s
```

---

## 📄 Step 3: Service Manifest

```yaml
apiVersion: v1
kind: Service
metadata:
  name: react-service
  namespace: react-microk8s
spec:
  type: NodePort  # remove this if using domain
  selector:
    app: react-demo
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
      nodePort: 32720  # remove this if using domain
```

Apply the service:

```bash
kubectl apply -f react-service.yaml
kubectl get svc -n react-microk8s
```

Test service internally:

```bash
curl http://<CLUSTER-IP>:80
```

---

## 🌐 Step 4: Enable and Configure Ingress

```bash
microk8s enable ingress
kubectl get all --all-namespaces
```

---

## 📄 Step 5: Ingress Manifest

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: react-ingress
  namespace: react-microk8s
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
    - host: sagarkakkala.shop
      http:
        paths:
          - pathType: Prefix
            path: /
            backend:
              service:
                name: react-service
                port:
                  number: 80
```

Apply the ingress:

```bash
kubectl apply -f react-ingress.yaml
kubectl get ingress -n react-microk8s
```

Test site inside server:

```bash
curl http://sagarkakkala.shop
```

---

## 🌍 Domain and Port Access

1. Allow port **80** in EC2 Security Group.
2. Copy your AWS EC2 **Public IP**.
3. Go to GoDaddy Dashboard → My Products → Domain → DNS.
4. Edit the **A Record** and set your EC2 public IP.
5. Access your app at: **[http://sagarkakkala.shop](http://sagarkakkala.shop)**

**Note:** EC2 public IP changes after instance restart. To make it static, use **Elastic IP** (may incur cost).

---

## 🎥 Build & Deploy Complete Series

👉 [Visit Sagar Kakkala's World](https://www.sagarkakkalasworld.com)

---

## 🤝 Connect with Me

* 📺 [YouTube - Sagar Kakkala's World](https://www.youtube.com/@SagarKakkalasWorld)
* 💼 [LinkedIn - Sagar Kakkala](https://www.linkedin.com/in/sagar-kakkala)

---

🖊 *Feedback, queries, and suggestions are welcome in the comments!*
