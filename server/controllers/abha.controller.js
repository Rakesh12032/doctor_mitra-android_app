const User = require('../models/User');

/**
 * @desc    Mock ABDM Sandbox API for ABHA Verification
 * @route   POST /api/abha/verify
 * @access  Private (Patient)
 */
exports.verifyAbha = async (req, res) => {
  try {
    const { abhaNumber, action, otp, transactionId } = req.body;

    if (!abhaNumber || abhaNumber.replace(/[^0-9]/g, '').length !== 14) {
      return res.status(400).json({
        success: false,
        error: 'Please provide a valid 14-digit ABHA Number',
      });
    }

    if (action === 'send_otp') {
      // Mock ABDM Sandbox OTP generation
      const mockTxId = `txn_${Math.random().toString(36).substring(2, 15)}`;
      return res.status(200).json({
        success: true,
        message: 'OTP sent to mobile registered with Aadhaar/ABHA',
        data: {
          transactionId: mockTxId,
          otpExpiredAt: new Date(Date.now() + 5 * 60000), // 5 min
        },
      });
    } else if (action === 'verify_otp') {
      if (!otp || otp.trim().length !== 6) {
        return res.status(400).json({
          success: false,
          error: 'Please provide a valid 6-digit OTP',
        });
      }

      if (otp !== '123456' && otp !== '654321') {
        return res.status(400).json({
          success: false,
          error: 'Invalid OTP. Please try again or use default code 123456.',
        });
      }

      // Mock demographic fetch from ABDM Sandbox registry
      const mockProfile = {
        name: 'Rakesh Raj',
        gender: 'Male',
        dob: '18-05-1996',
        photo: 'https://images.unsplash.com/photo-1537368910025-700350fe46c7?auto=format&fit=crop&w=400&q=80',
        abhaAddress: 'rakeshraj18@abdm',
        mobile: req.user?.phone || '9876543210',
        qrCodeText: `ABDM:ABHA-CARD:14-digit:${abhaNumber}:name:Rakesh Raj:address:rakeshraj18@abdm`,
      };

      return res.status(200).json({
        success: true,
        message: 'ABHA OTP verified successfully and profile retrieved',
        data: mockProfile,
      });
    } else {
      return res.status(400).json({
        success: false,
        error: 'Invalid verification action. Use "send_otp" or "verify_otp"',
      });
    }
  } catch (error) {
    console.error('❌ ABHA Verification Error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error during ABHA demographic check',
    });
  }
};

/**
 * @desc    Link verified ABHA number and address to user profile
 * @route   POST /api/abha/link
 * @access  Private (Patient)
 */
exports.linkAbha = async (req, res) => {
  try {
    const { userId, abhaNumber, abhaAddress } = req.body;

    if (!userId || !abhaNumber || !abhaAddress) {
      return res.status(400).json({
        success: false,
        error: 'Please provide all required fields: userId, abhaNumber, abhaAddress',
      });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found',
      });
    }

    user.abha = {
      abhaNumber: abhaNumber.replace(/[^0-9]/g, ''),
      abhaAddress: abhaAddress.trim().toLowerCase(),
      isLinked: true,
      linkedAt: new Date(),
    };

    // Auto-update name if empty
    if (!user.name) {
      user.name = 'Rakesh Raj';
    }

    await user.save();

    res.status(200).json({
      success: true,
      message: 'ABHA card linked successfully to your profile',
      data: user,
    });
  } catch (error) {
    console.error('❌ ABHA Linkage Error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error while linking ABHA details',
    });
  }
};

/**
 * @desc    Get linked ABHA details for a user
 * @route   GET /api/abha/:userId
 * @access  Private (Patient/Doctor)
 */
exports.getAbhaDetails = async (req, res) => {
  try {
    const { userId } = req.params;

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found',
      });
    }

    if (!user.abha || !user.abha.isLinked) {
      return res.status(200).json({
        success: true,
        linked: false,
        message: 'No ABHA details linked to this profile yet',
      });
    }

    // Mock demographic card details formatted nicely
    const mockCard = {
      abhaNumber: user.abha.abhaNumber,
      abhaAddress: user.abha.abhaAddress,
      name: user.name || 'Rakesh Raj',
      gender: user.gender || 'Male',
      dob: user.dob ? user.dob.toISOString().split('T')[0] : '18-05-1996',
      photo: user.profilePhoto || 'https://images.unsplash.com/photo-1537368910025-700350fe46c7?auto=format&fit=crop&w=400&q=80',
      isLinked: true,
      linkedAt: user.abha.linkedAt,
      qrCodeText: `ABDM:ABHA-CARD:14-digit:${user.abha.abhaNumber}:name:${user.name || 'Rakesh Raj'}:address:${user.abha.abhaAddress}`,
    };

    res.status(200).json({
      success: true,
      linked: true,
      data: mockCard,
    });
  } catch (error) {
    console.error('❌ Get ABHA Details Error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error while retrieving ABHA details',
    });
  }
};
