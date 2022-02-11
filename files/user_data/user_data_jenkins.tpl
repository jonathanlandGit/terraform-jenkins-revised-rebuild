#!/bin/bash

sudo yum update –y

echo "=============JAVA==========="
# JRE
sudo yum install -y java-1.8.0-openjdk.x86_64
# JDK
sudo yum install -y java-1.8.0-openjdk-devel
sudo /usr/sbin/alternatives --set java /usr/lib/jvm/jre-1.8.0-openjdk.x86_64/bin/java
sudo /usr/sbin/alternatives --set javac /usr/lib/jvm/jre-1.8.0-openjdk.x86_64/bin/javac

echo"============AWSCLI================"
# sudo yum install -y awscli
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo unzip awscliv2.zip
sudo ./aws/install
rm awscliv2.zip

echo "=============Import the Jenkins key on load==========="
sudo yum install wget -y
sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins.io/redhat/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key

echo "=============New Jenkins install==========="
sudo amazon-linux-extras install epel -y
sudo yum update -y
sudo yum install jenkins -y
sudo systemctl daemon-reload

echo 'jenkins  ALL=(ALL:ALL) ALL' >> /etc/sudoers

echo "=============TERRAFORM==========="
wget https://releases.hashicorp.com/terraform/1.1.1/terraform_1.1.1_linux_amd64.zip -O terraform.zip
unzip terraform.zip
sudo mv terraform /usr/bin/
rm terraform.zip

echo "=============GIT==========="
sudo yum install git -y

echo "=============JQ==========="
sudo yum install jq -y

echo "=============NODEJS==========="
curl --silent --location https://rpm.nodesource.com/setup_16.x | sudo bash -
sudo yum -y install nodejs

echo "=============Lambda==========="
sudo npm install -g node-lambda

echo "=============Angular==========="
sudo npm install -g @angular/cli

echo "===========GRUNT==========="
sudo npm install -g grunt-cli
sudo npm install grunt --save

echo "=============BOWER============="
npm install -g bower

echo "=============DOCKER==========="
sudo yum install -y docker
sudo usermod -a -G docker jenkins
sudo service docker start

echo "============PYTHON============="
sudo amazon-linux-extras enable python3.8 -y
# sudo yum install python3.8
sudo python get-pip.py

echo "==========ANSIBLE================"
sudo python -m pip install ansible
sudo yum install ansible -y

echo "===========PACKER==============="
wget https://releases.hashicorp.com/packer/1.7.9/packer_1.7.9_linux_amd64.zip
sudo unzip packer_1.7.9_linux_amd64.zip -d /usr/local/bin

# npm
# grunt
# bower

# echo "=============PHP==========="
# sudo amazon-linux-extras install -y php7.2
# curl -sS https://getcomposer.org/installer -o composer-setup.php
# sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer

echo "=============COPYING ARTFS==========="
aws s3 cp s3://${s3_bucket}/${env_file} --region us-east-1 /var/lib/jenkins/init.groovy.d/
aws s3 cp s3://${s3_bucket}/${init_file} --region us-east-1 /var/lib/jenkins/init.groovy.d/
aws s3 cp s3://${s3_bucket}/${plugin_script} --region us-east-1 /var/lib/jenkins/setup/
aws s3 cp s3://${s3_bucket}/${plugin_file} --region us-east-1 /var/lib/jenkins/setup/

aws s3 cp s3://${s3_bucket}/${jobs_file} --region us-east-1 /tmp/
tar xzvf /tmp/jobs.tgz -C /var/lib/jenkins/
sudo chown jenkins /tmp/jobs.tgz

echo "NOW COPY INTO JENKINS..."

credResponse=$(aws s3 ls ${s3_bucket}/credentials.tgz)
if [[ $credResponse != "" ]]
then
    aws s3 cp s3://${s3_bucket}/credentials.tgz --region us-east-1 /tmp/
    tar xzvf /tmp/credentials.tgz -C /var/lib/jenkins/
    sudo chown jenkins /tmp/credentials.tgz
fi

conResponse=$(aws s3 ls ${s3_bucket}/config.xml)
if [[ $conResponse != "" ]]
then
    rm /var/lib/jenkins/config.xml
    aws s3 cp s3://${s3_bucket}/config.xml --region us-east-1 /var/lib/jenkins/
fi

gConResponse=$(aws s3 ls ${s3_bucket}/github-plugin-configuration.xml)
if [[ $gConResponse != "" ]]
then
    aws s3 cp s3://${s3_bucket}/github-plugin-configuration.xml --region us-east-1 /var/lib/jenkins/
fi

uResponse=$(aws s3 ls ${s3_bucket}/users.tgz)
if [[ $uResponse != "" ]]
then
    aws s3 cp s3://${s3_bucket}/users.tgz --region us-east-1 /tmp/
    tar xzvf /tmp/users.tgz -C /var/lib/jenkins/
    sudo chown jenkins /tmp/users.tgz
fi

nResponse=$(aws s3 ls ${s3_bucket}/nodes.tgz)
if [[ $nResponse != "" ]]
then
    aws s3 cp s3://${s3_bucket}/nodes.tgz --region us-east-1 /tmp/
    tar xzvf /tmp/nodes.tgz -C /var/lib/jenkins/
    sudo chown jenkins /tmp/nodes.tgz
fi

fResponse=$(aws s3 ls ${s3_bucket}/fingerprints.tgz)
if [[ $fResponse != "" ]]
then
    aws s3 cp s3://${s3_bucket}/fingerprints.tgz --region us-east-1 /tmp/
    tar xzvf /tmp/fingerprints.tgz -C /var/lib/jenkins/
    sudo chown jenkins /tmp/fingerprints.tgz
fi

mfResponse=$(aws s3 ls ${s3_bucket}/org.jenkinsci.plugins.configfiles.GlobalConfigFiles.xml)
if [[ $mfResponse != "" ]]
then
    aws s3 cp s3://${s3_bucket}/org.jenkinsci.plugins.configfiles.GlobalConfigFiles.xml --region us-east-1 /var/lib/jenkins/
fi

echo "jenkins is maybe installing, who knows..."
cd /var/lib/jenkins/setup
sh install-plugins.sh $(echo $(cat plugins.txt))
echo "=============starting jenkins==========="

sudo service jenkins start
systemctl enable jenkins
sudo systemctl status jenkins

# sudo systemctl start jenkins
# sudo systemctl enable jenkins
