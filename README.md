# React Application - CI/CD & Kubernetes Deployment

## **Objective**
The Objective of this project is to demonstrate the knowledge gained while deploying a simple React app implementing common industry best practices and automating the deployment process. The focus was not on developing a React App so a barebone project is used. After completion of deployment this project helped me understand core and basic concepts of DevOps and IaC along with security handling methods. There are lots of scope of improvement and will be improved with more handson attempt.

---

## **Overview**
This project sets up a **CI/CD pipeline** for deploying a React application to **Azure Kubernetes Service (AKS)** using **GitHub Actions, Docker, and Kubernetes**. The setup automates:
- **Building & pushing the React app** as a Docker image to Docker Hub.
- **Deploying the application** to an AKS cluster using Kubernetes manifests.
- **Exposing the application** via a LoadBalancer service.

---

## **Project Structure**
```
.github/workflows/ci-cd.yaml   # GitHub Actions CI/CD pipeline
k8s/deployment.yaml            # Kubernetes Deployment manifest
k8s/service.yaml               # Kubernetes Service manifest
k8s/service-account.yaml       # Kubernetes Service Account for GitHub Actions
k8s/service-account-secret.yaml # Secret for GitHub Actions Service Account
Dockerfile                     # Dockerfile for building the React app image
```

---

## **Secrets Needed in GitHub Secrets**
To ensure smooth CI/CD execution, the following **secrets must be stored** in GitHub repository settings (`Settings > Secrets and variables > Actions`):

| **Secret Name**             | **How to Generate** |
|----------------------------|-------------------|
| `DOCKER_USERNAME`          | Your **Docker Hub username**. |
| `DOCKER_PASSWORD`          | Generate **Docker Hub access token** from [Docker Hub Security Settings] |
| `AZURE_CLIENT_ID`          | Run `az ad sp create-for-rbac --name "github-actions-aks" --query "clientId" --output tsv`. |
| `AZURE_TENANT_ID`          | Run `az account show --query tenantId --output tsv`. |
| `AZURE_SUBSCRIPTION_ID`    | Run `az account show --query id --output tsv`. |
| `AKS_RESOURCE_GROUP`       | The name of your Azure resource group. |
| `AKS_CLUSTER_NAME`         | The name of your Azure Kubernetes Service (AKS) cluster. |

---

## **CI/CD Workflow with GitHub Actions**
The **GitHub Actions workflow (`.github/workflows/ci-cd.yaml`)** consists of two jobs:

### **1️⃣ Build & Push Docker Image**
- Runs on **every push to `main` or pull request**.
- **Builds the Docker image** from the `Dockerfile`.
- **Tags the image** with the commit SHA.
- **Pushes the image** to Docker Hub.

### **2️⃣ Deploy to AKS**
- Runs **after the build completes**.
- Authenticates with **Azure using OIDC**.
- Gets **AKS credentials**.
- **Updates the Kubernetes deployment** with the new image.

---

## **Kubernetes Deployment**
The app is deployed as a **Kubernetes Deployment** and exposed via a **LoadBalancer Service**.

### **Deployment (`k8s/deployment.yaml`)**
- Defines a **replicated pod (2 instances)** running the React app.
- Uses the **latest image** from Docker Hub.
- Exposes **port 80**.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: react-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: react-app
  template:
    metadata:
      labels:
        app: react-app
    spec:
      containers:
      - name: react-app
        image: ayushmukherjee221b/react-app:latest
        ports:
        - containerPort: 80
```

### **Service (`k8s/service.yaml`)**
- Exposes the application using a **LoadBalancer**.
- Maps **port 80 (external) to 80 (container)**.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: react-service
spec:
  type: LoadBalancer
  selector:
    app: react-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
```

---

## **Setting Up Kubernetes Service Account for GitHub Actions**

### **Service Account (`k8s/service-account.yaml`)**
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: github-actions-sa
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: github-actions-sa-binding
subjects:
- kind: ServiceAccount
  name: github-actions-sa
  namespace: kube-system
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
```

### **Secret for Service Account (`k8s/service-account-secret.yaml`)**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: github-actions-sa-secret
  namespace: kube-system
  annotations:
    kubernetes.io/service-account.name: github-actions-sa
type: kubernetes.io/service-account-token
```

---

## **Manual Deployment Steps (Without GitHub Actions)**
If needed, you can deploy the app manually:

### **1️⃣ Build & Push Docker Image**
```sh
docker build -t ayushmukherjee221b/react-app:latest .
docker push ayushmukherjee221b/react-app:latest
```

### **2️⃣ Apply Kubernetes Manifests**
```sh
kubectl apply -f k8s/service-account.yaml
kubectl apply -f k8s/service-account-secret.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

### **3️⃣ Check Deployment & Service**
```sh
kubectl get pods
kubectl get svc react-service
```

---

## **How CI/CD Was Set Up**
1. **GitHub Actions Workflow (`ci-cd.yaml`)** was created to automate build & deployment.
2. **Docker image** is built and pushed to **Docker Hub**.
3. **Kubernetes manifests** were written to deploy the app to **AKS**.
4. **GitHub Secrets** were added to store sensitive credentials.
5. **Service Account & RBAC were configured** to allow GitHub Actions to authenticate with Kubernetes.
6. **The workflow was tested & verified** by making a code change and checking the automated deployment.

---

## **Next Steps**
- Implement **Terraform** for infrastructure automation.
- Set up **monitoring with Prometheus & Grafana**.
- Improve **security & role-based access control (RBAC)** in Kubernetes.

🚀 **Enjoy automated deployments with CI/CD & Kubernetes!** 🚀

