const Ambulance = require('../models/Ambulance');

/**
 * @desc    Get all ambulance services with optional filters
 * @route   GET /api/ambulances
 * @access  Public
 */
exports.getAllAmbulances = async (req, res) => {
  try {
    const { city, district, type, isGovernment } = req.query;
    const query = { isActive: true };

    if (city) query['serviceArea.city'] = { $regex: new RegExp(city, 'i') };
    if (district) query['serviceArea.district'] = { $regex: new RegExp(district, 'i') };
    if (type) query.type = type;
    if (isGovernment !== undefined) query.isGovernment = isGovernment === 'true';

    const ambulances = await Ambulance.find(query).sort({ isGovernment: -1, 'rating.average': -1 });

    res.status(200).json({
      success: true,
      count: ambulances.length,
      ambulances,
    });
  } catch (error) {
    console.error('❌ Get Ambulances Error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error while retrieving ambulance services',
    });
  }
};

/**
 * @desc    Get nearby ambulances sorted by distance
 * @route   GET /api/ambulances/nearby
 * @access  Public
 */
exports.getNearbyAmbulances = async (req, res) => {
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

    const ambulances = await Ambulance.find(query);

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

    const nearbyAmbulances = ambulances
      .map((a) => {
        const dist = a.lat && a.lng ? getDistance(userLat, userLng, a.lat, a.lng) : Infinity;
        return { ...a.toObject(), distance: dist === Infinity ? null : parseFloat(dist.toFixed(2)) };
      })
      .filter((a) => a.distance !== null && a.distance <= parseFloat(maxDistance))
      .sort((a, b) => a.distance - b.distance);

    res.status(200).json({
      success: true,
      count: nearbyAmbulances.length,
      ambulances: nearbyAmbulances,
    });
  } catch (error) {
    console.error('❌ Get Nearby Ambulances Error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error while searching nearby ambulances',
    });
  }
};

/**
 * @desc    Admin: Create a new ambulance service
 * @route   POST /api/ambulances
 * @access  Private (Admin)
 */
exports.createAmbulance = async (req, res) => {
  try {
    const ambulance = await Ambulance.create(req.body);
    res.status(201).json({ success: true, ambulance });
  } catch (error) {
    console.error('❌ Create Ambulance Error:', error);
    if (error.name === 'ValidationError') {
      const messages = Object.values(error.errors).map(e => e.message);
      return res.status(400).json({ success: false, error: messages.join('. ') });
    }
    res.status(500).json({ success: false, error: 'Server error while creating ambulance service' });
  }
};

/**
 * @desc    Admin: Update an ambulance service
 * @route   PUT /api/ambulances/:id
 * @access  Private (Admin)
 */
exports.updateAmbulance = async (req, res) => {
  try {
    const ambulance = await Ambulance.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });
    if (!ambulance) {
      return res.status(404).json({ success: false, error: 'Ambulance service not found' });
    }
    res.status(200).json({ success: true, ambulance });
  } catch (error) {
    console.error('❌ Update Ambulance Error:', error);
    res.status(500).json({ success: false, error: 'Server error while updating ambulance service' });
  }
};
