class RecyclingItem {
  final String id;
  final String name;
  final String category; // Paper | Plastic | Glass | Metal | Organic | E-Waste
  final String disposalMethod;
  final String iconName;
  final bool isRecyclable;

  const RecyclingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.disposalMethod,
    required this.iconName,
    required this.isRecyclable,
  });

  factory RecyclingItem.fromJson(Map<String, dynamic> json) {
    return RecyclingItem(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      disposalMethod: json['disposalMethod'] as String,
      iconName: json['iconName'] as String,
      isRecyclable: json['isRecyclable'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'disposalMethod': disposalMethod,
        'iconName': iconName,
        'isRecyclable': isRecyclable,
      };
}
