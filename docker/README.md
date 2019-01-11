Collection of scripts for working with Docker and ECR/ECS:

* Dockerfile:           App image
* docker-build.sh:      Builds an image
* ecr-push.sh:          Pushes it to ECR
* ecs-deploy-webapp.sh: Deploys the current app version to ECS
* docker-run-task.sh:   Runs a one-off rake task in Docker
* ecs-run-task.sh:      Runs a one-off rake task in ECS

These scripts must be run from the parent directory.
