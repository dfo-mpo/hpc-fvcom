# Requirements
- [ ] Parent directory has SSH (both public and private) keys generated with ssh-keygen for ubuntu/hpc users
- [ ] Environment Variables defined (as per below)
- [ ] Storage account has a blob named 'roms'
- [ ] S3 bucket exists ( s3://dfohpc/fvcom ) 


## Environment Variables
Must be defined before running terraform/ansible.
### Azure
````
echo "Setting environment variables for Terraform"
export ARM_SUBSCRIPTION_ID=abc-123-etc
export ARM_CLIENT_ID=abc-123-etc
export ARM_CLIENT_SECRET=abc-123-etc
export ARM_TENANT_ID=abc-123-etc
export ARM_ENVIRONMENT=public

export SAS_URL="https://myblob.blob.core.windows.net/fvcom?st=2019-05-31T12%3A28%3A32Z&se=2019-11-03T12%3A28%3A00Z&sp=racwdl&sv=2018-03-28&sr=c&sig=accesskey"
````

### AWS
````
export AWS_ACCESS_KEY_ID="dfg"
export AWS_SECRET_ACCESS_KEY="Sas32rsfad"
export AWS_DEFAULT_REGION="us-east-1"
````