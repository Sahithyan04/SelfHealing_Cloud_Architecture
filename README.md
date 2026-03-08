# Self-Healing Cloud Infrastructure

This project demonstrates a basic self-healing infrastructure pattern using Infrastructure as Code and serverless automation. The system monitors the health of an EC2 instance and automatically replaces it if it becomes unhealthy.

## Overview

The architecture provisions an EC2 instance using Terraform and monitors its health using CloudWatch. When an instance failure is detected, a Lambda function is triggered to terminate the unhealthy instance and launch a replacement instance automatically.

The project was tested locally using LocalStack to simulate AWS services without incurring cloud costs.

## Architecture Components

- **Terraform** – Infrastructure as Code for provisioning resources
- **EC2** – Compute instance being monitored
- **CloudWatch** – Detects instance health failures
- **SNS** – Sends alarm notifications
- **AWS Lambda** – Executes the self-healing logic
- **IAM** – Manages permissions for EC2 and Lambda
- **LocalStack** – Local AWS service emulator for testing

## Workflow

1. Terraform deploys EC2, IAM roles, Lambda, SNS, and CloudWatch alarms.
2. CloudWatch monitors EC2 health metrics.
3. When an instance becomes unhealthy, CloudWatch triggers an SNS notification.
4. SNS invokes the Lambda function.
5. The Lambda function identifies the failed instance and launches a replacement.

## Project Structure
self-healing-infra/
│
├── Terraform/
│ ├── main.tf
│ ├── lambda.tf
│ ├── provider.tf
│ ├── variables.tf
│ ├── outputs.tf
│ └── terraform.tfvars
│
├── Scripts/
│ ├── lambda_function.py
│ └── setup.sh
│
└── README.md


## Deployment

1. Start LocalStack (optional for local testing).

2. Initialize Terraform:
terraform init

3. Apply the infrastructure:
terraform apply


4. Verify resources using the AWS CLI or LocalStack endpoint.

## Purpose

This project demonstrates concepts related to cloud automation, infrastructure resilience, and event-driven serverless architecture.
