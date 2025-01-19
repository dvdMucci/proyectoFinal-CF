#!/bin/bash

# For AMD64 / x86_64
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo cp ./kind /usr/local/bin/kind
rm -rf kind

echo "Creando config de cluster..."
cat <<EOF > config.yml
# 2 node (1 workers) cluster config
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  image: kindest/node:v1.28.0
- role: worker
  image: kindest/node:v1.28.0
  extraPortMappings:
  - containerPort: 30173
    hostPort: 5173
  - containerPort: 30500
    hostPort: 5000
EOF

# Crear cluster
echo "Creando cluster..."
kind create cluster --config=config.yml

# Verificar si kubectl está instalado
if command -v kubectl &> /dev/null; then
    echo "kubectl ya está instalado. Versión: $(kubectl version --client --short)"
else
    echo "kubectl no está instalado. Procediendo con la instalación..."
    
    # Determinar la arquitectura del sistema
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) ARCH="amd64" ;;
        armv7l) ARCH="arm" ;;
        aarch64) ARCH="arm64" ;;
        *) echo "Arquitectura no soportada: $ARCH"; exit 1 ;;
    esac

    # Descargar kubectl
    URL="https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/$ARCH/kubectl"
    curl -LO "$URL"
    if [ $? -ne 0 ]; then
        echo "Error al descargar kubectl. Verifica tu conexión a Internet."
        exit 1
    fi

    # Mover el binario a /usr/local/bin y hacerlo ejecutable
    sudo mv kubectl /usr/local/bin/
    sudo chmod +x /usr/local/bin/kubectl

    # Verificar la instalación
    if command -v kubectl &> /dev/null; then
        echo "kubectl se instaló correctamente. Versión: $(kubectl version --client --short)"
    else
        echo "Ocurrió un error durante la instalación de kubectl."
        exit 1
    fi
fi

# Muestra info de cluster
kubectl cluster-info