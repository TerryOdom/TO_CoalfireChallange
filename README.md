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

### Deployment Steps

1.  **Clone the Repository**:

    ```
    git clone <your-repo-url>
    cd <your-repo-directory>

    ```

2.  **Prepare Terraform Variables**: Create a `terraform.tfvars` file by copying the example file.

    ```
    cp terraform.tfvars.example terraform.tfvars

    ```

    Edit `terraform.tfvars` and provide values for the variables, such as your IP address and the name of your EC2 key pair.

3.  **Initialize Terraform**: Run `terraform init` to initialize the backend and download the necessary providers.

    ```
    terraform init

    ```

4.  **Plan the Deployment**: Run `terraform plan` to review the resources that will be created.

    ```
    terraform plan -out=tfplan

    ```

5.  **Apply the Configuration**: Apply the plan to create the AWS resources.

    ```
    terraform apply "tfplan"

    ```

Upon successful completion, Terraform will output the DNS name of the Application Load Balancer.

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

**Runbook-style notes**

o Q-How would someone else deploy and operate your environment?
    A-I encountered issues trying to deploy to AWS.  My intent was to have a repo that could be cloned and deployed via Terraform in AWS

o Q-How would you respond to an outage for the EC2 instance?
    A-If the EC2 is accessible I would try a restart, then review logs to get specifics.  Considering the size of the EC2 for the challange I would consider a larger EC2 to help avoid outages

o Q-How would you restore data if the S3 bucket were deleted?
    A-I like to use lifecycle management with S3 to archive older data, this would help with restoring data

**Research Resources**

https://developer.hashicorp.com/terraform/tutorials/modules/module
https://spacelift.io/blog/terraform-files
https://dev.to/patdevops/building-reusable-infrastructure-with-terraform-modules-625
https://medium.com/@tahirbalarabe2/security-best-practices-for-aws-vpc-15832e1c6326
https://www.hyperglance.com/blog/aws-vpc-security-best-practices/
https://spacelift.io/blog/terraform-alb
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule
https://docs.gruntwork.io/reference/modules/terraform-aws-load-balancer/lb-listener-rules/
https://spacelift.io/blog/terraform-ec2-instance
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group
https://natworked.medium.com/creating-an-aws-ec2-instance-with-bash-user-data-script-to-install-apache-web-server-34cb4ba160bf
https://gist.github.com/herrera-ignacio/4d91ae564364f9120720f6bf029b9412
https://www.thinkstack.co/blog/using-terraform-to-create-an-ec2-instance-with-cloudwatch-alarm-metrics
https://developer.hashicorp.com/terraform/tutorials/aws/aws-asg
https://blog.avangards.io/5-tips-to-efficiently-manage-aws-security-groups-using-terraform
https://www.itwonderlab.com/aws-terraform-tutorial-aws-routing-tables/
https://dev.to/chinmay13/placing-ec2-webserver-instances-in-a-private-subnet-with-internet-access-via-nat-gateway-using-terraform-167n
https://businesscompassllc.com/how-to-set-up-a-private-nat-gateway-with-terraform-a-step-by-step-guide/
https://www.itwonderlab.com/aws-terraform-tutorial-aws-nat-gateway/
https://dev.to/charlesuneze/securing-your-vpc-using-public-private-subnets-2lcb
https://spacelift.io/blog/terraform-aws-vpc
https://docs.aws.amazon.com/prescriptive-guidance/latest/terraform-aws-provider-best-practices/structure.html
https://www.stormit.cloud/blog/aws-high-availability-architecture/
https://docs.gruntwork.io/reference/modules/terraform-aws-load-balancer/lb-listener-rules/
https://www.finops.org/wg/cost-optimization-for-aws-ec2-autoscaling/
https://aws.amazon.com/aws-cost-management/cost-optimization/
https://medium.com/@Muriithi_nancy/securing-aws-cloud-environments-a-practical-approach-to-aws-security-best-practices-ed9f6a386035
https://spacelift.io/blog/terraform-security-group
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm
https://dev.to/chinmay13/getting-started-with-aws-and-terraform-setting-up-cloudwatch-alarms-for-cpu-utilization-on-aws-ec2-instances-with-terraform-14l2
https://medium.com/@mattiamazzari/auto-scaling-with-cloudwatch-scaling-alarms-using-terraform-dbd83211fd17
https://miro.com/diagramming/aws-architecture-diagram/
https://www.reddit.com/r/learnprogramming/comments/vxfku6/how_to_write_a_readme/
https://github.com/banesullivan/README
https://medium.com/be-tech-with-santander/how-to-create-a-readme-md-for-projects-with-terraform-docs-b9ce7a969b34
