import boto3

class S3Repository:

    def __init__(self):
        self.s3_ressource = boto3.resource('s3')

    def read_file(self, bucket_name: str, key_to_read: str):
        obj = self.s3_ressource.Object(bucket_name, key_to_read)
        response = obj.get()
        raw_content = response['Body'].read()
        return raw_content

