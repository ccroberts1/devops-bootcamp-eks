#!/usr/bin/env groovy

pipeline {
    agent any
    environment {
        ECR_REPO_URL = '538343889439.dkr.ecr.us-east-1.amazonaws.com'
        IMAGE_REPO = "${ECR_REPO_URL}/eks-test"
        IMAGE_NAME = "1.0-${BUILD_NUMBER}"
        CLUSTER_NAME = "demo-cluster"
        CLUSTER_REGION = "us-east-1"
        AWS_ACCESS_KEY_ID = credentials('aws-secret-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
    }
    stages {
        stage('build app') {
            steps {
               script {
                   echo "building the application..."
                   sh 'pwd'
                   sh 'ls'
                   sh './gradlew clean build'
               }
            }
        }
        stage('build image') {
            steps {
                script {
                    echo "building the docker image..."
                    sh "docker build -t ${IMAGE_REPO}:${IMAGE_NAME} ."
                    sh "aws ecr get-login-password --region ${CLUSTER_REGION} | docker login --username AWS --password-stdin ${ECR_REPO_URL}"
                    sh "docker push ${IMAGE_REPO}:${IMAGE_NAME}"
                }
            }
        }
        stage('deploy') {
            environment {
                APP_NAME = 'java-app'
                APP_NAMESPACE = 'demo-app'
                DB_USER_SECRET = credentials('db_user')
                DB_PASS_SECRET = credentials('db_pass')
                DB_NAME_SECRET = credentials('db_name')
                DB_ROOT_PASS_SECRET = credentials('db_root_pass')
            }
            steps {
                script {
                    sh "aws eks update-kubeconfig --name ${CLUSTER_NAME} --region ${CLUSTER_REGION}"

                    env.DB_USER = sh(script: 'echo -n $DB_USER_SECRET | base64', returnStdout: true).trim()
                    env.DB_PASS = sh(script: 'echo -n $DB_PASS_SECRET | base64', returnStdout: true).trim()
                    env.DB_NAME = sh(script: 'echo -n $DB_NAME_SECRET | base64', returnStdout: true).trim()
                    env.DB_ROOT_PASS = sh(script: 'echo -n $DB_ROOT_PASS_SECRET | base64', returnStdout: true).trim()

                    echo 'deploying new release to EKS...'
                    sh 'envsubst < java-app-cicd.yaml | kubectl apply -f -'
                    sh 'envsubst < db-config-cicd.yaml | kubectl apply -f -'
                    sh 'envsubst < db-secret-cicd.yaml | kubectl apply -f -'
                }
            }
        }
    }
}

