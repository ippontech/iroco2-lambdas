import os
import boto3


class SQSRepository:
    def __init__(self):
        self.sqs_client = boto3.client(
            'sqs',        
            region_name=os.environ.get('REGION')                
        )

    def send_message(self, queue_url: str, message_body: str):
    
        response = self.sqs_client.send_message(
            QueueUrl=queue_url,
            MessageBody=message_body
        )
        return response
