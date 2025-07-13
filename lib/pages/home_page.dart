// ignore_for_file: use_build_context_synchronously

import 'package:doculens/pages/document_category_page.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';

import 'barcode_scanner_page.dart';

import '../core/colors.dart';
import '../core/spaces.dart';
import '../core/title_content.dart';
import '../data/datasources/document_local_datasource.dart';
import '../data/models/document_model.dart';
import 'latest_documents_page.dart';
import 'menu_categories.dart';
import 'save_document_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<DocumentModel> documents = [];

  String? pathImage;

  loadData() async {
    documents = await DocumentLocalDatasource.instance.getAllDocuments();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> navigateToCategoryPage(
      String category, String categoryTitle) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentCategoryPage(
          category: category,
          categoryTitle: categoryTitle,
          onDocumentDeleted: loadData, // Melewatkan fungsi loadData
        ),
      ),
    );
    loadData(); // Memuat ulang data setelah kembali dari halaman kategori
  }

  Future<void> _showScanningTipsDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tips Memindai'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: [
                Text('1. Pastikan dokumen berada di permukaan yang datar.'),
                Text('2. Hindari bayangan dan cahaya yang terlalu terang.'),
                Text('3. Pastikan seluruh dokumen terlihat dalam bingkai.'),
                Text('4. Jaga kamera tetap stabil saat memindai.'),
                Text('5. Gunakan latar belakang kontras jika memungkinkan.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Mengerti'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _scanAndCleanDocument() async {
    await _showScanningTipsDialog();

    DocumentScannerOptions documentOptions = DocumentScannerOptions(
      documentFormat: DocumentFormat.jpeg,
      mode: ScannerMode
          .full, // Menggunakan mode penuh untuk mendapatkan hasil terbaik
      pageLimit: 1,
      isGalleryImport: true,
    );

    final documentScanner = DocumentScanner(options: documentOptions);
    DocumentScanningResult result = await documentScanner.scanDocument();

    if (result.images.isNotEmpty) {
      pathImage = result.images[0];

      // Menambahkan langkah pembersihan
      final cleanedImage = await _cleanImage(pathImage!);

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SaveDocumentPage(
            pathImage: cleanedImage,
          ),
        ),
      );
      loadData();
    } else {
      // Menampilkan pesan jika tidak ada gambar yang dipindai
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada dokumen yang dipindai')),
      );
    }
  }

  Future<String> _cleanImage(String imagePath) async {
    // Di sini Anda dapat menambahkan logika pembersihan gambar
    // Misalnya, menggunakan library image processing seperti image atau photofilters
    // Untuk contoh ini, kita hanya akan mengembalikan path gambar asli
    return imagePath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DocuLens App'),
        centerTitle: true,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16.0, 16, 16, 0),
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Silahkan pilih fitur dibawah ini',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SpaceHeight(8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _scanAndCleanDocument,
                        child: const Text('Scan Dokumen'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const BarcodeScannerPage(),
                            ),
                          );
                        },
                        child: const Text('Scan Barcode'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SpaceHeight(20.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TitleContent(
                title: 'Kategori',
                onSeeAllTap: () {},
              ),
            ),
            const SpaceHeight(12.0),
            MenuCategories(
              onCategoryTap: navigateToCategoryPage,
            ),
            const SpaceHeight(20.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TitleContent(
                title: 'Dokumen Terbaru',
                onSeeAllTap: () {},
              ),
            ),
            const SpaceHeight(12.0),
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: LatestDocumentsPage(
                documents: documents,
                onDocumentDeleted: () {
                  loadData();
                },
              ),
            ),
            const SpaceHeight(20.0),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Made by Chairil Ali',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
