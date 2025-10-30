const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');

const authRoutes = require('./routes/authRoutes');
const profileRoutes = require('./routes/profileRoutes');
const paymentHistoryRoutes = require('./routes/paymentHistoryRoutes');
const outstandingReportRoutes = require('./routes/OutstandingReportRoutes'); 
const chequeRoutes = require('./routes/chequeRoutes');
const invoiceRoutes = require('./routes/invoiceRoutes');
const purchase_volumeRoutes = require('./routes/purchase_volumeRoutes');
const purchase_qty_amtRoutes = require('./routes/purchase_qty_amtRoutes');
const ppdRoutes = require('./routes/ppdRoutes');
const claimRoutes = require('./routes/claimRoutes');
const summaryRoutes = require('./routes/summaryRoutes');
const creditRoutes = require('./routes/creditRoutes');
const targetRoutes = require('./routes/targetRoutes');
const dispatchRoutes = require('./routes/dispatchRoutes');
const upload = require('./routes/uploadRoutes');
const claimRequestRoutes = require('./routes/claimRequestRoutes');


const app = express();
const port = 3000;
app.use(cors());
app.use(bodyParser.json());



app.use('/api', authRoutes);
app.use('/api', profileRoutes);
app.use('/api', paymentHistoryRoutes);
app.use('/api', outstandingReportRoutes);
app.use('/api', chequeRoutes);
app.use('/api', invoiceRoutes);
app.use('/api', purchase_volumeRoutes);
app.use('/api', purchase_qty_amtRoutes);
app.use('/api', ppdRoutes);
app.use('/api', claimRoutes);
app.use('/api', summaryRoutes);
app.use('/api', creditRoutes);
app.use('/api', targetRoutes);
app.use('/api', dispatchRoutes);
app.use('/api', upload);
app.use('/api', claimRequestRoutes);



app.listen(port, '0.0.0.0', () => {
  console.log(`Server running on http://0.0.0.0:${port}`);
});

