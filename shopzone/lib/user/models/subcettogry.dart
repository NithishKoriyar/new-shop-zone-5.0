

class Subcategory {
  String? subcategory_id;
  String? category_id;
  String? name;
  String? img_path;
  
  //
 

  Subcategory({
    this.subcategory_id,
    this.category_id,
    this.name,
    this.img_path,
   
  });

  Subcategory.fromJson(Map<String, dynamic> json) {
   subcategory_id = json["subcategory_id"];
    category_id = json["category_id"];
    name = json["name"];
   img_path = json["img_path"];
   

  
  }
}
