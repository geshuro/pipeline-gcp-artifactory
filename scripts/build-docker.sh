#!/bin/bash

# Script para construir y subir imagen Docker a GCP Artifact Registry

set -e

echo "🐳 Construyendo y subiendo imagen Docker..."

# Verificar variables de entorno requeridas
if [ -z "$GCP_PROJECT_ID" ]; then
    echo "❌ Error: GCP_PROJECT_ID no está definido"
    exit 1
fi

if [ -z "$ARTIFACT_REGISTRY_LOCATION" ]; then
    echo "❌ Error: ARTIFACT_REGISTRY_LOCATION no está definido"
    exit 1
fi

if [ -z "$ARTIFACT_REGISTRY_REPO" ]; then
    echo "❌ Error: ARTIFACT_REGISTRY_REPO no está definido"
    exit 1
fi

if [ -z "$APP_NAME" ]; then
    echo "❌ Error: APP_NAME no está definido"
    exit 1
fi

if [ -z "$BUILD_NUMBER" ]; then
    echo "❌ Error: BUILD_NUMBER no está definido"
    exit 1
fi

if [ -z "$GCP_KEY_FILE" ]; then
    echo "❌ Error: GCP_KEY_FILE no está definido"
    exit 1
fi

# Construir la URL completa de la imagen
IMAGE_URL="${ARTIFACT_REGISTRY_LOCATION}-docker.pkg.dev/${GCP_PROJECT_ID}/${ARTIFACT_REGISTRY_REPO}/${APP_NAME}"
IMAGE_TAG="${IMAGE_URL}:${BUILD_NUMBER}"

echo "📋 Configuración:"
echo "  - Proyecto GCP: $GCP_PROJECT_ID"
echo "  - Ubicación: $ARTIFACT_REGISTRY_LOCATION"
echo "  - Repositorio: $ARTIFACT_REGISTRY_REPO"
echo "  - Aplicación: $APP_NAME"
echo "  - Build Number: $BUILD_NUMBER"
echo "  - Imagen: $IMAGE_TAG"

# Verificar que Docker esté instalado
if ! command -v docker &> /dev/null; then
    echo "❌ Error: Docker no está instalado"
    exit 1
fi

# Verificar que Dockerfile existe
if [ ! -f "Dockerfile" ]; then
    echo "❌ Error: Dockerfile no encontrado"
    exit 1
fi

# Autenticar con GCP Artifact Registry
echo "🔐 Autenticando con GCP..."
gcloud auth activate-service-account --key-file="$GCP_KEY_FILE"
gcloud auth configure-docker "${ARTIFACT_REGISTRY_LOCATION}-docker.pkg.dev"

# Construir la imagen Docker
echo "🔨 Construyendo imagen Docker..."
docker build -t "$IMAGE_TAG" .

# Subir la imagen a Artifact Registry
echo "📤 Subiendo imagen a Artifact Registry..."
docker push "$IMAGE_TAG"

echo "✅ Imagen Docker construida y subida exitosamente: $IMAGE_TAG" 