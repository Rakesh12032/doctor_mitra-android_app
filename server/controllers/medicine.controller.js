const Medicine = require('../models/Medicine');

// Beautiful mock fallback medicines for robust offline demonstration
const MOCK_MEDICINES = [
  {
    _id: 'med-001',
    name: 'Crocin Pain Relief',
    genericName: 'Paracetamol & Caffeine',
    manufacturer: 'GlaxoSmithKline (GSK) Pharmaceuticals',
    price: 38.5,
    composition: 'Paracetamol 650mg + Caffeine 50mg',
    uses: ['Headache', 'Fever', 'Body Pain', 'Toothache'],
    sideEffects: ['Nausea', 'Allergy rashes', 'Acidity'],
    dosage: '1 tablet twice a day after meals, max 3 tablets in 24 hours',
    category: 'Analgesics',
    isAvailable: true,
  },
  {
    _id: 'med-002',
    name: 'Calpol 650',
    genericName: 'Paracetamol',
    manufacturer: 'GlaxoSmithKline (GSK)',
    price: 30.2,
    composition: 'Paracetamol IP 650mg',
    uses: ['Fever', 'Pain relief', 'Common cold'],
    sideEffects: ['Allergic reactions', 'Liver issues if overdosed'],
    dosage: '1 tablet 3-4 times daily as directed by doctor',
    category: 'Antipyretics',
    isAvailable: true,
  },
  {
    _id: 'med-003',
    name: 'Alersin-L',
    genericName: 'Levocetirizine',
    manufacturer: 'Cipla Ltd',
    price: 55.0,
    composition: 'Levocetirizine Dihydrochloride 5mg',
    uses: ['Sneezing', 'Running nose', 'Allergic rhinitis', 'Skin itching'],
    sideEffects: ['Drowsiness', 'Dry mouth', 'Fatigue'],
    dosage: '1 tablet daily at bedtime',
    category: 'Antihistamines',
    isAvailable: true,
  },
  {
    _id: 'med-004',
    name: 'Pan-D Capsule',
    genericName: 'Pantoprazole & Domperidone',
    manufacturer: 'Alkem Laboratories Ltd',
    price: 142.0,
    composition: 'Pantoprazole 40mg + Domperidone 30mg SR',
    uses: ['Acidity', 'Acid reflux', 'Gerd', 'Heartburn', 'Bloating'],
    sideEffects: ['Headache', 'Diarrhea', 'Flatulence'],
    dosage: '1 capsule daily in the morning, 30 minutes before breakfast',
    category: 'Antacids',
    isAvailable: true,
  },
  {
    _id: 'med-005',
    name: 'Combiflam',
    genericName: 'Ibuprofen & Paracetamol',
    manufacturer: 'Sanofi India Ltd',
    price: 45.8,
    composition: 'Ibuprofen 400mg + Paracetamol 325mg',
    uses: ['Muscle pain', 'Joint swelling', 'Inflammation', 'Tooth pain'],
    sideEffects: ['Stomach upset', 'Dizziness', 'Heartburn'],
    dosage: '1 tablet twice daily after food',
    category: 'Analgesics',
    isAvailable: true,
  },
  {
    _id: 'med-006',
    name: 'Azithral 500',
    genericName: 'Azithromycin',
    manufacturer: 'Alembic Pharmaceuticals Ltd',
    price: 119.5,
    composition: 'Azithromycin 500mg',
    uses: ['Bacterial infection', 'Throat infection', 'Tonsillitis', 'Bronchitis'],
    sideEffects: ['Nausea', 'Abdominal pain', 'Vomiting'],
    dosage: '1 tablet daily for 3 days, 1 hour before or 2 hours after food',
    category: 'Antibiotics',
    isAvailable: true,
  },
  {
    _id: 'med-007',
    name: 'Glycomet 500 SR',
    genericName: 'Metformin',
    manufacturer: 'USV Private Ltd',
    price: 24.5,
    composition: 'Metformin Hydrochloride IP 500mg',
    uses: ['Type-2 Diabetes', 'Polycystic ovary syndrome (PCOS)'],
    sideEffects: ['Nausea', 'Metallic taste in mouth', 'Stomach pain'],
    dosage: '1 tablet with dinner or as suggested by endocrinologist',
    category: 'Antidiabetics',
    isAvailable: true,
  },
  {
    _id: 'med-008',
    name: 'Amlokind-5',
    genericName: 'Amlodipine',
    manufacturer: 'Mankind Pharma Ltd',
    price: 15.0,
    composition: 'Amlodipine Besylate 5mg',
    uses: ['Hypertension (High Blood Pressure)', 'Angina (Chest pain)'],
    sideEffects: ['Ankle swelling', 'Headache', 'Sleepiness'],
    dosage: '1 tablet daily at the same time every day',
    category: 'Antihypertensives',
    isAvailable: true,
  },
  {
    _id: 'med-009',
    name: 'Montair-LC',
    genericName: 'Montelukast & Levocetirizine',
    manufacturer: 'Cipla Ltd',
    price: 198.0,
    composition: 'Montelukast 10mg + Levocetirizine 5mg',
    uses: ['Allergic asthma', 'Hay fever', 'Chronic running nose', 'Sneezing'],
    sideEffects: ['Drowsiness', 'Mild headache', 'Dry mouth'],
    dosage: '1 tablet once daily at night',
    category: 'Antiallergics',
    isAvailable: true,
  },
  {
    _id: 'med-010',
    name: 'Atorva 10',
    genericName: 'Atorvastatin',
    manufacturer: 'Zydus Cadila',
    price: 68.0,
    composition: 'Atorvastatin Calcium 10mg',
    uses: ['High cholesterol', 'Prevention of heart attacks'],
    sideEffects: ['Joint pain', 'Nausea', 'Muscle weakness'],
    dosage: '1 tablet daily before sleeping',
    category: 'Statins',
    isAvailable: true,
  }
];

/**
 * @desc    Get all medicines with search filter
 * @route   GET /api/medicines
 * @access  Public
 */
exports.getMedicines = async (req, res) => {
  try {
    const { search } = req.query;
    let query = {};

    if (search) {
      const searchRegex = new RegExp(search, 'i');
      query = {
        $or: [
          { name: { $regex: searchRegex } },
          { genericName: { $regex: searchRegex } },
          { category: { $regex: searchRegex } },
        ],
      };
    }

    let medicines = [];
    try {
      medicines = await Medicine.find(query).sort({ name: 1 });
    } catch (dbErr) {
      console.warn("DB Query failed in getMedicines, using mocks: ", dbErr.message);
    }

    // Fallback if empty database
    if (medicines.length === 0) {
      if (search) {
        const term = search.toLowerCase();
        medicines = MOCK_MEDICINES.filter(
          (m) =>
            m.name.toLowerCase().includes(term) ||
            m.genericName.toLowerCase().includes(term) ||
            m.category.toLowerCase().includes(term) ||
            m.uses.some((u) => u.toLowerCase().includes(term))
        );
      } else {
        medicines = MOCK_MEDICINES;
      }
    }

    res.status(200).json({
      success: true,
      count: medicines.length,
      data: medicines,
    });
  } catch (error) {
    console.error('❌ Get Medicines Error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error occurred while searching medicines',
    });
  }
};

/**
 * @desc    Get a single medicine detail by ID
 * @route   GET /api/medicines/:id
 * @access  Public
 */
exports.getMedicineById = async (req, res) => {
  try {
    let medicine = null;
    try {
      medicine = await Medicine.findById(req.params.id);
    } catch (dbErr) {
      console.warn("DB Query failed in getMedicineById, using mocks: ", dbErr.message);
    }

    if (!medicine) {
      // Find in mock list
      medicine = MOCK_MEDICINES.find((m) => m._id === req.params.id);
    }

    if (!medicine) {
      return res.status(404).json({
        success: false,
        error: 'Medicine not found',
      });
    }

    res.status(200).json({
      success: true,
      data: medicine,
    });
  } catch (error) {
    console.error('❌ Get Medicine By ID Error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error occurred while retrieving medicine profile',
    });
  }
};
