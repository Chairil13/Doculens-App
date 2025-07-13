import 'package:flutter/material.dart';
import '../data/datasources/document_local_datasource.dart';
import '../data/models/document_model.dart';
import 'latest_documents_page.dart';

class DocumentCategoryPage extends StatefulWidget {
  final String category;
  final String categoryTitle;
  final Function onDocumentDeleted;
  const DocumentCategoryPage({
    super.key,
    required this.category,
    required this.categoryTitle,
    required this.onDocumentDeleted,
  });

  @override
  State<DocumentCategoryPage> createState() => _DocumentCategoryPageState();
}

class _DocumentCategoryPageState extends State<DocumentCategoryPage> {
  List<DocumentModel> documents = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    documents = await DocumentLocalDatasource.instance
        .getDocumentByCategory(widget.category);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryTitle),
      ),
      body: LatestDocumentsPage(
        documents: documents,
        onDocumentDeleted: () {
          loadData(); // Memuat ulang data setelah dokumen dihapus
          widget
              .onDocumentDeleted(); // Memanggil callback untuk memperbarui halaman utama
        },
      ),
    );
  }
}
