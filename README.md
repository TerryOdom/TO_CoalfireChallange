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

```
graph TD
    subgraph "AWS Cloud"
        subgraph "VPC (10.1.0.0/16)"
            subgraph "Availability Zone A"
                subgraph "Public Subnet (Management)"
                    ec2_mgmt("EC2 Management Host")
                end
                subgraph "Private Subnet (Application)"
                    ec2_app_1("EC2 App Host 1")
                end
                 subgraph "Private Subnet (Backend)"
                    backend_1("...")
                end
            end

            subgraph "Availability Zone B"
                subgraph "Public Subnet (Management)"
                    alb("Application Load Balancer")
                end
                subgraph "Private Subnet (Application)"
                    ec2_app_2("EC2 App Host 2")
                end
                 subgraph "Private Subnet (Backend)"
                    backend_2("...")
                end
            end

            igw("Internet Gateway")
            nat("NAT Gateway")

            ec2_mgmt -- "SSH" --> ec2_app_1
            ec2_mgmt -- "SSH" --> ec2_app_2
            alb -- "HTTP" --> asg
            asg(Auto Scaling Group) --- ec2_app_1
            asg --- ec2_app_2
        end
    end

    user("User") -- "SSH" --> ec2_mgmt
    internet("Internet") -- "HTTP" --> alb
    ec2_app_1 -- "Outbound" --> nat
    ec2_app_2 -- "Outbound" --> nat
    nat -- "Outbound" --> igw
    internet -- "Inbound" --> igw
    igw -- "Inbound" --> alb
    igw -- "Inbound" --> ec2_mgmt

```

Deployment Instructions
-----------------------

### Prerequisites

-   [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli "null") installed (v1.0.0+).

-   [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html "null") installed and configured with appropriate credentials.

-   An existing AWS EC2 Key Pair for SSH access.

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

### Evidence of Successful Deployment

After running `terraform apply`, you will see an output similar to this:

```
Apply complete! Resources: 25 added, 0 changed, 0 destroyed.

Outputs:

alb_dns_name = "your-alb-dns-name.us-east-1.elb.amazonaws.com"

```

You can access the web server by pasting the `alb_dns_name` into your browser. You should see a "Hello World" message.

**(You would include screenshots here of the successful `terraform apply` output and the web page served by the ALB)**
