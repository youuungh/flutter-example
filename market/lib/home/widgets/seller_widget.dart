import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:market/model/product.dart';

Future addCategories(String title) async {
  final db = FirebaseFirestore.instance;
  final ref = db.collection("category");
  await ref.add({"title": title});
}

Future<List<Product>> fetchProducts() async {
  final db = FirebaseFirestore.instance;
  final snapshot = await db.collection("products").orderBy("timestamp").get();

  List<Product> productList = [];

  for (var document in snapshot.docs) {
    final productData = Product.fromJson(document.data());
    final productWithDocId = productData.copyWith(docId: document.id);
    productList.add(productWithDocId);
  }

  return productList;
}

Stream<QuerySnapshot> streamProducts(String query) {
  final db = FirebaseFirestore.instance;
  if (query.isNotEmpty) {
    return db.collection("products").orderBy("title").startAt([query]).endAt([
      "$query\uf8ff",
    ]).snapshots();
  }

  return db.collection("products").orderBy("timestamp").snapshots();
}

class SellerWidget extends StatefulWidget {
  const SellerWidget({super.key});

  @override
  State<SellerWidget> createState() => _SellerWidgetState();
}

class _SellerWidgetState extends State<SellerWidget> {
  TextEditingController searchController = TextEditingController();

  update(Product product) async {
    final db = FirebaseFirestore.instance;
    final ref = db.collection("products");
    await ref
        .doc(product.docId)
        .update(
      product
          .copyWith(title: "수정됨", price: 9999, stock: 99, isSale: false)
          .toJson(),
    );
  }

  delete(Product product) async {
    final db = FirebaseFirestore.instance;
    await db.collection("products").doc(product.docId).delete();

    final productCategory = await db
        .collection("products")
        .doc(product.docId)
        .collection("category")
        .get();
    final foo = productCategory.docs.first;
    final categoryId = foo.data()["docId"];
    final bar = await db
        .collection("category")
        .doc(categoryId)
        .collection("products")
        .where("docId", isEqualTo: product.docId)
        .get();
    for (var document in bar.docs) {
      document.reference.delete();
    }
  }

  Future<bool?> _showDeleteDialog(Product product) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 280,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Column(
                    children: [
                      Text(
                        "상품 삭제",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "'${product.title}'을(를) 정말 삭제하시겠습니까?\n삭제된 상품은 복구할 수 없습니다.",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 0.5,
                  color: Colors.grey[300],
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(true),
                    splashColor: Colors.red.withOpacity(0.1),
                    highlightColor: Colors.red.withOpacity(0.05),
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: const Text(
                        "삭제",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 0.5,
                  color: Colors.grey[300],
                ),
                Material(
                  color: Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(false),
                    splashColor: Colors.grey.withOpacity(0.1),
                    highlightColor: Colors.grey.withOpacity(0.05),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: const Text(
                        "취소",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String?> _showCategoryDialog() {
    TextEditingController controller = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 280,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Text(
                    "새 카테고리 추가",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: TextField(
                    controller: controller,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: "카테고리명을 입력하세요",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[600]!),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                Container(
                  height: 0.5,
                  color: Colors.grey[300],
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (controller.text.trim().isNotEmpty) {
                        Navigator.of(context).pop(controller.text.trim());
                      }
                    },
                    splashColor: Colors.blue.withOpacity(0.1),
                    highlightColor: Colors.blue.withOpacity(0.05),
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: const Text(
                        "추가",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 0.5,
                  color: Colors.grey[300],
                ),
                Material(
                  color: Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    splashColor: Colors.grey.withOpacity(0.1),
                    highlightColor: Colors.grey.withOpacity(0.05),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: const Text(
                        "취소",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showProductBottomSheet(Product product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              child: Text(
                product.title ?? "상품 옵션",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Divider(height: 1),

            ListTile(
              leading: Icon(Icons.reviews_outlined),
              title: Text("리뷰"),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: Icon(Icons.edit_outlined),
              title: Text("수정"),
              onTap: () {
                Navigator.pop(context);
                update(product);
              },
            ),

            ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red),
              title: Text("삭제", style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                final result = await _showDeleteDialog(product);
                if (result == true) {
                  delete(product);
                }
              },
            ),

            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: (s) {
                    setState(() {});
                  },
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  decoration: InputDecoration(
                    hintText: "상품 검색...",
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),

              SizedBox(height: 16),

              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "카테고리 관리",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              List<String> categories = [
                                "식품",
                                "패션",
                                "전자제품",
                                "생활용품",
                                "뷰티",
                                "가구",
                                "스포츠",
                                "도서",
                                "음반",
                              ];
                              final categoryRef = FirebaseFirestore.instance.collection(
                                "category",
                              );
                              final existingDocs = await categoryRef.get();

                              for (var document in existingDocs.docs) {
                                await document.reference.delete();
                              }

                              for (var category in categories) {
                                await categoryRef.add({"title": category});
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text("카테고리 일괄등록"),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final categoryName = await _showCategoryDialog();
                              if (categoryName != null) {
                                await addCategories(categoryName);
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.black87),
                              foregroundColor: Colors.black87,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text("카테고리 추가"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              Text(
                "상품목록",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: 12),

              Expanded(
                child: StreamBuilder(
                  stream: streamProducts(searchController.text),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final productList =
                          snapshot.data?.docs
                              .map(
                                (document) => Product.fromJson(
                              document.data() as Map<String, dynamic>,
                            ).copyWith(docId: document.id),
                          )
                              .toList() ??
                              [];

                      if (productList.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                "등록된 상품이 없습니다",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: EdgeInsets.only(bottom: 100),
                        itemCount: productList.length,
                        itemBuilder: (context, index) {
                          final product = productList[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: InkWell(
                              onTap: () {
                                print(product.docId);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            product.imgUrl ??
                                                "https://cdn.pixabay.com/photo/2023/04/23/16/08/flower-7946074_1280.jpg",
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  product.title ?? "상품명",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16,
                                                    color: Colors.black87,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () => _showProductBottomSheet(product),
                                                borderRadius: BorderRadius.circular(20),
                                                child: Padding(
                                                  padding: EdgeInsets.all(4),
                                                  child: Icon(
                                                    Icons.more_vert,
                                                    color: Colors.grey[600],
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            "${product.price?.toStringAsFixed(0) ?? 0}원",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: product.isSale == true
                                                      ? Colors.red[50]
                                                      : Colors.grey[100],
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  product.isSale == true ? "할인 중" : "정가",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: product.isSale == true
                                                        ? Colors.red[700]
                                                        : Colors.grey[700],
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                "재고: ${product.stock}개",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                    return Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}