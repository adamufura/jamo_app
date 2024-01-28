import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'J-Spy App',
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
        colorScheme:
            ColorScheme.fromSwatch().copyWith(secondary: Colors.blueAccent),
        scaffoldBackgroundColor: Colors.grey[200],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> googleAlerts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGoogleAlerts();
  }

  Future<void> fetchGoogleAlerts() async {
    try {
      Uri url =
          Uri.parse('https://webview.digikatproject.ng/jamoh/fetch_alerts.php');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        setState(() {
          googleAlerts = List<Map<String, dynamic>>.from(
            responseData.map(
              (dynamic alert) => Map<String, dynamic>.from(alert),
            ),
          );
          isLoading = false;
        });
      } else {
        print(
          'Failed to fetch Google Alerts. Status code: ${response.statusCode}',
        );
        isLoading = false;
      }
    } catch (error) {
      print('Error: $error');
      isLoading = false;
    }
  }

  String removeUnsubscribeNote(String content) {
    return content.replaceAllMapped(
      RegExp(
        r' Unsubscribe from this Google Alert: <https://www.google.com.ng/alerts/remove?source=alertsmail&hl=en&gl=NG&msgid=MTYyMzY4NjU4OTgzOTQyMzc0NjI&s=AB2Xq4gw9HGiKyXlHq3t7UDvUtB9kOdwxwo9XyY> Create another Google Alert: <https://www.google.com.ng/alerts?source=alertsmail&hl=en&gl=NG&msgid=MTYyMzY4NjU4OTgzOTQyMzc0NjI> Sign in to manage your alerts: <https://www.google.com.ng/alerts?source=alertsmail&hl=en&gl=NG&msgid=MTYyMzY4NjU4OTgzOTQyMzc0NjI>',
      ),
      (match) => '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('J-Spy App'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => SystemNavigator.pop(),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : googleAlerts.isEmpty
                ? Center(child: Text('No alerts found.'))
                : ListView.builder(
                    itemCount: googleAlerts.length,
                    itemBuilder: (context, index) {
                      final alert = googleAlerts[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 16.0),
                        elevation: 3,
                        child: ListTile(
                          title: Text(
                            "Breaking News - Dr. Bashir Jamoh | DG NIMASA",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 8),
                              Text(
                                'Date: ${alert['date']}',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  'Content: ${removeUnsubscribeNote(alert['content'])}',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                  ),
                                  textAlign: TextAlign.justify,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
