import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../theme/app_colors.dart';

class ArticleDetailScreen extends StatelessWidget {
  final String id;
  final String title;
  final String content;
  final String category;
  final String authorName;
  final String thumbnail;
  final int readTime;
  final int views;
  final List<String> tags;

  const ArticleDetailScreen({
    super.key,
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.authorName,
    required this.thumbnail,
    required this.readTime,
    required this.views,
    required this.tags,
  });

  void _shareArticle(BuildContext context, bool isHi) {
    final text = isHi
        ? 'डॉक्टर मित्रा पर इस उपयोगी स्वास्थ्य लेख को पढ़ें: "$title"\nडॉक्टर मित्रा ऐप डाउनलोड करें!'
        : 'Read this helpful health article on Doctor Mitra: "$title"\nDownload the Doctor Mitra App!';
    
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isHi ? 'साझा करने का लिंक क्लिपबोर्ड पर कॉपी किया गया!' : 'Share link copied to clipboard!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final isHi = lang.isHindi;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Large Custom Header Header
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            leading: const BackButton(color: Colors.white),
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    thumbnail,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.primaryLight,
                      child: const Icon(Icons.broken_image, color: AppColors.primary, size: 48),
                    ),
                  ),
                  // Bottom gradient overlay for readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Article Body content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Category tag and action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share_outlined, color: AppColors.primary),
                        onPressed: () => _shareArticle(context, isHi),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                      fontFamily: 'Nunito',
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Read time and Author info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.primaryLight,
                        child: const Icon(Icons.person, size: 16, color: AppColors.primary),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        authorName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                          fontFamily: 'Nunito',
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.schedule_rounded, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '$readTime ${isHi ? 'मिनट' : 'min'} read',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Views Stats
                  Row(
                    children: [
                      const Icon(Icons.visibility_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '$views ${isHi ? 'अवलोकन' : 'views'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32, thickness: 1),

                  // Full content
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textDark,
                      fontFamily: 'Nunito',
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Article tags
                  if (tags.isNotEmpty) ...[
                    const Divider(height: 16),
                    const SizedBox(height: 8),
                    Text(
                      isHi ? 'टैग्स' : 'Tags',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.textMedium,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tags.map((t) {
                        return Chip(
                          label: Text('#$t'),
                          labelStyle: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Nunito',
                          ),
                          backgroundColor: AppColors.primaryLight,
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 40),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
