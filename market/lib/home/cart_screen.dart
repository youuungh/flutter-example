import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:market/model/product.dart';

class CartScreen extends StatefulWidget {
  final String uid;

  const CartScreen({super.key, required this.uid});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color accentColor = Color(0xFFFF5722);
  static const Color buttonColor = Colors.black87;

  static const double spacing = 16.0;
  static const double smallSpacing = 8.0;
  static const double borderRadius = 12.0;

  Stream<QuerySnapshot<Map<String, dynamic>>> streamCartItems() {
    return FirebaseFirestore.instance
        .collection("cart")
        .where("uid", isEqualTo: widget.uid)
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  Future<void> _deleteCartItem(String cartDocId) async {
    try {
      await FirebaseFirestore.instance
          .collection("cart")
          .doc(cartDocId)
          .delete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("삭제 중 오류가 발생했습니다"),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.all(16)
          ),
        );
      }
    }
  }

  Future<void> _updateCartItemCount(String cartDocId, int newCount) async {
    try {
      await FirebaseFirestore.instance
          .collection("cart")
          .doc(cartDocId)
          .update({"count": newCount});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("수량 변경 중 오류가 발생했습니다"),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.all(16)
          ),
        );
      }
    }
  }

  double _calculateItemPrice(dynamic item) {
    final product = item['product'];
    final count = item['count'] ?? 1;
    final originalPrice = product?.price?.toDouble() ?? 0.0;
    final saleRate = product?.saleRate?.toDouble() ?? 0.0;
    final isOnSale = product?.isSale ?? false;

    if (isOnSale && saleRate > 0) {
      final discountedPrice = originalPrice * (1 - saleRate / 100);
      return discountedPrice * count;
    } else {
      return originalPrice * count;
    }
  }

  Future<bool?> _showDeleteConfirmDialog() {
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
                      const SizedBox(height: 12),
                      Text(
                        "장바구니에서 이 상품을 삭제하시겠습니까?",
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
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(true),
                    splashColor: Colors.red.withValues(alpha: 0.1),
                    highlightColor: Colors.red.withValues(alpha: 0.05),
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
                Container(height: 0.5, color: Colors.grey[300]),
                Material(
                  color: Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(false),
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "장바구니",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        backgroundColor: cardColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: streamCartItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red[300],
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "장바구니를 불러오는 중 오류가 발생했습니다",
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.grey[400],
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "장바구니가 비어있습니다",
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "상품을 담아보세요!",
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final items = snapshot.data!.docs.map((doc) {
                  final data = doc.data();
                  return {
                    'cartDocId': doc.id,
                    'product': data['product'] != null
                        ? Product.fromJson(data['product'])
                        : null,
                    'count': data['count'] ?? 1,
                    'timestamp': data['timestamp'],
                  };
                }).toList();

                return ListView.separated(
                  padding: EdgeInsets.all(spacing),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final product = item['product'] as Product?;
                    final count = item['count'] as int;
                    final cartDocId = item['cartDocId'] as String;

                    if (product == null) {
                      return Container(
                        margin: EdgeInsets.only(bottom: spacing),
                        padding: EdgeInsets.all(spacing),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(borderRadius),
                        ),
                        child: Text(
                          "상품 정보를 불러올 수 없습니다",
                          style: TextStyle(color: textSecondary),
                        ),
                      );
                    }

                    final itemPrice = _calculateItemPrice(item);
                    final originalPrice = product.price?.toDouble() ?? 0.0;
                    final saleRate = product.saleRate?.toDouble() ?? 0.0;
                    final isOnSale = product.isSale ?? false;

                    return Container(
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
                      child: Padding(
                        padding: EdgeInsets.all(spacing),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,  // ← 추가
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(borderRadius),
                                  color: Colors.grey[100],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(borderRadius),
                                  child: product.imgUrl != null && product.imgUrl!.isNotEmpty
                                      ? Image.network(
                                    product.imgUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[100],
                                        child: Icon(
                                          Icons.image_outlined,
                                          color: Colors.grey[400],
                                          size: 32,
                                        ),
                                      );
                                    },
                                  )
                                      : Container(
                                    color: Colors.grey[100],
                                    child: Icon(
                                      Icons.image_outlined,
                                      color: Colors.grey[400],
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: spacing),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            product.title ?? "상품명 없음",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: textPrimary,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        SizedBox(
                                          width: 32,
                                          height: 32,
                                          child: IconButton(
                                            onPressed: () async {
                                              final result = await _showDeleteConfirmDialog();
                                              if (result == true) {
                                                await _deleteCartItem(cartDocId);
                                              }
                                            },
                                            icon: Icon(
                                              Icons.delete_outline,
                                              color: Colors.red[400],
                                              size: 20,
                                            ),
                                            padding: EdgeInsets.zero,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: smallSpacing),

                                    if (isOnSale && saleRate > 0) ...[
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: accentColor,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              "${saleRate.toInt()}% 할인",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "${_formatPrice(originalPrice.toInt())}원",
                                            style: TextStyle(
                                              decoration: TextDecoration.lineThrough,
                                              color: Colors.grey[400],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                    ],

                                    Text(
                                      "${_formatPrice(itemPrice.toInt())}원",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: isOnSale ? accentColor : textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: spacing),

                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey[300]!),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,  // ← 최소 크기로 설정
                                          children: [
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () {
                                                  if (count > 1) {
                                                    _updateCartItemCount(cartDocId, count - 1);
                                                  }
                                                },
                                                borderRadius: BorderRadius.circular(8),
                                                child: Container(
                                                  width: 32,
                                                  height: 32,
                                                  alignment: Alignment.center,
                                                  child: Icon(
                                                    Icons.remove,
                                                    size: 16,
                                                    color: count > 1 ? textPrimary : Colors.grey[400],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 40,
                                              height: 32,
                                              alignment: Alignment.center,
                                              child: Text(
                                                count.toString(),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: textPrimary,
                                                ),
                                              ),
                                            ),
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () {
                                                  if (count < 99) {
                                                    _updateCartItemCount(cartDocId, count + 1);
                                                  }
                                                },
                                                borderRadius: BorderRadius.circular(8),
                                                child: Container(
                                                  width: 32,
                                                  height: 32,
                                                  alignment: Alignment.center,
                                                  child: Icon(
                                                    Icons.add,
                                                    size: 16,
                                                    color: count < 99 ? textPrimary : Colors.grey[400],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
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
                  separatorBuilder: (context, index) => SizedBox(height: spacing),
                );
              },
            ),
          ),

          Container(
            decoration: BoxDecoration(
              color: cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(spacing),
                child: Column(
                  children: [
                    StreamBuilder(
                      stream: streamCartItems(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Container();
                        }

                        final items = snapshot.data!.docs.map((doc) {
                          final data = doc.data();
                          return {
                            'product': data['product'] != null
                                ? Product.fromJson(data['product'])
                                : null,
                            'count': data['count'] ?? 1,
                          };
                        }).toList();

                        double totalPrice = 0;
                        for (var item in items) {
                          totalPrice += _calculateItemPrice(item);
                        }

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "총 합계",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: textPrimary,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                "${_formatPrice(totalPrice.toInt())}원",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: primaryColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: spacing),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(borderRadius),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "주문하기",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }
}