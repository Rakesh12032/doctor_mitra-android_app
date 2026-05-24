const Article = require('../models/Article');

// @desc    Get all articles
// @route   GET /api/articles
// @access  Public
exports.getArticles = async (req, res, next) => {
  try {
    const { category } = req.query;
    const filter = { isPublished: true };

    if (category) {
      filter.category = category;
    }

    const articles = await Article.find(filter)
      .populate('author', 'name speciality profilePhoto')
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      count: articles.length,
      data: articles,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get single article
// @route   GET /api/articles/:id
// @access  Public
exports.getArticleById = async (req, res, next) => {
  try {
    // Find and increment view count
    const article = await Article.findByIdAndUpdate(
      req.params.id,
      { $inc: { views: 1 } },
      { new: true }
    ).populate('author', 'name speciality profilePhoto');

    if (!article) {
      return res.status(404).json({
        success: false,
        error: 'Article not found',
      });
    }

    res.status(200).json({
      success: true,
      data: article,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Create new article
// @route   POST /api/articles
// @access  Private (Doctor or Admin only)
exports.createArticle = async (req, res, next) => {
  try {
    const { title, content, category, thumbnail, readTime, tags } = req.body;

    // Check roles
    if (req.user.role !== 'doctor' && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        error: 'Only doctors and admins can write articles',
      });
    }

    const articleData = {
      title,
      content,
      category,
      thumbnail,
      readTime: readTime || Math.ceil(content.split(' ').length / 200),
      tags: tags || [],
    };

    if (req.user.role === 'doctor') {
      articleData.author = req.user._id || req.user.id;
      articleData.authorName = req.user.name || 'Dr. Expert';
    } else {
      articleData.authorName = 'Doctor Mitra Editorial Team';
    }

    const article = await Article.create(articleData);

    res.status(201).json({
      success: true,
      data: article,
    });
  } catch (error) {
    next(error);
  }
};
