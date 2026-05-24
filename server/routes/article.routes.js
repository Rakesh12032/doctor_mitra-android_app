const express = require('express');
const router = express.Router();
const { getArticles, getArticleById, createArticle } = require('../controllers/article.controller');
const { protect } = require('../middleware/auth.middleware');

router.route('/')
  .get(getArticles)
  .post(protect, createArticle);

router.route('/:id')
  .get(getArticleById);

module.exports = router;
