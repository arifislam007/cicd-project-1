pipeline {
    agent any
    
    tools {
        jdk 'jdk'
        maven 'mvn'
    }
    environment {
        SCANNER_HOME= tool 'sonar-scanner'
    }

    stages {
        stage('Git checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/arifislam007/cicd-project-1.git'
            }
        }
        stage('Code Compile') {
            steps {
                sh 'mvn compile'
            }
        }
        stage('Test Stage') {
            steps {
                sh 'mvn test'
            }
        }
        stage('SonarQuibe Analisys') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=javaapp -Dsonar.projectKey=javaapp \
                            -Dsonar.java.binaries=. '''
                }
            }
        }
        stage('Quality Grade') {
            steps {
                waitForQualityGate abortPipeline: false, credentialsId: 'sonar-cred'
            }
        }
        stage('Build Package') {
            steps {
                sh 'mvn package'
            }
        }
        stage('Docker Build and push') {
            steps {
                script{
                    withDockerRegistry(credentialsId: 'docker-cred') {
                        sh "docker build -t arifislam/my-cicd:${BUILD_NUMBER} ."
                        sh "docker push arifislam/my-cicd:${BUILD_NUMBER}"
                    }
                }
            }
        }
        stage('Update Deployment File Image Tag') {
            steps {
                sh "sed -i 's/spring-bot:base/my-cicd:${BUILD_NUMBER}/' ./deployment.yml"
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                withKubeConfig(caCertificate: '', clusterName: 'kubernetes', contextName: '', credentialsId: 'kub-cred', namespace: 'java-app', restrictKubeConfigAccess: false, serverUrl: 'https://192.168.207.10:6443') {
                    sh 'kubectl apply -f deployment.yml -n java-app'
                }
            }
        }
    }
}
