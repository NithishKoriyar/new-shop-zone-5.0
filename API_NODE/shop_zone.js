import express from 'express';
import mysql from 'mysql';

const app = express();
const port = 3000;

var db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '',
  database: 'shops'
});

db.connect();

app.get('/', async (req, res) => {
  try {
    db.query('SELECT * FROM items', (err, result, fields) => {
      if (err) {
        console.error(err);
        return res.status(500).json({ error: 'Internal Server Error' });
      }

      res.json(result);
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

app.listen(port, () => {
  console.log(`Example app listening on port ${port}!`);
});
