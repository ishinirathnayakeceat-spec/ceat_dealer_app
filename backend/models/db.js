const mysql = require('mysql2');

const dbConfig = {
  host: '20.33.35.180',
  port: 4507,
  user: 'ceat_develop',
  password: '24cE@t12',
  database: 'test_dealer_portal'
};

let connection;

function handleDisconnect() {
  connection = mysql.createConnection(dbConfig);

  connection.connect((err) => {
    if (err) {
      console.error('Database connection failed, retrying in 5 seconds...', err.message);
      setTimeout(handleDisconnect, 5000);
    } else {
      console.log('Connected to MySQL database');
    }
  });

  connection.on('error', (err) => {
    console.error('Database error:', err);
    if (err.code === 'PROTOCOL_CONNECTION_LOST') {
      console.log('Reconnecting...');
      handleDisconnect();
    } else {
      throw err;
    }
  });
}

handleDisconnect();

module.exports = connection;

