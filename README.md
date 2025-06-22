# Jenkins Pipeline con Integración GCP Artifact Registry

## Descripción

Este proyecto contiene la configuración y scripts necesarios para implementar un pipeline de Jenkins que se integra con Google Cloud Platform (GCP) y GCP Artifact Registry para automatizar el proceso de construcción, pruebas, registro de imágenes Docker y análisis de imágenes para el despliegue de aplicaciones.

## Características

- 🔄 **Pipeline Automatizado**: Configuración completa de Jenkins pipeline
- ☁️ **Integración GCP**: Despliegue y gestión de recursos en Google Cloud Platform
- 📦 **GCP Artifact Registry**: Registro y gestión de imágenes Docker
- 🔍 **Análisis de Imágenes**: Escaneo de seguridad y vulnerabilidades en imágenes Docker
- 🧪 **Testing Automatizado**: Ejecución automática de pruebas
- 🚀 **CI/CD**: Integración y despliegue continuo
- 🔒 **Seguridad**: Gestión segura de credenciales y secretos

## Prerrequisitos

### Software Requerido
- Jenkins 2.387.3 o superior
- Docker
- Google Cloud SDK
- Java 11 o superior
- Maven 3.6+ o Gradle 7+

### Cuentas y Servicios
- Cuenta de Google Cloud Platform
- GCP Artifact Registry habilitado
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
1. Crear una cuenta de servicio en GCP con permisos para Artifact Registry
2. Descargar el archivo JSON de credenciales
3. En Jenkins: Manage Jenkins > Manage Credentials > System > Global credentials
4. Agregar credencial de tipo "Google Service Account from private key"

### 3. Configuración del Proyecto

```bash
# Clonar el repositorio
git clone <repository-url>
cd pipeline-gcp-artifactory

# Configurar variables de entorno
cp .env.example .env
# Editar .env con tus configuraciones
```

## Estructura del Proyecto

```
pipeline-gcp-artifactory/
├── Jenkinsfile                 # Pipeline principal de Jenkins
├── scripts/                    # Scripts auxiliares
│   ├── build.sh               # Script de construcción
│   ├── test.sh                # Script de pruebas
│   ├── build-docker.sh        # Script de construcción de imagen Docker
│   ├── scan-image.sh          # Script de análisis de imagen
│   └── deploy.sh              # Script de despliegue
├── config/                     # Archivos de configuración
│   ├── artifact-registry.json # Configuración de GCP Artifact Registry
│   └── gcp-config.json        # Configuración de GCP
├── docker/                     # Archivos Docker
│   ├── Dockerfile             # Dockerfile principal
│   └── docker-compose.yml     # Compose para desarrollo
├── docs/                       # Documentación
│   ├── setup.md               # Guía de configuración
│   └── troubleshooting.md     # Solución de problemas
└── README.md                   # Este archivo
```

## Uso

### Crear un Nuevo Pipeline

1. En Jenkins, crear un nuevo "Pipeline" job
2. Configurar el repositorio Git
3. Especificar la ruta del Jenkinsfile: `Jenkinsfile`
4. Configurar los triggers (webhook, polling, etc.)

### Variables de Entorno

```groovy
// Variables disponibles en el pipeline
GCP_PROJECT_ID = 'tu-proyecto-gcp'
ARTIFACT_REGISTRY_LOCATION = 'us-central1'
ARTIFACT_REGISTRY_REPOSITORY = 'tu-repositorio-docker'
DOCKER_REGISTRY = 'us-central1-docker.pkg.dev/tu-proyecto/tu-repositorio-docker'
```

### Ejecutar el Pipeline

El pipeline se ejecutará automáticamente cuando:
- Se haga push a la rama principal
- Se cree un pull request
- Se ejecute manualmente desde Jenkins

## Flujo del Pipeline

1. **Checkout**: Clonar el código fuente
2. **Build**: Compilar la aplicación
3. **Test**: Ejecutar pruebas unitarias e integración
4. **SonarQube**: Análisis de calidad de código
5. **Build Docker**: Crear imagen Docker
6. **Scan Image**: Análisis de seguridad de la imagen Docker
7. **Push to Artifact Registry**: Registrar imagen en GCP Artifact Registry
8. **Deploy to GCP**: Desplegar en Google Cloud Platform
9. **Integration Tests**: Pruebas de integración en producción

## Configuración de GCP Artifact Registry

### Crear Repositorio en Artifact Registry

```bash
# Crear repositorio para imágenes Docker
gcloud artifacts repositories create tu-repositorio-docker \
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
    image: "us-central1-docker.pkg.dev/${GCP_PROJECT_ID}/${ARTIFACT_REGISTRY_REPOSITORY}/${APP_NAME}:${BUILD_NUMBER}"
]
```

## Análisis de Imágenes Docker

### Escaneo de Seguridad
```bash
# Usando Trivy para análisis de vulnerabilidades
trivy image --severity HIGH,CRITICAL us-central1-docker.pkg.dev/tu-proyecto/tu-repositorio-docker/tu-app:latest

# Usando Snyk para análisis de dependencias
snyk container test us-central1-docker.pkg.dev/tu-proyecto/tu-repositorio-docker/tu-app:latest
```

### Configuración de Análisis Automático
```groovy
stage('Scan Docker Image') {
    steps {
        script {
            // Análisis de vulnerabilidades
            sh '''
                trivy image --format json --output trivy-results.json \
                us-central1-docker.pkg.dev/${GCP_PROJECT_ID}/${ARTIFACT_REGISTRY_REPOSITORY}/${APP_NAME}:${BUILD_NUMBER}
                
                # Verificar si hay vulnerabilidades críticas
                if jq -e '.Results[].Vulnerabilities[] | select(.Severity == "CRITICAL")' trivy-results.json > /dev/null; then
                    echo "CRITICAL vulnerabilities found!"
                    exit 1
                fi
            '''
        }
    }
}
```

## Configuración de GCP

### Servicios Utilizados
- **Cloud Build**: Construcción de imágenes Docker
- **Artifact Registry**: Almacenamiento y gestión de imágenes Docker
- **Container Analysis**: Análisis de vulnerabilidades de imágenes
- **Cloud Run**: Despliegue de aplicaciones
- **Cloud Storage**: Almacenamiento de artefactos

### Configuración de Despliegue
```yaml
# cloudbuild.yaml
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

### GCP
- Logs en Cloud Logging
- Métricas en Cloud Monitoring
- Alertas configuradas
- Análisis de vulnerabilidades en Container Analysis

### Artifact Registry
- Logs de acceso en Cloud Logging
- Métricas de uso disponibles
- Historial de versiones de imágenes

## Troubleshooting

### Problemas Comunes

1. **Error de credenciales GCP**
   - Verificar que el service account tenga permisos para Artifact Registry
   - Comprobar que las credenciales estén configuradas en Jenkins

2. **Error de conexión a Artifact Registry**
   - Verificar que el repositorio esté creado en la región correcta
   - Comprobar la autenticación Docker con `gcloud auth configure-docker`

3. **Fallo en el análisis de imagen**
   - Verificar que las herramientas de análisis estén instaladas
   - Comprobar la conectividad a internet para descargar bases de datos de vulnerabilidades

4. **Fallo en el build**
   - Revisar los logs del pipeline
   - Verificar las dependencias del proyecto

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
```

## Contribución

1. Fork el proyecto
2. Crear una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir un Pull Request

## Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## Contacto

- **Autor**: [Tu Nombre]
- **Email**: [tu-email@ejemplo.com]
- **Proyecto**: [https://github.com/tu-usuario/pipeline-gcp-artifactory]

## Changelog

### v1.0.0 (2024-01-XX)
- Configuración inicial del pipeline
- Integración con GCP Artifact Registry
- Análisis de imágenes Docker
- Documentación básica

---

**Nota**: Este README es una plantilla que debe ser personalizada según las necesidades específicas de tu proyecto. Asegúrate de actualizar las URLs, credenciales y configuraciones según tu entorno. 