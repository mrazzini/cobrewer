"""Cloudflare R2 (S3-compatible) storage service."""


async def upload_file(file_bytes: bytes, key: str, content_type: str) -> str:
    # TODO: implement boto3 upload to R2
    raise NotImplementedError
