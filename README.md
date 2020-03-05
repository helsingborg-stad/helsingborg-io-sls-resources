# Serverless Framework (AWS)

## The concept

If you have a service that doesn’t make sense to replicate in an ephemeral environment, we would suggest moving it to the repo with all the infrastructure services. This setup scales well as your project and team grows.

# Setup

## Requirements

- AWS CLI
- AWS Account
- AWS IAM user
- Homebrew (macOS)
- NodeJS
- NPM
- Serverless Framework

## Resources

### Environment variables (SSM)

```
git clone https://github.com/helsingborg/helsingborg-io-sls-resources

cd helsingborg-io-sls-resources/parameterStore

chmod +x ssmPutParameter.sh

./ssmPutParameter.sh
```

### Certificates (S3 Bucket)

```
cd ../certificates
sls deploy
```

**Take a note of the Bucket ID.**

### Database

```
cd ../database
sls deploy
```
