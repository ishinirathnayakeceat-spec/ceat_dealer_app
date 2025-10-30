const mysql = require('mysql2');

const db1 = mysql.createConnection({
    host: 'localhost',
    port: 4507,
    user: 'ceat_develop',
    password: '24cE@t12',
    database: 'dispatch_app',
});

db1.connect((err) => {
  if (err) {
    console.error('Error connecting to the MySQL database:', err.message);
    return;
  }
  console.log('Connected to MySQL database1');
});

module.exports = db1;
