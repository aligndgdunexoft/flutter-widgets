import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:syncfusion_flutter_core/core.dart';
import 'package:syncfusion_flutter_core/core_internal.dart';
import 'package:syncfusion_flutter_core/localizations.dart';
import 'package:syncfusion_flutter_core/theme.dart';

import '../../datepicker.dart';
import 'month_view.dart';
import 'picker_helper.dart';
import 'year_view.dart';

typedef UpdatePickerState = void Function(
    PickerStateArgs updatePickerStateDetails);

typedef DateRangePickerViewChangedCallback = void Function(
    DateRangePickerViewChangedArgs dateRangePickerViewChangedArgs);

typedef HijriDatePickerViewChangedCallback = void Function(
    HijriDatePickerViewChangedArgs hijriDatePickerViewChangedArgs);

typedef DateRangePickerSelectionChangedCallback = void Function(
    DateRangePickerSelectionChangedArgs dateRangePickerSelectionChangedArgs);

void _raiseSelectionChangedCallback(_SfDateRangePicker picker,
    {dynamic value}) {
  picker.onSelectionChanged?.call(DateRangePickerSelectionChangedArgs(value));
}

void _raisePickerViewChangedCallback(_SfDateRangePicker picker,
    {dynamic visibleDateRange, dynamic view}) {
  if (picker.onViewChanged == null) {
    return;
  }

  if (picker.isHijri) {
    picker
        .onViewChanged(HijriDatePickerViewChangedArgs(visibleDateRange, view));
  } else {
    picker
        .onViewChanged(DateRangePickerViewChangedArgs(visibleDateRange, view));
  }
}

@immutable
class SfDateRangePicker extends StatelessWidget {
  SfDateRangePicker({
    Key? key,
    DateRangePickerView view = DateRangePickerView.month,
    this.selectionMode = DateRangePickerSelectionMode.single,
    this.headerHeight = 40,
    this.todayHighlightColor,
    this.backgroundColor,
    DateTime? initialSelectedDate,
    List<DateTime>? initialSelectedDates,
    PickerDateRange? initialSelectedRange,
    List<PickerDateRange>? initialSelectedRanges,
    this.toggleDaySelection = false,
    this.enablePastDates = true,
    this.showNavigationArrow = false,
    this.confirmText = 'OK',
    this.cancelText = 'CANCEL',
    this.showActionButtons = false,
    this.selectionShape = DateRangePickerSelectionShape.circle,
    this.navigationDirection = DateRangePickerNavigationDirection.horizontal,
    this.allowViewNavigation = true,
    this.navigationMode = DateRangePickerNavigationMode.snap,
    this.enableMultiView = false,
    this.controller,
    this.onViewChanged,
    this.onSelectionChanged,
    this.onCancel,
    this.onSubmit,
    this.headerStyle = const DateRangePickerHeaderStyle(),
    this.yearCellStyle = const DateRangePickerYearCellStyle(),
    this.monthViewSettings = const DateRangePickerMonthViewSettings(),
    this.monthCellStyle = const DateRangePickerMonthCellStyle(),
    DateTime? minDate,
    DateTime? maxDate,
    DateTime? initialDisplayDate,
    double viewSpacing = 20,
    this.selectionRadius = -1,
    this.selectionColor,
    this.startRangeSelectionColor,
    this.endRangeSelectionColor,
    this.rangeSelectionColor,
    this.selectionTextStyle,
    this.rangeTextStyle,
    this.monthFormat,
    this.cellBuilder,
    this.showTodayButton = false,
    this.selectableDayPredicate,
    this.extendableRangeSelectionDirection =
        ExtendableRangeSelectionDirection.both,
    this.onTapCallBack,
    this.onLongPressCallBack,
    this.dragEndCallback,
  })  : assert(headerHeight >= -1),
        assert(minDate == null || maxDate == null || minDate.isBefore(maxDate)),
        assert(minDate == null || maxDate == null || maxDate.isAfter(minDate)),
        assert(viewSpacing >= 0),
        initialSelectedDate =
            controller != null && controller.selectedDate != null
                ? controller.selectedDate
                : initialSelectedDate,
        initialSelectedDates =
            controller != null && controller.selectedDates != null
                ? controller.selectedDates
                : initialSelectedDates,
        initialSelectedRange =
            controller != null && controller.selectedRange != null
                ? controller.selectedRange
                : initialSelectedRange,
        initialSelectedRanges =
            controller != null && controller.selectedRanges != null
                ? controller.selectedRanges
                : initialSelectedRanges,
        view = controller != null && controller.view != null
            ? controller.view!
            : view,
        initialDisplayDate =
            controller != null && controller.displayDate != null
                ? controller.displayDate!
                : initialDisplayDate ?? DateTime.now(),
        minDate = minDate ?? DateTime(1900),
        maxDate = maxDate ?? DateTime(2100, 12, 31),
        viewSpacing = enableMultiView ? viewSpacing : 0,
        super(key: key);

  final DateRangePickerView view;

  final DateRangePickerSelectionMode selectionMode;

  final DateRangePickerHeaderStyle headerStyle;

  final double headerHeight;

  final Color? todayHighlightColor;

  final Color? backgroundColor;

  final bool toggleDaySelection;

  final bool allowViewNavigation;

  final DateRangePickerCellBuilder? cellBuilder;

  final bool showTodayButton;

  final DateRangePickerSelectableDayPredicate? selectableDayPredicate;

  final ExtendableRangeSelectionDirection extendableRangeSelectionDirection;

  final bool enableMultiView;

  final double viewSpacing;

  final double selectionRadius;

  final TextStyle? selectionTextStyle;

  final TextStyle? rangeTextStyle;

  final Color? selectionColor;

  final Color? startRangeSelectionColor;

  final Color? rangeSelectionColor;

  final Color? endRangeSelectionColor;

  final DateRangePickerMonthViewSettings monthViewSettings;

  final DateRangePickerYearCellStyle yearCellStyle;

  final DateRangePickerMonthCellStyle monthCellStyle;

  final DateTime initialDisplayDate;

  final DateTime? initialSelectedDate;

  final DateTime minDate;

  final DateTime maxDate;

  final bool enablePastDates;

  final List<DateTime>? initialSelectedDates;

  final PickerDateRange? initialSelectedRange;

  final List<PickerDateRange>? initialSelectedRanges;

  final DateRangePickerController? controller;

  final bool showNavigationArrow;

  final DateRangePickerNavigationDirection navigationDirection;

  final DateRangePickerSelectionShape selectionShape;

  final String? monthFormat;

  final DateRangePickerNavigationMode navigationMode;

  final DateRangePickerViewChangedCallback? onViewChanged;

  final DateRangePickerSelectionChangedCallback? onSelectionChanged;

  final String confirmText;

  final String cancelText;

  final bool showActionButtons;

  final VoidCallback? onCancel;

  final Function(Object?)? onSubmit;

  final Function(PickerDateRange?, bool)? onTapCallBack;

  final Function(PickerDateRange?)? onLongPressCallBack;

  final DateRangePickerSelectionChangedCallback? dragEndCallback;

  @override
  Widget build(BuildContext context) {
    return _SfDateRangePicker(
      key: key,
      view: view,
      selectionMode: selectionMode,
      headerHeight: headerHeight,
      todayHighlightColor: todayHighlightColor,
      backgroundColor: backgroundColor,
      initialSelectedDate: initialSelectedDate,
      initialSelectedDates: initialSelectedDates,
      initialSelectedRange: initialSelectedRange,
      initialSelectedRanges: initialSelectedRanges,
      toggleDaySelection: toggleDaySelection,
      enablePastDates: enablePastDates,
      showNavigationArrow: showNavigationArrow,
      selectionShape: selectionShape,
      navigationDirection: navigationDirection,
      controller: controller,
      onViewChanged: onViewChanged,
      onSelectionChanged: onSelectionChanged,
      onCancel: onCancel,
      onSubmit: onSubmit,
      headerStyle: headerStyle,
      yearCellStyle: yearCellStyle,
      monthViewSettings: monthViewSettings,
      initialDisplayDate: initialDisplayDate,
      minDate: minDate,
      maxDate: maxDate,
      monthCellStyle: monthCellStyle,
      allowViewNavigation: allowViewNavigation,
      enableMultiView: enableMultiView,
      viewSpacing: viewSpacing,
      selectionRadius: selectionRadius,
      selectionColor: selectionColor,
      startRangeSelectionColor: startRangeSelectionColor,
      endRangeSelectionColor: endRangeSelectionColor,
      rangeSelectionColor: rangeSelectionColor,
      selectionTextStyle: selectionTextStyle,
      rangeTextStyle: rangeTextStyle,
      monthFormat: monthFormat,
      cellBuilder: cellBuilder,
      navigationMode: navigationMode,
      confirmText: confirmText,
      cancelText: cancelText,
      showActionButtons: showActionButtons,
      showTodayButton: showTodayButton,
      selectableDayPredicate: selectableDayPredicate,
      extendableRangeSelectionDirection: extendableRangeSelectionDirection,
      onTapCallback: onTapCallBack,
      dragEndCallback: dragEndCallback,
      onLongPressCallback: onLongPressCallBack,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<DateRangePickerView>('view', view));
    properties.add(EnumProperty<DateRangePickerSelectionMode>(
        'selectionMode', selectionMode));
    properties.add(EnumProperty<DateRangePickerSelectionShape>(
        'selectionShape', selectionShape));
    properties.add(EnumProperty<DateRangePickerNavigationDirection>(
        'navigationDirection', navigationDirection));
    properties.add(EnumProperty<DateRangePickerNavigationMode>(
        'navigationMode', navigationMode));
    properties.add(DoubleProperty('headerHeight', headerHeight));
    properties.add(DoubleProperty('viewSpacing', viewSpacing));
    properties.add(DoubleProperty('selectionRadius', selectionRadius));
    properties.add(ColorProperty('todayHighlightColor', todayHighlightColor));
    properties.add(ColorProperty('backgroundColor', backgroundColor));
    properties.add(ColorProperty('selectionColor', selectionColor));
    properties.add(
        ColorProperty('startRangeSelectionColor', startRangeSelectionColor));
    properties
        .add(ColorProperty('endRangeSelectionColor', endRangeSelectionColor));
    properties.add(ColorProperty('rangeSelectionColor', rangeSelectionColor));
    properties.add(StringProperty('monthFormat', monthFormat));
    properties.add(DiagnosticsProperty<TextStyle>(
        'selectionTextStyle', selectionTextStyle));
    properties
        .add(DiagnosticsProperty<TextStyle>('rangeTextStyle', rangeTextStyle));
    properties.add(DiagnosticsProperty<DateTime>(
        'initialDisplayDate', initialDisplayDate));
    properties.add(DiagnosticsProperty<DateTime>(
        'initialSelectedDate', initialSelectedDate));
    properties.add(IterableDiagnostics<DateTime>(initialSelectedDates)
        .toDiagnosticsNode(name: 'initialSelectedDates'));
    properties.add(DiagnosticsProperty<PickerDateRange>(
        'initialSelectedRange', initialSelectedRange));
    properties.add(IterableDiagnostics<PickerDateRange>(initialSelectedRanges)
        .toDiagnosticsNode(name: 'initialSelectedRanges'));
    properties.add(DiagnosticsProperty<DateTime>('minDate', minDate));
    properties.add(DiagnosticsProperty<DateTime>('maxDate', maxDate));
    properties.add(DiagnosticsProperty<DateRangePickerCellBuilder>(
        'cellBuilder', cellBuilder));
    properties.add(
        DiagnosticsProperty<bool>('allowViewNavigation', allowViewNavigation));
    properties.add(
        DiagnosticsProperty<bool>('toggleDaySelection', toggleDaySelection));
    properties
        .add(DiagnosticsProperty<bool>('enablePastDates', enablePastDates));
    properties.add(
        DiagnosticsProperty<bool>('showNavigationArrow', showNavigationArrow));
    properties
        .add(DiagnosticsProperty<bool>('showActionButtons', showActionButtons));
    properties.add(StringProperty('cancelText', cancelText));
    properties.add(StringProperty('confirmText', confirmText));
    properties
        .add(DiagnosticsProperty<bool>('enableMultiView', enableMultiView));
    properties.add(DiagnosticsProperty<DateRangePickerViewChangedCallback>(
        'onViewChanged', onViewChanged));
    properties.add(DiagnosticsProperty<DateRangePickerSelectionChangedCallback>(
        'onSelectionChanged', onSelectionChanged));
    properties.add(DiagnosticsProperty<VoidCallback>('onCancel', onCancel));
    properties.add(DiagnosticsProperty<Function(Object)>('onSubmit', onSubmit));
    properties.add(DiagnosticsProperty<DateRangePickerController>(
        'controller', controller));

    properties.add(headerStyle.toDiagnosticsNode(name: 'headerStyle'));

    properties.add(yearCellStyle.toDiagnosticsNode(name: 'yearCellStyle'));

    properties
        .add(monthViewSettings.toDiagnosticsNode(name: 'monthViewSettings'));

    properties.add(monthCellStyle.toDiagnosticsNode(name: 'monthCellStyle'));

    properties
        .add(DiagnosticsProperty<bool>('showTodayButton', showTodayButton));
    properties.add(DiagnosticsProperty<DateRangePickerSelectableDayPredicate>(
        'selectableDayPredicate', selectableDayPredicate));
    properties.add(EnumProperty<ExtendableRangeSelectionDirection>(
        'extendableRangeSelectionDirection',
        extendableRangeSelectionDirection));
  }
}

@immutable
class SfHijriDateRangePicker extends StatelessWidget {
  SfHijriDateRangePicker({
    Key? key,
    HijriDatePickerView view = HijriDatePickerView.month,
    this.selectionMode = DateRangePickerSelectionMode.single,
    this.headerHeight = 40,
    this.todayHighlightColor,
    this.backgroundColor,
    HijriDateTime? initialSelectedDate,
    List<HijriDateTime>? initialSelectedDates,
    HijriDateRange? initialSelectedRange,
    List<HijriDateRange>? initialSelectedRanges,
    this.toggleDaySelection = false,
    this.enablePastDates = true,
    this.showNavigationArrow = false,
    this.confirmText = 'OK',
    this.cancelText = 'CANCEL',
    this.showActionButtons = false,
    this.selectionShape = DateRangePickerSelectionShape.circle,
    this.navigationDirection = DateRangePickerNavigationDirection.horizontal,
    this.navigationMode = DateRangePickerNavigationMode.snap,
    this.allowViewNavigation = true,
    this.enableMultiView = false,
    this.controller,
    this.onViewChanged,
    this.onSelectionChanged,
    this.onCancel,
    this.onSubmit,
    this.headerStyle = const DateRangePickerHeaderStyle(),
    this.yearCellStyle = const HijriDatePickerYearCellStyle(),
    this.monthViewSettings = const HijriDatePickerMonthViewSettings(),
    HijriDateTime? initialDisplayDate,
    HijriDateTime? minDate,
    HijriDateTime? maxDate,
    this.monthCellStyle = const HijriDatePickerMonthCellStyle(),
    double viewSpacing = 20,
    this.selectionRadius = -1,
    this.selectionColor,
    this.startRangeSelectionColor,
    this.endRangeSelectionColor,
    this.rangeSelectionColor,
    this.selectionTextStyle,
    this.rangeTextStyle,
    this.monthFormat,
    this.cellBuilder,
    this.showTodayButton = false,
    this.selectableDayPredicate,
    this.extendableRangeSelectionDirection =
        ExtendableRangeSelectionDirection.both,
    this.onTapCallback,
    this.onLongPressCallback,
    this.dragEndCallback,
  })  : initialSelectedDate =
            controller != null && controller.selectedDate != null
                ? controller.selectedDate
                : initialSelectedDate,
        initialSelectedDates =
            controller != null && controller.selectedDates != null
                ? controller.selectedDates
                : initialSelectedDates,
        initialSelectedRange =
            controller != null && controller.selectedRange != null
                ? controller.selectedRange
                : initialSelectedRange,
        initialSelectedRanges =
            controller != null && controller.selectedRanges != null
                ? controller.selectedRanges
                : initialSelectedRanges,
        view = controller != null && controller.view != null
            ? controller.view!
            : view,
        initialDisplayDate =
            controller != null && controller.displayDate != null
                ? controller.displayDate!
                : initialDisplayDate ?? HijriDateTime.now(),
        minDate = minDate ?? HijriDateTime(1356, 01, 01),
        maxDate = maxDate ?? HijriDateTime(1499, 12, 30),
        viewSpacing = enableMultiView ? viewSpacing : 0,
        super(key: key);

  final HijriDatePickerView view;

  final DateRangePickerSelectionMode selectionMode;

  final DateRangePickerHeaderStyle headerStyle;

  final double headerHeight;

  final Color? todayHighlightColor;

  final Color? backgroundColor;

  final bool toggleDaySelection;

  final HijriDateRangePickerCellBuilder? cellBuilder;

  final bool showTodayButton;

  final HijriDatePickerSelectableDayPredicate? selectableDayPredicate;

  final ExtendableRangeSelectionDirection extendableRangeSelectionDirection;

  final bool allowViewNavigation;

  final bool enableMultiView;

  final double viewSpacing;

  final double selectionRadius;

  final TextStyle? selectionTextStyle;

  final TextStyle? rangeTextStyle;

  final Color? selectionColor;

  final Color? startRangeSelectionColor;

  final Color? rangeSelectionColor;

  final Color? endRangeSelectionColor;

  final HijriDatePickerMonthViewSettings monthViewSettings;

  final HijriDatePickerYearCellStyle yearCellStyle;

  final HijriDatePickerMonthCellStyle monthCellStyle;

  final HijriDateTime initialDisplayDate;

  final HijriDateTime? initialSelectedDate;

  final HijriDateTime minDate;

  final HijriDateTime maxDate;

  final bool enablePastDates;

  final List<HijriDateTime>? initialSelectedDates;

  final HijriDateRange? initialSelectedRange;

  final List<HijriDateRange>? initialSelectedRanges;

  final HijriDatePickerController? controller;

  final bool showNavigationArrow;

  final DateRangePickerNavigationDirection navigationDirection;

  final DateRangePickerSelectionShape selectionShape;

  final String? monthFormat;

  final DateRangePickerNavigationMode navigationMode;

  final HijriDatePickerViewChangedCallback? onViewChanged;

  final DateRangePickerSelectionChangedCallback? onSelectionChanged;

  final String confirmText;

  final String cancelText;

  final bool showActionButtons;

  final VoidCallback? onCancel;

  final Function(Object?)? onSubmit;

  final Function(PickerDateRange?, bool)? onTapCallback;

  final Function(PickerDateRange?)? onLongPressCallback;

  final DateRangePickerSelectionChangedCallback? dragEndCallback;

  @override
  Widget build(BuildContext context) {
    return _SfDateRangePicker(
      key: key,
      view: DateRangePickerHelper.getPickerView(view),
      selectionMode: selectionMode,
      headerHeight: headerHeight,
      todayHighlightColor: todayHighlightColor,
      backgroundColor: backgroundColor,
      initialSelectedDate: initialSelectedDate,
      initialSelectedDates: initialSelectedDates,
      initialSelectedRange: initialSelectedRange,
      initialSelectedRanges: initialSelectedRanges,
      toggleDaySelection: toggleDaySelection,
      enablePastDates: enablePastDates,
      showNavigationArrow: showNavigationArrow,
      selectionShape: selectionShape,
      navigationDirection: navigationDirection,
      controller: controller,
      onViewChanged: onViewChanged,
      onSelectionChanged: onSelectionChanged,
      onCancel: onCancel,
      onSubmit: onSubmit,
      headerStyle: headerStyle,
      yearCellStyle: yearCellStyle,
      monthViewSettings: monthViewSettings,
      initialDisplayDate: initialDisplayDate,
      minDate: minDate,
      maxDate: maxDate,
      monthCellStyle: monthCellStyle,
      allowViewNavigation: allowViewNavigation,
      enableMultiView: enableMultiView,
      viewSpacing: viewSpacing,
      selectionRadius: selectionRadius,
      selectionColor: selectionColor,
      startRangeSelectionColor: startRangeSelectionColor,
      endRangeSelectionColor: endRangeSelectionColor,
      rangeSelectionColor: rangeSelectionColor,
      selectionTextStyle: selectionTextStyle,
      rangeTextStyle: rangeTextStyle,
      monthFormat: monthFormat,
      cellBuilder: cellBuilder,
      navigationMode: navigationMode,
      confirmText: confirmText,
      cancelText: cancelText,
      showActionButtons: showActionButtons,
      isHijri: true,
      showTodayButton: showTodayButton,
      selectableDayPredicate: selectableDayPredicate,
      extendableRangeSelectionDirection: extendableRangeSelectionDirection,
      onTapCallback: onTapCallback,
      onLongPressCallback: onLongPressCallback,
      dragEndCallback: dragEndCallback,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<HijriDatePickerView>('view', view));
    properties.add(EnumProperty<DateRangePickerSelectionMode>(
        'selectionMode', selectionMode));
    properties.add(EnumProperty<DateRangePickerSelectionShape>(
        'selectionShape', selectionShape));
    properties.add(EnumProperty<DateRangePickerNavigationDirection>(
        'navigationDirection', navigationDirection));
    properties.add(EnumProperty<DateRangePickerNavigationMode>(
        'navigationMode', navigationMode));
    properties.add(DoubleProperty('headerHeight', headerHeight));
    properties.add(DoubleProperty('viewSpacing', viewSpacing));
    properties.add(DoubleProperty('selectionRadius', selectionRadius));
    properties.add(ColorProperty('todayHighlightColor', todayHighlightColor));
    properties.add(ColorProperty('backgroundColor', backgroundColor));
    properties.add(ColorProperty('selectionColor', selectionColor));
    properties.add(
        ColorProperty('startRangeSelectionColor', startRangeSelectionColor));
    properties
        .add(ColorProperty('endRangeSelectionColor', endRangeSelectionColor));
    properties.add(ColorProperty('rangeSelectionColor', rangeSelectionColor));
    properties.add(StringProperty('monthFormat', monthFormat));
    properties.add(DiagnosticsProperty<TextStyle>(
        'selectionTextStyle', selectionTextStyle));
    properties
        .add(DiagnosticsProperty<TextStyle>('rangeTextStyle', rangeTextStyle));
    properties.add(DiagnosticsProperty<HijriDateTime>(
        'initialDisplayDate', initialDisplayDate));
    properties.add(DiagnosticsProperty<HijriDateTime>(
        'initialSelectedDate', initialSelectedDate));
    properties.add(IterableDiagnostics<HijriDateTime>(initialSelectedDates)
        .toDiagnosticsNode(name: 'initialSelectedDates'));
    properties.add(DiagnosticsProperty<HijriDateRange>(
        'HijriDateRange', initialSelectedRange));
    properties.add(IterableDiagnostics<HijriDateRange>(initialSelectedRanges)
        .toDiagnosticsNode(name: 'initialSelectedRanges'));
    properties.add(DiagnosticsProperty<HijriDateTime>('minDate', minDate));
    properties.add(DiagnosticsProperty<HijriDateTime>('maxDate', maxDate));
    properties.add(DiagnosticsProperty<HijriDateRangePickerCellBuilder>(
        'cellBuilder', cellBuilder));
    properties.add(
        DiagnosticsProperty<bool>('allowViewNavigation', allowViewNavigation));
    properties.add(
        DiagnosticsProperty<bool>('toggleDaySelection', toggleDaySelection));
    properties
        .add(DiagnosticsProperty<bool>('enablePastDates', enablePastDates));
    properties.add(
        DiagnosticsProperty<bool>('showNavigationArrow', showNavigationArrow));
    properties
        .add(DiagnosticsProperty<bool>('showActionButtons', showActionButtons));
    properties.add(StringProperty('cancelText', cancelText));
    properties.add(StringProperty('confirmText', confirmText));
    properties
        .add(DiagnosticsProperty<bool>('enableMultiView', enableMultiView));
    properties.add(DiagnosticsProperty<HijriDatePickerViewChangedCallback>(
        'onViewChanged', onViewChanged));
    properties.add(DiagnosticsProperty<DateRangePickerSelectionChangedCallback>(
        'onSelectionChanged', onSelectionChanged));
    properties.add(DiagnosticsProperty<VoidCallback>('onCancel', onCancel));
    properties.add(DiagnosticsProperty<Function(Object)>('onSubmit', onSubmit));
    properties.add(DiagnosticsProperty<HijriDatePickerController>(
        'controller', controller));

    properties.add(headerStyle.toDiagnosticsNode(name: 'headerStyle'));

    properties.add(yearCellStyle.toDiagnosticsNode(name: 'yearCellStyle'));

    properties
        .add(monthViewSettings.toDiagnosticsNode(name: 'monthViewSettings'));

    properties.add(monthCellStyle.toDiagnosticsNode(name: 'monthCellStyle'));

    properties
        .add(DiagnosticsProperty<bool>('showTodayButton', showTodayButton));
    properties.add(DiagnosticsProperty<HijriDatePickerSelectableDayPredicate>(
        'selectableDayPredicate', selectableDayPredicate));
    properties.add(EnumProperty<ExtendableRangeSelectionDirection>(
        'extendableRangeSelectionDirection',
        extendableRangeSelectionDirection));
  }
}

@immutable
class _SfDateRangePicker extends StatefulWidget {
  const _SfDateRangePicker({
    Key? key,
    required this.view,
    required this.selectionMode,
    this.isHijri = false,
    required this.headerHeight,
    this.todayHighlightColor,
    this.backgroundColor,
    this.initialSelectedDate,
    this.initialSelectedDates,
    this.initialSelectedRange,
    this.initialSelectedRanges,
    this.toggleDaySelection = false,
    this.enablePastDates = true,
    this.showNavigationArrow = false,
    required this.selectionShape,
    required this.navigationDirection,
    this.controller,
    this.onViewChanged,
    this.onSelectionChanged,
    this.onCancel,
    this.onSubmit,
    required this.headerStyle,
    required this.yearCellStyle,
    required this.monthViewSettings,
    required this.initialDisplayDate,
    this.confirmText = 'OK',
    this.cancelText = 'CANCEL',
    this.showActionButtons = false,
    required this.minDate,
    required this.maxDate,
    required this.monthCellStyle,
    this.allowViewNavigation = true,
    this.enableMultiView = false,
    required this.navigationMode,
    required this.viewSpacing,
    required this.selectionRadius,
    this.selectionColor,
    this.startRangeSelectionColor,
    this.endRangeSelectionColor,
    this.rangeSelectionColor,
    this.selectionTextStyle,
    this.rangeTextStyle,
    this.monthFormat,
    this.cellBuilder,
    this.showTodayButton = false,
    this.selectableDayPredicate,
    this.extendableRangeSelectionDirection =
        ExtendableRangeSelectionDirection.both,
    this.onTapCallback,
    this.onLongPressCallback,
    this.dragEndCallback,
  }) : super(key: key);

  final DateRangePickerView view;

  final DateRangePickerSelectionMode selectionMode;

  final bool isHijri;

  final DateRangePickerHeaderStyle headerStyle;

  final double headerHeight;

  final String confirmText;

  final String cancelText;

  final bool showActionButtons;

  final Color? todayHighlightColor;

  final Color? backgroundColor;

  final bool toggleDaySelection;

  final bool allowViewNavigation;

  final bool enableMultiView;

  final double viewSpacing;

  final double selectionRadius;

  final TextStyle? selectionTextStyle;

  final TextStyle? rangeTextStyle;

  final Color? selectionColor;

  final Color? startRangeSelectionColor;

  final Color? rangeSelectionColor;

  final Color? endRangeSelectionColor;

  final dynamic monthViewSettings;

  final dynamic cellBuilder;

  final dynamic yearCellStyle;

  final dynamic monthCellStyle;

  final dynamic initialDisplayDate;

  final dynamic initialSelectedDate;

  final dynamic minDate;

  final dynamic maxDate;

  final bool enablePastDates;

  final List<dynamic>? initialSelectedDates;

  final dynamic initialSelectedRange;

  final List<dynamic>? initialSelectedRanges;

  final dynamic controller;

  final bool showNavigationArrow;

  final DateRangePickerNavigationDirection navigationDirection;

  final DateRangePickerSelectionShape selectionShape;

  final String? monthFormat;

  final dynamic onViewChanged;

  final DateRangePickerSelectionChangedCallback? onSelectionChanged;

  final DateRangePickerNavigationMode navigationMode;

  final VoidCallback? onCancel;

  final Function(Object?)? onSubmit;

  final bool showTodayButton;

  final dynamic selectableDayPredicate;

  final ExtendableRangeSelectionDirection extendableRangeSelectionDirection;

  final Function(PickerDateRange?, bool)? onTapCallback;

  final Function(PickerDateRange?)? onLongPressCallback;
  final DateRangePickerSelectionChangedCallback? dragEndCallback;

  @override
  _SfDateRangePickerState createState() => _SfDateRangePickerState();
}

class _SfDateRangePickerState extends State<_SfDateRangePicker>
    with SingleTickerProviderStateMixin {
  late List<dynamic> _currentViewVisibleDates;
  dynamic _currentDate, _selectedDate;
  double? _minWidth, _minHeight;
  late double _textScaleFactor;
  late ValueNotifier<List<dynamic>> _headerVisibleDates;
  late ValueNotifier<List<dynamic>> _viewHeaderVisibleDates;
  List<dynamic>? _selectedDates;
  dynamic _selectedRange;
  List<dynamic>? _selectedRanges;
  final GlobalKey<_PickerScrollViewState> _scrollViewKey =
      GlobalKey<_PickerScrollViewState>();
  late DateRangePickerView _view;
  late bool _isRtl;
  late dynamic _controller;
  late Locale _locale;
  late SfLocalizations _localizations;
  late SfDateRangePickerThemeData _datePickerTheme;

  final List<List> _forwardDateCollection = <List>[];

  final List<List> _backwardDateCollection = <List>[];

  Key _scrollKey = UniqueKey();

  Key _pickerKey = UniqueKey();

  ScrollController? _pickerScrollController;

  late double _minPickerWidth;

  late double _minPickerHeight;

  late PickerStateArgs _previousSelectedValue;

  late bool _isMobilePlatform;

  AnimationController? _fadeInController;

  Animation<double>? _fadeIn;

  final ValueNotifier<double> _opacity = ValueNotifier<double>(1);

  @override
  void initState() {
    _isRtl = false;

    _initPickerController();
    _initNavigation();

    _updateSelectionValues();
    _view = DateRangePickerHelper.getPickerView(_controller.view);
    _updateCurrentVisibleDates();
    _headerVisibleDates =
        ValueNotifier<List<dynamic>>(_currentViewVisibleDates);
    _viewHeaderVisibleDates =
        ValueNotifier<List<dynamic>>(_currentViewVisibleDates);
    _controller.addPropertyChangedListener(_pickerValueChangedListener);

    _previousSelectedValue = PickerStateArgs()
      ..selectedDate = _controller.selectedDate
      ..selectedDates =
          DateRangePickerHelper.cloneList(_controller.selectedDates)
      ..selectedRange = _controller.selectedRange
      ..selectedRanges =
          DateRangePickerHelper.cloneList(_controller.selectedRanges);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final TextDirection direction = Directionality.of(context);

    _minPickerWidth = MediaQuery.of(context).size.width;

    _minPickerHeight = 190;
    _locale = Localizations.localeOf(context);
    _localizations = SfLocalizations.of(context);
    _datePickerTheme = _getPickerThemeData(
        SfDateRangePickerTheme.of(context), Theme.of(context).colorScheme);
    _isRtl = direction == TextDirection.rtl;
    _isMobilePlatform =
        DateRangePickerHelper.isMobileLayout(Theme.of(context).platform);
    _fadeInController ??= AnimationController(
        duration: Duration(milliseconds: _isMobilePlatform ? 500 : 600),
        vsync: this)
      ..addListener(_updateFadeAnimation);
    _fadeIn ??= Tween<double>(
      begin: 0.1,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _fadeInController!,
      curve: Curves.easeIn,
    ));
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(_SfDateRangePicker oldWidget) {
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller
          ?.removePropertyChangedListener(_pickerValueChangedListener);
      _controller.removePropertyChangedListener(_pickerValueChangedListener);
      if (widget.controller != null) {
        _controller = widget.controller;
        _controller.selectedDates = _getSelectedDates(
            DateRangePickerHelper.cloneList(widget.controller!.selectedDates));
        _controller.selectedRanges = _getSelectedRanges(
            DateRangePickerHelper.cloneList(widget.controller!.selectedRanges));
        _controller.displayDate ??= _currentDate;
        _currentDate = getValidDate(
            widget.minDate, widget.maxDate, _controller.displayDate);
      } else {
        _initPickerController();
      }

      _controller.view ??= widget.isHijri
          ? DateRangePickerHelper.getHijriPickerView(_view)
          : DateRangePickerHelper.getPickerView(_view);
      _controller.addPropertyChangedListener(_pickerValueChangedListener);
      _initNavigation();
      _updateSelectionValues();
      _view = DateRangePickerHelper.getPickerView(_controller.view);
    }

    final DateRangePickerView view =
        DateRangePickerHelper.getPickerView(_controller.view);
    if (view == DateRangePickerView.month &&
        oldWidget.monthViewSettings.firstDayOfWeek !=
            widget.monthViewSettings.firstDayOfWeek) {
      if (widget.navigationMode == DateRangePickerNavigationMode.scroll) {
        _forwardDateCollection.clear();
        _backwardDateCollection.clear();
      } else {
        _updateCurrentVisibleDates();
        if (widget.navigationDirection ==
            DateRangePickerNavigationDirection.vertical) {
          _viewHeaderVisibleDates.value = _currentViewVisibleDates;
        }
      }
    }

    if (widget.navigationMode != oldWidget.navigationMode) {
      _initializeScrollView();
    }

    if (!widget.isHijri &&
        view == DateRangePickerView.month &&
        widget.navigationMode == DateRangePickerNavigationMode.scroll &&
        oldWidget.monthViewSettings.numberOfWeeksInView !=
            widget.monthViewSettings.numberOfWeeksInView) {
      _initializeScrollView();
    }

    if (view == DateRangePickerView.month &&
        widget.navigationMode == DateRangePickerNavigationMode.scroll &&
        widget.navigationDirection ==
            DateRangePickerNavigationDirection.vertical &&
        oldWidget.monthViewSettings.viewHeaderHeight !=
            widget.monthViewSettings.viewHeaderHeight) {
      _initializeScrollView();
    }

    if (oldWidget.showActionButtons != widget.showActionButtons) {
      if (widget.navigationMode == DateRangePickerNavigationMode.scroll &&
          widget.navigationDirection ==
              DateRangePickerNavigationDirection.vertical) {
        _initializeScrollView();
      }

      if (widget.showActionButtons) {
        _previousSelectedValue = PickerStateArgs()
          ..selectedDate = _controller.selectedDate
          ..selectedDates =
              DateRangePickerHelper.cloneList(_controller.selectedDates)
          ..selectedRange = _controller.selectedRange
          ..selectedRanges =
              DateRangePickerHelper.cloneList(_controller.selectedRanges);
      }
    }

    if ((oldWidget.navigationDirection != widget.navigationDirection ||
            oldWidget.enableMultiView != widget.enableMultiView) &&
        widget.navigationMode == DateRangePickerNavigationMode.scroll) {
      _initializeScrollView();
    }

    if (oldWidget.selectionMode != widget.selectionMode) {
      _updateSelectionValues();
    }

    if (widget.isHijri != oldWidget.isHijri) {
      _currentDate = getValidDate(widget.minDate, widget.maxDate, _currentDate);
      _updateCurrentVisibleDates();
    }

    if (oldWidget.minDate != widget.minDate ||
        oldWidget.maxDate != widget.maxDate) {
      _currentDate = getValidDate(widget.minDate, widget.maxDate, _currentDate);
      if (widget.navigationMode == DateRangePickerNavigationMode.scroll &&
          !_isScrollViewDatesValid()) {
        _initializeScrollView();
      }
    }

    if (_view == DateRangePickerView.month &&
        oldWidget.navigationDirection != widget.navigationDirection) {
      _viewHeaderVisibleDates.value = _currentViewVisibleDates;
    }

    if (!widget.isHijri &&
        DateRangePickerHelper.getNumberOfWeeksInView(
                widget.monthViewSettings, widget.isHijri) !=
            DateRangePickerHelper.getNumberOfWeeksInView(
                oldWidget.monthViewSettings, oldWidget.isHijri)) {
      _currentDate = _updateCurrentDate(oldWidget);
      _controller.displayDate = _currentDate;
    }

    if (oldWidget.controller != widget.controller ||
        widget.controller == null) {
      super.didUpdateWidget(oldWidget);
      return;
    }

    if (oldWidget.controller?.selectedDate != widget.controller?.selectedDate) {
      _selectedDate = _controller.selectedDate;
    }

    if (oldWidget.controller?.selectedDates !=
        widget.controller?.selectedDates) {
      _selectedDates =
          DateRangePickerHelper.cloneList(_controller.selectedDates);
    }

    if (oldWidget.controller?.selectedRange !=
        widget.controller?.selectedRange) {
      _selectedRange = _controller.selectedRange;
    }

    if (oldWidget.controller?.selectedRanges !=
        widget.controller?.selectedRanges) {
      _selectedRanges =
          DateRangePickerHelper.cloneList(_controller.selectedRanges);
    }

    if (oldWidget.controller?.view != widget.controller?.view) {
      _view = DateRangePickerHelper.getPickerView(_controller.view);
      _currentDate = _updateCurrentDate(oldWidget);
      _controller.displayDate = _currentDate;
    }

    if (oldWidget.controller?.displayDate != widget.controller?.displayDate &&
        widget.controller?.displayDate != null) {
      _currentDate =
          getValidDate(widget.minDate, widget.maxDate, _controller.displayDate);
      _controller.displayDate = _currentDate;
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    double top = 0, height;
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      final double? previousWidth = _minWidth;
      final double? previousHeight = _minHeight;
      _minWidth = constraints.maxWidth == double.infinity
          ? _minPickerWidth
          : constraints.maxWidth;
      _minHeight = constraints.maxHeight == double.infinity
          ? _minPickerHeight
          : constraints.maxHeight;

      final double actionButtonsHeight =
          (widget.showActionButtons || widget.showTodayButton)
              ? _minHeight! * 0.1 < 50
                  ? 50
                  : _minHeight! * 0.1
              : 0;
      _handleScrollViewSizeChanged(_minHeight!, _minWidth!, previousHeight,
          previousWidth, actionButtonsHeight);

      height = _minHeight! - widget.headerHeight;
      top = widget.headerHeight;
      if (_view == DateRangePickerView.month &&
          widget.navigationDirection ==
              DateRangePickerNavigationDirection.vertical) {
        height -= widget.monthViewSettings.viewHeaderHeight;
        top += widget.monthViewSettings.viewHeaderHeight;
      }

      return Container(
        width: _minWidth,
        height: _minHeight,
        color: widget.backgroundColor ?? _datePickerTheme.backgroundColor,
        child: widget.navigationMode == DateRangePickerNavigationMode.scroll
            ? _addScrollView(
                _minWidth!,
                _minHeight!,
                actionButtonsHeight,
                widget.onTapCallback,
                widget.onLongPressCallback,
                widget.dragEndCallback)
            : _addChildren(
                top,
                height,
                _minWidth!,
                actionButtonsHeight,
                widget.onTapCallback,
                widget.onLongPressCallback,
                widget.dragEndCallback),
      );
    });
  }

  @override
  void dispose() {
    _controller.removePropertyChangedListener(_pickerValueChangedListener);

    if (_fadeInController != null) {
      _fadeInController!.removeListener(_updateFadeAnimation);
      _fadeInController!.dispose();
      _fadeInController = null;
    }

    if (_fadeIn != null) {
      _fadeIn = null;
    }
    super.dispose();
  }

  SfDateRangePickerThemeData _getPickerThemeData(
      SfDateRangePickerThemeData pickerTheme, ColorScheme colorScheme) {
    return pickerTheme.copyWith(
        brightness: pickerTheme.brightness ?? colorScheme.brightness,
        backgroundColor: pickerTheme.backgroundColor ?? Colors.transparent,
        headerBackgroundColor:
            pickerTheme.headerBackgroundColor ?? Colors.transparent,
        viewHeaderBackgroundColor:
            pickerTheme.viewHeaderBackgroundColor ?? Colors.transparent,
        weekNumberBackgroundColor: pickerTheme.weekNumberBackgroundColor ??
            colorScheme.onSurface.withOpacity(0.08),
        viewHeaderTextStyle: pickerTheme.viewHeaderTextStyle ??
            TextStyle(
                color: colorScheme.onSurface.withOpacity(0.87),
                fontSize: 14,
                fontFamily: 'Roboto'),
        headerTextStyle: pickerTheme.headerTextStyle ??
            TextStyle(
                color: colorScheme.onSurface.withOpacity(0.87),
                fontSize: 16,
                fontFamily: 'Roboto'),
        trailingDatesTextStyle: pickerTheme.trailingDatesTextStyle ??
            TextStyle(
                color: colorScheme.onSurface.withOpacity(0.54),
                fontSize: 13,
                fontFamily: 'Roboto'),
        leadingCellTextStyle: pickerTheme.leadingCellTextStyle ??
            TextStyle(
                color: colorScheme.onSurface.withOpacity(0.54),
                fontSize: 13,
                fontFamily: 'Roboto'),
        activeDatesTextStyle: pickerTheme.activeDatesTextStyle ??
            TextStyle(
                color: colorScheme.onSurface.withOpacity(0.87),
                fontSize: 13,
                fontFamily: 'Roboto'),
        cellTextStyle: pickerTheme.cellTextStyle ??
            TextStyle(
                color: colorScheme.onSurface.withOpacity(0.87),
                fontSize: 13,
                fontFamily: 'Roboto'),
        leadingDatesTextStyle: pickerTheme.leadingDatesTextStyle ??
            TextStyle(
                color: colorScheme.onSurface.withOpacity(0.54),
                fontSize: 13,
                fontFamily: 'Roboto'),
        rangeSelectionTextStyle: pickerTheme.rangeSelectionTextStyle ??
            TextStyle(
                color: colorScheme.onSurface.withOpacity(0.87),
                fontSize: 13,
                fontFamily: 'Roboto'),
        disabledDatesTextStyle: pickerTheme.disabledDatesTextStyle ??
            TextStyle(
                color: colorScheme.onSurface.withOpacity(0.38),
                fontSize: 13,
                fontFamily: 'Roboto'),
        disabledCellTextStyle: pickerTheme.disabledCellTextStyle ??
            TextStyle(
                color: colorScheme.onSurface.withOpacity(0.38),
                fontSize: 13,
                fontFamily: 'Roboto'),
        selectionTextStyle: pickerTheme.selectionTextStyle ??
            TextStyle(
                color: colorScheme.onPrimary,
                fontSize: 13,
                fontFamily: 'Roboto'),
        weekNumberTextStyle: pickerTheme.weekNumberTextStyle ??
            TextStyle(
                color: colorScheme.onSurface.withOpacity(0.87),
                fontSize: 13,
                fontFamily: 'Roboto'),
        todayTextStyle: pickerTheme.todayTextStyle ??
            TextStyle(
                color: colorScheme.primary, fontSize: 13, fontFamily: 'Roboto'),
        todayCellTextStyle: pickerTheme.todayCellTextStyle ??
            TextStyle(
                color: colorScheme.primary, fontSize: 13, fontFamily: 'Roboto'),
        selectionColor: pickerTheme.selectionColor ?? colorScheme.primary,
        startRangeSelectionColor:
            pickerTheme.startRangeSelectionColor ?? colorScheme.primary,
        rangeSelectionColor: pickerTheme.rangeSelectionColor ??
            colorScheme.primary.withOpacity(0.1),
        endRangeSelectionColor:
            pickerTheme.endRangeSelectionColor ?? colorScheme.primary,
        todayHighlightColor:
            pickerTheme.todayHighlightColor ?? colorScheme.primary);
  }

  void _updateFadeAnimation() {
    if (!mounted) {
      return;
    }

    _opacity.value = _fadeIn!.value;
  }

  void _initNavigation() {
    _controller.forward = _moveToNextView;
    _controller.backward = _moveToPreviousView;
  }

  void _initPickerController() {
    _controller = widget.controller ??
        (widget.isHijri
            ? HijriDatePickerController()
            : DateRangePickerController());
    _controller.selectedDate = widget.initialSelectedDate;
    _controller.selectedDates = _getSelectedDates(
        DateRangePickerHelper.cloneList(widget.initialSelectedDates));
    _controller.selectedRange = widget.initialSelectedRange;
    _controller.selectedRanges =
        DateRangePickerHelper.cloneList(widget.initialSelectedRanges);
    _controller.view = widget.isHijri
        ? DateRangePickerHelper.getHijriPickerView(widget.view)
        : DateRangePickerHelper.getPickerView(widget.view);
    _currentDate =
        getValidDate(widget.minDate, widget.maxDate, widget.initialDisplayDate);
    _controller.displayDate = _currentDate;
  }

  void _updateSelectionValues() {
    _selectedDate = _controller.selectedDate;
    _selectedDates = DateRangePickerHelper.cloneList(_controller.selectedDates);
    _selectedRange = _controller.selectedRange;
    _selectedRanges =
        DateRangePickerHelper.cloneList(_controller.selectedRanges);
  }

  void _pickerValueChangedListener(String value) {
    if (value == 'selectedDate') {
      if (!mounted || isSameDate(_selectedDate, _controller.selectedDate)) {
        return;
      }

      _raiseSelectionChangedCallback(widget, value: _controller.selectedDate);
      setState(() {
        _selectedDate = _controller.selectedDate;
      });
    } else if (value == 'selectedDates') {
      if (!mounted ||
          DateRangePickerHelper.isDateCollectionEquals(
              _selectedDates, _controller.selectedDates)) {
        return;
      }

      _raiseSelectionChangedCallback(widget, value: _controller.selectedDates);
      setState(() {
        _selectedDates =
            DateRangePickerHelper.cloneList(_controller.selectedDates);
      });
    } else if (value == 'selectedRange') {
      if (!mounted ||
          DateRangePickerHelper.isRangeEquals(
              _selectedRange, _controller.selectedRange)) {
        return;
      }

      _raiseSelectionChangedCallback(widget, value: _controller.selectedRange);
      setState(() {
        _selectedRange = _controller.selectedRange;
      });
    } else if (value == 'selectedRanges') {
      if (!mounted ||
          DateRangePickerHelper.isDateRangesEquals(
              _selectedRanges, _controller.selectedRanges)) {
        return;
      }

      _raiseSelectionChangedCallback(widget, value: _controller.selectedRanges);
      setState(() {
        _selectedRanges =
            DateRangePickerHelper.cloneList(_controller.selectedRanges);
      });
    } else if (value == 'view') {
      if (!mounted ||
          _view == DateRangePickerHelper.getPickerView(_controller.view)) {
        return;
      }

      _fadeInController!.reset();
      _fadeInController!.forward();

      setState(() {
        _view = DateRangePickerHelper.getPickerView(_controller.view);
        if (widget.navigationMode == DateRangePickerNavigationMode.scroll) {
          _initializeScrollView();
        } else {
          _scrollViewKey.currentState!._position = 0.0;
          _scrollViewKey.currentState!._children.clear();
          _scrollViewKey.currentState!._updateVisibleDates();
          _scrollViewKey.currentState!._triggerSelectableDayPredicates(
              _scrollViewKey.currentState!._currentViewVisibleDates);
          _scrollViewKey.currentState!._triggerViewChangedCallback();
        }
      });
    } else if (value == 'displayDate') {
      if (!isSameOrAfterDate(widget.minDate, _controller.displayDate)) {
        _controller.displayDate = widget.minDate;
        return;
      }

      if (!isSameOrBeforeDate(widget.maxDate, _controller.displayDate)) {
        _controller.displayDate = widget.maxDate;
        return;
      }

      if (isSameDate(_currentDate, _controller.displayDate) ||
          _checkDateWithInVisibleDates(_controller.displayDate)) {
        _currentDate = _controller.displayDate;
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _currentDate = _controller.displayDate;
        if (widget.navigationMode == DateRangePickerNavigationMode.scroll) {
          _initializeScrollView();
        } else {
          _updateCurrentVisibleDates();
        }
      });
    }
  }

  bool _checkDateWithInVisibleDates(dynamic date) {
    final DateRangePickerView view =
        DateRangePickerHelper.getPickerView(_controller.view);
    switch (view) {
      case DateRangePickerView.month:
        {
          if (!widget.isHijri &&
              DateRangePickerHelper.getNumberOfWeeksInView(
                      widget.monthViewSettings, widget.isHijri) !=
                  6) {
            return isDateWithInDateRange(
                _currentViewVisibleDates[0],
                _currentViewVisibleDates[_currentViewVisibleDates.length - 1],
                date);
          } else {
            final dynamic currentMonth = _currentViewVisibleDates[
                _currentViewVisibleDates.length ~/
                    (_isMultiViewEnabled(widget) ? 4 : 2)];
            return date.month == currentMonth.month &&
                date.year == currentMonth.year;
          }
        }
      case DateRangePickerView.year:
        {
          final int currentYear = _currentViewVisibleDates[0].year as int;
          final int year = date.year as int;

          return currentYear == year;
        }
      case DateRangePickerView.decade:
        {
          final int minYear = _currentViewVisibleDates[0].year as int;
          final int maxYear = (_currentViewVisibleDates[10].year as int) - 1;
          final int year = date.year as int;
          return minYear <= year && maxYear >= year;
        }
      case DateRangePickerView.century:
        {
          final int minYear = _currentViewVisibleDates[0].year as int;
          final int maxYear = (_currentViewVisibleDates[10].year as int) - 1;
          final int year = date.year as int;

          return minYear <= year && maxYear >= year;
        }
    }
  }

  void _updateCurrentVisibleDates() {
    switch (_view) {
      case DateRangePickerView.month:
        {
          _currentViewVisibleDates = getVisibleDates(
            _currentDate,
            null,
            widget.monthViewSettings.firstDayOfWeek,
            DateRangePickerHelper.getViewDatesCount(
                _view,
                DateRangePickerHelper.getNumberOfWeeksInView(
                    widget.monthViewSettings, widget.isHijri),
                widget.isHijri),
          );
        }
        break;
      case DateRangePickerView.year:
      case DateRangePickerView.decade:
      case DateRangePickerView.century:
        {
          _currentViewVisibleDates = DateRangePickerHelper.getVisibleYearDates(
              _currentDate, _view, widget.isHijri);
        }
    }
  }

  dynamic _updateCurrentDate(_SfDateRangePicker oldWidget) {
    if (oldWidget.controller == widget.controller &&
        widget.controller != null &&
        oldWidget.controller?.view == DateRangePickerView.month &&
        DateRangePickerHelper.getPickerView(_controller.view) !=
            DateRangePickerView.month) {
      return _currentViewVisibleDates[_currentViewVisibleDates.length ~/
          (_isMultiViewEnabled(widget) ? 4 : 2)];
    }

    return _currentViewVisibleDates[0];
  }

  void _initializeScrollView() {
    _forwardDateCollection.clear();
    _backwardDateCollection.clear();
    _scrollKey = UniqueKey();
    _pickerKey = UniqueKey();
  }

  bool _isScrollViewDatesValid() {
    if (_forwardDateCollection.isEmpty) {
      return true;
    }
    final DateRangePickerView view =
        DateRangePickerHelper.getPickerView(_controller.view);
    final int numberOfWeekInView = DateRangePickerHelper.getNumberOfWeeksInView(
        widget.monthViewSettings, widget.isHijri);

    final List startDates = _backwardDateCollection.isNotEmpty
        ? _backwardDateCollection[_backwardDateCollection.length - 1]
        : _forwardDateCollection[0];

    final List endDates =
        _forwardDateCollection[_forwardDateCollection.length - 1];
    switch (view) {
      case DateRangePickerView.month:
        {
          if (!widget.isHijri && numberOfWeekInView != 6) {
            final DateTime visibleStartDate =
                DateRangePickerHelper.getDateTimeValue(
                    startDates[startDates.length - 1]);
            final DateTime visibleEndDate =
                DateRangePickerHelper.getDateTimeValue(endDates[0]);
            return isDateWithInDateRange(
                    widget.minDate, widget.maxDate, visibleStartDate) &&
                isDateWithInDateRange(
                    widget.minDate, widget.maxDate, visibleEndDate);
          } else {
            final DateTime visibleStartDate =
                DateRangePickerHelper.getDateTimeValue(
                    startDates[startDates.length ~/ 2]);
            final DateTime visibleEndDate =
                DateRangePickerHelper.getDateTimeValue(
                    endDates[endDates.length ~/ 2]);
            return (visibleStartDate.year > widget.minDate.year ||
                    (visibleStartDate.year == widget.minDate.year &&
                        visibleStartDate.month >= widget.minDate.month)) &&
                (visibleStartDate.year < widget.maxDate.year ||
                    (visibleStartDate.year == widget.maxDate.year &&
                        visibleStartDate.month <= widget.maxDate.month)) &&
                (visibleEndDate.year > widget.minDate.year ||
                    (visibleEndDate.year == widget.minDate.year &&
                        visibleEndDate.month >= widget.minDate.month)) &&
                (visibleEndDate.year < widget.maxDate.year ||
                    (visibleEndDate.year == widget.maxDate.year &&
                        visibleEndDate.month <= widget.maxDate.month));
          }
        }
      case DateRangePickerView.year:
        {
          final int visibleStartYear = startDates[0].year as int;
          final int visibleEndYear = endDates[0].year as int;
          return widget.minDate.year <= visibleStartYear == true &&
              widget.maxDate.year >= visibleStartYear == true &&
              widget.minDate.year <= visibleEndYear == true &&
              widget.maxDate.year >= visibleEndYear == true;
        }
      case DateRangePickerView.decade:
        {
          final int visibleStartYear = ((startDates[0].year as int) ~/ 10) * 10;
          final int visibleEndYear = ((endDates[0].year as int) ~/ 10) * 10;
          final int minDateYear = ((widget.minDate.year as int) ~/ 10) * 10;
          final int maxDateYear = ((widget.maxDate.year as int) ~/ 10) * 10;
          return minDateYear <= visibleStartYear &&
              maxDateYear >= visibleStartYear &&
              minDateYear <= visibleEndYear &&
              maxDateYear >= visibleEndYear;
        }
      case DateRangePickerView.century:
        {
          final int visibleStartYear =
              ((startDates[0].year as int) ~/ 100) * 100;
          final int visibleEndYear = ((endDates[0].year as int) ~/ 100) * 100;
          final int minDateYear = ((widget.minDate.year as int) ~/ 100) * 100;
          final int maxDateYear = ((widget.maxDate.year as int) ~/ 100) * 100;
          return minDateYear <= visibleStartYear &&
              maxDateYear >= visibleStartYear &&
              minDateYear <= visibleEndYear &&
              maxDateYear >= visibleEndYear;
        }
    }
  }

  void _handleScrollViewSizeChanged(double newHeight, double newWidth,
      double? oldHeight, double? oldWidth, double actionButtonHeight) {
    if (widget.navigationMode != DateRangePickerNavigationMode.scroll ||
        _pickerScrollController == null ||
        !_pickerScrollController!.hasClients) {
      return;
    }

    if (oldWidth != null &&
        widget.navigationDirection ==
            DateRangePickerNavigationDirection.horizontal &&
        oldWidth != newWidth) {
      final double index = _pickerScrollController!.position.pixels / oldWidth;
      _pickerScrollController!.removeListener(_handleScrollChanged);
      _pickerScrollController!.dispose();
      _scrollKey = UniqueKey();
      _pickerKey = UniqueKey();
      _pickerScrollController =
          ScrollController(initialScrollOffset: index * newWidth)
            ..addListener(_handleScrollChanged);
    } else if (oldHeight != null &&
        widget.navigationDirection ==
            DateRangePickerNavigationDirection.vertical &&
        oldHeight != newHeight) {
      final double viewHeaderHeight = _view == DateRangePickerView.month
          ? widget.monthViewSettings.viewHeaderHeight as double
          : 0;
      final double viewSize = oldHeight - viewHeaderHeight - actionButtonHeight;
      final double index = _pickerScrollController!.position.pixels / viewSize;
      _pickerScrollController!.removeListener(_handleScrollChanged);
      _pickerScrollController!.dispose();
      _scrollKey = UniqueKey();
      _pickerKey = UniqueKey();
      _pickerScrollController = ScrollController(
          initialScrollOffset:
              index * (newHeight - viewHeaderHeight - actionButtonHeight))
        ..addListener(_handleScrollChanged);
    }
  }

  void _handleScrollChanged() {
    final double scrolledPosition = _pickerScrollController!.position.pixels;
    final double actionButtonsHeight = widget.showActionButtons
        ? _minHeight! * 0.1 < 50
            ? 50
            : _minHeight! * 0.1
        : 0;
    double widgetSize = widget.navigationDirection ==
            DateRangePickerNavigationDirection.horizontal
        ? _minWidth!
        : _minHeight! -
            (_view == DateRangePickerView.month
                ? widget.monthViewSettings.viewHeaderHeight
                : 0) -
            actionButtonsHeight;
    if (widget.enableMultiView) {
      widgetSize /= 2;
    }

    bool isViewChanged = false;
    List<dynamic> visibleDates;
    if (scrolledPosition >= 0) {
      final int index = scrolledPosition ~/ widgetSize;
      if (index >= _forwardDateCollection.length) {
        return;
      }

      visibleDates = _forwardDateCollection[index];
      if (isSameDate(_currentViewVisibleDates[0], visibleDates[0])) {
        return;
      }

      isViewChanged = true;
    } else {
      final int index = -(scrolledPosition ~/ widgetSize);
      if (index >= _backwardDateCollection.length) {
        return;
      }

      visibleDates = _backwardDateCollection[index];
      if (isSameDate(_currentViewVisibleDates[0], visibleDates[0])) {
        return;
      }

      isViewChanged = true;
    }

    if (!isViewChanged) {
      return;
    }

    dynamic currentDate = visibleDates[0];
    final int numberOfWeeksInView =
        DateRangePickerHelper.getNumberOfWeeksInView(
            widget.monthViewSettings, widget.isHijri);
    if (_view == DateRangePickerView.month &&
        (numberOfWeeksInView == 6 || widget.isHijri)) {
      final dynamic date = visibleDates[visibleDates.length ~/ 2];
      currentDate = DateRangePickerHelper.getDate(
          date.year, date.month, 1, widget.isHijri);
    }

    _currentDate = getValidDate(widget.minDate, widget.maxDate, currentDate);
    _controller.displayDate = _currentDate;
    _currentViewVisibleDates = visibleDates;
    _notifyCurrentVisibleDatesChanged();
  }

  void _addScrollViewDateCollection(
      List<dynamic> dateCollection,
      bool isNextView,
      dynamic startDate,
      DateRangePickerView currentView,
      int numberOfWeeksInView,
      int visibleDatesCount) {
    int count = 0;
    dynamic visibleDate = startDate;
    while (count < 10) {
      switch (currentView) {
        case DateRangePickerView.month:
          {
            final List visibleDates = getVisibleDates(
              visibleDate,
              null,
              widget.monthViewSettings.firstDayOfWeek,
              visibleDatesCount,
            );

            if (isNextView) {
              if (!widget.isHijri && numberOfWeeksInView != 6) {
                final dynamic date = visibleDates[0];
                if (!isSameOrBeforeDate(widget.maxDate, date)) {
                  count = 10;
                  break;
                }
              } else {
                final dynamic date = visibleDates[visibleDates.length ~/ 2];
                if ((date.month > widget.maxDate.month == true &&
                        date.year == widget.maxDate.year) ||
                    date.year > widget.maxDate.year == true) {
                  count = 10;
                  break;
                }
              }
            } else {
              if (numberOfWeeksInView != 6 && !widget.isHijri) {
                final dynamic date = visibleDates[visibleDates.length - 1];
                if (!isSameOrAfterDate(widget.minDate, date)) {
                  count = 10;
                  break;
                }
              } else {
                final dynamic date = visibleDates[visibleDates.length ~/ 2];
                if ((date.month < widget.minDate.month == true &&
                        date.year == widget.minDate.year) ||
                    date.year < widget.minDate.year == true) {
                  count = 10;
                  break;
                }
              }
            }

            dateCollection.add(visibleDates);
            if (isNextView) {
              visibleDate = DateRangePickerHelper.getNextViewStartDate(
                  currentView,
                  numberOfWeeksInView,
                  visibleDate,
                  false,
                  widget.isHijri);
            } else {
              visibleDate = DateRangePickerHelper.getPreviousViewStartDate(
                  currentView,
                  numberOfWeeksInView,
                  visibleDate,
                  false,
                  widget.isHijri);
            }
            count++;
          }
          break;
        case DateRangePickerView.decade:
        case DateRangePickerView.year:
        case DateRangePickerView.century:
          {
            if (isNextView) {
              final int currentYear = visibleDate.year as int;
              final int maxYear = widget.maxDate.year as int;
              final int offset = DateRangePickerHelper.getOffset(currentView);
              if (((currentYear ~/ offset) * offset) >
                  ((maxYear ~/ offset) * offset)) {
                count = 10;
                break;
              }
            } else {
              final int currentYear = visibleDate.year as int;
              final int minYear = widget.minDate.year as int;
              final int offset = DateRangePickerHelper.getOffset(currentView);
              if (((currentYear ~/ offset) * offset) <
                  ((minYear ~/ offset) * offset)) {
                count = 10;
                break;
              }
            }

            final List visibleDates = DateRangePickerHelper.getVisibleYearDates(
              visibleDate,
              currentView,
              widget.isHijri,
            );

            dateCollection.add(visibleDates);
            if (isNextView) {
              visibleDate = DateRangePickerHelper.getNextViewStartDate(
                  currentView,
                  numberOfWeeksInView,
                  visibleDate,
                  false,
                  widget.isHijri);
            } else {
              visibleDate = DateRangePickerHelper.getPreviousViewStartDate(
                  currentView,
                  numberOfWeeksInView,
                  visibleDate,
                  false,
                  widget.isHijri);
            }
            count++;
          }
          break;
      }
    }
  }

  Widget _addScrollView(
      double width,
      double height,
      double actionButtonsHeight,
      Function(PickerDateRange?, bool)? onTapCallback,
      Function(PickerDateRange?)? onLongPressCallback,
      DateRangePickerSelectionChangedCallback? dragEndCallback) {
    _pickerScrollController ??= ScrollController()
      ..addListener(_handleScrollChanged);
    final DateRangePickerView currentView =
        DateRangePickerHelper.getPickerView(_view);
    final int numberOfWeeksInView =
        DateRangePickerHelper.getNumberOfWeeksInView(
            widget.monthViewSettings, widget.isHijri);
    final int visibleDatesCount = DateRangePickerHelper.getViewDatesCount(
        currentView, numberOfWeeksInView, widget.isHijri);
    final bool isInitialLoading = _forwardDateCollection.isEmpty;
    if (isInitialLoading) {
      _addScrollViewDateCollection(_forwardDateCollection, true, _currentDate,
          currentView, numberOfWeeksInView, visibleDatesCount);
    }

    if (_backwardDateCollection.isEmpty) {
      final List? lastViewDates = _forwardDateCollection[0];
      dynamic visibleDate =
          currentView == DateRangePickerView.month && numberOfWeeksInView != 6
              ? lastViewDates != null && lastViewDates.isNotEmpty
                  ? lastViewDates[0]
                  : _currentDate
              : lastViewDates != null && lastViewDates.isNotEmpty
                  ? lastViewDates[lastViewDates.length ~/ 2]
                  : _currentDate;
      visibleDate = DateRangePickerHelper.getPreviousViewStartDate(
          currentView, numberOfWeeksInView, visibleDate, false, widget.isHijri);
      _addScrollViewDateCollection(_backwardDateCollection, false, visibleDate,
          currentView, numberOfWeeksInView, visibleDatesCount);
    }

    int forwardCollectionLength = _forwardDateCollection.length;
    final int minForwardCollectionLength = widget.enableMultiView ? 2 : 1;

    while (_backwardDateCollection.isNotEmpty &&
        forwardCollectionLength < minForwardCollectionLength) {
      _forwardDateCollection.insert(0, _backwardDateCollection[0]);
      _backwardDateCollection.removeAt(0);
      forwardCollectionLength += 1;
    }

    if (isInitialLoading) {
      _currentViewVisibleDates = _forwardDateCollection[0];
      _notifyCurrentVisibleDatesChanged();
    }

    final bool isHorizontal = widget.navigationDirection ==
        DateRangePickerNavigationDirection.horizontal;
    final double topPosition =
        _view == DateRangePickerView.month && !isHorizontal
            ? widget.monthViewSettings.viewHeaderHeight as double
            : 0.0;
    final double scrollViewHeight = height - topPosition - actionButtonsHeight;
    double scrollViewItemHeight = scrollViewHeight;
    double scrollViewItemWidth = width;
    if (isHorizontal) {
      scrollViewItemWidth = widget.enableMultiView
          ? scrollViewItemWidth / 2
          : scrollViewItemWidth;
    } else {
      scrollViewItemHeight = widget.enableMultiView
          ? scrollViewItemHeight / 2
          : scrollViewItemHeight;
    }

    final Widget scrollView = CustomScrollView(
      scrollDirection: isHorizontal ? Axis.horizontal : Axis.vertical,
      key: _scrollKey,
      physics: const AlwaysScrollableScrollPhysics(
          parent:
              ClampingScrollPhysics(parent: RangeMaintainingScrollPhysics())),
      controller: _pickerScrollController,
      center: _pickerKey,
      slivers: <Widget>[
        SliverFixedExtentList(
          itemExtent: isHorizontal ? scrollViewItemWidth : scrollViewItemHeight,
          delegate:
              SliverChildBuilderDelegate((BuildContext context, int index) {
            if (_backwardDateCollection.length <= index) {
              return null;
            }

            return _getScrollViewItem(
                -(index + 1),
                scrollViewItemWidth,
                scrollViewItemHeight,
                _backwardDateCollection[index],
                isHorizontal,
                onTapCallback,
                onLongPressCallback,
                dragEndCallback);
          }),
        ),
        SliverFixedExtentList(
          itemExtent: isHorizontal ? scrollViewItemWidth : scrollViewItemHeight,
          delegate:
              SliverChildBuilderDelegate((BuildContext context, int index) {
            if (_forwardDateCollection.length <= index) {
              return null;
            }

            return _getScrollViewItem(
                index,
                scrollViewItemWidth,
                scrollViewItemHeight,
                _forwardDateCollection[index],
                isHorizontal,
                onTapCallback,
                onLongPressCallback,
                dragEndCallback);
          }),
          key: _pickerKey,
        ),
      ],
    );

    if (isHorizontal) {
      return Stack(
        children: <Widget>[
          scrollView,
          _getActionsButton(
              topPosition + scrollViewHeight, actionButtonsHeight),
        ],
      );
    } else {
      _viewHeaderVisibleDates.value = _currentViewVisibleDates;
      return Stack(children: <Widget>[
        _getViewHeaderView(0),
        Positioned(
            left: 0,
            top: topPosition,
            right: 0,
            height: scrollViewHeight,
            child: scrollView),
        _getActionsButton(topPosition + scrollViewHeight, actionButtonsHeight)
      ]);
    }
  }

  Widget _getScrollViewItem(
    int index,
    double width,
    double height,
    List dates,
    bool isHorizontal,
    Function(PickerDateRange?, bool)? onTapCallback,
    Function(PickerDateRange?)? onLongPressCallback,
    DateRangePickerSelectionChangedCallback? dragEndCallback,
  ) {
    final DateRangePickerView currentView =
        DateRangePickerHelper.getPickerView(_view);
    final int numberOfWeeksInView =
        DateRangePickerHelper.getNumberOfWeeksInView(
            widget.monthViewSettings, widget.isHijri);
    final int visibleDatesCount = DateRangePickerHelper.getViewDatesCount(
        currentView, numberOfWeeksInView, widget.isHijri);
    if (index >= 0) {
      if (_forwardDateCollection.isNotEmpty &&
          index > _forwardDateCollection.length - 2) {
        final List lastViewDates =
            _forwardDateCollection[_forwardDateCollection.length - 1];
        dynamic date = currentView == DateRangePickerView.month &&
                DateRangePickerHelper.getNumberOfWeeksInView(
                        widget.monthViewSettings, widget.isHijri) !=
                    6
            ? lastViewDates[0]
            : lastViewDates[lastViewDates.length ~/ 2];
        date = DateRangePickerHelper.getNextViewStartDate(
            currentView, numberOfWeeksInView, date, false, widget.isHijri);
        _addScrollViewDateCollection(_forwardDateCollection, true, date,
            currentView, numberOfWeeksInView, visibleDatesCount);
      }
    } else {
      if (_backwardDateCollection.isNotEmpty &&
          -index > _backwardDateCollection.length - 2) {
        final List lastViewDates =
            _backwardDateCollection[_backwardDateCollection.length - 1];
        dynamic date = currentView == DateRangePickerView.month &&
                DateRangePickerHelper.getNumberOfWeeksInView(
                        widget.monthViewSettings, widget.isHijri) !=
                    6
            ? lastViewDates[0]
            : lastViewDates[lastViewDates.length ~/ 2];
        date = DateRangePickerHelper.getPreviousViewStartDate(
            currentView, numberOfWeeksInView, date, false, widget.isHijri);
        _addScrollViewDateCollection(_backwardDateCollection, false, date,
            currentView, numberOfWeeksInView, visibleDatesCount);
      }
    }

    final double pickerHeight = height - widget.headerHeight;
    final double pickerWidth = width - (isHorizontal ? 1 : 0);
    double headerWidth = pickerWidth;
    if (isHorizontal) {
      final String headerText = _getHeaderText(
          dates,
          _view,
          0,
          widget.isHijri,
          numberOfWeeksInView,
          widget.monthFormat,
          false,
          widget.headerStyle,
          widget.navigationDirection,
          _locale,
          _localizations);
      headerWidth = _getTextWidgetWidth(
              headerText, widget.headerHeight, pickerWidth, context,
              style: widget.headerStyle.textStyle ??
                  _datePickerTheme.headerTextStyle!,
              widthPadding: 20)
          .width;
    }

    if (headerWidth > pickerWidth) {
      headerWidth = pickerWidth;
    }

    Color? backgroundColor = widget.headerStyle.backgroundColor ??
        _datePickerTheme.headerBackgroundColor;
    if (!isHorizontal && backgroundColor == Colors.transparent) {
      backgroundColor = _datePickerTheme.brightness == Brightness.dark
          ? Colors.grey[850]!
          : Colors.white;
    }
    final Widget header = Positioned(
      top: 0,
      left: 0,
      width: headerWidth,
      height: widget.headerHeight,
      child: GestureDetector(
        child: Container(
          color: backgroundColor,
          height: widget.headerHeight,
          child: _PickerHeaderView(
              ValueNotifier<List<dynamic>>(dates),
              widget.headerStyle,
              widget.selectionMode,
              _view,
              DateRangePickerHelper.getNumberOfWeeksInView(
                  widget.monthViewSettings, widget.isHijri),
              widget.showNavigationArrow,
              widget.navigationDirection,
              widget.monthViewSettings.enableSwipeSelection,
              widget.navigationMode,
              widget.minDate,
              widget.maxDate,
              widget.monthFormat,
              _datePickerTheme,
              _locale,
              headerWidth,
              widget.headerHeight,
              widget.allowViewNavigation,
              _controller.backward,
              _controller.forward,
              _isMultiViewEnabled(widget),
              widget.viewSpacing,
              widget.selectionColor ?? _datePickerTheme.selectionColor!,
              _isRtl,
              _textScaleFactor,
              widget.isHijri,
              _localizations),
        ),
        onTapUp: (TapUpDetails details) {
          if (_view == DateRangePickerView.century ||
              !widget.allowViewNavigation) {
            return;
          }

          dynamic currentDate = dates[0];
          final int numberOfWeeksInView =
              DateRangePickerHelper.getNumberOfWeeksInView(
                  widget.monthViewSettings, widget.isHijri);
          if (_view == DateRangePickerView.month &&
              (numberOfWeeksInView == 6 || widget.isHijri)) {
            final dynamic date = dates[dates.length ~/ 2];
            currentDate = DateRangePickerHelper.getDate(
                date.year, date.month, 1, widget.isHijri);
          }

          currentDate =
              getValidDate(widget.minDate, widget.maxDate, currentDate);

          if ((_view == DateRangePickerView.month &&
                  _currentDate.year != currentDate.year) ||
              (_view == DateRangePickerView.year &&
                  _currentDate.year ~/ 10 != currentDate.year ~/ 10) ||
              (_view == DateRangePickerView.decade &&
                  _currentDate.year ~/ 100 != currentDate.year ~/ 100)) {
            _currentDate = currentDate;
            _controller.displayDate = _currentDate;
          }
          _updateCalendarTapCallbackForHeader();
        },
      ),
    );
    final Widget pickerView = Positioned(
      top: widget.headerHeight,
      left: 0,
      width: pickerWidth,
      height: pickerHeight,
      child: _AnimatedOpacityWidget(
        opacity: _opacity,
        child: _PickerView(
          widget,
          _controller,
          dates,
          _isMultiViewEnabled(widget),
          pickerWidth,
          pickerHeight,
          _datePickerTheme,
          null,
          _textScaleFactor,
          null,
          getPickerStateDetails: _getPickerStateValues,
          updatePickerStateDetails: _updatePickerStateValues,
          isRtl: _isRtl,
          onTapCallback: onTapCallback,
          onLongPressCallback: onLongPressCallback,
          dragEndCallback: dragEndCallback,
        ),
      ),
    );

    final List<Widget> children = <Widget>[pickerView];
    if (isHorizontal) {
      children.add(Positioned(
        top: 0,
        left: pickerWidth,
        width: 1,
        height: height,
        child: const VerticalDivider(
          thickness: 1,
        ),
      ));
    }

    children.add(header);
    return SizedBox(
        width: width,
        height: height,
        child: _StickyHeader(
          isHorizontal: isHorizontal,
          isRTL: _isRtl,
          children: children,
        ));
  }

  Widget _addChildren(
    double top,
    double height,
    double width,
    double actionButtonsHeight,
    Function(PickerDateRange?, bool)? onTapCallback,
    Function(PickerDateRange?)? onLongPressCallback,
    DateRangePickerSelectionChangedCallback? dragEndCallback,
  ) {
    _headerVisibleDates.value = _currentViewVisibleDates;
    height -= actionButtonsHeight;
    return Stack(children: <Widget>[
      Positioned(
        top: 0,
        right: 0,
        left: 0,
        height: widget.headerHeight,
        child: GestureDetector(
          child: Container(
            color: widget.headerStyle.backgroundColor ??
                _datePickerTheme.headerBackgroundColor,
            height: widget.headerHeight,
            child: _PickerHeaderView(
                _headerVisibleDates,
                widget.headerStyle,
                widget.selectionMode,
                _view,
                DateRangePickerHelper.getNumberOfWeeksInView(
                    widget.monthViewSettings, widget.isHijri),
                widget.showNavigationArrow,
                widget.navigationDirection,
                widget.monthViewSettings.enableSwipeSelection,
                widget.navigationMode,
                widget.minDate,
                widget.maxDate,
                widget.monthFormat,
                _datePickerTheme,
                _locale,
                width,
                widget.headerHeight,
                widget.allowViewNavigation,
                _controller.backward,
                _controller.forward,
                _isMultiViewEnabled(widget),
                widget.viewSpacing,
                widget.selectionColor ?? _datePickerTheme.selectionColor!,
                _isRtl,
                _textScaleFactor,
                widget.isHijri,
                _localizations),
          ),
          onTapUp: (TapUpDetails details) {
            _updateCalendarTapCallbackForHeader();
          },
        ),
      ),
      _getViewHeaderView(widget.headerHeight),
      Positioned(
        top: top,
        left: 0,
        right: 0,
        height: height,
        child: _AnimatedOpacityWidget(
          opacity: _opacity,
          child: _PickerScrollView(
            widget,
            _controller,
            width,
            height,
            _isRtl,
            _datePickerTheme,
            _locale,
            _textScaleFactor,
            getPickerStateValues: (PickerStateArgs details) {
              _getPickerStateValues(details);
            },
            updatePickerStateValues: (PickerStateArgs details) {
              _updatePickerStateValues(details);
            },
            key: _scrollViewKey,
            onTapCallback: onTapCallback,
            onLongPressCallback: onLongPressCallback,
            dragEndCallback: dragEndCallback,
          ),
        ),
      ),
      _getActionsButton(top + height, actionButtonsHeight)
    ]);
  }

  Widget _getActionsButton(double top, double actionButtonsHeight) {
    if (!widget.showActionButtons && !widget.showTodayButton) {
      return const SizedBox(width: 0, height: 0);
    }
    Color textColor =
        widget.todayHighlightColor ?? _datePickerTheme.todayHighlightColor!;
    if (textColor == Colors.transparent) {
      final TextStyle style =
          widget.monthCellStyle.todayTextStyle as TextStyle? ??
              _datePickerTheme.todayTextStyle!;
      textColor = style.color != null ? style.color! : Colors.blue;
    }
    final Widget actionButtons = widget.showActionButtons
        ? Container(
            alignment: AlignmentDirectional.centerEnd,
            constraints: const BoxConstraints(minHeight: 52.0),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: OverflowBar(
              spacing: 8,
              children: <Widget>[
                TextButton(
                  onPressed: _handleCancel,
                  child: Text(
                    widget.cancelText,
                    style: TextStyle(color: textColor),
                  ),
                ),
                TextButton(
                  onPressed: _handleOk,
                  child: Text(
                    widget.confirmText,
                    style: TextStyle(color: textColor),
                  ),
                ),
              ],
            ),
          )
        : const SizedBox(width: 0, height: 0);
    final Widget todayButton = widget.showTodayButton
        ? Container(
            alignment: AlignmentDirectional.centerStart,
            constraints: const BoxConstraints(minHeight: 52.0),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: OverflowBar(
              spacing: 8,
              children: <Widget>[
                TextButton(
                  child: Text(
                    _localizations.todayLabel.toUpperCase(),
                    style: TextStyle(color: textColor),
                  ),
                  onPressed: () {
                    if (widget.allowViewNavigation) {
                      _controller.view = widget.isHijri
                          ? HijriDatePickerView.month
                          : DateRangePickerView.month;
                    }

                    _controller.displayDate =
                        DateRangePickerHelper.getToday(widget.isHijri);
                  },
                ),
              ],
            ),
          )
        : const SizedBox(width: 0, height: 0);
    return Positioned(
      top: top,
      left: 0,
      right: 0,
      height: actionButtonsHeight,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[todayButton, actionButtons]),
    );
  }

  void _handleCancel() {
    switch (widget.selectionMode) {
      case DateRangePickerSelectionMode.single:
        {
          _selectedDate = _previousSelectedValue.selectedDate;
          if (!isSameDate(_controller.selectedDate, _selectedDate)) {
            setState(() {
              _controller.selectedDate = _selectedDate;
            });
          }
        }
        break;
      case DateRangePickerSelectionMode.multiple:
        {
          _selectedDates = _previousSelectedValue.selectedDates != null
              ? _getSelectedDates(_previousSelectedValue.selectedDates)
              : null;
          if (!DateRangePickerHelper.isDateCollectionEquals(
              _selectedDates, _controller.selectedDates)) {
            setState(() {
              _controller.selectedDates =
                  _previousSelectedValue.selectedDates != null
                      ? _getSelectedDates(_previousSelectedValue.selectedDates)
                      : null;
            });
          }
        }
        break;
      case DateRangePickerSelectionMode.range:
      case DateRangePickerSelectionMode.extendableRange:
        {
          _selectedRange = _previousSelectedValue.selectedRange;
          if (!DateRangePickerHelper.isRangeEquals(
              _selectedRange, _controller.selectedRange)) {
            setState(() {
              _controller.selectedRange = _selectedRange;
            });
          }
        }
        break;
      case DateRangePickerSelectionMode.multiRange:
        {
          _selectedRanges = _previousSelectedValue.selectedRanges != null
              ? _getSelectedRanges(_previousSelectedValue.selectedRanges)
              : null;
          if (!DateRangePickerHelper.isDateRangesEquals(
              _selectedRanges, _controller.selectedRanges)) {
            setState(() {
              _controller.selectedRanges = _previousSelectedValue
                          .selectedRanges !=
                      null
                  ? _getSelectedRanges(_previousSelectedValue.selectedRanges)
                  : null;
            });
          }
        }
    }

    widget.onCancel?.call();
  }

  void _handleOk() {
    dynamic value;
    switch (widget.selectionMode) {
      case DateRangePickerSelectionMode.single:
        {
          value = _selectedDate;
          _previousSelectedValue.selectedDate = _selectedDate;
        }
        break;
      case DateRangePickerSelectionMode.multiple:
        {
          value = _getSelectedDates(_selectedDates);
          _previousSelectedValue.selectedDates =
              _getSelectedDates(_selectedDates);
        }
        break;
      case DateRangePickerSelectionMode.range:
      case DateRangePickerSelectionMode.extendableRange:
        {
          value = _selectedRange;
          _previousSelectedValue.selectedRange = _selectedRange;
        }
        break;
      case DateRangePickerSelectionMode.multiRange:
        {
          value = _getSelectedRanges(_selectedRanges);
          _previousSelectedValue.selectedRanges =
              _getSelectedRanges(_selectedRanges);
        }
    }

    widget.onSubmit?.call(value);
  }

  Widget _getViewHeaderView(double topPosition) {
    if (_view == DateRangePickerView.month &&
        widget.navigationDirection ==
            DateRangePickerNavigationDirection.vertical) {
      final Color todayTextColor =
          widget.monthCellStyle.todayTextStyle != null &&
                  widget.monthCellStyle.todayTextStyle!.color != null
              ? widget.monthCellStyle.todayTextStyle!.color! as Color
              : (widget.todayHighlightColor != null &&
                      widget.todayHighlightColor! != Colors.transparent
                  ? widget.todayHighlightColor!
                  : _datePickerTheme.todayHighlightColor!);
      return Positioned(
        left: 0,
        top: topPosition,
        right: 0,
        height: widget.monthViewSettings.viewHeaderHeight,
        child: _AnimatedOpacityWidget(
          opacity: _opacity,
          child: Container(
            color: widget.monthViewSettings.viewHeaderStyle.backgroundColor ??
                _datePickerTheme.viewHeaderBackgroundColor,
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _PickerViewHeaderPainter(
                    _currentViewVisibleDates,
                    widget.navigationMode,
                    widget.monthViewSettings.viewHeaderStyle,
                    widget.monthViewSettings.viewHeaderHeight,
                    widget.monthViewSettings,
                    _datePickerTheme,
                    _locale,
                    _isRtl,
                    widget.monthCellStyle,
                    _isMultiViewEnabled(widget),
                    widget.viewSpacing,
                    todayTextColor,
                    _textScaleFactor,
                    widget.isHijri,
                    widget.navigationDirection,
                    _viewHeaderVisibleDates,
                    widget.monthViewSettings.showWeekNumber,
                    _isMobilePlatform),
              ),
            ),
          ),
        ),
      );
    }

    return Positioned(left: 0, top: 0, right: 0, height: 0, child: Container());
  }

  void _moveToNextView() {
    if (widget.navigationMode == DateRangePickerNavigationMode.scroll) {
      return;
    }
    if (!DateRangePickerHelper.canMoveToNextView(
        _view,
        DateRangePickerHelper.getNumberOfWeeksInView(
            widget.monthViewSettings, widget.isHijri),
        widget.maxDate,
        _currentViewVisibleDates,
        _isMultiViewEnabled(widget),
        widget.isHijri)) {
      return;
    }

    _isRtl
        ? _scrollViewKey.currentState!._moveToPreviousViewWithAnimation()
        : _scrollViewKey.currentState!._moveToNextViewWithAnimation();
  }

  void _moveToPreviousView() {
    if (widget.navigationMode == DateRangePickerNavigationMode.scroll) {
      return;
    }
    if (!DateRangePickerHelper.canMoveToPreviousView(
        _view,
        DateRangePickerHelper.getNumberOfWeeksInView(
            widget.monthViewSettings, widget.isHijri),
        widget.minDate,
        _currentViewVisibleDates,
        _isMultiViewEnabled(widget),
        widget.isHijri)) {
      return;
    }

    _isRtl
        ? _scrollViewKey.currentState!._moveToNextViewWithAnimation()
        : _scrollViewKey.currentState!._moveToPreviousViewWithAnimation();
  }

  void _getPickerStateValues(PickerStateArgs details) {
    details.currentDate = _currentDate;
    details.selectedDate = _selectedDate;
    details.selectedDates = _selectedDates;
    details.selectedRange = _selectedRange;
    details.selectedRanges = _selectedRanges;
    details.currentViewVisibleDates = _currentViewVisibleDates;
    details.view = DateRangePickerHelper.getPickerView(_view);
  }

  void _updatePickerStateValues(PickerStateArgs details) {
    if (details.currentDate != null) {
      if (!isSameOrAfterDate(widget.minDate, details.currentDate)) {
        details.currentDate = widget.minDate;
      }

      if (!isSameOrBeforeDate(widget.maxDate, details.currentDate)) {
        details.currentDate = widget.maxDate;
      }

      _currentDate = details.currentDate;
      _controller.displayDate = _currentDate;
    }

    if (_currentViewVisibleDates != details.currentViewVisibleDates) {
      _currentViewVisibleDates = details.currentViewVisibleDates;
      _headerVisibleDates.value = _currentViewVisibleDates;
      _notifyCurrentVisibleDatesChanged();
    }

    if (_view != details.view) {
      _controller.view = widget.isHijri
          ? DateRangePickerHelper.getHijriPickerView(details.view)
          : DateRangePickerHelper.getPickerView(details.view);
      if (_view == DateRangePickerView.month &&
          widget.navigationDirection ==
              DateRangePickerNavigationDirection.vertical) {
        _viewHeaderVisibleDates.value = _currentViewVisibleDates;
      }
    }

    if (_view == DateRangePickerView.month &&
        widget.navigationDirection ==
            DateRangePickerNavigationDirection.vertical) {
      final dynamic today = DateRangePickerHelper.getToday(widget.isHijri);

      final dynamic previousMonthDate = getPreviousMonthDate(today);
      final dynamic nextMonthDate = getNextMonthDate(today);

      if ((_currentDate.month == today.month &&
              _currentDate.year == today.year) ||
          (_currentDate.month == previousMonthDate.month &&
              _currentDate.year == previousMonthDate.year) ||
          (_currentDate.month == nextMonthDate.month &&
              _currentDate.year == nextMonthDate.year) ||
          _viewHeaderVisibleDates.value.length !=
              _currentViewVisibleDates.length) {
        _viewHeaderVisibleDates.value = _currentViewVisibleDates;
      }
    }

    if (_view == DateRangePickerView.month || !widget.allowViewNavigation) {
      switch (widget.selectionMode) {
        case DateRangePickerSelectionMode.single:
          {
            _selectedDate = details.selectedDate;
            final bool isSameSelectedDate =
                isSameDate(_controller.selectedDate, _selectedDate);
            if (widget.navigationMode == DateRangePickerNavigationMode.scroll &&
                !isSameSelectedDate) {
              setState(() {});
            }

            _controller.selectedDate = _selectedDate;
            if (!isSameSelectedDate) {
              _raiseSelectionChangedCallback(widget,
                  value: _controller.selectedDate);
            }
          }
          break;
        case DateRangePickerSelectionMode.multiple:
          {
            _selectedDates = details.selectedDates;
            final bool isSameSelectedDate =
                DateRangePickerHelper.isDateCollectionEquals(
                    _selectedDates, _controller.selectedDates);
            if (widget.navigationMode == DateRangePickerNavigationMode.scroll &&
                !isSameSelectedDate) {
              setState(() {});
            }

            _controller.selectedDates = _getSelectedDates(_selectedDates);
            if (!isSameSelectedDate)
              _raiseSelectionChangedCallback(widget,
                  value: _controller.selectedDates);
          }
          break;
        case DateRangePickerSelectionMode.range:
        case DateRangePickerSelectionMode.extendableRange:
          {
            _selectedRange = details.selectedRange;
            final bool isSameSelectedDate = DateRangePickerHelper.isRangeEquals(
                _selectedRange, _controller.selectedRange);
            if (widget.navigationMode == DateRangePickerNavigationMode.scroll &&
                !isSameSelectedDate) {
              setState(() {});
            }

            _controller.selectedRange = _selectedRange;
            if (!isSameSelectedDate)
              _raiseSelectionChangedCallback(widget,
                  value: _controller.selectedRange);
          }
          break;
        case DateRangePickerSelectionMode.multiRange:
          {
            _selectedRanges = details.selectedRanges;
            final bool isSameSelectedDate =
                DateRangePickerHelper.isDateRangesEquals(
                    _selectedRanges, _controller.selectedRanges);
            if (widget.navigationMode == DateRangePickerNavigationMode.scroll &&
                !isSameSelectedDate) {
              setState(() {});
            }

            _controller.selectedRanges = _getSelectedRanges(_selectedRanges);
            if (!isSameSelectedDate)
              _raiseSelectionChangedCallback(widget,
                  value: _controller.selectedRanges);
          }
      }
    }
  }

  void _notifyCurrentVisibleDatesChanged() {
    final DateRangePickerView view =
        DateRangePickerHelper.getPickerView(_controller.view);
    dynamic visibleDateRange;
    switch (view) {
      case DateRangePickerView.month:
        {
          final bool enableMultiView = _isMultiViewEnabled(widget);
          if (widget.isHijri ||
              (!DateRangePickerHelper.canShowLeadingAndTrailingDates(
                      widget.monthViewSettings, widget.isHijri) &&
                  DateRangePickerHelper.getNumberOfWeeksInView(
                          widget.monthViewSettings, widget.isHijri) ==
                      6)) {
            final dynamic visibleDate = _currentViewVisibleDates[
                _currentViewVisibleDates.length ~/ (enableMultiView ? 4 : 2)];
            if (widget.isHijri) {
              visibleDateRange = HijriDateRange(
                  DateRangePickerHelper.getMonthStartDate(
                      visibleDate, widget.isHijri),
                  enableMultiView
                      ? DateRangePickerHelper.getMonthEndDate(
                          DateRangePickerHelper.getNextViewStartDate(
                              DateRangePickerHelper.getPickerView(
                                  _controller.view),
                              6,
                              visibleDate,
                              _isRtl,
                              widget.isHijri))
                      : DateRangePickerHelper.getMonthEndDate(visibleDate));
            } else {
              visibleDateRange = PickerDateRange(
                  DateRangePickerHelper.getMonthStartDate(
                      visibleDate, widget.isHijri),
                  enableMultiView
                      ? DateRangePickerHelper.getMonthEndDate(
                          DateRangePickerHelper.getNextViewStartDate(
                              DateRangePickerHelper.getPickerView(
                                  _controller.view),
                              6,
                              visibleDate,
                              _isRtl,
                              widget.isHijri))
                      : DateRangePickerHelper.getMonthEndDate(visibleDate));
            }
            _raisePickerViewChangedCallback(widget,
                visibleDateRange: visibleDateRange, view: _controller.view);
          } else {
            if (widget.isHijri) {
              visibleDateRange = HijriDateRange(
                  _currentViewVisibleDates[0],
                  _currentViewVisibleDates[
                      _currentViewVisibleDates.length - 1]);
            } else {
              visibleDateRange = PickerDateRange(
                  _currentViewVisibleDates[0],
                  _currentViewVisibleDates[
                      _currentViewVisibleDates.length - 1]);
            }
            _raisePickerViewChangedCallback(widget,
                visibleDateRange: visibleDateRange, view: _controller.view);
          }
        }
        break;
      case DateRangePickerView.year:
      case DateRangePickerView.decade:
      case DateRangePickerView.century:
        {
          if (widget.isHijri) {
            visibleDateRange = HijriDateRange(_currentViewVisibleDates[0],
                _currentViewVisibleDates[_currentViewVisibleDates.length - 1]);
          } else {
            visibleDateRange = PickerDateRange(_currentViewVisibleDates[0],
                _currentViewVisibleDates[_currentViewVisibleDates.length - 1]);
          }
          _raisePickerViewChangedCallback(widget,
              visibleDateRange: visibleDateRange, view: _controller.view);
        }
    }
  }

  List? _getSelectedRanges(List<dynamic>? ranges) {
    if (ranges == null) {
      return ranges;
    }

    List selectedRanges;
    if (widget.isHijri) {
      selectedRanges = <HijriDateRange>[];
    } else {
      selectedRanges = <PickerDateRange>[];
    }

    for (int i = 0; i < ranges.length; i++) {
      selectedRanges.add(ranges[i]);
    }

    return selectedRanges;
  }

  List? _getSelectedDates(List<dynamic>? dates) {
    if (dates == null) {
      return dates;
    }

    List selectedDates;
    if (widget.isHijri) {
      selectedDates = <HijriDateTime>[];
    } else {
      selectedDates = <DateTime>[];
    }

    for (int i = 0; i < dates.length; i++) {
      selectedDates.add(dates[i]);
    }

    return selectedDates;
  }

  void _updateCalendarTapCallbackForHeader() {
    if (_view == DateRangePickerView.century || !widget.allowViewNavigation) {
      return;
    }

    if (_view == DateRangePickerView.month) {
      _controller.view = widget.isHijri
          ? DateRangePickerHelper.getHijriPickerView(DateRangePickerView.year)
          : DateRangePickerHelper.getPickerView(DateRangePickerView.year);
    } else {
      if (_view == DateRangePickerView.year) {
        _controller.view = widget.isHijri
            ? DateRangePickerHelper.getHijriPickerView(
                DateRangePickerView.decade)
            : DateRangePickerHelper.getPickerView(DateRangePickerView.decade);
      } else if (_view == DateRangePickerView.decade) {
        _controller.view = widget.isHijri
            ? DateRangePickerHelper.getHijriPickerView(
                DateRangePickerView.century)
            : DateRangePickerHelper.getPickerView(DateRangePickerView.century);
      }
    }
  }
}

class _AnimatedOpacityWidget extends StatefulWidget {
  const _AnimatedOpacityWidget({required this.child, required this.opacity});

  final Widget child;

  final ValueNotifier<double> opacity;

  @override
  State<StatefulWidget> createState() => _AnimatedOpacityWidgetState();
}

class _AnimatedOpacityWidgetState extends State<_AnimatedOpacityWidget> {
  @override
  void initState() {
    widget.opacity.addListener(_update);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _AnimatedOpacityWidget oldWidget) {
    if (widget.opacity != oldWidget.opacity) {
      oldWidget.opacity.removeListener(_update);
      widget.opacity.addListener(_update);
    }
    super.didUpdateWidget(oldWidget);
  }

  void _update() {
    setState(() {});
  }

  @override
  void dispose() {
    widget.opacity.removeListener(_update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(opacity: widget.opacity.value, child: widget.child);
  }
}

class _StickyHeader extends Stack {
  _StickyHeader({
    required List<Widget> children,
    AlignmentDirectional alignment = AlignmentDirectional.topStart,
    this.isHorizontal = false,
    this.isRTL = false,
    Key? key,
  }) : super(
          key: key,
          children: children,
          alignment: alignment,
        );

  final bool isHorizontal;
  final bool isRTL;

  @override
  RenderStack createRenderObject(BuildContext context) =>
      _StickyHeaderRenderObject(
        scrollableState: Scrollable.of(context)!,
        alignment: alignment,
        textDirection: textDirection ?? Directionality.of(context),
        fit: fit,
        isHorizontal: isHorizontal,
        isRTL: isRTL,
      );

  @override
  @mustCallSuper
  void updateRenderObject(BuildContext context, RenderStack renderObject) {
    super.updateRenderObject(context, renderObject);

    if (renderObject is _StickyHeaderRenderObject) {
      renderObject
        ..scrollableState = Scrollable.of(context)!
        ..isRTL = isRTL
        ..isHorizontal = isHorizontal;
    }
  }
}

class _StickyHeaderRenderObject extends RenderStack {
  _StickyHeaderRenderObject({
    required ScrollableState scrollableState,
    required AlignmentGeometry alignment,
    required TextDirection textDirection,
    required StackFit fit,
    required bool isHorizontal,
    required bool isRTL,
  })  : _scrollableState = scrollableState,
        _isHorizontal = isHorizontal,
        _isRTL = isRTL,
        super(
          alignment: alignment,
          textDirection: textDirection,
          fit: fit,
        );

  ScrollableState _scrollableState;

  bool _isHorizontal = false;

  bool get isHorizontal => _isHorizontal;

  set isHorizontal(bool value) {
    if (_isHorizontal == value) {
      return;
    }

    _isHorizontal = value;
    markNeedsPaint();
  }

  bool _isRTL = false;

  bool get isRTL => _isRTL;

  set isRTL(bool value) {
    if (_isRTL == value) {
      return;
    }

    _isRTL = value;
    markNeedsPaint();
  }

  RenderAbstractViewport get _stackViewPort => RenderAbstractViewport.of(this)!;

  ScrollableState get scrollableState => _scrollableState;

  set scrollableState(ScrollableState newScrollable) {
    final ScrollableState oldScrollable = _scrollableState;
    _scrollableState = newScrollable;

    markNeedsPaint();
    if (attached) {
      oldScrollable.position.removeListener(markNeedsPaint);
      newScrollable.position.addListener(markNeedsPaint);
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    scrollableState.position.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    scrollableState.position.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  void paint(PaintingContext context, Offset paintOffset) {
    updateHeaderOffset();
    paintStack(context, paintOffset);
  }

  void updateHeaderOffset() {
    final double contentSize =
        _isHorizontal ? firstChild!.size.width : firstChild!.size.height;

    final RenderBox headerView = lastChild!;

    final double headerSize =
        _isHorizontal ? headerView.size.width : headerView.size.height;

    final double viewPosition =
        _stackViewPort.getOffsetToReveal(this, 0).offset;

    final double currentViewOffset =
        viewPosition - _scrollableState.position.pixels - _scrollableSize;

    final double offset = _getCurrentOffset(currentViewOffset, contentSize);
    final ParentData parentData = headerView.parentData!;
    final StackParentData? headerParentData =
        parentData is StackParentData ? parentData : null;

    final double headerYOffset = _isRTL && _isHorizontal
        ? contentSize -
            headerSize -
            _getHeaderOffset(contentSize, offset, headerSize)
        : _getHeaderOffset(contentSize, offset, headerSize);

    if (!_isHorizontal && headerYOffset != headerParentData?.offset.dy) {
      headerParentData?.offset =
          Offset(headerParentData.offset.dx, headerYOffset);
    } else if (_isHorizontal && headerYOffset != headerParentData?.offset.dx) {
      headerParentData?.offset =
          Offset(headerYOffset, headerParentData.offset.dy);
    }
  }

  double get _scrollableSize {
    final Object viewPort = _stackViewPort;
    double viewPortSize = 0;

    if (viewPort is RenderBox) {
      viewPortSize = _isHorizontal ? viewPort.size.width : viewPort.size.height;
    }

    double anchor = 0;
    if (viewPort is RenderViewport) {
      anchor = viewPort.anchor;
    }

    return -viewPortSize * anchor;
  }

  double _getCurrentOffset(double currentOffset, double contentSize) {
    final double currentHeaderPosition =
        -currentOffset > contentSize ? contentSize : -currentOffset;

    return currentHeaderPosition > 0 ? currentHeaderPosition : 0;
  }

  double _getHeaderOffset(
    double contentSize,
    double offset,
    double headerSize,
  ) {
    if (!_isHorizontal) {
      headerSize = 0;
    }
    return headerSize + offset < contentSize
        ? offset
        : contentSize - headerSize;
  }
}

@immutable
class _PickerHeaderView extends StatefulWidget {
  const _PickerHeaderView(
      this.visibleDates,
      this.headerStyle,
      this.selectionMode,
      this.view,
      this.numberOfWeeksInView,
      this.showNavigationArrow,
      this.navigationDirection,
      this.enableSwipeSelection,
      this.navigationMode,
      this.minDate,
      this.maxDate,
      this.monthFormat,
      this.datePickerTheme,
      this.locale,
      this.width,
      this.height,
      this.allowViewNavigation,
      this.previousNavigationCallback,
      this.nextNavigationCallback,
      this.enableMultiView,
      this.multiViewSpacing,
      this.hoverColor,
      this.isRtl,
      this.textScaleFactor,
      this.isHijri,
      this.localizations,
      {Key? key})
      : super(key: key);

  final double textScaleFactor;

  final DateRangePickerSelectionMode selectionMode;

  final DateRangePickerHeaderStyle headerStyle;

  final DateRangePickerView view;

  final int numberOfWeeksInView;

  final bool showNavigationArrow;

  final DateRangePickerNavigationDirection navigationDirection;

  final dynamic minDate;

  final dynamic maxDate;

  final String? monthFormat;

  final bool enableSwipeSelection;

  final DateRangePickerNavigationMode navigationMode;

  final bool allowViewNavigation;

  final SfDateRangePickerThemeData datePickerTheme;

  final Locale locale;

  final ValueNotifier<List<dynamic>> visibleDates;

  final VoidCallback? previousNavigationCallback;

  final VoidCallback? nextNavigationCallback;

  final double width;

  final double height;

  final bool isRtl;

  final Color hoverColor;

  final bool enableMultiView;

  final double multiViewSpacing;

  final SfLocalizations localizations;

  final bool isHijri;

  @override
  _PickerHeaderViewState createState() => _PickerHeaderViewState();
}

class _PickerHeaderViewState extends State<_PickerHeaderView> {
  bool _hovering = false;

  @override
  void initState() {
    _hovering = false;
    _addListener();
    super.initState();
  }

  @override
  void didUpdateWidget(_PickerHeaderView oldWidget) {
    widget.visibleDates.removeListener(_listener);
    _addListener();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobilePlatform =
        DateRangePickerHelper.isMobileLayout(Theme.of(context).platform);
    double arrowWidth = 0;
    double headerWidth = widget.width;
    bool showNavigationArrow = widget.showNavigationArrow ||
        ((widget.view == DateRangePickerView.month ||
                !widget.allowViewNavigation) &&
            _isSwipeInteractionEnabled(
                widget.enableSwipeSelection, widget.navigationMode) &&
            (widget.selectionMode == DateRangePickerSelectionMode.range ||
                widget.selectionMode ==
                    DateRangePickerSelectionMode.multiRange ||
                widget.selectionMode ==
                    DateRangePickerSelectionMode.extendableRange));
    showNavigationArrow = showNavigationArrow &&
        widget.navigationMode != DateRangePickerNavigationMode.scroll;
    if (showNavigationArrow) {
      arrowWidth = widget.width / 6;
      arrowWidth = arrowWidth > 50 ? 50 : arrowWidth;
      headerWidth = widget.width - (arrowWidth * 2);
    }

    Color arrowColor = widget.headerStyle.textStyle != null &&
            widget.headerStyle.textStyle!.color != null
        ? widget.headerStyle.textStyle!.color!
        : (widget.datePickerTheme.headerTextStyle!.color!);
    arrowColor = arrowColor.withOpacity(arrowColor.opacity * 0.6);
    Color prevArrowColor = arrowColor;
    Color nextArrowColor = arrowColor;
    final List<dynamic> dates = widget.visibleDates.value;
    if (showNavigationArrow &&
        !DateRangePickerHelper.canMoveToNextView(
            widget.view,
            widget.numberOfWeeksInView,
            widget.maxDate,
            dates,
            widget.enableMultiView,
            widget.isHijri)) {
      nextArrowColor = nextArrowColor.withOpacity(arrowColor.opacity * 0.5);
    }

    if (showNavigationArrow &&
        !DateRangePickerHelper.canMoveToPreviousView(
            widget.view,
            widget.numberOfWeeksInView,
            widget.minDate,
            dates,
            widget.enableMultiView,
            widget.isHijri)) {
      prevArrowColor = prevArrowColor.withOpacity(arrowColor.opacity * 0.5);
    }

    final Widget headerText = _getHeaderText(headerWidth, isMobilePlatform);
    if (widget.navigationMode == DateRangePickerNavigationMode.scroll &&
        widget.navigationDirection ==
            DateRangePickerNavigationDirection.horizontal) {
      return headerText;
    }

    double arrowSize = widget.height * 0.5;
    arrowSize = arrowSize > 25 ? 25 : arrowSize;
    arrowSize = arrowSize * widget.textScaleFactor;
    final Container leftArrow = showNavigationArrow
        ? _getLeftArrow(arrowWidth, arrowColor, prevArrowColor, arrowSize)
        : Container();

    final Container rightArrow = showNavigationArrow
        ? _getRightArrow(arrowWidth, arrowColor, nextArrowColor, arrowSize)
        : Container();

    if (widget.headerStyle.textAlign == TextAlign.left ||
        widget.headerStyle.textAlign == TextAlign.start) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            headerText,
            leftArrow,
            rightArrow,
          ]);
    } else if (widget.headerStyle.textAlign == TextAlign.right ||
        widget.headerStyle.textAlign == TextAlign.end) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            leftArrow,
            rightArrow,
            headerText,
          ]);
    } else {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            leftArrow,
            headerText,
            rightArrow,
          ]);
    }
  }

  @override
  void dispose() {
    widget.visibleDates.removeListener(_listener);
    super.dispose();
  }

  void _listener() {
    if (!mounted) {
      return;
    }

    if (widget.showNavigationArrow ||
        ((widget.view == DateRangePickerView.month ||
                !widget.allowViewNavigation) &&
            _isSwipeInteractionEnabled(
                widget.enableSwipeSelection, widget.navigationMode) &&
            (widget.selectionMode == DateRangePickerSelectionMode.range ||
                widget.selectionMode ==
                    DateRangePickerSelectionMode.multiRange ||
                widget.selectionMode ==
                    DateRangePickerSelectionMode.extendableRange))) {
      setState(() {
        /*Updates the header when visible dates changes */
      });
    }
  }

  void _addListener() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      widget.visibleDates.addListener(_listener);
    });
  }

  Widget _getHeaderText(double headerWidth, bool isMobilePlatform) {
    return MouseRegion(
        onEnter: (PointerEnterEvent event) {
          if (widget.view == DateRangePickerView.century ||
              (widget.isHijri && widget.view == DateRangePickerView.decade) ||
              isMobilePlatform) {
            return;
          }

          setState(() {
            _hovering = true;
          });
        },
        onHover: (PointerHoverEvent event) {
          if (widget.view == DateRangePickerView.century ||
              (widget.isHijri && widget.view == DateRangePickerView.decade) ||
              isMobilePlatform) {
            return;
          }

          setState(() {
            _hovering = true;
          });
        },
        onExit: (PointerExitEvent event) {
          setState(() {
            _hovering = false;
          });
        },
        child: RepaintBoundary(
            child: CustomPaint(
          painter: _PickerHeaderPainter(
              widget.visibleDates,
              widget.headerStyle,
              widget.view,
              widget.numberOfWeeksInView,
              widget.monthFormat,
              widget.datePickerTheme,
              widget.isRtl,
              widget.locale,
              widget.enableMultiView,
              widget.multiViewSpacing,
              widget.hoverColor,
              _hovering,
              widget.textScaleFactor,
              widget.isHijri,
              widget.localizations,
              widget.navigationDirection),
          size: Size(headerWidth, widget.height),
        )));
  }

  Container _getLeftArrow(double arrowWidth, Color arrowColor,
      Color prevArrowColor, double arrowSize) {
    return Container(
      alignment: Alignment.center,
      color: widget.headerStyle.backgroundColor ??
          widget.datePickerTheme.headerBackgroundColor,
      width: arrowWidth,
      padding: EdgeInsets.zero,
      child: MaterialButton(
        splashColor: prevArrowColor != arrowColor ? Colors.transparent : null,
        hoverColor: prevArrowColor != arrowColor ? Colors.transparent : null,
        highlightColor:
            prevArrowColor != arrowColor ? Colors.transparent : null,
        color: widget.headerStyle.backgroundColor ??
            widget.datePickerTheme.headerBackgroundColor,
        onPressed: widget.previousNavigationCallback,
        padding: EdgeInsets.zero,
        elevation: 0,
        focusElevation: 0,
        highlightElevation: 0,
        disabledElevation: 0,
        hoverElevation: 0,
        child: Semantics(
          label: 'Backward',
          child: Icon(
            widget.navigationDirection ==
                    DateRangePickerNavigationDirection.horizontal
                ? Icons.chevron_left
                : Icons.keyboard_arrow_up,
            color: prevArrowColor,
            size: arrowSize,
          ),
        ),
      ),
    );
  }

  Container _getRightArrow(double arrowWidth, Color arrowColor,
      Color nextArrowColor, double arrowSize) {
    return Container(
      alignment: Alignment.center,
      color: widget.headerStyle.backgroundColor ??
          widget.datePickerTheme.headerBackgroundColor,
      width: arrowWidth,
      padding: EdgeInsets.zero,
      child: MaterialButton(
        splashColor: nextArrowColor != arrowColor ? Colors.transparent : null,
        hoverColor: nextArrowColor != arrowColor ? Colors.transparent : null,
        highlightColor:
            nextArrowColor != arrowColor ? Colors.transparent : null,
        color: widget.headerStyle.backgroundColor ??
            widget.datePickerTheme.headerBackgroundColor,
        onPressed: widget.nextNavigationCallback,
        padding: EdgeInsets.zero,
        elevation: 0,
        focusElevation: 0,
        highlightElevation: 0,
        disabledElevation: 0,
        hoverElevation: 0,
        child: Semantics(
          label: 'Forward',
          child: Icon(
            widget.navigationDirection ==
                    DateRangePickerNavigationDirection.horizontal
                ? Icons.chevron_right
                : Icons.keyboard_arrow_down,
            color: nextArrowColor,
            size: arrowSize,
          ),
        ),
      ),
    );
  }
}

class _PickerHeaderPainter extends CustomPainter {
  _PickerHeaderPainter(
      this.visibleDates,
      this.headerStyle,
      this.view,
      this.numberOfWeeksInView,
      this.monthFormat,
      this.datePickerTheme,
      this.isRtl,
      this.locale,
      this.enableMultiView,
      this.multiViewSpacing,
      this.hoverColor,
      this.hovering,
      this.textScaleFactor,
      this.isHijri,
      this.localizations,
      this.navigationDirection)
      : super(repaint: visibleDates);

  final DateRangePickerHeaderStyle headerStyle;
  final DateRangePickerView view;
  final int numberOfWeeksInView;
  final SfDateRangePickerThemeData datePickerTheme;
  final bool isRtl;
  final String? monthFormat;
  final bool hovering;
  final bool enableMultiView;
  final double multiViewSpacing;
  final Color hoverColor;
  final Locale locale;
  final double textScaleFactor;
  final bool isHijri;
  final SfLocalizations localizations;
  final DateRangePickerNavigationDirection navigationDirection;
  ValueNotifier<List<dynamic>> visibleDates;
  String _headerText = '';
  final TextPainter _textPainter = TextPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    double xPosition = 0;
    _textPainter.textDirection = TextDirection.ltr;
    _textPainter.textWidthBasis = TextWidthBasis.longestLine;
    _textPainter.textScaleFactor = textScaleFactor;
    _textPainter.maxLines = 1;

    _headerText = '';
    final double width = (enableMultiView &&
                navigationDirection ==
                    DateRangePickerNavigationDirection.horizontal) &&
            headerStyle.textAlign == TextAlign.center
        ? (size.width - multiViewSpacing) / 2
        : size.width;
    final int count = (enableMultiView &&
                navigationDirection ==
                    DateRangePickerNavigationDirection.horizontal) &&
            headerStyle.textAlign == TextAlign.center
        ? 2
        : 1;
    for (int j = 0; j < count; j++) {
      final int currentViewIndex =
          isRtl ? DateRangePickerHelper.getRtlIndex(count, j) : j;
      xPosition = (currentViewIndex * width) + 10;

      final String text = _getHeaderText(
          visibleDates.value,
          view,
          j,
          isHijri,
          numberOfWeeksInView,
          monthFormat,
          enableMultiView,
          headerStyle,
          navigationDirection,
          locale,
          localizations);
      _headerText += j == 1 ? ' $text' : text;
      TextStyle? style =
          headerStyle.textStyle ?? datePickerTheme.headerTextStyle;
      if (hovering) {
        style = style!.copyWith(color: hoverColor);
      }

      final TextSpan span = TextSpan(text: text, style: style);
      _textPainter.text = span;

      if (headerStyle.textAlign == TextAlign.justify) {
        _textPainter.textAlign = headerStyle.textAlign;
      }

      double textWidth = ((currentViewIndex + 1) * width) - xPosition;
      textWidth = textWidth > 0 ? textWidth : 0;
      _textPainter.layout(minWidth: textWidth, maxWidth: textWidth);

      if (headerStyle.textAlign == TextAlign.center) {
        xPosition = (currentViewIndex * width) +
            (currentViewIndex * multiViewSpacing) +
            (width / 2) -
            (_textPainter.width / 2);
      } else if ((!isRtl &&
              (headerStyle.textAlign == TextAlign.right ||
                  headerStyle.textAlign == TextAlign.end)) ||
          (isRtl &&
              (headerStyle.textAlign == TextAlign.left ||
                  headerStyle.textAlign == TextAlign.start))) {
        xPosition =
            ((currentViewIndex + 1) * width) - _textPainter.width - xPosition;
      }
      _textPainter.paint(
          canvas, Offset(xPosition, size.height / 2 - _textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(_PickerHeaderPainter oldDelegate) {
    return oldDelegate.headerStyle != headerStyle ||
        oldDelegate.isRtl != isRtl ||
        oldDelegate.numberOfWeeksInView != numberOfWeeksInView ||
        oldDelegate.locale != locale ||
        oldDelegate.datePickerTheme != datePickerTheme ||
        oldDelegate.monthFormat != monthFormat ||
        oldDelegate.textScaleFactor != textScaleFactor ||
        oldDelegate.hovering != hovering ||
        oldDelegate.hoverColor != hoverColor;
  }

  @override
  SemanticsBuilderCallback get semanticsBuilder {
    return (Size size) {
      final Rect rect = Offset.zero & size;
      return <CustomPainterSemantics>[
        CustomPainterSemantics(
          rect: rect,
          properties: SemanticsProperties(
            label: _headerText.replaceAll('-', 'to'),
            textDirection: TextDirection.ltr,
          ),
        ),
      ];
    };
  }

  @override
  bool shouldRebuildSemantics(CustomPainter oldDelegate) {
    return true;
  }
}

class _PickerViewHeaderPainter extends CustomPainter {
  _PickerViewHeaderPainter(
      this.visibleDates,
      this.navigationMode,
      this.viewHeaderStyle,
      this.viewHeaderHeight,
      this.monthViewSettings,
      this.datePickerTheme,
      this.locale,
      this.isRtl,
      this.monthCellStyle,
      this.enableMultiView,
      this.multiViewSpacing,
      this.todayHighlightColor,
      this.textScaleFactor,
      this.isHijri,
      this.navigationDirection,
      this.viewHeaderVisibleDates,
      this.showWeekNumber,
      this.isMobilePlatform)
      : super(repaint: viewHeaderVisibleDates);

  final DateRangePickerViewHeaderStyle viewHeaderStyle;

  final dynamic monthViewSettings;

  final DateRangePickerNavigationMode navigationMode;

  List<dynamic> visibleDates;

  final double viewHeaderHeight;

  final dynamic monthCellStyle;

  final Locale locale;

  final bool isRtl;

  final Color? todayHighlightColor;

  final bool enableMultiView;

  final double multiViewSpacing;

  final SfDateRangePickerThemeData datePickerTheme;

  final bool isHijri;

  final double textScaleFactor;

  final DateRangePickerNavigationDirection navigationDirection;
  final TextPainter _textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
      textWidthBasis: TextWidthBasis.longestLine);

  final ValueNotifier<List<dynamic>>? viewHeaderVisibleDates;

  final bool showWeekNumber;

  final bool isMobilePlatform;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final double weekNumberPanelWidth =
        DateRangePickerHelper.getWeekNumberPanelWidth(
            showWeekNumber, size.width, isMobilePlatform);
    double width = showWeekNumber
        ? (size.width - weekNumberPanelWidth) / DateTime.daysPerWeek
        : size.width / DateTime.daysPerWeek;
    if (enableMultiView &&
        navigationDirection == DateRangePickerNavigationDirection.horizontal) {
      width = showWeekNumber
          ? (size.width - multiViewSpacing - (weekNumberPanelWidth * 2)) /
              (DateTime.daysPerWeek * 2)
          : (size.width - multiViewSpacing) / (DateTime.daysPerWeek * 2);
    }

    final TextStyle? viewHeaderDayStyle =
        viewHeaderStyle.textStyle ?? datePickerTheme.viewHeaderTextStyle;
    final dynamic today = DateRangePickerHelper.getToday(isHijri);
    TextStyle? dayTextStyle = viewHeaderDayStyle;
    double xPosition = isRtl ? 0 : weekNumberPanelWidth;
    double yPosition = 0;
    final int count = (enableMultiView &&
            navigationDirection ==
                DateRangePickerNavigationDirection.horizontal)
        ? 2
        : 1;
    final int datesCount = (enableMultiView &&
            navigationDirection ==
                DateRangePickerNavigationDirection.horizontal)
        ? visibleDates.length ~/ 2
        : visibleDates.length;
    final bool isVerticalScroll =
        navigationDirection == DateRangePickerNavigationDirection.vertical &&
            navigationMode == DateRangePickerNavigationMode.scroll;
    visibleDates = viewHeaderVisibleDates != null
        ? viewHeaderVisibleDates!.value
        : visibleDates;

    for (int j = 0; j < count; j++) {
      final int currentViewIndex =
          isRtl ? DateRangePickerHelper.getRtlIndex(count, j) : j;
      dynamic currentDate;
      final int month =
          visibleDates[(currentViewIndex * datesCount) + (datesCount ~/ 2)]
              .month as int;
      final int year =
          visibleDates[(currentViewIndex * datesCount) + (datesCount ~/ 2)].year
              as int;
      final int currentMonth = today.month as int;
      final int currentYear = today.year as int;

      final int numberOfWeeksInView =
          DateRangePickerHelper.getNumberOfWeeksInView(
              monthViewSettings, isHijri);
      final bool isTodayMonth = isDateWithInDateRange(
          visibleDates[(currentViewIndex * datesCount)],
          visibleDates[((currentViewIndex + 1) * datesCount) - 1],
          today);
      final bool hasToday = isVerticalScroll ||
          (numberOfWeeksInView > 0 && numberOfWeeksInView < 6 ||
              month == currentMonth && year == currentYear);
      for (int i = 0; i < DateTime.daysPerWeek; i++) {
        int index = isRtl
            ? DateRangePickerHelper.getRtlIndex(DateTime.daysPerWeek, i)
            : i;
        index = index + (currentViewIndex * datesCount);
        currentDate = visibleDates[index];
        String dayText =
            DateFormat(monthViewSettings.dayFormat, locale.toString())
                .format(isHijri ? currentDate.toDateTime() : currentDate)
                .toUpperCase();
        dayText = _updateViewHeaderFormat(dayText);

        if (hasToday &&
            currentDate.weekday == today.weekday &&
            (isTodayMonth || isVerticalScroll)) {
          final Color textColor = monthCellStyle.todayTextStyle != null &&
                  monthCellStyle.todayTextStyle.color != null
              ? monthCellStyle.todayTextStyle.color! as Color
              : todayHighlightColor ?? datePickerTheme.todayHighlightColor!;
          dayTextStyle = viewHeaderDayStyle!.copyWith(color: textColor);
        } else {
          dayTextStyle = viewHeaderDayStyle;
        }

        final TextSpan dayTextSpan = TextSpan(
          text: dayText,
          style: dayTextStyle,
        );

        _textPainter.textScaleFactor = textScaleFactor;
        _textPainter.text = dayTextSpan;
        _textPainter.layout(minWidth: width, maxWidth: width);
        yPosition = (viewHeaderHeight - _textPainter.height) / 2;
        _textPainter.paint(
            canvas,
            Offset(
                xPosition + (width / 2 - _textPainter.width / 2), yPosition));
        xPosition += width;
      }

      xPosition += multiViewSpacing + weekNumberPanelWidth;
    }
  }

  String _updateViewHeaderFormat(String dayText) {
    if (monthViewSettings.dayFormat == 'EE' && locale.languageCode == 'en') {
      dayText = dayText[0];
    }

    return dayText;
  }

  @override
  bool shouldRepaint(_PickerViewHeaderPainter oldDelegate) {
    return oldDelegate.visibleDates != visibleDates ||
        oldDelegate.viewHeaderStyle != viewHeaderStyle ||
        oldDelegate.viewHeaderHeight != viewHeaderHeight ||
        oldDelegate.todayHighlightColor != todayHighlightColor ||
        oldDelegate.monthViewSettings != monthViewSettings ||
        oldDelegate.datePickerTheme != datePickerTheme ||
        oldDelegate.isRtl != isRtl ||
        oldDelegate.locale != locale ||
        oldDelegate.textScaleFactor != textScaleFactor ||
        oldDelegate.isHijri != isHijri ||
        oldDelegate.showWeekNumber != showWeekNumber;
  }

  List<CustomPainterSemantics> _getSemanticsBuilder(Size size) {
    final List<CustomPainterSemantics> semanticsBuilder =
        <CustomPainterSemantics>[];
    double left, cellWidth;
    cellWidth = size.width / DateTime.daysPerWeek;
    int count = 1;
    int datesCount = visibleDates.length;
    if (enableMultiView &&
        navigationDirection == DateRangePickerNavigationDirection.horizontal) {
      cellWidth = (size.width - multiViewSpacing) / 14;
      count = 2;
      datesCount = visibleDates.length ~/ 2;
    }

    left = isRtl ? size.width - cellWidth : 0;
    const double top = 0;
    for (int j = 0; j < count; j++) {
      for (int i = 0; i < DateTime.daysPerWeek; i++) {
        semanticsBuilder.add(CustomPainterSemantics(
          rect: Rect.fromLTWH(left, top, cellWidth, size.height),
          properties: SemanticsProperties(
            label: DateFormat('EEEEE')
                .format(isHijri
                    ? visibleDates[(j * datesCount) + i].toDateTime()
                    : visibleDates[(j * datesCount) + i])
                .toUpperCase(),
            textDirection: TextDirection.ltr,
          ),
        ));
        if (isRtl) {
          left -= cellWidth;
        } else {
          left += cellWidth;
        }
      }

      if (isRtl) {
        left -= multiViewSpacing;
      } else {
        left += multiViewSpacing;
      }
    }

    return semanticsBuilder;
  }

  @override
  SemanticsBuilderCallback get semanticsBuilder {
    return (Size size) {
      return _getSemanticsBuilder(size);
    };
  }

  @override
  bool shouldRebuildSemantics(_PickerViewHeaderPainter oldDelegate) {
    return oldDelegate.visibleDates != visibleDates;
  }
}

@immutable
class _PickerScrollView extends StatefulWidget {
  const _PickerScrollView(
    this.picker,
    this.controller,
    this.width,
    this.height,
    this.isRtl,
    this.datePickerTheme,
    this.locale,
    this.textScaleFactor, {
    Key? key,
    required this.getPickerStateValues,
    required this.updatePickerStateValues,
    this.onTapCallback,
    this.onLongPressCallback,
    this.dragEndCallback,
  }) : super(key: key);

  final _SfDateRangePicker picker;

  final double width;

  final double height;

  final bool isRtl;

  final UpdatePickerState getPickerStateValues;

  final UpdatePickerState updatePickerStateValues;

  final dynamic controller;

  final SfDateRangePickerThemeData datePickerTheme;

  final Locale locale;

  final double textScaleFactor;

  final Function(PickerDateRange?, bool)? onTapCallback;

  final Function(PickerDateRange?)? onLongPressCallback;

  final DateRangePickerSelectionChangedCallback? dragEndCallback;

  @override
  _PickerScrollViewState createState() => _PickerScrollViewState();
}

class _PickerScrollViewState extends State<_PickerScrollView>
    with TickerProviderStateMixin {
  _PickerView? _currentView, _nextView, _previousView;

  final List<_PickerView> _children = <_PickerView>[];

  Map<List<dynamic>, List<dynamic>>? _disabledDates;

  int _currentChildIndex = 1;

  double? _scrollStartPosition;

  double _position = 0;

  late AnimationController _animationController;

  late Animation<double> _animation;

  late Tween<double> _tween;

  late List<dynamic> _visibleDates,
      _previousViewVisibleDates,
      _nextViewVisibleDates,
      _currentViewVisibleDates;

  final GlobalKey<_PickerViewState> _previousViewKey =
          GlobalKey<_PickerViewState>(),
      _currentViewKey = GlobalKey<_PickerViewState>(),
      _nextViewKey = GlobalKey<_PickerViewState>();

  final PickerStateArgs _pickerStateDetails = PickerStateArgs();
  final FocusScopeNode _focusNode = FocusScopeNode();

  @override
  void initState() {
    _updateVisibleDates();
    _triggerSelectableDayPredicates(_currentViewVisibleDates);
    _triggerViewChangedCallback();
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 250), vsync: this);
    _tween = Tween<double>(begin: 0.0, end: 0.1);
    _animation = _tween.animate(_animationController)
      ..addListener(_animationListener);

    super.initState();
  }

  @override
  void didUpdateWidget(_PickerScrollView oldWidget) {
    if (widget.picker.navigationDirection !=
            oldWidget.picker.navigationDirection ||
        widget.width != oldWidget.width ||
        widget.picker.cellBuilder != oldWidget.picker.cellBuilder ||
        oldWidget.datePickerTheme != widget.datePickerTheme ||
        widget.picker.viewSpacing != oldWidget.picker.viewSpacing ||
        widget.picker.selectionMode != oldWidget.picker.selectionMode ||
        widget.height != oldWidget.height ||
        widget.picker.extendableRangeSelectionDirection !=
            oldWidget.picker.extendableRangeSelectionDirection) {
      _position = 0;
      _children.clear();
    }

    if (oldWidget.textScaleFactor != widget.textScaleFactor ||
        oldWidget.picker.isHijri != widget.picker.isHijri) {
      _position = 0;
      _children.clear();
    }

    if (widget.isRtl != oldWidget.isRtl ||
        widget.picker.enableMultiView != oldWidget.picker.enableMultiView) {
      _position = 0;
      _children.clear();
      _updateVisibleDates();
      _triggerSelectableDayPredicates(_currentViewVisibleDates);
      _triggerViewChangedCallback();
    }

    _updateSettings(oldWidget);

    final DateRangePickerView pickerView =
        DateRangePickerHelper.getPickerView(widget.controller.view);

    if (pickerView == DateRangePickerView.year &&
        widget.picker.monthFormat != oldWidget.picker.monthFormat) {
      _position = 0;
      _children.clear();
    }

    if (pickerView != DateRangePickerView.month &&
        widget.picker.yearCellStyle != oldWidget.picker.yearCellStyle) {
      _position = 0;
      _children.clear();
    }

    if (widget.picker.minDate != oldWidget.picker.minDate ||
        widget.picker.maxDate != oldWidget.picker.maxDate) {
      final dynamic previousVisibleDate = _pickerStateDetails.currentDate;
      widget.getPickerStateValues(_pickerStateDetails);
      if (!isSameDate(_pickerStateDetails.currentDate, previousVisibleDate)) {
        _updateVisibleDates();
        _triggerViewChangedCallback();
      }

      _position = 0;
      _children.clear();
    }

    if (widget.picker.enablePastDates != oldWidget.picker.enablePastDates) {
      _position = 0;
      _children.clear();
    }

    if (pickerView == DateRangePickerView.month &&
        (oldWidget.picker.monthViewSettings.viewHeaderStyle !=
                widget.picker.monthViewSettings.viewHeaderStyle ||
            oldWidget.picker.monthViewSettings.viewHeaderHeight !=
                widget.picker.monthViewSettings.viewHeaderHeight ||
            DateRangePickerHelper.canShowLeadingAndTrailingDates(
                    widget.picker.monthViewSettings, widget.picker.isHijri) !=
                DateRangePickerHelper.canShowLeadingAndTrailingDates(
                    oldWidget.picker.monthViewSettings,
                    oldWidget.picker.isHijri))) {
      _children.clear();
      _position = 0;

      if (DateRangePickerHelper.canShowLeadingAndTrailingDates(
              widget.picker.monthViewSettings, widget.picker.isHijri) !=
          DateRangePickerHelper.canShowLeadingAndTrailingDates(
              oldWidget.picker.monthViewSettings, oldWidget.picker.isHijri)) {
        _disabledDates?.clear();
        _triggerSelectableDayPredicates(_currentViewVisibleDates);
      }
    }

    if (DateRangePickerHelper.getNumberOfWeeksInView(
                widget.picker.monthViewSettings, widget.picker.isHijri) !=
            DateRangePickerHelper.getNumberOfWeeksInView(
                oldWidget.picker.monthViewSettings, oldWidget.picker.isHijri) ||
        widget.picker.monthViewSettings.firstDayOfWeek !=
            oldWidget.picker.monthViewSettings.firstDayOfWeek) {
      _updateVisibleDates();
      _position = 0;
      _triggerSelectableDayPredicates(_currentViewVisibleDates);
      _triggerViewChangedCallback();
    }

    if (oldWidget.picker.allowViewNavigation !=
            widget.picker.allowViewNavigation &&
        pickerView != DateRangePickerView.month) {
      _position = 0;
      _children.clear();
      _triggerSelectableDayPredicates(_currentViewVisibleDates);
    }

    if (!isSameDate(
        _pickerStateDetails.currentDate, widget.controller.displayDate)) {
      _pickerStateDetails.currentDate = widget.controller?.displayDate;
      _updateVisibleDates();
      _triggerSelectableDayPredicates(_currentViewVisibleDates);
      _triggerViewChangedCallback();
    }

    if (_pickerStateDetails.view != pickerView) {
      _position = 0;
      _children.clear();
      _updateVisibleDates();
      _triggerViewChangedCallback();
    }

    _drawSelection(oldWidget.controller, widget.controller, pickerView);
    widget.getPickerStateValues(_pickerStateDetails);
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    double leftPosition = 0,
        rightPosition = 0,
        topPosition = 0,
        bottomPosition = 0;
    switch (widget.picker.navigationDirection) {
      case DateRangePickerNavigationDirection.horizontal:
        {
          leftPosition = -widget.width;
          rightPosition = -widget.width;
        }
        break;
      case DateRangePickerNavigationDirection.vertical:
        {
          topPosition = -widget.height;
          bottomPosition = -widget.height;
        }
    }

    return Stack(
      children: <Widget>[
        Positioned(
          left: leftPosition,
          right: rightPosition,
          bottom: bottomPosition,
          top: topPosition,
          child: GestureDetector(
            onHorizontalDragStart: widget.picker.navigationDirection ==
                        DateRangePickerNavigationDirection.horizontal &&
                    widget.picker.navigationMode !=
                        DateRangePickerNavigationMode.none
                ? _onHorizontalStart
                : null,
            onHorizontalDragUpdate: widget.picker.navigationDirection ==
                        DateRangePickerNavigationDirection.horizontal &&
                    widget.picker.navigationMode !=
                        DateRangePickerNavigationMode.none
                ? _onHorizontalUpdate
                : null,
            onHorizontalDragEnd: widget.picker.navigationDirection ==
                        DateRangePickerNavigationDirection.horizontal &&
                    widget.picker.navigationMode !=
                        DateRangePickerNavigationMode.none
                ? _onHorizontalEnd
                : null,
            onVerticalDragStart: widget.picker.navigationDirection ==
                        DateRangePickerNavigationDirection.vertical &&
                    widget.picker.navigationMode !=
                        DateRangePickerNavigationMode.none
                ? _onVerticalStart
                : null,
            onVerticalDragUpdate: widget.picker.navigationDirection ==
                        DateRangePickerNavigationDirection.vertical &&
                    widget.picker.navigationMode !=
                        DateRangePickerNavigationMode.none
                ? _onVerticalUpdate
                : null,
            onVerticalDragEnd: widget.picker.navigationDirection ==
                        DateRangePickerNavigationDirection.vertical &&
                    widget.picker.navigationMode !=
                        DateRangePickerNavigationMode.none
                ? _onVerticalEnd
                : null,
            child: FocusScope(
              node: _focusNode,
              onKey: _onKeyDown,
              child: CustomScrollViewerLayout(
                  _addViews(context, widget.onTapCallback,
                      widget.onLongPressCallback, widget.dragEndCallback),
                  widget.picker.navigationDirection ==
                          DateRangePickerNavigationDirection.horizontal
                      ? CustomScrollDirection.horizontal
                      : CustomScrollDirection.vertical,
                  _position,
                  _currentChildIndex),
            ),
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    _previousViewVisibleDates.clear();
    _nextViewVisibleDates.clear();
    _currentViewVisibleDates.clear();
    _animationController.dispose();
    _animation.removeListener(_animationListener);
    _focusNode.dispose();
    super.dispose();
  }

  void _updateVisibleDates() {
    widget.getPickerStateValues(_pickerStateDetails);
    final int numberOfWeeksInView =
        DateRangePickerHelper.getNumberOfWeeksInView(
            widget.picker.monthViewSettings, widget.picker.isHijri);
    final dynamic currentDate = _pickerStateDetails.currentDate;
    final dynamic prevDate = DateRangePickerHelper.getPreviousViewStartDate(
        DateRangePickerHelper.getPickerView(widget.controller.view),
        numberOfWeeksInView,
        _pickerStateDetails.currentDate,
        widget.isRtl,
        widget.picker.isHijri);
    final dynamic nextDate = DateRangePickerHelper.getNextViewStartDate(
        DateRangePickerHelper.getPickerView(widget.controller.view),
        numberOfWeeksInView,
        _pickerStateDetails.currentDate,
        widget.isRtl,
        widget.picker.isHijri);

    dynamic afterNextViewDate;
    List<dynamic>? afterVisibleDates;
    if (widget.picker.enableMultiView) {
      afterNextViewDate = DateRangePickerHelper.getNextViewStartDate(
          DateRangePickerHelper.getPickerView(widget.controller.view),
          numberOfWeeksInView,
          widget.isRtl ? prevDate : nextDate,
          false,
          widget.picker.isHijri);
    }

    final DateRangePickerView view =
        DateRangePickerHelper.getPickerView(widget.controller.view);

    switch (view) {
      case DateRangePickerView.month:
        {
          _visibleDates = getVisibleDates(
            currentDate,
            null,
            widget.picker.monthViewSettings.firstDayOfWeek,
            DateRangePickerHelper.getViewDatesCount(
                view, numberOfWeeksInView, widget.picker.isHijri),
          );
          _previousViewVisibleDates = getVisibleDates(
            prevDate,
            null,
            widget.picker.monthViewSettings.firstDayOfWeek,
            DateRangePickerHelper.getViewDatesCount(
                view, numberOfWeeksInView, widget.picker.isHijri),
          );
          _nextViewVisibleDates = getVisibleDates(
            nextDate,
            null,
            widget.picker.monthViewSettings.firstDayOfWeek,
            DateRangePickerHelper.getViewDatesCount(
                view, numberOfWeeksInView, widget.picker.isHijri),
          );
          if (widget.picker.enableMultiView) {
            afterVisibleDates = getVisibleDates(
              afterNextViewDate,
              null,
              widget.picker.monthViewSettings.firstDayOfWeek,
              DateRangePickerHelper.getViewDatesCount(
                  view, numberOfWeeksInView, widget.picker.isHijri),
            );
          }
        }
        break;
      case DateRangePickerView.decade:
      case DateRangePickerView.year:
      case DateRangePickerView.century:
        {
          _visibleDates = DateRangePickerHelper.getVisibleYearDates(
              currentDate, view, widget.picker.isHijri);
          _previousViewVisibleDates = DateRangePickerHelper.getVisibleYearDates(
              prevDate, view, widget.picker.isHijri);
          _nextViewVisibleDates = DateRangePickerHelper.getVisibleYearDates(
              nextDate, view, widget.picker.isHijri);
          if (widget.picker.enableMultiView) {
            afterVisibleDates = DateRangePickerHelper.getVisibleYearDates(
                afterNextViewDate, view, widget.picker.isHijri);
          }
        }
    }

    if (widget.picker.enableMultiView) {
      _updateVisibleDatesForMultiView(afterVisibleDates!);
    }

    _currentViewVisibleDates = _visibleDates;
    _pickerStateDetails.currentViewVisibleDates = _currentViewVisibleDates;

    if (_currentChildIndex == 0) {
      _visibleDates = _nextViewVisibleDates;
      _nextViewVisibleDates = _previousViewVisibleDates;
      _previousViewVisibleDates = _currentViewVisibleDates;
    } else if (_currentChildIndex == 1) {
      _visibleDates = _currentViewVisibleDates;
    } else if (_currentChildIndex == 2) {
      _visibleDates = _previousViewVisibleDates;
      _previousViewVisibleDates = _nextViewVisibleDates;
      _nextViewVisibleDates = _currentViewVisibleDates;
    }
  }

  void _triggerViewChangedCallback() {
    _pickerStateDetails.currentViewVisibleDates = _currentViewVisibleDates;
    widget.updatePickerStateValues(_pickerStateDetails);
  }

  void _moveToNextViewWithAnimation() {
    if (_animationController.isCompleted || _animationController.isDismissed) {
      _animationController.reset();
    } else {
      return;
    }

    _updateSelection();
    if (widget.picker.navigationDirection ==
        DateRangePickerNavigationDirection.vertical) {
      _tween.begin = 0;
      _tween.end = -widget.height;
    } else {
      _tween.begin = 0;
      _tween.end = -widget.width;
    }

    _triggerSelectableDayPredicates(_getCurrentVisibleDates(true));

    _animationController.duration = const Duration(milliseconds: 500);
    _animationController
        .forward()
        .then<dynamic>((dynamic value) => _updateNextView());

    _updateCurrentViewVisibleDates(isNextView: true);
  }

  void _moveToPreviousViewWithAnimation() {
    if (_animationController.isCompleted || _animationController.isDismissed) {
      _animationController.reset();
    } else {
      return;
    }

    _updateSelection();
    if (widget.picker.navigationDirection ==
        DateRangePickerNavigationDirection.vertical) {
      _tween.begin = 0;
      _tween.end = widget.height;
    } else {
      _tween.begin = 0;
      _tween.end = widget.width;
    }

    _triggerSelectableDayPredicates(_getCurrentVisibleDates(false));

    _animationController.duration = const Duration(milliseconds: 500);
    _animationController
        .forward()
        .then<dynamic>((dynamic value) => _updatePreviousView());

    _updateCurrentViewVisibleDates();
  }

  void _updateVisibleDatesForMultiView(List<dynamic> afterVisibleDates) {
    if (widget.isRtl) {
      for (int i = 0; i < _visibleDates.length; i++) {
        _nextViewVisibleDates.add(_visibleDates[i]);
      }
      for (int i = 0; i < _previousViewVisibleDates.length; i++) {
        _visibleDates.add(_previousViewVisibleDates[i]);
      }
      for (int i = 0; i < afterVisibleDates.length; i++) {
        _previousViewVisibleDates.add(afterVisibleDates[i]);
      }
    } else {
      for (int i = 0; i < _visibleDates.length; i++) {
        _previousViewVisibleDates.add(_visibleDates[i]);
      }
      for (int i = 0; i < _nextViewVisibleDates.length; i++) {
        _visibleDates.add(_nextViewVisibleDates[i]);
      }
      for (int i = 0; i < afterVisibleDates.length; i++) {
        _nextViewVisibleDates.add(afterVisibleDates[i]);
      }
    }
  }

  void _updateNextViewVisibleDates() {
    final DateRangePickerView pickerView =
        DateRangePickerHelper.getPickerView(widget.controller.view);
    final int numberOfWeeksInView =
        DateRangePickerHelper.getNumberOfWeeksInView(
            widget.picker.monthViewSettings, widget.picker.isHijri);
    dynamic currentViewDate = _currentViewVisibleDates[0];
    if ((pickerView == DateRangePickerView.month &&
            (numberOfWeeksInView == 6 || widget.picker.isHijri)) ||
        pickerView == DateRangePickerView.year ||
        pickerView == DateRangePickerView.decade ||
        pickerView == DateRangePickerView.century) {
      currentViewDate = _currentViewVisibleDates[
          (_currentViewVisibleDates.length /
                  (widget.picker.enableMultiView ? 4 : 2))
              .truncate()];
    }

    final DateRangePickerView view =
        DateRangePickerHelper.getPickerView(widget.controller.view);

    currentViewDate = DateRangePickerHelper.getNextViewStartDate(
        view,
        numberOfWeeksInView,
        currentViewDate,
        widget.isRtl,
        widget.picker.isHijri);
    List<dynamic>? afterVisibleDates;
    dynamic afterNextViewDate;
    if (widget.picker.enableMultiView && !widget.isRtl) {
      afterNextViewDate = DateRangePickerHelper.getNextViewStartDate(
          view,
          numberOfWeeksInView,
          currentViewDate,
          widget.isRtl,
          widget.picker.isHijri);
    }
    List<dynamic> dates;
    switch (view) {
      case DateRangePickerView.month:
        {
          dates = getVisibleDates(
            currentViewDate,
            null,
            widget.picker.monthViewSettings.firstDayOfWeek,
            DateRangePickerHelper.getViewDatesCount(
                view, numberOfWeeksInView, widget.picker.isHijri),
          );
          if (widget.picker.enableMultiView && !widget.isRtl) {
            afterVisibleDates = getVisibleDates(
              afterNextViewDate,
              null,
              widget.picker.monthViewSettings.firstDayOfWeek,
              DateRangePickerHelper.getViewDatesCount(
                  view, numberOfWeeksInView, widget.picker.isHijri),
            );
          }
        }
        break;
      case DateRangePickerView.year:
      case DateRangePickerView.decade:
      case DateRangePickerView.century:
        {
          dates = DateRangePickerHelper.getVisibleYearDates(
              currentViewDate, view, widget.picker.isHijri);
          if (widget.picker.enableMultiView && !widget.isRtl) {
            afterVisibleDates = DateRangePickerHelper.getVisibleYearDates(
                afterNextViewDate, view, widget.picker.isHijri);
          }
        }
    }

    if (widget.picker.enableMultiView) {
      dates.addAll(_updateNextVisibleDateForMultiView(afterVisibleDates));
    }

    if (_currentChildIndex == 0) {
      _nextViewVisibleDates = dates;
    } else if (_currentChildIndex == 1) {
      _previousViewVisibleDates = dates;
    } else {
      _visibleDates = dates;
    }
  }

  List<dynamic> _updateNextVisibleDateForMultiView(
      List<dynamic>? afterVisibleDates) {
    List<dynamic> dates;
    if (widget.picker.isHijri) {
      dates = <HijriDateTime>[];
    } else {
      dates = <DateTime>[];
    }
    if (!widget.isRtl) {
      for (int i = 0; i < afterVisibleDates!.length; i++) {
        dates.add(afterVisibleDates[i]);
      }
    } else {
      for (int i = 0; i < _currentViewVisibleDates.length ~/ 2; i++) {
        dates.add(_currentViewVisibleDates[i]);
      }
    }

    return dates;
  }

  void _updatePreviousViewVisibleDates() {
    final DateRangePickerView pickerView =
        DateRangePickerHelper.getPickerView(widget.controller.view);
    final int numberOfWeeksInView =
        DateRangePickerHelper.getNumberOfWeeksInView(
            widget.picker.monthViewSettings, widget.picker.isHijri);
    dynamic currentViewDate = _currentViewVisibleDates[0];
    if ((pickerView == DateRangePickerView.month &&
            (numberOfWeeksInView == 6 || widget.picker.isHijri)) ||
        pickerView == DateRangePickerView.year ||
        pickerView == DateRangePickerView.decade ||
        pickerView == DateRangePickerView.century) {
      currentViewDate = _currentViewVisibleDates[
          (_currentViewVisibleDates.length /
                  (widget.picker.enableMultiView ? 4 : 2))
              .truncate()];
    }

    final DateRangePickerView view =
        DateRangePickerHelper.getPickerView(widget.controller.view);

    currentViewDate = DateRangePickerHelper.getPreviousViewStartDate(
        view,
        numberOfWeeksInView,
        currentViewDate,
        widget.isRtl,
        widget.picker.isHijri);
    List<dynamic> dates;
    List<dynamic>? afterVisibleDates;
    dynamic afterNextViewDate;
    if (widget.picker.enableMultiView && widget.isRtl) {
      afterNextViewDate = DateRangePickerHelper.getPreviousViewStartDate(
          view,
          numberOfWeeksInView,
          currentViewDate,
          widget.isRtl,
          widget.picker.isHijri);
    }

    switch (view) {
      case DateRangePickerView.month:
        {
          dates = getVisibleDates(
            currentViewDate,
            null,
            widget.picker.monthViewSettings.firstDayOfWeek,
            DateRangePickerHelper.getViewDatesCount(
                view, numberOfWeeksInView, widget.picker.isHijri),
          );
          if (widget.picker.enableMultiView && widget.isRtl) {
            afterVisibleDates = getVisibleDates(
              afterNextViewDate,
              null,
              widget.picker.monthViewSettings.firstDayOfWeek,
              DateRangePickerHelper.getViewDatesCount(
                  view, numberOfWeeksInView, widget.picker.isHijri),
            );
          }
        }
        break;
      case DateRangePickerView.year:
      case DateRangePickerView.decade:
      case DateRangePickerView.century:
        {
          dates = DateRangePickerHelper.getVisibleYearDates(
              currentViewDate, view, widget.picker.isHijri);
          if (widget.picker.enableMultiView && widget.isRtl) {
            afterVisibleDates = DateRangePickerHelper.getVisibleYearDates(
                afterNextViewDate, view, widget.picker.isHijri);
          }
        }
    }

    if (widget.picker.enableMultiView) {
      dates.addAll(_updatePreviousDatesForMultiView(afterVisibleDates));
    }

    if (_currentChildIndex == 0) {
      _visibleDates = dates;
    } else if (_currentChildIndex == 1) {
      _nextViewVisibleDates = dates;
    } else {
      _previousViewVisibleDates = dates;
    }
  }

  List<dynamic> _updatePreviousDatesForMultiView(
      List<dynamic>? afterVisibleDates) {
    List<dynamic> dates;
    if (widget.picker.isHijri) {
      dates = <HijriDateTime>[];
    } else {
      dates = <DateTime>[];
    }
    if (widget.isRtl) {
      for (int i = 0; i < (afterVisibleDates!.length); i++) {
        dates.add(afterVisibleDates[i]);
      }
    } else {
      for (int i = 0; i < (_currentViewVisibleDates.length / 2); i++) {
        dates.add(_currentViewVisibleDates[i]);
      }
    }
    return dates;
  }

  void _getPickerViewStateDetails(PickerStateArgs details) {
    details.currentViewVisibleDates = _currentViewVisibleDates;
    details.currentDate = _pickerStateDetails.currentDate;
    details.selectedDate = _pickerStateDetails.selectedDate;
    details.selectedDates = _pickerStateDetails.selectedDates;
    details.selectedRange = _pickerStateDetails.selectedRange;
    details.selectedRanges = _pickerStateDetails.selectedRanges;
    details.view = _pickerStateDetails.view;
  }

  void _updatePickerViewStateDetails(PickerStateArgs details) {
    _pickerStateDetails.currentDate = details.currentDate;
    _pickerStateDetails.selectedDate = details.selectedDate;
    _pickerStateDetails.selectedDates = details.selectedDates;
    _pickerStateDetails.selectedRange = details.selectedRange;
    _pickerStateDetails.selectedRanges = details.selectedRanges;
    _pickerStateDetails.view = details.view;
    widget.updatePickerStateValues(_pickerStateDetails);
  }

  _PickerView _getView(
    List<dynamic> dates,
    Key key,
    Function(PickerDateRange?, bool)? onTapCallback,
    Function(PickerDateRange?)? onLongPressCallback,
    DateRangePickerSelectionChangedCallback? dragEndCallback,
  ) {
    return _PickerView(
      widget.picker,
      widget.controller,
      dates,
      _isMultiViewEnabled(widget.picker),
      widget.width,
      widget.height,
      widget.datePickerTheme,
      _focusNode,
      widget.textScaleFactor,
      DateRangePickerHelper.cloneList((_disabledDates != null &&
              _disabledDates?.values != null &&
              _disabledDates!.values.isNotEmpty)
          ? _disabledDates?.values.first
          : null),
      key: key,
      getPickerStateDetails: (PickerStateArgs details) {
        _getPickerViewStateDetails(details);
      },
      updatePickerStateDetails: (PickerStateArgs details) {
        _updatePickerViewStateDetails(details);
      },
      isRtl: widget.isRtl,
      onTapCallback: onTapCallback,
      onLongPressCallback: onLongPressCallback,
      dragEndCallback: dragEndCallback,
    );
  }

  List<Widget> _addViews(
    BuildContext context,
    Function(PickerDateRange?, bool)? onTapCallback,
    Function(PickerDateRange?)? onLongPressCallback,
    DateRangePickerSelectionChangedCallback? dragEndCallback,
  ) {
    if (_children.isEmpty) {
      _previousView = _getView(
        _previousViewVisibleDates,
        _previousViewKey,
        onTapCallback,
        onLongPressCallback,
        dragEndCallback,
      );
      _currentView = _getView(_visibleDates, _currentViewKey, onTapCallback,
          onLongPressCallback, dragEndCallback);
      _nextView = _getView(_nextViewVisibleDates, _nextViewKey, onTapCallback,
          onLongPressCallback, dragEndCallback);

      _children.add(_previousView!);
      _children.add(_currentView!);
      _children.add(_nextView!);
      return _children;
    }

    final _PickerView previousView = _updateViews(
        _previousView!,
        _previousView!.visibleDates,
        _previousViewVisibleDates,
        onTapCallback,
        onLongPressCallback,
        dragEndCallback);
    final _PickerView currentView = _updateViews(
        _currentView!,
        _currentView!.visibleDates,
        _visibleDates,
        onTapCallback,
        onLongPressCallback,
        dragEndCallback);
    final _PickerView nextView = _updateViews(
        _nextView!,
        _nextView!.visibleDates,
        _nextViewVisibleDates,
        onTapCallback,
        onLongPressCallback,
        dragEndCallback);

    if (_previousView != previousView) {
      _previousView = previousView;
    }
    if (_currentView != currentView) {
      _currentView = currentView;
    }
    if (_nextView != nextView) {
      _nextView = nextView;
    }

    return _children;
  }

  _PickerView _updateViews(
    _PickerView view,
    List<dynamic> viewDates,
    List<dynamic> visibleDates,
    Function(PickerDateRange?, bool)? onTapCallback,
    Function(PickerDateRange?)? onLongPressCallback,
    DateRangePickerSelectionChangedCallback? dragEndCallback,
  ) {
    final int index = _children.indexOf(view);

    if (viewDates != visibleDates) {
      view = _getView(visibleDates, view.key!, onTapCallback,
          onLongPressCallback, dragEndCallback);
      _children[index] = view;
    } else if (_disabledDates != null &&
        _disabledDates!.isNotEmpty &&
        _disabledDates?.keys != null &&
        _disabledDates!.keys.isNotEmpty &&
        _disabledDates!.keys.first == viewDates &&
        !DateRangePickerHelper.isDateCollectionEquals(
            view.disableDatePredicates, _disabledDates!.values.first)) {
      view = _getView(viewDates, view.key!, onTapCallback, onLongPressCallback,
          dragEndCallback);
      _children[index] = view;
    }

    return view;
  }

  void _animationListener() {
    setState(() {
      _position = _animation.value;
    });
  }

  void _updateSettings(_PickerScrollView oldWidget) {
    if (oldWidget.picker.monthViewSettings != widget.picker.monthViewSettings ||
        oldWidget.picker.monthCellStyle != widget.picker.monthCellStyle ||
        oldWidget.picker.selectionRadius != widget.picker.selectionRadius ||
        oldWidget.picker.startRangeSelectionColor !=
            widget.picker.startRangeSelectionColor ||
        oldWidget.picker.endRangeSelectionColor !=
            widget.picker.endRangeSelectionColor ||
        oldWidget.picker.rangeSelectionColor !=
            widget.picker.rangeSelectionColor ||
        oldWidget.picker.selectionColor != widget.picker.selectionColor ||
        oldWidget.picker.selectionTextStyle !=
            widget.picker.selectionTextStyle ||
        oldWidget.picker.rangeTextStyle != widget.picker.rangeTextStyle ||
        oldWidget.picker.monthViewSettings.blackoutDates !=
            widget.picker.monthViewSettings.blackoutDates ||
        oldWidget.picker.monthViewSettings.specialDates !=
            widget.picker.monthViewSettings.specialDates ||
        oldWidget.picker.monthViewSettings.weekendDays !=
            widget.picker.monthViewSettings.weekendDays ||
        oldWidget.picker.selectionShape != widget.picker.selectionShape ||
        oldWidget.picker.todayHighlightColor !=
            widget.picker.todayHighlightColor ||
        oldWidget.locale != widget.locale) {
      _children.clear();
      _position = 0;
    }
  }

  void _drawSelection(
      dynamic oldValue, dynamic newValue, DateRangePickerView pickerView) {
    switch (widget.picker.selectionMode) {
      case DateRangePickerSelectionMode.single:
        {
          if (oldValue.selectedDate != newValue.selectedDate ||
              !isSameDate(
                  _pickerStateDetails.selectedDate, newValue.selectedDate)) {
            _pickerStateDetails.selectedDate = newValue.selectedDate;
            if (pickerView != DateRangePickerView.month &&
                !widget.picker.allowViewNavigation) {
              _drawYearSelection();
            } else {
              _drawMonthSelection();
            }

            _position = 0;
          }
        }
        break;
      case DateRangePickerSelectionMode.multiple:
        {
          if (oldValue.selectedDates != newValue.selectedDates ||
              !DateRangePickerHelper.isDateCollectionEquals(
                  _pickerStateDetails.selectedDates, newValue.selectedDates)) {
            _pickerStateDetails.selectedDates =
                newValue.selectedDates as List<dynamic>?;
            if (pickerView != DateRangePickerView.month &&
                !widget.picker.allowViewNavigation) {
              _drawYearSelection();
            } else {
              _drawMonthSelection();
            }

            _position = 0;
          }
        }
        break;
      case DateRangePickerSelectionMode.range:
      case DateRangePickerSelectionMode.extendableRange:
        {
          if (oldValue.selectedRange != newValue.selectedRange ||
              !DateRangePickerHelper.isRangeEquals(
                  _pickerStateDetails.selectedRange, newValue.selectedRange)) {
            _pickerStateDetails.selectedRange = newValue.selectedRange;
            if (pickerView != DateRangePickerView.month &&
                !widget.picker.allowViewNavigation) {
              _drawYearSelection();
            } else {
              _drawMonthSelection();
            }

            _position = 0;
          }
        }
        break;
      case DateRangePickerSelectionMode.multiRange:
        {
          if (oldValue.selectedRanges != newValue.selectedRanges ||
              !DateRangePickerHelper.isDateRangesEquals(
                  _pickerStateDetails.selectedRanges,
                  newValue.selectedRanges)) {
            _pickerStateDetails.selectedRanges =
                newValue.selectedRanges as List<dynamic>?;
            if (pickerView != DateRangePickerView.month &&
                !widget.picker.allowViewNavigation) {
              _drawYearSelection();
            } else {
              _drawMonthSelection();
            }

            _position = 0;
          }
        }
    }
  }

  void _updateSelection({dynamic selectedDate}) {
    final DateRangePickerView pickerView =
        DateRangePickerHelper.getPickerView(widget.controller.view);

    if (pickerView != DateRangePickerView.month &&
        widget.picker.allowViewNavigation) {
      return;
    }

    widget.getPickerStateValues(_pickerStateDetails);
    for (int i = 0; i < _children.length; i++) {
      if (i == _currentChildIndex) {
        continue;
      }

      final DateRangePickerView view =
          DateRangePickerHelper.getPickerView(widget.controller.view);

      final _PickerViewState viewState = _getCurrentViewState(i);
      switch (view) {
        case DateRangePickerView.month:
          {
            viewState._monthView!.selectionNotifier.value =
                !viewState._monthView!.selectionNotifier.value;
          }
          break;
        case DateRangePickerView.year:
        case DateRangePickerView.decade:
        case DateRangePickerView.century:
          {
            viewState._yearView!.selectionNotifier.value =
                !viewState._yearView!.selectionNotifier.value;
          }
      }

      if (widget.picker.selectionMode == DateRangePickerSelectionMode.range ||
          widget.picker.selectionMode ==
              DateRangePickerSelectionMode.extendableRange) {
        viewState._lastSelectedDate = selectedDate;
      }
    }
  }

  void _drawMonthSelection() {
    final DateRangePickerView pickerView =
        DateRangePickerHelper.getPickerView(widget.controller.view);
    if (pickerView != DateRangePickerView.month || _children.isEmpty) {
      return;
    }

    for (int i = 0; i < _children.length; i++) {
      final _PickerViewState viewState = _getCurrentViewState(i);

      if (viewState._monthView!.visibleDates !=
          _pickerStateDetails.currentViewVisibleDates) {
        continue;
      }

      viewState._monthView!.selectionNotifier.value =
          !viewState._monthView!.selectionNotifier.value;
    }
  }

  void _drawYearSelection() {
    final DateRangePickerView pickerView =
        DateRangePickerHelper.getPickerView(widget.controller.view);
    if (pickerView == DateRangePickerView.month || _children.isEmpty) {
      return;
    }

    for (int i = 0; i < _children.length; i++) {
      final _PickerViewState viewState = _getCurrentViewState(i);

      if (viewState._yearView!.visibleDates !=
          _pickerStateDetails.currentViewVisibleDates) {
        continue;
      }

      viewState._yearView!.selectionNotifier.value =
          !viewState._yearView!.selectionNotifier.value;
    }
  }

  _PickerViewState _getCurrentViewState(int index) {
    if (index == 1) {
      return _currentViewKey.currentState!;
    } else if (index == 2) {
      return _nextViewKey.currentState!;
    }

    return _previousViewKey.currentState!;
  }

  List<dynamic> _getCurrentVisibleDates(bool isNextView) {
    if (isNextView) {
      if (_currentChildIndex == 0) {
        return _visibleDates;
      } else if (_currentChildIndex == 1) {
        return _nextViewVisibleDates;
      } else {
        return _previousViewVisibleDates;
      }
    } else {
      if (_currentChildIndex == 0) {
        return _nextViewVisibleDates;
      } else if (_currentChildIndex == 1) {
        return _previousViewVisibleDates;
      } else {
        return _visibleDates;
      }
    }
  }

  void _updateCurrentViewVisibleDates({bool isNextView = false}) {
    final DateRangePickerView pickerView =
        DateRangePickerHelper.getPickerView(widget.controller.view);
    _currentViewVisibleDates = _getCurrentVisibleDates(isNextView);

    _pickerStateDetails.currentViewVisibleDates = _currentViewVisibleDates;
    _pickerStateDetails.currentDate = _currentViewVisibleDates[0];
    final int numberOfWeeksInView =
        DateRangePickerHelper.getNumberOfWeeksInView(
            widget.picker.monthViewSettings, widget.picker.isHijri);
    if (pickerView == DateRangePickerView.month &&
        (numberOfWeeksInView == 6 || widget.picker.isHijri)) {
      final dynamic date = _currentViewVisibleDates[
          _currentViewVisibleDates.length ~/
              (widget.picker.enableMultiView ? 4 : 2)];
      _pickerStateDetails.currentDate = DateRangePickerHelper.getDate(
          date.year, date.month, 1, widget.picker.isHijri);
    }

    widget.updatePickerStateValues(_pickerStateDetails);
  }

  void _updateNextView() {
    if (!_animationController.isCompleted) {
      return;
    }

    _updateNextViewVisibleDates();

    if (_currentChildIndex == 0) {
      _currentChildIndex = 1;
    } else if (_currentChildIndex == 1) {
      _currentChildIndex = 2;
    } else if (_currentChildIndex == 2) {
      _currentChildIndex = 0;
    }

    if (kIsWeb) {
      setState(() {});
    }

    _resetPosition();
  }

  void _updatePreviousView() {
    if (!_animationController.isCompleted) {
      return;
    }

    _updatePreviousViewVisibleDates();

    if (_currentChildIndex == 0) {
      _currentChildIndex = 2;
    } else if (_currentChildIndex == 1) {
      _currentChildIndex = 0;
    } else if (_currentChildIndex == 2) {
      _currentChildIndex = 1;
    }

    if (kIsWeb) {
      setState(() {});
    }

    _resetPosition();
  }

  void _resetPosition() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_position.abs() == widget.width || _position.abs() == widget.height) {
        _position = 0;
      }
    });
  }

  dynamic _getYearSelectedDate(dynamic selectedDate, LogicalKeyboardKey key,
      _PickerView view, _PickerViewState state) {
    final DateRangePickerView pickerView =
        DateRangePickerHelper.getPickerView(widget.controller.view);
    dynamic date;

    int index = DateRangePickerHelper.getDateCellIndex(
        view.visibleDates, selectedDate, widget.controller.view);
    if (key == LogicalKeyboardKey.arrowRight) {
      if ((index == view.visibleDates.length - 1 ||
              (widget.picker.enableMultiView &&
                  pickerView != DateRangePickerView.year &&
                  index >= view.visibleDates.length - 3)) &&
          widget.picker.selectionMode == DateRangePickerSelectionMode.single) {
        widget.isRtl
            ? _moveToPreviousViewWithAnimation()
            : _moveToNextViewWithAnimation();
      }

      if (index != -1) {
        date = _updateNextYearSelectionDate(selectedDate);
      }
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      if (index == 0 &&
          widget.picker.selectionMode == DateRangePickerSelectionMode.single) {
        widget.isRtl
            ? _moveToNextViewWithAnimation()
            : _moveToPreviousViewWithAnimation();
      }

      if (index != -1) {
        date = _updatePreviousYearSelectionDate(selectedDate);
      }
    } else if (key == LogicalKeyboardKey.arrowUp) {
      if (index >= 3 && index != -1) {
        index -= 3;
        date = view.visibleDates[index];
      }
    } else if (key == LogicalKeyboardKey.arrowDown) {
      if (index <= 8 && index != -1) {
        index += 3;
        date = view.visibleDates[index];
      } else if (widget.picker.enableMultiView &&
          widget.picker.navigationDirection ==
              DateRangePickerNavigationDirection.vertical &&
          index <= 20 &&
          index != -1) {
        index += 3;
        date = _updateNextYearSelectionDate(selectedDate);
        for (int i = 1; i < 3; i++) {
          date = _updateNextYearSelectionDate(date);
        }
      }
    }

    return date;
  }

  dynamic _updateNextYearSelectionDate(dynamic selectedDate) {
    final DateRangePickerView view =
        DateRangePickerHelper.getPickerView(widget.controller.view);
    final int numberOfWeeksInView =
        DateRangePickerHelper.getNumberOfWeeksInView(
            widget.picker.monthViewSettings, widget.picker.isHijri);
    switch (view) {
      case DateRangePickerView.month:
        {
          break;
        }
      case DateRangePickerView.year:
        {
          return DateRangePickerHelper.getNextViewStartDate(
              DateRangePickerView.month,
              numberOfWeeksInView,
              selectedDate,
              widget.isRtl,
              widget.picker.isHijri);
        }
      case DateRangePickerView.decade:
        {
          return DateRangePickerHelper.getNextViewStartDate(
              DateRangePickerView.year,
              numberOfWeeksInView,
              selectedDate,
              widget.isRtl,
              widget.picker.isHijri);
        }
      case DateRangePickerView.century:
        {
          return DateRangePickerHelper.getNextViewStartDate(
              DateRangePickerView.decade,
              numberOfWeeksInView,
              selectedDate,
              widget.isRtl,
              widget.picker.isHijri);
        }
    }

    return selectedDate;
  }

  dynamic _updatePreviousYearSelectionDate(dynamic selectedDate) {
    final int numberOfWeeksInView =
        DateRangePickerHelper.getNumberOfWeeksInView(
            widget.picker.monthViewSettings, widget.picker.isHijri);
    final DateRangePickerView view =
        DateRangePickerHelper.getPickerView(widget.controller.view);
    switch (view) {
      case DateRangePickerView.month:
        {
          break;
        }
      case DateRangePickerView.year:
        {
          return DateRangePickerHelper.getPreviousViewStartDate(
              DateRangePickerView.month,
              numberOfWeeksInView,
              selectedDate,
              widget.isRtl,
              widget.picker.isHijri);
        }
      case DateRangePickerView.decade:
        {
          return DateRangePickerHelper.getPreviousViewStartDate(
              DateRangePickerView.year,
              numberOfWeeksInView,
              selectedDate,
              widget.isRtl,
              widget.picker.isHijri);
        }
      case DateRangePickerView.century:
        {
          return DateRangePickerHelper.getPreviousViewStartDate(
              DateRangePickerView.decade,
              numberOfWeeksInView,
              selectedDate,
              widget.isRtl,
              widget.picker.isHijri);
        }
    }

    return selectedDate;
  }

  KeyEventResult _switchViewsByKeyBoardEvent(RawKeyEvent event) {
    if (event.isAltPressed) {
      if (event.logicalKey == LogicalKeyboardKey.digit1) {
        _pickerStateDetails.view = DateRangePickerView.month;
      } else if (event.logicalKey == LogicalKeyboardKey.digit2) {
        _pickerStateDetails.view = DateRangePickerView.year;
      } else if (event.logicalKey == LogicalKeyboardKey.digit3) {
        _pickerStateDetails.view = DateRangePickerView.decade;
      } else if (event.logicalKey == LogicalKeyboardKey.digit4) {
        _pickerStateDetails.view = DateRangePickerView.century;
      } else {
        return KeyEventResult.ignored;
      }

      widget.updatePickerStateValues(_pickerStateDetails);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  KeyEventResult _updateYearSelectionByKeyBoardNavigation(
      _PickerViewState currentVisibleViewState,
      _PickerView currentVisibleView,
      DateRangePickerView pickerView,
      RawKeyEvent event) {
    dynamic selectedDate;
    if (_pickerStateDetails.selectedDate != null &&
        widget.picker.selectionMode == DateRangePickerSelectionMode.single) {
      selectedDate = _getYearSelectedDate(_pickerStateDetails.selectedDate,
          event.logicalKey, currentVisibleView, currentVisibleViewState);
      if (selectedDate != null &&
          DateRangePickerHelper.isBetweenMinMaxDateCell(
              selectedDate,
              widget.picker.minDate,
              widget.picker.maxDate,
              widget.picker.enablePastDates,
              widget.controller.view,
              widget.picker.isHijri)) {
        _pickerStateDetails.selectedDate = selectedDate;
      }
    } else if (widget.picker.selectionMode ==
            DateRangePickerSelectionMode.multiple &&
        _pickerStateDetails.selectedDates != null &&
        _pickerStateDetails.selectedDates!.isNotEmpty &&
        event.isShiftPressed) {
      final dynamic date = _pickerStateDetails
          .selectedDates![_pickerStateDetails.selectedDates!.length - 1];
      selectedDate = _getYearSelectedDate(
          date, event.logicalKey, currentVisibleView, currentVisibleViewState);
      if (selectedDate != null &&
          DateRangePickerHelper.isBetweenMinMaxDateCell(
              selectedDate,
              widget.picker.minDate,
              widget.picker.maxDate,
              widget.picker.enablePastDates,
              widget.controller.view,
              widget.picker.isHijri)) {
        _pickerStateDetails.selectedDates =
            DateRangePickerHelper.cloneList(_pickerStateDetails.selectedDates)
              ?..add(selectedDate);
      }
    } else if ((widget.picker.selectionMode ==
                DateRangePickerSelectionMode.range ||
            widget.picker.selectionMode ==
                DateRangePickerSelectionMode.extendableRange) &&
        _pickerStateDetails.selectedRange != null &&
        _pickerStateDetails.selectedRange.startDate != null &&
        event.isShiftPressed) {
      final dynamic date = currentVisibleViewState._lastSelectedDate;
      selectedDate = _getYearSelectedDate(
          date, event.logicalKey, currentVisibleView, currentVisibleViewState);
      if (selectedDate == null ||
          !DateRangePickerHelper.isBetweenMinMaxDateCell(
              selectedDate,
              widget.picker.minDate,
              widget.picker.maxDate,
              widget.picker.enablePastDates,
              widget.controller.view,
              widget.picker.isHijri)) {
        return KeyEventResult.ignored;
      }

      final bool isExtendableRange = widget.picker.selectionMode ==
          DateRangePickerSelectionMode.extendableRange;

      if (isExtendableRange &&
          DateRangePickerHelper.isDisableDirectionDate(
              _pickerStateDetails.selectedRange,
              selectedDate,
              widget.picker.extendableRangeSelectionDirection,
              pickerView,
              widget.picker.isHijri)) {
        return KeyEventResult.ignored;
      }

      dynamic startDate = _pickerStateDetails.selectedRange.startDate;
      dynamic endDate = _pickerStateDetails.selectedRange.endDate ?? startDate;
      if (selectedDate.isAfter(endDate) == true) {
        endDate = selectedDate;
      } else if (selectedDate.isBefore(startDate) == true) {
        startDate = selectedDate;
      } else if (selectedDate.isAfter(startDate) == true &&
          selectedDate.isBefore(endDate) == true) {
        if (isExtendableRange &&
            widget.picker.extendableRangeSelectionDirection !=
                ExtendableRangeSelectionDirection.both) {
          if (widget.picker.extendableRangeSelectionDirection ==
              ExtendableRangeSelectionDirection.forward) {
            endDate = selectedDate;
          } else if (widget.picker.extendableRangeSelectionDirection ==
              ExtendableRangeSelectionDirection.backward) {
            startDate = selectedDate;
          }
        } else {
          final int overAllDifference =
              endDate.difference(startDate).inDays as int;
          final int selectedDateIndex =
              selectedDate.difference(startDate).inDays as int;
          if (selectedDateIndex > overAllDifference / 2) {
            endDate = selectedDate;
          } else {
            startDate = selectedDate;
          }
        }
      }

      if (DateRangePickerHelper.isSameCellDates(
          startDate, endDate, pickerView)) {
        return KeyEventResult.ignored;
      }

      endDate = DateRangePickerHelper.getLastDate(
          endDate, widget.controller.view, widget.picker.isHijri);
      if (widget.picker.maxDate != null) {
        endDate = endDate.isAfter(widget.picker.maxDate) == true
            ? widget.picker.maxDate
            : endDate;
      }

      startDate = DateRangePickerHelper.getFirstDate(
          startDate, widget.picker.isHijri, pickerView);
      if (widget.picker.minDate != null) {
        startDate = startDate.isBefore(widget.picker.minDate) == true
            ? widget.picker.minDate
            : startDate;
      }

      _pickerStateDetails.selectedRange = widget.picker.isHijri
          ? HijriDateRange(startDate, endDate)
          : PickerDateRange(startDate, endDate);
      currentVisibleViewState._lastSelectedDate = selectedDate;
    } else {
      return KeyEventResult.ignored;
    }

    widget.updatePickerStateValues(_pickerStateDetails);
    _drawYearSelection();
    return KeyEventResult.handled;
  }

  void _updateRangeSelectionByKeyboardNavigation(dynamic selectedDate) {
    if (_pickerStateDetails.selectedRange != null &&
        _pickerStateDetails.selectedRange.startDate != null &&
        (_pickerStateDetails.selectedRange.endDate == null ||
            isSameDate(_pickerStateDetails.selectedRange.startDate,
                _pickerStateDetails.selectedRange.endDate))) {
      dynamic startDate = _pickerStateDetails.selectedRange.startDate;
      dynamic endDate = selectedDate;
      if (startDate.isAfter(endDate) == true) {
        final dynamic temp = startDate;
        startDate = endDate;
        endDate = temp;
      }

      _pickerStateDetails.selectedRange = widget.picker.isHijri
          ? HijriDateRange(startDate, endDate)
          : PickerDateRange(startDate, endDate);
    } else {
      _pickerStateDetails.selectedRange = widget.picker.isHijri
          ? HijriDateRange(selectedDate, null)
          : PickerDateRange(selectedDate, null);
    }
  }

  void _updateSelectionByKeyboardNavigation(dynamic selectedDate) {
    switch (widget.picker.selectionMode) {
      case DateRangePickerSelectionMode.single:
        {
          _pickerStateDetails.selectedDate = selectedDate;
        }
        break;
      case DateRangePickerSelectionMode.multiple:
        {
          _pickerStateDetails.selectedDates!.add(selectedDate);
        }
        break;
      case DateRangePickerSelectionMode.range:
      case DateRangePickerSelectionMode.extendableRange:
        {
          if (_pickerStateDetails.selectedRange != null &&
              _pickerStateDetails.selectedRange.startDate != null &&
              _pickerStateDetails.selectedRange.endDate != null) {
            dynamic startDate = _pickerStateDetails.selectedRange.startDate;
            dynamic endDate = _pickerStateDetails.selectedRange.endDate;
            if (selectedDate.isAfter(endDate) == true) {
              endDate = selectedDate;
            } else if (selectedDate.isBefore(startDate) == true) {
              startDate = selectedDate;
            } else if (selectedDate.isAfter(startDate) == true &&
                selectedDate.isBefore(endDate) == true) {
              if (widget.picker.selectionMode ==
                      DateRangePickerSelectionMode.extendableRange &&
                  widget.picker.extendableRangeSelectionDirection !=
                      ExtendableRangeSelectionDirection.both) {
                if (widget.picker.extendableRangeSelectionDirection ==
                    ExtendableRangeSelectionDirection.forward) {
                  endDate = selectedDate;
                } else if (widget.picker.extendableRangeSelectionDirection ==
                    ExtendableRangeSelectionDirection.backward) {
                  startDate = selectedDate;
                }
              } else {
                final int overAllDifference =
                    endDate.difference(startDate).inDays as int;
                final int selectedDateIndex =
                    selectedDate.difference(startDate).inDays as int;
                if (selectedDateIndex > overAllDifference / 2) {
                  endDate = selectedDate;
                } else {
                  startDate = selectedDate;
                }
              }
            }
            _pickerStateDetails.selectedRange = widget.picker.isHijri
                ? HijriDateRange(startDate, endDate)
                : PickerDateRange(startDate, endDate);
          } else {
            _updateRangeSelectionByKeyboardNavigation(selectedDate);
          }
        }
        break;
      case DateRangePickerSelectionMode.multiRange:
        break;
    }
  }

  KeyEventResult _onKeyDown(FocusNode node, RawKeyEvent event) {
    KeyEventResult result = KeyEventResult.ignored;
    if (event.runtimeType != RawKeyDownEvent) {
      return result;
    }

    if (event.isShiftPressed && event.logicalKey == LogicalKeyboardKey.tab) {
      FocusScope.of(context).previousFocus();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.tab) {
      FocusScope.of(context).nextFocus();
      return KeyEventResult.handled;
    }

    final DateRangePickerView pickerView =
        DateRangePickerHelper.getPickerView(widget.controller.view);

    result = _switchViewsByKeyBoardEvent(event);

    if (event.isControlPressed) {
      final bool canMoveToNextView = DateRangePickerHelper.canMoveToNextViewRtl(
          pickerView,
          DateRangePickerHelper.getNumberOfWeeksInView(
              widget.picker.monthViewSettings, widget.picker.isHijri),
          widget.picker.minDate,
          widget.picker.maxDate,
          _currentViewVisibleDates,
          widget.isRtl,
          widget.picker.enableMultiView,
          widget.picker.isHijri);
      final bool canMoveToPreviousView =
          DateRangePickerHelper.canMoveToPreviousViewRtl(
              pickerView,
              DateRangePickerHelper.getNumberOfWeeksInView(
                  widget.picker.monthViewSettings, widget.picker.isHijri),
              widget.picker.minDate,
              widget.picker.maxDate,
              _currentViewVisibleDates,
              widget.isRtl,
              widget.picker.enableMultiView,
              widget.picker.isHijri);
      if (event.logicalKey == LogicalKeyboardKey.arrowRight &&
          canMoveToNextView) {
        widget.isRtl
            ? _moveToPreviousViewWithAnimation()
            : _moveToNextViewWithAnimation();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft &&
          canMoveToPreviousView) {
        widget.isRtl
            ? _moveToNextViewWithAnimation()
            : _moveToPreviousViewWithAnimation();
        return KeyEventResult.handled;
      }
      result = KeyEventResult.ignored;
    }

    if (pickerView != DateRangePickerView.month &&
        widget.picker.allowViewNavigation) {
      return result;
    }

    if (_pickerStateDetails.selectedDate == null &&
        (_pickerStateDetails.selectedDates == null ||
            _pickerStateDetails.selectedDates!.isEmpty) &&
        _pickerStateDetails.selectedRange == null &&
        (_pickerStateDetails.selectedRanges == null ||
            _pickerStateDetails.selectedRanges!.isEmpty)) {
      return result;
    }

    _PickerViewState currentVisibleViewState;
    _PickerView currentVisibleView;
    if (_currentChildIndex == 0) {
      currentVisibleViewState = _previousViewKey.currentState!;
      currentVisibleView = _previousView!;
    } else if (_currentChildIndex == 1) {
      currentVisibleViewState = _currentViewKey.currentState!;
      currentVisibleView = _currentView!;
    } else {
      currentVisibleViewState = _nextViewKey.currentState!;
      currentVisibleView = _nextView!;
    }

    if (pickerView != DateRangePickerView.month) {
      result = _updateYearSelectionByKeyBoardNavigation(
          currentVisibleViewState, currentVisibleView, pickerView, event);
      return result;
    }

    final dynamic selectedDate =
        _updateSelectedDate(event, currentVisibleViewState, currentVisibleView);

    if (DateRangePickerHelper.isDateWithInVisibleDates(
            currentVisibleView.visibleDates,
            widget.picker.monthViewSettings.blackoutDates,
            selectedDate) ||
        DateRangePickerHelper.isDateWithInVisibleDates(
            currentVisibleView.visibleDates,
            currentVisibleView.disableDatePredicates,
            selectedDate) ||
        !DateRangePickerHelper.isEnabledDate(
            widget.picker.minDate,
            widget.picker.maxDate,
            widget.picker.enablePastDates,
            selectedDate,
            widget.picker.isHijri)) {
      return result;
    }

    if (widget.picker.selectionMode ==
            DateRangePickerSelectionMode.extendableRange &&
        _pickerStateDetails.selectedRange != null &&
        DateRangePickerHelper.isDisableDirectionDate(
            _pickerStateDetails.selectedRange,
            selectedDate,
            widget.picker.extendableRangeSelectionDirection,
            pickerView,
            widget.picker.isHijri)) {
      return result;
    }

    final int numberOfWeeksInView =
        DateRangePickerHelper.getNumberOfWeeksInView(
            widget.picker.monthViewSettings, widget.picker.isHijri);
    final dynamic visibleStartDate = currentVisibleView.visibleDates[0];
    final dynamic visibleEndDate = currentVisibleView
        .visibleDates[currentVisibleView.visibleDates.length - 1];
    final int datesCount = currentVisibleView.visibleDates.length ~/
        (widget.picker.enableMultiView ? 2 : 1);

    final bool showLeadingTrailingDates = widget.picker.enableMultiView
        ? false
        : DateRangePickerHelper.canShowLeadingAndTrailingDates(
            widget.picker.monthViewSettings, widget.picker.isHijri);
    final bool isCurrentMonthDate = widget.picker.enableMultiView
        ? (DateRangePickerHelper.isDateAsCurrentMonthDate(
                currentVisibleView.visibleDates[datesCount ~/ 2],
                numberOfWeeksInView,
                showLeadingTrailingDates,
                selectedDate,
                widget.picker.isHijri) ||
            DateRangePickerHelper.isDateAsCurrentMonthDate(
                currentVisibleView.visibleDates[datesCount + (datesCount ~/ 2)],
                numberOfWeeksInView,
                showLeadingTrailingDates,
                selectedDate,
                widget.picker.isHijri))
        : DateRangePickerHelper.isDateAsCurrentMonthDate(
            currentVisibleView.visibleDates[datesCount ~/ 2],
            numberOfWeeksInView,
            showLeadingTrailingDates,
            selectedDate,
            widget.picker.isHijri);
    if (!isCurrentMonthDate ||
        !isDateWithInDateRange(
            visibleStartDate, visibleEndDate, selectedDate)) {
      final int month = selectedDate.month as int;
      final dynamic nextMonthDate = getNextMonthDate(
          currentVisibleView.visibleDates[
              currentVisibleView.visibleDates.length ~/
                  (widget.picker.enableMultiView ? 4 : 2)]);
      int nextMonth = nextMonthDate.month as int;
      final dynamic nextMonthEndDate =
          DateRangePickerHelper.getMonthEndDate(nextMonthDate);
      if (isDateWithInDateRange(
          visibleStartDate, visibleEndDate, nextMonthEndDate)) {
        nextMonth = getNextMonthDate(nextMonthEndDate).month as int;
      }
      if (month == nextMonth) {
        widget.isRtl
            ? _moveToPreviousViewWithAnimation()
            : _moveToNextViewWithAnimation();
      } else {
        widget.isRtl
            ? _moveToNextViewWithAnimation()
            : _moveToPreviousViewWithAnimation();
      }

      result = KeyEventResult.handled;
    }

    result = KeyEventResult.handled;
    currentVisibleViewState._drawSelection(selectedDate, true);
    _updateSelectionByKeyboardNavigation(selectedDate);
    widget.updatePickerStateValues(_pickerStateDetails);
    currentVisibleViewState._monthView!.selectionNotifier.value =
        !currentVisibleViewState._monthView!.selectionNotifier.value;
    _updateSelection(selectedDate: selectedDate);
    return result;
  }

  dynamic _updateSingleSelectionByKeyBoardKeys(
      RawKeyEvent event, _PickerView currentView) {
    dynamic selectedDate = _pickerStateDetails.selectedDate;
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (isSameDate(_pickerStateDetails.selectedDate,
          currentView.visibleDates[currentView.visibleDates.length - 1])) {
        _moveToNextViewWithAnimation();
      }
      do {
        selectedDate = addDays(selectedDate, 1);
      } while (DateRangePickerHelper.isDateWithInVisibleDates(
          currentView.visibleDates,
          widget.picker.monthViewSettings.blackoutDates,
          selectedDate));

      return selectedDate;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (isSameDate(
          _pickerStateDetails.selectedDate, currentView.visibleDates[0])) {
        _moveToPreviousViewWithAnimation();
      }
      do {
        selectedDate = addDays(selectedDate, -1);
      } while (DateRangePickerHelper.isDateWithInVisibleDates(
          currentView.visibleDates,
          widget.picker.monthViewSettings.blackoutDates,
          selectedDate));

      return selectedDate;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      do {
        selectedDate = addDays(selectedDate, -DateTime.daysPerWeek);
      } while (DateRangePickerHelper.isDateWithInVisibleDates(
          currentView.visibleDates,
          widget.picker.monthViewSettings.blackoutDates,
          selectedDate));
      return selectedDate;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      do {
        selectedDate = addDays(selectedDate, DateTime.daysPerWeek);
      } while (DateRangePickerHelper.isDateWithInVisibleDates(
          currentView.visibleDates,
          widget.picker.monthViewSettings.blackoutDates,
          selectedDate));
      return selectedDate;
    }
    return null;
  }

  dynamic _updateMultiAndRangeSelectionByKeyBoard(RawKeyEvent event,
      _PickerViewState currentState, _PickerView currentView) {
    dynamic selectedDate;
    if (event.isShiftPressed &&
        event.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (widget.picker.selectionMode ==
          DateRangePickerSelectionMode.multiple) {
        selectedDate = _pickerStateDetails
            .selectedDates![_pickerStateDetails.selectedDates!.length - 1];
        do {
          selectedDate = addDays(selectedDate, 1);
        } while (DateRangePickerHelper.isDateWithInVisibleDates(
            currentView.visibleDates,
            widget.picker.monthViewSettings.blackoutDates,
            selectedDate));
        return selectedDate;
      } else {
        selectedDate = currentState._lastSelectedDate;
        do {
          selectedDate = addDays(selectedDate, 1);
        } while (DateRangePickerHelper.isDateWithInVisibleDates(
            currentView.visibleDates,
            widget.picker.monthViewSettings.blackoutDates,
            selectedDate));
        return selectedDate;
      }
    } else if (event.isShiftPressed &&
        event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (widget.picker.selectionMode ==
          DateRangePickerSelectionMode.multiple) {
        selectedDate = _pickerStateDetails
            .selectedDates![_pickerStateDetails.selectedDates!.length - 1];
        do {
          selectedDate = addDays(selectedDate, -1);
        } while (DateRangePickerHelper.isDateWithInVisibleDates(
            currentView.visibleDates,
            widget.picker.monthViewSettings.blackoutDates,
            selectedDate));
        return selectedDate;
      } else {
        selectedDate = currentState._lastSelectedDate;
        do {
          selectedDate = addDays(selectedDate, -1);
        } while (DateRangePickerHelper.isDateWithInVisibleDates(
            currentView.visibleDates,
            widget.picker.monthViewSettings.blackoutDates,
            selectedDate));
        return selectedDate;
      }
    } else if (event.isShiftPressed &&
        event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (widget.picker.selectionMode ==
          DateRangePickerSelectionMode.multiple) {
        selectedDate = _pickerStateDetails
            .selectedDates![_pickerStateDetails.selectedDates!.length - 1];
        do {
          selectedDate = addDays(selectedDate, -DateTime.daysPerWeek);
        } while (DateRangePickerHelper.isDateWithInVisibleDates(
            currentView.visibleDates,
            widget.picker.monthViewSettings.blackoutDates,
            selectedDate));
        return selectedDate;
      } else {
        selectedDate = currentState._lastSelectedDate;
        do {
          selectedDate = addDays(selectedDate, -DateTime.daysPerWeek);
        } while (DateRangePickerHelper.isDateWithInVisibleDates(
            currentView.visibleDates,
            widget.picker.monthViewSettings.blackoutDates,
            selectedDate));
        return selectedDate;
      }
    } else if (event.isShiftPressed &&
        event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (widget.picker.selectionMode ==
          DateRangePickerSelectionMode.multiple) {
        selectedDate = _pickerStateDetails
            .selectedDates![_pickerStateDetails.selectedDates!.length - 1];
        do {
          selectedDate = addDays(selectedDate, DateTime.daysPerWeek);
        } while (DateRangePickerHelper.isDateWithInVisibleDates(
            currentView.visibleDates,
            widget.picker.monthViewSettings.blackoutDates,
            selectedDate));
        return selectedDate;
      } else {
        selectedDate = currentState._lastSelectedDate;
        do {
          selectedDate = addDays(selectedDate, DateTime.daysPerWeek);
        } while (DateRangePickerHelper.isDateWithInVisibleDates(
            currentView.visibleDates,
            widget.picker.monthViewSettings.blackoutDates,
            selectedDate));
        return selectedDate;
      }
    }
    return null;
  }

  dynamic _updateSelectedDate(RawKeyEvent event, _PickerViewState currentState,
      _PickerView currentView) {
    switch (widget.picker.selectionMode) {
      case DateRangePickerSelectionMode.single:
        {
          return _updateSingleSelectionByKeyBoardKeys(event, currentView);
        }
      case DateRangePickerSelectionMode.multiple:
      case DateRangePickerSelectionMode.range:
      case DateRangePickerSelectionMode.extendableRange:
        {
          return _updateMultiAndRangeSelectionByKeyBoard(
              event, currentState, currentView);
        }
      case DateRangePickerSelectionMode.multiRange:
        break;
    }

    return null;
  }

  void _onHorizontalStart(DragStartDetails dragStartDetails) {
    switch (widget.picker.navigationDirection) {
      case DateRangePickerNavigationDirection.horizontal:
        {
          _scrollStartPosition = dragStartDetails.globalPosition.dx;
          _updateSelection();
        }
        break;
      case DateRangePickerNavigationDirection.vertical:
        break;
    }
  }

  void _onHorizontalUpdate(DragUpdateDetails dragUpdateDetails) {
    final DateRangePickerView pickerView =
        DateRangePickerHelper.getPickerView(widget.controller.view);
    switch (widget.picker.navigationDirection) {
      case DateRangePickerNavigationDirection.horizontal:
        {
          final double difference =
              dragUpdateDetails.globalPosition.dx - _scrollStartPosition!;
          if (difference < 0 &&
              !DateRangePickerHelper.canMoveToNextViewRtl(
                  pickerView,
                  DateRangePickerHelper.getNumberOfWeeksInView(
                      widget.picker.monthViewSettings, widget.picker.isHijri),
                  widget.picker.minDate,
                  widget.picker.maxDate,
                  _currentViewVisibleDates,
                  widget.isRtl,
                  widget.picker.enableMultiView,
                  widget.picker.isHijri)) {
            return;
          } else if (difference > 0 &&
              !DateRangePickerHelper.canMoveToPreviousViewRtl(
                  pickerView,
                  DateRangePickerHelper.getNumberOfWeeksInView(
                      widget.picker.monthViewSettings, widget.picker.isHijri),
                  widget.picker.minDate,
                  widget.picker.maxDate,
                  _currentViewVisibleDates,
                  widget.isRtl,
                  widget.picker.enableMultiView,
                  widget.picker.isHijri)) {
            return;
          }

          final bool isNextView = difference < 0;
          _triggerSelectableDayPredicates(_getCurrentVisibleDates(isNextView));

          _position = difference;
          setState(() {
            /* Updates the widget navigated distance and moves the widget
              in the custom scroll view */
          });
        }
        break;
      case DateRangePickerNavigationDirection.vertical:
        break;
    }
  }

  void _onHorizontalEnd(DragEndDetails dragEndDetails) {
    final DateRangePickerView pickerView =
        DateRangePickerHelper.getPickerView(widget.controller.view);
    switch (widget.picker.navigationDirection) {
      case DateRangePickerNavigationDirection.vertical:
        break;
      case DateRangePickerNavigationDirection.horizontal:
        {
          _position = _position != 0 ? _position : 0;

          if (-_position >= widget.width / 2) {
            _tween.begin = _position;
            _tween.end = -widget.width;

            if (_animationController.isCompleted && _position != _tween.end) {
              _animationController.reset();
            }

            _animationController.duration = const Duration(milliseconds: 250);
            _animationController
                .forward()
                .then<dynamic>((dynamic value) => _updateNextView());

            _updateCurrentViewVisibleDates(isNextView: true);
          } else if (-dragEndDetails.velocity.pixelsPerSecond.dx >
              widget.width) {
            if (!DateRangePickerHelper.canMoveToNextViewRtl(
                pickerView,
                DateRangePickerHelper.getNumberOfWeeksInView(
                    widget.picker.monthViewSettings, widget.picker.isHijri),
                widget.picker.minDate,
                widget.picker.maxDate,
                _currentViewVisibleDates,
                widget.isRtl,
                widget.picker.enableMultiView,
                widget.picker.isHijri)) {
              _position = 0;
              setState(() {
                /* Completes the swiping and rearrange the children position in
                  the custom scroll view */
              });
              return;
            }

            _tween.begin = _position;
            _tween.end = -widget.width;

            if (_animationController.isCompleted && _position != _tween.end) {
              _animationController.reset();
            }

            _animationController.duration = const Duration(milliseconds: 250);
            _animationController
                .fling(
                    velocity: 5.0, animationBehavior: AnimationBehavior.normal)
                .then<dynamic>((dynamic value) => _updateNextView());

            _updateCurrentViewVisibleDates(isNextView: true);
          } else if (_position >= widget.width / 2) {
            _tween.begin = _position;
            _tween.end = widget.width;

            if (_animationController.isCompleted || _position != _tween.end) {
              _animationController.reset();
            }

            _animationController.duration = const Duration(milliseconds: 250);
            _animationController
                .forward()
                .then<dynamic>((dynamic value) => _updatePreviousView());

            _updateCurrentViewVisibleDates();
          } else if (dragEndDetails.velocity.pixelsPerSecond.dx >
              widget.width) {
            if (!DateRangePickerHelper.canMoveToPreviousViewRtl(
                pickerView,
                DateRangePickerHelper.getNumberOfWeeksInView(
                    widget.picker.monthViewSettings, widget.picker.isHijri),
                widget.picker.minDate,
                widget.picker.maxDate,
                _currentViewVisibleDates,
                widget.isRtl,
                widget.picker.enableMultiView,
                widget.picker.isHijri)) {
              _position = 0;
              setState(() {
                /* Completes the swiping and rearrange the children position in
                  the custom scroll view */
              });
              return;
            }

            _tween.begin = _position;
            _tween.end = widget.width;

            if (_animationController.isCompleted && _position != _tween.end) {
              _animationController.reset();
            }

            _animationController.duration = const Duration(milliseconds: 250);
            _animationController
                .fling(
                    velocity: 5.0, animationBehavior: AnimationBehavior.normal)
                .then<dynamic>((dynamic value) => _updatePreviousView());

            _updateCurrentViewVisibleDates();
          } else if (_position.abs() <= widget.width / 2) {
            _tween.begin = _position;
            _tween.end = 0.0;

            if (_animationController.isCompleted && _position != _tween.end) {
              _animationController.reset();
            }

            _triggerSelectableDayPredicates(_currentViewVisibleDates);
            _animationController.duration = const Duration(milliseconds: 250);
            _animationController.forward();
          }
        }
    }
  }

  void _onVerticalStart(DragStartDetails dragStartDetails) {
    switch (widget.picker.navigationDirection) {
      case DateRangePickerNavigationDirection.horizontal:
        break;
      case DateRangePickerNavigationDirection.vertical:
        {
          _scrollStartPosition = dragStartDetails.globalPosition.dy;
          _updateSelection();
        }
        break;
    }
  }

  void _onVerticalUpdate(DragUpdateDetails dragUpdateDetails) {
    final DateRangePickerView pickerView =
        DateRangePickerHelper.getPickerView(widget.controller.view);
    switch (widget.picker.navigationDirection) {
      case DateRangePickerNavigationDirection.horizontal:
        break;
      case DateRangePickerNavigationDirection.vertical:
        {
          final double difference =
              dragUpdateDetails.globalPosition.dy - _scrollStartPosition!;
          if (difference < 0 &&
              !DateRangePickerHelper.canMoveToNextView(
                  pickerView,
                  DateRangePickerHelper.getNumberOfWeeksInView(
                      widget.picker.monthViewSettings, widget.picker.isHijri),
                  widget.picker.maxDate,
                  _currentViewVisibleDates,
                  widget.picker.enableMultiView,
                  widget.picker.isHijri)) {
            return;
          } else if (difference > 0 &&
              !DateRangePickerHelper.canMoveToPreviousView(
                  pickerView,
                  DateRangePickerHelper.getNumberOfWeeksInView(
                      widget.picker.monthViewSettings, widget.picker.isHijri),
                  widget.picker.minDate,
                  _currentViewVisibleDates,
                  widget.picker.enableMultiView,
                  widget.picker.isHijri)) {
            return;
          }

          final bool isNextView = difference < 0;
          _triggerSelectableDayPredicates(_getCurrentVisibleDates(isNextView));

          _position = difference;
          setState(() {
            /* Updates the widget navigated distance and moves the widget
              in the custom scroll view */
          });
        }
    }
  }

  void _onVerticalEnd(DragEndDetails dragEndDetails) {
    final DateRangePickerView pickerView =
        DateRangePickerHelper.getPickerView(widget.controller.view);
    switch (widget.picker.navigationDirection) {
      case DateRangePickerNavigationDirection.horizontal:
        break;
      case DateRangePickerNavigationDirection.vertical:
        {
          _position = _position != 0 ? _position : 0;

          if (-_position >= widget.height / 2) {
            _tween.begin = _position;
            _tween.end = -widget.height;

            if (_animationController.isCompleted || _position != _tween.end) {
              _animationController.reset();
            }

            _animationController.duration = const Duration(milliseconds: 250);
            _animationController
                .forward()
                .then<dynamic>((dynamic value) => _updateNextView());

            _updateCurrentViewVisibleDates(isNextView: true);
          } else if (-dragEndDetails.velocity.pixelsPerSecond.dy >
              widget.height) {
            if (!DateRangePickerHelper.canMoveToNextView(
                pickerView,
                DateRangePickerHelper.getNumberOfWeeksInView(
                    widget.picker.monthViewSettings, widget.picker.isHijri),
                widget.picker.maxDate,
                _currentViewVisibleDates,
                widget.picker.enableMultiView,
                widget.picker.isHijri)) {
              _position = 0;
              setState(() {
                /* Completes the swiping and rearrange the children position in
                  the custom scroll view */
              });
              return;
            }
            _tween.begin = _position;
            _tween.end = -widget.height;

            if (_animationController.isCompleted || _position != _tween.end) {
              _animationController.reset();
            }

            _animationController.duration = const Duration(milliseconds: 250);
            _animationController
                .fling(
                    velocity: 5.0, animationBehavior: AnimationBehavior.normal)
                .then<dynamic>((dynamic value) => _updateNextView());

            _updateCurrentViewVisibleDates(isNextView: true);
          } else if (_position >= widget.height / 2) {
            _tween.begin = _position;
            _tween.end = widget.height;

            if (_animationController.isCompleted || _position != _tween.end) {
              _animationController.reset();
            }

            _animationController.duration = const Duration(milliseconds: 250);
            _animationController
                .forward()
                .then<dynamic>((dynamic value) => _updatePreviousView());

            _updateCurrentViewVisibleDates();
          } else if (dragEndDetails.velocity.pixelsPerSecond.dy >
              widget.height) {
            if (!DateRangePickerHelper.canMoveToPreviousView(
                pickerView,
                DateRangePickerHelper.getNumberOfWeeksInView(
                    widget.picker.monthViewSettings, widget.picker.isHijri),
                widget.picker.minDate,
                _currentViewVisibleDates,
                widget.picker.enableMultiView,
                widget.picker.isHijri)) {
              _position = 0;
              setState(() {
                /* Completes the swiping and rearrange the children position in
                  the custom scroll view */
              });
              return;
            }

            _tween.begin = _position;
            _tween.end = widget.height;

            if (_animationController.isCompleted || _position != _tween.end) {
              _animationController.reset();
            }

            _animationController.duration = const Duration(milliseconds: 250);
            _animationController
                .fling(
                    velocity: 5.0, animationBehavior: AnimationBehavior.normal)
                .then<dynamic>((dynamic value) => _updatePreviousView());

            _updateCurrentViewVisibleDates();
          } else if (_position.abs() <= widget.height / 2) {
            _tween.begin = _position;
            _tween.end = 0.0;

            if (_animationController.isCompleted || _position != _tween.end) {
              _animationController.reset();
            }

            _triggerSelectableDayPredicates(_currentViewVisibleDates);
            _animationController.duration = const Duration(milliseconds: 250);
            _animationController.forward();
          }
        }
    }
  }

  void _triggerSelectableDayPredicates(List<dynamic> visibleDates) {
    if ((widget.picker.selectableDayPredicate == null) ||
        (_disabledDates != null &&
            _disabledDates!.isNotEmpty &&
            _disabledDates?.keys != null &&
            _disabledDates!.keys.isNotEmpty &&
            _disabledDates!.keys.first == visibleDates)) {
      return;
    }

    final DateRangePickerView view =
        DateRangePickerHelper.getPickerView(widget.controller.view);
    final int viewCount = _isMultiViewEnabled(widget.picker) ? 2 : 1;

    _disabledDates ??= <List<dynamic>, List<dynamic>>{};
    _disabledDates!.clear();

    final List<dynamic> disabledDateCollection = <dynamic>[];

    switch (view) {
      case DateRangePickerView.month:
        final int datesCount =
            visibleDates.length ~/ (widget.picker.enableMultiView ? 2 : 1);
        for (int i = 0; i < viewCount; i++) {
          int midDateIndex = datesCount ~/ 2;
          if (i == 1) {
            midDateIndex = datesCount + (datesCount ~/ 2);
          }
          for (int j = i * datesCount; j < ((i + 1) * datesCount); j++) {
            final int numberOfWeeksInView =
                DateRangePickerHelper.getNumberOfWeeksInView(
                    widget.picker.monthViewSettings, widget.picker.isHijri);
            final bool showLeadingTrailingDates =
                DateRangePickerHelper.canShowLeadingAndTrailingDates(
                    widget.picker.monthViewSettings, widget.picker.isHijri);
            final bool isCurrentMonthDate =
                DateRangePickerHelper.isDateAsCurrentMonthDate(
                    visibleDates[midDateIndex],
                    numberOfWeeksInView,
                    showLeadingTrailingDates,
                    visibleDates[j],
                    widget.picker.isHijri);
            if (isCurrentMonthDate) {
              final bool isSelectedDayPredicate =
                  widget.picker.selectableDayPredicate(visibleDates[j]) as bool;
              if (!isSelectedDayPredicate) {
                disabledDateCollection.add(visibleDates[j]);
              }
            }
          }
        }
        break;
      case DateRangePickerView.year:
      case DateRangePickerView.century:
      case DateRangePickerView.decade:
        if (widget.picker.allowViewNavigation) {
          return;
        }
        for (int i = 0; i < visibleDates.length; i++) {
          final bool isSelectedDayPredicate =
              widget.picker.selectableDayPredicate(visibleDates[i]) as bool;
          if (!isSelectedDayPredicate) {
            disabledDateCollection.add(visibleDates[i]);
          }
        }
    }

    _disabledDates![visibleDates] = disabledDateCollection;
  }
}

@immutable
class _PickerView extends StatefulWidget {
  const _PickerView(
    this.picker,
    this.controller,
    this.visibleDates,
    this.enableMultiView,
    this.width,
    this.height,
    this.datePickerTheme,
    this.focusNode,
    this.textScaleFactor,
    this.disableDatePredicates, {
    Key? key,
    required this.getPickerStateDetails,
    required this.updatePickerStateDetails,
    this.onTapCallback,
    this.onLongPressCallback,
    this.isRtl = false,
    this.dragEndCallback,
  }) : super(key: key);

  final List<dynamic> visibleDates;

  final _SfDateRangePicker picker;

  final bool enableMultiView;

  final dynamic controller;

  final double width;

  final double height;

  final UpdatePickerState getPickerStateDetails;

  final UpdatePickerState updatePickerStateDetails;

  final SfDateRangePickerThemeData datePickerTheme;

  final bool isRtl;

  final FocusNode? focusNode;

  final double textScaleFactor;

  final List<dynamic>? disableDatePredicates;

  final Function(PickerDateRange?, bool)? onTapCallback;

  final Function(PickerDateRange?)? onLongPressCallback;

  final DateRangePickerSelectionChangedCallback? dragEndCallback;

  @override
  _PickerViewState createState() => _PickerViewState();
}

class _PickerViewState extends State<_PickerView>
    with TickerProviderStateMixin {
  final PickerStateArgs _pickerStateDetails = PickerStateArgs();

  MonthView? _monthView;

  YearView? _yearView;
  final ValueNotifier<HoveringDetails?> _mouseHoverPosition =
      ValueNotifier<HoveringDetails?>(null);

  dynamic _previousSelectedDate;

  bool _isDragStart = false;

  bool _isMobilePlatform = true;

  dynamic _lastSelectedDate;

  late LongPressDownDetails _longPressDownDetails;

  @override
  void dispose() {
    _mouseHoverPosition.value = null;
    _mouseHoverPosition.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final SfLocalizations localizations = SfLocalizations.of(context);
    _isMobilePlatform =
        DateRangePickerHelper.isMobileLayout(Theme.of(context).platform);
    widget.getPickerStateDetails(_pickerStateDetails);
    final DateRangePickerView pickerView =
        DateRangePickerHelper.getPickerView(widget.controller.view);

    switch (pickerView) {
      case DateRangePickerView.month:
        {
          return GestureDetector(
            onTapUp: (TapUpDetails details) {
              final PickerDateRange? date = _onTapCallback(details);
              if (date == null) {
                _updateTapCallback(details, true);
              } else {
                _updateTapCallback(details, false);
              }
              widget.onTapCallback?.call(_onTapCallback(details), date != null);
            },
            onLongPress: () {
              widget.onLongPressCallback
                  ?.call(_onTapCallback(_longPressDownDetails));
              _updateTapCallback(_longPressDownDetails, false);
            },
            onLongPressDown: (LongPressDownDetails details) {
              _longPressDownDetails = details;
            },
            onDoubleTap: () {
              widget.onLongPressCallback
                  ?.call(_onTapCallback(_longPressDownDetails));
              _updateTapCallback(_longPressDownDetails, false);
            },
            onHorizontalDragStart: _getDragStartCallback(),
            onVerticalDragStart: _getDragStartCallback(),
            onHorizontalDragUpdate: _getDragUpdateCallback(),
            onVerticalDragUpdate: _getDragUpdateCallback(),
            onVerticalDragEnd: (details) => _getDragEndCallback(details),
            onHorizontalDragEnd: (details) => _getDragEndCallback(details),
            child: MouseRegion(
                onEnter: _pointerEnterEvent,
                onHover: _pointerHoverEvent,
                onExit: _pointerExitEvent,
                child: SizedBox(
                  width: widget.width,
                  height: widget.height,
                  child: _addMonthView(
                      locale, widget.datePickerTheme, localizations),
                )),
          );
        }
      case DateRangePickerView.year:
      case DateRangePickerView.decade:
      case DateRangePickerView.century:
        {
          return GestureDetector(
            onTapUp: (TapUpDetails details) {
              final PickerDateRange? date = _onTapCallback(details);
              if (date != null) {
                widget.onTapCallback?.call(_onTapCallback(details), true);
              } else {
                _updateTapCallback(details, true);
              }
            },
            onLongPress: () {
              _updateTapCallback(_longPressDownDetails, false);
              widget.onLongPressCallback
                  ?.call(_onTapCallback(_longPressDownDetails));
            },
            onLongPressDown: (LongPressDownDetails details) {
              _longPressDownDetails = details;
            },
            onHorizontalDragStart: _getDragStartCallback(),
            onVerticalDragStart: _getDragStartCallback(),
            onHorizontalDragUpdate: _getDragUpdateCallback(),
            onVerticalDragUpdate: _getDragUpdateCallback(),
            child: MouseRegion(
              onEnter: _pointerEnterEvent,
              onHover: _pointerHoverEvent,
              onExit: _pointerExitEvent,
              child: _addYearView(locale, localizations),
            ),
          );
        }
    }
  }

  void _drawSelection(dynamic selectedDate, bool isSelect) {
    switch (widget.picker.selectionMode) {
      case DateRangePickerSelectionMode.single:
        _drawSingleSelectionForMonth(selectedDate);
        break;
      case DateRangePickerSelectionMode.multiple:
        _drawMultipleSelectionForMonth(selectedDate);
        break;
      case DateRangePickerSelectionMode.range:
        _drawRangeSelectionForMonth(selectedDate);
        break;
      case DateRangePickerSelectionMode.multiRange:
        if (isSelect) {
          selectRange(selectedDate);
        } else {
          removeRange(selectedDate);
        }

        break;
      case DateRangePickerSelectionMode.extendableRange:
        _drawExtendableRangeSelection(selectedDate);
    }
  }

  Widget _addMonthView(
      Locale locale,
      SfDateRangePickerThemeData datePickerTheme,
      SfLocalizations localizations) {
    final DateRangePickerView pickerView =
        DateRangePickerHelper.getPickerView(widget.controller.view);
    double viewHeaderHeight =
        widget.picker.monthViewSettings.viewHeaderHeight as double;
    if (pickerView == DateRangePickerView.month &&
        widget.picker.navigationDirection ==
            DateRangePickerNavigationDirection.vertical) {
      viewHeaderHeight = 0;
    }

    final double height = widget.height - viewHeaderHeight;
    _monthView = _getMonthView(locale, widget.datePickerTheme, localizations,
        widget.width, height, pickerView);
    return Stack(
      children: <Widget>[
        _getViewHeader(viewHeaderHeight, locale, datePickerTheme),
        Positioned(
          left: 0,
          top: viewHeaderHeight,
          right: 0,
          height: height,
          child: RepaintBoundary(
            child: _monthView,
          ),
        ),
      ],
    );
  }

  MonthView _getMonthView(
      Locale locale,
      SfDateRangePickerThemeData datePickerTheme,
      SfLocalizations localizations,
      double width,
      double height,
      DateRangePickerView pickerView) {
    final int rowCount = DateRangePickerHelper.getNumberOfWeeksInView(
        widget.picker.monthViewSettings, widget.picker.isHijri);
    return MonthView(
      widget.visibleDates,
      rowCount,
      widget.picker.monthCellStyle,
      widget.picker.selectionTextStyle,
      widget.picker.rangeTextStyle,
      widget.picker.selectionColor,
      widget.picker.startRangeSelectionColor,
      widget.picker.endRangeSelectionColor,
      widget.picker.rangeSelectionColor,
      widget.datePickerTheme,
      widget.isRtl,
      widget.picker.todayHighlightColor,
      widget.picker.minDate,
      widget.picker.maxDate,
      widget.picker.enablePastDates,
      DateRangePickerHelper.canShowLeadingAndTrailingDates(
          widget.picker.monthViewSettings, widget.picker.isHijri),
      widget.picker.monthViewSettings.blackoutDates,
      widget.picker.monthViewSettings.specialDates,
      widget.picker.monthViewSettings.weekendDays,
      widget.picker.selectionShape,
      widget.picker.selectionRadius,
      _mouseHoverPosition,
      widget.enableMultiView,
      widget.picker.viewSpacing,
      ValueNotifier<bool>(false),
      widget.textScaleFactor,
      widget.picker.selectionMode,
      widget.picker.isHijri,
      localizations,
      widget.picker.navigationDirection,
      width,
      height,
      widget.getPickerStateDetails,
      widget.picker.cellBuilder,
      widget.picker.monthViewSettings.showWeekNumber,
      widget.picker.monthViewSettings.weekNumberStyle,
      _isMobilePlatform,
      widget.disableDatePredicates,
      widget.picker.extendableRangeSelectionDirection,
    );
  }

  Widget _getViewHeader(double viewHeaderHeight, Locale locale,
      SfDateRangePickerThemeData datePickerTheme) {
    if (viewHeaderHeight == 0) {
      return Positioned(
          left: 0,
          top: 0,
          right: 0,
          height: viewHeaderHeight,
          child: Container());
    }

    final Color todayTextColor =
        widget.picker.monthCellStyle.todayTextStyle != null &&
                widget.picker.monthCellStyle.todayTextStyle!.color != null
            ? widget.picker.monthCellStyle.todayTextStyle!.color! as Color
            : (widget.picker.todayHighlightColor != null &&
                    widget.picker.todayHighlightColor != Colors.transparent
                ? widget.picker.todayHighlightColor!
                : widget.datePickerTheme.todayHighlightColor!);

    return Positioned(
      left: 0,
      top: 0,
      right: 0,
      height: viewHeaderHeight,
      child: Container(
        color:
            widget.picker.monthViewSettings.viewHeaderStyle.backgroundColor ??
                widget.datePickerTheme.viewHeaderBackgroundColor,
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _PickerViewHeaderPainter(
                widget.visibleDates,
                widget.picker.navigationMode,
                widget.picker.monthViewSettings.viewHeaderStyle,
                viewHeaderHeight,
                widget.picker.monthViewSettings,
                widget.datePickerTheme,
                locale,
                widget.isRtl,
                widget.picker.monthCellStyle,
                widget.enableMultiView,
                widget.picker.viewSpacing,
                todayTextColor,
                widget.textScaleFactor,
                widget.picker.isHijri,
                widget.picker.navigationDirection,
                null,
                widget.picker.monthViewSettings.showWeekNumber,
                _isMobilePlatform),
          ),
        ),
      ),
    );
  }

  PickerDateRange? _onTapCallback(dynamic details) {
    widget.getPickerStateDetails(_pickerStateDetails);
    final DateRangePickerView pickerView =
        DateRangePickerHelper.getPickerView(widget.controller.view);
    if (pickerView == DateRangePickerView.month) {
      final int index =
          _getSelectedIndex(details.localPosition.dx, details.localPosition.dy);
      if (index == -1) {
        return null;
      }

      final DateTime selectedDate = widget.visibleDates[index];
      if (_pickerStateDetails.selectedRanges == null) {
        return null;
      }
      for (int i = 0; i < _pickerStateDetails.selectedRanges!.length; i++) {
        final PickerDateRange range =
            _pickerStateDetails.selectedRanges![i] as PickerDateRange;
        if (range.endDate != null) {
          if ((selectedDate.isBefore(range.endDate!) &&
                  selectedDate.isAfter(range.startDate!)) ||
              range.startDate == selectedDate ||
              range.endDate == selectedDate) {
            return range;
          }
        } else {
          if (selectedDate == range.startDate) {
            return range;
          }
        }
      }
      return null;
    }
    return null;
  }

  void _updateTapCallback(dynamic details, bool isSelect) {
    final DateRangePickerView pickerView =
        DateRangePickerHelper.getPickerView(widget.controller.view);
    switch (pickerView) {
      case DateRangePickerView.month:
        {
          double viewHeaderHeight =
              widget.picker.monthViewSettings.viewHeaderHeight as double;
          if (widget.picker.navigationDirection ==
              DateRangePickerNavigationDirection.vertical) {
            viewHeaderHeight = 0;
          }

          final double weekNumberPanelWidth =
              DateRangePickerHelper.getWeekNumberPanelWidth(
                  widget.picker.monthViewSettings.showWeekNumber,
                  widget.width,
                  _isMobilePlatform);

          if (details.localPosition.dy < viewHeaderHeight ||
              ((!widget.isRtl &&
                      details.localPosition.dx < weekNumberPanelWidth) ||
                  (widget.isRtl &&
                      details.localPosition.dx >
                          widget.width - weekNumberPanelWidth))) {
            return;
          }

          if (details.localPosition.dy > viewHeaderHeight) {
            _handleTouch(
                Offset(details.localPosition.dx,
                    details.localPosition.dy - viewHeaderHeight),
                details,
                isSelect);
          }
        }
        break;
      case DateRangePickerView.year:
      case DateRangePickerView.decade:
      case DateRangePickerView.century:
        {
          _handleYearPanelSelection(
              Offset(details.localPosition.dx, details.localPosition.dy));
        }
    }

    if (widget.focusNode != null && !widget.focusNode!.hasFocus) {
      widget.focusNode!.requestFocus();
    }
  }

  void _updateMouseHover(Offset globalPosition) {
    if (_isMobilePlatform) {
      return;
    }

    widget.getPickerStateDetails(_pickerStateDetails);
    final DateRangePickerView pickerView =
        DateRangePickerHelper.getPickerView(widget.controller.view);
    final RenderObject renderObject = context.findRenderObject()!;
    final RenderBox? box = renderObject is RenderBox ? renderObject : null;
    final Offset localPosition = box!.globalToLocal(globalPosition);
    final double viewHeaderHeight = pickerView == DateRangePickerView.month &&
            widget.picker.navigationDirection ==
                DateRangePickerNavigationDirection.horizontal
        ? widget.picker.monthViewSettings.viewHeaderHeight as double
        : 0;
    final double xPosition = localPosition.dx;
    final double yPosition = localPosition.dy - viewHeaderHeight;

    if (localPosition.dy < viewHeaderHeight) {
      _mouseHoverPosition.value = null;
      return;
    }

    dynamic range;
    if (widget.picker.selectionMode ==
            DateRangePickerSelectionMode.extendableRange &&
        _pickerStateDetails.selectedRange != null &&
        widget.picker.navigationMode != DateRangePickerNavigationMode.scroll) {
      int index;
      dynamic date;
      final DateRangePickerView pickerView =
          DateRangePickerHelper.getPickerView(widget.controller.view);
      switch (pickerView) {
        case DateRangePickerView.month:
          {
            index = _getSelectedIndex(xPosition, yPosition);
            if (index == -1) {
              return;
            }

            date = widget.visibleDates[index];

            if (!DateRangePickerHelper.isEnabledDate(
                widget.picker.minDate,
                widget.picker.maxDate,
                widget.picker.enablePastDates,
                date,
                widget.picker.isHijri)) {
              _mouseHoverPosition.value = null;
              return;
            }

            final int currentMonthIndex = _getCurrentDateIndex(index);
            if (!DateRangePickerHelper.isDateAsCurrentMonthDate(
                widget.visibleDates[currentMonthIndex],
                DateRangePickerHelper.getNumberOfWeeksInView(
                    widget.picker.monthViewSettings, widget.picker.isHijri),
                DateRangePickerHelper.canShowLeadingAndTrailingDates(
                    widget.picker.monthViewSettings, widget.picker.isHijri),
                date,
                widget.picker.isHijri)) {
              _mouseHoverPosition.value = null;
              return;
            }
          }
          break;
        case DateRangePickerView.year:
        case DateRangePickerView.decade:
        case DateRangePickerView.century:
          {
            if (widget.picker.allowViewNavigation) {
              _mouseHoverPosition.value =
                  HoveringDetails(range, Offset(xPosition, yPosition));
              return;
            }

            index = _getYearViewIndex(xPosition, yPosition);
            final int viewCount = widget.enableMultiView ? 2 : 1;
            if (index == -1 || index >= 12 * viewCount) {
              return;
            }

            date = widget.visibleDates[index];
            if (!DateRangePickerHelper.isBetweenMinMaxDateCell(
                date,
                widget.picker.minDate,
                widget.picker.maxDate,
                widget.picker.enablePastDates,
                widget.controller.view,
                widget.picker.isHijri)) {
              _mouseHoverPosition.value = null;
              return;
            }
          }
      }

      if (DateRangePickerHelper.isDisableDirectionDate(
          _pickerStateDetails.selectedRange,
          date,
          widget.picker.extendableRangeSelectionDirection,
          pickerView,
          widget.picker.isHijri)) {
        _mouseHoverPosition.value = null;
        return;
      }

      dynamic rangeStartDate = _pickerStateDetails.selectedRange.startDate;
      dynamic rangeEndDate = _pickerStateDetails.selectedRange.endDate ?? date;
      if (_pickerStateDetails.selectedRange.startDate != null &&
          _pickerStateDetails.selectedRange.endDate != null &&
          isSameOrAfterDate(rangeStartDate, date) &&
          isSameOrBeforeDate(rangeEndDate, date)) {
        rangeStartDate = null;
        rangeEndDate = null;
      } else if (date.isAfter(rangeEndDate) == true) {
        rangeStartDate = rangeEndDate;
        rangeEndDate = date;
      } else if (date.isBefore(rangeStartDate) == true) {
        rangeEndDate = rangeStartDate;
        rangeStartDate = date;
      }

      range = widget.picker.isHijri
          ? HijriDateRange(rangeStartDate, rangeEndDate)
          : PickerDateRange(rangeStartDate, rangeEndDate);
    }

    _mouseHoverPosition.value =
        HoveringDetails(range, Offset(xPosition, yPosition));
  }

  void _pointerEnterEvent(PointerEnterEvent event) {
    _updateMouseHover(event.position);
  }

  void _pointerHoverEvent(PointerHoverEvent event) {
    _updateMouseHover(event.position);
  }

  void _pointerExitEvent(PointerExitEvent event) {
    _mouseHoverPosition.value = null;
  }

  Widget _addYearView(Locale locale, SfLocalizations localizations) {
    _yearView = _getYearView(locale, localizations);
    return RepaintBoundary(
      child: _yearView,
    );
  }

  YearView _getYearView(Locale locale, SfLocalizations localizations) {
    return YearView(
        widget.visibleDates,
        widget.picker.yearCellStyle,
        widget.picker.minDate,
        widget.picker.maxDate,
        widget.picker.enablePastDates,
        widget.picker.todayHighlightColor,
        widget.picker.selectionShape,
        widget.picker.monthFormat,
        widget.isRtl,
        widget.datePickerTheme,
        locale,
        _mouseHoverPosition,
        widget.enableMultiView,
        widget.picker.viewSpacing,
        widget.picker.selectionTextStyle,
        widget.picker.rangeTextStyle,
        widget.picker.selectionColor,
        widget.picker.startRangeSelectionColor,
        widget.picker.endRangeSelectionColor,
        widget.picker.rangeSelectionColor,
        widget.picker.selectionMode,
        widget.picker.selectionRadius,
        ValueNotifier<bool>(false),
        widget.textScaleFactor,
        widget.picker.allowViewNavigation,
        widget.picker.cellBuilder,
        widget.getPickerStateDetails,
        DateRangePickerHelper.getPickerView(widget.controller.view),
        widget.picker.isHijri,
        localizations,
        widget.picker.navigationDirection,
        widget.width,
        widget.height,
        widget.disableDatePredicates,
        widget.picker.extendableRangeSelectionDirection);
  }

  GestureDragStartCallback? _getDragStartCallback() {
    final DateRangePickerView pickerView =
        DateRangePickerHelper.getPickerView(widget.controller.view);

    if ((pickerView != DateRangePickerView.month &&
            widget.picker.allowViewNavigation) ||
        !_isSwipeInteractionEnabled(
            widget.picker.monthViewSettings.enableSwipeSelection,
            widget.picker.navigationMode)) {
      return null;
    }

    if (widget.picker.selectionMode != DateRangePickerSelectionMode.range &&
        widget.picker.selectionMode !=
            DateRangePickerSelectionMode.multiRange &&
        widget.picker.selectionMode !=
            DateRangePickerSelectionMode.extendableRange) {
      return null;
    }

    switch (pickerView) {
      case DateRangePickerView.month:
        {
          return _dragStart;
        }
      case DateRangePickerView.year:
      case DateRangePickerView.decade:
      case DateRangePickerView.century:
        return _dragStartOnYear;
    }
  }

  void _getDragEndCallback(DragEndDetails args) {
    widget.dragEndCallback?.call(DateRangePickerSelectionChangedArgs(
        _pickerStateDetails.selectedRanges));
  }

  GestureDragUpdateCallback? _getDragUpdateCallback() {
    final DateRangePickerView pickerView =
        DateRangePickerHelper.getPickerView(widget.controller.view);

    if ((pickerView != DateRangePickerView.month &&
            widget.picker.allowViewNavigation) ||
        !_isSwipeInteractionEnabled(
            widget.picker.monthViewSettings.enableSwipeSelection,
            widget.picker.navigationMode)) {
      return null;
    }

    if (widget.picker.selectionMode != DateRangePickerSelectionMode.range &&
        widget.picker.selectionMode !=
            DateRangePickerSelectionMode.multiRange &&
        widget.picker.selectionMode !=
            DateRangePickerSelectionMode.extendableRange) {
      return null;
    }

    switch (pickerView) {
      case DateRangePickerView.month:
        {
          return _dragUpdate;
        }
      case DateRangePickerView.year:
      case DateRangePickerView.decade:
      case DateRangePickerView.century:
        {
          return _dragUpdateOnYear;
        }
    }
  }

  int _getYearViewIndex(double xPosition, double yPosition) {
    int rowIndex, columnIndex;
    int columnCount = YearView.maxColumnCount;
    double width = widget.width;
    double height = widget.height;
    int rowCount = YearView.maxRowCount;
    int index = -1;
    if (widget.enableMultiView) {
      switch (widget.picker.navigationDirection) {
        case DateRangePickerNavigationDirection.horizontal:
          {
            columnCount *= 2;
            width -= widget.picker.viewSpacing;
            if (xPosition > width / 2 &&
                xPosition < (width / 2) + widget.picker.viewSpacing) {
              return index;
            } else if (xPosition > width / 2) {
              xPosition -= widget.picker.viewSpacing;
            }
          }
          break;
        case DateRangePickerNavigationDirection.vertical:
          {
            rowCount *= 2;
            height = (height - widget.picker.viewSpacing) / 2;
            if (yPosition > height &&
                yPosition < height + widget.picker.viewSpacing) {
              return index;
            } else if (yPosition > height) {
              yPosition -= widget.picker.viewSpacing;
            }
          }
      }
    }

    final double cellWidth = width / columnCount;
    final double cellHeight = height / YearView.maxRowCount;
    if (yPosition < 0 || xPosition < 0) {
      return index;
    }

    rowIndex = xPosition ~/ cellWidth;
    if (rowIndex >= columnCount) {
      rowIndex = columnCount - 1;
    } else if (rowIndex < 0) {
      return index;
    }

    columnIndex = yPosition ~/ cellHeight;
    if (columnIndex >= rowCount) {
      columnIndex = rowCount - 1;
    } else if (columnIndex < 0) {
      return index;
    }

    if (widget.isRtl) {
      rowIndex = DateRangePickerHelper.getRtlIndex(columnCount, rowIndex);
      if (widget.enableMultiView &&
          widget.picker.navigationDirection ==
              DateRangePickerNavigationDirection.vertical) {
        if (columnIndex > YearView.maxColumnCount) {
          columnIndex -= YearView.maxColumnCount + 1;
        } else {
          columnIndex += YearView.maxColumnCount + 1;
        }
      }
    }

    const int totalDatesCount = YearView.maxRowCount * YearView.maxColumnCount;
    index = (columnIndex * YearView.maxColumnCount) +
        ((rowIndex ~/ YearView.maxColumnCount) * totalDatesCount) +
        (rowIndex % YearView.maxColumnCount);
    return widget.enableMultiView &&
            DateRangePickerHelper.isLeadingCellDate(
                index,
                (index ~/ totalDatesCount) * totalDatesCount,
                widget.visibleDates,
                widget.controller.view)
        ? -1
        : index;
  }

  int _getSelectedIndex(double xPosition, double yPosition) {
    final double weekNumberPanelWidth =
        DateRangePickerHelper.getWeekNumberPanelWidth(
            widget.picker.monthViewSettings.showWeekNumber,
            widget.width,
            _isMobilePlatform);
    int rowIndex, columnIndex;
    double width = widget.width - weekNumberPanelWidth;
    double height = widget.height;
    int index = -1;
    int totalColumnCount = DateTime.daysPerWeek;
    final int rowCount = DateRangePickerHelper.getNumberOfWeeksInView(
        widget.picker.monthViewSettings, widget.picker.isHijri);
    int totalRowCount = rowCount;
    if (widget.enableMultiView) {
      switch (widget.picker.navigationDirection) {
        case DateRangePickerNavigationDirection.horizontal:
          {
            width = width - widget.picker.viewSpacing - weekNumberPanelWidth;
            totalColumnCount *= 2;
            if (xPosition > width / 2 &&
                xPosition <
                    (width / 2) +
                        widget.picker.viewSpacing +
                        weekNumberPanelWidth) {
              return index;
            } else if (xPosition > width / 2) {
              xPosition =
                  xPosition - widget.picker.viewSpacing - weekNumberPanelWidth;
            }
          }
          break;
        case DateRangePickerNavigationDirection.vertical:
          {
            height = (height - widget.picker.viewSpacing) / 2;
            totalRowCount *= 2;
            if (yPosition > height &&
                yPosition < height + widget.picker.viewSpacing) {
              return index;
            } else if (yPosition > height) {
              yPosition -= widget.picker.viewSpacing;
            }
          }
      }
    }

    if (yPosition < 0 ||
        (!widget.isRtl && xPosition < weekNumberPanelWidth) ||
        (widget.isRtl && xPosition > widget.width - weekNumberPanelWidth)) {
      return index;
    }

    if (!widget.isRtl) {
      xPosition -= weekNumberPanelWidth;
    }

    final DateRangePickerView pickerView =
        DateRangePickerHelper.getPickerView(widget.controller.view);

    double viewHeaderHeight =
        widget.picker.monthViewSettings.viewHeaderHeight as double;
    if (pickerView == DateRangePickerView.month &&
        widget.picker.navigationDirection ==
            DateRangePickerNavigationDirection.vertical) {
      viewHeaderHeight = 0;
    }

    final double cellWidth = width / totalColumnCount;
    final double cellHeight = (height - viewHeaderHeight) / rowCount;
    rowIndex = (xPosition / cellWidth).truncate();
    if (rowIndex >= totalColumnCount) {
      rowIndex = totalColumnCount - 1;
    } else if (rowIndex < 0) {
      return index;
    }

    columnIndex = (yPosition / cellHeight).truncate();
    if (columnIndex >= totalRowCount) {
      columnIndex = totalRowCount - 1;
    } else if (columnIndex < 0) {
      return index;
    }

    if (widget.isRtl) {
      rowIndex = DateRangePickerHelper.getRtlIndex(totalColumnCount, rowIndex);
      if (widget.enableMultiView &&
          widget.picker.navigationDirection ==
              DateRangePickerNavigationDirection.vertical) {
        if (columnIndex >= rowCount) {
          columnIndex -= rowCount;
        } else {
          columnIndex += rowCount;
        }
      }
    }

    index = (columnIndex * DateTime.daysPerWeek) +
        ((rowIndex ~/ DateTime.daysPerWeek) *
            (totalRowCount * DateTime.daysPerWeek)) +
        (rowIndex % DateTime.daysPerWeek);
    return index;
  }

  void _dragStart(DragStartDetails details) {
    _isDragStart = false;
    widget.getPickerStateDetails(_pickerStateDetails);
    final double xPosition = details.localPosition.dx;
    final DateRangePickerView pickerView =
        DateRangePickerHelper.getPickerView(widget.controller.view);
    double yPosition = details.localPosition.dy;
    if (pickerView == DateRangePickerView.month &&
        widget.picker.navigationDirection ==
            DateRangePickerNavigationDirection.horizontal) {
      yPosition = details.localPosition.dy -
          widget.picker.monthViewSettings.viewHeaderHeight;
    }

    final int index = _getSelectedIndex(xPosition, yPosition);
    if (index == -1) {
      return;
    }

    final dynamic selectedDate = widget.visibleDates[index];
    if (!DateRangePickerHelper.isEnabledDate(
        widget.picker.minDate,
        widget.picker.maxDate,
        widget.picker.enablePastDates,
        selectedDate,
        widget.picker.isHijri)) {
      return;
    }

    final int currentMonthIndex = _getCurrentDateIndex(index);
    if (!DateRangePickerHelper.isDateAsCurrentMonthDate(
        widget.visibleDates[currentMonthIndex],
        DateRangePickerHelper.getNumberOfWeeksInView(
            widget.picker.monthViewSettings, widget.picker.isHijri),
        DateRangePickerHelper.canShowLeadingAndTrailingDates(
            widget.picker.monthViewSettings, widget.picker.isHijri),
        selectedDate,
        widget.picker.isHijri)) {
      return;
    }

    if (DateRangePickerHelper.isDateWithInVisibleDates(widget.visibleDates,
            widget.picker.monthViewSettings.blackoutDates, selectedDate) ||
        DateRangePickerHelper.isDateWithInVisibleDates(
            widget.visibleDates, widget.disableDatePredicates, selectedDate)) {
      return;
    }

    if (widget.picker.selectionMode ==
            DateRangePickerSelectionMode.extendableRange &&
        _pickerStateDetails.selectedRange != null &&
        DateRangePickerHelper.isDisableDirectionDate(
            _pickerStateDetails.selectedRange,
            selectedDate,
            widget.picker.extendableRangeSelectionDirection,
            pickerView,
            widget.picker.isHijri)) {
      return;
    }

    _isDragStart = true;
    _updateSelectedRangesOnDragStart(_monthView, selectedDate);

    _previousSelectedDate = selectedDate;

    widget.updatePickerStateDetails(_pickerStateDetails);
    _monthView!.selectionNotifier.value = !_monthView!.selectionNotifier.value;
  }

  void _dragUpdate(DragUpdateDetails details) {
    widget.getPickerStateDetails(_pickerStateDetails);
    final double xPosition = details.localPosition.dx;
    double yPosition = details.localPosition.dy;
    final DateRangePickerView pickerView =
        DateRangePickerHelper.getPickerView(widget.controller.view);
    if (pickerView == DateRangePickerView.month &&
        widget.picker.navigationDirection ==
            DateRangePickerNavigationDirection.horizontal) {
      yPosition = details.localPosition.dy -
          widget.picker.monthViewSettings.viewHeaderHeight;
    }

    final int index = _getSelectedIndex(xPosition, yPosition);
    if (index == -1) {
      return;
    }

    final dynamic selectedDate = widget.visibleDates[index];
    if (!DateRangePickerHelper.isEnabledDate(
        widget.picker.minDate,
        widget.picker.maxDate,
        widget.picker.enablePastDates,
        selectedDate,
        widget.picker.isHijri)) {
      return;
    }

    final int currentMonthIndex = _getCurrentDateIndex(index);
    if (!DateRangePickerHelper.isDateAsCurrentMonthDate(
        widget.visibleDates[currentMonthIndex],
        DateRangePickerHelper.getNumberOfWeeksInView(
            widget.picker.monthViewSettings, widget.picker.isHijri),
        DateRangePickerHelper.canShowLeadingAndTrailingDates(
            widget.picker.monthViewSettings, widget.picker.isHijri),
        selectedDate,
        widget.picker.isHijri)) {
      return;
    }

    if (DateRangePickerHelper.isDateWithInVisibleDates(widget.visibleDates,
            widget.picker.monthViewSettings.blackoutDates, selectedDate) ||
        DateRangePickerHelper.isDateWithInVisibleDates(
            widget.visibleDates, widget.disableDatePredicates, selectedDate)) {
      return;
    }

    if (widget.picker.selectionMode ==
            DateRangePickerSelectionMode.extendableRange &&
        _pickerStateDetails.selectedRange != null &&
        DateRangePickerHelper.isDisableDirectionDate(
            _pickerStateDetails.selectedRange,
            selectedDate,
            widget.picker.extendableRangeSelectionDirection,
            pickerView,
            widget.picker.isHijri)) {
      return;
    }

    _updateSelectedRangesOnDragUpdateMonth(selectedDate);

    _previousSelectedDate = selectedDate;

    _isDragStart = true;
    widget.updatePickerStateDetails(_pickerStateDetails);
    _monthView!.selectionNotifier.value = !_monthView!.selectionNotifier.value;
  }

  void _updateSelectedRangesOnDragStart(dynamic view, dynamic selectedDate) {
    switch (widget.picker.selectionMode) {
      case DateRangePickerSelectionMode.single:
      case DateRangePickerSelectionMode.multiple:
        break;
      case DateRangePickerSelectionMode.range:
        {
          _pickerStateDetails.selectedRange = widget.picker.isHijri
              ? HijriDateRange(selectedDate, null)
              : PickerDateRange(selectedDate, null);
        }
        break;
      case DateRangePickerSelectionMode.multiRange:
        {
          _pickerStateDetails.selectedRanges ??= <dynamic>[];
          _pickerStateDetails.selectedRanges!.add(widget.picker.isHijri
              ? HijriDateRange(selectedDate, null)
              : PickerDateRange(selectedDate, null));
          _removeInterceptRanges(
              _pickerStateDetails.selectedRanges,
              _pickerStateDetails.selectedRanges![
                  _pickerStateDetails.selectedRanges!.length - 1]);
        }
        break;
      case DateRangePickerSelectionMode.extendableRange:
        _drawExtendableRangeSelection(selectedDate);
    }
  }

  void _updateSelectedRangesOnDragUpdateMonth(dynamic selectedDate) {
    switch (widget.picker.selectionMode) {
      case DateRangePickerSelectionMode.single:
      case DateRangePickerSelectionMode.multiple:
        break;
      case DateRangePickerSelectionMode.range:
        {
          if (!_isDragStart) {
            _pickerStateDetails.selectedRange = widget.picker.isHijri
                ? HijriDateRange(selectedDate, null)
                : PickerDateRange(selectedDate, null);
          } else {
            if (_pickerStateDetails.selectedRange != null &&
                _pickerStateDetails.selectedRange.startDate != null) {
              final dynamic updatedRange = _getSelectedRangeOnDragUpdate(
                  _pickerStateDetails.selectedRange, selectedDate);
              if (DateRangePickerHelper.isRangeEquals(
                  _pickerStateDetails.selectedRange, updatedRange)) {
                return;
              }

              _pickerStateDetails.selectedRange = updatedRange;
            } else {
              _pickerStateDetails.selectedRange = widget.picker.isHijri
                  ? HijriDateRange(selectedDate, null)
                  : PickerDateRange(selectedDate, null);
            }
          }
        }
        break;
      case DateRangePickerSelectionMode.multiRange:
        {
          _pickerStateDetails.selectedRanges ??= <dynamic>[];
          final int count = _pickerStateDetails.selectedRanges!.length;
          dynamic lastRange;
          if (count > 0) {
            lastRange = _pickerStateDetails.selectedRanges![count - 1];
          }

          if (!_isDragStart) {
            _pickerStateDetails.selectedRanges!.add(widget.picker.isHijri
                ? HijriDateRange(selectedDate, null)
                : PickerDateRange(selectedDate, null));
          } else {
            if (lastRange != null && lastRange.startDate != null) {
              final dynamic updatedRange =
                  _getSelectedRangeOnDragUpdate(lastRange, selectedDate);
              if (DateRangePickerHelper.isRangeEquals(
                  lastRange, updatedRange)) {
                return;
              }

              _pickerStateDetails.selectedRanges![count - 1] = updatedRange;
            } else {
              _pickerStateDetails.selectedRanges!.add(widget.picker.isHijri
                  ? HijriDateRange(selectedDate, null)
                  : PickerDateRange(selectedDate, null));
            }
          }

          _removeInterceptRanges(
              _pickerStateDetails.selectedRanges,
              _pickerStateDetails.selectedRanges![
                  _pickerStateDetails.selectedRanges!.length - 1]);
        }
        break;
      case DateRangePickerSelectionMode.extendableRange:
        _drawExtendableRangeSelection(selectedDate);
    }
  }

  dynamic _getSelectedRangeOnDragUpdate(
      dynamic previousRange, dynamic selectedDate) {
    final dynamic previousRangeStartDate = previousRange.startDate;
    final dynamic previousRangeEndDate =
        previousRange.endDate ?? previousRange.startDate;
    dynamic rangeStartDate = previousRangeStartDate;
    dynamic rangeEndDate = selectedDate;
    if (isSameDate(previousRangeStartDate, _previousSelectedDate)) {
      if (isSameOrBeforeDate(previousRangeEndDate, rangeEndDate)) {
        rangeStartDate = selectedDate;
        rangeEndDate = previousRangeEndDate;
      } else {
        rangeStartDate = previousRangeEndDate;
        rangeEndDate = selectedDate;
      }
    } else if (isSameDate(previousRangeEndDate, _previousSelectedDate)) {
      if (isSameOrAfterDate(previousRangeStartDate, rangeEndDate)) {
        rangeStartDate = previousRangeStartDate;
        rangeEndDate = selectedDate;
      } else {
        rangeStartDate = selectedDate;
        rangeEndDate = previousRangeStartDate;
      }
    }

    if (widget.picker.isHijri) {
      return HijriDateRange(rangeStartDate, rangeEndDate);
    }

    return PickerDateRange(rangeStartDate, rangeEndDate);
  }

  dynamic _getSelectedRangeOnDragUpdateYear(
      dynamic previousRange, dynamic selectedDate) {
    final dynamic previousRangeStartDate = previousRange.startDate;
    final dynamic previousRangeEndDate =
        previousRange.endDate ?? previousRange.startDate;
    dynamic rangeStartDate = previousRangeStartDate;
    dynamic rangeEndDate = selectedDate;
    if (DateRangePickerHelper.isSameCellDates(previousRangeStartDate,
        _previousSelectedDate, widget.controller.view)) {
      if (_isSameOrBeforeDateCell(previousRangeEndDate, rangeEndDate)) {
        rangeStartDate = selectedDate;
        rangeEndDate = previousRangeEndDate;
      } else {
        rangeStartDate = previousRangeEndDate;
        rangeEndDate = selectedDate;
      }
    } else if (DateRangePickerHelper.isSameCellDates(
        previousRangeEndDate, _previousSelectedDate, widget.controller.view)) {
      if (_isSameOrAfterDateCell(previousRangeStartDate, rangeEndDate)) {
        rangeStartDate = previousRangeStartDate;
        rangeEndDate = selectedDate;
      } else {
        rangeStartDate = selectedDate;
        rangeEndDate = previousRangeStartDate;
      }
    }

    rangeEndDate = DateRangePickerHelper.getLastDate(
        rangeEndDate, widget.controller.view, widget.picker.isHijri);
    if (widget.picker.maxDate != null) {
      rangeEndDate = rangeEndDate.isAfter(widget.picker.maxDate) == true
          ? widget.picker.maxDate
          : rangeEndDate;
    }

    final DateRangePickerView pickerView =
        DateRangePickerHelper.getPickerView(widget.controller.view);
    rangeStartDate = DateRangePickerHelper.getFirstDate(
        rangeStartDate, widget.picker.isHijri, pickerView);
    if (widget.picker.minDate != null) {
      rangeStartDate = rangeStartDate.isBefore(widget.picker.minDate) == true
          ? widget.picker.minDate
          : rangeStartDate;
    }

    if (widget.picker.isHijri) {
      return HijriDateRange(rangeStartDate, rangeEndDate);
    }

    return PickerDateRange(rangeStartDate, rangeEndDate);
  }

  bool _isSameOrBeforeDateCell(dynamic currentMaxDate, dynamic currentDate) {
    final DateRangePickerView pickerView =
        DateRangePickerHelper.getPickerView(widget.controller.view);
    if (pickerView == DateRangePickerView.year) {
      return (currentDate.month <= currentMaxDate.month == true &&
              currentDate.year == currentMaxDate.year) ||
          currentDate.year < currentMaxDate.year == true;
    } else if (pickerView == DateRangePickerView.decade) {
      return currentDate.year <= currentMaxDate.year == true;
    } else if (pickerView == DateRangePickerView.century) {
      return (currentDate.year ~/ 10) <= (currentMaxDate.year ~/ 10) == true;
    }

    return false;
  }

  bool _isSameOrAfterDateCell(dynamic currentMinDate, dynamic currentDate) {
    final DateRangePickerView pickerView =
        DateRangePickerHelper.getPickerView(widget.controller.view);
    if (pickerView == DateRangePickerView.year) {
      return (currentDate.month >= currentMinDate.month == true &&
              currentDate.year == currentMinDate.year) ||
          currentDate.year > currentMinDate.year == true;
    } else if (pickerView == DateRangePickerView.decade) {
      return currentDate.year >= currentMinDate.year == true;
    } else if (pickerView == DateRangePickerView.century) {
      return (currentDate.year ~/ 10) >= (currentMinDate.year ~/ 10) == true;
    }

    return false;
  }

  void _updateSelectedRangesOnDragUpdateYear(dynamic selectedDate) {
    switch (widget.picker.selectionMode) {
      case DateRangePickerSelectionMode.single:
      case DateRangePickerSelectionMode.multiple:
        break;
      case DateRangePickerSelectionMode.range:
        {
          if (!_isDragStart) {
            _pickerStateDetails.selectedRange = widget.picker.isHijri
                ? HijriDateRange(selectedDate, null)
                : PickerDateRange(selectedDate, null);
          } else {
            if (_pickerStateDetails.selectedRange != null &&
                _pickerStateDetails.selectedRange.startDate != null) {
              final dynamic updatedRange = _getSelectedRangeOnDragUpdateYear(
                  _pickerStateDetails.selectedRange, selectedDate);
              if (DateRangePickerHelper.isRangeEquals(
                  _pickerStateDetails.selectedRange, updatedRange)) {
                return;
              }

              _pickerStateDetails.selectedRange = updatedRange;
            } else {
              _pickerStateDetails.selectedRange = widget.picker.isHijri
                  ? HijriDateRange(selectedDate, null)
                  : PickerDateRange(selectedDate, null);
            }
          }
        }
        break;
      case DateRangePickerSelectionMode.multiRange:
        {
          _pickerStateDetails.selectedRanges ??= <dynamic>[];
          final int count = _pickerStateDetails.selectedRanges!.length;
          dynamic lastRange;
          if (count > 0) {
            lastRange = _pickerStateDetails.selectedRanges![count - 1];
          }

          if (!_isDragStart) {
            _pickerStateDetails.selectedRanges!.add(widget.picker.isHijri
                ? HijriDateRange(selectedDate, null)
                : PickerDateRange(selectedDate, null));
          } else {
            if (lastRange != null && lastRange.startDate != null) {
              final dynamic updatedRange =
                  _getSelectedRangeOnDragUpdateYear(lastRange, selectedDate);
              if (DateRangePickerHelper.isRangeEquals(
                  lastRange, updatedRange)) {
                return;
              }

              _pickerStateDetails.selectedRanges![count - 1] = updatedRange;
            } else {
              _pickerStateDetails.selectedRanges!.add(widget.picker.isHijri
                  ? HijriDateRange(selectedDate, null)
                  : PickerDateRange(selectedDate, null));
            }
          }

          _removeInterceptRanges(
              _pickerStateDetails.selectedRanges,
              _pickerStateDetails.selectedRanges![
                  _pickerStateDetails.selectedRanges!.length - 1]);
        }
        break;
      case DateRangePickerSelectionMode.extendableRange:
        _drawExtendableRangeSelection(selectedDate);
    }
  }

  void _dragStartOnYear(DragStartDetails details) {
    _isDragStart = false;
    widget.getPickerStateDetails(_pickerStateDetails);
    final int index =
        _getYearViewIndex(details.localPosition.dx, details.localPosition.dy);
    if (index == -1) {
      return;
    }

    final dynamic selectedDate = widget.visibleDates[index];
    if (!DateRangePickerHelper.isBetweenMinMaxDateCell(
            selectedDate,
            widget.picker.minDate,
            widget.picker.maxDate,
            widget.picker.enablePastDates,
            widget.controller.view,
            widget.picker.isHijri) ||
        DateRangePickerHelper.isDateWithInVisibleDates(
            widget.visibleDates, widget.disableDatePredicates, selectedDate)) {
      return;
    }

    if (widget.picker.selectionMode ==
            DateRangePickerSelectionMode.extendableRange &&
        _pickerStateDetails.selectedRange != null) {
      final DateRangePickerView pickerView =
          DateRangePickerHelper.getPickerView(widget.controller.view);
      if (DateRangePickerHelper.isDisableDirectionDate(
          _pickerStateDetails.selectedRange,
          selectedDate,
          widget.picker.extendableRangeSelectionDirection,
          pickerView,
          widget.picker.isHijri)) {
        return;
      }
    }

    _isDragStart = true;
    _updateSelectedRangesOnDragStart(_yearView, selectedDate);
    _previousSelectedDate = selectedDate;

    widget.updatePickerStateDetails(_pickerStateDetails);
    _yearView!.selectionNotifier.value = !_yearView!.selectionNotifier.value;
  }

  void _dragUpdateOnYear(DragUpdateDetails details) {
    widget.getPickerStateDetails(_pickerStateDetails);
    final int index =
        _getYearViewIndex(details.localPosition.dx, details.localPosition.dy);
    if (index == -1) {
      return;
    }

    final dynamic selectedDate = widget.visibleDates[index];
    if (!DateRangePickerHelper.isBetweenMinMaxDateCell(
            selectedDate,
            widget.picker.minDate,
            widget.picker.maxDate,
            widget.picker.enablePastDates,
            widget.controller.view,
            widget.picker.isHijri) ||
        DateRangePickerHelper.isDateWithInVisibleDates(
            widget.visibleDates, widget.disableDatePredicates, selectedDate)) {
      return;
    }

    if (widget.picker.selectionMode ==
            DateRangePickerSelectionMode.extendableRange &&
        _pickerStateDetails.selectedRange != null) {
      final DateRangePickerView pickerView =
          DateRangePickerHelper.getPickerView(widget.controller.view);
      if (DateRangePickerHelper.isDisableDirectionDate(
          _pickerStateDetails.selectedRange,
          selectedDate,
          widget.picker.extendableRangeSelectionDirection,
          pickerView,
          widget.picker.isHijri)) {
        return;
      }
    }

    _updateSelectedRangesOnDragUpdateYear(selectedDate);
    _previousSelectedDate = selectedDate;

    _isDragStart = true;
    widget.updatePickerStateDetails(_pickerStateDetails);
    _yearView!.selectionNotifier.value = !_yearView!.selectionNotifier.value;
  }

  void _handleTouch(Offset details, dynamic tapUpDetails, bool isSelect) {
    widget.getPickerStateDetails(_pickerStateDetails);
    final DateRangePickerView pickerView =
        DateRangePickerHelper.getPickerView(widget.controller.view);
    if (pickerView == DateRangePickerView.month) {
      final int index = _getSelectedIndex(details.dx, details.dy);
      if (index == -1) {
        return;
      }

      final dynamic selectedDate = widget.visibleDates[index];
      if (!DateRangePickerHelper.isEnabledDate(
          widget.picker.minDate,
          widget.picker.maxDate,
          widget.picker.enablePastDates,
          selectedDate,
          widget.picker.isHijri)) {
        return;
      }

      final int currentMonthIndex = _getCurrentDateIndex(index);
      if (!DateRangePickerHelper.isDateAsCurrentMonthDate(
          widget.visibleDates[currentMonthIndex],
          DateRangePickerHelper.getNumberOfWeeksInView(
              widget.picker.monthViewSettings, widget.picker.isHijri),
          DateRangePickerHelper.canShowLeadingAndTrailingDates(
              widget.picker.monthViewSettings, widget.picker.isHijri),
          selectedDate,
          widget.picker.isHijri)) {
        return;
      }

      if (DateRangePickerHelper.isDateWithInVisibleDates(widget.visibleDates,
              widget.picker.monthViewSettings.blackoutDates, selectedDate) ||
          DateRangePickerHelper.isDateWithInVisibleDates(widget.visibleDates,
              widget.disableDatePredicates, selectedDate)) {
        return;
      }

      if (widget.picker.selectionMode ==
              DateRangePickerSelectionMode.extendableRange &&
          _pickerStateDetails.selectedRange != null &&
          DateRangePickerHelper.isDisableDirectionDate(
              _pickerStateDetails.selectedRange,
              selectedDate,
              widget.picker.extendableRangeSelectionDirection,
              pickerView,
              widget.picker.isHijri)) {
        return;
      }

      _drawSelection(selectedDate, isSelect);
      widget.updatePickerStateDetails(_pickerStateDetails);
      _monthView!.selectionNotifier.value =
          !_monthView!.selectionNotifier.value;
    }
  }

  int _getCurrentDateIndex(int index) {
    final int datesCount = DateRangePickerHelper.getNumberOfWeeksInView(
            widget.picker.monthViewSettings, widget.picker.isHijri) *
        DateTime.daysPerWeek;
    int currentMonthIndex = datesCount ~/ 2;
    if (widget.enableMultiView && index >= datesCount) {
      currentMonthIndex += datesCount;
    }

    return currentMonthIndex;
  }

  void _drawSingleSelectionForYear(dynamic selectedDate) {
    if (widget.picker.toggleDaySelection &&
        DateRangePickerHelper.isSameCellDates(selectedDate,
            _pickerStateDetails.selectedDate, widget.controller.view)) {
      selectedDate = null;
    }

    _pickerStateDetails.selectedDate = selectedDate;
  }

  void _drawMultipleSelectionForYear(dynamic selectedDate) {
    int selectedIndex = -1;
    if (_pickerStateDetails.selectedDates != null &&
        _pickerStateDetails.selectedDates!.isNotEmpty) {
      selectedIndex = DateRangePickerHelper.getDateCellIndex(
          _pickerStateDetails.selectedDates!,
          selectedDate,
          widget.controller.view);
    }

    if (selectedIndex == -1) {
      _pickerStateDetails.selectedDates ??= <dynamic>[];
      _pickerStateDetails.selectedDates!.add(selectedDate);
    } else {
      _pickerStateDetails.selectedDates!.removeAt(selectedIndex);
    }
  }

  void _drawRangeSelectionForYear(dynamic selectedDate) {
    if (_pickerStateDetails.selectedRange != null &&
        _pickerStateDetails.selectedRange.startDate != null &&
        (_pickerStateDetails.selectedRange.endDate == null ||
            DateRangePickerHelper.isSameCellDates(
                _pickerStateDetails.selectedRange.startDate,
                _pickerStateDetails.selectedRange.endDate,
                widget.controller.view))) {
      dynamic startDate = _pickerStateDetails.selectedRange.startDate;
      dynamic endDate = selectedDate;
      if (startDate.isAfter(endDate) == true) {
        final dynamic temp = startDate;
        startDate = endDate;
        endDate = temp;
      }

      endDate = DateRangePickerHelper.getLastDate(
          endDate, widget.controller.view, widget.picker.isHijri);
      if (widget.picker.maxDate != null) {
        endDate = endDate.isAfter(widget.picker.maxDate) == true
            ? widget.picker.maxDate
            : endDate;
      }

      if (widget.picker.minDate != null) {
        startDate = startDate.isBefore(widget.picker.minDate) == true
            ? widget.picker.minDate
            : startDate;
      }

      _pickerStateDetails.selectedRange = widget.picker.isHijri
          ? HijriDateRange(startDate, endDate)
          : PickerDateRange(startDate, endDate);
    } else {
      _pickerStateDetails.selectedRange = widget.picker.isHijri
          ? HijriDateRange(selectedDate, null)
          : PickerDateRange(selectedDate, null);
    }

    _lastSelectedDate = selectedDate;
  }

  void _drawRangesSelectionForYear(dynamic selectedDate) {
    _pickerStateDetails.selectedRanges ??= <dynamic>[];
    int count = _pickerStateDetails.selectedRanges!.length;
    dynamic lastRange;
    if (count > 0) {
      lastRange = _pickerStateDetails.selectedRanges![count - 1];
    }

    if (lastRange != null &&
        lastRange.startDate != null &&
        (lastRange.endDate == null ||
            DateRangePickerHelper.isSameCellDates(lastRange.startDate,
                lastRange.endDate, widget.controller.view))) {
      dynamic startDate = lastRange.startDate;
      dynamic endDate = selectedDate;
      if (startDate.isAfter(endDate) == true) {
        final dynamic temp = startDate;
        startDate = endDate;
        endDate = temp;
      }

      endDate = DateRangePickerHelper.getLastDate(
          endDate, widget.controller.view, widget.picker.isHijri);
      if (widget.picker.maxDate != null) {
        endDate = endDate.isAfter(widget.picker.maxDate) == true
            ? widget.picker.maxDate
            : endDate;
      }

      if (widget.picker.minDate != null) {
        startDate = startDate.isBefore(widget.picker.minDate) == true
            ? widget.picker.minDate
            : startDate;
      }

      final dynamic newRange = widget.picker.isHijri
          ? HijriDateRange(startDate, endDate)
          : PickerDateRange(startDate, endDate);
      _pickerStateDetails.selectedRanges![count - 1] = newRange;
    } else {
      _pickerStateDetails.selectedRanges!.add(widget.picker.isHijri
          ? HijriDateRange(selectedDate, null)
          : PickerDateRange(selectedDate, null));
    }

    count = _pickerStateDetails.selectedRanges!.length;
    _removeInterceptRanges(
        _pickerStateDetails.selectedRanges,
        _pickerStateDetails
            .selectedRanges![_pickerStateDetails.selectedRanges!.length - 1]);
    lastRange = _pickerStateDetails
        .selectedRanges![_pickerStateDetails.selectedRanges!.length - 1];
    if (count != _pickerStateDetails.selectedRanges!.length &&
        (lastRange.endDate == null ||
            DateRangePickerHelper.isSameCellDates(lastRange.endDate,
                lastRange.startDate, widget.controller.view))) {
      _pickerStateDetails.selectedRanges!.removeLast();
    }
  }

  void _drawYearCellSelection(dynamic selectedDate) {
    switch (widget.picker.selectionMode) {
      case DateRangePickerSelectionMode.single:
        _drawSingleSelectionForYear(selectedDate);
        break;
      case DateRangePickerSelectionMode.multiple:
        _drawMultipleSelectionForYear(selectedDate);
        break;
      case DateRangePickerSelectionMode.range:
        _drawRangeSelectionForYear(selectedDate);
        break;
      case DateRangePickerSelectionMode.multiRange:
        _drawRangesSelectionForYear(selectedDate);
        break;
      case DateRangePickerSelectionMode.extendableRange:
        _drawExtendableRangeSelection(selectedDate);
    }
  }

  void _handleYearPanelSelection(Offset details) {
    final int selectedIndex = _getYearViewIndex(details.dx, details.dy);
    final int viewCount = widget.enableMultiView ? 2 : 1;
    if (selectedIndex == -1 || selectedIndex >= 12 * viewCount) {
      return;
    }

    final dynamic date = widget.visibleDates[selectedIndex];
    widget.getPickerStateDetails(_pickerStateDetails);
    final DateRangePickerView pickerView =
        DateRangePickerHelper.getPickerView(widget.controller.view);
    if (!widget.picker.allowViewNavigation) {
      if (!DateRangePickerHelper.isBetweenMinMaxDateCell(
              date,
              widget.picker.minDate,
              widget.picker.maxDate,
              widget.picker.enablePastDates,
              widget.controller.view,
              widget.picker.isHijri) ||
          DateRangePickerHelper.isDateWithInVisibleDates(
              widget.visibleDates, widget.disableDatePredicates, date)) {
        return;
      }

      if (widget.picker.selectionMode ==
              DateRangePickerSelectionMode.extendableRange &&
          _pickerStateDetails.selectedRange != null &&
          DateRangePickerHelper.isDisableDirectionDate(
              _pickerStateDetails.selectedRange,
              date,
              widget.picker.extendableRangeSelectionDirection,
              pickerView,
              widget.picker.isHijri)) {
        return;
      }

      _drawYearCellSelection(date);
      widget.updatePickerStateDetails(_pickerStateDetails);
      _yearView!.selectionNotifier.value = !_yearView!.selectionNotifier.value;
      return;
    }

    switch (pickerView) {
      case DateRangePickerView.month:
        break;
      case DateRangePickerView.century:
        {
          final int year = (date.year as int) ~/ 10;
          final int minYear = (widget.picker.minDate.year as int) ~/ 10;
          final int maxYear = (widget.picker.maxDate.year as int) ~/ 10;
          if (year < minYear || year > maxYear) {
            return;
          }

          _pickerStateDetails.view = DateRangePickerView.decade;
        }
        break;
      case DateRangePickerView.decade:
        {
          final int year = date.year as int;
          final int minYear = widget.picker.minDate.year as int;
          final int maxYear = widget.picker.maxDate.year as int;

          if (year < minYear || year > maxYear) {
            return;
          }
          _pickerStateDetails.view = DateRangePickerView.year;
        }
        break;
      case DateRangePickerView.year:
        {
          final int year = date.year as int;
          final int month = date.month as int;
          final int minYear = widget.picker.minDate.year as int;
          final int maxYear = widget.picker.maxDate.year as int;
          final int minMonth = widget.picker.minDate.month as int;
          final int maxMonth = widget.picker.maxDate.month as int;

          if ((year < minYear || (year == minYear && month < minMonth)) ||
              (year > maxYear || (year == maxYear && month > maxMonth))) {
            return;
          }

          _pickerStateDetails.view = DateRangePickerView.month;
        }
    }

    _pickerStateDetails.currentDate = date;
    widget.updatePickerStateDetails(_pickerStateDetails);
  }

  void _drawSingleSelectionForMonth(dynamic selectedDate) {
    if (widget.picker.toggleDaySelection &&
        isSameDate(selectedDate, _pickerStateDetails.selectedDate)) {
      selectedDate = null;
    }

    _pickerStateDetails.selectedDate = selectedDate;
  }

  void _drawMultipleSelectionForMonth(dynamic selectedDate) {
    final int selectedIndex = DateRangePickerHelper.isDateIndexInCollection(
        _pickerStateDetails.selectedDates, selectedDate);
    if (selectedIndex == -1) {
      _pickerStateDetails.selectedDates ??= <dynamic>[];
      _pickerStateDetails.selectedDates!.add(selectedDate);
    } else {
      _pickerStateDetails.selectedDates!.removeAt(selectedIndex);
    }
  }

  void _drawExtendableRangeSelection(dynamic selectedDate) {
    final DateRangePickerView pickerView =
        DateRangePickerHelper.getPickerView(widget.controller.view);
    if (_pickerStateDetails.selectedRange == null) {
      dynamic startDate = selectedDate;
      if (pickerView != DateRangePickerView.month &&
          widget.picker.minDate != null) {
        startDate = startDate.isBefore(widget.picker.minDate) == true
            ? widget.picker.minDate
            : startDate;
      }

      _pickerStateDetails.selectedRange = widget.picker.isHijri
          ? HijriDateRange(startDate, null)
          : PickerDateRange(startDate, null);
      _lastSelectedDate = selectedDate;
      return;
    }

    dynamic startDate = _pickerStateDetails.selectedRange.startDate;
    dynamic endDate = _pickerStateDetails.selectedRange.endDate ?? startDate;

    if (selectedDate.isAfter(endDate) == true) {
      endDate = selectedDate;
    } else if (selectedDate.isBefore(startDate) == true) {
      startDate = selectedDate;
    } else if (selectedDate.isAfter(startDate) == true &&
        selectedDate.isBefore(endDate) == true) {
      if (widget.picker.selectionMode ==
              DateRangePickerSelectionMode.extendableRange &&
          widget.picker.extendableRangeSelectionDirection !=
              ExtendableRangeSelectionDirection.both) {
        if (widget.picker.extendableRangeSelectionDirection ==
            ExtendableRangeSelectionDirection.forward) {
          endDate = selectedDate;
        } else if (widget.picker.extendableRangeSelectionDirection ==
            ExtendableRangeSelectionDirection.backward) {
          startDate = selectedDate;
        }
      } else {
        final int overAllDifference =
            endDate.difference(startDate).inDays as int;
        final int selectedDateIndex =
            selectedDate.difference(startDate).inDays as int;
        if (selectedDateIndex > overAllDifference / 2) {
          endDate = selectedDate;
        } else {
          startDate = selectedDate;
        }
      }
    }

    if (DateRangePickerHelper.isSameCellDates(startDate, endDate, pickerView)) {
      return;
    }

    if (pickerView != DateRangePickerView.month) {
      endDate = DateRangePickerHelper.getLastDate(
          endDate, widget.controller.view, widget.picker.isHijri);
      if (widget.picker.maxDate != null) {
        endDate = endDate.isAfter(widget.picker.maxDate) == true
            ? widget.picker.maxDate
            : endDate;
      }

      startDate = DateRangePickerHelper.getFirstDate(
          startDate, widget.picker.isHijri, pickerView);
      if (widget.picker.minDate != null) {
        startDate = startDate.isBefore(widget.picker.minDate) == true
            ? widget.picker.minDate
            : startDate;
      }
    }

    _pickerStateDetails.selectedRange = widget.picker.isHijri
        ? HijriDateRange(startDate, endDate)
        : PickerDateRange(startDate, endDate);
    _lastSelectedDate = selectedDate;

    _mouseHoverPosition.value = HoveringDetails(null, null);
  }

  void _drawRangeSelectionForMonth(dynamic selectedDate) {
    if (_pickerStateDetails.selectedRange != null &&
        _pickerStateDetails.selectedRange.startDate != null &&
        (_pickerStateDetails.selectedRange.endDate == null ||
            isSameDate(_pickerStateDetails.selectedRange.startDate,
                _pickerStateDetails.selectedRange.endDate))) {
      dynamic startDate = _pickerStateDetails.selectedRange.startDate;
      dynamic endDate = selectedDate;
      if (startDate.isAfter(endDate) == true) {
        final dynamic temp = startDate;
        startDate = endDate;
        endDate = temp;
      }

      _pickerStateDetails.selectedRange = widget.picker.isHijri
          ? HijriDateRange(startDate, endDate)
          : PickerDateRange(startDate, endDate);
    } else {
      _pickerStateDetails.selectedRange = widget.picker.isHijri
          ? HijriDateRange(selectedDate, null)
          : PickerDateRange(selectedDate, null);
    }

    _lastSelectedDate = selectedDate;
  }

  void selectRange(dynamic selectedDate) {
    _pickerStateDetails.selectedRanges ??= <dynamic>[];
    int count = _pickerStateDetails.selectedRanges!.length;
    dynamic lastRange;
    if (count > 0) {
      lastRange = _pickerStateDetails.selectedRanges![count - 1];
    }
    if (lastRange != null &&
        (_pickerStateDetails.selectedRanges!
            .any((element) => element.startDate == selectedDate))) {
    } else {
      _pickerStateDetails.selectedRanges!.add(widget.picker.isHijri
          ? HijriDateRange(selectedDate, null)
          : PickerDateRange(selectedDate, null));
    }

    count = _pickerStateDetails.selectedRanges!.length;
    if (count > 0) {
      _removeInterceptRanges(
          _pickerStateDetails.selectedRanges,
          _pickerStateDetails
              .selectedRanges![_pickerStateDetails.selectedRanges!.length - 1]);
      lastRange = _pickerStateDetails
          .selectedRanges![_pickerStateDetails.selectedRanges!.length - 1];
      if (count != _pickerStateDetails.selectedRanges!.length &&
          (lastRange.endDate == null ||
              isSameDate(lastRange.endDate, lastRange.startDate))) {
        _pickerStateDetails.selectedRanges!.removeLast();
      }
    }
  }

  void removeRange(dynamic selectedDate) {
    _pickerStateDetails.selectedRanges ??= <dynamic>[];
    int count = _pickerStateDetails.selectedRanges!.length;
    dynamic lastRange;
    if (count > 0) {
      lastRange = _pickerStateDetails.selectedRanges![count - 1];
    }
    if (lastRange != null &&
        (_pickerStateDetails.selectedRanges!.any(
          (dynamic element) {
            return selectedDate.isAfter(element.startDate) &&
                    (element.endDate != null &&
                        selectedDate.isBefore(element.endDate)) ||
                isSameDate(element.startDate, selectedDate) ||
                (element.endDate != null &&
                    isSameDate(element.endDate, selectedDate));
          },
        ))) {
      _pickerStateDetails.selectedRanges!.removeWhere(
        (dynamic element) {
          return (selectedDate.isAfter(element.startDate) &&
                  (element.endDate != null &&
                      selectedDate.isBefore(element.endDate))) ||
              (isSameDate(element.startDate, selectedDate) ||
                  (element.endDate != null &&
                      isSameDate(element.endDate, selectedDate)));
        },
      );
    } else {}

    count = _pickerStateDetails.selectedRanges!.length;
    if (count > 0) {
      _removeInterceptRanges(
          _pickerStateDetails.selectedRanges,
          _pickerStateDetails
              .selectedRanges![_pickerStateDetails.selectedRanges!.length - 1]);
      lastRange = _pickerStateDetails
          .selectedRanges![_pickerStateDetails.selectedRanges!.length - 1];
      if (count != _pickerStateDetails.selectedRanges!.length &&
          (lastRange.endDate == null ||
              isSameDate(lastRange.endDate, lastRange.startDate))) {
        _pickerStateDetails.selectedRanges!.removeLast();
      }
    }
  }

  void _drawRangesSelectionForMonth(dynamic selectedDate) {
    _pickerStateDetails.selectedRanges ??= <dynamic>[];
    int count = _pickerStateDetails.selectedRanges!.length;
    dynamic lastRange;
    if (count > 0) {
      lastRange = _pickerStateDetails.selectedRanges![count - 1];
    }
    if (lastRange != null &&
        (_pickerStateDetails.selectedRanges!
            .any((element) => element.startDate == selectedDate))) {
      _pickerStateDetails.selectedRanges!
          .removeWhere((element) => element.startDate == selectedDate);
    } else {
      _pickerStateDetails.selectedRanges!.add(widget.picker.isHijri
          ? HijriDateRange(selectedDate, null)
          : PickerDateRange(selectedDate, null));
    }

    count = _pickerStateDetails.selectedRanges!.length;
    if (count > 0) {
      _removeInterceptRanges(
          _pickerStateDetails.selectedRanges,
          _pickerStateDetails
              .selectedRanges![_pickerStateDetails.selectedRanges!.length - 1]);
      lastRange = _pickerStateDetails
          .selectedRanges![_pickerStateDetails.selectedRanges!.length - 1];
      if (count != _pickerStateDetails.selectedRanges!.length &&
          (lastRange.endDate == null ||
              isSameDate(lastRange.endDate, lastRange.startDate))) {
        _pickerStateDetails.selectedRanges!.removeLast();
      }
    }
  }

  int? _removeInterceptRangesForMonth(dynamic range, dynamic startDate,
      dynamic endDate, int i, dynamic selectedRangeValue) {
    if (range != null &&
        !DateRangePickerHelper.isRangeEquals(range, selectedRangeValue) &&
        ((range.startDate != null &&
                ((startDate != null &&
                        isSameDate(range.startDate, startDate)) ||
                    (endDate != null &&
                        isSameDate(range.startDate, endDate)))) ||
            (range.endDate != null &&
                ((startDate != null && isSameDate(range.endDate, startDate)) ||
                    (endDate != null && isSameDate(range.endDate, endDate)))) ||
            (range.startDate != null &&
                range.endDate != null &&
                ((startDate != null &&
                        isDateWithInDateRange(
                            range.startDate, range.endDate, startDate)) ||
                    (endDate != null &&
                        isDateWithInDateRange(
                            range.startDate, range.endDate, endDate)))) ||
            (startDate != null &&
                endDate != null &&
                ((range.startDate != null &&
                        isDateWithInDateRange(
                            startDate, endDate, range.startDate)) ||
                    (range.endDate != null &&
                        isDateWithInDateRange(
                            startDate, endDate, range.endDate)))) ||
            (range.startDate != null &&
                range.endDate != null &&
                startDate != null &&
                endDate != null &&
                ((range.startDate.isAfter(startDate) == true &&
                        range.endDate.isBefore(endDate) == true) ||
                    (range.endDate.isAfter(startDate) == true &&
                        range.startDate.isBefore(endDate) == true))))) {
      return i;
    }

    return null;
  }

  int? _removeInterceptRangesForYear(dynamic range, dynamic startDate,
      dynamic endDate, int i, dynamic selectedRangeValue) {
    if (range == null ||
        DateRangePickerHelper.isRangeEquals(range, selectedRangeValue)) {
      return null;
    }

    if (range.startDate != null &&
        ((startDate != null &&
                DateRangePickerHelper.isSameCellDates(
                    range.startDate, startDate, widget.controller.view)) ||
            (endDate != null &&
                DateRangePickerHelper.isSameCellDates(
                    range.startDate, endDate, widget.controller.view)))) {
      return i;
    }

    if (range.endDate != null &&
        ((startDate != null &&
                DateRangePickerHelper.isSameCellDates(
                    range.endDate, startDate, widget.controller.view)) ||
            (endDate != null &&
                DateRangePickerHelper.isSameCellDates(
                    range.endDate, endDate, widget.controller.view)))) {
      return i;
    }

    if (range.startDate != null &&
        range.endDate != null &&
        ((startDate != null &&
                _isDateWithInYearRange(
                    range.startDate, range.endDate, startDate)) ||
            (endDate != null &&
                _isDateWithInYearRange(
                    range.startDate, range.endDate, endDate)))) {
      return i;
    }

    if (startDate != null &&
        endDate != null &&
        ((range.startDate != null &&
                _isDateWithInYearRange(startDate, endDate, range.startDate)) ||
            (range.endDate != null &&
                _isDateWithInYearRange(startDate, endDate, range.endDate)))) {
      return i;
    }

    if (range.startDate != null &&
        range.endDate != null &&
        startDate != null &&
        endDate != null &&
        ((range.startDate.isAfter(startDate) == true &&
                range.endDate.isBefore(endDate) == true) ||
            (range.endDate.isAfter(startDate) == true &&
                range.startDate.isBefore(endDate) == true))) {
      return i;
    }

    return null;
  }

  bool _isDateWithInYearRange(
      dynamic startDate, dynamic endDate, dynamic date) {
    if (startDate == null || endDate == null || date == null) {
      return false;
    }

    final DateRangePickerView pickerView =
        DateRangePickerHelper.getPickerView(widget.controller.view);

    if (startDate.isAfter(endDate) == true) {
      final dynamic temp = startDate;
      startDate = endDate;
      endDate = temp;
    }

    if ((DateRangePickerHelper.isSameCellDates(endDate, date, pickerView) ||
            endDate.isAfter(date) == true) &&
        (DateRangePickerHelper.isSameCellDates(startDate, date, pickerView) ||
            startDate.isBefore(date) == true)) {
      return true;
    }

    return false;
  }

  void _removeInterceptRanges(
      List<dynamic>? selectedRanges, dynamic selectedRangeValue) {
    if (selectedRanges == null ||
        selectedRanges.isEmpty ||
        selectedRangeValue == null) {
      return;
    }

    dynamic startDate = selectedRangeValue.startDate;
    dynamic endDate = selectedRangeValue.endDate;
    if (startDate != null &&
        endDate != null &&
        startDate.isAfter(endDate) == true) {
      final dynamic temp = startDate;
      startDate = endDate;
      endDate = temp;
    }

    final List<int> interceptIndex = <int>[];
    for (int i = 0; i < selectedRanges.length; i++) {
      final dynamic range = selectedRanges[i];

      int? index;
      switch (_pickerStateDetails.view) {
        case DateRangePickerView.month:
          {
            index = _removeInterceptRangesForMonth(
                range, startDate, endDate, i, selectedRangeValue);
          }
          break;
        case DateRangePickerView.year:
        case DateRangePickerView.decade:
        case DateRangePickerView.century:
          {
            index = _removeInterceptRangesForYear(
                range, startDate, endDate, i, selectedRangeValue);
          }
      }
      if (index != null) {
        interceptIndex.add(index);
      }
    }

    interceptIndex.sort();
    for (int i = interceptIndex.length - 1; i >= 0; i--) {
      selectedRanges.removeAt(interceptIndex[i]);
    }
  }
}

String _getMonthHeaderText(
    int startIndex,
    int endIndex,
    List<dynamic> dates,
    int middleIndex,
    int datesCount,
    bool isHijri,
    int numberOfWeeksInView,
    String? monthFormat,
    bool enableMultiView,
    DateRangePickerHeaderStyle headerStyle,
    DateRangePickerNavigationDirection navigationDirection,
    Locale locale,
    SfLocalizations localizations) {
  if ((!isHijri && numberOfWeeksInView != 6) &&
      dates[startIndex].month != dates[endIndex].month) {
    final String monthTextFormat =
        monthFormat == null || monthFormat.isEmpty ? 'MMM' : monthFormat;
    int endIndex = dates.length - 1;
    if (enableMultiView && headerStyle.textAlign == TextAlign.center) {
      endIndex = endIndex;
    }
    final String startText =
        '${DateFormat(monthTextFormat, locale.toString()).format(dates[startIndex])} ${dates[startIndex].year}';
    final String endText =
        '${DateFormat(monthTextFormat, locale.toString()).format(dates[endIndex])} ${dates[endIndex].year}';
    if (startText == endText) {
      return startText;
    }

    return '$startText - $endText';
  } else {
    final String monthTextFormat = monthFormat == null || monthFormat.isEmpty
        ? enableMultiView &&
                navigationDirection ==
                    DateRangePickerNavigationDirection.vertical
            ? 'MMM'
            : 'MMMM'
        : monthFormat;
    String text;
    dynamic middleDate = dates[middleIndex];
    if (isHijri) {
      text =
          '${DateRangePickerHelper.getHijriMonthText(middleDate, localizations, monthTextFormat)} ${middleDate.year}';
    } else {
      text =
          '${DateFormat(monthTextFormat, locale.toString()).format(middleDate)}'
          ' ${middleDate.year}';
    }

    if (enableMultiView &&
        navigationDirection == DateRangePickerNavigationDirection.vertical &&
        numberOfWeeksInView != 6 &&
        dates[startIndex].month == dates[endIndex].month) {
      return text;
    }

    if ((enableMultiView && headerStyle.textAlign != TextAlign.center) ||
        (enableMultiView &&
            navigationDirection ==
                DateRangePickerNavigationDirection.vertical)) {
      middleDate = dates[datesCount + middleIndex];
      if (isHijri) {
        return '$text - ${DateRangePickerHelper.getHijriMonthText(middleDate, localizations, monthTextFormat)} ${middleDate.year}';
      } else {
        return '$text - ${DateFormat(monthTextFormat, locale.toString()).format(middleDate)} ${middleDate.year}';
      }
    }

    return text;
  }
}

String _getHeaderText(
    List<dynamic> dates,
    DateRangePickerView view,
    int index,
    bool isHijri,
    int numberOfWeeksInView,
    String? monthFormat,
    bool enableMultiView,
    DateRangePickerHeaderStyle headerStyle,
    DateRangePickerNavigationDirection navigationDirection,
    Locale locale,
    SfLocalizations localizations) {
  final int count = enableMultiView ? 2 : 1;
  final int datesCount = dates.length ~/ count;
  final int startIndex = index * datesCount;
  final int endIndex = ((index + 1) * datesCount) - 1;
  final int middleIndex = startIndex + (datesCount ~/ 2);
  switch (view) {
    case DateRangePickerView.month:
      {
        return _getMonthHeaderText(
            startIndex,
            endIndex,
            dates,
            middleIndex,
            datesCount,
            isHijri,
            numberOfWeeksInView,
            monthFormat,
            enableMultiView,
            headerStyle,
            navigationDirection,
            locale,
            localizations);
      }
    case DateRangePickerView.year:
      {
        final dynamic date = dates[middleIndex];
        if ((enableMultiView && headerStyle.textAlign != TextAlign.center) ||
            (enableMultiView &&
                navigationDirection ==
                    DateRangePickerNavigationDirection.vertical)) {
          return '${date.year} - ${dates[datesCount + middleIndex].year}';
        }

        return date.year.toString();
      }
    case DateRangePickerView.decade:
      {
        final int year = ((dates[middleIndex].year as int) ~/ 10) * 10;
        if ((enableMultiView && headerStyle.textAlign != TextAlign.center) ||
            (enableMultiView &&
                navigationDirection ==
                    DateRangePickerNavigationDirection.vertical)) {
          return '$year - ${((dates[datesCount + middleIndex].year ~/ 10) * 10) + 9}';
        }

        return '$year - ${year + 9}';
      }
    case DateRangePickerView.century:
      {
        final int year = ((dates[middleIndex].year as int) ~/ 100) * 100;
        if ((enableMultiView && headerStyle.textAlign != TextAlign.center) ||
            (enableMultiView &&
                navigationDirection ==
                    DateRangePickerNavigationDirection.vertical)) {
          return '$year - ${((dates[datesCount + middleIndex].year ~/ 100) * 100) + 99}';
        }

        return '$year - ${year + 99}';
      }
  }
}

Size _getTextWidgetWidth(
    String text, double height, double width, BuildContext context,
    {required TextStyle style,
    double widthPadding = 10,
    double heightPadding = 10}) {
  final Widget textWidget = Text(
    text,
    style: style,
    maxLines: 1,
    softWrap: false,
    textDirection: TextDirection.ltr,
    textAlign: TextAlign.left,
  ).build(context);

  final RichText? richTextWidget = textWidget is RichText ? textWidget : null;

  final RenderParagraph renderObject =
      richTextWidget!.createRenderObject(context);
  renderObject.layout(BoxConstraints(
    minWidth: width,
    maxWidth: width,
    minHeight: height,
    maxHeight: height,
  ));

  final List<TextBox> textBox = renderObject.getBoxesForSelection(
      TextSelection(baseOffset: 0, extentOffset: text.length));
  double textWidth = 0;
  double textHeight = 0;
  for (final TextBox box in textBox) {
    textWidth += box.right - box.left;
    final double currentBoxHeight = box.bottom - box.top;
    textHeight = textHeight > currentBoxHeight ? textHeight : currentBoxHeight;
  }

  return Size(textWidth + widthPadding, textHeight + heightPadding);
}

bool _isSwipeInteractionEnabled(
    bool enableSwipeSelection, DateRangePickerNavigationMode navigationMode) {
  return enableSwipeSelection &&
      navigationMode != DateRangePickerNavigationMode.scroll;
}

bool _isMultiViewEnabled(_SfDateRangePicker picker) {
  return picker.enableMultiView &&
      picker.navigationMode != DateRangePickerNavigationMode.scroll;
}
