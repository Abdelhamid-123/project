import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

class DatabaseService {
  static const String _baseURL = 'https://myflutterapp123.atwebpages.com';
  static final EncryptedSharedPreferences _encryptedData = EncryptedSharedPreferences();

  static Future<void> saveConversion({
  required double amount,
  required String fromCurrency,
  required String toCurrency,
  required double convertedAmount,
  }) async {
  try {
  String? key = await _encryptedData.getString('myKey');
  if (key == null || key.isEmpty) {
  print('No key found for database access');
  return;
  }

  final response = await http.post(
  Uri.parse('$_baseURL/save_conversion.php'),
  headers: <String, String>{
  'Content-Type': 'application/json; charset=UTF-8',
  },
  body: jsonEncode(<String, dynamic>{
  'amount': amount,
  'fromCurrency': fromCurrency,
  'toCurrency': toCurrency,
  'convertedAmount': convertedAmount,
  'key': key,
  }),
  ).timeout(const Duration(seconds: 5));

  if (response.statusCode == 200) {
  print('Conversion saved: ${response.body}');
  } else {
  print('Failed to save conversion: ${response.statusCode}');
  }
  } catch (e) {
  print('Error saving conversion: $e');
  }
  }
  static Future<void> saveTipCalculation({
  required double billAmount,
  required double tipPercentage,
  required int numberOfPeople,
  required double totalTip,
  required double totalBill,
  required double perPerson,
  }) async {
  try {
  String? key = await _encryptedData.getString('myKey');
  if (key == null || key.isEmpty) {
  print('No key found for database access');
  return;
  }

  final response = await http.post(
  Uri.parse('$_baseURL/save_tip.php'),
  headers: <String, String>{
  'Content-Type': 'application/json; charset=UTF-8',
  },
  body: jsonEncode(<String, dynamic>{
  'billAmount': billAmount,
  'tipPercentage': tipPercentage,
  'numberOfPeople': numberOfPeople,
  'totalTip': totalTip,
  'totalBill': totalBill,
  'perPerson': perPerson,
  'key': key,
  }),
  ).timeout(const Duration(seconds: 5));

  if (response.statusCode == 200) {
  print('Tip calculation saved: ${response.body}');
  } else {
  print('Failed to save tip: ${response.statusCode}');
  }
  } catch (e) {
  print('Error saving tip: $e');
  }
  }

  static Future<bool> saveKey(String key) async {
  try {
  return await _encryptedData.setString('myKey', key);
  } catch (e) {
  print('Error saving key: $e');
  return false;
  }
  }

  static Future<String?> getKey() async {
  try {
  return await _encryptedData.getString('myKey');
  } catch (e) {
  print('Error getting key: $e');
  return null;
  }
  }

  static Future<void> removeKey() async {
  try {

  await _encryptedData.clear();

  } catch (e) {
  print('Error removing key: $e');
  }
  }
  }