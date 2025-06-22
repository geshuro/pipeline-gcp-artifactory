#!/bin/bash

# Script para desplegar la aplicación en Google Cloud Run

set -e

echo "🚀 Desplegando aplicación en Google Cloud Run..."

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

echo "📋 Configuración de despliegue:"
echo "  - Proyecto GCP: $GCP_PROJECT_ID"
echo "  - Región: $ARTIFACT_REGISTRY_LOCATION"
echo "  - Servicio: $APP_NAME"
echo "  - Imagen: $IMAGE_TAG"

# Autenticar con GCP
echo "🔐 Autenticando con GCP..."
gcloud auth activate-service-account --key-file="$GCP_KEY_FILE"

# Verificar que el servicio existe
echo "🔍 Verificando estado del servicio..."
if gcloud run services describe "$APP_NAME" --region="$ARTIFACT_REGISTRY_LOCATION" --project="$GCP_PROJECT_ID" &>/dev/null; then
    echo "📋 Servicio existente encontrado, actualizando..."
    UPDATE_MODE="update"
else
    echo "🆕 Servicio no encontrado, creando nuevo servicio..."
    UPDATE_MODE="create"
fi

# Desplegar en Cloud Run
echo "🚀 Desplegando en Cloud Run..."
gcloud run deploy "$APP_NAME" \
    --image "$IMAGE_TAG" \
    --platform managed \
    --region "$ARTIFACT_REGISTRY_LOCATION" \
    --allow-unauthenticated \
    --project "$GCP_PROJECT_ID" \
    --port 8080 \
    --memory 512Mi \
    --cpu 1 \
    --max-instances 10 \
    --timeout 300

# Obtener la URL del servicio
echo "🔗 Obteniendo URL del servicio..."
SERVICE_URL=$(gcloud run services describe "$APP_NAME" \
    --region="$ARTIFACT_REGISTRY_LOCATION" \
    --project="$GCP_PROJECT_ID" \
    --format='get(status.url)')

echo "✅ Despliegue completado exitosamente"
echo "🌐 URL del servicio: $SERVICE_URL"

# Probar el endpoint de salud
echo "🧪 Probando endpoint de salud..."
sleep 10  # Esperar a que el servicio esté completamente listo

if curl -f "$SERVICE_URL/health" &>/dev/null; then
    echo "✅ Endpoint de salud responde correctamente"
else
    echo "⚠️ Endpoint de salud no responde, pero el despliegue fue exitoso"
fi

echo "🎉 Despliegue completado. La aplicación está disponible en: $SERVICE_URL" 