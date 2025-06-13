# LetterAI Development Guide
## Step-by-Step Commands for VS Code GitHub Copilot Agent

Based on the PRD, this guide breaks down the development of LetterAI into manageable phases with specific commands and tasks.

---

## Phase 1: Project Setup & Foundation (Week 1-2)

### Step 1.1: Flutter Project Initialization
```bash
# Create new Flutter project
flutter create letterai --org com.letterai.app
cd letterai

# Add to version control
git init
git add .
git commit -m "Initial Flutter project setup"
```

### Step 1.2: Project Structure Setup
```bash
# Create directory structure
mkdir -p lib/models
mkdir -p lib/services
mkdir -p lib/screens
mkdir -p lib/widgets
mkdir -p lib/utils
mkdir -p lib/providers
mkdir -p lib/constants
mkdir -p assets/fonts
mkdir -p assets/images
mkdir -p assets/templates
```

### Step 1.3: Dependencies Configuration
Add to `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1
  http: ^1.1.0
  shared_preferences: ^2.2.2
  pdf: ^3.10.7
  printing: ^5.11.1
  file_picker: ^6.1.1
  permission_handler: ^11.1.0
  flutter_quill: ^8.6.4
  google_fonts: ^6.1.0
  uuid: ^4.2.1
  path_provider: ^2.1.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
```

### Step 1.4: Core Model Classes
Create the following files with basic structure:

**File: `lib/models/letter_category.dart`**
```dart
class LetterCategory {
  final String id;
  final String name;
  final String icon;
  final List<LetterSubcategory> subcategories;
  
  const LetterCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.subcategories,
  });
}

class LetterSubcategory {
  final String id;
  final String name;
  final String description;
  final String categoryId;
  
  const LetterSubcategory({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
  });
}
```

**File: `lib/models/letter.dart`**
```dart
import 'package:uuid/uuid.dart';

class Letter {
  final String id;
  final String title;
  final String content;
  final String categoryId;
  final String subcategoryId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isTemplate;
  
  Letter({
    String? id,
    required this.title,
    required this.content,
    required this.categoryId,
    required this.subcategoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isTemplate = false,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();
       
  Letter copyWith({
    String? title,
    String? content,
    DateTime? updatedAt,
  }) {
    return Letter(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      categoryId: categoryId,
      subcategoryId: subcategoryId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isTemplate: isTemplate,
    );
  }
}
```

---

## Phase 2: Data Layer & Services (Week 2-3)

### Step 2.1: Letter Categories Data
**File: `lib/constants/letter_categories.dart`**
```dart
import '../models/letter_category.dart';

class LetterCategories {
  static const List<LetterCategory> categories = [
    LetterCategory(
      id: 'business',
      name: 'Business Letters',
      icon: '💼',
      subcategories: [
        LetterSubcategory(
          id: 'job_applications',
          name: 'Job Applications',
          description: 'Cover letters and job application letters',
          categoryId: 'business',
        ),
        LetterSubcategory(
          id: 'resignation',
          name: 'Resignation Letters',
          description: 'Professional resignation and notice letters',
          categoryId: 'business',
        ),
        LetterSubcategory(
          id: 'complaints',
          name: 'Complaint Letters',
          description: 'Business complaint and grievance letters',
          categoryId: 'business',
        ),
        LetterSubcategory(
          id: 'requests',
          name: 'Request Letters',
          description: 'Business request and inquiry letters',
          categoryId: 'business',
        ),
        LetterSubcategory(
          id: 'proposals',
          name: 'Business Proposals',
          description: 'Business proposal and partnership letters',
          categoryId: 'business',
        ),
      ],
    ),
    LetterCategory(
      id: 'personal',
      name: 'Personal Letters',
      icon: '💌',
      subcategories: [
        LetterSubcategory(
          id: 'thank_you',
          name: 'Thank You Letters',
          description: 'Gratitude and appreciation letters',
          categoryId: 'personal',
        ),
        LetterSubcategory(
          id: 'invitations',
          name: 'Invitations',
          description: 'Event and occasion invitation letters',
          categoryId: 'personal',
        ),
        LetterSubcategory(
          id: 'condolence',
          name: 'Condolence Letters',
          description: 'Sympathy and condolence letters',
          categoryId: 'personal',
        ),
        LetterSubcategory(
          id: 'love',
          name: 'Love Letters',
          description: 'Romantic and affectionate letters',
          categoryId: 'personal',
        ),
        LetterSubcategory(
          id: 'friendship',
          name: 'Friendship Letters',
          description: 'Letters to friends and acquaintances',
          categoryId: 'personal',
        ),
      ],
    ),
    // Continue with other categories...
  ];
}
```

### Step 2.2: Storage Service
**File: `lib/services/storage_service.dart`**
```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/letter.dart';

class StorageService {
  static const String _lettersKey = 'user_letters';
  
  Future<List<Letter>> getLetters() async {
    final prefs = await SharedPreferences.getInstance();
    final lettersJson = prefs.getStringList(_lettersKey) ?? [];
    
    return lettersJson
        .map((json) => Letter.fromJson(jsonDecode(json)))
        .toList();
  }
  
  Future<void> saveLetter(Letter letter) async {
    final letters = await getLetters();
    final existingIndex = letters.indexWhere((l) => l.id == letter.id);
    
    if (existingIndex >= 0) {
      letters[existingIndex] = letter;
    } else {
      letters.add(letter);
    }
    
    await _saveLetters(letters);
  }
  
  Future<void> deleteLetter(String id) async {
    final letters = await getLetters();
    letters.removeWhere((letter) => letter.id == id);
    await _saveLetters(letters);
  }
  
  Future<void> _saveLetters(List<Letter> letters) async {
    final prefs = await SharedPreferences.getInstance();
    final lettersJson = letters
        .map((letter) => jsonEncode(letter.toJson()))
        .toList();
    await prefs.setStringList(_lettersKey, lettersJson);
  }
}
```

### Step 2.3: AI Service
**File: `lib/services/ai_service.dart`**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  static const String _apiKey = 'YOUR_OPENAI_API_KEY'; // Move to env file
  
  Future<String> generateLetterContent({
    required String category,
    required String subcategory,
    required String prompt,
    String tone = 'professional',
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content': 'You are a professional letter writing assistant. Generate well-structured letters based on the category and requirements provided.',
          },
          {
            'role': 'user',
            'content': 'Write a $tone $subcategory letter for $category category. Requirements: $prompt',
          },
        ],
        'max_tokens': 800,
        'temperature': 0.7,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('Failed to generate content');
    }
  }
  
  Future<List<String>> enhanceText({
    required String text,
    required String context,
  }) async {
    // Implementation for text enhancement
    // Returns multiple suggestions for improvement
  }
}
```

---

## Phase 3: UI Foundation & Navigation (Week 3-4)

### Step 3.1: Theme and Constants
**File: `lib/constants/app_theme.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6366F1),
      brightness: Brightness.light,
    ),
    textTheme: GoogleFonts.interTextTheme(),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
    ),
  );
  
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6366F1),
      brightness: Brightness.dark,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
  );
}
```

### Step 3.2: Main App Structure
**File: `lib/main.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/app_theme.dart';
import 'providers/letter_provider.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const LetterAIApp());
}

class LetterAIApp extends StatelessWidget {
  const LetterAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LetterProvider()),
      ],
      child: MaterialApp(
        title: 'LetterAI',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
```

### Step 3.3: Provider Setup
**File: `lib/providers/letter_provider.dart`**
```dart
import 'package:flutter/foundation.dart';
import '../models/letter.dart';
import '../models/letter_category.dart';
import '../services/storage_service.dart';
import '../services/ai_service.dart';
import '../constants/letter_categories.dart';

class LetterProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final AIService _aiService = AIService();
  
  List<Letter> _letters = [];
  List<LetterCategory> _categories = LetterCategories.categories;
  bool _isLoading = false;
  
  List<Letter> get letters => _letters;
  List<LetterCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  
  Future<void> loadLetters() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _letters = await _storageService.getLetters();
    } catch (e) {
      debugPrint('Error loading letters: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> saveLetter(Letter letter) async {
    try {
      await _storageService.saveLetter(letter);
      await loadLetters();
    } catch (e) {
      debugPrint('Error saving letter: $e');
    }
  }
  
  Future<String> generateContent({
    required String category,
    required String subcategory,
    required String prompt,
    String tone = 'professional',
  }) async {
    return await _aiService.generateLetterContent(
      category: category,
      subcategory: subcategory,
      prompt: prompt,
      tone: tone,
    );
  }
}
```

---

## Phase 4: Core Screens Implementation (Week 4-6)

### Step 4.1: Home Screen
**File: `lib/screens/home/home_screen.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/letter_provider.dart';
import '../../widgets/category_grid.dart';
import '../../widgets/recent_letters.dart';
import '../letter_creation/category_selection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LetterProvider>().loadLetters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                floating: true,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'LetterAI',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  centerTitle: true,
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      // Navigate to settings
                    },
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuickActions(context),
                      const SizedBox(height: 24),
                      _buildCategoriesSection(context),
                      const SizedBox(height: 24),
                      _buildRecentLettersSection(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CategorySelectionScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Letter'),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                context,
                icon: Icons.auto_awesome,
                label: 'AI Assistant',
                onTap: () {
                  // Navigate to AI assistant
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionButton(
                context,
                icon: Icons.template_outlined,
                label: 'Templates',
                onTap: () {
                  // Navigate to templates
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Letter Categories',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        const CategoryGrid(),
      ],
    );
  }

  Widget _buildRecentLettersSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Letters',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to all letters
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const RecentLetters(),
      ],
    );
  }
}
```

### Step 4.2: Category Selection Screen
**File: `lib/screens/letter_creation/category_selection_screen.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/letter_provider.dart';
import '../../models/letter_category.dart';
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
    return Card(
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
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                category.icon,
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 12),
              Text(
                category.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${category.subcategories.length} types',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## Phase 5: Letter Editor Implementation (Week 6-8)

### Step 5.1: Letter Editor Screen
**File: `lib/screens/letter_creation/letter_editor_screen.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';
import '../../models/letter.dart';
import '../../models/letter_category.dart';
import '../../providers/letter_provider.dart';
import '../../widgets/ai_assistant_panel.dart';
import '../pdf/pdf_preview_screen.dart';

class LetterEditorScreen extends StatefulWidget {
  final LetterCategory category;
  final LetterSubcategory subcategory;
  final Letter? existingLetter;

  const LetterEditorScreen({
    super.key,
    required this.category,
    required this.subcategory,
    this.existingLetter,
  });

  @override
  State<LetterEditorScreen> createState() => _LetterEditorScreenState();
}

class _LetterEditorScreenState extends State<LetterEditorScreen> {
  late QuillController _controller;
  late TextEditingController _titleController;
  bool _showAIPanel = false;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic();
    _titleController = TextEditingController();
    
    if (widget.existingLetter != null) {
      _titleController.text = widget.existingLetter!.title;
      // Load existing content into Quill controller
    }
    
    _controller.addListener(_onContentChanged);
    _titleController.addListener(_onContentChanged);
  }

  void _onContentChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.subcategory.name}'),
          actions: [
            if (_hasUnsavedChanges)
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: _saveLetter,
              ),
            IconButton(
              icon: const Icon(Icons.smart_toy),
              onPressed: () {
                setState(() {
                  _showAIPanel = !_showAIPanel;
                });
              },
            ),
            PopupMenuButton<String>(
              onSelected: _handleMenuSelection,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'preview',
                  child: ListTile(
                    leading: Icon(Icons.preview),
                    title: Text('Preview PDF'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'export',
                  child: ListTile(
                    leading: Icon(Icons.download),
                    title: Text('Export PDF'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'templates',
                  child: ListTile(
                    leading: Icon(Icons.template_outlined),
                    title: Text('Insert Template'),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            // Title input
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Letter Title',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            
            // Quill toolbar
            QuillToolbar.basic(controller: _controller),
            
            // Editor area
            Expanded(
              child: Row(
                children: [
                  // Main editor
                  Expanded(
                    flex: _showAIPanel ? 2 : 1,
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      child: QuillEditor.basic(
                        controller: _controller,
                        readOnly: false,
                      ),
                    ),
                  ),
                  
                  // AI Assistant Panel
                  if (_showAIPanel)
                    Expanded(
                      flex: 1,
                      child: AIAssistantPanel(
                        category: widget.category,
                        subcategory: widget.subcategory,
                        onContentGenerated: _insertGeneratedContent,
                        currentContent: _controller.document.toPlainText(),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _saveLetter,
          child: const Icon(Icons.save),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;
    
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text('You have unsaved changes. Do you want to save before leaving?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _saveLetter();
              Navigator.of(context).pop(true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    
    return shouldPop ?? false;
  }

  Future<void> _saveLetter() async {
    final provider = context.read<LetterProvider>();
    
    final letter = Letter(
      id: widget.existingLetter?.id,
      title: _titleController.text.trim(),
      content: _controller.document.toPlainText(),
      categoryId: widget.category.id,
      subcategoryId: widget.subcategory.id,
    );
    
    await provider.saveLetter(letter);
    
    setState(() {
      _hasUnsavedChanges = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Letter saved successfully')),
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'preview':
        _previewPDF();
        break;
      case 'export':
        _exportPDF();
        break;
      case 'templates':
        _showTemplates();
        break;
    }
  }

  void _previewPDF() {
    final letter = Letter(
      title: _titleController.text.trim(),
      content: _controller.document.toPlainText(),
      categoryId: widget.category.id,
      subcategoryId: widget.subcategory.id,
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFPreviewScreen(letter: letter),
      ),
    );
  }

  void _exportPDF() {
    // Implementation for PDF export
  }

  void _showTemplates() {
    // Implementation for template selection
  }

  void _insertGeneratedContent(String content) {
    // Insert AI-generated content into the editor
    final index = _controller.selection.baseOffset;
    _controller.document.insert(index, content);
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    super.dispose();
  }
}
```

---

## Phase 6: AI Integration & Enhancement (Week 8-10)

### Step 6.1: AI Assistant Panel Widget
**File: `lib/widgets/ai_assistant_panel.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/letter_category.dart';
import '../providers/letter_provider.dart';

class AIAssistantPanel extends StatefulWidget {
  final LetterCategory category;
  final LetterSubcategory subcategory;
  final Function(String) onContentGenerated;
  final String currentContent;

  const AIAssistantPanel({
    super.key,
    required this.category,
    required this.subcategory,
    required this.onContentGenerated,
    required this.currentContent,
  });

  @override
  State<AIAssistantPanel> createState() => _AIAssistantPanelState();
}

class _AIAssistantPanelState extends State<AIAssistantPanel> {
  final TextEditingController _promptController = TextEditingController();
  String _selectedTone = 'professional';
  bool _isGenerating = false;
  List<String> _suggestions = [];

  final List<String> _tones = [
    'professional',
    'formal',
    'friendly',
    'casual',
    'persuasive',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Assistant',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Tone selection
            Text(
              'Tone',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedTone,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: _tones.map((tone) {
                return DropdownMenuItem(
                  value: tone,
                  child: Text(tone.substring(0, 1).toUpperCase() + tone.substring(1)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTone = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Prompt input
            Text(
              'What would you like help with?',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _promptController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Describe what you want to write about...',
              ),
            ),
            const SizedBox(height: 16),
            
            // Generate button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateContent,
                icon: _isGenerating 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(_isGenerating ? 'Generating...' : 'Generate'),
              ),
            ),
            const SizedBox(height: 16),
            
            // Quick suggestions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickActionChip('Complete Letter'),
                _buildQuickActionChip('Improve Grammar'),
                _buildQuickActionChip('Make More Formal'),
                _buildQuickActionChip('Add Conclusion'),
              ],
            ),
            
            // Generated suggestions
            if (_suggestions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Suggestions',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _suggestions[index],
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    widget.onContentGenerated(_suggestions[index]);
                                  },
                                  child: const Text('Use This'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionChip(String label) {
    return ActionChip(
      label: Text(label),
      onPressed: () => _quickAction(label),
      avatar: const Icon(Icons.flash_on, size: 16),
    );
  }

  Future<void> _generateContent() async {
    if (_promptController.text.trim().isEmpty) return;
    
    setState(() {
      _isGenerating = true;
    });
    
    try {
      final provider = context.read<LetterProvider>();
      final content = await provider.generateContent(
        category: widget.category.name,
        subcategory: widget.subcategory.name,
        prompt: _promptController.text.trim(),
        tone: _selectedTone,
      );
      
      setState(() {
        _suggestions = [content]; // Can be expanded to multiple suggestions
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating content: $e')),
      );
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  void _quickAction(String action) {
    String prompt = '';
    switch (action) {
      case 'Complete Letter':
        prompt = 'Complete this letter with appropriate closing';
        break;
      case 'Improve Grammar':
        prompt = 'Improve the grammar and style of this text';
        break;
      case 'Make More Formal':
        prompt = 'Make this text more formal and professional';
        break;
      case 'Add Conclusion':
        prompt = 'Add a professional conclusion to this letter';
        break;
    }
    
    _promptController.text = prompt;
    _generateContent();
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }
}
```

---

## Phase 7: PDF Generation & Export (Week 10-11)

### Step 7.1: PDF Service
**File: `lib/services/pdf_service.dart`**
```dart
import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../models/letter.dart';

class PDFService {
  static Future<Uint8List> generatePDF({
    required Letter letter,
    String fontFamily = 'handwriting',
    String template = 'modern',
  }) async {
    final pdf = pw.Document();
    
    // Load font
    final font = await _loadFont(fontFamily);
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return _buildLetterContent(letter, font, template);
        },
      ),
    );
    
    return pdf.save();
  }
  
  static pw.Widget _buildLetterContent(
    Letter letter,
    pw.Font font,
    String template,
  ) {
    switch (template) {
      case 'classic':
        return _buildClassicTemplate(letter, font);
      case 'modern':
        return _buildModernTemplate(letter, font);
      case 'elegant':
        return _buildElegantTemplate(letter, font);
      default:
        return _buildModernTemplate(letter, font);
    }
  }
  
  static pw.Widget _buildModernTemplate(Letter letter, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(40),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.only(bottom: 20),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(
                  color: PdfColors.grey300,
                  width: 1,
                ),
              ),
            ),
            child: pw.Text(
              letter.title,
              style: pw.TextStyle(
                font: font,
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          
          pw.SizedBox(height: 30),
          
          // Date
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              _formatDate(letter.createdAt),
              style: pw.TextStyle(
                font: font,
                fontSize: 12,
                color: PdfColors.grey600,
              ),
            ),
          ),
          
          pw.SizedBox(height: 30),
          
          // Content
          pw.Expanded(
            child: pw.Text(
              letter.content,
              style: pw.TextStyle(
                font: font,
                fontSize: 14,
                lineSpacing: 1.5,
              ),
            ),
          ),
          
          // Footer
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.only(top: 20),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(
                  color: PdfColors.grey300,
                  width: 1,
                ),
              ),
            ),
            child: pw.Text(
              'Created with LetterAI',
              style: pw.TextStyle(
                font: font,
                fontSize: 10,
                color: PdfColors.grey500,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
  
  static pw.Widget _buildClassicTemplate(Letter letter, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(50),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            letter.title,
            style: pw.TextStyle(
              font: font,
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 40),
          pw.Text(
            _formatDate(letter.createdAt),
            style: pw.TextStyle(font: font, fontSize: 12),
          ),
          pw.SizedBox(height: 30),
          pw.Expanded(
            child: pw.Text(
              letter.content,
              style: pw.TextStyle(
                font: font,
                fontSize: 12,
                lineSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  static pw.Widget _buildElegantTemplate(Letter letter, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(60),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: PdfColors.grey400,
          width: 2,
        ),
      ),
      child: pw.Column(
        children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(vertical: 20),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(
                  color: PdfColors.grey400,
                  width: 2,
                ),
              ),
            ),
            child: pw.Text(
              letter.title,
              style: pw.TextStyle(
                font: font,
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.SizedBox(height: 40),
          pw.Expanded(
            child: pw.Text(
              letter.content,
              style: pw.TextStyle(
                font: font,
                fontSize: 13,
                lineSpacing: 1.8,
              ),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            _formatDate(letter.createdAt),
            style: pw.TextStyle(
              font: font,
              fontSize: 11,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
  
  static Future<pw.Font> _loadFont(String fontFamily) async {
    // In a real implementation, you would load different fonts
    // For now, using default font
    return pw.Font.helvetica();
  }
  
  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  static Future<File> savePDF(Uint8List pdfBytes, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName.pdf');
    await file.writeAsBytes(pdfBytes);
    return file;
  }
  
  static Future<void> printPDF(Uint8List pdfBytes) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }
  
  static Future<void> sharePDF(Uint8List pdfBytes, String fileName) async {
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: '$fileName.pdf',
    );
  }
}
```

### Step 7.2: PDF Preview Screen
**File: `lib/screens/pdf/pdf_preview_screen.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../models/letter.dart';
import '../../services/pdf_service.dart';

class PDFPreviewScreen extends StatefulWidget {
  final Letter letter;

  const PDFPreviewScreen({
    super.key,
    required this.letter,
  });

  @override
  State<PDFPreviewScreen> createState() => _PDFPreviewScreenState();
}

class _PDFPreviewScreenState extends State<PDFPreviewScreen> {
  String _selectedTemplate = 'modern';
  String _selectedFont = 'handwriting';

  final List<String> _templates = ['modern', 'classic', 'elegant'];
  final List<String> _fonts = ['handwriting', 'professional', 'casual'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Preview'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'save',
                child: ListTile(
                  leading: Icon(Icons.save),
                  title: Text('Save PDF'),
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Share PDF'),
                ),
              ),
              const PopupMenuItem(
                value: 'print',
                child: ListTile(
                  leading: Icon(Icons.print),
                  title: Text('Print'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Customization panel
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Template',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      DropdownButton<String>(
                        value: _selectedTemplate,
                        isExpanded: true,
                        items: _templates.map((template) {
                          return DropdownMenuItem(
                            value: template,
                            child: Text(template.substring(0, 1).toUpperCase() + 
                                      template.substring(1)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedTemplate = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Font Style',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      DropdownButton<String>(
                        value: _selectedFont,
                        isExpanded: true,
                        items: _fonts.map((font) {
                          return DropdownMenuItem(
                            value: font,
                            child: Text(font.substring(0, 1).toUpperCase() + 
                                      font.substring(1)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedFont = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // PDF Preview
          Expanded(
            child: PdfPreview(
              build: (format) => PDFService.generatePDF(
                letter: widget.letter,
                fontFamily: _selectedFont,
                template: _selectedTemplate,
              ),
              allowSharing: true,
              allowPrinting: true,
              canChangePageFormat: false,
              canDebug: false,
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) async {
    final pdfBytes = await PDFService.generatePDF(
      letter: widget.letter,
      fontFamily: _selectedFont,
      template: _selectedTemplate,
    );

    switch (action) {
      case 'save':
        try {
          final file = await PDFService.savePDF(
            pdfBytes,
            widget.letter.title.replaceAll(' ', '_'),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('PDF saved to ${file.path}')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving PDF: $e')),
          );
        }
        break;
        
      case 'share':
        try {
          await PDFService.sharePDF(
            pdfBytes,
            widget.letter.title.replaceAll(' ', '_'),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error sharing PDF: $e')),
          );
        }
        break;
        
      case 'print':
        try {
          await PDFService.printPDF(pdfBytes);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error printing PDF: $e')),
          );
        }
        break;
    }
  }
}
```

---

## Phase 8: Testing & Deployment (Week 11-12)

### Step 8.1: Testing Commands
```bash
# Run tests
flutter test

# Run integration tests
flutter test integration_test/

# Analyze code
flutter analyze

# Format code
flutter format .

# Check for outdated dependencies
flutter pub outdated
```

### Step 8.2: Build Commands
```bash
# Build for Android (Debug)
flutter build apk --debug

# Build for Android (Release)
flutter build apk --release
flutter build appbundle --release

# Build for iOS (Release)
flutter build ios --release

# Install on connected device
flutter install
```

### Step 8.3: Deployment Preparation
```bash
# Generate app icons
flutter pub get
flutter pub run flutter_launcher_icons:main

# Generate splash screens
flutter pub run flutter_native_splash:create

# Clean and rebuild
flutter clean
flutter pub get
flutter build apk --release
```

---

## Additional Implementation Tasks

### Environment Configuration
Create `.env` file:
```
OPENAI_API_KEY=your_openai_api_key_here
APP_VERSION=1.0.0
```

### Error Handling & Logging
Implement proper error handling and logging throughout the app.

### Offline Capabilities
Implement offline storage and basic editing capabilities when internet is unavailable.

### Performance Optimization
- Implement lazy loading for categories and templates
- Optimize PDF generation for large documents
- Add caching for AI responses

### Security & Privacy
- Implement proper data encryption
- Add privacy policy and terms of service
- Ensure GDPR compliance

---

This comprehensive guide provides a structured approach to building the LetterAI app according to the PRD specifications. Each phase can be implemented independently, making it easier for a GitHub Copilot agent to work through the development process systematically.
