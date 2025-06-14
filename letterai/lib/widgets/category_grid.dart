import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/letter_provider.dart';
import '../models/letter_category.dart';
import '../constants/app_theme.dart';
import '../screens/letter_creation/subcategory_selection_screen.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LetterProvider>(
      builder: (context, provider, child) {
        // Show first 4 categories on home screen for better layout
        final displayCategories = provider.categories.take(4).toList();
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.7, // Further reduced to 0.7 to ensure no overflow
          ),
          itemCount: displayCategories.length,
          itemBuilder: (context, index) {
            final category = displayCategories[index];
            return _buildCategoryCard(context, category);
          },
        );
      },
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
            padding: const EdgeInsets.all(14.0), // Further reduced padding from 16 to 14
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Modern icon container with glassmorphism styling
                Container(
                  width: 52, // Further reduced from 56 to 52
                  height: 52, // Further reduced from 56 to 52
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
                    borderRadius: BorderRadius.circular(14), // Reduced from 16 to 14
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
                        blurRadius: 8, // Reduced blur
                        offset: const Offset(0, 3), // Reduced offset
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      category.icon,
                      style: const TextStyle(
                        fontSize: 22, // Further reduced from 24 to 22
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 10), // Further reduced from 12 to 10
                
                // Category name with theme-aware typography
                Flexible(
                  child: Text(
                    category.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.getGlassTextColor(isDark),
                      fontSize: 13, // Further reduced from 14 to 13
                      height: 1.1, // Reduced line height
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                const SizedBox(height: 6), // Further reduced from 8 to 6
                
                // Glassmorphism badge design
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), // Reduced padding
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
                    borderRadius: BorderRadius.circular(8), // Reduced from 10 to 8
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
                      fontSize: 10, // Further reduced from 11 to 10
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
