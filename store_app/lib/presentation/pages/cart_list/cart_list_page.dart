import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/constant/app_icons.dart';
import '../../../core/theme/custom/custom_font_weight.dart';
import '../../../core/theme/custom/custom_theme.dart';
import '../../../core/utils/constant.dart';
import '../../main/component/payment/payment_button.dart';
import '../../main/component/top_app_bar/widgets/svg_icon_button.dart';
import 'bloc/cart_list_bloc/cart_list_bloc.dart';
import 'component/cart_product_card.dart';
import 'component/cart_total_price.dart';

class CartListPage extends StatelessWidget {
  const CartListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: BlocProvider.of<CartListBloc>(context)..add(CartListInitialized()),
      child: const CartListView(),
    );
  }
}

class CartListView extends StatelessWidget {
  const CartListView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: Center(
          child: SvgIconButton(
            icon: AppIcons.close,
            color: colorScheme.contentPrimary,
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              }
            },
          ),
        ),
        title: Text(
          '장바구니',
          style: textTheme.titleMedium.semiBold?.copyWith(
            color: colorScheme.contentPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: colorScheme.outline),
                bottom: BorderSide(color: colorScheme.outline),
              ),
            ),
            child: BlocBuilder<CartListBloc, CartListState>(
              builder: (context, state) {
                final bool isSelectedAll =
                    (state.selectedProduct.length == state.cartList.length) &&
                    state.cartList.isNotEmpty;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SvgIconButton(
                          icon: isSelectedAll
                              ? AppIcons.checkMarkCircleFill
                              : AppIcons.checkMarkCircle,
                          color: isSelectedAll
                              ? colorScheme.primary
                              : colorScheme.contentFourth,
                          onPressed: () => context.read<CartListBloc>().add(
                            CartListSelectedAll(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '전체 선택 (${state.selectedProduct.length}/${state.cartList.length})',
                          style: textTheme.titleSmall?.copyWith(
                            color: colorScheme.contentPrimary,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      child: Text(
                        '선택 삭제',
                        style: textTheme.titleSmall.semiBold?.copyWith(
                          color: colorScheme.contentSecondary,
                        ),
                      ),
                      onTap: () => context.read<CartListBloc>().add(
                        CartListDeleted(productIds: state.selectedProduct),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: BlocBuilder<CartListBloc, CartListState>(
        builder: (context, state) {
          switch (state.status) {
            case Status.initial:
            case Status.loading:
            case Status.error:
              return const Center(child: CircularProgressIndicator());
            case Status.success:
              return ListView(
                children: [
                  Divider(height: 8, thickness: 8, color: colorScheme.surface),
                  Column(
                    children: [
                      for (
                        int index = 0;
                        index < state.cartList.length;
                        index++
                      ) ...[
                        CartProductCard(cart: state.cartList[index]),
                        if (index < state.cartList.length - 1)
                          Divider(
                            height: 1,
                            thickness: 1,
                            indent: 16,
                            endIndent: 16,
                            color: colorScheme.outline,
                          ),
                      ],
                    ],
                  ),
                  CartTotalPrice(isEmpty: state.cartList.isEmpty),
                  const SizedBox(height: 100),
                ],
              );
          }
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, -2),
              blurRadius: 10,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 8,
            top: 16,
            right: 8,
            bottom: MediaQuery.of(context).padding.bottom + 16,
          ),
          child: BlocBuilder<CartListBloc, CartListState>(
            builder: (context, state) {
              final selectedCartList = state.cartList
                  .where(
                    (cart) =>
                        state.selectedProduct.contains(cart.product.productId),
                  )
                  .toList();

              return PaymentButton(
                selectedCartList: selectedCartList,
                totalPrice: state.totalPrice,
              );
            },
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
