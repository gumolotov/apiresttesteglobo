const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const mongoose = require('mongoose');
const comentariosRoutes = require('./src/routes/comentarios.routes');

const app = express();
app.use(express.json());
app.use(cors());
app.use(helmet());
app.use(morgan('combined'));

mongoose.connect('mongodb://172.31.90.249:27017/comentarios', {
    useNewUrlParser: true,
    useUnifiedTopology: true,
});

app.use('/comentarios', comentariosRoutes);

const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Servidor rodando na porta ${PORT}`);
});
