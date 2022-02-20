class NoteModel {
  String notes;
  String title;
  String url;

  NoteModel({
    required this.notes,
    required this.title,
    required this.url,
  });

  factory NoteModel.fromMap(Map<String, dynamic> json) {
    return NoteModel(
        notes: json["notes"], title: json["title"], url: json["url"] ?? "");
  }

  Map<String, dynamic> crud() {
    return {"notes": notes, "title": title, "url": url};
  }
}
