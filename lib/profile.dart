import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Tambahkan impor ini

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<dynamic> profileData = [];

  Future<void> fetchProfile() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/profile'));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        setState(() {
          profileData = responseData['data']; // Menyimpan data profil
        });
      } else {
        print('Failed to fetch profile. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching profile: $e');
    }
  }

  // Fungsi untuk memformat tanggal
  String formatDate(String dateTime) {
    try {
      final DateTime parsedDate = DateTime.parse(dateTime);
      return DateFormat('d MMMM yyyy').format(parsedDate); // Contoh: 19 November 2024
    } catch (e) {
      return 'Format tanggal tidak valid'; // Jika parsing gagal
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil Sekolah',
          style: TextStyle(
            color: Colors.blueAccent, // Mengubah warna teks menjadi warna latar belakang
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Menghapus latar belakang AppBar (transparent)
        elevation: 0, // Menghilangkan bayangan pada AppBar
        shadowColor: Colors.transparent, // Menghilangkan bayangan jika ada
      ),
      body: profileData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: profileData.length,
              itemBuilder: (context, index) {
                final profile = profileData[index];
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
                            profile['judul'],
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            profile['isi'],
                            style: TextStyle(fontSize: 16, color: Colors.black87),
                            maxLines: 50,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Dibuat pada: ${formatDate(profile['created_at'])}',
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
