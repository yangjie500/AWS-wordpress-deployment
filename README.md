# AWS Autoscaling Wordpress
Using Terraform to initialise AWS Cloud Infrastructures and Ansible to make state configuration to EC2 instances (Amazon-Linux 2)

## How to start
Download AWS CLI v2
```bash
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
```
Configure AWS Credential

First log into AWS console and go IAM services to get API Key then configure using 
```bash
    aws configure
```
under <span style="color:#49fb35">/infra/providers.tf</span> rename profile and region to what you have configure above

To Start
```bash
    terraform -chdir="infra" init
    cd ansible
    ansible-galaxy collection install community.mysql
    cd ..
    terraform -chdir="infra" apply
```

Configure your own database username and password etc... at <span style="color:#49fb35">/infra/variables.tf</span>