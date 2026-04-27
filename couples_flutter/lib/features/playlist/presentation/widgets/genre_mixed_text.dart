import 'package:flutter/material.dart';

class GenreMixedText extends StatelessWidget {
  const GenreMixedText({
    super.key,
    required this.text,
    required this.chineseFontFamily,
    required this.englishFontFamily,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  final String text;
  final String chineseFontFamily;
  final String englishFontFamily;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  static List<InlineSpan> buildTextSpans({
    required String text,
    required String chineseFontFamily,
    required String englishFontFamily,
    TextStyle? style,
  }) {
    final spans = <InlineSpan>[];
    final matcher =
        RegExp(r'[\u4E00-\u9FFF]+|[A-Za-z0-9&+./-]+|[^A-Za-z0-9\u4E00-\u9FFF]+');
    for (final match in matcher.allMatches(text)) {
      final segment = match.group(0) ?? '';
      if (segment.isEmpty) {
        continue;
      }
      final isChinese = RegExp(r'[\u4E00-\u9FFF]').hasMatch(segment);
      spans.add(
        TextSpan(
          text: segment,
          style: (style ?? const TextStyle()).copyWith(
            fontFamily: isChinese ? chineseFontFamily : englishFontFamily,
          ),
        ),
      );
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
      textAlign: textAlign ?? TextAlign.start,
      text: TextSpan(
        children: buildTextSpans(
          text: text,
          chineseFontFamily: chineseFontFamily,
          englishFontFamily: englishFontFamily,
          style: DefaultTextStyle.of(context).style.merge(style),
        ),
      ),
    );
  }
}

