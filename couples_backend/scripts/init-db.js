const fs = require('fs');
const path = require('path');
const { DatabaseSync } = require('node:sqlite');

const config = require('../src/config');

const schemaSql = fs.readFileSync(
  path.resolve(__dirname, '..', 'src', 'database', 'init.sql'),
  'utf8',
);

fs.mkdirSync(path.dirname(config.dbPath), { recursive: true });

const db = new DatabaseSync(config.dbPath);
db.exec(schemaSql);
db.close();

console.log(`Database initialized at ${config.dbPath}`);
