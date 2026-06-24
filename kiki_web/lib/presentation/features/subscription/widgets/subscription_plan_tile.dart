import 'package:flutter/material.dart';

import '../../../../domain/entities/subscription.dart';

class SubscriptionPlanTile extends StatelessWidget {
  final SubscriptionProduct product;
  final bool isBusy;
  final VoidCallback onTap;

  const SubscriptionPlanTile({
    Key? key,
    required this.product,
    required this.isBusy,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isYearly = product.period == SubscriptionPeriod.yearly;
    final title = isYearly ? '年支付' : '月支付';
    final note = product.trialDays > 0 ? '${product.trialDays} 天试用' : '立即生效';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: isBusy ? null : onTap,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: product.isRecommended
                ? const Color(0xFFFFF7D8)
                : Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: product.isRecommended
                  ? const Color(0xFFFFC857)
                  : const Color(0xFFE5E7EB),
              width: product.isRecommended ? 1.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: product.isRecommended
                          ? const Color(0xFFFFE08A)
                          : const Color(0xFFEAF0FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isYearly
                          ? Icons.workspace_premium_rounded
                          : Icons.calendar_month_rounded,
                      color: product.isRecommended
                          ? const Color(0xFF8A4A00)
                          : const Color(0xFF2F6BFF),
                    ),
                  ),
                  const Spacer(),
                  if (product.isRecommended)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC857),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '推荐',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF5A3300),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 34,
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    product.displayPrice,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                      height: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 14,
                    color: product.isRecommended
                        ? const Color(0xFF8A4A00)
                        : const Color(0xFF2F6BFF),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      note,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withOpacity(0.58),
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                height: 38,
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: product.isRecommended
                        ? const Color(0xFFFFC857)
                        : const Color(0xFF2F6BFF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isBusy)
                        const SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      else
                        Icon(
                          Icons.lock_open_rounded,
                          size: 16,
                          color: product.isRecommended
                              ? const Color(0xFF4B2800)
                              : Colors.white,
                        ),
                      const SizedBox(width: 5),
                      Text(
                        isBusy ? '处理中' : '开通',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: product.isRecommended
                              ? const Color(0xFF4B2800)
                              : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
