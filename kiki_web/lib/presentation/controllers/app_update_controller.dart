import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/app_update_info.dart';
import '../../data/services/app_update_service.dart';
import '../../core/utils/app_toast.dart';
import '../widgets/gradient_button.dart';

/// App 版本更新控制器
class AppUpdateController extends GetxController {
  final AppUpdateService _updateService = AppUpdateService();

  final RxBool isChecking = false.obs;
  final RxBool isDownloading = false.obs;
  final RxDouble downloadProgress = 0.0.obs;
  final Rxn<AppUpdateInfo> updateInfo = Rxn<AppUpdateInfo>();
  final RxString downloadedApkPath = ''.obs;
  final RxBool hasLocalApk = false.obs;
  OverlayEntry? _updateOverlayEntry;
  OverlayEntry? _installOverlayEntry;
  bool _isUpdateDialogShowing = false;
  bool _isInstallDialogShowing = false;

  /// 检查更新
  Future<void> checkUpdateOnStartup({
    bool forceCheck = false,
    bool Function()? canShowDialog,
  }) async {
    try {
      isChecking.value = true;
      final info = await _updateService.checkUpdate(forceCheck: forceCheck);

      if (info != null) {
        if (canShowDialog != null && !canShowDialog()) {
          debugPrint('[AppUpdateController] 页面已离开首页，跳过更新弹窗');
          return;
        }

        updateInfo.value = info;
        hasLocalApk.value = await _updateService.hasLocalApk(info.version);
        _showUpdateDialog(info, canShowDialog: canShowDialog);
      }
    } catch (e) {
      debugPrint('[AppUpdateController] 检查更新失败: $e');
    } finally {
      isChecking.value = false;
    }
  }

  void _showUpdateDialog(AppUpdateInfo info, {bool Function()? canShowDialog}) {
    Future.delayed(const Duration(milliseconds: 500), () {
      try {
        if (canShowDialog != null && !canShowDialog()) {
          debugPrint('[AppUpdateController] 页面已离开首页，跳过更新弹窗');
          return;
        }

        // 检查上下文是否有效且已挂载
        if (Get.context == null || !Get.context!.mounted) {
          debugPrint('[AppUpdateController] 上下文无效，跳过弹窗');
          return;
        }

        if (_isUpdateDialogShowing || _isInstallDialogShowing) {
          debugPrint('[AppUpdateController] 已有弹窗打开，跳过');
          return;
        }

        final overlay = Overlay.of(Get.context!, rootOverlay: true);
        _isUpdateDialogShowing = true;
        _updateOverlayEntry = OverlayEntry(
          builder: (_) => Material(
            color: Colors.black.withOpacity(0.35),
            child: Center(
              child: WillPopScope(
                onWillPop: () async => false,
                child: AppUpdateDialog(
                  updateInfo: info,
                  onUpdate: () => downloadAndInstall(info),
                  onCancel: _closeCurrentDialog,
                ),
              ),
            ),
          ),
        );
        overlay.insert(_updateOverlayEntry!);
      } catch (e) {
        _clearUpdateOverlay();
        debugPrint('[AppUpdateController] 弹窗显示失败: $e');
      }
    });
  }

  Future<void> downloadAndInstall(AppUpdateInfo info) async {
    try {
      if (isDownloading.value) {
        return;
      }

      if (hasLocalApk.value) {
        final localPath = await _updateService.getLocalApkPath(info.version);
        if (localPath != null) {
          await _closeCurrentDialog();
          await _showInstallDialog(localPath, info.version);
          return;
        }
      }

      isDownloading.value = true;
      downloadProgress.value = 0.0;

      final apkPath = await _updateService.downloadApk(
        info.downloadUrl,
        version: info.version,
        onProgress: (received, total) {
          downloadProgress.value = received / total;
        },
      );

      if (apkPath != null) {
        downloadedApkPath.value = apkPath;
        await _closeCurrentDialog();
        await _showInstallDialog(apkPath, info.version);
      } else {
        await _closeCurrentDialog();
        AppToast.showCenterBottom('无法下载更新包，请稍后重试');
      }
    } catch (e) {
      debugPrint('[AppUpdateController] 下载失败: $e');
      await _closeCurrentDialog();
      AppToast.showCenterBottom('下载失败');
    } finally {
      isDownloading.value = false;
      downloadProgress.value = 0.0;
    }
  }

  Future<void> _closeCurrentDialog() async {
    _clearUpdateOverlay();
    _clearInstallOverlay();
    await Future<void>.delayed(const Duration(milliseconds: 16));
  }

  void _clearUpdateOverlay() {
    _updateOverlayEntry?.remove();
    _updateOverlayEntry = null;
    _isUpdateDialogShowing = false;
  }

  void _clearInstallOverlay() {
    _installOverlayEntry?.remove();
    _installOverlayEntry = null;
    _isInstallDialogShowing = false;
  }

  Future<void> _showInstallDialog(String apkPath, String version) async {
    if (_isInstallDialogShowing || _isUpdateDialogShowing) {
      debugPrint('[AppUpdateController] 已有弹窗打开，跳过安装弹窗');
      return;
    }

    // 延迟执行，避免 Overlay 冲突
    await Future<void>.delayed(const Duration(milliseconds: 300));
    try {
      // 检查上下文
      if (Get.context == null || !Get.context!.mounted) {
        debugPrint('[AppUpdateController] 安装弹窗：上下文无效');
        return;
      }

      final overlay = Overlay.of(Get.context!, rootOverlay: true);
      _isInstallDialogShowing = true;
      _installOverlayEntry = OverlayEntry(
        builder: (_) => Material(
          color: Colors.black.withOpacity(0.35),
          child: Center(
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: 320,
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: const Color(0xFF8BC34A), width: 6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: _closeCurrentDialog,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              color: Color(0xFF8BC34A), size: 18),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 90, 20, 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('下载完成',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333))),
                          const SizedBox(height: 8),
                          Text('版本 $version 已准备好',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey.shade600)),
                          const Spacer(),
                          Row(
                            children: [
                              Expanded(
                                  child: GradientButton(
                                      text: '稍后',
                                      isPrimary: false,
                                      onTap: _closeCurrentDialog)),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: GradientButton(
                                  text: '立即安装',
                                  onTap: () async {
                                    await _closeCurrentDialog();
                                    installApk(apkPath);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: -40,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF9E6),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFF8BC34A), width: 4),
                          ),
                          child: const Icon(Icons.check_circle_outline,
                              color: Color(0xFF8BC34A), size: 50),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      overlay.insert(_installOverlayEntry!);
    } catch (e) {
      _clearInstallOverlay();
      debugPrint('[AppUpdateController] 安装弹窗显示失败: $e');
    }
  }

  Future<void> installApk(String apkPath) async {
    final success = await _updateService.installApk(apkPath);
    if (!success) {
      AppToast.showCenterBottom('安装失败，请手动安装');
    }
  }
}

/// App 更新弹窗
class AppUpdateDialog extends StatelessWidget {
  final AppUpdateInfo updateInfo;
  final VoidCallback onUpdate;
  final VoidCallback onCancel;

  const AppUpdateDialog({
    Key? key,
    required this.updateInfo,
    required this.onUpdate,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 320,
        height: 300,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9E6),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFF8BC34A), width: 6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: onCancel,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close,
                      color: Color(0xFF8BC34A), size: 18),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'v${updateInfo.version}',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333)),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        updateInfo.updateContent,
                        style: TextStyle(
                            fontSize: 11,
                            height: 1.4,
                            color: Colors.grey.shade700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GetX<AppUpdateController>(
                    init: Get.find<AppUpdateController>(),
                    builder: (controller) {
                      if (controller.isDownloading.value) {
                        return Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor:
                                      controller.downloadProgress.value,
                                  child: Container(
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF8BC34A),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${(controller.downloadProgress.value * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                  fontSize: 10, color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 12),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  GetX<AppUpdateController>(
                    init: Get.find<AppUpdateController>(),
                    builder: (controller) {
                      final buttonText = controller.hasLocalApk.value
                          ? '立即安装'
                          : (controller.isDownloading.value ? '下载中' : '立即下载');

                      return Row(
                        children: [
                          Expanded(
                            child: GradientButton(
                              text: '取消',
                              isPrimary: false,
                              isDisabled: controller.isDownloading.value,
                              onTap: onCancel,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: GradientButton(
                              text: buttonText,
                              isDisabled: controller.isDownloading.value,
                              onTap: onUpdate,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              top: -40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9E6),
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: const Color(0xFF8BC34A), width: 4),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 55,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFB74D),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                        child: const Icon(Icons.download,
                            color: Color(0xFF8BC34A), size: 28),
                      ),
                      Positioned(
                        top: 12,
                        child: Container(
                          width: 36,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                      width: 3,
                                      height: 3,
                                      decoration: const BoxDecoration(
                                          color: Colors.black,
                                          shape: BoxShape.circle)),
                                  const SizedBox(width: 6),
                                  Container(
                                      width: 3,
                                      height: 3,
                                      decoration: const BoxDecoration(
                                          color: Colors.black,
                                          shape: BoxShape.circle)),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Container(
                                width: 12,
                                height: 6,
                                decoration: const BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.black, width: 1.5)),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  ),
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
            ),
          ],
        ),
      ),
    );
  }
}
