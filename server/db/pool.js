// db/pool.js
// Creates a single shared connection pool to PostgreSQL.
// Every route imports this instead of opening its own connection.

const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  host:     process.env.DB_HOST,
  port:     process.env.DB_PORT,
  database: process.env.DB_NAME,
  user:     process.env.DB_USER,
  password: process.env.DB_PASSWORD,
});

// Test the connection on startup and log the result
pool.connect((err, client, release) => {
  if (err) {
    console.error('❌  Database connection failed:', err.message);
  } else {
    console.log('✅  Connected to PostgreSQL —', process.env.DB_NAME);
    release();
  }
});

module.exports = pool;
