import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/services/payment/payment_manager.dart';
import '../../../../domain/entities/subscription.dart';
import '../../../../domain/repositories/i_subscription_repository.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/home_controller.dart';

class SubscriptionController extends GetxController {
  SubscriptionController({
    ISubscriptionRepository? subscriptionRepository,
    PaymentManager? paymentManager,
    DateTime Function()? now,
  })  : _subscriptionRepository = subscriptionRepository ??
            ServiceLocator.instance.subscriptionRepository,
        _paymentManager = paymentManager ?? PaymentManager(),
        _now = now ?? DateTime.now;

  final ISubscriptionRepository _subscriptionRepository;
  final PaymentManager _paymentManager;
  final DateTime Function() _now;

  final RxBool isLoading = false.obs;
  final RxBool isPaying = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<ProductsResult> productsResult = Rxn<ProductsResult>();
  final Rxn<VipEntitlement> entitlement = Rxn<VipEntitlement>();
  final Rxn<SubscriptionProduct> selectedProduct = Rxn<SubscriptionProduct>();
  final Rxn<PaymentOption> selectedPaymentOption = Rxn<PaymentOption>();
  bool _hasUserSelectedProduct = false;

  late final ClientPaymentContext paymentContext;

  static final DateTime _freeSubscriptionDeadline =
      DateTime(2026, 8, 1);

  bool get isFreeSubscriptionPeriod =>
      _now().isBefore(_freeSubscriptionDeadline);

  String get freeSubscriptionNoticeText {
    if (!isFreeSubscriptionPeriod) return '';
    return '限时体验：2026年8月1日前免费开通 VIP';
  }

  String get primaryActionText {
    if (isFreeSubscriptionPeriod) {
      return '免费订阅 ¥0';
    }
    final product = selectedProduct.value;
    final price = _formatPayAmount(product?.displayPrice ?? '');
    return price.isEmpty ? '确认支付' : '确认并支付 $price';
  }

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
    selectedPaymentOption.value = paymentOptions.first;
    _ensureDefaultSelection();
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
      _ensureDefaultSelection();
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

  List<PaymentOption> get paymentOptions {
    return const [
      PaymentOption(
        channel: PaymentChannel.wechatPay,
        label: '微信支付',
        platform: 'android',
        distributionChannel: 'direct_apk',
      ),
    ];
  }

  void selectProduct(SubscriptionProduct product) {
    _hasUserSelectedProduct = true;
    selectedProduct.value = product;
    selectedProduct.refresh();
    update();
  }

  void selectPaymentOption(PaymentOption option) {
    selectedPaymentOption.value = option;
  }

  Future<void> subscribeSelected() async {
    final product = selectedProduct.value;
    if (product == null) {
      EasyLoading.showToast('请选择套餐');
      return;
    }
    await subscribe(product);
  }

  Future<void> subscribe(SubscriptionProduct product) async {
    if (isPaying.value) return;

    try {
      isPaying.value = true;
      EasyLoading.show(status: '正在创建订单...');
      final paymentOption = selectedPaymentOption.value ?? paymentOptions.first;

      final order = await _subscriptionRepository.createOrder(
        productId: product.productId,
        region: paymentOption.region,
        platform: paymentOption.platform,
        distributionChannel: paymentOption.distributionChannel,
      );

      String? purchaseToken;
      if (isFreeSubscriptionPeriod) {
        EasyLoading.show(status: '正在开通免费订阅...');
        purchaseToken = 'free_before_2026_08_01_${order.orderId}';
      } else {
        EasyLoading.show(status: '正在拉起支付...');
        final paymentResult =
            await _paymentManager.pay(order: order, product: product);

        if (!paymentResult.success) {
          EasyLoading.showError(paymentResult.message);
          return;
        }
        purchaseToken = paymentResult.purchaseToken;
      }

      EasyLoading.show(status: '正在确认权益...');
      final vip = await _subscriptionRepository.confirmOrder(
        orderId: order.orderId,
        purchaseToken: purchaseToken,
        sandbox: true,
      );
      entitlement.value = vip;
      await _syncVipEntitlement(vip);
      EasyLoading.showSuccess('VIP 已解锁');
      Get.back(result: vip);
    } catch (e, stackTrace) {
      AppLogger.error('Subscription payment failed', e, stackTrace);
      EasyLoading.showError(e.toString());
    } finally {
      isPaying.value = false;
    }
  }

  void _ensureDefaultSelection() {
    if (products.isEmpty) return;
    final selected = selectedProduct.value;
    if (_hasUserSelectedProduct &&
        selected != null &&
        products.any((product) => product.productId == selected.productId)) {
      return;
    }

    selectedProduct.value = products.firstWhere(
      (product) => product.period == SubscriptionPeriod.yearly,
      orElse: () => products.firstWhere(
        (product) => product.isRecommended,
        orElse: () => products.first,
      ),
    );
    selectedPaymentOption.value ??= paymentOptions.first;
  }

  Future<void> _syncVipEntitlement(VipEntitlement vip) async {
    if (!vip.isVip) return;

    try {
      final authController = Get.find<AuthController>();
      authController.applyVipEntitlement(
        isVip: vip.isVip,
        vipExpireAt: vip.vipExpireAt,
      );
    } catch (e, stackTrace) {
      AppLogger.warning('Failed to sync VIP to auth controller', e, stackTrace);
    }

    if (!Get.isRegistered<HomeController>()) return;
    try {
      await Get.find<HomeController>().refreshAfterSubscription(vip);
    } catch (e, stackTrace) {
      AppLogger.warning(
        'Failed to refresh home after subscription',
        e,
        stackTrace,
      );
    }
  }

  String _formatPayAmount(String displayPrice) {
    if (displayPrice.isEmpty) return '';
    return displayPrice.split('/').first.trim();
  }
}

class PaymentOption {
  final PaymentChannel channel;
  final String label;
  final String region;
  final String platform;
  final String distributionChannel;

  const PaymentOption({
    required this.channel,
    required this.label,
    this.region = 'cn',
    required this.platform,
    required this.distributionChannel,
  });
}
