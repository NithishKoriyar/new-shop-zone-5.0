import express from 'express';
import mysql from 'mysql';

const app = express();
app.use(express.json());

// Set up MySQL connection
const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'shopzone'
});

db.connect(err => {
    if (err) throw err;
    console.log('Connected to MySQL');
});

// Enable CORS for all routes
app.use((req, res, next) => {
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Content-Type", "application/json; charset=UTF-8");
    next();
});

// Endpoint to get orders
app.get('/getOrders', (req, res) => {
    const sql = `SELECT uo.orderId, uo.orderBy, uo.orderTime, uo.itemQuantity, uo.totalAmount, uo.itemID, uo.orderStatus, 
                 it.*, 
                 ua.name, ua.phoneNumber, ua.completeAddress 
                 FROM foodOrders uo
                 INNER JOIN foodItems it ON uo.itemID = it.itemID
                 INNER JOIN useraddress ua ON uo.addressID = ua.id
                 WHERE uo.orderStatus = 'normal'`;

    db.query(sql, (err, result) => {
        if (err) {
            res.json({ error: 'Error in query' });
            return;
        }
        if (result.length === 0) {
            res.json({ error: 'No orders found.' });
            return;
        }
        res.json({ orders: result });
    });
});

const port = 3000;
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
