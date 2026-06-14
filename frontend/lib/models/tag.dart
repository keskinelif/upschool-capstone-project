enum TagType { vibe, product }

class Tag {
  const Tag({
    required this.id,
    required this.name,
    required this.type,
    required this.isActive,
  });

  final String id;
  final String name;
  final TagType type;
  final bool isActive;

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
        id: json['id'] as String,
        name: json['name'] as String,
        type: (json['type'] as String) == 'vibe' ? TagType.vibe : TagType.product,
        isActive: json['is_active'] as bool,
      );
}
