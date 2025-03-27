const mongoose = require('mongoose');

const ComentarioSchema = new mongoose.Schema({
    autor: String,
    texto: String,
    data: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Comentario', ComentarioSchema);
