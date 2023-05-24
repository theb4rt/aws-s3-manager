#!/bin/bash
# Upload files to AWS S3 bucket
upload_single() {
    local file_name=$1
    local bucket_name=$2
    local key_object=$3

    aws s3 cp "$file_name" "s3://$bucket_name/$key_object" || return 1
    echo "https://${bucket_name}.s3.amazonaws.com/${key_object}"
}

# Upload multiple files to AWS S3 bucket
upload_multiple() {
    local bucket_name=$1
    local key_object=$2
    shift 2
    local files=("$@")

    local urls=()
    for file in "${files[@]}"; do
        url=$(upload_single "$file" "$bucket_name" "$key_object") || continue
        urls+=("$url")
    done

    for url in "${urls[@]}"; do
        echo "$url"
    done
}

# Search files in AWS S3 bucket
search_files() {
    local bucket_name=$1
    local prefix=$2

    aws s3 ls "s3://$bucket_name/$prefix"
}

# Get bucket location
get_bucket_location() {
    local bucket_name=$1

    aws s3api get-bucket-location --bucket "$bucket_name" --query 'LocationConstraint'
}

# Create bucket
create_bucket() {
    local bucket_name=$1
    local region=$2

    if aws s3api create-bucket --bucket "$bucket_name" --region "$region" --create-bucket-configuration LocationConstraint="$region"; then
        echo "Bucket $bucket_name created successfully in $region"
        echo "https://${bucket_name}.s3.amazonaws.com/"
    else
        echo "Error creating bucket $bucket_name in $region"
        return 1
    fi
}
