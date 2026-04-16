import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

// ─── APP HEADER ──────────────────────────────────────────────
class SplashAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  const SplashAppBar({super.key, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              // Logo icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.splash,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'SS',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontHeading,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontHeading,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark,
                  ),
                  children: [
                    TextSpan(text: 'Splash'),
                    TextSpan(
                      text: 'Sphere',
                      style: TextStyle(color: AppColors.splash),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Avatar
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.splash, AppColors.aqua],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  'MS',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontHeading,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              if (actions != null) ...actions!,
            ],
          ),
        ),
      ),
    );
  }
}

// ─── SECTION TITLE ───────────────────────────────────────────
class SectionTitle extends StatelessWidget {
  final String title;
  final EdgeInsets? padding;

  const SectionTitle(this.title, {super.key, this.padding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(20, 18, 20, 10),
      child: Text(title, style: AppTextStyles.sectionTitle),
    );
  }
}

// ─── BADGE ───────────────────────────────────────────────────
class AppBadge extends StatelessWidget {
  final String text;
  final Color bg;
  final Color textColor;

  const AppBadge(
    this.text, {
    super.key,
    required this.bg,
    required this.textColor,
  });

  factory AppBadge.gold(String text) => AppBadge(
        text,
        bg: AppColors.amberLight,
        textColor: AppColors.gold,
      );

  factory AppBadge.silver(String text) => AppBadge(
        text,
        bg: const Color(0xFFF1F5F9),
        textColor: const Color(0xFF64748B),
      );

  factory AppBadge.emerald(String text) => AppBadge(
        text,
        bg: AppColors.emeraldLight,
        textColor: const Color(0xFF059669),
      );

  factory AppBadge.splash(String text) => AppBadge(
        text,
        bg: AppColors.splashLight,
        textColor: AppColors.splashDark,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: AppTextStyles.fontHeading,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ─── PRIMARY BUTTON ──────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool fullWidth;
  final double fontSize;
  final EdgeInsets? padding;

  const PrimaryButton(
    this.label, {
    super.key,
    this.onTap,
    this.fullWidth = false,
    this.fontSize = 13,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget btn = GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.splash,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTextStyles.fontHeading,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
    if (fullWidth) return SizedBox(width: double.infinity, child: btn);
    return btn;
  }
}

class OutlineButton2 extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool fullWidth;
  final double fontSize;

  const OutlineButton2(
    this.label, {
    super.key,
    this.onTap,
    this.fullWidth = false,
    this.fontSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    Widget btn = GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: AppColors.splash, width: 1.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTextStyles.fontHeading,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: AppColors.splash,
          ),
        ),
      ),
    );
    if (fullWidth) return SizedBox(width: double.infinity, child: btn);
    return btn;
  }
}

// ─── PILL ROW ────────────────────────────────────────────────
class PillRow extends StatefulWidget {
  final List<String> pills;
  final int initial;

  const PillRow({super.key, required this.pills, this.initial = 0});

  @override
  State<PillRow> createState() => _PillRowState();
}

class _PillRowState extends State<PillRow> {
  late int _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(widget.pills.length, (i) {
          final active = i == _selected;
          return GestureDetector(
            onTap: () => setState(() => _selected = i),
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: active ? AppColors.splash : Colors.white,
                border: Border.all(
                  color: active ? AppColors.splash : AppColors.border,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                widget.pills[i],
                style: TextStyle(
                  fontFamily: AppTextStyles.fontHeading,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : AppColors.muted,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}