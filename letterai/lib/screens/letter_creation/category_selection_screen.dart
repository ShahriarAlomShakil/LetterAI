import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/letter_provider.dart';
import '../../models/letter_category.dart';
import '../../constants/app_theme.dart';
import 'subcategory_selection_screen.dart';

class CategorySelectionScreen extends StatelessWidget {
  const CategorySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Category'),
      ),
      body: Consumer<LetterProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: provider.categories.length,
              itemBuilder: (context, index) {
                final category = provider.categories[index];
                return _buildCategoryCard(context, category);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, LetterCategory category) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.getGlassmorphismGradient(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.getGlassBorderColor(isDark),
          width: 1.5,
        ),
        boxShadow: [
          AppTheme.getGlassShadow(isDark),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubcategorySelectionScreen(
                  category: category,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark 
                        ? [
                            Colors.white.withOpacity(0.15),
                            Colors.white.withOpacity(0.08),
                          ]
                        : [
                            Colors.white.withOpacity(0.4),
                            Colors.white.withOpacity(0.2),
                          ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark 
                        ? Colors.white.withOpacity(0.2)
                        : Colors.white.withOpacity(0.5),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark 
                          ? Colors.black.withOpacity(0.3)
                          : Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      category.icon,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  category.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getGlassTextColor(isDark),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark 
                        ? [
                            Colors.white.withOpacity(0.12),
                            Colors.white.withOpacity(0.06),
                          ]
                        : [
                            Colors.white.withOpacity(0.3),
                            Colors.white.withOpacity(0.15),
                          ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark 
                        ? Colors.white.withOpacity(0.15)
                        : Colors.white.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${category.subcategories.length} types',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.getGlassSecondaryTextColor(isDark),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
