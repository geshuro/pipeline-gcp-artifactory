# Makefile para el pipeline de CI/CD
# Este Makefile orquesta los scripts bash para automatizar el proceso de construcción, pruebas y despliegue

# Variables de configuración
GCP_PROJECT_ID ?= tu-proyecto-gcp
ARTIFACT_REGISTRY_LOCATION ?= us-central1
ARTIFACT_REGISTRY_REPO ?= tu-repo-docker
APP_NAME ?= go-api-demo
BUILD_NUMBER ?= $(shell date +%Y%m%d-%H%M%S)
GCP_CREDENTIALS_ID ?= gcp-service-account

# Construir la URL completa de la imagen
IMAGE_URL = $(ARTIFACT_REGISTRY_LOCATION)-docker.pkg.dev/$(GCP_PROJECT_ID)/$(ARTIFACT_REGISTRY_REPO)/$(APP_NAME)
IMAGE_TAG = $(IMAGE_URL):$(BUILD_NUMBER)

# Colores para output
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
BLUE = \033[0;34m
NC = \033[0m # No Color

# Target por defecto
.DEFAULT_GOAL := help

# Ayuda
.PHONY: help
help: ## Mostrar esta ayuda
	@echo "$(BLUE)Comandos disponibles:$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Variables de entorno:$(NC)"
	@echo "  GCP_PROJECT_ID              = $(GCP_PROJECT_ID)"
	@echo "  ARTIFACT_REGISTRY_LOCATION  = $(ARTIFACT_REGISTRY_LOCATION)"
	@echo "  ARTIFACT_REGISTRY_REPO      = $(ARTIFACT_REGISTRY_REPO)"
	@echo "  APP_NAME                    = $(APP_NAME)"
	@echo "  BUILD_NUMBER                = $(BUILD_NUMBER)"
	@echo "  GCP_CREDENTIALS_ID          = $(GCP_CREDENTIALS_ID)"

# Pipeline completo
.PHONY: pipeline
pipeline: ## Ejecutar el pipeline completo de CI/CD
	@echo "$(BLUE)🚀 Iniciando pipeline completo...$(NC)"
	$(MAKE) install-deps
	$(MAKE) test
	$(MAKE) build-docker
	$(MAKE) scan-image
	$(MAKE) deploy
	@echo "$(GREEN)✅ Pipeline completado exitosamente$(NC)"

# Instalar dependencias
.PHONY: install-deps
install-deps: ## Instalar dependencias (gcloud, etc.)
	@echo "$(BLUE)🔧 Instalando dependencias...$(NC)"
	@chmod +x scripts/install-dependencies.sh
	@GCP_PROJECT_ID=$(GCP_PROJECT_ID) ./scripts/install-dependencies.sh

# Ejecutar pruebas
.PHONY: test
test: ## Ejecutar pruebas unitarias
	@echo "$(BLUE)🧪 Ejecutando pruebas...$(NC)"
	@chmod +x scripts/run-tests.sh
	@./scripts/run-tests.sh

# Construir y subir imagen Docker
.PHONY: build-docker
build-docker: ## Construir y subir imagen Docker a Artifact Registry
	@echo "$(BLUE)🐳 Construyendo y subiendo imagen Docker...$(NC)"
	@chmod +x scripts/build-docker.sh
	@GCP_PROJECT_ID=$(GCP_PROJECT_ID) \
	ARTIFACT_REGISTRY_LOCATION=$(ARTIFACT_REGISTRY_LOCATION) \
	ARTIFACT_REGISTRY_REPO=$(ARTIFACT_REGISTRY_REPO) \
	APP_NAME=$(APP_NAME) \
	BUILD_NUMBER=$(BUILD_NUMBER) \
	GCP_KEY_FILE=$(GCP_KEY_FILE) \
	./scripts/build-docker.sh

# Escanear imagen
.PHONY: scan-image
scan-image: ## Escanear imagen Docker en busca de vulnerabilidades
	@echo "$(BLUE)🔍 Escaneando imagen Docker...$(NC)"
	@chmod +x scripts/scan-image.sh
	@GCP_PROJECT_ID=$(GCP_PROJECT_ID) \
	ARTIFACT_REGISTRY_LOCATION=$(ARTIFACT_REGISTRY_LOCATION) \
	ARTIFACT_REGISTRY_REPO=$(ARTIFACT_REGISTRY_REPO) \
	APP_NAME=$(APP_NAME) \
	BUILD_NUMBER=$(BUILD_NUMBER) \
	GCP_KEY_FILE=$(GCP_KEY_FILE) \
	./scripts/scan-image.sh

# Desplegar aplicación
.PHONY: deploy
deploy: ## Desplegar aplicación en Cloud Run
	@echo "$(BLUE)🚀 Desplegando aplicación...$(NC)"
	@chmod +x scripts/deploy.sh
	@GCP_PROJECT_ID=$(GCP_PROJECT_ID) \
	ARTIFACT_REGISTRY_LOCATION=$(ARTIFACT_REGISTRY_LOCATION) \
	ARTIFACT_REGISTRY_REPO=$(ARTIFACT_REGISTRY_REPO) \
	APP_NAME=$(APP_NAME) \
	BUILD_NUMBER=$(BUILD_NUMBER) \
	GCP_KEY_FILE=$(GCP_KEY_FILE) \
	./scripts/deploy.sh

# Desarrollo local
.PHONY: dev
dev: ## Ejecutar aplicación en modo desarrollo
	@echo "$(BLUE)🛠️ Ejecutando aplicación en modo desarrollo...$(NC)"
	@go mod tidy
	@go run main.go

# Ejecutar pruebas localmente
.PHONY: test-local
test-local: ## Ejecutar pruebas localmente
	@echo "$(BLUE)🧪 Ejecutando pruebas localmente...$(NC)"
	@go test -v ./...

# Construir imagen Docker localmente
.PHONY: build-local
build-local: ## Construir imagen Docker localmente
	@echo "$(BLUE)🐳 Construyendo imagen Docker localmente...$(NC)"
	@docker build -t $(APP_NAME):local .

# Ejecutar contenedor localmente
.PHONY: run-local
run-local: ## Ejecutar contenedor localmente
	@echo "$(BLUE)🐳 Ejecutando contenedor localmente...$(NC)"
	@docker run -p 8080:8080 $(APP_NAME):local

# Limpiar
.PHONY: clean
clean: ## Limpiar archivos temporales y contenedores
	@echo "$(BLUE)🧹 Limpiando archivos temporales...$(NC)"
	@docker system prune -f
	@docker rmi $(APP_NAME):local 2>/dev/null || true
	@go clean -cache

# Verificar configuración
.PHONY: check-config
check-config: ## Verificar configuración del proyecto
	@echo "$(BLUE)🔍 Verificando configuración...$(NC)"
	@echo "  - GCP_PROJECT_ID: $(GCP_PROJECT_ID)"
	@echo "  - ARTIFACT_REGISTRY_LOCATION: $(ARTIFACT_REGISTRY_LOCATION)"
	@echo "  - ARTIFACT_REGISTRY_REPO: $(ARTIFACT_REGISTRY_REPO)"
	@echo "  - APP_NAME: $(APP_NAME)"
	@echo "  - BUILD_NUMBER: $(BUILD_NUMBER)"
	@echo "  - IMAGE_TAG: $(IMAGE_TAG)"
	@echo "  - GCP_KEY_FILE: $(GCP_KEY_FILE)"
	@echo ""
	@if [ -z "$(GCP_KEY_FILE)" ]; then \
		echo "$(RED)❌ GCP_KEY_FILE no está definido$(NC)"; \
		echo "   Ejecuta: export GCP_KEY_FILE=/path/to/service-account-key.json"; \
		exit 1; \
	fi
	@if [ ! -f "$(GCP_KEY_FILE)" ]; then \
		echo "$(RED)❌ Archivo de credenciales no encontrado: $(GCP_KEY_FILE)$(NC)"; \
		exit 1; \
	fi
	@echo "$(GREEN)✅ Configuración verificada$(NC)"

# Pipeline con verificación de configuración
.PHONY: pipeline-safe
pipeline-safe: check-config pipeline ## Ejecutar pipeline con verificación de configuración

# Mostrar información de la imagen
.PHONY: image-info
image-info: ## Mostrar información de la imagen Docker
	@echo "$(BLUE)📋 Información de la imagen:$(NC)"
	@echo "  - URL: $(IMAGE_URL)"
	@echo "  - Tag: $(IMAGE_TAG)"
	@echo "  - Build Number: $(BUILD_NUMBER)"

# Verificar estado del servicio
.PHONY: service-status
service-status: ## Verificar estado del servicio en Cloud Run
	@echo "$(BLUE)🔍 Verificando estado del servicio...$(NC)"
	@if [ -z "$(GCP_KEY_FILE)" ]; then \
		echo "$(RED)❌ GCP_KEY_FILE no está definido$(NC)"; \
		exit 1; \
	fi
	@gcloud auth activate-service-account --key-file=$(GCP_KEY_FILE)
	@gcloud run services describe $(APP_NAME) \
		--region=$(ARTIFACT_REGISTRY_LOCATION) \
		--project=$(GCP_PROJECT_ID) \
		--format="table(metadata.name,status.url,status.conditions[0].status,status.conditions[0].message)"

# Logs del servicio
.PHONY: logs
logs: ## Mostrar logs del servicio en Cloud Run
	@echo "$(BLUE)📋 Mostrando logs del servicio...$(NC)"
	@if [ -z "$(GCP_KEY_FILE)" ]; then \
		echo "$(RED)❌ GCP_KEY_FILE no está definido$(NC)"; \
		exit 1; \
	fi
	@gcloud auth activate-service-account --key-file=$(GCP_KEY_FILE)
	@gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=$(APP_NAME)" \
		--project=$(GCP_PROJECT_ID) \
		--limit=50 \
		--format="table(timestamp,severity,textPayload)" 