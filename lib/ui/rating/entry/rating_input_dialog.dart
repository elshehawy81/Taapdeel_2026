import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/provider/rating/rating_provider.dart';
import 'package:taapdeel/repository/rating_repository.dart';
import 'package:taapdeel/ui/common/dialog/warning_dialog_view.dart';
import 'package:taapdeel/ui/common/ps_textfield_widget.dart';
import 'package:taapdeel/ui/common/smooth_star_rating_widget.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_button.dart';
import 'package:taapdeel/utils/ps_progress_dialog.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/holder/rating_holder.dart';
import 'package:taapdeel/viewobject/rating.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class RatingInputDialog extends StatefulWidget {
  const RatingInputDialog({
    Key? key,
    required this.buyerUserId,
    required this.sellerUserId,
    this.rating,
  }) : super(key: key);

  final String? buyerUserId;
  final String? sellerUserId;
  final Rating? rating;

  @override
  _RatingInputDialogState createState() => _RatingInputDialogState();
}

class _RatingInputDialogState extends State<RatingInputDialog> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  PsValueHolder? psValueHolder;
  RatingRepository? ratingRepo;
  double? rating;
  bool isBindData = true;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ratingRepo = Provider.of<RatingRepository>(context);
    psValueHolder = Provider.of<PsValueHolder>(context);

    // Bind existing rating (edit mode)
    if (isBindData && widget.rating != null) {
      titleController.text = widget.rating!.title ?? '';
      descriptionController.text = widget.rating!.description ?? '';
      rating = double.tryParse(widget.rating!.rating ?? '0.0') ?? 0.0;
      isBindData = false;
    }

    return ChangeNotifierProvider<RatingProvider>(
      lazy: false,
      create: (BuildContext context) {
        final RatingProvider provider = RatingProvider(repo: ratingRepo);
        return provider;
      },
      child: Consumer<RatingProvider>(
        builder: (
            BuildContext context,
            RatingProvider provider,
            Widget? child,
            ) {
          final ThemeData theme = Theme.of(context);
          final bool isDark = theme.brightness == Brightness.dark;

          final String dialogTitle = Utils.getString(
            context,
            'rating_entry__user_rating_entry',
          );

          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: PsDimens.space24,
              vertical: PsDimens.space24,
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: (Theme.of(context).dialogTheme.backgroundColor ??
                      PsColors.baseLightColor)
                      .withValues(alpha:isDark ? 0.96 : 0.98),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.20),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(PsDimens.space16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.star_rate_rounded,
                            color: PsColors.activeColor,
                          ),
                          const SizedBox(width: PsDimens.space4),
                          Text(
                            dialogTitle,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: PsColors.textColor1,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: PsDimens.space16),

                      // "Your rating" + stars
                      Column(
                        children: <Widget>[
                          Text(
                            Utils.getString(
                              context,
                              'rating_entry__your_rating',
                            ),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: PsColors.textColor1,
                            ),
                          ),
                          const SizedBox(height: PsDimens.space8),
                          SmoothStarRating(
                            isRTl: Directionality.of(context) ==
                                TextDirection.rtl,
                            allowHalfRating: false,
                            rating: rating ??
                                (widget.rating != null
                                    ? double.tryParse(
                                  widget.rating!.rating ?? '0.0',
                                ) ??
                                    0.0
                                    : 0.0),
                            starCount: 5,
                            size: PsDimens.space40,
                            color: PsColors.ratingColor,
                            borderColor: PsColors.grey.withAlpha(100),
                            spacing: 0.0,
                            onRated: (double? r) {
                              setState(() {
                                rating = r;
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: PsDimens.space16),

                      // Title field
                      PsTextFieldWidget(
                        titleText: Utils.getString(
                          context,
                          'rating_entry__title',
                        ),
                        hintText: Utils.getString(
                          context,
                          'rating_entry__title',
                        ),
                        textEditingController: titleController,
                      ),

                      // Message field
                      PsTextFieldWidget(
                        height: PsDimens.space120,
                        keyboardType: TextInputType.multiline,
                        titleText: Utils.getString(
                          context,
                          'rating_entry__message',
                        ),
                        hintText: Utils.getString(
                          context,
                          'rating_entry__message',
                        ),
                        textEditingController: descriptionController,
                      ),

                      const SizedBox(height: PsDimens.space16),

                      // Buttons row (Cancel / Submit)
                      _ButtonWidget(
                        descriptionController: descriptionController,
                        provider: provider,
                        titleController: titleController,
                        rating: rating,
                        psValueHolder: psValueHolder,
                        buyerUserId: widget.buyerUserId,
                        sellerUserId: widget.sellerUserId,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ButtonWidget extends StatelessWidget {
  const _ButtonWidget({
    Key? key,
    required this.titleController,
    required this.descriptionController,
    required this.provider,
    required this.rating,
    required this.psValueHolder,
    required this.buyerUserId,
    required this.sellerUserId,
  }) : super(key: key);

  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final RatingProvider provider;
  final double? rating;
  final PsValueHolder? psValueHolder;
  final String? buyerUserId;
  final String? sellerUserId;

  @override
  Widget build(BuildContext context) {
    late RatingParameterHolder commentHeaderParameterHolder;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PsDimens.space8,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TaapdeelButton(
              label: Utils.getString(context, 'rating_entry__cancel'),
              isPrimary: false,
              outlined: true,
              isExpanded: true,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: PsDimens.space8),
          Expanded(
            child: TaapdeelButton(
              label: Utils.getString(context, 'rating_entry__submit'),
              isPrimary: true,
              isExpanded: true,
              onPressed: () async {
                if (titleController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty &&
                    rating != null &&
                    rating.toString() != '0.0') {
                  // Build parameter holder
                  if (buyerUserId == psValueHolder!.loginUserId) {
                    commentHeaderParameterHolder = RatingParameterHolder(
                      fromUserId: buyerUserId,
                      toUserId: sellerUserId,
                      title: titleController.text,
                      description: descriptionController.text,
                      rating: rating.toString(),
                    );
                  }
                  if (sellerUserId == psValueHolder!.loginUserId) {
                    commentHeaderParameterHolder = RatingParameterHolder(
                      fromUserId: sellerUserId,
                      toUserId: buyerUserId,
                      title: titleController.text,
                      description: descriptionController.text,
                      rating: rating.toString(),
                    );
                  }

                  await PsProgressDialog.showDialog(context);
                  await provider.postRating(
                    commentHeaderParameterHolder.toMap(),
                  );
                  PsProgressDialog.dismissDialog();

                  Navigator.of(context).pop();
                  Fluttertoast.showToast(
                    msg: 'Rating Successed!!!',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.blueGrey,
                    textColor: Colors.white,
                  );
                } else {
                  showDialog<dynamic>(
                    context: context,
                    builder: (BuildContext context) {
                      return WarningDialog(
                        message: Utils.getString(
                          context,
                          'rating_entry__error',
                        ),
                        onPressed: () {},
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
