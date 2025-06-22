pipeline {
    agent any

    environment {
        GCP_PROJECT_ID = 'tu-proyecto-gcp'
        GCP_CREDENTIALS_ID = 'gcp-service-account' // ID de la credencial de Jenkins
        ARTIFACT_REGISTRY_LOCATION = 'us-central1'
        ARTIFACT_REGISTRY_REPO = 'tu-repo-docker'
        APP_NAME = 'go-api-demo'
        // La URL completa del registro
        IMAGE_URL = "${ARTIFACT_REGISTRY_LOCATION}-docker.pkg.dev/${GCP_PROJECT_ID}/${ARTIFACT_REGISTRY_REPO}/${APP_NAME}"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/tu-usuario/pipeline-gcp-artifactory.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                script {
                    withCredentials([file(credentialsId: GCP_CREDENTIALS_ID, variable: 'GCP_KEY_FILE')]) {
                        sh '''
                            # Configurar variables de entorno para el Makefile
                            export GCP_PROJECT_ID="${GCP_PROJECT_ID}"
                            export ARTIFACT_REGISTRY_LOCATION="${ARTIFACT_REGISTRY_LOCATION}"
                            export ARTIFACT_REGISTRY_REPO="${ARTIFACT_REGISTRY_REPO}"
                            export APP_NAME="${APP_NAME}"
                            export BUILD_NUMBER="${BUILD_NUMBER}"
                            export GCP_KEY_FILE="${GCP_KEY_FILE}"
                            
                            # Ejecutar instalación de dependencias usando Makefile
                            make install-deps
                        '''
                    }
                }
            }
        }

        stage('Unit Tests') {
            steps {
                sh 'make test'
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                script {
                    withCredentials([file(credentialsId: GCP_CREDENTIALS_ID, variable: 'GCP_KEY_FILE')]) {
                        sh '''
                            # Configurar variables de entorno para el Makefile
                            export GCP_PROJECT_ID="${GCP_PROJECT_ID}"
                            export ARTIFACT_REGISTRY_LOCATION="${ARTIFACT_REGISTRY_LOCATION}"
                            export ARTIFACT_REGISTRY_REPO="${ARTIFACT_REGISTRY_REPO}"
                            export APP_NAME="${APP_NAME}"
                            export BUILD_NUMBER="${BUILD_NUMBER}"
                            export GCP_KEY_FILE="${GCP_KEY_FILE}"
                            
                            # Ejecutar construcción y subida de imagen usando Makefile
                            make build-docker
                        '''
                    }
                }
            }
        }

        stage('Scan Image & Check Vulnerabilities') {
            steps {
                script {
                    withCredentials([file(credentialsId: GCP_CREDENTIALS_ID, variable: 'GCP_KEY_FILE')]) {
                        sh '''
                            # Configurar variables de entorno para el Makefile
                            export GCP_PROJECT_ID="${GCP_PROJECT_ID}"
                            export ARTIFACT_REGISTRY_LOCATION="${ARTIFACT_REGISTRY_LOCATION}"
                            export ARTIFACT_REGISTRY_REPO="${ARTIFACT_REGISTRY_REPO}"
                            export APP_NAME="${APP_NAME}"
                            export BUILD_NUMBER="${BUILD_NUMBER}"
                            export GCP_KEY_FILE="${GCP_KEY_FILE}"
                            
                            # Ejecutar escaneo de imagen usando Makefile
                            make scan-image
                        '''
                    }
                }
            }
        }
        
        stage('Deploy to Cloud Run') {
            steps {
                script {
                    withCredentials([file(credentialsId: GCP_CREDENTIALS_ID, variable: 'GCP_KEY_FILE')]) {
                        sh '''
                            # Configurar variables de entorno para el Makefile
                            export GCP_PROJECT_ID="${GCP_PROJECT_ID}"
                            export ARTIFACT_REGISTRY_LOCATION="${ARTIFACT_REGISTRY_LOCATION}"
                            export ARTIFACT_REGISTRY_REPO="${ARTIFACT_REGISTRY_REPO}"
                            export APP_NAME="${APP_NAME}"
                            export BUILD_NUMBER="${BUILD_NUMBER}"
                            export GCP_KEY_FILE="${GCP_KEY_FILE}"
                            
                            # Ejecutar despliegue usando Makefile
                            make deploy
                        '''
                    }
                }
            }
        }
    }
    
    post {
        always {
            script {
                withCredentials([file(credentialsId: GCP_CREDENTIALS_ID, variable: 'GCP_KEY_FILE')]) {
                    sh '''
                        # Configurar variables de entorno para el Makefile
                        export GCP_PROJECT_ID="${GCP_PROJECT_ID}"
                        export ARTIFACT_REGISTRY_LOCATION="${ARTIFACT_REGISTRY_LOCATION}"
                        export ARTIFACT_REGISTRY_REPO="${ARTIFACT_REGISTRY_REPO}"
                        export APP_NAME="${APP_NAME}"
                        export BUILD_NUMBER="${BUILD_NUMBER}"
                        export GCP_KEY_FILE="${GCP_KEY_FILE}"
                        
                        # Mostrar información de la imagen construida
                        make image-info
                    '''
                }
            }
        }
        success {
            script {
                withCredentials([file(credentialsId: GCP_CREDENTIALS_ID, variable: 'GCP_KEY_FILE')]) {
                    sh '''
                        # Configurar variables de entorno para el Makefile
                        export GCP_PROJECT_ID="${GCP_PROJECT_ID}"
                        export ARTIFACT_REGISTRY_LOCATION="${ARTIFACT_REGISTRY_LOCATION}"
                        export ARTIFACT_REGISTRY_REPO="${ARTIFACT_REGISTRY_REPO}"
                        export APP_NAME="${APP_NAME}"
                        export BUILD_NUMBER="${BUILD_NUMBER}"
                        export GCP_KEY_FILE="${GCP_KEY_FILE}"
                        
                        # Mostrar estado del servicio
                        make service-status
                    '''
                }
            }
        }
        failure {
            script {
                withCredentials([file(credentialsId: GCP_CREDENTIALS_ID, variable: 'GCP_KEY_FILE')]) {
                    sh '''
                        # Configurar variables de entorno para el Makefile
                        export GCP_PROJECT_ID="${GCP_PROJECT_ID}"
                        export ARTIFACT_REGISTRY_LOCATION="${ARTIFACT_REGISTRY_LOCATION}"
                        export ARTIFACT_REGISTRY_REPO="${ARTIFACT_REGISTRY_REPO}"
                        export APP_NAME="${APP_NAME}"
                        export BUILD_NUMBER="${BUILD_NUMBER}"
                        export GCP_KEY_FILE="${GCP_KEY_FILE}"
                        
                        # Mostrar logs del servicio en caso de fallo
                        make logs
                    '''
                }
            }
        }
    }
} 