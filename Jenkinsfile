/* import shared library */
@Library('shared_library')_
pipeline {
    environment {

        IMAGE_NAME = "${PARAM_IMAGE_NAME}"                    /*staticwebsite*/
        APP_NAME = "${PARAM_APP_NAME}"                        /*younesabdh*/
        IMAGE_TAG = "${PARAM_IMAGE_TAG}"                      /*v2*/
        
        STAGING = "${PARAM_APP_NAME}-staging"
        PRODUCTION = "${PARAM_APP_NAME}-prod"
        DOCKERHUB_USR = "${PARAM_DOCKERHUB_ID}"
        DOCKERHUB_PSW = credentials('dockerhub')
        APP_EXPOSED_PORT = "${PARAM_PORT_EXPOSED}"            /*80 by default*/

        STG_API_ENDPOINT = "${PARAM_STG_API_ENDPOINT}"
        STG_APP_ENDPOINT = "${PARAM_STG_APP_ENDPOINT}"
        PROD_API_ENDPOINT = "${PARAM_PROD_API_ENDPOINT}"
        PROD_APP_ENDPOINT = "${PARAM_PROD_APP_ENDPOINT}"
        
        INTERNAL_PORT = "${PARAM_INTERNAL_PORT}"              /*5000 ny default*/
        EXTERNAL_PORT = "${PARAM_PORT_EXPOSED}"
        CONTAINER_IMAGE = "${DOCKERHUB_USR}/${IMAGE_NAME}:${IMAGE_TAG}"
    }
    /*
    parameters {
        // booleanParam(name: "RELEASE", defaultValue: false)
        // choice(name: "DEPLOY_TO", choices: ["", "INT", "PRE", "PROD"])
        string(name: 'PARAM_APP_NAME', defaultValue: 'abdelhamid', description: 'App Name')
        string(name: 'PARAM_IMAGE_NAME', defaultValue: 'static-web', description: 'Image Name')
        string(name: 'PARAM_IMAGE_TAG', defaultValue: 'v2', description: 'Image Tag')
        string(name: 'PARAM_PORT_EXPOSED', defaultValue: '8060', description: 'APP EXPOSED PORT')
        string(name: 'PARAM_INTERNAL_PORT', defaultValue: '80', description: 'APP INTERNAL PORT')
        string(name: 'PARAM_DOCKERHUB_ID', defaultValue: 'olivierkkoc', description: 'dockerhub')
        string(name: 'PARAM_STG_API_ENDPOINT', defaultValue: '3.80.158.216:1993', description: 'STG EAZYLABS API')
        string(name: 'PARAM_STG_APP_ENDPOINT', defaultValue: '3.80.158.216', description: 'STG EAZYLABS APP')
        string(name: 'PARAM_PROD_API_ENDPOINT', defaultValue: '3.94.159.126:1993', description: 'PROD EAZYLABS API')
        string(name: 'PARAM_PROD_APP_ENDPOINT', defaultValue: '3.94.159.126', description: 'PROD EAZYLABS APP')
    }
    */
    agent none
    stages {
        stage('Build image') {
            agent any
            steps {
                script {
                    sh 'docker build -t ${DOCKERHUB_USR}/$IMAGE_NAME:$IMAGE_TAG .'
                }
            }
        }
        stage('Run container based on built image'){
            agent any
            steps {
                script{
                    sh '''
                        echo "Cleaning existing container if exists"
                        docker ps -a | grep -i $IMAGE_NAME && docker rm -f $IMAGE_NAME
                        docker run --name $IMAGE_NAME -d -p $APP_EXPOSED_PORT:$INTERNAL_PORT -e PORT=$INTERNAL_PORT ${DOCKERHUB_USR}/$IMAGE_NAME:$IMAGE_TAG
                        sleep 5
                    '''
                }
            }
        }
        stage('Test image') {
            agent any
            steps{
                script {
                    sh '''
                        curl http://172.17.0.1:$APP_EXPOSED_PORT | grep -i "Dimension"
                    '''
                }
            }
        }
        stage('Clean container') {
            agent any
            steps{
                script {
                    sh '''
                        docker stop $IMAGE_NAME
                        docker rm $IMAGE_NAME
                    '''
                }
            }
        }
        stage('Login and Push Image on Docker Hub') {
            when{
                expression {GIT_BRANCH == 'origin/master'}
            }
            agent any
            steps{
                script {
                    sh '''
                        echo $DOCKERHUB_PSW | docker login -u $DOCKERHUB_USR --password-stdin
                        docker push $DOCKERHUB_USR/$IMAGE_NAME:$IMAGE_TAG
                    '''
                }
            }
        }
        stage('STAGING - Deploy app') {
            agent any
            steps {
                script {
                    sh """
                        echo  {\\"your_name\\":\\"${APP_NAME}\\",\\"container_image\\":\\"${CONTAINER_IMAGE}\\", \\"external_port\\":\\"${EXTERNAL_PORT}\\", \\"internal_port\\":\\"${INTERNAL_PORT}\\"}  > data.json 
                        curl -k -v -X POST http://${STG_API_ENDPOINT}/staging -H 'Content-Type: application/json'  --data-binary @data.json  2>&1 | grep 200
                    """
                }
            }
        }
        stage('PROD - Deploy app') {
            when {
                expression { GIT_BRANCH == 'origin/master' }
            }
            agent any
            steps {
                script {
                sh """
                    echo  {\\"your_name\\":\\"${APP_NAME}\\",\\"container_image\\":\\"${CONTAINER_IMAGE}\\", \\"external_port\\":\\"${EXTERNAL_PORT}\\", \\"internal_port\\":\\"${INTERNAL_PORT}\\"}  > data.json 
                    curl -k -v -X POST http://${PROD_API_ENDPOINT}/prod -H 'Content-Type: application/json'  --data-binary @data.json  2>&1 | grep 200
                """
                }
            }
        }
    }
  post {
    always {
      script {
        slackNotifier currentBuild.result
      }
    }  
  }
}
