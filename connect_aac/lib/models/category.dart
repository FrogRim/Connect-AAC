// lib/models/category.dart
import 'package:flutter/material.dart'; // For IconData mapping

class Category {
  final String id;
  final String name;
  final String iconName;
  final String? description;
  final int displayOrder; // Added based on API spec

  Category({
    required this.id,
    required this.name,
    required this.iconName,
    this.description,
    required this.displayOrder,
  });

  // Factory constructor to create a Category from JSON map
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['category_id'] as String,
      name: json['name'] as String,
      iconName: json['icon_name'] as String,
      description: json['description'] as String?,
      // Provide a default value if display_order might be null/missing
      displayOrder: (json['display_order'] ?? 0) as int,
    );
  }

  // Helper method to get IconData based on iconName
  IconData get iconData {
     switch (iconName) {
        case 'sentiment_satisfied': return Icons.sentiment_satisfied;
        case 'restaurant': return Icons.restaurant;
        case 'directions_run': return Icons.directions_run;
        case 'access_time': return Icons.access_time;
        case 'place': return Icons.place;
        case 'cleaning_services': return Icons.cleaning_services;
        case 'people': return Icons.people;
        case 'healing': return Icons.healing;
        case 'groups': return Icons.groups;
        case 'nature': return Icons.nature_people;
        case 'school': return Icons.school;
        case 'help_outline': return Icons.help_outline;
        case 'home': return Icons.home;
        case 'warning': return Icons.warning;
        case 'sports_esports': return Icons.sports_esports;
        default: return Icons.category;
     }
  }
}
