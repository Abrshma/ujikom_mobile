import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class GaleryScreen extends StatefulWidget {
  @override
  _GaleryScreenState createState() => _GaleryScreenState();
}

class _GaleryScreenState extends State<GaleryScreen> {
  List<dynamic> galeryItems = [];
  bool isLoading = false;
  String? errorMessage;

  // Fungsi untuk mengambil data galeri dari API
  Future<void> fetchGaleryItems() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http
          .get(Uri.parse('http://10.0.2.2:8000/api/foto'))
          .timeout(Duration(seconds: 60)); // Menambahkan timeout

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          galeryItems = responseData['data'] ?? []; // Menyimpan data galeri
        });
      } else {
        setState(() {
          errorMessage = 'Gagal memuat galeri. Status code: ${response.statusCode}';
        });
      }
    } on TimeoutException {
      setState(() {
        errorMessage = 'Permintaan waktu habis. Coba lagi.';
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchGaleryItems();
  }

  // Fungsi untuk memformat tanggal menjadi "dd MMMM"
  String formatDate(String? dateStr) {
    if (dateStr == null) return 'Tanggal tidak tersedia';
    try {
      final dateTime = DateTime.parse(dateStr);
      final formattedDate = DateFormat('dd MMMM').format(dateTime);
      return formattedDate; // Contoh output: "20 November"
    } catch (e) {
      return 'Format tanggal tidak valid';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Galery Sekolah',
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: fetchGaleryItems,
                        child: Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : galeryItems.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada item galeri.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Jumlah kolom per baris
                        mainAxisSpacing: 8.0,
                        crossAxisSpacing: 8.0,
                        childAspectRatio: 3 / 4, // Rasio tinggi ke lebar
                      ),
                      itemCount: galeryItems.length,
                      itemBuilder: (context, index) {
                        final galeryItem = galeryItems[index];
                        return Card(
                          elevation: 5,
                          shadowColor: Colors.grey.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  galeryItem['judul'] ?? 'Judul Tidak Tersedia',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 8),
                                Expanded(
                                  child: CachedNetworkImage(
                                    imageUrl: galeryItem['file'] ?? '',
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        Center(child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.broken_image,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  formatDate(galeryItem['created_at']),
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
