import 'package:flutter/material.dart';
void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency & Tip Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  // Currency Converter Variables
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
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      ),
                      keyboardType: TextInputType.number,
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
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: convertCurrency,
                      child: Text('Convert Currency'),
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
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Converted Amount: ${convertedAmount.toStringAsFixed(2)} $toCurrency',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
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
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          billAmount = double.tryParse(value) ?? 0.0;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Tip Percentage (%)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          tipPercentage = double.tryParse(value) ?? 15.0;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Number of People',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          numberOfPeople = int.tryParse(value) ?? 1;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: calculateTip,
                      child: Text('Calculate Tip'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                    SizedBox(height: 16),
                    if (totalBill > 0)
                      Column(
                        children: [
                          ResultRow('Total Bill:', '\$${totalBill.toStringAsFixed(2)}'),
                          ResultRow('Total Tip:', '\$${totalTip.toStringAsFixed(2)}'),
                          ResultRow('Per Person:', '\$${perPerson.toStringAsFixed(2)}'),
                        ],
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
    setState(() {});
  }
  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
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
              color: Colors.green[800],
            ),
          ),
        ],
      ),
    );
  }
}