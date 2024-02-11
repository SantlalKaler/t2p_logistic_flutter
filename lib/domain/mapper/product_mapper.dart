
import '../Model/AF2APOrderResponse.dart';
import '../Model/AF2APUpdateProduct.dart' as updateProduct;

extension ProductsExtension on Products{
  updateProduct.Products toAF2APUpdateProduct(){
    return updateProduct.Products(
      name: name,
      weidth: weidth,
      height: height,
      weight: weight,
      length: length,
      category: category!.id!,
      subCategory: subCategory!.id
    );
  }
}