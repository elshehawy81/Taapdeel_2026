import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/ui/common/ps_ui_widget.dart';
import 'package:taapdeel/viewobject/sub_category.dart';

class SubCategoryGridItem extends StatefulWidget {
  const SubCategoryGridItem({
    Key? key,
    required this.subCategory,
    this.onTap,
    this.selected,
    this.onBoarding = false,
    this.animationController,
    this.animation,
    required this.subScribeNoti,
    required this.tempList,
  }) : super(key: key);

  final SubCategory subCategory;
  final GestureTapCallback? onTap;
  final AnimationController? animationController;
  final Animation<double>? animation;
  final List<String?> tempList;
  final bool subScribeNoti;
  final bool? selected;
  final bool onBoarding;

  @override
  State<SubCategoryGridItem> createState() => _SubCategoryGridItemState();
}

class _SubCategoryGridItemState extends State<SubCategoryGridItem> {
  @override
  Widget build(BuildContext context) {
    widget.animationController?.forward();

    final bool isSelected = widget.selected ?? false;

    // هل الفئة لها صورة فعلًا؟
    final bool hasImage = widget.subCategory.defaultIcon != null &&
        widget.subCategory.defaultIcon!.imgPath != null &&
        widget.subCategory.defaultIcon!.imgPath!.isNotEmpty;

    final BorderRadius cardRadius = BorderRadius.circular(16);

    return AnimatedBuilder(
      animation: widget.animationController ?? kAlwaysCompleteAnimation,

      // 👈 هنا هنحوط الكارت كله في SizedBox عشان ندي Stack قيود محددة
      child: SizedBox(
        width: 180,  // عرض ثابت للكارت (مناسب للـ Grid والـ List)
        height: 120, // مماثل تقريبا للي كان بيظهر في اللوج (h ≈ 104–120)

        child: InkWell(
          onTap: widget.onTap,
          borderRadius: cardRadius,
          child: AnimatedScale(
            scale: widget.onBoarding && isSelected ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,

            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(
                horizontal: PsDimens.space6,
                vertical: PsDimens.space8,
              ),
              decoration: BoxDecoration(
                borderRadius: cardRadius,
                color: widget.onBoarding && isSelected
                    ? PsColors.primary500.withValues(alpha: 0.08)
                    : Colors.transparent,
                border: Border.all(
                  color: widget.onBoarding && isSelected
                      ? PsColors.primary900
                      : Colors.white30,
                  width: 2.5,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: PsColors.black.withValues(
                      alpha: widget.onBoarding && isSelected ? 0.14 : 0.08,
                    ),
                    blurRadius: widget.onBoarding && isSelected ? 12 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: cardRadius,
                child: Stack(
                  fit: StackFit.expand, // ⬅️ مهم: خلي الـ Stack يملى مساحة الكارت
                  children: <Widget>[
                    // صورة الفئة / Placeholder
                    Positioned.fill(
                      child: hasImage
                          ? PsNetworkCircleIconImage(
                        photoKey: '',
                        defaultIcon: widget.subCategory.defaultIcon,
                        width: double.infinity,
                        height: double.infinity,
                        boxfit: BoxFit.cover,
                      )
                          : _TaapdeelCategoryPlaceholder(),
                    ),

                    // شريط زجاجي داكن ثابت في الأسفل لزيادة وضوح النص
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            height: 46,
                            padding: const EdgeInsets.symmetric(
                              horizontal: PsDimens.space8,
                              vertical: PsDimens.space6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.70),
                            ),
                            child: Center(
                              child: Text(
                                widget.subCategory.name ?? '',
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15.5,
                                  color: Colors.white,
                                  height: 1.15,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // دائرة الاختيار – تظهر فقط عند الاختيار في الـ onboarding
                    if (widget.onBoarding && isSelected)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const CircleAvatar(
                            radius: 11,
                            backgroundColor: Color(0xFF274F8C),
                            child: Icon(
                              Icons.check,
                              size: 18,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),

      builder: (BuildContext context, Widget? child) {
        final Animation<double> effectiveAnimation =
            widget.animation ?? kAlwaysCompleteAnimation;

        return FadeTransition(
          opacity: effectiveAnimation,
          child: Transform(
            transform: Matrix4.translationValues(
              0.0,
              40 * (1.0 - effectiveAnimation.value),
              0.0,
            ),
            child: child,
          ),
        );
      },
    );
  }
}

// أنيميشن ثابتة في حال عدم وجود controller
const AlwaysStoppedAnimation<double> kAlwaysCompleteAnimation =
AlwaysStoppedAnimation<double>(1.0);

/// Placeholder متناسق مع Taapdeel لو ما فيش صورة للفئة
class _TaapdeelCategoryPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            PsColors.primary500.withValues(alpha: 0.18),
            PsColors.primary900.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.category_rounded,
        color: PsColors.primaryDarkWhite,
        size: 36,
      ),
    );
  }
}
