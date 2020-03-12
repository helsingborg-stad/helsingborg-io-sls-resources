import { config, DynamoDB } from 'aws-sdk';
import { readFileSync } from 'fs';

const stage = process.argv.slice(2)[0] || 'dev';

config.update({
  region: 'eu-north-1'
});

// Future stuff
function deleteData() {
  console.log('\n😢 Goodbye Users...');
  process.exit();
}

function loadData() {
  const docClient = new DynamoDB.DocumentClient();

  console.log('Importing users into DynamoDb. Please wait...');

  const users = JSON.parse(readFileSync(`${__dirname}/data/users.json`, 'utf-8'));

  users.forEach((user) => {
    const params = {
      TableName: `${stage}-user`,
      Item: { ...user }
    };

    docClient.put(params, (err, data) => {
      if (err) {
        console.error('👎 Unable to add user', user.id, '. Error JSON:', JSON.stringify(err, null, 2))
      } else {
        console.log('Put user succeeded:', user.id);
      }
    });
  });

  console.log('\n👍 Done!');
  process.exit();
}

if (process.argv.includes('--delete')) {
  deleteData();
} else {
  loadData();
}
