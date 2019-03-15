This directory contains a Dockerfile and a collection of scripts for working
with Docker and ECR/ECS:

* docker-build.sh:      Builds an image
* ecr-push.sh:          Pushes it to ECR
* ecs-deploy-webapp.sh: Deploys the current app version to ECS
* docker-run-task.sh:   Runs a one-off rake task locally in Docker
* ecs-run-task.sh:      Runs a one-off rake task in ECS

These scripts must be run from the parent (application root) directory.

For the ones that access AWS, you must be logged into AWS using `aws login`.
