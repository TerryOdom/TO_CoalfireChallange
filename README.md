# TO_CoalfireChallange
Used for take home Terraform challenge from Coalfire

# AWS VPC Terraform Infrastructure

This Terraform project deploys a basic networking infrastructure in AWS according to the following requirements:

-   1 VPC with CIDR `10.1.0.0/16`.
-   3 Subnets, each with a `/24` CIDR block, spread across two Availability Zones.
-   **Management Subnet**: A public subnet with a route to the Internet Gateway. Instances launched here will get a public IP address.
-   **Application Subnet**: A private subnet with no direct internet access.
-   **Backend Subnet**: A private subnet with no direct internet access.

## Architecture Diagram


## How to Use

### Prerequisites
-   [Terraform](https://developer.hashicorp.com/terraform/downloads) installed.
-   [AWS CLI](https://aws.amazon.com/cli/) installed and configured with your credentials.

### Deployment Steps
1.  **Clone the repository:**
    ```sh
    git clone <your-repo-url>
    cd <your-repo-name>
    ```

2.  **Initialize Terraform:**
    This command downloads the necessary provider plugins.
    ```sh
    terraform init
    ```

3.  **Plan the deployment:**
    This command shows you what resources will be created.
    ```sh
    terraform plan
    ```

4.  **Apply the configuration:**
    This command builds the resources in your AWS account.
    ```sh
    terraform apply
    ```
    Enter `yes` when prompted to confirm.

### Cleanup
To destroy all the resources created by this configuration, run:
```sh
terraform destroy
```