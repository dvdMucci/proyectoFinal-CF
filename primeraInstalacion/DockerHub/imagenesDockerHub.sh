#!/bin/bash

# Variables
REPO_URL="https://gitlab.com/training-devops-cf/avatares-devops.git"
LOCAL_DIR="avatares-devops"
API_IMAGE="avatarescf-api"
WEB_IMAGE="avatarescf-web"
DOCKERUSER=$DOCKERUSER
DOCKERPASS=$DOCKERPASS

# Función para crear el Dockerfile para la API
create_api_dockerfile() {
  echo "Creando Dockerfile para la API..."
  cat <<EOF > api/Dockerfile
# Usar Python 3.10 como base
FROM python:3.10-slim

# Establecer el directorio de trabajo
WORKDIR /api

# Copiar los archivos de la API
COPY . .

# Instalar las dependencias
RUN pip install --no-cache-dir -r requirements.txt

# Establecer variables de entorno necesarias para Flask
ENV FLASK_APP=app.py
ENV FLASK_ENV=development

# Exponer el puerto necesario
EXPOSE 5000

# Comando de inicio
CMD ["flask", "run", "--host=0.0.0.0", "--port=5000"]
EOF
}

# Función para crear el Dockerfile para el frontend
create_web_dockerfile() {
  echo "Creando Dockerfile para el frontend..."
  cat <<EOF > web/Dockerfile
# Usar Node.js 18 como base
FROM node:18

# Establecer el directorio de trabajo
WORKDIR /web

# Copiar solo package.json y package-lock.json para instalar dependencias
COPY package*.json /web

# Instalar las dependencias
RUN npm install

# Copiar el resto de los archivos de la web
COPY . /web

# Establecer variables de entorno necesarias para Vite
ENV VITE_HOST=0.0.0.0
ENV VITE_PORT=5173

# Exponer el puerto necesario
EXPOSE 5173

# Comando de inicio
CMD ["npm", "run", "dev"]
EOF
}

# Clonar el repositorio
echo "Clonando el repositorio..."
git clone $REPO_URL $LOCAL_DIR

# Navegar al directorio
cd $LOCAL_DIR || { echo "Error al acceder al directorio del repositorio"; exit 1; }

# Ruta al archivo vite.config.js
FILE="./web/vite.config.js"

# Verificar si el archivo existe
if [[ -f "$FILE" ]]; then
  # Reemplazar "target: 'http://api'," por "target: 'http://api:5000',"
  sed -i "s|target: 'http://api',|target: 'http://127.0.0.1:5000',|g" "$FILE"
  echo "El archivo $FILE ha sido modificado correctamente."
else
  echo "El archivo $FILE no existe. Verifica la ruta e inténtalo de nuevo."
fi

# Crear los Dockerfiles y el archivo docker-compose.yml
create_api_dockerfile
create_web_dockerfile

# Construir las imágenes Docker localmente
echo "Construyendo las imágenes Docker..."
docker build -t $DOCKERUSER/$API_IMAGE ./api || { echo "Error al construir la imagen de la API"; exit 1; }
docker build -t $DOCKERUSER/$WEB_IMAGE ./web || { echo "Error al construir la imagen del frontend"; exit 1; }

# Login a Docker Hub
echo "Autenticando en Docker Hub..."
docker login -u "$DOCKERUSER" -p "$DOCKERPASS"
if [ $? -ne 0 ]; then
    echo "Error: Falló la autenticación en Docker Hub."
    exit 1
fi

# Etiquetar y subir la imagen API
echo "Etiquetando y subiendo $API_IMAGE..."
docker tag "$API_IMAGE" "$DOCKERUSER/$API_IMAGE:latest"
docker push "$DOCKERUSER/$API_IMAGE"
if [ $? -ne 0 ]; then
    echo "Error: Falló la subida de la imagen $API_IMAGE."
    exit 1
fi

# Etiquetar y subir la imagen WEB
echo "Etiquetando y subiendo $WEB_IMAGE..."
docker tag "$WEB_IMAGE" "$DOCKERUSER/$WEB_IMAGE:latest"
docker push "$DOCKERUSER/$WEB_IMAGE"
if [ $? -ne 0 ]; then
    echo "Error: Falló la subida de la imagen $WEB_IMAGE."
    exit 1
fi

echo "Imágenes subidas exitosamente a Docker Hub."

