import pandas as pd
import json
import os
import re
import isodate

from io import StringIO
from datetime import timedelta
from src.repository.s3_repository import S3Repository
from src.repository.sqs_repository import SQSRepository
from src.service.correlation_id_util import CorrelationIdUtil
from src.service.cur_processor_EC2_service import CurProcessorEC2Service
from src.service.cur_processor_S3_service import CurProcessorS3Service


class CurProcessorService:

    def __init__(self):
        self.s3_repository = S3Repository()
        self.sqs_repository = SQSRepository()
        self.cur_processor_ec2_service = CurProcessorEC2Service()
        self.cur_processor_s3_service = CurProcessorS3Service()

    def parsing_cur_and_send_to_sqs(self, bucket_name, s3_file_name, queue_url):
        cur_file_type = os.path.splitext(s3_file_name)[1].replace(".", "")
        print(cur_file_type)
        cur = self.s3_repository.read_file(bucket_name, s3_file_name)
        message_parsed = []
        parsed_ec2_message = self.cur_processor_ec2_service.creating_message_from_cur(cur, cur_file_type)
        parsed_s3_message = self.cur_processor_s3_service.creating_message_from_cur(cur, cur_file_type)
        message_parsed.extend(parsed_ec2_message)
        message_parsed.extend(parsed_s3_message)
        self.__send_message_parsed_to_sqs(message_parsed, s3_file_name, queue_url)

    def __send_message_parsed_to_sqs(self, messages_parsed, s3_file_name, queue_url):
        total_message_sent = len(messages_parsed)
        correlation_id = CorrelationIdUtil.determine_correlation_id_from_s3_file_name(s3_file_name)

        for message_parsed in messages_parsed:
            message_parsed["correlationId"] = correlation_id
            message_parsed["numberOfMessageExpected"] = total_message_sent
            self.sqs_repository.send_message(queue_url, json.dumps(message_parsed))
