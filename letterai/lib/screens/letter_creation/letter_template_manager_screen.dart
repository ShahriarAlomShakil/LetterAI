import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/letter_provider.dart';
import '../../models/letter.dart';
import '../../models/letter_category.dart';
import 'letter_editor_screen.dart';

class LetterTemplateManagerScreen extends StatefulWidget {
  final LetterCategory category;
  final LetterSubcategory subcategory;

  const LetterTemplateManagerScreen({
    super.key,
    required this.category,
    required this.subcategory,
  });

  @override
  State<LetterTemplateManagerScreen> createState() => _LetterTemplateManagerScreenState();
}

class _LetterTemplateManagerScreenState extends State<LetterTemplateManagerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LetterProvider>().loadTemplates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subcategory.name} Templates'),
        actions: [
          IconButton(
            onPressed: _createNewTemplate,
            icon: const Icon(Icons.add),
            tooltip: 'Create New Template',
          ),
        ],
      ),
      body: Consumer<LetterProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final templates = provider.templates
              .where((template) => 
                  template.categoryId == widget.category.id &&
                  template.subcategoryId == widget.subcategory.id)
              .toList();

          if (templates.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              return _buildTemplateCard(template);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No templates yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first template to get started',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createNewTemplate,
            icon: const Icon(Icons.add),
            label: const Text('Create Template'),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(Letter template) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _useTemplate(template),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      template.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleTemplateAction(template, value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy),
                            SizedBox(width: 8),
                            Text('Duplicate'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                template.content.length > 100
                    ? '${template.content.substring(0, 100)}...'
                    : template.content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Updated ${_formatDate(template.updatedAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _useTemplate(template),
                    child: const Text('Use Template'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createNewTemplate() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LetterEditorScreen(
          category: widget.category,
          subcategory: widget.subcategory,
        ),
      ),
    );
  }

  void _useTemplate(Letter template) {
    // Create a new letter based on the template
    final newLetter = Letter(
      title: template.title,
      content: template.content,
      categoryId: template.categoryId,
      subcategoryId: template.subcategoryId,
      isTemplate: false,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LetterEditorScreen(
          category: widget.category,
          subcategory: widget.subcategory,
          existingLetter: newLetter,
        ),
      ),
    );
  }

  void _handleTemplateAction(Letter template, String action) {
    switch (action) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LetterEditorScreen(
              category: widget.category,
              subcategory: widget.subcategory,
              existingLetter: template,
            ),
          ),
        );
        break;
      case 'duplicate':
        _duplicateTemplate(template);
        break;
      case 'delete':
        _deleteTemplate(template);
        break;
    }
  }

  void _duplicateTemplate(Letter template) {
    final duplicatedTemplate = Letter(
      title: '${template.title} (Copy)',
      content: template.content,
      categoryId: template.categoryId,
      subcategoryId: template.subcategoryId,
      isTemplate: true,
    );

    context.read<LetterProvider>().saveLetter(duplicatedTemplate);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Template duplicated successfully')),
    );
  }

  void _deleteTemplate(Letter template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text('Are you sure you want to delete "${template.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<LetterProvider>().deleteLetter(template.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Template deleted successfully')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
