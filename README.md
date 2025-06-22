# Jenkins Pipeline con Integración GCP Artifact Registry

## Descripción

Este proyecto contiene una aplicación Go con tres APIs sencillas y la configuración completa de un pipeline de Jenkins que se integra con Google Cloud Platform (GCP) y GCP Artifact Registry para automatizar el proceso de construcción, pruebas, registro de imágenes Docker, análisis de seguridad y despliegue de aplicaciones.

**Característica destacada**: El proyecto utiliza un **Makefile** como orquestador principal que invoca scripts bash modulares organizados en la carpeta `scripts/`, proporcionando una estructura limpia, mantenible y fácil de debuggear.

## Características

- 🔄 **Pipeline Automatizado**: Configuración completa de Jenkins pipeline
- ☁️ **Integración GCP**: Despliegue y gestión de recursos en Google Cloud Platform
- 📦 **GCP Artifact Registry**: Registro y gestión de imágenes Docker
- 🔍 **Análisis de Imágenes**: Escaneo automático de seguridad y vulnerabilidades en imágenes Docker
- 🧪 **Testing Automatizado**: Ejecución automática de pruebas unitarias
- 🚀 **CI/CD**: Integración y despliegue continuo
- 🔒 **Seguridad**: Gestión segura de credenciales y verificación de vulnerabilidades
- 🐳 **Docker**: Contenedorización automática de la aplicación
- ☕ **Aplicación Go**: Tres APIs REST sencillas listas para usar
- 🛠️ **Arquitectura Modular**: Makefile + Scripts bash organizados
- 🎯 **Fácil Debugging**: Comandos individuales para cada etapa del pipeline

## APIs Disponibles

La aplicación incluye tres endpoints REST:

- **`GET /`**: Página de bienvenida
- **`GET /hello?name=<nombre>`**: Saludo personalizado (usa "World" por defecto)
- **`GET /health`**: Endpoint de salud para monitoreo

## Prerrequisitos

### Software Requerido
- Jenkins 2.387.3 o superior
- Docker
- Java 11 o superior (para Jenkins)
- Git
- Make (para desarrollo local)

### Cuentas y Servicios
- Cuenta de Google Cloud Platform
- GCP Artifact Registry habilitado
- GCP Container Analysis habilitado
- GCP Cloud Run habilitado
- Repositorio Git (GitHub, GitLab, Bitbucket)

### Plugins de Jenkins Requeridos
- Pipeline
- Git
- Docker Pipeline
- Credentials Binding
- Google Cloud Storage
- Google Cloud Build

## Instalación y Configuración

### 1. Configuración de Jenkins

```bash
# Instalar plugins necesarios
# Ir a Manage Jenkins > Manage Plugins > Available
# Buscar e instalar:
# - Pipeline
# - Git
# - Docker Pipeline
# - Credentials Binding
# - Google Cloud Storage
# - Google Cloud Build
```

### 2. Configuración de Credenciales

#### GCP Service Account
1. Crear una cuenta de servicio en GCP con los siguientes roles:
   - Artifact Registry Writer
   - Cloud Run Admin
   - Service Account User
   - Container Analysis Admin
2. Descargar el archivo JSON de credenciales
3. En Jenkins: Manage Jenkins > Manage Credentials > System > Global credentials
4. Agregar credencial de tipo "Secret file" con ID: `gcp-service-account`

### 3. Configuración del Proyecto

```bash
# Clonar el repositorio
git clone <repository-url>
cd pipeline-gcp-artifactory

# Configurar variables de entorno
export GCP_PROJECT_ID="tu-proyecto-gcp"
export ARTIFACT_REGISTRY_LOCATION="us-central1"
export ARTIFACT_REGISTRY_REPO="tu-repo-docker"
export APP_NAME="go-api-demo"
export GCP_KEY_FILE="/path/to/service-account-key.json"
```

## Estructura del Proyecto

```
pipeline-gcp-artifactory/
├── main.go                     # Aplicación Go con tres APIs
├── main_test.go                # Pruebas unitarias
├── go.mod                      # Módulo de Go
├── Dockerfile                  # Dockerfile multi-etapa
├── Jenkinsfile                 # Pipeline simplificado que usa Makefile
├── Makefile                    # Orquestador principal de comandos
├── scripts/                    # Scripts bash modulares
│   ├── install-dependencies.sh # Instalación de gcloud y dependencias
│   ├── run-tests.sh           # Ejecución de pruebas unitarias
│   ├── build-docker.sh        # Construcción y subida de imagen Docker
│   ├── scan-image.sh          # Escaneo de vulnerabilidades
│   └── deploy.sh              # Despliegue en Cloud Run
├── .gitignore                  # Archivos a ignorar en git
└── README.md                   # Este archivo
```

## Uso

### Comandos del Makefile

El proyecto utiliza un Makefile como orquestador principal. Ejecuta `make help` para ver todos los comandos disponibles:

```bash
# Mostrar ayuda y comandos disponibles
make help

# Pipeline completo de CI/CD
make pipeline

# Comandos individuales
make install-deps    # Instalar dependencias (gcloud, etc.)
make test           # Ejecutar pruebas unitarias
make build-docker   # Construir y subir imagen Docker
make scan-image     # Escanear vulnerabilidades
make deploy         # Desplegar aplicación en Cloud Run

# Desarrollo local
make dev            # Ejecutar aplicación en modo desarrollo
make test-local     # Ejecutar pruebas localmente
make build-local    # Construir imagen Docker localmente
make run-local      # Ejecutar contenedor localmente

# Utilidades
make clean          # Limpiar archivos temporales
make check-config   # Verificar configuración del proyecto
make image-info     # Mostrar información de la imagen
make service-status # Verificar estado del servicio
make logs           # Mostrar logs del servicio
```

### Ejecutar la Aplicación Localmente

```bash
# Instalar dependencias
go mod tidy

# Ejecutar la aplicación
make dev
# o
go run main.go

# La aplicación estará disponible en http://localhost:8080
```

### Probar las APIs

```bash
# Endpoint principal
curl http://localhost:8080/

# Endpoint de saludo
curl http://localhost:8080/hello
curl http://localhost:8080/hello?name=TuNombre

# Endpoint de salud
curl http://localhost:8080/health
```

### Ejecutar Pruebas

```bash
# Ejecutar todas las pruebas
make test-local
# o
go test -v

# Ejecutar pruebas con cobertura
go test -v -cover
```

### Crear un Nuevo Pipeline en Jenkins

1. En Jenkins, crear un nuevo "Pipeline" job
2. Configurar el repositorio Git
3. Especificar la ruta del Jenkinsfile: `Jenkinsfile`
4. Configurar los triggers (webhook, polling, etc.)

### Variables de Entorno del Pipeline

```groovy
// Variables disponibles en el pipeline
GCP_PROJECT_ID = 'tu-proyecto-gcp'
GCP_CREDENTIALS_ID = 'gcp-service-account'
ARTIFACT_REGISTRY_LOCATION = 'us-central1'
ARTIFACT_REGISTRY_REPO = 'tu-repo-docker'
APP_NAME = 'go-api-demo'
IMAGE_URL = "${ARTIFACT_REGISTRY_LOCATION}-docker.pkg.dev/${GCP_PROJECT_ID}/${ARTIFACT_REGISTRY_REPO}/${APP_NAME}"
```

### Ejecutar el Pipeline

El pipeline se ejecutará automáticamente cuando:
- Se haga push a la rama principal
- Se cree un pull request
- Se ejecute manualmente desde Jenkins

## Flujo del Pipeline

1. **Checkout**: Clonar el código fuente
2. **Install Dependencies**: Instalar Google Cloud SDK automáticamente
3. **Unit Tests**: Ejecutar pruebas unitarias de Go
4. **Build & Push Docker Image**: Construir imagen Docker y subir a Artifact Registry
5. **Scan Image & Check Vulnerabilities**: Análisis automático de seguridad
6. **Deploy to Cloud Run**: Desplegar en Google Cloud Run

## Arquitectura Modular

### Makefile como Orquestador

El `Makefile` actúa como el punto de entrada principal y orquesta todos los scripts bash:

- **Variables configurables**: Fácil personalización de parámetros
- **Sistema de ayuda**: `make help` muestra todos los comandos disponibles
- **Colores en output**: Mejor experiencia de usuario
- **Validación de configuración**: Verificación automática de variables requeridas

### Scripts Bash Modulares

Cada script en la carpeta `scripts/` tiene una responsabilidad específica:

#### `install-dependencies.sh`
- Detección automática del sistema operativo
- Instalación de Google Cloud SDK
- Configuración del proyecto GCP

#### `run-tests.sh`
- Verificación de dependencias de Go
- Ejecución de pruebas unitarias
- Generación de reportes de cobertura

#### `build-docker.sh`
- Validación de variables de entorno
- Autenticación con GCP Artifact Registry
- Construcción y subida de imagen Docker

#### `scan-image.sh`
- Escaneo automático de vulnerabilidades
- Verificación de vulnerabilidades críticas
- Timeout y manejo de errores robusto

#### `deploy.sh`
- Despliegue en Google Cloud Run
- Verificación del estado del servicio
- Prueba automática del endpoint de salud

### Ventajas de la Arquitectura Modular

- **Mantenibilidad**: Cada script tiene una responsabilidad única
- **Reutilización**: Scripts pueden ejecutarse independientemente
- **Debugging**: Fácil ejecutar comandos individuales para troubleshooting
- **Portabilidad**: Funciona tanto en Jenkins como localmente
- **Escalabilidad**: Fácil agregar nuevos scripts y comandos

## Configuración de GCP Artifact Registry

### Crear Repositorio en Artifact Registry

```bash
# Crear repositorio para imágenes Docker
gcloud artifacts repositories create tu-repo-docker \
    --repository-format=docker \
    --location=us-central1 \
    --description="Repositorio para imágenes Docker del proyecto"

# Configurar autenticación Docker
gcloud auth configure-docker us-central1-docker.pkg.dev
```

### Configuración de Build Info
```groovy
def buildInfo = [
    name: env.JOB_NAME,
    number: env.BUILD_NUMBER,
    timestamp: new Date().format("yyyy-MM-dd'T'HH:mm:ss'Z'"),
    image: "us-central1-docker.pkg.dev/${GCP_PROJECT_ID}/${ARTIFACT_REGISTRY_REPO}/${APP_NAME}:${BUILD_NUMBER}"
]
```

## Análisis de Imágenes Docker

### Escaneo Automático
El pipeline incluye un stage dedicado que:
- Espera a que el análisis automático de Artifact Registry se complete
- Verifica vulnerabilidades críticas
- Falla el pipeline si encuentra vulnerabilidades críticas
- Continúa el despliegue si no hay problemas de seguridad

### Herramientas de Análisis
- **GCP Container Analysis**: Análisis automático integrado
- **Vulnerability Scanning**: Escaneo de vulnerabilidades conocido
- **Policy Enforcement**: Verificación de políticas de seguridad

## Configuración de GCP

### Servicios Utilizados
- **Cloud Build**: Construcción de imágenes Docker
- **Artifact Registry**: Almacenamiento y gestión de imágenes Docker
- **Container Analysis**: Análisis automático de vulnerabilidades
- **Cloud Run**: Despliegue de aplicaciones serverless
- **Cloud Storage**: Almacenamiento de artefactos

### Configuración de Despliegue
```yaml
# cloudbuild.yaml (ejemplo)
steps:
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'us-central1-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/$IMAGE_NAME:$COMMIT_SHA', '.']
  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', 'us-central1-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/$IMAGE_NAME:$COMMIT_SHA']
  - name: 'gcr.io/cloud-builders/gcloud'
    args: ['run', 'deploy', '$SERVICE_NAME', '--image', 'us-central1-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/$IMAGE_NAME:$COMMIT_SHA', '--region', 'us-central1', '--platform', 'managed']
```

## Monitoreo y Logs

### Jenkins
- Logs del pipeline disponibles en la interfaz de Jenkins
- Notificaciones por email/Slack configuradas
- Historial de builds y análisis de vulnerabilidades

### GCP
- Logs en Cloud Logging
- Métricas en Cloud Monitoring
- Alertas configuradas
- Análisis de vulnerabilidades en Container Analysis

### Artifact Registry
- Logs de acceso en Cloud Logging
- Métricas de uso disponibles
- Historial de versiones de imágenes
- Reportes de vulnerabilidades

## Troubleshooting

### Problemas Comunes

1. **Error de credenciales GCP**
   - Verificar que el service account tenga permisos para Artifact Registry
   - Comprobar que las credenciales estén configuradas en Jenkins
   - Verificar que el ID de credencial sea `gcp-service-account`

2. **Error de conexión a Artifact Registry**
   - Verificar que el repositorio esté creado en la región correcta
   - Comprobar la autenticación Docker con `gcloud auth configure-docker`
   - Verificar que las APIs estén habilitadas en GCP

3. **Fallo en el análisis de imagen**
   - Verificar que Container Analysis esté habilitado
   - Comprobar que el repositorio tenga análisis automático activado
   - Revisar los logs de Container Analysis en Cloud Logging

4. **Fallo en la instalación de gcloud**
   - Verificar que el agente de Jenkins tenga permisos de sudo
   - Comprobar la conectividad a internet
   - Revisar los logs de instalación en el stage "Install Dependencies"

5. **Fallo en el build**
   - Revisar los logs del pipeline
   - Verificar las dependencias del proyecto Go
   - Comprobar que Docker esté disponible en el agente

6. **Error en scripts bash**
   - Verificar que los scripts tengan permisos de ejecución: `chmod +x scripts/*.sh`
   - Comprobar que las variables de entorno estén definidas
   - Ejecutar comandos individuales para debugging: `make check-config`

### Debugging con Comandos Individuales

```bash
# Verificar configuración
make check-config

# Ejecutar etapas individuales para debugging
make install-deps
make test
make build-docker
make scan-image
make deploy

# Ver información del servicio
make service-status
make logs
```

### Logs Útiles
```bash
# Logs de Jenkins
tail -f /var/log/jenkins/jenkins.log

# Logs de Docker
docker logs <container-id>

# Logs de GCP
gcloud logging read "resource.type=gce_instance"

# Logs de Artifact Registry
gcloud logging read "resource.type=artifactregistry.googleapis.com/Repository"

# Logs de Container Analysis
gcloud logging read "resource.type=containeranalysis.googleapis.com/Note"
```

## Desarrollo Local

### Requisitos de Desarrollo
- Go 1.19 o superior
- Docker
- Make
- Google Cloud SDK (opcional para desarrollo local)

### Comandos de Desarrollo
```bash
# Instalar dependencias
go mod tidy

# Ejecutar aplicación localmente
make dev

# Ejecutar pruebas
make test-local

# Construir imagen Docker local
make build-local

# Ejecutar contenedor local
make run-local

# Limpiar archivos temporales
make clean
```

### Configuración Local
```bash
# Configurar variables de entorno para desarrollo local
export GCP_PROJECT_ID="tu-proyecto-gcp"
export ARTIFACT_REGISTRY_LOCATION="us-central1"
export ARTIFACT_REGISTRY_REPO="tu-repo-docker"
export APP_NAME="go-api-demo"
export GCP_KEY_FILE="/path/to/service-account-key.json"

# Verificar configuración
make check-config
```

## Contribución

1. Fork el proyecto
2. Crear una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir un Pull Request

### Guías de Contribución

- Mantener la estructura modular de scripts bash
- Agregar nuevos comandos al Makefile con documentación
- Incluir validaciones de variables de entorno en scripts
- Usar emojis para mensajes informativos
- Mantener compatibilidad con Jenkins y desarrollo local

## Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## Contacto

- **Autor**: [Tu Nombre]
- **Email**: [tu-email@ejemplo.com]
- **Proyecto**: [https://github.com/tu-usuario/pipeline-gcp-artifactory]

## Changelog

### v2.0.0 (2024-01-XX)
- **Refactorización completa**: Implementación de Makefile como orquestador principal
- **Arquitectura modular**: Scripts bash organizados en carpeta `scripts/`
- **Mejor debugging**: Comandos individuales para cada etapa del pipeline
- **Sistema de ayuda**: `make help` con documentación completa
- **Validación de configuración**: Verificación automática de variables requeridas
- **Colores en output**: Mejor experiencia de usuario
- **Portabilidad**: Scripts funcionan tanto en Jenkins como localmente

### v1.1.0 (2024-01-XX)
- Agregada aplicación Go con tres APIs REST
- Implementado Dockerfile multi-etapa
- Agregadas pruebas unitarias
- Instalación automática de gcloud en el pipeline
- Análisis automático de vulnerabilidades en Artifact Registry

### v1.0.0 (2024-01-XX)
- Configuración inicial del pipeline
- Integración con GCP Artifact Registry
- Análisis de imágenes Docker
- Documentación básica

---

**Nota**: Este README es una plantilla que debe ser personalizada según las necesidades específicas de tu proyecto. Asegúrate de actualizar las URLs, credenciales y configuraciones según tu entorno. 