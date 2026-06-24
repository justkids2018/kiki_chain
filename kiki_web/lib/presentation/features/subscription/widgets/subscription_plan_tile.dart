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
    final subtitle = isYearly ? '长期学习更划算' : '低门槛体验';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: isBusy ? null : onTap,
        child: Ink(
          padding: const EdgeInsets.all(16),
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
                    width: 38,
                    height: 38,
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
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                product.displayPrice,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.trialDays > 0 ? '${product.trialDays} 天免费试用' : '立即生效',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black.withOpacity(0.58),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                height: 42,
                alignment: Alignment.center,
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
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    else
                      Icon(
                        Icons.lock_open_rounded,
                        size: 17,
                        color: product.isRecommended
                            ? const Color(0xFF4B2800)
                            : Colors.white,
                      ),
                    const SizedBox(width: 6),
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
            ],
          ),
        ),
      ),
    );
  }
}
