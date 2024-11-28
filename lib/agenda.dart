import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Import untuk format tanggal

class AgendaPage extends StatefulWidget {
  @override
  _AgendaPageState createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  List<dynamic> agendaPosts = [];

  Future<void> fetchAgenda() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/posts'));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        setState(() {
          // Filter posts by category ID (Agenda: 6) and status (published)
          agendaPosts = responseData['data']
              .where((post) => post['kategori']['id'] == 6 && post['status'] == 'published')
              .toList();
        });
      } else {
        print('Failed to fetch agenda. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching agenda: $e');
    }
  }

  String formatDate(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('dd MMMM yyyy').format(dateTime); // Hanya tanggal tanpa jam
    } catch (e) {
      return 'Tanggal tidak valid';
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAgenda();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Agenda Sekolah',
          style: TextStyle(
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      body: agendaPosts.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: agendaPosts.length,
              itemBuilder: (context, index) {
                final agenda = agendaPosts[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 5,
                    shadowColor: Colors.grey.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            agenda['judul'],
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            agenda['isi'],
                            style: TextStyle(fontSize: 16, color: Colors.black87),
                            maxLines: 50,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Dibuat pada: ${formatDate(agenda['created_at'])}',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
