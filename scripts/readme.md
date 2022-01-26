# About the scripts
The scripts facilitate migrating data and settings between environments.
Switch between environment with 
```sh
  $ aws-vault exec <environment>
```
as in 
```sh
  $ aws-vault exec sandbox
```

# Copy settings to local
```sh
  $ aws-vault exec <environment>
  $ ./scripts/copy-aws-secrets.sh` # writes to /tmp/secrets.txt 
  $ ./scripts/copy-ssm-parameters.sh` # writes to /tmp/parameters.txt 
```

# Copy data to local
```sh
  $ ./copy-deb-table.sh --table dev-forms # writes to /tmp.dev-forms.txt
  $ ./copy-deb-table.sh --table dev-users # writes to /tmp.dev-users.txt
  $ ./copy-deb-table.sh --table dev-cases # # writes to /tmp.dev-cases.txt
```

# Copy required certificates to local
Check out actual name of bucket **certificates-s3-dev-certificatesbucket-XXX** and paste in before proceeding.
```sh
  $ aws s3 cp s3://certificates-s3-dev-certificatesbucket-XXX ./tmp-certs --recursive
```


# Export local to AWS
**REMINDER: switch environment first!**
Example: `$ aws-vault exec sandbox`

## Execute the created text files
```sh
  $ /tmp/secrets.txt
  $ /tmp/parameters.txt
  $ /tmp/dev-forms.txt
  $ /tmp/dev-cases.txt
  $ /tmp/dev-users.txt
```

To make the files above executable its probably suffcient to `$ chmod +d /tmp/*.txt`


## Copy local certificates to bucket:
Check out actual name of bucket **certificates-s3-dev-certificatesbucket-XXX** and paste in before proceeding.
```sh
  $ aws s3 cp ./tmp-certs s3://certificates-s3-dev-certificatesbucket-XXX --recursive
```

# Manual fixup of settings
In **AWS Parameter Store**, the parameter **/navetEnvs/dev** must be fixed regarding **bucketName** - fill in the name of your own bucket (_certificates-s3-dev-certificatesbucket-XXX_).
