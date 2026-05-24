const http = require('https');

/**
 * Sends SMS OTP using 2Factor API gateway.
 * Falls back to console logger in development if no API Key is configured.
 * 
 * @param {string} phone 10-digit mobile number with or without prefix
 * @param {string} otp 6-digit OTP code
 * @returns {Promise<{success: boolean, message: string}>}
 */
const sendOtpSms = (phone, otp) => {
  return new Promise((resolve) => {
    const apiKey = process.env.TWOFACTOR_API_KEY;
    const templateId = process.env.TWOFACTOR_TEMPLATE_NAME;

    // Check if we are in development or keys are default placeholders
    if (
      process.env.NODE_ENV === 'development' ||
      !apiKey ||
      apiKey.includes('your_2factor_api_key') ||
      apiKey === ''
    ) {
      console.log(`\n--------------------------------------------`);
      console.log(`📱 MOCK SMS SEND (2FACTOR GATEWAY)`);
      console.log(`To: +91 ${phone}`);
      console.log(`Message: Your Doctor Mitra verification code is: ${otp}`);
      console.log(`--------------------------------------------\n`);
      return resolve({
        success: true,
        message: 'Mock OTP sent successfully in development mode.',
      });
    }

    // Clean phone number format (+91 prefix handling)
    let formattedPhone = phone.trim();
    if (!formattedPhone.startsWith('+91') && !formattedPhone.startsWith('91')) {
      formattedPhone = `91${formattedPhone}`;
    } else if (formattedPhone.startsWith('+91')) {
      formattedPhone = formattedPhone.replace('+91', '91');
    }

    // Build 2Factor request URL
    // Standard GET template: https://2factor.in/API/V1/{api_key}/SMS/{phone}/{otp}/{template_name}
    const url = `https://2factor.in/API/V1/${apiKey}/SMS/${formattedPhone}/${otp}/${templateId || 'DoctorMitraOTP'}`;

    http.get(url, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        try {
          const parsed = JSON.parse(data);
          if (parsed.Status === 'Success') {
            console.log(`📡 2Factor SMS Sent successfully to +91 ${phone}`);
            resolve({ success: true, message: 'OTP sent successfully.' });
          } else {
            console.error(`❌ 2Factor Error response:`, parsed);
            resolve({ success: false, message: parsed.Details || 'Failed to send SMS via 2Factor.' });
          }
        } catch (e) {
          console.error(`❌ Failed to parse 2Factor response:`, data);
          resolve({ success: false, message: 'Invalid response from SMS gateway.' });
        }
      });
    }).on('error', (err) => {
      console.error(`❌ 2Factor Connection Error:`, err.message);
      resolve({ success: false, message: 'SMS gateway connection failed.' });
    });
  });
};

module.exports = { sendOtpSms };
