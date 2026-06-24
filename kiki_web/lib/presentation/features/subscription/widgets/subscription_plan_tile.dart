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
    final title = isYearly ? '年付' : '月包';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFFFF4CF)
                : Colors.white.withOpacity(0.94),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFFFC857)
                  : const Color(0xFFE5E7EB),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? const Color(0xFFFFC857).withOpacity(0.22)
                    : Colors.black.withOpacity(0.05),
                blurRadius: isSelected ? 20 : 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFFC857)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFFC857)
                          : const Color(0xFFD1D5DB),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 15,
                          color: Color(0xFF4B2800),
                        )
                      : null,
                ),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 46,
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    product.displayPrice,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                      height: 1,
                    ),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
