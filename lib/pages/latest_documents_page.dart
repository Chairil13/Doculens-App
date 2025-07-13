import 'dart:io';

import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/spaces.dart';
import '../data/models/document_model.dart';
import 'detail_document_page.dart';

class LatestDocumentsPage extends StatefulWidget {
  final List<DocumentModel> documents;
  final VoidCallback onDocumentDeleted;
  const LatestDocumentsPage({
    super.key,
    required this.documents,
    required this.onDocumentDeleted,
  });

  @override
  State<LatestDocumentsPage> createState() => _LatestDocumentsPageState();
}

class _LatestDocumentsPageState extends State<LatestDocumentsPage> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: widget.documents.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 3 / 2,
        ),
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey[200],
            ),
            child: InkWell(
              onTap: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DetailDocumentPage(
                              document: widget.documents[index],
                              onDocumentDeleted: widget.onDocumentDeleted,
                            )));
              },
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
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
                          File(widget.documents[index].path!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SpaceHeight(4),
                  Text(
                    widget.documents[index].name!,
                    style: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
