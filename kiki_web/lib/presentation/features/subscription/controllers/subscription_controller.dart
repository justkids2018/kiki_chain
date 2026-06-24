import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/services/payment/payment_manager.dart';
import '../../../../domain/entities/subscription.dart';
import '../../../../domain/repositories/i_subscription_repository.dart';

class SubscriptionController extends GetxController {
  SubscriptionController({
    ISubscriptionRepository? subscriptionRepository,
    PaymentManager? paymentManager,
  })  : _subscriptionRepository = subscriptionRepository ??
            ServiceLocator.instance.subscriptionRepository,
        _paymentManager = paymentManager ?? PaymentManager();

  final ISubscriptionRepository _subscriptionRepository;
  final PaymentManager _paymentManager;

  final RxBool isLoading = false.obs;
  final RxBool isPaying = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<ProductsResult> productsResult = Rxn<ProductsResult>();
  final Rxn<VipEntitlement> entitlement = Rxn<VipEntitlement>();

  late final ClientPaymentContext paymentContext;

  List<SubscriptionProduct> get products {
    final remoteProducts = productsResult.value?.products ?? const [];
    return remoteProducts.isEmpty ? defaultProducts : remoteProducts;
  }

  bool get isUsingFallbackProducts =>
      (productsResult.value?.products ?? const []).isEmpty;

  static const List<SubscriptionProduct> defaultProducts = [
    SubscriptionProduct(
      productId: 'kiki_vip_monthly',
      title: '月支付',
      period: SubscriptionPeriod.monthly,
      priceCents: 990,
      currency: 'CNY',
      displayPrice: '¥9.9/月',
      trialDays: 0,
      isRecommended: false,
    ),
    SubscriptionProduct(
      productId: 'kiki_vip_yearly',
      title: '年支付',
      period: SubscriptionPeriod.yearly,
      priceCents: 8800,
      currency: 'CNY',
      displayPrice: '¥88/年',
      trialDays: 3,
      isRecommended: true,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    paymentContext = ClientPaymentContext.current();
    load();
  }

  Future<void> load() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final result = await _subscriptionRepository.getProducts(
        region: paymentContext.region,
        platform: paymentContext.platform,
        distributionChannel: paymentContext.distributionChannel,
      );
      productsResult.value = result;
      try {
        entitlement.value = await _subscriptionRepository.getEntitlement();
      } catch (_) {
        entitlement.value = null;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load subscription products', e, stackTrace);
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> subscribe(SubscriptionProduct product) async {
    if (isPaying.value) return;

    try {
      isPaying.value = true;
      EasyLoading.show(status: '正在创建订单...');

      final order = await _subscriptionRepository.createOrder(
        productId: product.productId,
        region: paymentContext.region,
        platform: paymentContext.platform,
        distributionChannel: paymentContext.distributionChannel,
      );

      EasyLoading.show(status: '正在拉起支付...');
      final paymentResult =
          await _paymentManager.pay(order: order, product: product);

      if (!paymentResult.success) {
        EasyLoading.showError(paymentResult.message);
        return;
      }

      EasyLoading.show(status: '正在确认权益...');
      final vip = await _subscriptionRepository.confirmOrder(
        orderId: order.orderId,
        purchaseToken: paymentResult.purchaseToken,
        sandbox: true,
      );
      entitlement.value = vip;
      EasyLoading.showSuccess('VIP 已解锁');
      Get.back(result: vip);
    } catch (e, stackTrace) {
      AppLogger.error('Subscription payment failed', e, stackTrace);
      EasyLoading.showError(e.toString());
    } finally {
      isPaying.value = false;
    }
  }
}
