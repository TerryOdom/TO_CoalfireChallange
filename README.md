Coalfire SRE AWS Technical Challenge
====================================

This repository contains the solution for the Coalfire SRE AWS Technical Challenge. The project deploys a proof-of-concept AWS environment using Terraform, featuring a basic web server with proper network segmentation and security controls, following infrastructure-as-code best practices.

Solution Overview
-----------------

The Terraform configuration is fully modular and designed to be reusable and maintainable. It sets up the following resources:

1.  **Networking**: A custom VPC with a `10.1.0.0/16` CIDR block. It contains three subnets (`management`, `application`, `backend`) spread across two Availability Zones for high availability.

    -   The **management subnet** is public, allowing controlled access to a bastion host.
    -   The **application and backend subnets** are private. Instances in these subnets use a NAT Gateway for outbound internet access (e.g., for software updates) without being directly exposed.

2.  **Compute**:

    -   A **Management (Bastion) Host**: A single `t2.micro` EC2 instance in the public management subnet. Access is restricted via a security group to a specific IP address.
    -   An **Application Fleet**: An Auto Scaling Group (ASG) of `t2.micro` EC2 instances running Amazon Linux 2. The ASG maintains a minimum of 2 and a maximum of 6 instances across the private application subnets. A user data script installs and starts the Apache web server on each instance.

3.  **Load Balancing**: An Application Load Balancer (ALB) is deployed in the public subnets to distribute incoming web traffic across the EC2 instances in the ASG.

4.  **Security**: Security Groups are used to enforce a strict firewall policy.

    -   The ALB allows inbound HTTP traffic from anywhere.
    -   The application instances only accept traffic from the ALB and SSH traffic from the management host.
    -   The management host only accepts SSH traffic from a specified IP.

Architecture Diagram
--------------------

The following diagram illustrates the architecture of the deployed infrastructure.
<img width="3662" height="3840" alt="tc_challenge_diagram" src="https://github.com/user-attachments/assets/810d40b9-8b9f-4611-9f0f-84db8ac6d304" />

Deployment Instructions
-----------------------

### Prerequisites

-   [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli "null") installed (v1.0.0+).
-   [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html "null") installed and configured with appropriate credentials.


Part Two: Operational Analysis and Improvement Plan
---------------------------------------------------

### Analysis of Deployed Infrastructure

This infrastructure is a solid proof-of-concept, but for a production environment, it has several gaps.

-   **Security Gaps**:

    -   **No IAM Roles for EC2**: The EC2 instances don't have an IAM role attached so interaction with other AWS services is allowed. 
    -   **No WAF**: The Application Load Balancer is exposed to the internet without a WAF

-   **Availability Issues**:

    -   **Single NAT Gateway**: There is only one NAT Gateway for both private subnets. 
    -   **No Database Tier**: No DB prescence, just placeholders provided for the back-end

-   **Operational Shortcomings**:

    -   **No Monitoring or Alarms**: Nothing is inplace to monitor for application performance or resource utilization.
    -   **No Backups**: There is no automated backup strategy for the EC2 instances like snapshots

-   **Cost Optimization Opportunities**:

    -   **Instance Types**: t2.micro instances won't work for significant workloads.  A more robust EC2 may be needed depending on its use.


