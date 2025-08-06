import re


class CorrelationIdUtil:
    @staticmethod
    def determine_correlation_id_from_s3_file_name(s3_file_name):
        uuid_pattern = re.compile(r'\b[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\b')
        correlation_id = uuid_pattern.search(s3_file_name).group(0)
        return correlation_id
