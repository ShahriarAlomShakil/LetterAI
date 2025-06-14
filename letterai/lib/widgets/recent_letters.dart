import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/letter_provider.dart';
import '../models/letter.dart';
import '../constants/letter_categories.dart';
import '../constants/app_theme.dart';

class RecentLetters extends StatelessWidget {
  const RecentLetters({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LetterProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.letters.isEmpty) {
          return _buildEmptyState(context);
        }

        // Show most recent 3 letters
        final recentLetters = provider.letters.take(3).toList();

        return Column(
          children: recentLetters.map((letter) {
            return _buildLetterCard(context, letter);
          }).toList(),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: AppTheme.getGlassmorphismGradient(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.getGlassBorderColor(isDark),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.description_rounded,
              size: 48,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No letters yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first letter to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLetterCard(BuildContext context, Letter letter) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Get category info for display
    final category = LetterCategories.getCategoryById(letter.categoryId);
    final subcategory = category != null 
        ? LetterCategories.getSubcategoryById(letter.categoryId, letter.subcategoryId)
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: AppTheme.getGlassmorphismGradient(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.getGlassBorderColor(isDark),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to letter detail/editor - will be implemented in later phases
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Opening "${letter.title}" coming soon!'),
                backgroundColor: Colors.white.withOpacity(0.9),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: isDark ? const LinearGradient(
                      colors: [Color(0xFF818CF8), Color(0xFFA78BFA)],
                    ) : const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? const Color(0xFF818CF8) : const Color(0xFF667EEA)).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      category?.icon ?? '📄',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        letter.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(isDark ? 0.15 : 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          subcategory?.name ?? 'Unknown Type',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatDate(letter.updatedAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(isDark ? 0.05 : 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
