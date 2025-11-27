import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/logging/app_logger.dart';
import 'interactive_image_controller.dart';
import 'interactive_image_view.dart';

class InteractiveImagePage extends StatelessWidget {
  const InteractiveImagePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get existing controller or create new one
    final controller = Get.isRegistered<InteractiveImageController>()
        ? Get.find<InteractiveImageController>()
        : Get.put(InteractiveImageController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiki Zhiwuyuan'),
      ),
      body: Obx(() {
        AppLogger.verbose('Page rebuild - loaded: ${controller.isLoaded.value}, error: ${controller.errorMessage.value}');

        // Show error state
        if (controller.errorMessage.value != null && controller.isLoaded.value) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to Load',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    controller.errorMessage.value ?? 'Unknown error',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      controller.onInit();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Show loading state
        if (!controller.isLoaded.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Obx(() => Text(
                  'Loading: ${(controller.loadingProgress.value * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.bodyMedium,
                )),
              ],
            ),
          );
        }

        // Show image with regions
        return Center(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            boundaryMargin: const EdgeInsets.all(20),
            child: InteractiveImageView(
              imagePath: controller.imagePath,  // 使用 controller 中的动态图片路径
              originalWidth: controller.imageWidth.value,
              originalHeight: controller.imageHeight.value,
              regions: controller.regions,
              onRegionTap: controller.speakRegion,
            ),
          ),
        );
      }),
    );
  }
}
