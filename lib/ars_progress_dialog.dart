import 'dart:ui';

import 'package:flutter/material.dart';

/// Ars Progress Dialog
class ArsProgressDialog {
  /// BuildContext to show dialog in
  final BuildContext context;

  /// Main widget of dialog,
  final Widget? loadingWidget;

  /// Whether dialog can dismiss by touching outside or not
  final bool dismissable;

  /// This function will trigger when user dismisses dialog
  final Function? onDismiss;

  /// Amount of background blur
  final double blur;

  /// Dialog's background color
  final Color backgroundColor;

  /// Using safe area, dialog will keep padding from status bar, navigation bar and ...
  final bool useSafeArea;

  /// Duration of blur and background color animation
  final Duration animationDuration;

  /// Is dialog showing or not
  bool _isShowing = false;

  /// Dialog widget instance
  late _ArsProgressDialogWidget _progressDialogWidget;

  /// Getter for _isShowing
  bool get isShowing => _isShowing;

  /// Progress Indicator Color
  final Color progressIndicatorColor;

  ArsProgressDialog(
    this.context, {
    this.backgroundColor = const Color(0x99000000),
    this.blur = 0,
    this.dismissable = true,
    this.onDismiss,
    this.loadingWidget,
    this.useSafeArea = false,
    this.animationDuration = const Duration(milliseconds: 300),
    this.progressIndicatorColor=Colors.blue
  }) {
    _initProgress();
  }

  /// Initialize dialog's instance
  void _initProgress() {
    _progressDialogWidget = _ArsProgressDialogWidget(
      blur: blur,
      dismissable: dismissable,
      backgroundColor: backgroundColor,
      onDismiss: onDismiss,
      loadingWidget: loadingWidget,
      animationDuration: animationDuration,
      progressIndicatorColor: progressIndicatorColor,
    );
  }

  /// Show progress dialog
  void show() async {
    if (!_isShowing) {
      _isShowing = true;
      if (_progressDialogWidget == null) _initProgress();
      await showDialog(
        useSafeArea: useSafeArea,
        context: context,
        barrierDismissible: dismissable,
        builder: (context) => _progressDialogWidget,
        barrierColor: Colors.transparent,
      );
      _isShowing = false;
    }
  }

  /// Dismiss progress dialog
  void dismiss() {
    if (_isShowing) {
      _isShowing = false;
      Navigator.pop(context);
    }
  }
}

// ignore: must_be_immutable
class _ArsProgressDialogWidget extends StatelessWidget {
  /// Main widget of dialog,
  Widget? loadingWidget;

  /// This function will trigger when user dismisses dialog
  final Function? onDismiss;

  /// Amount of background blur
  final double blur;

  /// Dialog's background color
  final Color backgroundColor;

  /// Whether dialog can dismiss by touching outside or not
  final bool dismissable;

  /// Duration of blur and background color animation
  final Duration animationDuration;

  /// Progress Indicator Color
  final Color progressIndicatorColor;

  _ArsProgressDialogWidget({
    this.dismissable=true,
    this.onDismiss,
    this.backgroundColor=Colors.white,
    this.loadingWidget,
    this.blur=0,
    this.animationDuration = const Duration(milliseconds: 300),
    this.progressIndicatorColor=Colors.blue
  }) {
    loadingWidget = loadingWidget ??
        Container(
          padding: EdgeInsets.all(10.0),
          height: 100.0,
          width: 100.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: CircularProgressIndicator(
            color: progressIndicatorColor,
            strokeWidth: 2,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return _DialogBackground(
      blur: blur,
      dismissable: dismissable,
      onDismiss: onDismiss,
      color: backgroundColor,
      animationDuration: animationDuration,
      dialog: Padding(
        padding: MediaQuery.of(context).viewInsets +
            const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Center(
          child: loadingWidget,
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class _DialogBackground extends StatelessWidget {
  /// Widget of dialog, you can use NDialog, Dialog, AlertDialog or Custom your own Dialog
  final Widget dialog;

  /// Because blur dialog cover the barrier, you have to declare here
  final bool dismissable;

  /// Action before dialog dismissed
  final Function? onDismiss;

  /// Creates an background filter that applies a Gaussian blur.
  /// Default = 0
  final double blur;

  /// Background color
  final Color color;

  /// Animation Duration
  final Duration animationDuration;

  /// Color Opacity
  double _colorOpacity=0;

  _DialogBackground(
      {
      required this.dialog,
      this.dismissable=true,
      this.blur=0,
      this.onDismiss,
      this.animationDuration = const Duration(milliseconds: 300),
      this.color=Colors.white}) {
    _colorOpacity = color.opacity;
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: 1),
        duration: animationDuration,
        builder: (context, val, child) {
          double parsedValue = double.parse((val??'0').toString());
          return Material(
            type: MaterialType.canvas,
            color: color.withOpacity(parsedValue * _colorOpacity),
            child: WillPopScope(
              onWillPop: () async {
                if (dismissable) {
                  if (onDismiss != null) onDismiss!();
                  Navigator.pop(context);
                }
                return dismissable;
              },
              child: Stack(
                clipBehavior: Clip.antiAlias,
                alignment: Alignment.center,
                children: <Widget>[
                  GestureDetector(
                      onTap: dismissable
                          ? () {
                              if (onDismiss != null) {
                                onDismiss!();
                              }
                              Navigator.pop(context);
                            }
                          : () {},
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: parsedValue * blur,
                          sigmaY: parsedValue * blur,
                        ),
                        child: Container(
                          color: Colors.transparent,
                        ),
                      )),
                  dialog
                ],
              ),
            ),
          );
        });
  }
}
