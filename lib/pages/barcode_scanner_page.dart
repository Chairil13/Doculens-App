// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_picker/image_picker.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  _BarcodeScannerPageState createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  String _scanBarcode = 'Belum dipindai';
  final ImagePicker _picker = ImagePicker();

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Batal', true, ScanMode.BARCODE);

      if (barcodeScanRes == '-1') {
        barcodeScanRes = 'Pemindaian dibatalkan';
      }
    } catch (e) {
      barcodeScanRes = 'Gagal memindai barcode: $e';
    }

    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  Future<void> scanBarcodeFromImage() async {
    try {
      print('Mencoba memilih gambar...');
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) {
        setState(() {
          _scanBarcode = 'Tidak ada gambar yang dipilih';
        });
        return;
      }

      print('Gambar dipilih: ${image.path}');
      final inputImage = InputImage.fromFilePath(image.path);
      final barcodeScanner = BarcodeScanner();

      print('Memproses gambar...');
      final List<Barcode> barcodes =
          await barcodeScanner.processImage(inputImage);

      if (barcodes.isNotEmpty) {
        setState(() {
          _scanBarcode =
              barcodes.first.rawValue ?? 'Tidak dapat membaca barcode';
        });
        print('Barcode ditemukan: $_scanBarcode');
      } else {
        setState(() {
          _scanBarcode = 'Tidak ditemukan barcode dalam gambar';
        });
        print('Tidak ada barcode yang ditemukan');
      }

      barcodeScanner.close();
    } catch (e) {
      print('Error: $e');
      setState(() {
        _scanBarcode = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton.icon(
                  onPressed: () => scanBarcodeNormal(),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Scan dari Kamera'),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => scanBarcodeFromImage(),
                  icon: const Icon(Icons.image),
                  label: const Text('Scan dari Gambar'),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.8,
                  ),
                  child: SingleChildScrollView(
                    child: SelectionArea(
                      child: Text(
                        'Hasil Pemindaian:\n$_scanBarcode',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            left: 16,
            bottom: 16,
            child: Text(
              'Tip: Tekan lama teks lalu pilih copy',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
