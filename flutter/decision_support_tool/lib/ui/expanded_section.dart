// Widget used to store instructions for a given question in the DST.
// Collapsable widget that shows instructions upon selection.

// import 'package:decision_support_tool/logic/instruction.dart';
import 'package:flutter/material.dart';
// import '../logic/assessment_info.dart';

class ExpandedSection extends StatefulWidget {
  final Widget child;
  final bool expand;
  ExpandedSection({this.expand = false, required this.child});

  @override
  _ExpandedSectionState createState() => _ExpandedSectionState();
}

class _ExpandedSectionState extends State<ExpandedSection>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    animation = CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn,
    );

    _runExpandCheck();
  }

  void _runExpandCheck() {
    if (widget.expand) {
      controller.forward();
    } else {
      controller.reverse();
    }
  }

  @override
  void didUpdateWidget(ExpandedSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _runExpandCheck();
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      axisAlignment: 1.0,
      sizeFactor: animation,
      child: widget.child,
    );
  }
}
