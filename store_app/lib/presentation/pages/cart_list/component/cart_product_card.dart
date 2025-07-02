import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/constant/app_icons.dart';
import '../../../../core/theme/custom/custom_font_weight.dart';
import '../../../../core/theme/custom/custom_theme.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/widgets/cart_counter_btn.dart';
import '../../../../domain/model/display/display.model.dart';
import '../../../main/component/top_app_bar/widgets/svg_icon_button.dart';
import '../bloc/cart_list_bloc/cart_list_bloc.dart';

const double _imageHeight = 78;
const double _imageWidth = 60;

class CartProductCard extends StatelessWidget {
  final Cart cart;

  const CartProductCard({super.key, required this.cart});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final productId = cart.product.productId;
    final bloc = context.read<CartListBloc>();
    final isSelected = context.select(
          (CartListBloc bloc) => bloc.state.selectedProduct.contains(productId),
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgIconButton(
            icon: isSelected
                ? AppIcons.checkMarkCircleFill
                : AppIcons.checkMarkCircle,
            color: isSelected ? colorScheme.primary : colorScheme.contentFourth,
            onPressed: () => bloc.add(CartListSelected(cart: cart)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        cart.product.title,
                        style: textTheme.titleSmall.semiBold?.copyWith(
                          color: colorScheme.contentPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    SvgIconButton(
                      icon: AppIcons.close,
                      color: colorScheme.contentTertiary,
                      onPressed: () =>
                          bloc.add(CartListDeleted(productIds: [productId])),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      child: Image.network(
                        cart.product.imageUrl,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                            width: _imageWidth,
                            height: _imageHeight,
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 24,
                              color: colorScheme.contentFourth,
                            ),
                          );
                        },
                        width: _imageWidth,
                        height: _imageHeight,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cart.product.price.toWon(),
                            style: textTheme.titleMedium.bold?.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          CartCountBtn(
                            quantity: cart.quantity,
                            increased: () =>
                                bloc.add(CartListQtyIncreased(cart: cart)),
                            decreased: () =>
                                bloc.add(CartListQtyDecreased(cart: cart)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}