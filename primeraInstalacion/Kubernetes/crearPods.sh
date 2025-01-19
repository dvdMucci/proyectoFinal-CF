#!/bin/bash
# Variables
REPO_URL="https://gitlab.com/training-devops-cf/avatares-devops.git"
LOCAL_DIR="avatares-devops"
NAMESPACE="avatares-devops"
API_IMAGE="dvdmucci/avatares-cf-api:latest"
WEB_IMAGE="dvdmucci/avatares-cf-web:latest"

# Paso 1: Clonar el repositorio
echo "Clonando el repositorio..."
git clone $REPO_URL $LOCAL_DIR || { echo "Error al clonar el repositorio"; exit 1; }

# Paso 2: Crear manifiesto Kubernetes con Deployments
echo "Creando manifiesto Kubernetes..."
cat <<EOF > deploy-avatares.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: $NAMESPACE
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: avatares-deployment
  namespace: $NAMESPACE
spec:
  replicas: 4
  selector:
    matchLabels:
      app: avatares
  template:
    metadata:
      labels:
        app: avatares
    spec:
      containers:
      - name: web
        image: $WEB_IMAGE
        ports:
        - containerPort: 5173
        env:
        - name: VITE_HOST
          value: "0.0.0.0"
        - name: VITE_PORT
          value: "5173"
      - name: api
        image: $API_IMAGE
        ports:
        - containerPort: 5000
        env:
        - name: FLASK_APP
          value: "app.py"
        - name: FLASK_ENV
          value: "development"
---
apiVersion: v1
kind: Service
metadata:
  name: avatares-service
  namespace: $NAMESPACE
spec:
  type: NodePort
  selector:
    app: avatares
  ports:
  - protocol: TCP
    name: api
    port: 5000
    nodePort: 30500
  - protocol: TCP
    name: web
    port: 5173
    nodePort: 30173
EOF

# Paso 3: Aplicar el manifiesto Kubernetes
echo "Aplicando manifiesto Kubernetes..."
kubectl delete -f deploy-avatares.yaml || true  # Eliminar si existe
kubectl apply -f deploy-avatares.yaml || { echo "Error al aplicar el manifiesto"; exit 1; }

# Paso 4: Verificar el estado del Deployment
echo "Esperando a que el Deployment esté listo..."
kubectl -n $NAMESPACE rollout status deployment/avatares-deployment

# Paso 5: Mostrar información de acceso
echo "Despliegue completado."
echo "La aplicación estará disponible en:"
echo "API: http://<NODE-IP>:5000"
echo "Web: http://<NODE-IP>:5173"
