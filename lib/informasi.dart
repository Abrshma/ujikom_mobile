import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Import untuk format tanggal

class InformasiPage extends StatefulWidget {
  @override
  _InformasiPageState createState() => _InformasiPageState();
}

class _InformasiPageState extends State<InformasiPage> {
  List<dynamic> informasiPosts = [];

  Future<void> fetchInformasi() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/posts'));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        setState(() {
          informasiPosts = responseData['data']
              .where((post) => post['kategori']['id'] == 3 && post['status'] == 'published')
              .toList();
        });
      } else {
        print('Failed to fetch informasi. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching informasi: $e');
    }
  }

  // Format tanggal hanya dengan tanggal tanpa jam
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
    fetchInformasi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Informasi Terkini',
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
      body: informasiPosts.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: informasiPosts.length,
              itemBuilder: (context, index) {
                final informasi = informasiPosts[index];
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
                            informasi['judul'],
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            informasi['isi'],
                            style: TextStyle(fontSize: 16, color: Colors.black87),
                            maxLines: 50,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Dibuat pada: ${formatDate(informasi['created_at'])}', // Gunakan format tanggal yang sudah diubah
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
