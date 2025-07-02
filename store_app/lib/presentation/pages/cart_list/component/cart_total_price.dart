import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/constant/app_icons.dart';
import '../../../../core/theme/custom/custom_font_weight.dart';
import '../../../../core/theme/custom/custom_theme.dart';
import '../../../../core/utils/extensions.dart';
import '../bloc/cart_list_bloc/cart_list_bloc.dart';

class CartTotalPrice extends StatelessWidget {
  final bool isEmpty;

  const CartTotalPrice({super.key, required this.isEmpty});

  @override
  Widget build(BuildContext context) {
    if (isEmpty) {
      return Container(
        color: Colors.white,
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.contentFourth,
              ),
              const SizedBox(height: 16),
              Text(
                '장바구니에 담긴 상품이 없습니다.',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.contentSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final totalPrice = context.watch<CartListBloc>().state.totalPrice;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Divider(height: 8, thickness: 8, color: colorScheme.surface),
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '상품금액',
                      style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.contentPrimary,
                      ),
                    ),
                    Text(
                      totalPrice.toWon(),
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.contentPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '상품할인금액',
                      style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.contentPrimary,
                      ),
                    ),
                    Text(
                      '0원',
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.contentPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Text(
                  '로그인 후 할인 금액 적용',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.contentSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                Divider(height: 1, thickness: 1, color: colorScheme.outline),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '결제예정금액',
                      style: textTheme.titleMedium.semiBold?.copyWith(
                        color: colorScheme.contentPrimary,
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          WidgetSpan(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(
                                NumberFormat(
                                  '###,###,###,###',
                                ).format(totalPrice),
                                style: textTheme.titleLarge.bold?.copyWith(
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          TextSpan(
                            text: '원',
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Text(
                  '쿠폰/적립금은 주문서에서 사용 가능합니다',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.contentSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(AppIcons.badge, width: 31, height: 17),
                      const SizedBox(width: 8),
                      Text(
                        '로그인 후, 할인 및 적립 혜택 제공',
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.contentSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
