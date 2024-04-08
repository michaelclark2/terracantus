resource "aws_s3_bucket" "uploads" {
  bucket = "terracantus-uploads"
}

resource "aws_s3_bucket_public_access_block" "uploads" {
  bucket                  = aws_s3_bucket.uploads.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "uploads" {
  bucket = aws_s3_bucket.uploads.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_policy" "uploads_policy" {
  bucket = aws_s3_bucket.uploads.id
  policy = jsonencode({
    Version : "2012-10-17"
    Statement : [{
      Sid : "PublicRead"
      Effect : "Allow"
      Principal : "*"
      Action : ["s3:GetObject"]
      Resource : ["arn:aws:s3:::terracantus-uploads/images/*", "arn:aws:s3:::terracantus-uploads/tracks/*"]
    }]
  })
}
