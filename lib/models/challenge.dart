class Challenge {
  final String id;
  final String title;
  final String description;
  final String type; // 'daily' | 'weekly'
  final int points; // Contributes to Eco Score
  bool isCompleted; // Mutable — toggled by AppController during session

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.points,
    this.isCompleted = false,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      points: json['points'] as int,
      isCompleted: false, // Always starts false — session resets on restart
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type,
        'points': points,
        'isCompleted': isCompleted,
      };
}
