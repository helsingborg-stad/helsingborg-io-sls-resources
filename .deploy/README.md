# Helsingborg IO SLS Resources - Deploy

## Table of Contents
- [Helsingborg IO SLS Resources - Deploy](#helsingborg-io-sls-resources---deploy)
  - [Table of Contents](#table-of-contents)
  - [Deploy script](#deploy-script)
  - [Buildspecs](#buildspecs)
    - [buildspec.yml](#buildspecyml)
  - [Cloudformation](#cloudformation)
    - [Prerequisites](#prerequisites)
    - [Template imports](#template-imports)
    - [Serverless Deploy Role](#serverless-deploy-role)
    - [Parameter stores](#parameter-stores)
    - [Create/Update/Delete stack](#createupdatedelete-stack)
      - [Production/Staging/Test](#productionstagingtest)
      - [Develop](#develop)
      - [Release](#release)


## Deploy script
The deploy script is located(with helpers) in this folder.  
A deploy is triggered by running `node .deploy /path/to/cached-sha-file` from the project root folder.  
The deploy script will check for cached previous git SHA from successful deploys and make a list of services to deploy based on this diff.  
  
If anything changes in libs folder all services will be deployes.
If anything changes in one or more services folder, those services will be deployed but nothing else.

The deploy script will find any exports and imports to do the deploys in the correct order based on what service import from an exporting service.  

## Buildspecs
Located in `.deploy/cloudformation/pipeline/` there are two buildspec files.  
These are used to run the two codebuild steps in the pipeline.  

### buildspec.yml
This spec will set up all needed credentials to fetch npm packages and deploy to the different account.  
This is what will store the last deployed commit SHA and trigger the deploy script.  

## Cloudformation

### Prerequisites
You will need to install AWS CLI and configure your AWS credentials as default or use a profile.  

### Template imports
This import makes CodePipeline react to github-events, the connection is created in a different CFN stack located in a secure private repository.  
```
Fn::ImportValue: github-connection-CodeStarConnection
```

### Serverless Deploy Role
The ServerlessDeployRole is used in order to be able to push deploys to selected accounts ex. prod/stage/test/dev.  
The serverless role is created in a different CFN stack an located in a secure private repository.  

### Parameter stores
In the parameters section in the CFN template, parameter store values are fetched. These are created in a different CFN stack located in a secure private repository.  

### Create/Update/Delete stack
In project root folder, run these commands to create, update and delete pipelines.  

#### Production/Staging/Test
Production and staging is deployed in the same pipeline.  

Create:
```
aws cloudformation create-stack --stack-name helsingborg-io-sls-resources-pipeline --template-body file://$PWD/.deploy/cloudformation/pipelines/production/stack.yml --capabilities CAPABILITY_NAMED_IAM
```

Update:
```
aws cloudformation update-stack --stack-name helsingborg-io-sls-resources-pipeline --template-body file://$PWD/.deploy/cloudformation/pipelines/production/stack.yml --capabilities CAPABILITY_NAMED_IAM
```

Delete:
```
aws cloudformation delete-stack --stack-name helsingborg-io-sls-resources-pipeline
```

#### Develop
Create:
```
aws cloudformation create-stack --stack-name helsingborg-io-sls-resources-develop-pipeline --template-body file://$PWD/.deploy/cloudformation/pipelines/develop/stack.yml --capabilities CAPABILITY_NAMED_IAM
```

Update:
```
aws cloudformation update-stack --stack-name helsingborg-io-sls-resources-develop-pipeline --template-body file://$PWD/.deploy/cloudformation/pipelines/develop/stack.yml --capabilities CAPABILITY_NAMED_IAM
```

Delete:
```
aws cloudformation delete-stack --stack-name helsingborg-io-sls-resources-develop-pipeline
```

#### Release
Create:
```
aws cloudformation create-stack --stack-name helsingborg-io-sls-resources-release-pipeline --template-body file://$PWD/.deploy/cloudformation/pipelines/release/stack.yml --capabilities CAPABILITY_NAMED_IAM
```

Update:
```
aws cloudformation update-stack --stack-name helsingborg-io-sls-resources-release-pipeline --template-body file://$PWD/.deploy/cloudformation/pipelines/release/stack.yml --capabilities CAPABILITY_NAMED_IAM
```

Delete:
```
aws cloudformation delete-stack --stack-name helsingborg-io-sls-resources-release-pipeline
```