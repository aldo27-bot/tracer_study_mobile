class NotifModel {
  final String title;
  final String body;
  final String time;

  NotifModel({
    required this.title,
    required this.body,
    required this.time,
  });

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "body": body,
      "time": time,
    };
  }

  factory NotifModel.fromJson(Map<String, dynamic> json) {
    return NotifModel(
      title: json["title"] ?? "",
      body: json["body"] ?? "",
      time: json["time"] ?? "",
    );
  }
}