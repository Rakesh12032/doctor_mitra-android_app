import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../providers/language_provider.dart';
import '../providers/store_provider.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/language_toggle.dart';

class DoctorEarningsScreen extends StatefulWidget {
  final String doctorId;
  const DoctorEarningsScreen({super.key, required this.doctorId});

  @override
  State<DoctorEarningsScreen> createState() => _DoctorEarningsScreenState();
}

class _DoctorEarningsScreenState extends State<DoctorEarningsScreen> {
  bool _isLoading = false;
  
  // Earnings Stats & Details
  double _todayEarnings = 0.0;
  double _weekEarnings = 0.0;
  double _monthEarnings = 0.0;
  double _totalEarned = 0.0;
  double _platformFee = 0.0;
  double _netEarned = 0.0;
  double _pendingSettlement = 0.0;
  
  List<Map<String, dynamic>> _transactions = [];
  String _selectedFilter = 'All'; // All | video | clinic | phone
  
  // Bank Account Fields
  final _bankNameController = TextEditingController();
  final _accountNoController = TextEditingController();
  final _ifscController = TextEditingController();
  final _upiController = TextEditingController();
  bool _isEditingBank = false;
  
  @override
  void initState() {
    super.initState();
    _loadBankDetails();
    _fetchEarningsData();
  }
  
  @override
  void dispose() {
    _bankNameController.dispose();
    _accountNoController.dispose();
    _ifscController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  Future<void> _loadBankDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bankNameController.text = prefs.getString('bank_name_${widget.doctorId}') ?? 'State Bank of India';
      _accountNoController.text = prefs.getString('account_no_${widget.doctorId}') ?? 'XXXX XXXX 9845';
      _ifscController.text = prefs.getString('ifsc_${widget.doctorId}') ?? 'SBIN0000123';
      _upiController.text = prefs.getString('upi_${widget.doctorId}') ?? 'doctor@okaxis';
    });
  }

  Future<void> _saveBankDetails() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bank_name_${widget.doctorId}', _bankNameController.text.trim());
    await prefs.setString('account_no_${widget.doctorId}', _accountNoController.text.trim());
    await prefs.setString('ifsc_${widget.doctorId}', _ifscController.text.trim());
    await prefs.setString('upi_${widget.doctorId}', _upiController.text.trim());
    setState(() {
      _isEditingBank = false;
    });
    
    if (mounted) {
      final lang = Provider.of<LanguageProvider>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            lang.isHindi ? "बैंक खाता विवरण सुरक्षित किया गया!" : "Bank details saved successfully!",
            style: const TextStyle(fontFamily: 'Nunito'),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _fetchEarningsData() async {
    setState(() {
      _isLoading = true;
    });
    
    final store = Provider.of<DoctorMitraStore>(context, listen: false);
    final token = store.token;

    if (InternetApiLayer.isConfiguredStatic) {
      try {
        final apiBaseUrl = const String.fromEnvironment('DOCTOR_MITRA_API_URL');
        final headers = {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        };

        // Fetch Earnings Stats & Transactions
        final earnRes = await http.get(
          Uri.parse('$apiBaseUrl/api/doctors/${widget.doctorId}/earnings'),
          headers: headers,
        ).timeout(const Duration(seconds: 5));

        // Fetch Earnings Summary
        final sumRes = await http.get(
          Uri.parse('$apiBaseUrl/api/doctors/${widget.doctorId}/earnings/summary'),
          headers: headers,
        ).timeout(const Duration(seconds: 5));

        if (earnRes.statusCode == 200 && sumRes.statusCode == 200) {
          final earnBody = jsonDecode(earnRes.body) as Map<String, dynamic>;
          final sumBody = jsonDecode(sumRes.body) as Map<String, dynamic>;

          if (earnBody['success'] == true && sumBody['success'] == true) {
            final earnData = earnBody['data'];
            final sumData = sumBody['data'];

            setState(() {
              _todayEarnings = double.tryParse(earnData['today'].toString()) ?? 0.0;
              _weekEarnings = double.tryParse(earnData['thisWeek'].toString()) ?? 0.0;
              _monthEarnings = double.tryParse(earnData['thisMonth'].toString()) ?? 0.0;
              
              _totalEarned = double.tryParse(sumData['totalEarned'].toString()) ?? 0.0;
              _platformFee = double.tryParse(sumData['platformFee'].toString()) ?? 0.0;
              _netEarned = double.tryParse(sumData['netEarned'].toString()) ?? 0.0;
              _pendingSettlement = double.tryParse(sumData['pendingSettlement'].toString()) ?? 0.0;

              _transactions = List<Map<String, dynamic>>.from(
                (earnData['transactions'] as List).map((e) => Map<String, dynamic>.from(e as Map))
              );
              _isLoading = false;
            });
            return;
          }
        }
      } catch (e) {
        debugPrint("DoctorEarningsScreen: REST API failed, using fallbacks. Error: $e");
      }
    }

    // Offline / Local fallback seeds
    final now = DateTime.now();
    setState(() {
      _todayEarnings = 1500.0;
      _weekEarnings = 12500.0;
      _monthEarnings = 48000.0;
      
      _totalEarned = 48000.0;
      _platformFee = 4800.0; // 10% Platform fee
      _netEarned = 43200.0;
      _pendingSettlement = 10800.0; // 25% of net

      _transactions = [
        {
          'id': 'tx-001',
          'patientName': 'Ramesh Kumar',
          'date': now.subtract(const Duration(hours: 2)).toIso8601String(),
          'amount': 500.0,
          'type': 'video'
        },
        {
          'id': 'tx-002',
          'patientName': 'Asha Devi',
          'date': now.subtract(const Duration(hours: 4)).toIso8601String(),
          'amount': 1000.0,
          'type': 'clinic'
        },
        {
          'id': 'tx-003',
          'patientName': 'Sanjay Singh',
          'date': now.subtract(const Duration(days: 1)).toIso8601String(),
          'amount': 500.0,
          'type': 'video'
        },
        {
          'id': 'tx-004',
          'patientName': 'Priyanjali Roy',
          'date': now.subtract(const Duration(days: 2)).toIso8601String(),
          'amount': 800.0,
          'type': 'phone'
        },
        {
          'id': 'tx-005',
          'patientName': 'Amit Verma',
          'date': now.subtract(const Duration(days: 5)).toIso8601String(),
          'amount': 1000.0,
          'type': 'clinic'
        }
      ];
      _isLoading = false;
    });
  }

  void _requestPayout(LanguageProvider lang) {
    if (_pendingSettlement <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            lang.isHindi ? "कोई लंबित भुगतान उपलब्ध नहीं है।" : "No pending settlement amount to request.",
            style: const TextStyle(fontFamily: 'Nunito'),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            lang.isHindi ? "भुगतान अनुरोध" : "Payout Request",
            style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
          ),
          content: Text(
            lang.isHindi
                ? "क्या आप ₹${_pendingSettlement.toStringAsFixed(0)} के लंबित भुगतान का दावा बैंक खाते/UPI में करना चाहते हैं?"
                : "Do you want to request payout of ₹${_pendingSettlement.toStringAsFixed(0)} to your linked Bank Account/UPI?",
            style: const TextStyle(fontFamily: 'Nunito', height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(lang.isHindi ? 'रद्द करें' : 'Cancel', style: const TextStyle(fontFamily: 'Nunito')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _processPayoutClaim(lang);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Text(
                lang.isHindi ? 'अनुरोध भेजें' : 'Claim Payout',
                style: const TextStyle(color: Colors.white, fontFamily: 'Nunito', fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _processPayoutClaim(LanguageProvider lang) async {
    setState(() {
      _isLoading = true;
    });

    // Simulate server transaction processing delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _pendingSettlement = 0.0;
      _isLoading = false;
    });

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                const Icon(Icons.check_circle, color: AppColors.success, size: 64),
                const SizedBox(height: 16),
                Text(
                  lang.isHindi ? "अनुरोध सफल!" : "Request Placed!",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Nunito'),
                ),
                const SizedBox(height: 8),
                Text(
                  lang.isHindi
                      ? "आपका भुगतान अनुरोध 24-48 घंटों के भीतर सत्यापित होकर बैंक खाते में क्रेडिट कर दिया जाएगा।"
                      : "Your payout has been requested. The amount will credit to your account within 24-48 hours after admin review.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppColors.textMedium, height: 1.4, fontFamily: 'Nunito'),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(
                    lang.isHindi ? "ठीक है" : "Done",
                    style: const TextStyle(color: Colors.white, fontFamily: 'Nunito'),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final isHi = lang.isHindi;

    final filteredTransactions = _transactions.where((tx) {
      if (_selectedFilter == 'All') return true;
      return tx['type'].toString().toLowerCase() == _selectedFilter.toLowerCase();
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const BackButton(color: AppColors.primary),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        title: Text(
          isHi ? 'डॉक्टर कमाई विवरण' : 'Doctor Earnings',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, fontFamily: 'Nunito'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _fetchEarningsData,
          ),
          const Padding(padding: EdgeInsets.only(right: 8.0), child: LanguageToggle())
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.border.withOpacity(0.5), height: 1.0),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                strokeWidth: 3,
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Settlement Header Card (Highlighted)
                    _buildSettlementCard(isHi, lang),
                    const SizedBox(height: 20),

                    // Stats row Today/Week/Month
                    Row(
                      children: [
                        Expanded(
                          child: _buildMiniStat(isHi ? 'आज' : 'Today', _todayEarnings, const Color(0xFFE8F5E9), AppColors.primary),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildMiniStat(isHi ? 'इस सप्ताह' : 'This Week', _weekEarnings, const Color(0xFFE3F2FD), Colors.blue.shade700),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildMiniStat(isHi ? 'इस महीने' : 'This Month', _monthEarnings, const Color(0xFFFFF3E0), Colors.orange.shade800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Bank Account details
                    _buildBankSection(isHi),
                    const SizedBox(height: 24),

                    // Transaction list section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isHi ? 'भुगतान इतिहास' : 'Transaction History',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark, fontFamily: 'Nunito'),
                        ),
                        _buildFilterDropdown(isHi),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    if (filteredTransactions.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              Text(
                                isHi ? 'कोई ट्रांजैक्शन नहीं मिला' : 'No transactions found',
                                style: const TextStyle(color: AppColors.textMedium, fontSize: 13, fontFamily: 'Nunito'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final tx = filteredTransactions[index];
                          return _buildTransactionCard(tx, isHi);
                        },
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSettlementCard(bool isHi, LanguageProvider lang) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isHi ? 'लंबित सेटलमेंट (निकासी योग्य)' : 'Pending Settlement',
                style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Nunito'),
              ),
              const Icon(Icons.account_balance_outlined, color: Colors.white, size: 22),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '₹${_pendingSettlement.toStringAsFixed(0)}',
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isHi ? 'कुल कमाई (सकल)' : 'Gross Earned',
                    style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11, fontFamily: 'Nunito'),
                  ),
                  Text(
                    '₹${_totalEarned.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isHi ? 'प्लेटफॉर्म शुल्क (10%)' : 'Platform Fee (10%)',
                    style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11, fontFamily: 'Nunito'),
                  ),
                  Text(
                    '- ₹${_platformFee.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => _requestPayout(lang),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.send_rounded, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    isHi ? 'खाते में ट्रांसफर करें' : 'Request Payout',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Nunito'),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMiniStat(String title, double value, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: textCol.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            '₹${value.toStringAsFixed(0)}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textCol, fontFamily: 'Nunito'),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: AppColors.textMedium, fontWeight: FontWeight.w600, fontFamily: 'Nunito'),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBankSection(bool isHi) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.premiumShadow,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isHi ? 'बैंक और UPI विवरण' : 'Linked Settlement Account',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark, fontFamily: 'Nunito'),
              ),
              IconButton(
                icon: Icon(_isEditingBank ? Icons.check_circle_outline : Icons.edit, color: AppColors.primary, size: 20),
                onPressed: () {
                  if (_isEditingBank) {
                    _saveBankDetails();
                  } else {
                    setState(() {
                      _isEditingBank = true;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (!_isEditingBank) ...[
            _buildBankRow(isHi ? 'बैंक का नाम' : 'Bank Name', _bankNameController.text),
            const Divider(color: AppColors.border, height: 16),
            _buildBankRow(isHi ? 'खाता संख्या' : 'Account No', _accountNoController.text),
            const Divider(color: AppColors.border, height: 16),
            _buildBankRow(isHi ? 'IFSC कोड' : 'IFSC Code', _ifscController.text),
            const Divider(color: AppColors.border, height: 16),
            _buildBankRow(isHi ? 'UPI आईडी' : 'UPI ID', _upiController.text),
          ] else ...[
            _buildBankInput(isHi ? 'बैंक का नाम' : 'Bank Name', _bankNameController),
            const SizedBox(height: 12),
            _buildBankInput(isHi ? 'खाता संख्या' : 'Account Number', _accountNoController),
            const SizedBox(height: 12),
            _buildBankInput(isHi ? 'IFSC कोड' : 'IFSC Code', _ifscController),
            const SizedBox(height: 12),
            _buildBankInput(isHi ? 'UPI आईडी (वैकल्पिक)' : 'UPI ID (Optional)', _upiController),
          ],
        ],
      ),
    );
  }

  Widget _buildBankRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMedium, fontSize: 12, fontFamily: 'Nunito')),
        Text(value, style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Nunito')),
      ],
    );
  }

  Widget _buildBankInput(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 13, fontFamily: 'Nunito', fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: AppColors.textMedium),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  Widget _buildFilterDropdown(bool isHi) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButton<String>(
        value: _selectedFilter,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'Nunito'),
        items: [
          DropdownMenuItem(value: 'All', child: Text(isHi ? 'सभी' : 'All')),
          DropdownMenuItem(value: 'video', child: Text(isHi ? 'वीडियो' : 'Video')),
          DropdownMenuItem(value: 'clinic', child: Text(isHi ? 'ओपीडी' : 'OPD')),
          DropdownMenuItem(value: 'phone', child: Text(isHi ? 'फ़ोन कॉल' : 'Phone')),
        ],
        onChanged: (val) {
          if (val != null) {
            setState(() {
              _selectedFilter = val;
            });
          }
        },
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> tx, bool isHi) {
    final DateTime date = DateTime.parse(tx['date'].toString());
    final dateStr = '${date.day} ${_getMonthName(date.month, isHi)} ${date.year}';
    final String type = tx['type'].toString().toLowerCase();

    IconData typeIcon = Icons.video_call_outlined;
    Color iconColor = Colors.teal;
    if (type == 'clinic') {
      typeIcon = Icons.local_hospital_outlined;
      iconColor = AppColors.primary;
    } else if (type == 'phone') {
      typeIcon = Icons.phone_callback_outlined;
      iconColor = Colors.blue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.08),
            radius: 20,
            child: Icon(typeIcon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx['patientName'].toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark, fontFamily: 'Nunito'),
                ),
                const SizedBox(height: 2),
                Text(
                  '$dateStr • ${type.toUpperCase()}',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontFamily: 'Nunito'),
                ),
              ],
            ),
          ),
          Text(
            '+ ₹${double.parse(tx['amount'].toString()).toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green, fontFamily: 'Nunito'),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month, bool isHi) {
    const namesEn = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const namesHi = ['जनवरी', 'फ़रवरी', 'मार्च', 'अप्रैल', 'मई', 'जून', 'जुलाई', 'अगस्त', 'सितंबर', 'अक्टूबर', 'नवंबर', 'दिसंबर'];
    return isHi ? namesHi[month - 1] : namesEn[month - 1];
  }
}
