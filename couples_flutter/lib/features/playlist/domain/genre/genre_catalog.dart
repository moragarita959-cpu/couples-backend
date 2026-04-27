import 'package:flutter/material.dart';

/// Genre metadata for the playlist feature.
///
/// We intentionally keep the persisted field as the existing single `genre`
/// string to avoid touching the current Song model / Drift schema. New values
/// are encoded as `primaryId|secondaryId`, while legacy free-form values are
/// resolved back into a known category when possible.
class GenreCategory {
  const GenreCategory({
    required this.id,
    required this.name,
    required this.englishName,
    required this.chineseFontFamily,
    required this.englishFontFamily,
    required this.gradient,
    required this.primaryColor,
    required this.children,
  });

  final String id;
  final String name;
  final String englishName;
  final String chineseFontFamily;
  final String englishFontFamily;
  final List<Color> gradient;
  final Color primaryColor;
  final List<GenreSubTag> children;

  String get mixedLabel => '$name $englishName';
}

class GenreSubTag {
  const GenreSubTag({
    required this.id,
    required this.name,
    required this.color,
  });

  final String id;
  final String name;
  final Color color;
}

class ResolvedGenre {
  const ResolvedGenre({
    required this.category,
    this.subTag,
    required this.rawValue,
    this.isLegacy = false,
  });

  final GenreCategory category;
  final GenreSubTag? subTag;
  final String rawValue;
  final bool isLegacy;

  bool get hasSecondary => subTag != null;

  String get storageValue =>
      subTag == null ? category.id : '${category.id}|${subTag!.id}';
}

class GenreCatalog {
  const GenreCatalog._();

  static final GenreCategory other = GenreCategory(
    id: 'other',
    name: '其他',
    englishName: 'Other',
    chineseFontFamily: 'GenreIndieZh',
    englishFontFamily: 'GenreIndieEn',
    gradient: const <Color>[Color(0xFF7A7D74), Color(0xFFC3B8A6)],
    primaryColor: const Color(0xFF8A867B),
    children: const <GenreSubTag>[],
  );

  static final List<GenreCategory> categories = <GenreCategory>[
    _category(
      id: 'pop',
      name: '流行',
      englishName: 'Pop',
      chineseFontFamily: 'GenrePopZh',
      englishFontFamily: 'GenrePopEn',
      gradient: const <Color>[Color(0xFFFF8F7A), Color(0xFFFFD4A8)],
      primaryColor: const Color(0xFFFFA98D),
      children: const <String>[
        '华语流行',
        '欧美流行',
        'J-Pop',
        'K-Pop',
        'C-Pop',
        'City Pop',
        'Synth Pop',
        'Dream Pop',
        'Teen Pop',
        'Dance Pop',
        'Indie Pop',
        'Electropop',
      ],
    ),
    _category(
      id: 'rock',
      name: '摇滚',
      englishName: 'Rock',
      chineseFontFamily: 'GenreRockZh',
      englishFontFamily: 'GenreRockEn',
      gradient: const <Color>[Color(0xFF465266), Color(0xFF8A6A63)],
      primaryColor: const Color(0xFF5D6775),
      children: const <String>[
        '经典摇滚',
        '独立摇滚',
        '硬摇滚',
        '后摇',
        '迷幻摇滚',
        'Britpop',
        'Shoegaze',
        'Garage Rock',
        'Alternative Rock',
        'Art Rock',
        'Progressive Rock',
      ],
    ),
    _category(
      id: 'metal',
      name: '金属',
      englishName: 'Metal',
      chineseFontFamily: 'GenreMetalZh',
      englishFontFamily: 'GenreMetalEn',
      gradient: const <Color>[Color(0xFF4C5563), Color(0xFF8D97A8)],
      primaryColor: const Color(0xFF626C7C),
      children: const <String>[
        '重金属',
        '黑金属',
        '死亡金属',
        '金属核',
        '前卫金属',
        'Djent',
        '工业金属',
        '交响金属',
        '力量金属',
        '民谣金属',
      ],
    ),
    _category(
      id: 'folk',
      name: '民谣',
      englishName: 'Folk',
      chineseFontFamily: 'GenreFolkZh',
      englishFontFamily: 'GenreFolkEn',
      gradient: const <Color>[Color(0xFFB58B68), Color(0xFFDDC6A4)],
      primaryColor: const Color(0xFFC19A78),
      children: const <String>[
        '校园民谣',
        '独立民谣',
        '原声民谣',
        '叙事民谣',
        '当代民谣',
        'Bluegrass',
        'Singer-Songwriter',
      ],
    ),
    _category(
      id: 'electronic',
      name: '电子',
      englishName: 'Electronic',
      chineseFontFamily: 'GenreElectronicZh',
      englishFontFamily: 'GenreElectronicEn',
      gradient: const <Color>[Color(0xFF4E7D91), Color(0xFF72B9C7)],
      primaryColor: const Color(0xFF5E98AB),
      children: const <String>[
        'House',
        'Techno',
        'Trance',
        'EDM',
        'Future Bass',
        'Synthwave',
        'Vaporwave',
        'DnB',
        'Dubstep',
        'IDM',
        'Electro',
        'Hardstyle',
      ],
    ),
    _category(
      id: 'hiphop',
      name: '说唱',
      englishName: 'Hip-Hop/Rap',
      chineseFontFamily: 'GenreHipHopZh',
      englishFontFamily: 'GenreHipHopEn',
      gradient: const <Color>[Color(0xFF575F69), Color(0xFFA58B67)],
      primaryColor: const Color(0xFF7F7768),
      children: const <String>[
        '中文说唱',
        'Trap',
        'Drill',
        'Boom Bap',
        'Jazz Rap',
        'Cloud Rap',
        'Old School',
        'New School',
        'Gangsta Rap',
        'Lo-fi Rap',
      ],
    ),
    _category(
      id: 'rnb',
      name: 'R&B',
      englishName: 'Soul',
      chineseFontFamily: 'GenreRnBZh',
      englishFontFamily: 'GenreRnBEn',
      gradient: const <Color>[Color(0xFF5F687D), Color(0xFFC9A17D)],
      primaryColor: const Color(0xFF8C7B7D),
      children: const <String>[
        'Neo Soul',
        'Alt R&B',
        'Trap Soul',
        'Bedroom R&B',
        'Soul',
        'Slow Jam',
        'Funk Soul',
        'Contemporary R&B',
      ],
    ),
    _category(
      id: 'jazz',
      name: '爵士',
      englishName: 'Jazz',
      chineseFontFamily: 'GenreJazzZh',
      englishFontFamily: 'GenreJazzEn',
      gradient: const <Color>[Color(0xFF785C49), Color(0xFFB99A73)],
      primaryColor: const Color(0xFF987658),
      children: const <String>[
        'Swing',
        'Bebop',
        'Smooth Jazz',
        'Fusion',
        'Vocal Jazz',
        'Acid Jazz',
        'Free Jazz',
        'Cool Jazz',
        'Latin Jazz',
      ],
    ),
    _category(
      id: 'blues',
      name: '布鲁斯',
      englishName: 'Blues',
      chineseFontFamily: 'GenreBluesZh',
      englishFontFamily: 'GenreBluesEn',
      gradient: const <Color>[Color(0xFF4B5F77), Color(0xFF8CA4B9)],
      primaryColor: const Color(0xFF647D97),
      children: const <String>[
        'Delta Blues',
        'Chicago Blues',
        'Electric Blues',
        'Blues Rock',
        'Soul Blues',
        'Country Blues',
      ],
    ),
    _category(
      id: 'classical',
      name: '古典',
      englishName: 'Classical',
      chineseFontFamily: 'GenreClassicalZh',
      englishFontFamily: 'GenreClassicalEn',
      gradient: const <Color>[Color(0xFF8E7C62), Color(0xFFD9C8AC)],
      primaryColor: const Color(0xFFB1997F),
      children: const <String>[
        '巴洛克',
        '古典主义',
        '浪漫主义',
        '现代古典',
        '室内乐',
        '协奏曲',
        '交响乐',
        '钢琴曲',
        '歌剧',
        '宗教音乐',
      ],
    ),
    _category(
      id: 'guofeng',
      name: '国风',
      englishName: 'Guofeng',
      chineseFontFamily: 'GenreGuofengZh',
      englishFontFamily: 'GenreGuofengEn',
      gradient: const <Color>[Color(0xFFA78049), Color(0xFFD9BE87)],
      primaryColor: const Color(0xFFC49C63),
      children: const <String>[
        '古风',
        '国风',
        '戏腔',
        '民乐',
        '仙侠',
        '武侠',
        '中国风',
        '国风电子',
        '新民乐',
        '古琴',
        '琵琶',
      ],
    ),
    _category(
      id: 'lightmusic',
      name: '轻音乐',
      englishName: 'Light Music',
      chineseFontFamily: 'GenreLightMusicZh',
      englishFontFamily: 'GenreLightMusicEn',
      gradient: const <Color>[Color(0xFF7E9F98), Color(0xFFDFE9E3)],
      primaryColor: const Color(0xFF9BB8B2),
      children: const <String>[
        '纯音乐',
        '钢琴曲',
        '吉他曲',
        '治愈器乐',
        '睡眠音乐',
        '背景音乐',
        '小提琴曲',
        '器乐独奏',
      ],
    ),
    _category(
      id: 'ambient',
      name: '氛围',
      englishName: 'Ambient',
      chineseFontFamily: 'GenreAmbientZh',
      englishFontFamily: 'GenreAmbientEn',
      gradient: const <Color>[Color(0xFF708B97), Color(0xFFC2D1D9)],
      primaryColor: const Color(0xFF8EA6B1),
      children: const <String>[
        'Ambient',
        'Dark Ambient',
        'Drone',
        'Soundscape',
        'Field Recording',
        'Space Ambient',
        'Minimal Ambient',
      ],
    ),
    _category(
      id: 'ost',
      name: '配乐',
      englishName: 'OST',
      chineseFontFamily: 'GenreOSTZh',
      englishFontFamily: 'GenreOSTEn',
      gradient: const <Color>[Color(0xFF6C7280), Color(0xFFB9A889)],
      primaryColor: const Color(0xFF8B8C86),
      children: const <String>[
        '电影原声',
        '动漫原声',
        '游戏原声',
        '史诗配乐',
        '电视剧原声',
        '预告片音乐',
        '舞台剧配乐',
      ],
    ),
    _category(
      id: 'club',
      name: '舞曲',
      englishName: 'Club',
      chineseFontFamily: 'GenreClubZh',
      englishFontFamily: 'GenreClubEn',
      gradient: const <Color>[Color(0xFF5E7590), Color(0xFF8EB7A2)],
      primaryColor: const Color(0xFF7396A0),
      children: const <String>[
        'Dance',
        'Club',
        'Disco',
        'Eurodance',
        'Amapiano',
        'Reggaeton Dance',
        'Big Room',
        'Melbourne Bounce',
      ],
    ),
    _category(
      id: 'funk',
      name: '放克',
      englishName: 'Funk',
      chineseFontFamily: 'GenreFunkZh',
      englishFontFamily: 'GenreFunkEn',
      gradient: const <Color>[Color(0xFFA06B42), Color(0xFFD6B168)],
      primaryColor: const Color(0xFFBE8E54),
      children: const <String>[
        'Funk',
        'Nu Disco',
        'Boogie',
        'Future Funk',
        'Disco Funk',
        'P-Funk',
        'Electro Funk',
      ],
    ),
    _category(
      id: 'latin',
      name: '拉丁',
      englishName: 'World',
      chineseFontFamily: 'GenreLatinZh',
      englishFontFamily: 'GenreLatinEn',
      gradient: const <Color>[Color(0xFFB86E4C), Color(0xFFE6B46D)],
      primaryColor: const Color(0xFFD18A56),
      children: const <String>[
        'Salsa',
        'Bossa Nova',
        'Flamenco',
        'Afrobeat',
        'Tango',
        'Cumbia',
        'Samba',
        'Mambo',
        'Latin Pop',
        'World Fusion',
      ],
    ),
    _category(
      id: 'reggae',
      name: '雷鬼',
      englishName: 'Reggae',
      chineseFontFamily: 'GenreReggaeZh',
      englishFontFamily: 'GenreReggaeEn',
      gradient: const <Color>[Color(0xFF72864A), Color(0xFFD2B96B)],
      primaryColor: const Color(0xFF99A25A),
      children: const <String>[
        'Reggae',
        'Dub',
        'Ska',
        'Dancehall',
        'Rocksteady',
        'Roots Reggae',
        'Lovers Rock',
      ],
    ),
    _category(
      id: 'country',
      name: '乡村',
      englishName: 'Americana',
      chineseFontFamily: 'GenreCountryZh',
      englishFontFamily: 'GenreCountryEn',
      gradient: const <Color>[Color(0xFF8C6C50), Color(0xFFD2AF88)],
      primaryColor: const Color(0xFFB48865),
      children: const <String>[
        'Country',
        'Americana',
        'Alt-Country',
        'Honky Tonk',
        'Bluegrass',
        'Country Pop',
        'Country Rock',
      ],
    ),
    _category(
      id: 'punk',
      name: '朋克',
      englishName: 'Punk',
      chineseFontFamily: 'GenrePunkZh',
      englishFontFamily: 'GenrePunkEn',
      gradient: const <Color>[Color(0xFF5C4B52), Color(0xFFA86E59)],
      primaryColor: const Color(0xFF7E5E58),
      children: const <String>[
        'Punk Rock',
        'Pop Punk',
        'Hardcore Punk',
        'Post-Punk',
        'Emo',
        'Screamo',
        'Garage Punk',
        'Crust Punk',
      ],
    ),
    _category(
      id: 'indie',
      name: '独立',
      englishName: 'Alternative',
      chineseFontFamily: 'GenreIndieZh',
      englishFontFamily: 'GenreIndieEn',
      gradient: const <Color>[Color(0xFF6D6F5B), Color(0xFFB8A88B)],
      primaryColor: const Color(0xFF8A8A71),
      children: const <String>[
        'Indie Pop',
        'Indie Rock',
        'Alt Pop',
        'Alt R&B',
        'Dream Pop',
        'Bedroom Pop',
        'Lo-fi Indie',
        'Noise Pop',
      ],
    ),
    _category(
      id: 'experimental',
      name: '实验',
      englishName: 'Experimental',
      chineseFontFamily: 'GenreExperimentalZh',
      englishFontFamily: 'GenreExperimentalEn',
      gradient: const <Color>[Color(0xFF6A667A), Color(0xFFA7A2C2)],
      primaryColor: const Color(0xFF817D96),
      children: const <String>[
        'Experimental Pop',
        'Avant-garde',
        'Noise',
        'Glitch',
        'Musique Concrète',
        'Art Pop',
        'Industrial',
        'Free Improvisation',
      ],
    ),
    _category(
      id: 'lofi',
      name: 'Lo-fi',
      englishName: 'Chill',
      chineseFontFamily: 'GenreLofiZh',
      englishFontFamily: 'GenreLofiEn',
      gradient: const <Color>[Color(0xFF80939A), Color(0xFFC8BAA8)],
      primaryColor: const Color(0xFF9AA5A3),
      children: const <String>[
        'Lo-fi Hip-Hop',
        'Chillhop',
        'Downtempo',
        'Study Beats',
        'Soft Beats',
        'Chillwave',
        'Trip-Hop',
      ],
    ),
    _category(
      id: 'acg',
      name: '二次元',
      englishName: 'ACG',
      chineseFontFamily: 'GenreACGZh',
      englishFontFamily: 'GenreACGEn',
      gradient: const <Color>[Color(0xFF7E8CB6), Color(0xFFD7BDD9)],
      primaryColor: const Color(0xFF9E9FC8),
      children: const <String>[
        '动漫歌曲',
        'Anime OST',
        'Vocaloid',
        '同人音乐',
        '角色歌',
        'Galgame',
        '偶像企划',
        '虚拟歌手',
      ],
    ),
    _category(
      id: 'opera',
      name: '戏曲',
      englishName: 'Opera',
      chineseFontFamily: 'GenreOperaZh',
      englishFontFamily: 'GenreOperaEn',
      gradient: const <Color>[Color(0xFF9A7059), Color(0xFFD6B49C)],
      primaryColor: const Color(0xFFB58974),
      children: const <String>[
        '京剧',
        '昆曲',
        '越剧',
        '黄梅戏',
        '粤剧',
        '评弹',
        '戏歌',
        '豫剧',
        '秦腔',
      ],
    ),
    _category(
      id: 'newage',
      name: '灵性',
      englishName: 'New Age',
      chineseFontFamily: 'GenreNewAgeZh',
      englishFontFamily: 'GenreNewAgeEn',
      gradient: const <Color>[Color(0xFF7AA39B), Color(0xFFD8E6D3)],
      primaryColor: const Color(0xFF96BBB1),
      children: const <String>[
        'New Age',
        '冥想',
        'Healing',
        'Yoga',
        'Spiritual',
        'Zen Music',
        'Nature Music',
      ],
    ),
    _category(
      id: 'gospel',
      name: '宗教',
      englishName: 'Gospel',
      chineseFontFamily: 'GenreGospelZh',
      englishFontFamily: 'GenreGospelEn',
      gradient: const <Color>[Color(0xFF8B7D66), Color(0xFFE1D0AA)],
      primaryColor: const Color(0xFFB4A07F),
      children: const <String>[
        'Gospel',
        'Choir',
        'Christian Pop',
        'Sacred Music',
        'Chant',
        'Hymn',
      ],
    ),
    _category(
      id: 'industrial',
      name: '工业',
      englishName: 'Industrial',
      chineseFontFamily: 'GenreIndustrialZh',
      englishFontFamily: 'GenreIndustrialEn',
      gradient: const <Color>[Color(0xFF4D555C), Color(0xFF9A8D7F)],
      primaryColor: const Color(0xFF696D6B),
      children: const <String>[
        'Industrial Rock',
        'Industrial Metal',
        'EBM',
        'Power Noise',
        'Dark Electro',
      ],
    ),
    _category(
      id: 'emo',
      name: '情绪核',
      englishName: 'Emo',
      chineseFontFamily: 'GenreEmoZh',
      englishFontFamily: 'GenreEmoEn',
      gradient: const <Color>[Color(0xFF5D5268), Color(0xFFB38FA5)],
      primaryColor: const Color(0xFF836C84),
      children: const <String>[
        'Emo Pop',
        'Midwest Emo',
        'Emo Rap',
        'Screamo',
        'Post-Hardcore',
      ],
    ),
    _category(
      id: 'vocal',
      name: '人声',
      englishName: 'Vocal',
      chineseFontFamily: 'GenreVocalZh',
      englishFontFamily: 'GenreVocalEn',
      gradient: const <Color>[Color(0xFF7C728E), Color(0xFFD4C3E6)],
      primaryColor: const Color(0xFFA390BB),
      children: const <String>[
        'A Cappella',
        '合唱',
        '人声爵士',
        '美声',
        '声乐',
        'Beatbox',
        'Vocal Group',
      ],
    ),
    _category(
      id: 'children',
      name: '儿童',
      englishName: 'Children',
      chineseFontFamily: 'GenreChildrenZh',
      englishFontFamily: 'GenreChildrenEn',
      gradient: const <Color>[Color(0xFFF0A7A0), Color(0xFFF8D9A8)],
      primaryColor: const Color(0xFFF3BC9D),
      children: const <String>[
        '儿歌',
        '童谣',
        '儿童合唱',
        '亲子音乐',
        '动画儿歌',
      ],
    ),
    _category(
      id: 'instrumentalrock',
      name: '器乐摇滚',
      englishName: 'Instrumental Rock',
      chineseFontFamily: 'GenreInstrumentalRockZh',
      englishFontFamily: 'GenreInstrumentalRockEn',
      gradient: const <Color>[Color(0xFF56616D), Color(0xFF9BA7B3)],
      primaryColor: const Color(0xFF73808C),
      children: const <String>[
        'Post-Rock',
        'Math Rock',
        'Surf Rock',
        'Guitar Instrumental',
        'Progressive Instrumental',
      ],
    ),
    _category(
      id: 'mathprog',
      name: '前卫',
      englishName: 'Math / Prog',
      chineseFontFamily: 'GenreMathProgZh',
      englishFontFamily: 'GenreMathProgEn',
      gradient: const <Color>[Color(0xFF4E5C6E), Color(0xFF9E8FA8)],
      primaryColor: const Color(0xFF6F7387),
      children: const <String>[
        'Math Rock',
        'Mathcore',
        'Prog Rock',
        'Prog Metal',
        'Technical Death Metal',
      ],
    ),
    _category(
      id: 'kawaiifuture',
      name: '未来系',
      englishName: 'Kawaii Future',
      chineseFontFamily: 'GenreKawaiiFutureZh',
      englishFontFamily: 'GenreKawaiiFutureEn',
      gradient: const <Color>[Color(0xFFF2A7D8), Color(0xFFA7D8FF)],
      primaryColor: const Color(0xFFCAB1EB),
      children: const <String>[
        'Kawaii Future Bass',
        'Future Core',
        'Hyperpop',
        'Jersey Club',
        'Bubblegum Bass',
      ],
    ),
    _category(
      id: 'hyperpop',
      name: '网络流行',
      englishName: 'Hyperpop',
      chineseFontFamily: 'GenreHyperpopZh',
      englishFontFamily: 'GenreHyperpopEn',
      gradient: const <Color>[Color(0xFFFF6FD8), Color(0xFF8C7BFF)],
      primaryColor: const Color(0xFFC278F1),
      children: const <String>[
        'Hyperpop',
        'Digicore',
        'Glitch Pop',
        'PC Music',
        'Internet Pop',
        'Webcore',
      ],
    ),
  ];

  static final Map<String, GenreCategory> _byId = <String, GenreCategory>{
    for (final category in categories) category.id: category,
    other.id: other,
  };

  static final Map<String, String> _legacyAliases = <String, String>{
    '流行': 'pop',
    'pop': 'pop',
    'r&b': 'rnb',
    '摇滚': 'rock',
    '电子': 'electronic',
    '民谣': 'folk',
    '独立': 'indie',
    '另类': 'indie',
    '爵士': 'jazz',
    '轻音乐': 'lightmusic',
    '纯音乐': 'lightmusic',
    '古风': 'guofeng',
    '国风': 'guofeng',
    '戏腔': 'guofeng',
    '说唱': 'hiphop',
    'rap': 'hiphop',
    'hip-hop': 'hiphop',
    'hip hop': 'hiphop',
    'metal': 'metal',
    'jazz': 'jazz',
    'blues': 'blues',
    'classical': 'classical',
    'ambient': 'ambient',
    'ost': 'ost',
    'club': 'club',
    'funk': 'funk',
    'latin': 'latin',
    'country': 'country',
    'punk': 'punk',
    'lofi': 'lofi',
    'lo-fi': 'lofi',
    'acg': 'acg',
    'new age': 'newage',
    'industrial': 'industrial',
    'emo': 'emo',
    'vocal': 'vocal',
    'children': 'children',
  };

  static GenreCategory categoryById(String id) => _byId[id] ?? other;

  static String encode(String primaryId, [String? secondaryId]) {
    return secondaryId == null || secondaryId.trim().isEmpty
        ? primaryId
        : '$primaryId|$secondaryId';
  }

  static ResolvedGenre resolve(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return ResolvedGenre(rawValue: raw, category: other);
    }

    if (trimmed.contains('|')) {
      final parts = trimmed.split('|');
      final primary = categoryById(parts.first.trim());
      if (parts.length > 1) {
        final subId = parts[1].trim();
        final subTag = primary.children.cast<GenreSubTag?>().firstWhere(
              (item) => item?.id == subId,
              orElse: () => null,
            );
        return ResolvedGenre(
          rawValue: raw,
          category: primary,
          subTag: subTag,
        );
      }
      return ResolvedGenre(rawValue: raw, category: primary);
    }

    final normalized = trimmed.toLowerCase();
    final aliasMatch = _legacyAliases[normalized];
    if (aliasMatch != null) {
      return ResolvedGenre(
        rawValue: raw,
        category: categoryById(aliasMatch),
        isLegacy: true,
      );
    }

    for (final category in categories) {
      if (category.name == trimmed ||
          category.englishName.toLowerCase() == normalized ||
          category.mixedLabel.toLowerCase() == normalized) {
        return ResolvedGenre(
          rawValue: raw,
          category: category,
          isLegacy: true,
        );
      }
      for (final child in category.children) {
        if (child.name.toLowerCase() == normalized) {
          return ResolvedGenre(
            rawValue: raw,
            category: category,
            subTag: child,
            isLegacy: true,
          );
        }
      }
    }

    return ResolvedGenre(rawValue: raw, category: other, isLegacy: true);
  }

  static GenreCategory? maybePrimaryById(String id) => _byId[id];

  static GenreSubTag? subTagById(GenreCategory category, String? subTagId) {
    if (subTagId == null || subTagId.trim().isEmpty) {
      return null;
    }
    final trimmed = subTagId.trim();
    for (final child in category.children) {
      if (child.id == trimmed) {
        return child;
      }
    }
    return null;
  }

  static GenreCategory _category({
    required String id,
    required String name,
    required String englishName,
    required String chineseFontFamily,
    required String englishFontFamily,
    required List<Color> gradient,
    required Color primaryColor,
    required List<String> children,
  }) {
    return GenreCategory(
      id: id,
      name: name,
      englishName: englishName,
      chineseFontFamily: chineseFontFamily,
      englishFontFamily: englishFontFamily,
      gradient: gradient,
      primaryColor: primaryColor,
      children: _children(primaryColor, children),
    );
  }

  static List<GenreSubTag> _children(Color baseColor, List<String> names) {
    return <GenreSubTag>[
      for (var i = 0; i < names.length; i++)
        GenreSubTag(
          id: _normalizedSubId(names[i]),
          name: names[i],
          color: Color.lerp(
                baseColor,
                const Color(0xFFF5F1EA),
                0.16 + (i % 5) * 0.1,
              ) ??
              baseColor,
        ),
    ];
  }

  static String _normalizedSubId(String name) {
    final ascii = name
        .toLowerCase()
        .replaceAll('&', 'and')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    return ascii.isEmpty ? name : ascii;
  }
}
