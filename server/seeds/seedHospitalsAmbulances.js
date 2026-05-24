/**
 * Seed Bihar & UP hospital and ambulance data into MongoDB.
 * 
 * Usage: node seeds/seedHospitalsAmbulances.js
 * 
 * This script is idempotent — it checks existing records by name before inserting.
 */
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');

// Load env from server directory
dotenv.config({ path: path.join(__dirname, '..', '.env') });

const Hospital = require('../models/Hospital');
const Ambulance = require('../models/Ambulance');

const hospitals = [
  // ══════════════ PATNA ══════════════
  {
    name: 'AIIMS Patna',
    type: 'medical_college',
    address: { street: 'Phulwarisharif', city: 'Patna', district: 'Patna', state: 'Bihar', pincode: '801507' },
    lat: 25.5760, lng: 85.0690,
    phone: '0612-2451070',
    emergencyPhone: '0612-2451071',
    specialities: ['Cardiology', 'Neurology', 'Orthopaedics', 'General Surgery', 'Paediatrics', 'Oncology', 'Nephrology', 'Gastroenterology'],
    facilities: ['ICU', 'NICU', 'CT Scan', 'MRI', 'Blood Bank', 'Emergency', 'Pharmacy', 'Dialysis'],
    beds: { total: 990, available: 120 },
    rating: { average: 4.2, count: 3500 },
    timings: '24x7',
  },
  {
    name: 'Patna Medical College & Hospital (PMCH)',
    type: 'medical_college',
    address: { street: 'Ashok Rajpath', city: 'Patna', district: 'Patna', state: 'Bihar', pincode: '800004' },
    lat: 25.6180, lng: 85.1690,
    phone: '0612-2300343',
    emergencyPhone: '0612-2300343',
    specialities: ['General Medicine', 'General Surgery', 'Orthopaedics', 'Paediatrics', 'Obstetrics & Gynaecology', 'ENT', 'Ophthalmology'],
    facilities: ['ICU', 'Blood Bank', 'Emergency', 'Pharmacy', 'X-Ray', 'Pathology'],
    beds: { total: 1800, available: 200 },
    rating: { average: 3.8, count: 5000 },
    timings: '24x7',
  },
  {
    name: 'Indira Gandhi Institute of Cardiology (IGIC)',
    type: 'government',
    address: { street: 'PMCH Campus', city: 'Patna', district: 'Patna', state: 'Bihar', pincode: '800004' },
    lat: 25.6175, lng: 85.1680,
    phone: '0612-2672862',
    specialities: ['Cardiology', 'Cardiac Surgery', 'Interventional Cardiology'],
    facilities: ['ICU', 'CCU', 'Cath Lab', 'Echo Lab', 'ECMO'],
    beds: { total: 400, available: 50 },
    rating: { average: 4.0, count: 2000 },
    timings: '24x7',
  },
  {
    name: 'Paras HMRI Hospital',
    type: 'private',
    address: { street: 'Raja Bazar, Bailey Road', city: 'Patna', district: 'Patna', state: 'Bihar', pincode: '800014' },
    lat: 25.6040, lng: 85.1440,
    phone: '0612-7107107',
    emergencyPhone: '0612-7107108',
    specialities: ['Cardiology', 'Neurosurgery', 'Orthopaedics', 'Oncology', 'Nephrology', 'Urology'],
    facilities: ['ICU', 'NICU', 'CT Scan', 'MRI', 'Blood Bank', 'Emergency', 'Cath Lab', 'Modular OT'],
    beds: { total: 350, available: 40 },
    rating: { average: 4.3, count: 2800 },
    timings: '24x7',
  },
  {
    name: 'Mahavir Vaatsalya Hospital',
    type: 'private',
    address: { street: 'Kankadbagh', city: 'Patna', district: 'Patna', state: 'Bihar', pincode: '800020' },
    lat: 25.5920, lng: 85.1670,
    phone: '0612-2353535',
    specialities: ['Paediatrics', 'Neonatology', 'General Surgery', 'Obstetrics & Gynaecology'],
    facilities: ['NICU', 'PICU', 'Blood Bank', 'Emergency', 'Pharmacy'],
    beds: { total: 200, available: 30 },
    rating: { average: 4.1, count: 1500 },
    timings: '24x7',
  },
  {
    name: 'Ruban Memorial Hospital',
    type: 'private',
    address: { street: 'Boring Road', city: 'Patna', district: 'Patna', state: 'Bihar', pincode: '800001' },
    lat: 25.6100, lng: 85.1310,
    phone: '0612-2531010',
    specialities: ['General Medicine', 'General Surgery', 'Orthopaedics', 'Cardiology', 'Gastroenterology'],
    facilities: ['ICU', 'CT Scan', 'MRI', 'Emergency', 'Pharmacy', 'Dialysis'],
    beds: { total: 300, available: 35 },
    rating: { average: 4.0, count: 1800 },
    timings: '24x7',
  },

  // ══════════════ MUZAFFARPUR ══════════════
  {
    name: 'Sri Krishna Medical College & Hospital (SKMCH)',
    type: 'medical_college',
    address: { street: 'Umanagar', city: 'Muzaffarpur', district: 'Muzaffarpur', state: 'Bihar', pincode: '842004' },
    lat: 26.1200, lng: 85.3900,
    phone: '0621-2240289',
    specialities: ['General Medicine', 'Paediatrics', 'General Surgery', 'Obstetrics & Gynaecology', 'Orthopaedics'],
    facilities: ['ICU', 'Blood Bank', 'Emergency', 'Pharmacy', 'X-Ray'],
    beds: { total: 1100, available: 150 },
    rating: { average: 3.5, count: 2500 },
    timings: '24x7',
  },

  // ══════════════ GAYA ══════════════
  {
    name: 'Anugrah Narayan Magadh Medical College & Hospital',
    type: 'medical_college',
    address: { street: 'Magadh University Road', city: 'Gaya', district: 'Gaya', state: 'Bihar', pincode: '823001' },
    lat: 24.7955, lng: 84.9994,
    phone: '0631-2220050',
    specialities: ['General Medicine', 'General Surgery', 'Paediatrics', 'Orthopaedics', 'Obstetrics & Gynaecology'],
    facilities: ['ICU', 'Blood Bank', 'Emergency', 'Pharmacy'],
    beds: { total: 800, available: 100 },
    rating: { average: 3.6, count: 1800 },
    timings: '24x7',
  },

  // ══════════════ BHAGALPUR ══════════════
  {
    name: 'Jawaharlal Nehru Medical College & Hospital',
    type: 'medical_college',
    address: { street: 'Mayaganj', city: 'Bhagalpur', district: 'Bhagalpur', state: 'Bihar', pincode: '812001' },
    lat: 25.2425, lng: 86.9842,
    phone: '0641-2401024',
    specialities: ['General Medicine', 'General Surgery', 'Paediatrics', 'ENT', 'Ophthalmology'],
    facilities: ['ICU', 'Blood Bank', 'Emergency', 'Pharmacy', 'X-Ray'],
    beds: { total: 700, available: 80 },
    rating: { average: 3.4, count: 1500 },
    timings: '24x7',
  },

  // ══════════════ DARBHANGA ══════════════
  {
    name: 'Darbhanga Medical College & Hospital (DMCH)',
    type: 'medical_college',
    address: { street: 'Laheriasarai', city: 'Darbhanga', district: 'Darbhanga', state: 'Bihar', pincode: '846003' },
    lat: 26.1522, lng: 85.9020,
    phone: '06272-222550',
    specialities: ['General Medicine', 'General Surgery', 'Paediatrics', 'Orthopaedics', 'Psychiatry'],
    facilities: ['ICU', 'Blood Bank', 'Emergency', 'Pharmacy'],
    beds: { total: 900, available: 100 },
    rating: { average: 3.5, count: 2000 },
    timings: '24x7',
  },

  // ══════════════ LUCKNOW (UP) ══════════════
  {
    name: 'King George Medical University (KGMU)',
    type: 'medical_college',
    address: { street: 'Chowk', city: 'Lucknow', district: 'Lucknow', state: 'Uttar Pradesh', pincode: '226003' },
    lat: 26.8580, lng: 80.9400,
    phone: '0522-2257540',
    specialities: ['Cardiology', 'Neurology', 'Orthopaedics', 'Oncology', 'General Surgery', 'Paediatrics', 'Nephrology'],
    facilities: ['ICU', 'NICU', 'CT Scan', 'MRI', 'Blood Bank', 'Emergency', 'Dialysis', 'Cath Lab'],
    beds: { total: 3500, available: 400 },
    rating: { average: 4.1, count: 5000 },
    timings: '24x7',
  },
  {
    name: 'Sanjay Gandhi Post Graduate Institute (SGPGI)',
    type: 'government',
    address: { street: 'Raebareli Road', city: 'Lucknow', district: 'Lucknow', state: 'Uttar Pradesh', pincode: '226014' },
    lat: 26.7970, lng: 80.9920,
    phone: '0522-2668700',
    specialities: ['Nephrology', 'Gastroenterology', 'Neurosurgery', 'Cardiology', 'Endocrinology', 'Hepatology'],
    facilities: ['ICU', 'NICU', 'CT Scan', 'MRI', 'PET Scan', 'Blood Bank', 'Emergency', 'Liver Transplant'],
    beds: { total: 1200, available: 150 },
    rating: { average: 4.4, count: 4000 },
    timings: '24x7',
  },

  // ══════════════ VARANASI (UP) ══════════════
  {
    name: 'Banaras Hindu University Hospital (BHU)',
    type: 'medical_college',
    address: { street: 'BHU Campus, Lanka', city: 'Varanasi', district: 'Varanasi', state: 'Uttar Pradesh', pincode: '221005' },
    lat: 25.2677, lng: 82.9913,
    phone: '0542-2368558',
    specialities: ['General Medicine', 'General Surgery', 'Orthopaedics', 'Oncology', 'Cardiology', 'Neurology'],
    facilities: ['ICU', 'NICU', 'CT Scan', 'MRI', 'Blood Bank', 'Emergency', 'Trauma Centre'],
    beds: { total: 2500, available: 300 },
    rating: { average: 4.0, count: 3500 },
    timings: '24x7',
  },
];

const ambulances = [
  // ══════════════ GOVERNMENT ══════════════
  {
    name: 'Bihar 108 Emergency Ambulance',
    type: 'advanced',
    phone: '108',
    alternatePhone: '0612-2294204',
    serviceArea: { city: 'Patna', district: 'Patna', state: 'Bihar', coverage: 'All 38 districts of Bihar' },
    lat: 25.5941, lng: 85.1376,
    isGovernment: true,
    is24x7: true,
    charges: { basePrice: 0, perKm: 0, currency: 'INR' },
    features: ['Oxygen', 'Trained EMT', 'Stretcher', 'First Aid Kit', 'GPS Tracked'],
    rating: { average: 3.8, count: 5000 },
  },
  {
    name: 'Bihar 102 Mother-Child Ambulance',
    type: 'basic',
    phone: '102',
    alternatePhone: '0612-2294205',
    serviceArea: { city: 'Patna', district: 'Patna', state: 'Bihar', coverage: 'All districts — Maternal and Child Emergency' },
    lat: 25.5941, lng: 85.1376,
    isGovernment: true,
    is24x7: true,
    charges: { basePrice: 0, perKm: 0, currency: 'INR' },
    features: ['Stretcher', 'First Aid Kit', 'Maternal Care Kit'],
    rating: { average: 3.5, count: 2000 },
  },
  {
    name: 'UP 108 Emergency Ambulance',
    type: 'advanced',
    phone: '108',
    alternatePhone: '0522-2627888',
    serviceArea: { city: 'Lucknow', district: 'Lucknow', state: 'Uttar Pradesh', coverage: 'All 75 districts of UP' },
    lat: 26.8467, lng: 80.9462,
    isGovernment: true,
    is24x7: true,
    charges: { basePrice: 0, perKm: 0, currency: 'INR' },
    features: ['Oxygen', 'Ventilator (select units)', 'Trained EMT', 'GPS Tracked', 'Stretcher'],
    rating: { average: 3.9, count: 8000 },
  },

  // ══════════════ PRIVATE (PATNA) ══════════════
  {
    name: 'Paras Ambulance Service Patna',
    type: 'icu',
    phone: '0612-7107107',
    alternatePhone: '9771002003',
    serviceArea: { city: 'Patna', district: 'Patna', state: 'Bihar', coverage: '100km radius from Patna' },
    lat: 25.6040, lng: 85.1440,
    isGovernment: false,
    is24x7: true,
    charges: { basePrice: 1500, perKm: 25, currency: 'INR' },
    features: ['ICU Setup', 'Ventilator', 'Oxygen', 'Defibrillator', 'Trained EMT', 'Doctor on board (critical cases)'],
    rating: { average: 4.3, count: 800 },
  },
  {
    name: 'Red Cross Ambulance Patna',
    type: 'basic',
    phone: '0612-2222693',
    serviceArea: { city: 'Patna', district: 'Patna', state: 'Bihar', coverage: 'Patna city and surrounding' },
    lat: 25.6100, lng: 85.1300,
    isGovernment: false,
    is24x7: true,
    charges: { basePrice: 500, perKm: 10, currency: 'INR' },
    features: ['Stretcher', 'First Aid Kit', 'Oxygen'],
    rating: { average: 3.7, count: 500 },
  },
  {
    name: 'Mahavir Vaatsalya Ambulance',
    type: 'neonatal',
    phone: '0612-2353535',
    serviceArea: { city: 'Patna', district: 'Patna', state: 'Bihar', coverage: 'Patna and nearby districts' },
    lat: 25.5920, lng: 85.1670,
    isGovernment: false,
    is24x7: true,
    charges: { basePrice: 2000, perKm: 30, currency: 'INR' },
    features: ['Neonatal Incubator', 'Ventilator', 'Oxygen', 'Trained Neonatal EMT'],
    rating: { average: 4.2, count: 400 },
  },

  // ══════════════ PRIVATE (MUZAFFARPUR) ══════════════
  {
    name: 'City Ambulance Muzaffarpur',
    type: 'basic',
    phone: '9876001002',
    serviceArea: { city: 'Muzaffarpur', district: 'Muzaffarpur', state: 'Bihar', coverage: 'Muzaffarpur city and 30km radius' },
    lat: 26.1200, lng: 85.3900,
    isGovernment: false,
    is24x7: true,
    charges: { basePrice: 800, perKm: 15, currency: 'INR' },
    features: ['Stretcher', 'First Aid Kit', 'Oxygen'],
    rating: { average: 3.6, count: 200 },
  },
];

// ═══════════════ SEED RUNNER ═══════════════
async function seedData() {
  try {
    console.log('\n🏥 Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB Atlas!\n');

    // Seed Hospitals
    let hospitalInserted = 0;
    let hospitalSkipped = 0;
    for (const h of hospitals) {
      const existing = await Hospital.findOne({ name: h.name });
      if (existing) {
        hospitalSkipped++;
        console.log(`⏩ Hospital already exists: ${h.name}`);
      } else {
        await Hospital.create(h);
        hospitalInserted++;
        console.log(`✅ Inserted hospital: ${h.name}`);
      }
    }

    // Seed Ambulances
    let ambulanceInserted = 0;
    let ambulanceSkipped = 0;
    for (const a of ambulances) {
      const existing = await Ambulance.findOne({ name: a.name });
      if (existing) {
        ambulanceSkipped++;
        console.log(`⏩ Ambulance already exists: ${a.name}`);
      } else {
        await Ambulance.create(a);
        ambulanceInserted++;
        console.log(`✅ Inserted ambulance: ${a.name}`);
      }
    }

    console.log('\n════════════════════════════════════════');
    console.log(`🏥 Hospitals: ${hospitalInserted} inserted, ${hospitalSkipped} skipped`);
    console.log(`🚑 Ambulances: ${ambulanceInserted} inserted, ${ambulanceSkipped} skipped`);
    console.log('════════════════════════════════════════\n');

    await mongoose.connection.close();
    console.log('🔌 MongoDB connection closed.\n');
    process.exit(0);
  } catch (error) {
    console.error('❌ Seed Error:', error);
    process.exit(1);
  }
}

seedData();
