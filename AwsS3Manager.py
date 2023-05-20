import boto3
from boto3.exceptions import S3UploadFailedError
from botocore.exceptions import ClientError


class AwsS3Manager:
    def __init__(self, aws_access_key_id, aws_secret_access_key, region_name='us-east-1', allowed_extensions=None):
        self.s3 = boto3.client('s3',
                               aws_access_key_id,
                               aws_secret_access_key,
                               region_name)
        self.allowed_extensions = allowed_extensions

    def upload_single(self, file_name, bucket_name, key_object, **kwargs):
        url = None
        try:
            response = self.s3.upload_file(file_name, bucket_name, key_object, ExtraArgs=kwargs)
            location = self.s3.get_bucket_location(Bucket=bucket_name)['LocationConstraint']
            url = f"https://{bucket_name}.s3.amazonaws.com/{key_object}"

        except S3UploadFailedError as e:
            print(str(e))
            return False
        except ClientError as e:
            print(str(e))
            return False

        return url

    def upload_multiple(self, files, bucket_name, key_object, **kwargs):
        urls = []
        for file in files:
            url = self.upload_single(file, bucket_name, key_object, **kwargs)
            if url:
                urls.append(url)
        return urls
