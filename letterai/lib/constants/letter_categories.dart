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
    LetterCategory(
      id: 'formal',
      name: 'Formal Letters',
      icon: '📋',
      subcategories: [
        LetterSubcategory(
          id: 'government',
          name: 'Government Letters',
          description: 'Official government correspondence',
          categoryId: 'formal',
        ),
        LetterSubcategory(
          id: 'legal',
          name: 'Legal Letters',
          description: 'Legal notices and documentation',
          categoryId: 'formal',
        ),
        LetterSubcategory(
          id: 'insurance',
          name: 'Insurance Letters',
          description: 'Insurance claims and correspondence',
          categoryId: 'formal',
        ),
        LetterSubcategory(
          id: 'bank',
          name: 'Banking Letters',
          description: 'Bank-related correspondence',
          categoryId: 'formal',
        ),
        LetterSubcategory(
          id: 'medical',
          name: 'Medical Letters',
          description: 'Healthcare and medical correspondence',
          categoryId: 'formal',
        ),
      ],
    ),
    LetterCategory(
      id: 'academic',
      name: 'Academic Letters',
      icon: '🎓',
      subcategories: [
        LetterSubcategory(
          id: 'admission',
          name: 'Admission Letters',
          description: 'College and university admission applications',
          categoryId: 'academic',
        ),
        LetterSubcategory(
          id: 'recommendation',
          name: 'Recommendation Letters',
          description: 'Academic and professional recommendations',
          categoryId: 'academic',
        ),
        LetterSubcategory(
          id: 'scholarship',
          name: 'Scholarship Applications',
          description: 'Scholarship and grant applications',
          categoryId: 'academic',
        ),
        LetterSubcategory(
          id: 'leave',
          name: 'Leave Applications',
          description: 'Academic leave and absence requests',
          categoryId: 'academic',
        ),
        LetterSubcategory(
          id: 'inquiry',
          name: 'Academic Inquiries',
          description: 'Course and program inquiries',
          categoryId: 'academic',
        ),
      ],
    ),
    LetterCategory(
      id: 'customer_service',
      name: 'Customer Service',
      icon: '🛠️',
      subcategories: [
        LetterSubcategory(
          id: 'support_request',
          name: 'Support Requests',
          description: 'Customer support and service requests',
          categoryId: 'customer_service',
        ),
        LetterSubcategory(
          id: 'product_inquiry',
          name: 'Product Inquiries',
          description: 'Product information and specification requests',
          categoryId: 'customer_service',
        ),
        LetterSubcategory(
          id: 'feedback',
          name: 'Feedback Letters',
          description: 'Customer feedback and suggestions',
          categoryId: 'customer_service',
        ),
        LetterSubcategory(
          id: 'refund_request',
          name: 'Refund Requests',
          description: 'Product return and refund requests',
          categoryId: 'customer_service',
        ),
        LetterSubcategory(
          id: 'warranty_claim',
          name: 'Warranty Claims',
          description: 'Product warranty and repair claims',
          categoryId: 'customer_service',
        ),
      ],
    ),
    LetterCategory(
      id: 'real_estate',
      name: 'Real Estate',
      icon: '🏠',
      subcategories: [
        LetterSubcategory(
          id: 'rental_inquiry',
          name: 'Rental Inquiries',
          description: 'Property rental and lease inquiries',
          categoryId: 'real_estate',
        ),
        LetterSubcategory(
          id: 'lease_termination',
          name: 'Lease Termination',
          description: 'Rental lease termination notices',
          categoryId: 'real_estate',
        ),
        LetterSubcategory(
          id: 'maintenance_request',
          name: 'Maintenance Requests',
          description: 'Property maintenance and repair requests',
          categoryId: 'real_estate',
        ),
        LetterSubcategory(
          id: 'property_inquiry',
          name: 'Property Inquiries',
          description: 'Property purchase and sale inquiries',
          categoryId: 'real_estate',
        ),
        LetterSubcategory(
          id: 'neighbor_dispute',
          name: 'Neighbor Disputes',
          description: 'Neighbor-related issues and communications',
          categoryId: 'real_estate',
        ),
      ],
    ),
  ];

  static LetterCategory? getCategoryById(String id) {
    try {
      return categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  static LetterSubcategory? getSubcategoryById(String categoryId, String subcategoryId) {
    final category = getCategoryById(categoryId);
    if (category == null) return null;
    
    try {
      return category.subcategories.firstWhere((sub) => sub.id == subcategoryId);
    } catch (e) {
      return null;
    }
  }

  static List<LetterSubcategory> getAllSubcategories() {
    return categories
        .expand((category) => category.subcategories)
        .toList();
  }
}
