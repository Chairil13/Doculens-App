import 'package:flutter/material.dart';
import '../core/colors.dart';

class MenuCategories extends StatelessWidget {
  final Function(String, String) onCategoryTap;

  const MenuCategories({
    super.key,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: categories.map((category) {
            return InkWell(
              onTap: () => onCategoryTap(category.name, category.name),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      category.icon,
                      color: AppColors.primary,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

final categories = [
  Category(name: 'Kartu', icon: Icons.credit_card),
  Category(name: 'Nota', icon: Icons.receipt_long),
  Category(name: 'Surat', icon: Icons.mail),
];

class Category {
  final String name;
  final IconData icon;

  Category({required this.name, required this.icon});
}
