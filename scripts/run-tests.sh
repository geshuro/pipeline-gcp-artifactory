#!/bin/bash

# Script para ejecutar pruebas unitarias de Go

set -e

echo "🧪 Ejecutando pruebas unitarias..."

# Verificar que Go esté instalado
if ! command -v go &> /dev/null; then
    echo "❌ Error: Go no está instalado"
    exit 1
fi

# Verificar que go.mod existe
if [ ! -f "go.mod" ]; then
    echo "❌ Error: go.mod no encontrado. Ejecutar desde el directorio raíz del proyecto"
    exit 1
fi

# Instalar dependencias y generar go.sum si no existe
echo "📦 Instalando dependencias de Go..."
go mod tidy

# Ejecutar pruebas con verbose
echo "🔍 Ejecutando pruebas..."
go test -v ./...

# Ejecutar pruebas con cobertura
echo "📊 Generando reporte de cobertura..."
go test -v -cover ./...

echo "✅ Pruebas completadas exitosamente" 