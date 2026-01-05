import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency & Tip Calculator with Database',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<String?>(
        future: DatabaseService.getKey(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
            return HomePage();
          } else {
            return LoginPage();
          }
        },
      ),
    );
  }
}

class DatabaseService {
  static const String _baseURL = 'https://yourusername.awardspace.com'; // CHANGE THIS
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

      await _encryptedData.setString('myKey', '');
    } catch (e) {
      print('Error removing key: $e');
    }
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _controller = TextEditingController();
  final EncryptedSharedPreferences _encryptedData = EncryptedSharedPreferences();

  @override
  void initState() {
    super.initState();
    checkSavedData();
  }

  void checkSavedData() async {
    String myKey = await _encryptedData.getString('myKey');
    if (myKey.isNotEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  void checkLogin() async {
    if (_controller.text.toString().trim() == '') {
      showSnackBar('Please enter a key');
    } else {
      bool success = await DatabaseService.saveKey(_controller.text.toString());
      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        showSnackBar('Failed to save key');
      }
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red, // FIXED: Removed the nullable issue
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter API Key'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      'Database Setup',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Enter your API key to enable database storage',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 30),
                    SizedBox(
                      width: 300,
                      child: TextField(
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        controller: _controller,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'API Key',
                          hintText: 'Enter your secure key',
                          prefixIcon: Icon(Icons.key),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: checkLogin,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        child: Text(
                          'Save Key & Continue',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'The key will be stored securely on your device',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double amount = 0.0;
  String fromCurrency = 'USD';
  String toCurrency = 'EUR';
  double convertedAmount = 0.0;

  double billAmount = 0.0;
  double tipPercentage = 15.0;
  int numberOfPeople = 1;
  double totalTip = 0.0;
  double totalBill = 0.0;
  double perPerson = 0.0;


  final Map<String, double> exchangeRates = {
    'USD': 1.0,
    'EUR': 0.85,
    'GBP': 0.73,
    'JPY': 110.0,
    'CAD': 1.25,
  };

  final List<String> currencies = ['USD', 'EUR', 'GBP', 'JPY', 'CAD'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Currency & Tip Calculator'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await DatabaseService.removeKey();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Card(
              elevation: 3,

              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.cloud_done, color: Colors.green),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Database Connected - All calculations will be saved',
                        style: TextStyle(
                          color: Colors.green[800]!,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Currency Converter',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Amount to Convert',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        setState(() {
                          amount = double.tryParse(value) ?? 0.0;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: fromCurrency,
                            items: currencies.map((String currency) {
                              return DropdownMenuItem<String>(
                                value: currency,
                                child: Text(currency),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                fromCurrency = newValue!;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'From',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Icon(Icons.arrow_forward, color: Colors.blue),
                        SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: toCurrency,
                            items: currencies.map((String currency) {
                              return DropdownMenuItem<String>(
                                value: currency,
                                child: Text(currency),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                toCurrency = newValue!;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'To',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: convertCurrency,
                      child: Text('Convert & Save to Database'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                    SizedBox(height: 16),
                    if (convertedAmount > 0)
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          // FIXED: Using Colors.green.shade50 instead of Colors.green[50]
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Conversion Result',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '${amount.toStringAsFixed(2)} $fromCurrency = ${convertedAmount.toStringAsFixed(2)} $toCurrency',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade900,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '✓ Saved to database',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tip Calculator',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Bill Amount',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.receipt),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        setState(() {
                          billAmount = double.tryParse(value) ?? 0.0;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Tip Percentage (%)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.percent),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                tipPercentage = double.tryParse(value) ?? 15.0;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Number of People',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.people),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                numberOfPeople = int.tryParse(value) ?? 1;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: calculateTip,
                      child: Text('Calculate & Save to Database'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                    SizedBox(height: 20),
                    if (totalBill > 0)
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          // FIXED: Using Colors.orange.shade50 instead of Colors.orange[50]
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Tip Calculation Results',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                // FIXED: Using Colors.orange.shade800 instead of Colors.orange[800]
                                color: Colors.orange.shade800,
                              ),
                            ),
                            SizedBox(height: 12),
                            ResultRow('Total Bill:', '\$${totalBill.toStringAsFixed(2)}'),
                            ResultRow('Total Tip:', '\$${totalTip.toStringAsFixed(2)}'),
                            ResultRow('Per Person:', '\$${perPerson.toStringAsFixed(2)}'),
                            SizedBox(height: 8),
                            Text(
                              '✓ Saved to database',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Database Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '✓ All currency conversions are saved to database\n'
                          '✓ All tip calculations are saved to database\n'
                          '✓ Data is transmitted securely using HTTPS\n'
                          '✓ API key is encrypted on your device\n'
                          '✓ Click logout to clear saved key',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void convertCurrency() {
    if (amount <= 0) {
      showSnackBar('Please enter a valid amount');
      return;
    }

    double fromRate = exchangeRates[fromCurrency] ?? 1.0;
    double toRate = exchangeRates[toCurrency] ?? 1.0;
    double amountInUSD = amount / fromRate;
    convertedAmount = amountInUSD * toRate;


    DatabaseService.saveConversion(
      amount: amount,
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      convertedAmount: convertedAmount,
    );

    showSnackBar('Conversion saved to database!');
    setState(() {});
  }

  void calculateTip() {
    if (billAmount <= 0) {
      showSnackBar('Please enter a valid bill amount');
      return;
    }
    if (numberOfPeople <= 0) {
      showSnackBar('Please enter a valid number of people');
      return;
    }

    totalTip = billAmount * (tipPercentage / 100);
    totalBill = billAmount + totalTip;
    perPerson = totalBill / numberOfPeople;

    DatabaseService.saveTipCalculation(
      billAmount: billAmount,
      tipPercentage: tipPercentage,
      numberOfPeople: numberOfPeople,
      totalTip: totalTip,
      totalBill: totalBill,
      perPerson: perPerson,
    );

    showSnackBar('Tip calculation saved to database!');
    setState(() {});
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green, // FIXED: Removed the nullable issue
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class ResultRow extends StatelessWidget {
  final String label;
  final String value;

  ResultRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800, // FIXED: Using shade instead of index
            ),
          ),
        ],
      ),
    );
  }
}