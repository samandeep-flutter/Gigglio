import 'package:flutter/material.dart';
import 'package:gigglio/services/extension_services.dart';
import '../../data/utils/dimens.dart';
import 'my_cached_image.dart';
import 'top_widgets.dart';

class ImageCarousel extends StatefulWidget {
  final List<String> images;

  const ImageCarousel({super.key, required this.images});

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  final pageContr = PageController();
  late List<String> images;
  int current = 0;

  @override
  void initState() {
    images = widget.images;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (images.length == 1) {
      return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: context.height * .6),
          child: MyCachedImage(images.first,
              width: context.width, fit: BoxFit.fitHeight));
    }

    return Column(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: context.height * .4),
          child: PageView.builder(
              controller: pageContr,
              onPageChanged: (value) => setState(() => current = value),
              itemCount: images.length,
              itemBuilder: (context, index) {
                return MyCachedImage(images[index],
                    width: context.width, fit: BoxFit.fitHeight);
              }),
        ),
        const SizedBox(height: Dimens.sizeMedSmall),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(images.length, (index) {
            return PaginationDots(
              current: current == index,
              onTap: () {
                pageContr.animateToPage(index,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut);
              },
            );
          }),
        )
      ],
    );
  }
}
