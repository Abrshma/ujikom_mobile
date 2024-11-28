import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PostsPage extends StatefulWidget {
  @override
  _PostsPageState createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  // List untuk menyimpan data agenda dan informasi
  List<dynamic> agendaPosts = [];
  List<dynamic> informasiPosts = [];

  // Fungsi untuk mengambil data dari API
  Future<void> fetchPosts() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/posts'));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        setState(() {
          final data = responseData['data'];
          agendaPosts = data.where((post) => post['kategori']['id'] == 6).toList();
          informasiPosts = data.where((post) => post['kategori']['id'] == 3).toList();
        });
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching posts: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // Memanggil fetchPosts ketika halaman dimuat
    fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agenda & Informasi'),
      ),
      body: agendaPosts.isEmpty && informasiPosts.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Agenda Sekolah
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Agenda Sekolah',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  agendaPosts.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('Tidak ada agenda yang tersedia.'),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: agendaPosts.length,
                          itemBuilder: (context, index) {
                            final agenda = agendaPosts[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              child: ListTile(
                                title: Text(agenda['judul']),
                                subtitle: Text(agenda['isi']),
                              ),
                            );
                          },
                        ),

                  // Informasi Terkini
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Informasi Terkini',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  informasiPosts.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('Tidak ada informasi yang tersedia.'),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: informasiPosts.length,
                          itemBuilder: (context, index) {
                            final informasi = informasiPosts[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              child: ListTile(
                                title: Text(informasi['judul']),
                                subtitle: Text(informasi['isi']),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
}
