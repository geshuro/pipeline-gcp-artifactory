#!/bin/bash

# Script para escanear imagen Docker en busca de vulnerabilidades usando GCP Artifact Registry

set -e

echo "🔍 Escaneando imagen Docker en busca de vulnerabilidades..."

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

echo "📋 Configuración de escaneo:"
echo "  - Imagen: $IMAGE_TAG"

# Autenticar con GCP
echo "🔐 Autenticando con GCP..."
gcloud auth activate-service-account --key-file="$GCP_KEY_FILE"

# Obtener el digest de la imagen
echo "🔍 Obteniendo digest de la imagen..."
IMAGE_DIGEST=$(gcloud artifacts docker images describe "$IMAGE_TAG" --format='get(image_summary.digest)')

if [ -z "$IMAGE_DIGEST" ]; then
    echo "❌ Error: No se pudo obtener el digest de la imagen"
    exit 1
fi

echo "📋 Digest de la imagen: $IMAGE_DIGEST"

# Esperar a que el análisis de vulnerabilidades termine
echo "⏳ Esperando el análisis de la imagen... Esto puede tardar unos minutos."
TIMEOUT=600  # 10 minutos
ELAPSED=0
INTERVAL=30  # Verificar cada 30 segundos

while [ $ELAPSED -lt $TIMEOUT ]; do
    echo "⏱️ Verificando análisis... (${ELAPSED}s/${TIMEOUT}s)"
    
    # Verificar si el análisis está completo
    REPORT=$(gcloud artifacts vulnerability-summary list \
        --project="$GCP_PROJECT_ID" \
        --location="$ARTIFACT_REGISTRY_LOCATION" \
        --repository="$ARTIFACT_REGISTRY_REPO" \
        --image="$IMAGE_DIGEST" \
        --format=json 2>/dev/null || echo "[]")
    
    # El análisis está completo si el reporte no está vacío
    if [ "$REPORT" != "[]" ]; then
        echo "✅ Análisis completado"
        break
    fi
    
    sleep $INTERVAL
    ELAPSED=$((ELAPSED + INTERVAL))
done

if [ $ELAPSED -ge $TIMEOUT ]; then
    echo "❌ Error: Timeout esperando el análisis de vulnerabilidades"
    exit 1
fi

# Obtener el resumen de vulnerabilidades
echo "📊 Obteniendo resumen de vulnerabilidades..."
VULNERABILITY_REPORT=$(gcloud artifacts vulnerability-summary list \
    --project="$GCP_PROJECT_ID" \
    --location="$ARTIFACT_REGISTRY_LOCATION" \
    --repository="$ARTIFACT_REGISTRY_REPO" \
    --image="$IMAGE_DIGEST" \
    --format=json)

echo "📋 Reporte de vulnerabilidades:"
echo "$VULNERABILITY_REPORT"

# Verificar vulnerabilidades críticas usando jq si está disponible
if command -v jq &> /dev/null; then
    echo "🔍 Verificando vulnerabilidades críticas..."
    CRITICAL_COUNT=$(echo "$VULNERABILITY_REPORT" | jq -r '.[] | select(.severity == "CRITICAL") | .count // 0' | awk '{sum += $1} END {print sum}')
    
    if [ "$CRITICAL_COUNT" -gt 0 ]; then
        echo "❌ Se encontraron $CRITICAL_COUNT vulnerabilidades CRÍTICAS"
        echo "🚫 Pipeline detenido debido a vulnerabilidades críticas"
        exit 1
    else
        echo "✅ No se encontraron vulnerabilidades críticas"
    fi
else
    echo "⚠️ jq no está instalado, verificando vulnerabilidades manualmente..."
    if echo "$VULNERABILITY_REPORT" | grep -q '"severity": "CRITICAL"'; then
        echo "❌ Se encontraron vulnerabilidades CRÍTICAS"
        echo "🚫 Pipeline detenido debido a vulnerabilidades críticas"
        exit 1
    else
        echo "✅ No se encontraron vulnerabilidades críticas"
    fi
fi

echo "✅ Escaneo de vulnerabilidades completado exitosamente" 