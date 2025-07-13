// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:doculens/data/datasources/document_local_datasource.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../core/colors.dart';
import '../core/spaces.dart';
import '../data/models/document_model.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/services.dart'; // Tambahkan import ini

class DetailDocumentPage extends StatefulWidget {
  final DocumentModel document;
  final VoidCallback onDocumentDeleted;
  const DetailDocumentPage({
    super.key,
    required this.document,
    required this.onDocumentDeleted,
  });

  @override
  State<DetailDocumentPage> createState() => _DetailDocumentPageState();
}

class _DetailDocumentPageState extends State<DetailDocumentPage> {
  // Tambahkan variabel untuk menyimpan teks hasil ekstraksi
  String extractedText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Dokumen',
          style: TextStyle(color: AppColors.primary),
        ),
        titleSpacing: 0, // Menghilangkan spacing default
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: false, // Memastikan judul tidak di tengah
        automaticallyImplyLeading: false, // Menghilangkan tombol back default
        actions: [
          IconButton(
            icon: const Icon(
              Icons.image_outlined,
              color: AppColors.primary,
            ),
            onPressed: () => _downloadDocument(),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined,
                color: AppColors.primary),
            onPressed: () => _saveToPdf(),
          ),
          // Tambahkan tombol untuk ekstraksi teks
          IconButton(
            icon: const Icon(Icons.text_fields, color: AppColors.primary),
            onPressed: _extractText,
          ),

          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _deleteDocument(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            widget.document.name!,
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SpaceHeight(12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.document.category!,
                style: const TextStyle(
                  fontSize: 16.0,
                  color: AppColors.primary,
                ),
              ),
              Text(
                widget.document.createdAt!,
                style: const TextStyle(
                  fontSize: 16.0,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SpaceHeight(12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ColorFiltered(
              colorFilter: const ColorFilter.matrix([
                1.2,
                0,
                0,
                0,
                0,
                0,
                1.2,
                0,
                0,
                0,
                0,
                0,
                1.2,
                0,
                0,
                0,
                0,
                0,
                1,
                0,
              ]),
              child: Image.file(
                width: double.infinity,
                File(widget.document.path!),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadDocument() async {
    try {
      final result = await ImageGallerySaver.saveFile(widget.document.path!);
      if (result['isSuccess']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Dokumen berhasil tersimpan di Galeri'),
              backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan dokumen'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _saveToPdf() async {
    final pdf = pw.Document();

    final image = pw.MemoryImage(File(widget.document.path!).readAsBytesSync());

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(image),
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/${widget.document.name}.pdf');
    await file.writeAsBytes(await pdf.save());

    await OpenFile.open(file.path);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Silahkan Simpan PDF nya menggunakan aplikasi pihak ketiga PDF reader atau yang lain'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _deleteDocument() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menghapus dokumen ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await DocumentLocalDatasource.instance
            .deleteDocument(widget.document.id!);
        widget
            .onDocumentDeleted(); // Memanggil callback setelah dokumen dihapus
        Navigator.of(context).pop(); // Kembali ke halaman sebelumnya
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dokumen berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus dokumen: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Tambahkan metode untuk mengekstrak teks
  Future<void> _extractText() async {
    final inputImage = InputImage.fromFilePath(widget.document.path!);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      if (kDebugMode) {
        print('Memulai proses ekstraksi teks dari: ${widget.document.path}');
      }

      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      if (kDebugMode) {
        print('Teks yang diekstrak: ${recognizedText.text}');
      }

      setState(() {
        extractedText = recognizedText.text;
      });

      if (extractedText.isEmpty) {
        throw Exception('Tidak ada teks yang diekstrak');
      }

      // Tampilkan dialog dengan teks yang diekstrak
      _showExtractedTextDialog();
    } catch (e) {
      if (kDebugMode) {
        print('Error saat mengekstrak teks: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengekstrak teks dari gambar: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      textRecognizer.close();
    }
  }

  // Ubah metode _showExtractedTextDialog
  void _showExtractedTextDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Teks yang Diekstrak'),
          content: SingleChildScrollView(
            child: Text(extractedText),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Salin Teks'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: extractedText));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Teks berhasil disalin'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
            TextButton(
              child: const Text('Tutup'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
