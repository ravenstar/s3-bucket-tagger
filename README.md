# What
The current AWS CostExplorer does not provide insight into how much each S3 bucket costs.
This Bash script tags each S3 bucket with a corresponding 'BucketName' tag, allowing costs in CostExplorer to be evaulated by tags.

# Setup
 - `git clone https://github.com/ravenstar/s3-bucket-tagger`
 - `cd s3-bucket-tagger/`
 - `chmod a+x run.sh`
 - `./run.sh`
