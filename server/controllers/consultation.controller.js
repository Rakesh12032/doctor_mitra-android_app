const Appointment = require('../models/Appointment');
let RtcTokenBuilder, RtcRole;

try {
  const agoraToken = require('agora-token');
  RtcTokenBuilder = agoraToken.RtcTokenBuilder;
  RtcRole = agoraToken.RtcRole;
} catch (err) {
  console.warn('⚠️ Agora-token package load warning. Dynamic compilation fallbacks active.');
}

/**
 * @desc    Generate Agora Video Consultation access token for an appointment channel
 * @route   GET /api/consultations/video-token/:appointmentId
 * @access  Private (Patient/Doctor)
 */
exports.getVideoToken = async (req, res) => {
  try {
    const { appointmentId } = req.params;

    const appointment = await Appointment.findById(appointmentId).populate('doctor patient');
    if (!appointment) {
      return res.status(404).json({
        success: false,
        error: 'Appointment booking not found',
      });
    }

    // Verify authorized party (Patient or Doctor of the appointment)
    const isPatient = appointment.patient._id.toString() === req.user._id.toString();
    const isDoctor = appointment.doctor._id.toString() === req.user._id.toString();
    const isAdmin = req.user.role === 'admin';

    if (!isPatient && !isDoctor && !isAdmin) {
      return res.status(403).json({
        success: false,
        error: 'Not authorized to request video tokens for this consultation',
      });
    }

    if (appointment.appointmentType !== 'video') {
      return res.status(400).json({
        success: false,
        error: 'This appointment is not scheduled for online video consultation',
      });
    }

    const appId = process.env.AGORA_APP_ID;
    const appCertificate = process.env.AGORA_APP_CERTIFICATE;

    const channelName = appointmentId.toString();
    const uid = 0; // Dynamic client allocation
    let token = 'mock-agora-token-12032';
    let isMock = true;

    // Standard credential checking
    if (
      appId && appId !== 'your_agora_app_id' &&
      appCertificate && appCertificate !== 'your_agora_app_certificate' &&
      RtcTokenBuilder && RtcRole
    ) {
      try {
        const role = RtcRole.PUBLISHER;
        const expirationTimeInSeconds = 7200; // 2 hour duration
        const currentTimestamp = Math.floor(Date.now() / 1000);
        const privilegeExpireTime = currentTimestamp + expirationTimeInSeconds;

        token = RtcTokenBuilder.buildTokenWithUid(
          appId,
          appCertificate,
          channelName,
          uid,
          role,
          privilegeExpireTime
        );
        isMock = false;
      } catch (tokenBuildErr) {
        console.error('❌ Agora Token Generation Error:', tokenBuildErr.message);
        // gracefully fall back to mock
      }
    }

    if (isMock) {
      console.log(`[MOCK AGORA TOKEN DISPATCHED]: Channel="${channelName}"`);
    }

    // Save token in the booking link reference field
    appointment.meetingLink = token;
    await appointment.save();

    res.status(200).json({
      success: true,
      token,
      channelName,
      appId: isMock ? 'mock-agora-app-id-12032' : appId,
      isMock,
    });
  } catch (error) {
    console.error('❌ Get Video Consultation Token Error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error occurred while preparing consultation room',
    });
  }
};
