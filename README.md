# API Platform Resources - Serverless Framework - AWS

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
- [Serverless Framework](https://serverless.com/)

### AWS CLI (Homebrew on macOS)

```
brew install awscli
```

### Create an AWS Account (Personal)

- [Create an account here](https://portal.aws.amazon.com/billing/signup#/start)

### Create an AWS IAM User

- Please follow [this](https://serverless-stack.com/chapters/create-an-iam-user.html) guide

**Take a note of the Access key ID and Secret access key.**

### Adding your access key for the IAM User to AWS CLI

It should look something like this:

- **Access key ID:** AKIAIOSFODNN7EXAMPLE
- **Secret access key:** wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

Simply run the following with your Secret Key ID and your Access Key.

(You can leave the **Default region** name and **Default output** format the way they are)

```
aws configure
```

### Serverless Framework

The Serverless Framework helps you develop and deploy your AWS Lambda functions, along with the AWS infrastructure resources they require.

```
npm install serverless -g
```

## Usage

Clone this repo.

```
git clone git@github.com:helsingborg-stad/helsingborg-io-sls-resources.git
```

### Environment variables (SSM)

```
cd helsingborg-io-sls-resources/services/parameterStore

chmod +x ssmPutParameter.sh

./ssmPutParameter.sh
```

### Certificates (S3 Bucket)

```
cd ../certificates
sls deploy
```

**Take a note of the generated bucket name.**

### Database (DynamoDB)

```
cd ../database
sls deploy
```

Once you deploy the resources in this repo, head over to this [accompanying repo](https://github.com/helsingborg-stad/helsingborg-io-sls-api) to deploy the API services.
