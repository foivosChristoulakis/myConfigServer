#!/usr/bin/env groovy

pipeline{
	agent any
	
	environment{

		def CREDENTIALS_ID = "ecr:eu-west-2:awsCredentials"
		def REPO = "754250089381.dkr.ecr.eu-west-2.amazonaws.com/adlgallery" //may contain '/'.
		
		def SERVICE_NAME = "configService"
		def TASK_FAMILY =  "deploysimpleserver"
		def ECS_CLUSTER =  "web-servers-cluster"
		def REGION = "eu-west-2"
	}
	
	stages{

		stage('Checkout') {
			steps{
				// Clone config server repository
				checkout scm
				
				}
			}
		
		
		stage('Load env vars') {
			steps{
				load "environmentProperties.groovy"
				script{
					IMAGE_TAG = "${ENVDEV}-latest"
				}
			}
		}
		
		stage('Bake docker image') {
			steps{
				script{
					DCR_IMAGE = docker.build ("coral-epos2-infra-config:${IMAGE_TAG}", "--build-arg=devEnvDockerArg=${ENVDEV} .")
				}
			}
		}
		
		stage('Renew docker aws authorisation token') {
			steps{
				script{
					sh "eval \$(aws ecr get-login --no-include-email --region ${REGION})"
				}	
			}
		}
		
		stage('Deploy to ecr repo') {
			steps{
				script{
					docker.withRegistry("https://${REPO}", "${CREDENTIALS_ID}") {
						DCR_IMAGE.push("${IMAGE_TAG}")
					}
				}	
			}
		}
				
		stage("Update service") {
			steps{
				script{
					
					// Process container definitions template -> export containerDef.json
					REPOESCAPED = REPO.replace("/", "\\/")
					sh """
						#echo ${REPOESCAPED}
						sed -e \"s/__imageName__/${REPOESCAPED}/\" -e \"s/__imageTag__/${IMAGE_TAG}/\" containersDef.jsonTemplate > containersDef.json
					"""
					
					// Create new task definition revision
					sh  "aws ecs register-task-definition --family ${TASK_FAMILY} --cli-input-json file://containersDef.json --region ${REGION}"
					
					// Get the latest task revision
					TASK_REVISION = sh (
						script: "aws ecs describe-task-definition --task-definition ${TASK_FAMILY} | egrep \"revision\" | tr \"/\" \" \" | awk '{print \$2}' | sed 's/\"\$//'",
						returnStdout: true
					).trim()
					
					// Get desired task count currently deployed on the service
					DESIRED_COUNT = sh (
						script: "aws ecs describe-services --cluster ${ECS_CLUSTER} --services ${SERVICE_NAME} | egrep \"desiredCount\"  | tr \"/\" \" \"| awk '{print \$2}'| sed 's/,\$//'| sed -n 1p",
						returnStdout: true
					).trim()
					
					// Update the service.
					sh "aws ecs update-service --cluster ${ECS_CLUSTER} --service ${SERVICE_NAME} --task-definition ${TASK_FAMILY}:${TASK_REVISION} --desired-count ${DESIRED_COUNT} > /dev/null"
				
				}
			}
		}

	}
}