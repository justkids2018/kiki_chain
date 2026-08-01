import 'package:flutter/material.dart';

import '../../../../domain/entities/subscription.dart';

class SubscriptionPlanTile extends StatelessWidget {
  final SubscriptionProduct product;
  final bool isSelected;
  final VoidCallback onTap;

  const SubscriptionPlanTile({
    Key? key,
    required this.product,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isYearly = product.period == SubscriptionPeriod.yearly;
    final title = isYearly ? '年付' : '月付';
    final priceParts = _splitDisplayPrice(product.displayPrice);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.0 : 0.985,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.fromLTRB(17, 14, 17, 15),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFFF1C4)
                    : const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFF0B63A)
                      : const Color(0xFFE7DDCC),
                  width: isSelected ? 2.2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? const Color(0xFFF0B63A).withOpacity(0.22)
                        : const Color(0xFF6C4A20).withOpacity(0.06),
                    blurRadius: isSelected ? 18 : 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2D3B31),
                        fontFamily: 'Fredoka',
                      ),
                    ),
                  ),
                  Text(
                    priceParts.amount,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF233126),
                      fontFamily: 'Fredoka',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF4F7DF3)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF4F7DF3)
                            : const Color(0xFFD8CEBD),
                        width: 1.8,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check_rounded,
                            size: 15, color: Colors.white)
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceParts {
  final String amount;
  final String unit;

  const _PriceParts(this.amount, this.unit);
}

_PriceParts _splitDisplayPrice(String displayPrice) {
  final parts = displayPrice.split('/');
  if (parts.length < 2) {
    return _PriceParts(displayPrice, '');
  }
  return _PriceParts(parts.first.trim(), '/${parts.sublist(1).join('/')}');
}
