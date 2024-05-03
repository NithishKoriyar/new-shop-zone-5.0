
class ShopCategory {
  String? category_id;
  String? name;
  String? file_path;
  String? added_date;

  ShopCategory({
    this.category_id,
    this.name,
    this.file_path,
    this.added_date,
  });

  ShopCategory.fromJson(Map<String, dynamic> json) {
    category_id = json["category_id"];
    name = json["name"];
    file_path = json["file_path"];
    added_date = json["added_date"];
  }
}
