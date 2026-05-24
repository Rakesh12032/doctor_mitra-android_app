const mongoose = require('mongoose');

const ArticleSchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'Please add a title'],
    trim: true,
  },
  content: {
    type: String,
    required: [true, 'Please add content'],
  },
  category: {
    type: String,
    required: [true, 'Please add a category'],
    enum: ['Heart', 'Diabetes', 'Women', 'Mental Health', 'General'],
  },
  author: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Doctor',
    required: false,
  },
  authorName: {
    type: String,
    default: 'Doctor Mitra Expert',
  },
  thumbnail: {
    type: String,
    default: 'https://images.unsplash.com/photo-1576091160550-2173dba999ef?auto=format&fit=crop&w=400&q=80',
  },
  readTime: {
    type: Number,
    default: 5,
  },
  tags: [String],
  isPublished: {
    type: Boolean,
    default: true,
  },
  views: {
    type: Number,
    default: 0,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('Article', ArticleSchema);
