import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../core/theme/app_colors.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  // ================= IMAGES =================

  final List<String> images = const [
    'assets/images/plant.jpeg',
    'assets/images/recycle.jpg',
    'assets/images/water.jpeg',
    'assets/images/plastic.jpeg',
    'assets/images/light.jpeg',
  ];

  // ================= IMAGE NAMES =================

  final List<String> imageNames = const [
    'Plantation',
    'Recycling',
    'Save Water',
    'Reduce Plastic',
    'Save Electricity',
  ];

  // ================= VIDEOS =================

  final List<String> videos = const [
    'assets/images/plant.mp4',
    'assets/images/recycling.mp4',
    'assets/images/water.mp4',
    'assets/images/plastic.mp4',
    'assets/images/lighting.mp4',
  ];

  // ================= VIDEO NAMES =================

  final List<String> videoNames = const [
    'Plantation Awareness',
    'Recycling Awareness',
    'Water Conservation',
    'Plastic Pollution',
    'Energy Saving',
  ];

  // ================= VIDEO THUMBNAILS =================

  final List<String> videoThumbnails = const [
    'assets/images/plant.jpeg',
    'assets/images/recycle.jpg',
    'assets/images/water.jpeg',
    'assets/images/plastic.jpeg',
    'assets/images/light.jpeg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Awareness Gallery'),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // =====================================================
            // LEFT SIDE - GALLERY IMAGES
            // =====================================================

            Expanded(
              child: Column(
                children: [

                  const Text(
                    'Gallery Images',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Expanded(
                    child: ListView.separated(
                      itemCount: images.length,

                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 12);
                      },

                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,

                              builder: (context) {
                                return Dialog(
                                  backgroundColor: Colors.transparent,

                                  child: Stack(
                                    children: [

                                      // FULL IMAGE
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(20),

                                        child: Image.asset(
                                          images[index],
                                          fit: BoxFit.contain,

                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              height: 300,
                                              color: AppColors.surface,

                                              child: const Center(
                                                child: Icon(
                                                  Icons.broken_image,
                                                  size: 60,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),

                                      // CLOSE BUTTON
                                      Positioned(
                                        top: 8,
                                        right: 8,

                                        child: IconButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },

                                          icon: const CircleAvatar(
                                            backgroundColor: Colors.white,

                                            child: Icon(
                                              Icons.close,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },

                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),

                            child: Stack(
                              children: [

                                // IMAGE
                                SizedBox(
                                  height: 140,
                                  width: double.infinity,

                                  child: Image.asset(
                                    images[index],
                                    fit: BoxFit.cover,

                                    errorBuilder:
                                        (context, error, stackTrace) {
                                      return Container(
                                        color: AppColors.surface,

                                        child: const Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            size: 50,
                                            color:
                                                AppColors.textSecondary,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                // DARK GRADIENT
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,

                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withValues(
                                            alpha: 0.7,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // IMAGE NAME
                                Positioned(
                                  bottom: 10,
                                  left: 12,
                                  right: 12,

                                  child: Text(
                                    imageNames[index],

                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // =====================================================
            // RIGHT SIDE - VIDEOS
            // =====================================================

            Expanded(
              child: Column(
                children: [

                  const Text(
                    'Awareness Videos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Expanded(
                    child: ListView.separated(
                      itemCount: videos.length,

                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 12);
                      },

                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,

                              builder: (context) {
                                return VideoPopup(
                                  videoPath: videos[index],
                                );
                              },
                            );
                          },

                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),

                            child: Container(
                              height: 140,
                              width: double.infinity,
                              color: AppColors.surface,

                              child: Stack(
                                children: [

                                  // VIDEO THUMBNAIL
                                  Positioned.fill(
                                    child: Image.asset(
                                      videoThumbnails[index],
                                      fit: BoxFit.cover,

                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          color: AppColors.surface,

                                          child: const Center(
                                            child: Icon(
                                              Icons.video_library,
                                              size: 55,
                                              color:
                                                  AppColors.textSecondary,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  // DARK OVERLAY
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,

                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withValues(
                                              alpha: 0.75,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // PLAY BUTTON
                                  Center(
                                    child: Container(
                                      width: 58,
                                      height: 58,

                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),

                                      child: const Icon(
                                        Icons.play_arrow,
                                        size: 38,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),

                                  // VIDEO NAME
                                  Positioned(
                                    bottom: 10,
                                    left: 12,
                                    right: 12,

                                    child: Text(
                                      videoNames[index],

                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
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

// =============================================================
// VIDEO POPUP
// =============================================================

class VideoPopup extends StatefulWidget {
  final String videoPath;

  const VideoPopup({
    super.key,
    required this.videoPath,
  });

  @override
  State<VideoPopup> createState() => _VideoPopupState();
}

class _VideoPopupState extends State<VideoPopup> {
  late VideoPlayerController controller;

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.asset(
      widget.videoPath,
    );

    controller.initialize().then((_) {
      if (mounted) {
        setState(() {});
        controller.play();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(20),

      child: SizedBox(
        width: 600,
        height: 420,

        child: Stack(
          children: [

            // VIDEO
            Positioned.fill(
              child: Center(
                child: controller.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: controller.value.aspectRatio,
                        child: VideoPlayer(controller),
                      )
                    : const CircularProgressIndicator(
                        color: Colors.white,
                      ),
              ),
            ),

            // CLOSE BUTTON
            Positioned(
              top: 10,
              right: 10,

              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },

                icon: const CircleAvatar(
                  backgroundColor: Colors.white,

                  child: Icon(
                    Icons.close,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            // PLAY / PAUSE BUTTON
            Positioned(
              bottom: 15,
              left: 0,
              right: 0,

              child: IconButton(
                iconSize: 50,
                color: Colors.white,

                icon: Icon(
                  controller.value.isPlaying
                      ? Icons.pause_circle
                      : Icons.play_circle,
                ),

                onPressed: () {
                  setState(() {
                    if (controller.value.isPlaying) {
                      controller.pause();
                    } else {
                      controller.play();
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}