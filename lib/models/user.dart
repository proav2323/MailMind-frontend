class USER {
  String _id = "";
  final String name;
  final String email;
  final String photoUrl;
  final String college;
  final String branch;
  final int year;
  final String oAuthProvider;

  USER({
    required this.name,
    required this.email,
    required this.branch,
    required this.college,
    required this.oAuthProvider,
    required this.photoUrl,
    required this.year,
    required id,
  }) {
    _id = id;
  }

  factory USER.fromJson(Map<String, Object?> json) {
    return USER(
      name: json['name'] as String,
      email: json['email'] as String,
      branch: json['branch'] as String,
      college: json['college'] as String,
      oAuthProvider: json['oAuthProvider'] as String,
      photoUrl: json['photoUrl'] as String,
      year: json['year'] as int,
      id: json['_id'] as String,
    );
  }
}
