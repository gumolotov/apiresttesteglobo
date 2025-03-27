const express = require('express');
const Comentario = require('../models/comentario.model');
const router = express.Router();

router.post('/', async (req, res) => {
    const comentario = new Comentario(req.body);
    await comentario.save();
    res.status(201).send(comentario);
});

router.get('/', async (req, res) => {
    const comentarios = await Comentario.find();
    res.send(comentarios);
});

router.get('/:id', async (req, res) => {
    const comentario = await Comentario.findById(req.params.id);
    if (!comentario) return res.status(404).send('Comentário não encontrado');
    res.send(comentario);
});

router.put('/:id', async (req, res) => {
    const comentario = await Comentario.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!comentario) return res.status(404).send('Comentário não encontrado');
    res.send(comentario);
});

router.delete('/:id', async (req, res) => {
    const comentario = await Comentario.findByIdAndDelete(req.params.id);
    if (!comentario) return res.status(404).send('Comentário não encontrado');
    res.send({ message: 'Comentário removido' });
});

module.exports = router;
