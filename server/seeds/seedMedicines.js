const mongoose = require('mongoose');
const Medicine = require('../models/Medicine');
const dotenv = require('dotenv');
const path = require('path');

// Load environment variables
dotenv.config({ path: path.join(__dirname, '../.env') });

const MEDICINES_DATA = [
  { name: 'Crocin Pain Relief', genericName: 'Paracetamol & Caffeine', manufacturer: 'GlaxoSmithKline (GSK)', price: 38.5, composition: 'Paracetamol 650mg + Caffeine 50mg', category: 'Analgesics' },
  { name: 'Calpol 650', genericName: 'Paracetamol', manufacturer: 'GlaxoSmithKline (GSK)', price: 30.2, composition: 'Paracetamol IP 650mg', category: 'Antipyretics' },
  { name: 'Dolo 650', genericName: 'Paracetamol', manufacturer: 'Micro Labs Ltd', price: 30.9, composition: 'Paracetamol IP 650mg', category: 'Antipyretics' },
  { name: 'Alersin-L', genericName: 'Levocetirizine', manufacturer: 'Cipla Ltd', price: 55.0, composition: 'Levocetirizine Dihydrochloride 5mg', category: 'Antihistamines' },
  { name: 'Pan-D Capsule', genericName: 'Pantoprazole & Domperidone', manufacturer: 'Alkem Laboratories Ltd', price: 142.0, composition: 'Pantoprazole 40mg + Domperidone 30mg SR', category: 'Antacids' },
  { name: 'Combiflam', genericName: 'Ibuprofen & Paracetamol', manufacturer: 'Sanofi India Ltd', price: 45.8, composition: 'Ibuprofen 400mg + Paracetamol 325mg', category: 'Analgesics' },
  { name: 'Azithral 500', genericName: 'Azithromycin', manufacturer: 'Alembic Pharmaceuticals Ltd', price: 119.5, composition: 'Azithromycin 500mg', category: 'Antibiotics' },
  { name: 'Glycomet 500 SR', genericName: 'Metformin', manufacturer: 'USV Private Ltd', price: 24.5, composition: 'Metformin Hydrochloride IP 500mg', category: 'Antidiabetics' },
  { name: 'Amlokind-5', genericName: 'Amlodipine', manufacturer: 'Mankind Pharma Ltd', price: 15.0, composition: 'Amlodipine Besylate 5mg', category: 'Antihypertensives' },
  { name: 'Montair-LC', genericName: 'Montelukast & Levocetirizine', manufacturer: 'Cipla Ltd', price: 198.0, composition: 'Montelukast 10mg + Levocetirizine 5mg', category: 'Antiallergics' },
  { name: 'Atorva 10', genericName: 'Atorvastatin', manufacturer: 'Zydus Cadila', price: 68.0, composition: 'Atorvastatin Calcium 10mg', category: 'Statins' },
  { name: 'Allegra 120', genericName: 'Fexofenadine', manufacturer: 'Sanofi India Ltd', price: 180.0, composition: 'Fexofenadine Hydrochloride 120mg', category: 'Antihistamines' },
  { name: 'Pantocid 40', genericName: 'Pantoprazole', manufacturer: 'Sun Pharmaceutical Industries', price: 78.5, composition: 'Pantoprazole Sodium 40mg', category: 'Antacids' },
  { name: 'Zantac 150', genericName: 'Ranitidine', manufacturer: 'GlaxoSmithKline', price: 22.0, composition: 'Ranitidine Hydrochloride 150mg', category: 'Antacids' },
  { name: 'Omenez 20', genericName: 'Omeprazole', manufacturer: 'Dr. Reddys Laboratories', price: 35.0, composition: 'Omeprazole Magnesium 20mg', category: 'Antacids' },
  { name: 'Voveran SR 100', genericName: 'Diclofenac', manufacturer: 'Novartis India Ltd', price: 92.4, composition: 'Diclofenac Sodium 100mg SR', category: 'Analgesics' },
  { name: 'Ciplox 500', genericName: 'Ciprofloxacin', manufacturer: 'Cipla Ltd', price: 42.5, composition: 'Ciprofloxacin Hydrochloride 500mg', category: 'Antibiotics' },
  { name: 'Zenflox 200', genericName: 'Ofloxacin', manufacturer: 'Mankind Pharma Ltd', price: 58.0, composition: 'Ofloxacin 200mg', category: 'Antibiotics' },
  { name: 'Telma 40', genericName: 'Telmisartan', manufacturer: 'Glenmark Pharmaceuticals', price: 88.0, composition: 'Telmisartan IP 40mg', category: 'Antihypertensives' },
  { name: 'Repace 50', genericName: 'Losartan', manufacturer: 'Sun Pharmaceutical', price: 64.5, composition: 'Losartan Potassium 50mg', category: 'Antihypertensives' },
  { name: 'Rosuvas 10', genericName: 'Rosuvastatin', manufacturer: 'Sun Pharmaceutical', price: 110.0, composition: 'Rosuvastatin Calcium 10mg', category: 'Statins' },
  { name: 'Clopilet 75', genericName: 'Clopidogrel', manufacturer: 'Sun Pharmaceutical', price: 82.0, composition: 'Clopidogrel Bisulfate 75mg', category: 'Antiplatelet' },
  { name: 'Amaryl 1mg', genericName: 'Glimepiride', manufacturer: 'Sanofi India', price: 54.0, composition: 'Glimepiride 1mg', category: 'Antidiabetics' },
  { name: 'Volibo 0.2', genericName: 'Voglibose', manufacturer: 'Sun Pharmaceutical', price: 78.0, composition: 'Voglibose 0.2mg', category: 'Antidiabetics' },
  { name: 'Istavel 50', genericName: 'Sitagliptin', manufacturer: 'Sun Pharmaceutical', price: 280.0, composition: 'Sitagliptin Phosphate 50mg', category: 'Antidiabetics' },
  { name: 'Asthalin Inhaler', genericName: 'Salbutamol', manufacturer: 'Cipla Ltd', price: 145.0, composition: 'Salbutamol Inhalation IP 100mcg', category: 'Bronchodilators' },
  { name: 'Duolin Inhaler', genericName: 'Levosalbutamol & Ipratropium', manufacturer: 'Cipla Ltd', price: 295.0, composition: 'Levosalbutamol 50mcg + Ipratropium Bromide 20mcg', category: 'Bronchodilators' },
  { name: 'Budecort 200', genericName: 'Budesonide', manufacturer: 'Cipla Ltd', price: 340.0, composition: 'Budesonide Inhalation IP 200mcg', category: 'Corticosteroids' },
  { name: 'Ascoril LS Syrup', genericName: 'Ambroxol & Levosalbutamol', manufacturer: 'Glenmark Pharmaceuticals', price: 118.0, composition: 'Ambroxol 30mg + Levosalbutamol 1mg', category: 'Cough Syrups' },
  { name: 'Grilinctus Syrup', genericName: 'Dextromethorphan & CPM', manufacturer: 'Franco-Indian Pharmaceuticals', price: 125.0, composition: 'Dextromethorphan HBr 5mg + Chlorpheniramine Maleate 2mg', category: 'Cough Syrups' },
  { name: 'Becosules Capsules', genericName: 'Vitamin B-Complex', manufacturer: 'Pfizer Ltd', price: 42.0, composition: 'Vitamin B1, B2, B3, B6, B12, Folic Acid & Vitamin C', category: 'Multivitamins' },
  { name: 'Evion 400', genericName: 'Vitamin E', manufacturer: 'Procter & Gamble Health', price: 35.8, composition: 'Tocopheryl Acetate IP 400mg', category: 'Vitamins' },
  { name: 'Shelcal 500', genericName: 'Calcium & Vitamin D3', manufacturer: 'Torrent Pharmaceuticals', price: 110.0, composition: 'Calcium Carbonate 1250mg + Vitamin D3 250 IU', category: 'Supplements' },
  { name: 'Autrin Capsules', genericName: 'Iron, Folic Acid & Vitamin B12', manufacturer: 'Pfizer Ltd', price: 138.0, composition: 'Ferrous Fumarate + Folic Acid + Vitamin B12', category: 'Supplements' },
  { name: 'Zinconia Syrup', genericName: 'Zinc Gluconate', manufacturer: 'Zuventus Healthcare Ltd', price: 75.0, composition: 'Zinc Gluconate IP 20mg', category: 'Supplements' },
  { name: 'Folvite 5mg', genericName: 'Folic Acid', manufacturer: 'Pfizer Ltd', price: 28.5, composition: 'Folic Acid IP 5mg', category: 'Vitamins' },
  { name: 'Razo 20', genericName: 'Rabeprazole', manufacturer: 'Dr. Reddys Laboratories', price: 165.0, composition: 'Rabeprazole Sodium 20mg', category: 'Antacids' },
  { name: 'Nexpro 40', genericName: 'Esomeprazole', manufacturer: 'Torrent Pharmaceuticals', price: 135.0, composition: 'Esomeprazole Magnesium 40mg', category: 'Antacids' },
  { name: 'Ondem MD 4', genericName: 'Ondansetron', manufacturer: 'Alkem Laboratories', price: 52.0, composition: 'Ondansetron IP 4mg orally disintegrating', category: 'Antiemetics' },
  { name: 'Domstal 10', genericName: 'Domperidone', manufacturer: 'Torrent Pharmaceuticals', price: 28.0, composition: 'Domperidone 10mg', category: 'Antiemetics' },
  { name: 'Perinorm 10', genericName: 'Metoclopramide', manufacturer: 'Ipca Laboratories Ltd', price: 12.5, composition: 'Metoclopramide Hydrochloride 10mg', category: 'Antiemetics' },
  { name: 'Lopamide 2mg', genericName: 'Loperamide', manufacturer: 'Torrent Pharmaceuticals', price: 18.0, composition: 'Loperamide Hydrochloride 2mg', category: 'Antidiarrheals' },
  { name: 'Electral ORS Powder', genericName: 'Oral Rehydration Salts', manufacturer: 'FDC Ltd', price: 21.0, composition: 'Sodium Chloride + Potassium Chloride + Dextrose', category: 'Rehydration' },
  { name: 'Meftal-Spas', genericName: 'Mefenamic Acid & Dicyclomine', manufacturer: 'Blue Cross Laboratories', price: 46.0, composition: 'Mefenamic Acid 250mg + Dicyclomine HCl 10mg', category: 'Antispasmodics' },
  { name: 'Cyclopam', genericName: 'Dicyclomine & Paracetamol', manufacturer: 'Indoco Remedies Ltd', price: 48.0, composition: 'Dicyclomine HCl 20mg + Paracetamol 500mg', category: 'Antispasmodics' },
  { name: 'Taxim-O 200', genericName: 'Cefixime', manufacturer: 'Alkem Laboratories Ltd', price: 105.0, composition: 'Cefixime Trihydrate 200mg', category: 'Antibiotics' },
  { name: 'Monocef 1g Injection', genericName: 'Ceftriaxone', manufacturer: 'Aristo Pharmaceuticals', price: 58.5, composition: 'Ceftriaxone Sodium Sterile 1g', category: 'Antibiotics' },
  { name: 'Augmentin 625 Duo', genericName: 'Amoxicillin & Clavulanate', manufacturer: 'GlaxoSmithKline (GSK)', price: 201.2, composition: 'Amoxicillin 500mg + Clavulanic Acid 125mg', category: 'Antibiotics' },
  { name: 'Novamox 500', genericName: 'Amoxicillin', manufacturer: 'Alkem Laboratories Ltd', price: 82.5, composition: 'Amoxicillin Trihydrate 500mg', category: 'Antibiotics' },
  { name: 'Cremaffin Syrup', genericName: 'Liquid Paraffin & Milk of Magnesia', manufacturer: 'Abbott India Ltd', price: 235.0, composition: 'Liquid Paraffin + Magnesium Hydroxide', category: 'Laxatives' }
];

const seedMedicines = async () => {
  const mongoUri = process.env.MONGODB_URI || "mongodb+srv://rakeshraj18052_db_user:Rakesh12032@cluster0.bgztajy.mongodb.net/doctormitra?appName=Cluster0";
  console.log('💊 Seed script attempting connection to MongoDB for Medicines...');

  try {
    await mongoose.connect(mongoUri, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log('✅ Connected to MongoDB for Medicine seeding.');

    // Clear existing
    await Medicine.deleteMany({});
    console.log('🗑️ Cleared existing medicines.');

    // Prepare full mock data details for the 50 medicines
    const fullMedicines = MEDICINES_DATA.map((med, index) => {
      const idx = index + 1;
      return {
        ...med,
        composition: med.composition || `${med.genericName} IP`,
        uses: med.uses || [`Relief from symptoms of ${med.category}`, `General clinical management of ${med.category.toLowerCase()}`],
        sideEffects: med.sideEffects || ['Mild headache', 'Dizziness', 'Stomach irritation'],
        dosage: med.dosage || '1 tablet daily as advised by your physician',
        isAvailable: true
      };
    });

    // Insert 50 medicines
    const result = await Medicine.insertMany(fullMedicines);
    console.log(`✅ Successfully seeded ${result.length} common medicines into MongoDB!`);
    
    mongoose.connection.close();
    process.exit(0);
  } catch (error) {
    console.error('❌ Medicine Seeding Failed:', error);
    process.exit(1);
  }
};

seedMedicines();
