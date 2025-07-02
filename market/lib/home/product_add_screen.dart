import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:market/home/camera_example_page.dart';
import 'package:market/model/product.dart';

import '../model/category.dart';

class ProductAddScreen extends StatefulWidget {
  const ProductAddScreen({super.key});

  @override
  State<ProductAddScreen> createState() => _ProductAddScreenState();
}

class _ProductAddScreenState extends State<ProductAddScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isSale = false;
  bool isLoading = false;

  static const Color primaryColor = Color(0xFF2196F3);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color accentColor = Color(0xFFFF5722);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color buttonColor = Colors.black87;

  static const double spacing = 16.0;
  static const double smallSpacing = 8.0;
  static const double borderRadius = 12.0;

  final db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  Uint8List? imageData;
  XFile? selectedImageFile;

  Category? selectedCategory;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController stockController = TextEditingController();
  TextEditingController saleRateController = TextEditingController();

  List<Category> categoryList = [];
  bool isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final snapshot = await db.collection("category").get();
      categoryList.clear();

      for (var document in snapshot.docs) {
        categoryList.add(
          Category(docId: document.id, title: document.data()["title"]),
        );
      }

      if (mounted && categoryList.isNotEmpty) {
        setState(() {
          selectedCategory = categoryList.first;
          isLoadingCategories = false;
        });
      }
    } catch (e) {
      print('카테고리 로딩 실패: $e');
      if (mounted) {
        setState(() {
          isLoadingCategories = false;
        });
      }
    }
  }

  Future<Uint8List> imageCompressList(Uint8List list) async {
    var result = await FlutterImageCompress.compressWithList(list, quality: 50);
    return result;
  }

  void _showCategoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "카테고리 선택",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            Divider(height: 1),

            Expanded(
              child: isLoadingCategories
                  ? Center(
                child: CircularProgressIndicator(),
              )
                  : categoryList.isEmpty
                  ? Center(
                child: Text(
                  "카테고리가 없습니다",
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 16,
                  ),
                ),
              )
                  : ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 4),
                itemCount: categoryList.length,
                itemBuilder: (context, index) {
                  final category = categoryList[index];
                  final isSelected = selectedCategory?.docId == category.docId;

                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                    title: Text(
                      category.title ?? "카테고리",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? Colors.black87 : Colors.black87,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check, color: Colors.black87, size: 20)
                        : null,
                    onTap: () {
                      setState(() {
                        selectedCategory = category;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addProducts() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('카테고리를 선택해주세요'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.all(16)
        ),
      );
      return;
    }

    if (imageData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('제품 이미지를 선택해주세요'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.all(16)
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final storageRef = storage.ref().child(
        "products/${DateTime.now().millisecondsSinceEpoch}_${selectedImageFile?.name ?? "product"}.jpg",
      );
      final compressedImage = await imageCompressList(imageData!);
      await storageRef.putData(compressedImage);
      final imageUrl = await storageRef.getDownloadURL();

      for (var i = 0; i < 10; i++) {
        final productData = Product(
          title: "${titleController.text.trim()}${i + 1}",
          description: descriptionController.text.trim(),
          price: int.parse(priceController.text),
          stock: int.parse(stockController.text),
          isSale: isSale,
          saleRate: saleRateController.text.isNotEmpty
              ? double.parse(saleRateController.text)
              : 0,
          imgUrl: imageUrl,
          timestamp: DateTime.now().millisecondsSinceEpoch + i,
        );

        final doc = await db.collection("products").add(productData.toJson());
        await doc.collection("category").add(selectedCategory?.toJson() ?? {});
        final categoRef = db.collection("category").doc(selectedCategory?.docId);
        await categoRef.collection("products").add({"docId": doc.id});
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('10개 상품이 성공적으로 일괄 등록되었습니다!'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.all(16)
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('일괄 등록에 실패했습니다: $e'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.all(16)
          ),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('카테고리를 선택해주세요'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.all(16)
        ),
      );
      return;
    }

    if (imageData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('제품 이미지를 선택해주세요'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.all(16)
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final storageRef = storage.ref().child(
        "products/${DateTime.now().millisecondsSinceEpoch}_${selectedImageFile?.name ?? "product"}.jpg",
      );
      final compressedImage = await imageCompressList(imageData!);
      await storageRef.putData(compressedImage);
      final imageUrl = await storageRef.getDownloadURL();

      final productData = Product(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        price: int.parse(priceController.text),
        stock: int.parse(stockController.text),
        isSale: isSale,
        saleRate: saleRateController.text.isNotEmpty
            ? double.parse(saleRateController.text)
            : 0,
        imgUrl: imageUrl,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      final doc = await db.collection("products").add(productData.toJson());
      await doc.collection("category").add(selectedCategory?.toJson() ?? {});
      final categoRef = db.collection("category").doc(selectedCategory?.docId);
      await categoRef.collection("products").add({"docId": doc.id});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('상품이 성공적으로 등록되었습니다!'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.all(16)
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('상품 등록에 실패했습니다: $e'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.all(16)
          ),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          "상품 추가",
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: textPrimary),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => CameraExamplePage()),
              );
            },
            icon: Icon(Icons.camera_alt_outlined),
          ),
          IconButton(
            onPressed: isLoading ? null : addProducts,
            icon: Icon(Icons.content_copy),
          ),
          IconButton(
            onPressed: isLoading ? null : addProduct,
            icon: isLoading
                ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : Icon(Icons.check),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        final ImagePicker picker = ImagePicker();
                        selectedImageFile = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        imageData = await selectedImageFile?.readAsBytes();
                        setState(() {});
                      },
                      child: Container(
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: selectedImageFile == null
                            ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 8),
                            Text(
                              "이미지 추가",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        )
                            : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            imageData!,
                            height: 200,
                            width: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 32),

                  _buildTextField(
                    controller: titleController,
                    label: "상품명",
                    hint: "제품명을 입력하세요",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "필수 입력 항목입니다";
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 20),

                  _buildTextField(
                    controller: descriptionController,
                    label: "상품 설명",
                    hint: "상품에 대한 설명을 입력하세요",
                    maxLines: 3,
                    maxLength: 250,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "필수 입력 항목입니다";
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: priceController,
                          label: "가격",
                          hint: "원",
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "필수 입력";
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: stockController,
                          label: "재고",
                          hint: "개",
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "필수 입력";
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "할인 설정",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Switch(
                              value: isSale,
                              activeColor: Colors.white,
                              activeTrackColor: Colors.black87,
                              inactiveThumbColor: Colors.grey[400],
                              inactiveTrackColor: Colors.grey[200],
                              onChanged: (value) {
                                setState(() {
                                  isSale = value;
                                });
                              },
                            ),
                          ],
                        ),
                        if (isSale) ...[
                          SizedBox(height: 16),
                          _buildTextField(
                            controller: saleRateController,
                            label: "할인율",
                            hint: "%",
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (isSale && (value == null || value.isEmpty)) {
                                return "할인율을 입력해주세요";
                              }
                              return null;
                            },
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  Text(
                    "카테고리",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),

                  GestureDetector(
                    onTap: () => _showCategoryBottomSheet(),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedCategory?.title ?? "카테고리를 선택하세요",
                            style: TextStyle(
                              fontSize: 16,
                              color: selectedCategory != null
                                  ? Colors.black87
                                  : Colors.grey[500],
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black87, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}