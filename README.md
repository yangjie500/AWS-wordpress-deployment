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
under 
<br>
<b>/infra/providers.tf</b>
<br>
<b>/infra/ssm.tf resource local_file.tf_ansible_vars_file.provision</b>
<br>
rename profile and region to what you have configure above

Configure your own database username and password etc... at 
<br>
<b>/infra/variables.tf</b>

To Start
```bash
    terraform -chdir="infra" init
    cd ansible
    ansible-galaxy collection install community.mysql
    cd ..
    terraform -chdir="infra" apply
```



## Apply AWS SSM again AFTER you install wordpress (ONLY FIRST TIME)
Go the EC2 console under load balancer get LB_URL
and install wordpress with your credential

Go to AWS SSM under state manager reapply the Ansible playbook again

## Note if you want to be able to upload photo 
Under /var/www/html/wordpress/wp-content/
Create the following folder
```bash
cd /var/www/html/wordpress/wp-content/
mkdir uploads
mkdir uploads/(YEAR)/(MONTH) -p
chown nginx:nginx /var/www/html/wordpress/wp-content/uploads --recursive
chmod '0755' /var/www/html/wordpress/wp-content/uploads -R
```