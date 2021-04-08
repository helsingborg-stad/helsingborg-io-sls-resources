<!-- SHIELDS -->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![License][license-shield]][license-url]

<p>
  <a href="https://github.com/helsingborg-stad/helsingborg-io-sls-resources">
    <img src="images/hbg-github-logo-combo.png" alt="Logo" width="300">
  </a>
</p>
<h3>API Platform Resources - Serverless Framework - AWS</h3>
<p>
  Services that run on Helsingborgs stads API platform <a href="https://helsingborg.io/">helsingborg.io</a>
  <br />
  <a href="https://github.com/helsingborg-stad/helsingborg-io-sls-resources/issues">Report Bug</a>
  ·
  <a href="https://github.com/helsingborg-stad/helsingborg-io-sls-resources/issues">Request Feature</a>
</p>


## Table of Contents
- [Setup](#setup)
  - [Prerequisites](#prerequisites)
    - [AWS CLI (Homebrew on macOS)](#aws-cli-homebrew-on-macos)
    - [Create an AWS Account (Personal)](#create-an-aws-account-personal)
    - [Create an AWS IAM User](#create-an-aws-iam-user)
    - [Adding your access key for the IAM User to AWS CLI](#adding-your-access-key-for-the-iam-user-to-aws-cli)
    - [Serverless Framework](#serverless-framework)
  - [Installation](#installation)
    - [Environment variables (SSM)](#environment-variables-ssm)
    - [Certificates (S3 Bucket)](#certificates-s3-bucket)
    - [Database (DynamoDB)](#database-dynamodb)
  - [KMS](#kms)
    - [Prerequisites](#prerequisites-1)
    - [Create and import key in AWS](#create-and-import-key-in-aws)
  - [Roadmap](#roadmap)
  - [Contributing](#contributing)
  - [License](#license)


## About API Platform Resources

If you have a service that doesn’t make sense to replicate in an ephemeral environment, we would suggest moving it to the repo with all the infrastructure services. This setup scales well as your project and team grows.

# Setup

## Prerequisites

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

## Installation

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


## KMS
If you do not want to use AWS own generated keys you can generate your own key with *openssl* and later import the key into your AWS environment.
Use 

### Prerequisites
- openssl version 1.0.2 or later
- AWS CLI version 2
- jq (cli tool)


If on macOS Make sure you are using openssl and not libressl.
```
openssl version
```

If using libressl, install openssl brew and use the full path to encrypt your key before import.  
```
brew install openssl
brew info openssl
```

### Create and import key in AWS 
First create the key storage space in AWS KMS.  
Modify the REGION and KEY_ALIAS exports to fit your naming scheme and AWS region.  
```
export REGION=eu-north-1
export KEY_ALIAS=external/master
export KEY_ID=`aws kms create-key --region $REGION --origin EXTERNAL --description $KEY_ALIAS --query KeyMetadata.KeyId --output text`
aws kms --region $REGION create-alias --alias-name alias/$KEY_ALIAS --target-key-id $KEY_ID
```

Get the nessesary files to encrypt your key from AWS, they will end up in your current working directory as PublicKey.bin and ImportToken.bin
```
export KEY_PARAMETERS=`aws kms --region $REGION get-parameters-for-import --key-id $KEY_ID --wrapping-algorithm RSAES_OAEP_SHA_256 --wrapping-key-spec RSA_2048 --output json`
echo $KEY_PARAMETERS | jq -r .PublicKey | base64 --decode > PublicKey.bin
echo $KEY_PARAMETERS | jq -r .ImportToken | base64 --decode > ImportToken.bin
```

Generate the 256-bit symmetric key material.
```
dd if=/dev/urandom of=PlaintextKeyMaterial.bin bs=32 count=1
```

Encrypt your key material with the AWS tokens and key.
```
/usr/local/opt/openssl@1.1/bin/openssl pkeyutl -in PlaintextKeyMaterial.bin -out EncryptedKeyMaterial.bin -inkey PublicKey.bin -keyform DER -pubin -encrypt -pkeyopt rsa_padding_mode:oaep -pkeyopt rsa_oaep_md:sha256
```

Import the key to AWS KMS.
```
aws kms --region $REGION import-key-material --key-id $KEY_ID --encrypted-key-material fileb://EncryptedKeyMaterial.bin --import-token fileb://ImportToken.bin --expiration-model KEY_MATERIAL_DOES_NOT_EXPIRE
```

Check the status when done, status should be `Enabled`. 
```
aws kms --region $REGION describe-key --key-id $KEY_ID
```

To make arn dynamic you can reference your created key in serverless.yml files by constructing the ARN like this with your KEY_ALIAS as a suffix
```
arn:aws:kms:${AWS::Region}:${AWS::AccountId}:alias/{KEY ALIAS}
```

Following this example, the arn would be
```
arn:aws:kms:${AWS::Region}:${AWS::AccountId}:alias/external/master
```

## Roadmap
This repo is part of a project called Mitt Helsingborg. See the [project backlog](https://share.clickup.com/l/h/6-33382576-1/763b706816dbf53) for a complete list of upcoming features, known issues and releases.



## Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feat/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feat/AmazingFeature`)
5. Open a Pull Request



## License

Distributed under the [MIT License][license-url].

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/helsingborg-stad/helsingborg-io-sls-resources.svg?style=flat-square
[contributors-url]: https://github.com/helsingborg-stad/helsingborg-io-sls-resources/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/helsingborg-stad/helsingborg-io-sls-resources.svg?style=flat-square
[forks-url]: https://github.com/helsingborg-stad/helsingborg-io-sls-resources/network/members
[stars-shield]: https://img.shields.io/github/stars/helsingborg-stad/helsingborg-io-sls-resources.svg?style=flat-square
[stars-url]: https://github.com/helsingborg-stad/helsingborg-io-sls-resources/stargazers
[issues-shield]: https://img.shields.io/github/issues/helsingborg-stad/helsingborg-io-sls-resources.svg?style=flat-square
[issues-url]: https://github.com/helsingborg-stad/helsingborg-io-sls-resources/issues
[license-shield]: https://img.shields.io/github/license/helsingborg-stad/helsingborg-io-sls-resources.svg?style=flat-square
[license-url]: https://raw.githubusercontent.com/helsingborg-stad/helsingborg-io-sls-resources/master/LICENSE