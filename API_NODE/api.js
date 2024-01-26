import express from "express";
import bodyParser from "body-parser"; 
import mysql from 'mysql';

const app = express();

const port = 3000;

app.use(bodyParser.urlencoded({ extended: false }));

const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'shopzone'
});

db.connect((err) => {
    if (err) {
        throw err;
    }
    console.log('Connected to database');
});

app.get('/', (req, res) => {
   res.send("shop zone api")
});
// Fetch orders
app.get('/getOrders', (req, res) => {
    db.query("SELECT * FROM foodorders WHERE orderStatus = 'normal'  ORDER BY orderTime DESC", (err, results) => {
        if (err) {
            console.log(err);
            res.status(500).send('Error in fetching orders');
            return;
        }
        console.log(results);
        res.json(results);
    });
});

// Fetch order items
app.get('/getOrderItems', (req, res) => {
    let orderID = req.query.orderID;
    db.query("SELECT * FROM fooditems WHERE itemID = ? ORDER BY publishedDate DESC", [orderID], (err, results) => {
        if (err) {
            res.status(500).send('Error in fetching order items');
            return;
        }
        res.json(results);
    });
});

app.listen(port, () => console.log(`Example app listening on port ${port}!`));
