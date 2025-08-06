import os

from src.service.cur_processor_service import CurProcessorService


def lambda_handler(event, _context):
    cur_processor_service = CurProcessorService()

    cur_processor_service.parsing_cur_and_send_to_sqs(
        event['Records'][0]['s3']['bucket']['name'],
        event['Records'][0]['s3']['object']['key'],
        os.environ['QUEUE_URL']
    )
