import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../providers/language_provider.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/language_toggle.dart';
import 'article_detail_screen.dart';

class LocalArticle {
  final String id;
  final String title;
  final String content;
  final String category;
  final String authorName;
  final String thumbnail;
  final int readTime;
  final int views;
  final List<String> tags;

  LocalArticle({
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
}

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  String? _selectedCategory;
  String _searchQuery = '';
  bool _isLoading = false;
  List<LocalArticle> _articles = [];
  final Set<String> _bookmarkedIds = {};

  final List<LocalArticle> _localFallbackArticles = [
    LocalArticle(
      id: 'art-001',
      title: '5 Habits to Keep Your Heart Healthy / दिल को स्वस्थ रखने के लिए 5 आदतें',
      category: 'Heart',
      authorName: 'Dr. Sharad Kumar',
      thumbnail: 'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?auto=format&fit=crop&w=400&q=80',
      readTime: 4,
      views: 1205,
      tags: ['Cardiology', 'Diet', 'Exercise'],
      content: '''English:
A healthy heart is essential for general well-being. Start today by adding these simple daily habits:
1. Exercise Regularly: Dedicate at least 30 minutes to moderate physical activities like brisk walking.
2. Eat a Balanced Diet: Integrate more green leafy vegetables, whole grains, and healthy fats like walnuts into your plates.
3. Manage Stress: Practice deep breathing, meditation, or mindfulness to keep your blood pressure stable.
4. Sleep Well: Aim for 7 to 8 hours of uninterrupted rest to allow cellular repairs.
5. Limit Salt & Sugar: Reduce processed fast foods to support dynamic cardiovascular health.

हिंदी:
एक स्वस्थ दिल संपूर्ण शरीर को निरोगी रखने की कुंजी है। आज ही से इन सरल आदतों को अपनाएं:
1. नियमित व्यायाम: प्रतिदिन कम से कम 30 मिनट तेज चलने या योग जैसी शारीरिक गतिविधियां करें।
2. संतुलित आहार: अपने भोजन में हरी पत्तेदार सब्जियां, साबुत अनाज और अखरोट जैसे स्वस्थ फैट्स शामिल करें।
3. तनाव प्रबंधन: रक्तचाप को नियंत्रित रखने के लिए गहरी सांस लें, ध्यान या माइंडफुलनेस का अभ्यास करें।
4. पर्याप्त नींद: शरीर की आंतरिक मरम्मत के लिए रोजाना 7 से 8 घंटे की गहरी नींद लें।
5. नमक और चीनी का कम सेवन: प्रोसेस्ड और जंक फूड का उपयोग सीमित करें।''',
    ),
    LocalArticle(
      id: 'art-002',
      title: 'Understanding Diabetes & Blood Sugar Spikes / मधुमेह और ब्लड शुगर को समझें',
      category: 'Diabetes',
      authorName: 'Dr. Anjali Mitra',
      thumbnail: 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&w=400&q=80',
      readTime: 5,
      views: 894,
      tags: ['Diabetes', 'Sugar', 'Health Tips'],
      content: '''English:
Diabetes is a chronic condition affecting how your body processes glucose. Blood sugar spikes can cause fatigue, blurred vision, and long-term complications.
- Maintain a Low-GI Diet: Eat foods that digest slowly, preventing rapid glucose releases (e.g., oats, lentils, brown rice).
- Stay Hydrated: Drink ample pure water to assist your kidneys in flushing out excess sugar.
- Track Regularly: Use home glucometers to note blood sugar responses before and after meals.

हिंदी:
मधुमेह एक पुरानी स्थिति है जो प्रभावित करती है कि आपका शरीर ग्लूकोज को कैसे नियंत्रित करता है। ब्लड शुगर का अचानक बढ़ना थकान, धुंधली दृष्टि और दीर्घकालिक जटिलताओं का कारण बन सकता है।
- कम ग्लाइसेमिक इंडेक्स (GI) आहार लें: ऐसे खाद्य पदार्थ खाएं जो धीरे-धीरे पचते हैं (जैसे जई, दालें, भूरे चावल)।
- पर्याप्त पानी पीएं: गुर्दे को अतिरिक्त शुगर बाहर निकालने में मदद करने के लिए पानी पीते रहें।
- नियमित जांच: भोजन से पहले और बाद में ग्लूकोमीटर की मदद से ब्लड शुगर की जांच करें।''',
    ),
    LocalArticle(
      id: 'art-003',
      title: 'Essential Nutritional Advice for Expecting Mothers / गर्भवती महिलाओं के लिए पोषण सलाह',
      category: 'Women',
      authorName: 'Dr. Renu Sinha',
      thumbnail: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?auto=format&fit=crop&w=400&q=80',
      readTime: 6,
      views: 2401,
      tags: ['Pregnancy', 'Gynecology', 'Nutrition'],
      content: '''English:
Pregnancy demands elevated nutrient intakes to ensure optimal fetal growth and maternal wellness.
1. Folic Acid: Essential to prevent neural tube defects. Include spinach, oranges, and beans.
2. Iron & Calcium: Vital for maternal blood supply and fetal skeletal development.
3. Hydration: Drink 10-12 glasses of water daily to maintain amniotic fluid volumes.

हिंदी:
गर्भावस्था के दौरान भ्रूण के विकास और मां के अच्छे स्वास्थ्य के लिए विशेष पोषण की आवश्यकता होती है।
1. फॉलिक एसिड: न्यूरल ट्यूब दोषों से बचाव के लिए पालक, संतरे और फलियां भरपूर मात्रा में खाएं।
2. आयरन और कैल्शियम: मां के शरीर में रक्त प्रवाह बढ़ाने और शिशु की हड्डियों के विकास के लिए अत्यंत महत्वपूर्ण।
3. पर्याप्त पानी: एमनियोटिक द्रव की मात्रा बनाए रखने के लिए रोजाना 10-12 गिलास पानी अवश्य पीएं।''',
    ),
    LocalArticle(
      id: 'art-004',
      title: 'Tips to Manage Stress and Daily Anxiety / तनाव और दैनिक चिंता को प्रबंधित करने के उपाय',
      category: 'Mental Health',
      authorName: 'Dr. Vikram Prasad',
      thumbnail: 'https://images.unsplash.com/photo-1518241353330-0f7941c2d9b5?auto=format&fit=crop&w=400&q=80',
      readTime: 4,
      views: 1530,
      tags: ['Anxiety', 'Mental Health', 'Meditation'],
      content: '''English:
Mental health is just as critical as physical health. Manage daily anxiety with these tips:
- Practice Box Breathing: Inhale for 4 seconds, hold for 4, exhale for 4, hold for 4.
- Digital Detox: Stay away from screens for at least 1 hour before sleeping.
- Write a Journal: Jotting down your feelings helps clarify thoughts and release emotional blockages.

हिंदी:
मानसिक स्वास्थ्य भी उतना ही महत्वपूर्ण है जितना कि शारीरिक स्वास्थ्य। दैनिक तनाव को कम करने के लिए इन आदतों को अपनाएं:
- बॉक्स ब्रीदिंग करें: 4 सेकंड के लिए सांस लें, 4 सेकंड रोकें, 4 सेकंड में छोड़ें, 4 सेकंड रुकें।
- डिजिटल डिटॉक्स: सोने से कम से कम 1 घंटा पहले मोबाइल और टीवी स्क्रीन से दूरी बना लें।
- डायरी लिखें: अपनी भावनाओं को लिखने से विचारों में स्पष्टता आती है और मानसिक बोझ कम होता है।''',
    ),
    LocalArticle(
      id: 'art-005',
      title: 'Hydration and Summer Health in Bihar/UP / बिहार और यूपी में गर्मी में सेहत का ख्याल',
      category: 'General',
      authorName: 'Dr. Rajiv Ranjan',
      thumbnail: 'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?auto=format&fit=crop&w=400&q=80',
      readTime: 5,
      views: 3120,
      tags: ['Summer', 'ORS', 'Dehydration'],
      content: '''English:
During peak summer, temperatures in Bihar and Uttar Pradesh regularly cross 40°C. Guard against heatstrokes:
- Drink ORS & Shikanji: Keep electrolytes balanced.
- Wear Loose Clothing: Opt for breathable cotton light-colored outfits.
- Avoid Direct Sun: Remain indoors between 12 PM and 4 PM.

हिंदी:
गर्मियों के मौसम में बिहार और उत्तर प्रदेश में तापमान अक्सर 40 डिग्री सेल्सियस से ऊपर चला जाता है। लू (Heatstroke) से बचाव के तरीके:
- ओआरएस (ORS) और शिकंजी पीएं: शरीर में इलेक्ट्रोलाइट्स का संतुलन बनाए रखें।
- सूती कपड़े पहनें: ढीले और हल्के रंग के सूती कपड़ों का चुनाव करें।
- तेज धूप से बचें: दोपहर 12 बजे से 4 बजे के बीच घर के अंदर ही रहने का प्रयास करें।''',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
    _fetchArticles();
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarked = prefs.getStringList('bookmarked_articles') ?? [];
    setState(() {
      _bookmarkedIds.addAll(bookmarked);
    });
  }

  Future<void> _toggleBookmark(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_bookmarkedIds.contains(id)) {
        _bookmarkedIds.remove(id);
      } else {
        _bookmarkedIds.add(id);
      }
    });
    await prefs.setStringList('bookmarked_articles', _bookmarkedIds.toList());
  }

  Future<void> _fetchArticles() async {
    setState(() {
      _isLoading = true;
    });

    if (InternetApiLayer.isConfiguredStatic) {
      try {
        final apiBaseUrl = const String.fromEnvironment('DOCTOR_MITRA_API_URL');
        final response = await http.get(Uri.parse('$apiBaseUrl/api/articles')).timeout(const Duration(seconds: 6));
        if (response.statusCode == 200) {
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          if (body['success'] == true && body['data'] is List) {
            final list = body['data'] as List;
            setState(() {
              _articles = list.map((item) {
                return LocalArticle(
                  id: (item['_id'] ?? item['id']).toString(),
                  title: item['title'].toString(),
                  content: item['content'].toString(),
                  category: item['category'].toString(),
                  authorName: item['authorName']?.toString() ?? 'Doctor Mitra Expert',
                  thumbnail: item['thumbnail']?.toString() ?? 'https://images.unsplash.com/photo-1576091160550-2173dba999ef?auto=format&fit=crop&w=400&q=80',
                  readTime: int.tryParse(item['readTime'].toString()) ?? 5,
                  views: int.tryParse(item['views'].toString()) ?? 0,
                  tags: item['tags'] != null ? List<String>.from(item['tags'] as List) : [],
                );
              }).toList();
              _isLoading = false;
            });
            return;
          }
        }
      } catch (e) {
        debugPrint("ArticlesScreen: REST API fetch failed, falling back to offline: $e");
      }
    }

    // Offline / Local fallback
    setState(() {
      _articles = _localFallbackArticles;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final isHi = lang.isHindi;

    final filteredArticles = _articles.where((art) {
      final query = _searchQuery.toLowerCase();
      final matchesSearch = art.title.toLowerCase().contains(query) ||
          art.content.toLowerCase().contains(query) ||
          art.category.toLowerCase().contains(query);

      final matchesCategory = _selectedCategory == null ||
          art.category.toLowerCase() == _selectedCategory!.toLowerCase();

      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const BackButton(color: AppColors.primary),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        title: Text(
          isHi ? 'स्वास्थ्य लेख' : 'Health Articles',
          style: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 20, fontFamily: 'Nunito'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: _fetchArticles,
          ),
          const Padding(padding: EdgeInsets.only(right: 8.0), child: LanguageToggle())
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.border.withOpacity(0.5), height: 1.0),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: TextField(
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: isHi ? 'बीमारी, खानपान या डॉक्टर खोजें...' : 'Search heart, diet, anxiety...',
                  hintStyle: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.search,
                      color: AppColors.primary, size: 22),
                  fillColor: AppColors.background,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
            ),

            // Horizontal Filter Chips
            Container(
              color: Colors.white,
              height: 48,
              padding: const EdgeInsets.only(bottom: 10, left: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategoryChip(isHi ? 'सभी' : 'All', null),
                  _buildCategoryChip(isHi ? 'हृदय स्वास्थ्य' : 'Heart', 'Heart'),
                  _buildCategoryChip(isHi ? 'मधुमेह' : 'Diabetes', 'Diabetes'),
                  _buildCategoryChip(isHi ? 'महिला स्वास्थ्य' : 'Women', 'Women'),
                  _buildCategoryChip(isHi ? 'मानसिक स्वास्थ्य' : 'Mental Health', 'Mental Health'),
                  _buildCategoryChip(isHi ? 'सामान्य' : 'General', 'General'),
                ],
              ),
            ),

            // Main Articles Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        strokeWidth: 3,
                      ),
                    )
                  : (filteredArticles.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.article_outlined,
                                  size: 64, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text(
                                isHi ? 'कोई लेख नहीं मिला' : 'No articles found',
                                style: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textMedium,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Nunito'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredArticles.length,
                          itemBuilder: (context, index) {
                            final art = filteredArticles[index];
                            final isBookmarked = _bookmarkedIds.contains(art.id);
                            return _buildArticleCard(art, isBookmarked, isHi);
                          },
                        )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? category) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.primaryLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              fontFamily: 'Nunito',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArticleCard(LocalArticle art, bool isBookmarked, bool isHi) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailScreen(
              id: art.id,
              title: art.title,
              content: art.content,
              category: art.category,
              authorName: art.authorName,
              thumbnail: art.thumbnail,
              readTime: art.readTime,
              views: art.views,
              tags: art.tags,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.premiumShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail Image Header
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                art.thumbnail,
                height: 160,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 160,
                  color: AppColors.primaryLight,
                  child: const Icon(Icons.broken_image, color: AppColors.primary),
                ),
              ),
            ),
            
            // Article Info Card Block
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Bookmark Action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          art.category,
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Nunito'),
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                          color: isBookmarked ? AppColors.primary : Colors.grey,
                          size: 22,
                        ),
                        onPressed: () => _toggleBookmark(art.id),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  // Title
                  Text(
                    art.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textDark,
                        fontFamily: 'Nunito',
                        height: 1.3),
                  ),
                  const SizedBox(height: 8),
                  
                  // Author & Stats footer
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: const Icon(Icons.person, size: 12, color: AppColors.primary),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        art.authorName,
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMedium,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Nunito'),
                      ),
                      const Spacer(),
                      const Icon(Icons.schedule_rounded, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${art.readTime} ${isHi ? 'मिनट' : 'min'}',
                        style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            fontFamily: 'Nunito'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
