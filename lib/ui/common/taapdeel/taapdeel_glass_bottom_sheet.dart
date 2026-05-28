import 'dart:ui';
import 'package:flutter/material.dart';

class TaapdeelGlassBottomSheet extends StatelessWidget {
  const TaapdeelGlassBottomSheet({
    Key? key,
    required this.child,

    this.padding = const EdgeInsets.fromLTRB(20, 18, 20, 26),
    this.showHandle = true,
    this.bottomBar,
  }) : super(key: key);

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool showHandle;

  /// ✅ Sticky Action Bar (اختياري)
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) {
    final double safeBottom = MediaQuery.of(context).padding.bottom;

    // ✅ Controller عشان الـ Scrollbar يشتغل صح
    final ScrollController scrollController = ScrollController();

    return Container(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  Colors.white.withOpacity(1),
                  const Color(0xFFE0F1FF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.75),
                width: 1.2,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 40,
                  offset: const Offset(0, -20),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ✅ Scrollable content
                  Flexible(
                    child: Padding(
                      padding: padding,
                      child: Scrollbar(
                        controller: scrollController,
                        thickness: 3, // ✅ خفيف
                        radius: const Radius.circular(999),
                        thumbVisibility: false, // يظهر وقت السحب فقط
                        child: SingleChildScrollView(
                          controller: scrollController,
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              if (showHandle)
                                Container(
                                  width: 60,
                                  height: 4,
                                  margin: const EdgeInsets.only(bottom: 18),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.65),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              child,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ✅ Sticky bar
                  if (bottomBar != null)
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 10, 16, 12 + safeBottom),
                      child: bottomBar!,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
