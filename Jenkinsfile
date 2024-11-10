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
        stage('Git Checkout') {
            steps {
                git branch: 'blueGree', url: 'https://github.com/arifislam007/cicd-project-1.git'
            }
        }
        stage('Code Compile') {
            steps {
                sh 'mvn compile'
            }
        }
        stage('SonarQuibe Analisys') {
            steps {
                withSonarQubeEnv('sonarserver') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=javaapp -Dsonar.projectKey=javaapp \
                            -Dsonar.java.binaries=. '''
                }
            }
        }
        stage('Code Build') {
            steps {
                sh 'mvn package'
            }
        }
        stage('Docker Build and push') {
            steps {
                script{
                    withDockerRegistry(credentialsId: 'Docker-cred') {
                        sh "docker build -t arifislam/blue-gree-app:${BUILD_NUMBER} ."
                        sh "docker push arifislam/blue-gree-app:${BUILD_NUMBER}"
                    }
                }
            }
        }
        stage('Update Deployment File Image Tag') {
            steps {
                sh "sed -i 's/blue-gree-app:base/blue-gree-app:${BUILD_NUMBER}/' ./deployment.yml"
                sh "cat ./deployment.yml"
            }
        }
        stage('Deploy with Kubectl') {
            steps {
                withKubeConfig(caCertificate: '', clusterName: 'kubernetes', contextName: '', credentialsId: 'kube-secret', namespace: 'java-app', restrictKubeConfigAccess: false, serverUrl: 'https://192.168.207.197:6443') {
                    sh 'kubectl apply -f deployment.yml -n java-app'
                }
            }
        }
    }
}
