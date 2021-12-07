const AWS = require('aws-sdk');
const fs = require('fs');

const stage = process.argv.slice(2)[0] || 'dev';

AWS.config.update({
  region: 'eu-north-1',
});

// Future stuff
function deleteData() {
  console.log('\n😢 Goodbye Users... [NOT IMPLEMENTED]');
  process.exit();
}

function loadData() {
  const docClient = new AWS.DynamoDB.DocumentClient();

  console.log('Importing users into AWS DynamoDb. Please wait...');

  const users = JSON.parse(fs.readFileSync(`${__dirname}/users.json`, 'utf-8'));

  users.forEach(function (user) {
    const params = {
      TableName: `${stage}-users`,
      Item: { ...user },
    };

    docClient.put(params, function (err, _data) {
      if (err) {
        console.error(
          '👎 Unable to add user',
          user.id,
          '. Error JSON:',
          JSON.stringify(err, null, 2)
        );
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
