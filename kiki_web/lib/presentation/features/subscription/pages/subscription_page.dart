import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../design_ui/kiki_ui_kit.dart';
import '../../../widgets/glass_back_button.dart';
import '../controllers/subscription_controller.dart';
import '../widgets/subscription_plan_tile.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SubscriptionController>(
      init: SubscriptionController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: KikiUiColors.pageBackground,
          body: Container(
            decoration: KikiUiDecor.pageBackgroundDecor,
            child: SafeArea(
              child: Stack(
                children: [
                  const Positioned(left: 16, top: 12, child: GlassBackButton()),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 62, 24, 24),
                        child: Obx(() {
                          final products = controller.products;
                          return LayoutBuilder(
                            builder: (context, constraints) {
                              final useLandscapeLayout =
                                  constraints.maxWidth >= 620;
                              if (!useLandscapeLayout) {
                                return SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _PlanSection(
                                        controller: controller,
                                        products: products,
                                      ),
                                      const SizedBox(height: 18),
                                      _PaymentPanel(controller: controller),
                                    ],
                                  ),
                                );
                              }

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: _PlanSection(
                                      controller: controller,
                                      products: products,
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    flex: 4,
                                    child: _PaymentPanel(
                                      controller: controller,
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        }),
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
  }
}

class _PlanSection extends StatelessWidget {
  final SubscriptionController controller;
  final List<dynamic> products;

  const _PlanSection({
    required this.controller,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                '选择套餐',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
            if (controller.isLoading.value)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2.2),
              ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth =
                ((constraints.maxWidth - 14) / 2).clamp(160.0, 230.0);
            return SizedBox(
              height: 182,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return SizedBox(
                    width: cardWidth,
                    child: SubscriptionPlanTile(
                      product: product,
                      isSelected: controller.selectedProduct.value?.productId ==
                          product.productId,
                      onTap: () => controller.selectProduct(product),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _PaymentPanel extends StatelessWidget {
  final SubscriptionController controller;

  const _PaymentPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    final selectedProduct = controller.selectedProduct.value;
    final price = selectedProduct?.displayPrice ?? '';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.82),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE7DFD4), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '支付方式',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          _PaymentMethodSelector(controller: controller),
          const SizedBox(height: 18),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: controller.isPaying.value
                  ? null
                  : controller.subscribeSelected,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFFFFC857),
                disabledBackgroundColor: const Color(0xFFE5E7EB),
                foregroundColor: const Color(0xFF4B2800),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: controller.isPaying.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Color(0xFF4B2800),
                      ),
                    )
                  : Text(
                      price.isEmpty ? '确认支付' : '确认支付 $price',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
            ),
          ),
          if (controller.errorMessage.value.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                '价格会在支付时再次校验',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withOpacity(0.54),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PaymentMethodSelector extends StatelessWidget {
  final SubscriptionController controller;

  const _PaymentMethodSelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    final options = controller.paymentOptions;
    final selected = controller.selectedPaymentOption.value;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final option in options)
          _PaymentMethodButton(
            option: option,
            isSelected: selected?.channel == option.channel,
            onTap: () => controller.selectPaymentOption(option),
          ),
      ],
    );
  }
}

class _PaymentMethodButton extends StatelessWidget {
  final PaymentOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodButton({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFF2C7) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFFFC857)
                  : const Color(0xFFE5E7EB),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chat_bubble_rounded,
                size: 18,
                color: isSelected
                    ? const Color(0xFF8A4A00)
                    : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 7),
              Text(
                option.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: isSelected
                      ? const Color(0xFF4B2800)
                      : const Color(0xFF374151),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
