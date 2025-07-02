import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:market/model/category.dart';
import 'package:market/model/product.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  List<Category> categories = [];

  static const Color primaryColor = Color(0xFF2196F3);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color accentColor = Color(0xFFFF5722);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color buttonColor = Colors.black87;

  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  static const double spacing = 16.0;
  static const double smallSpacing = 8.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _getCategoriesStream() {
    return FirebaseFirestore.instance.collection("category").snapshots();
  }

  Stream<List<Product>> _getSaleProductsStream() {
    return FirebaseFirestore.instance
        .collection("products")
        .where("isSale", isEqualTo: true)
        .orderBy("saleRate", descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) {
      List<Product> productList = [];
      try {
        for (var document in snapshot.docs) {
          final productData = Product.fromJson(document.data());
          final productWithDocId = productData.copyWith(docId: document.id);
          productList.add(productWithDocId);
        }
      } catch (e) {
        debugPrint('Error processing sale products: $e');
      }
      return productList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: spacing),
            const BannerSection(),
            const SizedBox(height: spacing),
            _buildCategorySection(),
            const SizedBox(height: spacing),
            _buildSaleSection(),
            const SizedBox(height: spacing),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Container(
      decoration: _buildCardDecoration(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(spacing, spacing, spacing, 0),
            child: _buildSectionHeader("카테고리", () {
            }),
          ),
          const SizedBox(height: spacing),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _getCategoriesStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return SizedBox(
                  height: 160,
                  child: _buildErrorWidget("카테고리를 불러올 수 없습니다."),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: 160,
                  child: _buildLoadingWidget(),
                );
              }

              if (snapshot.hasData) {
                categories.clear();
                final docs = snapshot.data;
                final categoryDocs = docs?.docs ?? [];

                for (var doc in categoryDocs) {
                  categories.add(
                    Category(docId: doc.id, title: doc.data()["title"]),
                  );
                }

                if (categories.isEmpty) {
                  return SizedBox(
                    height: 160,
                    child: _buildEmptyWidget("등록된 카테고리가 없습니다."),
                  );
                }

                return SizedBox(
                  height: 160,
                  child: GridView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: spacing),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.0,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return _buildCategoryItem(category);
                    },
                  ),
                );
              }

              return SizedBox(
                height: 160,
                child: _buildLoadingWidget(),
              );
            },
          ),
          const SizedBox(height: spacing),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(Category category) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
        },
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Colors.transparent,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: buttonColor.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: buttonColor.withValues(alpha: 0.12),
                  child: Icon(
                    Icons.category_rounded,
                    color: buttonColor,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  category.title ?? "카테고리",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: textPrimary,
                    height: 1.0,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaleSection() {
    return Container(
      decoration: _buildCardDecoration(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(spacing, spacing, spacing, 0),
            child: _buildSectionHeader("🔥 오늘의 특가", () {
            }),
          ),
          const SizedBox(height: spacing),
          SizedBox(
            height: 300,
            child: StreamBuilder<List<Product>>(
              stream: _getSaleProductsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: spacing),
                    child: _buildErrorWidget("특가 상품을 불러올 수 없습니다."),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: spacing),
                    child: _buildLoadingWidget(),
                  );
                }

                if (snapshot.hasData) {
                  final products = snapshot.data ?? [];

                  if (products.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: spacing),
                      child: _buildEmptyWidget("특가 상품이 없습니다."),
                    );
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: spacing),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _buildSaleProductItem(context, product);
                    },
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: spacing),
                  child: _buildLoadingWidget(),
                );
              },
            ),
          ),
          const SizedBox(height: spacing),
        ],
      ),
    );
  }

  Widget _buildSaleProductItem(BuildContext context, Product product) {
    final originalPrice = product.price ?? 0;
    final saleRate = product.saleRate ?? 0;
    final discountedPrice = (originalPrice * (1 - saleRate / 100)).toInt();

    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.go("/product", extra: product);
          },
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.grey.withValues(alpha: 0.2),
          highlightColor: Colors.grey.withValues(alpha: 0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      children: [
                        SizedBox.expand(
                          child: Image.network(
                            product.imgUrl ?? "",
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[50],
                                child: Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.grey[400]!,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[50],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_outlined,
                                      color: Colors.grey[300],
                                      size: 24,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "이미지 없음",
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 9,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        if (saleRate > 0)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: accentColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "${saleRate.toInt()}%",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  height: 1.0,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title ?? "상품명",
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: textPrimary,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 6),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (saleRate > 0) ...[
                            Text(
                              "${originalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원",
                              style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                decorationColor: Colors.grey[400],
                                color: Colors.grey[400],
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 2),
                          ],

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${discountedPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                                style: TextStyle(
                                  color: saleRate > 0 ? accentColor : textPrimary,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(width: 1),
                              Text(
                                "원",
                                style: TextStyle(
                                  color: saleRate > 0 ? accentColor : textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  height: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const Spacer(),

                      Row(
                        children: [
                          if (product.stock != null && product.stock! > 0) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "재고 ${product.stock}",
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          if (saleRate > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "특가",
                                style: TextStyle(
                                  color: accentColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onMorePressed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: textPrimary,
          ),
        ),
        TextButton(
          onPressed: onMorePressed,
          style: TextButton.styleFrom(
            foregroundColor: buttonColor,
            padding: const EdgeInsets.symmetric(horizontal: spacing),
          ),
          child: const Text(
            "더보기",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: cardColor,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[300],
            size: 48,
          ),
          const SizedBox(height: smallSpacing),
          Text(
            message,
            style: const TextStyle(
              color: textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            color: Colors.grey[400],
            size: 48,
          ),
          const SizedBox(height: smallSpacing),
          Text(
            message,
            style: const TextStyle(
              color: textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class BannerSection extends StatefulWidget {
  const BannerSection({super.key});

  @override
  State<BannerSection> createState() => _BannerSectionState();
}

class _BannerSectionState extends State<BannerSection> {
  PageController pageController = PageController(initialPage: 5000);
  int currentBannerIndex = 0;
  Timer? _timer;

  final List<String> bannerImages = [
    "https://picsum.photos/800/400?random=1",
    "https://picsum.photos/800/400?random=2",
    "https://picsum.photos/800/400?random=3",
  ];

  static const Color primaryColor = Color(0xFF2196F3);
  static const double borderRadius = 12.0;
  static const double spacing = 16.0;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (pageController.hasClients) {
        final currentPage = pageController.page ?? 5000;
        final nextPage = currentPage.toInt() + 1;

        pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: spacing),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            PageView.builder(
              controller: pageController,
              onPageChanged: (index) {
                setState(() {
                  currentBannerIndex = index % bannerImages.length;
                });
              },
              itemBuilder: (context, index) {
                final imageIndex = index % bannerImages.length;
                return _buildBannerItem(bannerImages[imageIndex]);
              },
            ),
            Positioned(
              bottom: spacing,
              right: spacing,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DotsIndicator(
                  dotsCount: bannerImages.length,
                  position: currentBannerIndex.toDouble(),
                  decorator: DotsDecorator(
                    activeColor: Colors.white,
                    color: Colors.white.withValues(alpha: 0.5),
                    size: const Size.square(4.0),
                    activeSize: const Size(8.0, 4.0),
                    activeShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerItem(String imageUrl) {
    return Stack(
      children: [
        SizedBox.expand(
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      primaryColor.withValues(alpha: 0.8),
                      primaryColor,
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.3),
              ],
            ),
          ),
        ),
      ],
    );
  }
}