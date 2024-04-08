resource "aws_s3_bucket" "staticfiles" {
  bucket = "terracantus-staticfiles"

}

resource "aws_s3_bucket_public_access_block" "staticfiles" {
  bucket                  = aws_s3_bucket.staticfiles.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "staticfiles" {
  bucket = aws_s3_bucket.staticfiles.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_policy" "staticfiles_policy" {
  bucket = aws_s3_bucket.staticfiles.id
  policy = jsonencode({
    Version : "2012-10-17"
    Statement : [{
      Sid : "PublicRead"
      Effect : "Allow"
      Principal : "*"
      Action : ["s3:GetObject"]
      Resource : ["arn:aws:s3:::terracantus-staticfiles/*"]
    }]
  })
}
