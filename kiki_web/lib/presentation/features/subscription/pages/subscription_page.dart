import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../design_ui/kiki_ui_kit.dart';
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
                  Positioned(
                    left: 12,
                    top: 8,
                    child: IconButton(
                      tooltip: '返回',
                      onPressed: Get.back,
                      icon: const Icon(Icons.arrow_back_ios_new),
                    ),
                  ),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 620),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 46, 24, 24),
                        child: Obx(() {
                          final products = controller.products;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const _VipAvatarHeader(),
                              const SizedBox(height: 26),
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      '选择套餐',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF1F2937),
                                      ),
                                    ),
                                  ),
                                  if (controller.isLoading.value)
                                    const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final cardWidth =
                                      ((constraints.maxWidth - 14) / 2)
                                          .clamp(156.0, 248.0);
                                  return SizedBox(
                                    height: 178,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: products.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(width: 14),
                                      itemBuilder: (context, index) {
                                        final product = products[index];
                                        return SizedBox(
                                          width: cardWidth,
                                          child: SubscriptionPlanTile(
                                            product: product,
                                            isSelected: controller
                                                    .selectedProduct
                                                    .value
                                                    ?.productId ==
                                                product.productId,
                                            onTap: () => controller
                                                .selectProduct(product),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              _PaymentMethodSelector(controller: controller),
                              const SizedBox(height: 14),
                              SizedBox(
                                height: 46,
                                child: ElevatedButton(
                                  onPressed: controller.isPaying.value
                                      ? null
                                      : controller.subscribeSelected,
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: const Color(0xFFFFC857),
                                    disabledBackgroundColor:
                                        const Color(0xFFE5E7EB),
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
                                      : const Text(
                                          '开通 VIP',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                ),
                              ),
                              if (controller.errorMessage.value.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    '暂时使用默认价格，支付时会再次校验渠道',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black.withOpacity(0.54),
                                    ),
                                  ),
                                ),
                            ],
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

class _PaymentMethodSelector extends StatelessWidget {
  final SubscriptionController controller;

  const _PaymentMethodSelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    final options = controller.paymentOptions;
    final selected = controller.selectedPaymentOption.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '支付方式',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
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
                option.icon,
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

class _VipAvatarHeader extends StatelessWidget {
  const _VipAvatarHeader();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 104,
        height: 104,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFE08A), Color(0xFFFFB340)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Image.asset(
                      'assets/icon/app_icon.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: -4,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC857),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Text(
                  'VIP',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF4B2800),
                    height: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
