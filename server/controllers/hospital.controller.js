const Hospital = require('../models/Hospital');

/**
 * @desc    Get all hospitals with optional filters
 * @route   GET /api/hospitals
 * @access  Public
 */
exports.getAllHospitals = async (req, res) => {
  try {
    const { city, district, type, search } = req.query;
    const query = { isActive: true };

    if (city) query['address.city'] = { $regex: new RegExp(city, 'i') };
    if (district) query['address.district'] = { $regex: new RegExp(district, 'i') };
    if (type) query.type = type;
    if (search) {
      query.$or = [
        { name: { $regex: new RegExp(search, 'i') } },
        { 'address.city': { $regex: new RegExp(search, 'i') } },
        { specialities: { $in: [new RegExp(search, 'i')] } },
      ];
    }

    const hospitals = await Hospital.find(query).sort({ 'rating.average': -1 });

    res.status(200).json({
      success: true,
      count: hospitals.length,
      hospitals,
    });
  } catch (error) {
    console.error('❌ Get Hospitals Error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error while retrieving hospitals',
    });
  }
};

/**
 * @desc    Get a single hospital by ID
 * @route   GET /api/hospitals/:id
 * @access  Public
 */
exports.getHospitalById = async (req, res) => {
  try {
    const hospital = await Hospital.findById(req.params.id);
    if (!hospital) {
      return res.status(404).json({
        success: false,
        error: 'Hospital not found',
      });
    }

    res.status(200).json({ success: true, hospital });
  } catch (error) {
    console.error('❌ Get Hospital By ID Error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error while retrieving hospital',
    });
  }
};

/**
 * @desc    Get nearby hospitals sorted by distance
 * @route   GET /api/hospitals/nearby
 * @access  Public
 */
exports.getNearbyHospitals = async (req, res) => {
  try {
    const { lat, lng, type, maxDistance = 50 } = req.query;

    if (!lat || !lng) {
      return res.status(400).json({
        success: false,
        error: 'Please provide lat and lng coordinates',
      });
    }

    const userLat = parseFloat(lat);
    const userLng = parseFloat(lng);
    const query = { isActive: true };
    if (type) query.type = type;

    const hospitals = await Hospital.find(query);

    // Haversine distance
    const getDistance = (lat1, lon1, lat2, lon2) => {
      const R = 6371;
      const dLat = ((lat2 - lat1) * Math.PI) / 180;
      const dLon = ((lon2 - lon1) * Math.PI) / 180;
      const a =
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos((lat1 * Math.PI) / 180) *
          Math.cos((lat2 * Math.PI) / 180) *
          Math.sin(dLon / 2) *
          Math.sin(dLon / 2);
      const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
      return R * c;
    };

    const nearbyHospitals = hospitals
      .map((h) => {
        const dist = h.lat && h.lng ? getDistance(userLat, userLng, h.lat, h.lng) : Infinity;
        return { ...h.toObject(), distance: dist === Infinity ? null : parseFloat(dist.toFixed(2)) };
      })
      .filter((h) => h.distance !== null && h.distance <= parseFloat(maxDistance))
      .sort((a, b) => a.distance - b.distance);

    res.status(200).json({
      success: true,
      count: nearbyHospitals.length,
      hospitals: nearbyHospitals,
    });
  } catch (error) {
    console.error('❌ Get Nearby Hospitals Error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error while searching nearby hospitals',
    });
  }
};

/**
 * @desc    Admin: Create a new hospital
 * @route   POST /api/hospitals
 * @access  Private (Admin)
 */
exports.createHospital = async (req, res) => {
  try {
    const hospital = await Hospital.create(req.body);
    res.status(201).json({ success: true, hospital });
  } catch (error) {
    console.error('❌ Create Hospital Error:', error);
    if (error.name === 'ValidationError') {
      const messages = Object.values(error.errors).map(e => e.message);
      return res.status(400).json({ success: false, error: messages.join('. ') });
    }
    res.status(500).json({ success: false, error: 'Server error while creating hospital' });
  }
};

/**
 * @desc    Admin: Update a hospital
 * @route   PUT /api/hospitals/:id
 * @access  Private (Admin)
 */
exports.updateHospital = async (req, res) => {
  try {
    const hospital = await Hospital.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });
    if (!hospital) {
      return res.status(404).json({ success: false, error: 'Hospital not found' });
    }
    res.status(200).json({ success: true, hospital });
  } catch (error) {
    console.error('❌ Update Hospital Error:', error);
    res.status(500).json({ success: false, error: 'Server error while updating hospital' });
  }
};
