import boto3
import os

ec2 = boto3.client('ec2')
asg = boto3.client('autoscaling')

def lambda_handler(event, context):
    instance_id = event['detail']['instance-id']
    state = event['detail']['state']

    print(f"🔍 Instance {instance_id} changed state to {state}")

    if state == "stopped" or state == "terminated":
        print(f"Instance {instance_id} is unhealthy. Replacing...")
        try:
            response = ec2.describe_instances(InstanceIds=[instance_id])
            instance = response['Reservations'][0]['Instances'][0]
            ami_id = instance['ImageId']
            instance_type = instance['InstanceType']
            key_name = instance['KeyName']
            subnet_id = instance['SubnetId']
            security_group_ids = [sg['GroupId'] for sg in instance['SecurityGroups']]

            print("Launching replacement instance...")
            new_instance = ec2.run_instances(
                ImageId=ami_id,
                InstanceType=instance_type,
                KeyName=key_name,
                MaxCount=1,
                MinCount=1,
                NetworkInterfaces=[{
                    'AssociatePublicIpAddress': True,
                    'DeviceIndex': 0,
                    'SubnetId': subnet_id,
                    'Groups': security_group_ids
                }],
                TagSpecifications=[{
                    'ResourceType': 'instance',
                    'Tags': [{'Key': 'Name', 'Value': 'Self-Healing-EC2'}]
                }]
            )

            new_id = new_instance['Instances'][0]['InstanceId']
            print(f"New instance launched: {new_id}")

        except Exception as e:
            print(f"[Error] Error replacing instance: {str(e)}")
    else:
        print("Instance healthy. No action taken.")
