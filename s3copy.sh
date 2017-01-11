#S3 Bucket Validation
mybucket=`aws s3api list-buckets --query "Buckets[*].Name" --output text`
if [[ $mybucket == intuittest ]]; then
  return
else
  aws s3api create-bucket --bucket intuittest
  mybucket=`aws s3api list-buckets --query "Buckets[*].Name" --output text`
fi

#Copy Local file to S3 bucket
touch "/tmp/test-$(date +%F_%R)"
file=`ls -t /tmp/test* |head -1`
aws s3 cp $file s3://$mybucket/
