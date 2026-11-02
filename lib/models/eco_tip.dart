class EcoTip {
  final String id;
  final String category;
  final String title;
  final String description;
  final String iconName; // Maps to a Material icon name string for display

  const EcoTip({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.iconName,
  });

  factory EcoTip.fromJson(Map<String, dynamic> json) {
    return EcoTip(
      id: json['id'] as String,
      category: json['category'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      iconName: json['iconName'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'title': title,
        'description': description,
        'iconName': iconName,
      };
}
