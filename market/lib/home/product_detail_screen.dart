import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:market/main.dart';
import 'package:market/model/product.dart';

import '../login/provider/login_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isAddingToCart = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildProductImageSection(),
                  _buildProductInfoSection(),
                  _buildTabSection(),
                ],
              ),
            ),
          ),
          _buildAddToCartButton(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        widget.product.title ?? "상품 상세",
        style: const TextStyle(fontWeight: FontWeight.w600, color: textPrimary),
      ),
      backgroundColor: cardColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      actions: [
        GestureDetector(
          onTap: () => _showCustomDropdownMenu(),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: const Icon(Icons.more_vert, color: textPrimary),
          ),
        ),
      ],
    );
  }

  void _showCustomDropdownMenu() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        size.width - 160,
        kToolbarHeight + MediaQuery.of(context).padding.top,
        0,
        0,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      elevation: 8,
      items: [
        PopupMenuItem(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.rate_review_outlined,
                size: 20,
                color: Colors.grey[700],
              ),
              const SizedBox(width: 12),
              Text(
                "리뷰 작성",
                style: TextStyle(fontSize: 14, color: Colors.grey[800]),
              ),
            ],
          ),
          onTap: () => _showReviewDialog(),
        ),
      ],
    );
  }

  Widget _buildProductImageSection() {
    final saleRate = widget.product.saleRate ?? 0;

    return Container(
      height: 320,
      width: double.infinity,
      margin: const EdgeInsets.all(spacing),
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
            Image.network(
              widget.product.imgUrl ?? "",
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[100],
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[100],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_outlined,
                        color: Colors.grey[400],
                        size: 64,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "이미지를 불러올 수 없습니다",
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      ),
                    ],
                  ),
                );
              },
            ),

            if (widget.product.isSale == true && saleRate > 0)
              Positioned(
                top: spacing,
                left: spacing,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${saleRate.toInt()}% 할인",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfoSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(spacing, 0, spacing, spacing),
      padding: const EdgeInsets.all(spacing),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.product.title ?? "상품명",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: textPrimary,
              height: 1.2,
            ),
          ),

          const SizedBox(height: smallSpacing),

          if (widget.product.description != null &&
              widget.product.description!.isNotEmpty)
            Text(
              widget.product.description!,
              style: const TextStyle(
                color: textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),

          const SizedBox(height: spacing),

          _buildPriceSection(),

          const SizedBox(height: spacing),

          _buildStockAndRatingSection(),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    final originalPrice = widget.product.price ?? 0;
    final saleRate = widget.product.saleRate ?? 0;
    final discountedPrice = (originalPrice * (1 - saleRate / 100)).toInt();
    final isOnSale = widget.product.isSale == true && saleRate > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isOnSale) ...[
          Text(
            "${_formatPrice(originalPrice)}원",
            style: TextStyle(
              decoration: TextDecoration.lineThrough,
              decorationColor: Colors.grey[400],
              color: Colors.grey[400],
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
        ],

        Row(
          children: [
            Text(
              _formatPrice(isOnSale ? discountedPrice : originalPrice),
              style: TextStyle(
                color: isOnSale ? accentColor : textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                height: 1.0,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              "원",
              style: TextStyle(
                color: isOnSale ? accentColor : textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w500,
                height: 1.0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStockAndRatingSection() {
    return Row(
      children: [
        if (widget.product.stock != null && widget.product.stock! > 0) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inventory_2_outlined, color: primaryColor, size: 16),
                const SizedBox(width: 4),
                Text(
                  "재고 ${widget.product.stock}개",
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.orange, size: 16),
              const SizedBox(width: 4),
              Text(
                "0.0",
                style: TextStyle(
                  color: Colors.orange[700],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(spacing, 0, spacing, spacing),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              labelColor: primaryColor,
              unselectedLabelColor: textSecondary,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
              indicatorColor: primaryColor,
              indicatorWeight: 3,
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              tabs: const [
                Tab(text: "상품 상세"),
                Tab(text: "리뷰"),
              ],
            ),
            SizedBox(
              height: 300,
              child: TabBarView(
                children: [_buildProductDetailTab(), _buildReviewTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetailTab() {
    return Padding(
      padding: const EdgeInsets.all(spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "상품 정보",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: smallSpacing),
          Text(
            widget.product.description ?? "상품 설명이 없습니다.",
            style: const TextStyle(
              color: textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("products")
          .doc(widget.product.docId)
          .collection("reviews")
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(spacing),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red[300],
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "리뷰를 불러오는 중 오류가 발생했습니다",
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final reviews = snapshot.data?.docs ?? [];

        if (reviews.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(spacing),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      Icons.rate_review_outlined,
                      color: Colors.grey[400],
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "아직 리뷰가 없습니다",
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "첫 번째 리뷰를 작성해보세요!",
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(spacing),
          itemCount: reviews.length,
          itemBuilder: (context, index) => _buildReviewItem(reviews[index]),
          separatorBuilder: (context, index) => const SizedBox(height: 12),
        );
      },
    );
  }

  Widget _buildReviewItem(QueryDocumentSnapshot review) {
    final reviewData = review.data() as Map<String, dynamic>;
    final score = int.tryParse(reviewData["score"]?.toString() ?? "0") ?? 0;
    final reviewText = reviewData["review"]?.toString() ?? "";
    final email = reviewData["email"]?.toString() ?? "익명";
    final timestamp = (reviewData["timestamp"] as Timestamp?)?.toDate();

    final userName = email != "익명" ? email.split("@").first : "익명";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor.withValues(alpha: 0.8), primaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : "?",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          color: textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (timestamp != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          "${timestamp.year}.${timestamp.month.toString().padLeft(2, '0')}.${timestamp.day.toString().padLeft(2, '0')}",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.orange,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        score.toString(),
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (reviewText.isNotEmpty) ...[
              Text(
                reviewText,
                style: const TextStyle(
                  color: textPrimary,
                  fontSize: 14,
                  height: 1.5,
                  letterSpacing: -0.2,
                ),
              ),
            ] else ...[
              Text(
                "리뷰 내용이 없습니다.",
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddToCartButton() {
    return Container(
      padding: const EdgeInsets.all(spacing),
      decoration: const BoxDecoration(color: cardColor),
      child: SafeArea(
        child: Consumer(  // 여기가 추가됨!
          builder: (context, ref, child) {
            return SizedBox(
              width: double.infinity,
              height: 56,
              child: Material(
                color: _isAddingToCart
                    ? buttonColor.withValues(alpha: 0.6)
                    : buttonColor,
                borderRadius: BorderRadius.circular(borderRadius),
                child: InkWell(
                  onTap: _isAddingToCart ? null : () => _handleAddToCart(ref), // ref 전달
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: Container(
                    height: 56,
                    alignment: Alignment.center,
                    child: _isAddingToCart
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                        : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 20,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "장바구니에 담기",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleAddToCart(WidgetRef ref) async {
    setState(() {
      _isAddingToCart = true;
    });

    try {
      final user = ref.read(userCredentialProvider);
      final currentUid = user?.user?.uid;

      if (currentUid == null) {
        if (mounted) {
          _showErrorDialog("오류", "로그인이 필요합니다.");
        }
        return;
      }

      final db = FirebaseFirestore.instance;
      final existingCartItems = await db
          .collection("cart")
          .where("uid", isEqualTo: currentUid)
          .where("product.docId", isEqualTo: widget.product.docId)
          .get();

      if (existingCartItems.docs.isNotEmpty) {
        if (mounted) {
          _showInfoDialog("알림", "이미 장바구니에 있는 상품입니다.");
        }
        return;
      }

      await db.collection("cart").add({
        "uid": currentUid,
        "email": user?.user?.email ?? "",
        "timestamp": DateTime.now().millisecondsSinceEpoch,
        "product": widget.product.toJson(),
        "count": 1,
      });

      if (mounted) {
        // 🔧 수정: SnackBar에 장바구니 이동 버튼 추가
        _showSuccessSnackBar("장바구니에 상품이 추가되었습니다!", currentUid);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog("오류", "장바구니 추가 중 오류가 발생했습니다.");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  void _showSuccessSnackBar(String message, String uid) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 4), // 좀 더 길게 표시
        action: SnackBarAction(
          label: "장바구니 보기",
          textColor: Colors.white,
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          onPressed: () {
            context.go("/cart/$uid");
          },
        ),
      ),
    );
  }

  void _showReviewDialog() {
    int selectedRating = 0;
    final reviewController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: 300,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                        child: Column(
                          children: [
                            const Text(
                              "리뷰 작성",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "평점",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                5,
                                    (index) => GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedRating = index + 1;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                    ),
                                    child: Icon(
                                      Icons.star,
                                      color: index < selectedRating
                                          ? Colors.orange
                                          : Colors.grey[300],
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: reviewController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: "상품에 대한 후기를 작성해주세요",
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 13,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.black87,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.all(12),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(height: 0.5, color: Colors.grey[300]),
                      Consumer(
                        builder: (context, ref, child) {
                          final user = ref.watch(userCredentialProvider);
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                if (selectedRating == 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("별점을 선택해주세요"),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      margin: EdgeInsets.all(16)
                                    ),
                                  );
                                  return;
                                }

                                await FirebaseFirestore.instance
                                    .collection("products")
                                    .doc("${widget.product.docId}")
                                    .collection("reviews")
                                    .add({
                                  "uid": user?.user?.uid ?? "",
                                  "email": user?.user?.email ?? "",
                                  "review": reviewController.text.trim(),
                                  "timestamp": Timestamp.now(),
                                  "score": selectedRating,
                                });

                                Navigator.of(context).pop();
                                _showSuccessDialog("성공", "리뷰가 등록되었습니다.");
                              },
                              splashColor: Colors.blue.withValues(alpha: 0.1),
                              highlightColor: Colors.blue.withValues(alpha: 0.05),
                              child: Container(
                                height: 50,
                                width: double.infinity,
                                alignment: Alignment.center,
                                child: const Text(
                                  "등록",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      Container(height: 0.5, color: Colors.grey[300]),
                      Material(
                        color: Colors.transparent,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          splashColor: Colors.grey.withValues(alpha: 0.1),
                          highlightColor: Colors.grey.withValues(alpha: 0.05),
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
              ),
            );
          },
        );
      },
    );
  }

  void _showInfoDialog(String title, String message) {
    showDialog(
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
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        message,
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
                Container(height: 0.5, color: Colors.grey[300]),
                Material(
                  color: Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    splashColor: Colors.blue.withValues(alpha: 0.1),
                    highlightColor: Colors.blue.withValues(alpha: 0.05),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: const Text(
                        "확인",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
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

  void _showSuccessDialog(String title, String message) {
    showDialog(
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
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        message,
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
                Container(height: 0.5, color: Colors.grey[300]),
                Material(
                  color: Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    splashColor: primaryColor.withValues(alpha: 0.1),
                    highlightColor: primaryColor.withValues(alpha: 0.05),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text(
                        "확인",
                        style: TextStyle(
                          fontSize: 16,
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
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

  void _showErrorDialog(String title, String message) {
    showDialog(
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
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        message,
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
                Container(height: 0.5, color: Colors.grey[300]),
                Material(
                  color: Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    splashColor: Colors.red.withValues(alpha: 0.1),
                    highlightColor: Colors.red.withValues(alpha: 0.05),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: const Text(
                        "확인",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
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

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }
}