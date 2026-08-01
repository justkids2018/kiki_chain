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
                  const Positioned.fill(child: _SubscriptionDecorations()),
                  const Positioned(left: 16, top: 12, child: GlassBackButton()),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(28, 48, 28, 24),
                        child: Obx(() {
                          final products = controller.products;
                          return LayoutBuilder(
                            builder: (context, constraints) {
                              final useLandscapeLayout =
                                  constraints.maxWidth >= 680;
                              if (!useLandscapeLayout) {
                                return SingleChildScrollView(
                                  child: _SubscriptionShell(
                                    controller: controller,
                                    products: products,
                                  ),
                                );
                              }

                              return SingleChildScrollView(
                                child: _SubscriptionShell(
                                  controller: controller,
                                  products: products,
                                ),
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

class _SubscriptionDecorations extends StatelessWidget {
  const _SubscriptionDecorations();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          const Positioned(
            left: 116,
            top: 74,
            child: _SoftLeaf(size: 42, angle: -0.35),
          ),
          const Positioned(
            right: 116,
            top: 92,
            child: _SoftLeaf(size: 34, angle: 0.3),
          ),
          const Positioned(
            left: 72,
            bottom: 132,
            child: _SoftLeaf(size: 28, angle: 0.2),
          ),
          const Positioned(
            right: 78,
            bottom: 138,
            child: _SoftLeaf(size: 24, angle: -0.25),
          ),
        ],
      ),
    );
  }
}

class _SoftLeaf extends StatelessWidget {
  final double size;
  final double angle;

  const _SoftLeaf({required this.size, required this.angle});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Icon(
        Icons.eco_rounded,
        size: size,
        color: const Color(0xFF79B95F).withOpacity(0.24),
      ),
    );
  }
}

class _SubscriptionShell extends StatelessWidget {
  final SubscriptionController controller;
  final List<SubscriptionProduct> products;

  const _SubscriptionShell({required this.controller, required this.products});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFFE7DDCC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 760) {
                return Column(
                  children: [
                    _PlanSection(controller: controller, products: products),
                    const SizedBox(height: 16),
                    _PaymentPanel(controller: controller),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 7,
                    child: _PlanSection(
                      controller: controller,
                      products: products,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(child: _PaymentPanel(controller: controller)),
                ],
              );
            },
          ),
        ],
      ),
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
        LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                for (var index = 0; index < products.length; index++) ...[
                  SizedBox(
                    height: 66,
                    width: double.infinity,
                    child: SubscriptionPlanTile(
                      product: products[index],
                      isSelected: controller.selectedProduct.value?.productId ==
                          products[index].productId,
                      onTap: () => controller.selectProduct(products[index]),
                    ),
                  ),
                  if (index < products.length - 1) const SizedBox(height: 10),
                ],
              ],
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
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2E7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9DEC9), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _WechatPaymentLine(),
          const SizedBox(height: 10),
          if (controller.freeSubscriptionNoticeText.isNotEmpty) ...[
            _FreeSubscriptionNotice(
                text: controller.freeSubscriptionNoticeText),
            const SizedBox(height: 10),
          ],
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: controller.isPaying.value
                  ? null
                  : controller.subscribeSelected,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFF4F7DF3),
                disabledBackgroundColor: const Color(0xFFE5E7EB),
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Fredoka',
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
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

class _WechatPaymentLine extends StatelessWidget {
  const _WechatPaymentLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE7DDCC)),
      ),
      child: Row(
        children: [
          const Icon(Icons.chat_bubble_rounded,
              size: 18, color: Color(0xFF22B573)),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              '微信支付',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2D3B31),
              ),
            ),
          ),
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: Color(0xFF22B573),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.check_rounded, size: 13, color: Colors.white),
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
        color: const Color(0xFFEAF6DF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFC8E6B8),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_month_rounded,
            size: 17,
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
