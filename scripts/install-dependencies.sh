#!/bin/bash

# Script para instalar dependencias necesarias para el pipeline
# Incluye la instalación de Google Cloud SDK

set -e

echo "🔧 Instalando dependencias..."

# Detectar el sistema operativo
OS=$(uname -s)

echo "📋 Sistema operativo detectado: $OS"

case $OS in
    "Linux")
        echo "🐧 Instalando Google Cloud SDK en Linux..."
        
        # Agregar el repositorio de Google Cloud SDK
        echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
        
        # Importar la clave GPG
        curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
        
        # Actualizar e instalar gcloud
        sudo apt-get update
        sudo apt-get install -y google-cloud-cli
        
        # Verificar la instalación
        gcloud version
        ;;
        
    "Darwin")
        echo "🍎 Instalando Google Cloud SDK en macOS..."
        
        # Instalar usando Homebrew si está disponible
        if command -v brew &> /dev/null; then
            echo "🍺 Usando Homebrew para instalar gcloud..."
            brew install --cask google-cloud-sdk
        else
            echo "📥 Instalación manual en macOS..."
            curl https://sdk.cloud.google.com | bash
            exec -l $SHELL
        fi
        
        # Verificar la instalación
        gcloud version
        ;;
        
    *)
        echo "🌐 Instalación genérica usando el instalador oficial..."
        
        # Descargar e instalar Google Cloud SDK
        curl https://sdk.cloud.google.com | bash
        exec -l $SHELL
        
        # Verificar la instalación
        gcloud version
        ;;
esac

# Configurar gcloud para el proyecto
if [ ! -z "$GCP_PROJECT_ID" ]; then
    echo "⚙️ Configurando gcloud para el proyecto: $GCP_PROJECT_ID"
    gcloud config set project "$GCP_PROJECT_ID"
else
    echo "⚠️ Variable GCP_PROJECT_ID no definida, saltando configuración del proyecto"
fi

echo "✅ Instalación de dependencias completada" 