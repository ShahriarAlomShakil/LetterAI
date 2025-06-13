class AppConstants {
  // App Information
  static const String appName = 'LetterAI';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'AI-Powered Letter Writing Assistant';
  
  // API Constants
  static const String openAIModel = 'gpt-3.5-turbo';
  static const int maxTokens = 800;
  static const double temperature = 0.7;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Font Sizes
  static const Map<String, double> fontSizes = {
    'small': 12.0,
    'medium': 14.0,
    'large': 16.0,
    'extra_large': 18.0,
  };
  
  // Tone Options
  static const List<String> toneOptions = [
    'professional',
    'friendly',
    'formal',
    'casual',
    'persuasive',
    'apologetic',
    'urgent',
    'grateful',
  ];
  
  // Theme Options
  static const List<String> themeOptions = [
    'light',
    'dark',
    'system',
  ];
  
  // Language Options
  static const Map<String, String> languageOptions = {
    'en': 'English',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German',
    'it': 'Italian',
    'pt': 'Portuguese',
    'ru': 'Russian',
    'zh': 'Chinese',
    'ja': 'Japanese',
    'ko': 'Korean',
  };
  
  // Storage Keys
  static const String userLettersKey = 'user_letters';
  static const String userTemplatesKey = 'user_templates';
  static const String appSettingsKey = 'app_settings';
  
  // Default Values
  static const String defaultTheme = 'system';
  static const String defaultFontSize = 'medium';
  static const String defaultTone = 'professional';
  static const String defaultLanguage = 'en';
  static const bool defaultAutoSave = true;
  static const bool defaultNotifications = true;
  
  // Validation Rules
  static const int minTitleLength = 1;
  static const int maxTitleLength = 100;
  static const int minContentLength = 10;
  static const int maxContentLength = 10000;
  
  // File Export
  static const String exportFilePrefix = 'letterai_export';
  static const String exportFileExtension = '.json';
  static const String pdfFileExtension = '.pdf';
  
  // Error Messages
  static const String genericError = 'An unexpected error occurred. Please try again.';
  static const String networkError = 'Please check your internet connection and try again.';
  static const String apiKeyError = 'Please configure your API key in settings.';
  static const String storageError = 'Failed to save data. Please try again.';
  static const String validationError = 'Please check your input and try again.';
  
  // Success Messages
  static const String saveSuccess = 'Letter saved successfully!';
  static const String deleteSuccess = 'Letter deleted successfully!';
  static const String exportSuccess = 'Letters exported successfully!';
  static const String importSuccess = 'Letters imported successfully!';
  
  // Placeholder Text
  static const String titlePlaceholder = 'Enter letter title...';
  static const String contentPlaceholder = 'Start writing your letter here...';
  static const String promptPlaceholder = 'Describe what you want to write about...';
  
  // Feature Flags
  static const bool enableAIFeatures = true;
  static const bool enableTemplates = true;
  static const bool enableExport = true;
  static const bool enablePDFGeneration = true;
  static const bool enableVoiceInput = false; // Future feature
  static const bool enableCollaboration = false; // Future feature
}

class AppStrings {
  // Navigation
  static const String home = 'Home';
  static const String categories = 'Categories';
  static const String letters = 'My Letters';
  static const String templates = 'Templates';
  static const String settings = 'Settings';
  
  // Actions
  static const String create = 'Create';
  static const String edit = 'Edit';
  static const String delete = 'Delete';
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String share = 'Share';
  static const String export = 'Export';
  static const String import = 'Import';
  static const String generate = 'Generate';
  static const String enhance = 'Enhance';
  
  // Categories
  static const String businessLetters = 'Business Letters';
  static const String personalLetters = 'Personal Letters';
  static const String formalLetters = 'Formal Letters';
  static const String academicLetters = 'Academic Letters';
  static const String customerService = 'Customer Service';
  static const String realEstate = 'Real Estate';
  
  // Features
  static const String aiAssistant = 'AI Assistant';
  static const String letterEditor = 'Letter Editor';
  static const String templateLibrary = 'Template Library';
  static const String letterHistory = 'Letter History';
  
  // Settings
  static const String appearance = 'Appearance';
  static const String notifications = 'Notifications';
  static const String dataBackup = 'Data & Backup';
  static const String about = 'About';
  static const String helpSupport = 'Help & Support';
  
  // Onboarding
  static const String welcome = 'Welcome to LetterAI';
  static const String getStarted = 'Get Started';
  static const String skipTutorial = 'Skip Tutorial';
  static const String next = 'Next';
  static const String previous = 'Previous';
  static const String finish = 'Finish';
}

class AppUrls {
  static const String privacyPolicy = 'https://letterai.com/privacy';
  static const String termsOfService = 'https://letterai.com/terms';
  static const String helpCenter = 'https://letterai.com/help';
  static const String contactSupport = 'https://letterai.com/support';
  static const String appStore = 'https://apps.apple.com/app/letterai';
  static const String playStore = 'https://play.google.com/store/apps/details?id=com.letterai.app';
  static const String website = 'https://letterai.com';
}

/// Utility class for app-wide helper functions
class AppUtils {
  /// Format date for display
  static String formatDate(DateTime date) {
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
  
  /// Get readable file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  /// Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  /// Generate random ID
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
  
  /// Get word count
  static int getWordCount(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }
  
  /// Get character count
  static int getCharacterCount(String text) {
    return text.length;
  }
  
  /// Truncate text with ellipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
  
  /// Get initials from name
  static String getInitials(String name) {
    final words = name.trim().split(' ');
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
  
  /// Check if string is empty or null
  static bool isNullOrEmpty(String? text) {
    return text == null || text.trim().isEmpty;
  }
  
  /// Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
