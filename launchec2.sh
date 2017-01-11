################################################################################################################
# VPC Creation
#http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/vpc-subnets-commands-example.html
aws ec2 create-vpc --cidr-block 10.0.0.0/16

vpc_id=`aws ec2 describe-vpcs --query "Vpcs[*].VpcId" --output text`
aws ec2 create-subnet --vpc-id $vpc_id --cidr-block 10.0.1.0/24

#Make Subnet Public
#Internet Gateway Creation
aws ec2 create-internet-gateway

gateway_id=`aws ec2 describe-internet-gateways --query "InternetGateways[*].InternetGatewayId" --output text`

#Attach Internet Gateway to VPC
aws ec2 attach-internet-gateway --vpc-id $vpc_id --internet-gateway-id $gateway_id

#Custom Route Table Creation
aws ec2 create-route-table --vpc-id $vpc_id

routetable_id=`aws ec2 describe-route-tables --query "RouteTables[1].RouteTableId" --output text`

#Create Route in the Route Table
aws ec2 create-route --route-table-id $routetable_id --destination-cidr-block 0.0.0.0/0 --gateway-id $gateway_id

subnet_id=`aws ec2 describe-subnets --query "Subnets[*].SubnetId" --output text`
aws ec2 associate-route-table  --subnet-id $subnet_id --route-table-id $routetable_id

#Public IP Mapping
aws ec2 modify-subnet-attribute --subnet-id $subnet_id --map-public-ip-on-launch

################################################################################################################
#Security Group
aws ec2 create-security-group --group-name MySecurityGroup --description "My security group" --vpc-id $vpc_id
security_gid=`aws ec2 describe-security-groups --query 'SecurityGroups[?starts_with(Description, `My`) == `true`].GroupId' --output text`

aws ec2 authorize-security-group-ingress --group-id $security_gid --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $security_gid --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $security_gid --protocol tcp --port 443 --cidr 0.0.0.0/0

################################################################################################################
#Launch EC2
image_id="ami-1e299d7e"
keyname=`aws ec2 describe-key-pairs --query "KeyPairs[*].KeyName" --output text`

aws ec2 run-instances --image-id $image_id --count 1 --instance-type t2.micro --key-name $keyname --security-group-ids $security_gid --subnet-id $subnet_id
