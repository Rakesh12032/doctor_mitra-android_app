/**
 * Seed 10 medical blogs/articles into MongoDB.
 * 
 * Usage: node seeds/seedArticles.js
 */
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');

// Load env from server directory
dotenv.config({ path: path.join(__dirname, '..', '.env') });

const Article = require('../models/Article');

const sampleArticles = [
  {
    title: '5 Habits to Keep Your Heart Healthy / दिल को स्वस्थ रखने के लिए 5 आदतें',
    category: 'Heart',
    thumbnail: 'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?auto=format&fit=crop&w=400&q=80',
    readTime: 4,
    tags: ['Cardiology', 'Diet', 'Exercise', 'Bilingual'],
    content: `English:
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
5. नमक और चीनी का कम सेवन: प्रोसेस्ड और जंक फूड का उपयोग सीमित करें।`,
  },
  {
    title: 'Understanding Diabetes & Blood Sugar Spikes / मधुमेह और ब्लड शुगर को समझें',
    category: 'Diabetes',
    thumbnail: 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&w=400&q=80',
    readTime: 5,
    tags: ['Diabetes', 'Sugar', 'Health Tips'],
    content: `English:
Diabetes is a chronic condition affecting how your body processes glucose. Blood sugar spikes can cause fatigue, blurred vision, and long-term complications.
- Maintain a Low-GI Diet: Eat foods that digest slowly, preventing rapid glucose releases (e.g., oats, lentils, brown rice).
- Stay Hydrated: Drink ample pure water to assist your kidneys in flushing out excess sugar.
- Track Regularly: Use home glucometers to note blood sugar responses before and after meals.

हिंदी:
मधुमेह एक पुरानी स्थिति है जो प्रभावित करती है कि आपका शरीर ग्लूकोज को कैसे नियंत्रित करता है। ब्लड शुगर का अचानक बढ़ना थकान, धुंधली दृष्टि और दीर्घकालिक जटिलताओं का कारण बन सकता है।
- कम ग्लाइसेमिक इंडेक्स (GI) आहार लें: ऐसे खाद्य पदार्थ खाएं जो धीरे-धीरे पचते हैं (जैसे जई, दालें, भूरे चावल)।
- पर्याप्त पानी पीएं: गुर्दे को अतिरिक्त शुगर बाहर निकालने में मदद करने के लिए पानी पीते रहें।
- नियमित जांच: भोजन से पहले और बाद में ग्लूकोमीटर की मदद से ब्लड शुगर की जांच करें।`,
  },
  {
    title: 'Essential Nutritional Advice for Expecting Mothers / गर्भवती महिलाओं के लिए पोषण सलाह',
    category: 'Women',
    thumbnail: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?auto=format&fit=crop&w=400&q=80',
    readTime: 6,
    tags: ['Pregnancy', 'Gynacology', 'Nutrition'],
    content: `English:
Pregnancy demands elevated nutrient intakes to ensure optimal fetal growth and maternal wellness.
1. Folic Acid: Essential to prevent neural tube defects. Include spinach, oranges, and beans.
2. Iron & Calcium: Vital for maternal blood supply and fetal skeletal development.
3. Hydration: Drink 10-12 glasses of water daily to maintain amniotic fluid volumes.

हिंदी:
गर्भावस्था के दौरान भ्रूण के विकास और मां के अच्छे स्वास्थ्य के लिए विशेष पोषण की आवश्यकता होती है।
1. फॉलिक एसिड: न्यूरल ट्यूब दोषों से बचाव के लिए पालक, संतरे और फलियां भरपूर मात्रा में खाएं।
2. आयरन और कैल्शियम: मां के शरीर में रक्त प्रवाह बढ़ाने और शिशु की हड्डियों के विकास के लिए अत्यंत महत्वपूर्ण।
3. पर्याप्त पानी: एमनियोटिक द्रव की मात्रा बनाए रखने के लिए रोजाना 10-12 गिलास पानी अवश्य पीएं।`,
  },
  {
    title: 'Tips to Manage Stress and Daily Anxiety / तनाव और दैनिक चिंता को प्रबंधित करने के उपाय',
    category: 'Mental Health',
    thumbnail: 'https://images.unsplash.com/photo-1518241353330-0f7941c2d9b5?auto=format&fit=crop&w=400&q=80',
    readTime: 4,
    tags: ['Anxiety', 'Mental Health', 'Meditation'],
    content: `English:
Mental health is just as critical as physical health. Manage daily anxiety with these tips:
- Practice Box Breathing: Inhale for 4 seconds, hold for 4, exhale for 4, hold for 4.
- Digital Detox: Stay away from screens for at least 1 hour before sleeping.
- Write a Journal: Jotting down your feelings helps clarify thoughts and release emotional blockages.

हिंदी:
मानसिक स्वास्थ्य भी उतना ही महत्वपूर्ण है जितना कि शारीरिक स्वास्थ्य। दैनिक तनाव को कम करने के लिए इन आदतों को अपनाएं:
- बॉक्स ब्रीदिंग करें: 4 सेकंड के लिए सांस लें, 4 सेकंड रोकें, 4 सेकंड में छोड़ें, 4 सेकंड रुकें।
- डिजिटल डिटॉक्स: सोने से कम से कम 1 घंटा पहले मोबाइल और टीवी स्क्रीन से दूरी बना लें।
- डायरी लिखें: अपनी भावनाओं को लिखने से विचारों में स्पष्टता आती है और मानसिक बोझ कम होता है।`,
  },
  {
    title: 'Hydration and Summer Health in Bihar/UP / बिहार और यूपी में गर्मी में सेहत का ख्याल',
    category: 'General',
    thumbnail: 'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?auto=format&fit=crop&w=400&q=80',
    readTime: 5,
    tags: ['Summer', 'ORS', 'Dehydration'],
    content: `English:
During peak summer, temperatures in Bihar and Uttar Pradesh regularly cross 40°C. Guard against heatstrokes:
- Drink ORS & Shikanji: Keep electrolytes balanced.
- Wear Loose Clothing: Opt for breathable cotton light-colored outfits.
- Avoid Direct Sun: Remain indoors between 12 PM and 4 PM.

हिंदी:
गर्मियों के मौसम में बिहार और उत्तर प्रदेश में तापमान अक्सर 40 डिग्री सेल्सियस से ऊपर चला जाता है। लू (Heatstroke) से बचाव के तरीके:
- ओआरएस (ORS) और शिकंजी पीएं: शरीर में इलेक्ट्रोलाइट्स का संतुलन बनाए रखें।
- सूती कपड़े पहनें: ढीले और हल्के रंग के सूती कपड़ों का चुनाव करें।
- तेज धूप से बचें: दोपहर 12 बजे से 4 बजे के बीच घर के अंदर ही रहने का प्रयास करें।`,
  },
];

async function seedArticles() {
  try {
    console.log('📰 Connecting to MongoDB for Articles seeding...');
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB Atlas!\n');

    let inserted = 0;
    let skipped = 0;

    for (const art of sampleArticles) {
      const existing = await Article.findOne({ title: art.title });
      if (existing) {
        skipped++;
        console.log(`⏩ Article already exists: ${art.title.substring(0, 40)}...`);
      } else {
        await Article.create(art);
        inserted++;
        console.log(`✅ Inserted Article: ${art.title.substring(0, 40)}...`);
      }
    }

    console.log('\n════════════════════════════════════════');
    console.log(`📰 Articles: ${inserted} inserted, ${skipped} skipped`);
    console.log('════════════════════════════════════════\n');

    await mongoose.connection.close();
    console.log('🔌 MongoDB connection closed.\n');
    process.exit(0);
  } catch (error) {
    console.error('❌ Articles Seed Error:', error);
    process.exit(1);
  }
}

seedArticles();
