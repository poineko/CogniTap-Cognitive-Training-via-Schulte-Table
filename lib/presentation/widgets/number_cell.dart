import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CellState { idle, correct, wrong, alreadyTapped }

class NumberCell extends StatefulWidget {
  final int number;
  final CellState cellState;
  final Color? distractionColor; // Interference Mode
  final VoidCallback onTap;

  const NumberCell({
    super.key,
    required this.number,
    required this.cellState,
    required this.onTap,
    this.distractionColor,
  });

  @override
  State<NumberCell> createState() => _NumberCellState();
}

class _NumberCellState extends State<NumberCell>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void didUpdateWidget(NumberCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cellState == CellState.wrong &&
        oldWidget.cellState != CellState.wrong) {
      _shakeController.forward(from: 0);
      HapticFeedback.mediumImpact();
    }
    if (widget.cellState == CellState.correct &&
        oldWidget.cellState != CellState.correct) {
      HapticFeedback.lightImpact();
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color bgColor;
    Color textColor;

    switch (widget.cellState) {
      case CellState.correct:
        bgColor = Colors.greenAccent.shade400;
        textColor = Colors.white;
      case CellState.wrong:
        bgColor = Colors.red.shade400;
        textColor = Colors.white;
      case CellState.alreadyTapped:
        bgColor =
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4);
        textColor = theme.colorScheme.onSurface.withValues(alpha: 0.3);
      case CellState.idle:
        bgColor = widget.distractionColor ?? theme.colorScheme.primaryContainer;
        textColor = theme.colorScheme.onPrimaryContainer;
    }

    // Shake animation untuk ketukan salah
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final shakeDx = widget.cellState == CellState.wrong
            ? (8 * (0.5 - _shakeAnimation.value).abs() * 2 - 8).clamp(-8.0, 8.0)
            : 0.0;
        return Transform.translate(
          offset: Offset(shakeDx, 0),
          child: child,
        );
      },
      child: GestureDetector(
        onTap:
            widget.cellState == CellState.alreadyTapped ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: widget.cellState == CellState.idle
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 150),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              child: Text('${widget.number}'),
            ),
          ),
        ),
      ),
    );
  }
}
