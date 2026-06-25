import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../design_ui/kiki_ui_kit.dart';
import '../../../../domain/entities/subscription.dart';
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
                  const Positioned.fill(child: _BotanicalBackdrop()),
                  const Positioned(left: 16, top: 12, child: GlassBackButton()),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 820),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(28, 58, 28, 28),
                        child: Obx(() {
                          final products = controller.products;
                          return LayoutBuilder(
                            builder: (context, constraints) {
                              final useLandscapeLayout =
                                  constraints.maxWidth >= 680;
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
                                    flex: 7,
                                    child: _PlanSection(
                                      controller: controller,
                                      products: products,
                                    ),
                                  ),
                                  const SizedBox(width: 26),
                                  Expanded(
                                    flex: 5,
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
  final List<SubscriptionProduct> products;

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
                '选择 VIP 套餐',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1F2937),
                  fontFamily: 'Fredoka',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth =
                ((constraints.maxWidth - 16) / 2).clamp(170.0, 238.0);
            return SizedBox(
              height: 188,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.82),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE9DEC9), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SubscriptionBrandHeader(),
          const SizedBox(height: 16),
          const Text(
            '支付方式',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 14),
          _PaymentMethodSelector(controller: controller),
          const SizedBox(height: 20),
          if (controller.freeSubscriptionNoticeText.isNotEmpty) ...[
            _FreeSubscriptionNotice(
              text: controller.freeSubscriptionNoticeText,
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            height: 58,
            child: ElevatedButton(
              onPressed: controller.isPaying.value
                  ? null
                  : controller.subscribeSelected,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFFFFC857),
                disabledBackgroundColor: const Color(0xFFE5E7EB),
                foregroundColor: const Color(0xFF4B2800),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Fredoka',
                ),
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
                      controller.primaryActionText,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Fredoka',
                        height: 1.1,
                      ),
                    ),
            ),
          ),
          if (controller.errorMessage.value.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                '支付前会再次校验价格',
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

class _FreeSubscriptionNotice extends StatelessWidget {
  const _FreeSubscriptionNotice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF8E7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFC8E6B8),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.eco_rounded,
            size: 16,
            color: Color(0xFF4E9F2E),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF37651F),
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BotanicalBackdrop extends StatelessWidget {
  const _BotanicalBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: const [
          Positioned(
            left: 78,
            bottom: 34,
            child: _BackdropLeaf(size: 72, turns: -0.18),
          ),
          Positioned(
            right: 96,
            top: 36,
            child: _BackdropLeaf(size: 60, turns: 0.16),
          ),
          Positioned(
            right: 210,
            bottom: 46,
            child: _BackdropLeaf(size: 42, turns: -0.08),
          ),
        ],
      ),
    );
  }
}

class _BackdropLeaf extends StatelessWidget {
  final double size;
  final double turns;

  const _BackdropLeaf({
    required this.size,
    required this.turns,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: turns,
      child: Icon(
        Icons.eco_rounded,
        size: size,
        color: const Color(0xFF6DBF4A).withOpacity(0.055),
      ),
    );
  }
}

class _SubscriptionBrandHeader extends StatelessWidget {
  const _SubscriptionBrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFD8D2C8), width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(
              'assets/icon/app_icon.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Hi Kiki VIP',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1F2937),
              height: 1.1,
              fontFamily: 'Fredoka',
            ),
          ),
        ),
      ],
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
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF48C774)
                  : const Color(0xFFE5E7EB),
              width: isSelected ? 1.6 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFF48C774).withOpacity(0.16),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.chat_bubble_rounded,
                  size: 18,
                  color: Color(0xFF2BA84A),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                option.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1F2937),
                  fontFamily: 'Fredoka',
                ),
              ),
              const Spacer(),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF48C774)
                        : const Color(0xFFD1D5DB),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Center(
                        child: Icon(
                          Icons.circle,
                          size: 12,
                          color: Color(0xFF48C774),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
