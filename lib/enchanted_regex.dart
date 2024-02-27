library;

import 'dart:developer';
import 'package:enchanted_collection/enchanted_collection.dart';

extension MatchExtension on Match {
  /// Return's the text of the match.
  /// This is, the text beetween [Match.start] and [Match.end] indexes.
  String get text => input.substring(start, end);
}

extension EnchantedStringRegexExtension on String {
  /// Similar to [String.replaceAllMapped], but using
  /// [FindedGroup] instead of [Match] on "onMatch" function.
  String replaceAllNamedGroups(
    RegExp regex, {
    required String Function(FindedGroup group) onMatch,
  }) {
    String output = this;

    final matchs = regex.allMatches(this);
    matchs.toList().reversed.toList().forEach((final RegExpMatch match) {
      final namedGroups = match.groupsStats(regex.pattern);
      for (final FindedGroup namedGroup in namedGroups.reversed) {
        final response = output.replaceRange(
          namedGroup.globalStart,
          namedGroup.globalEnd,
          onMatch(namedGroup),
        );
        output = response;
      }
    });

    return output;
  }

  /// Really close to what [forEachNamedGroup] does, but
  /// with more parameters to help you to know where you are
  /// in the list loop iteration.<br>
  /// Such as:
  /// - **bool** - isFirst<br>
  /// Returns `true` if it is the first index
  /// - **bool** - isLast<br>
  /// Returns `true` if it is the last index
  /// - **int** - index<br>
  /// The index of the current iteration
  /// - **int** - matchsFinded<br>
  /// The total number of matchs finded in the string
  /// - **int** - groupsInCurrentMatch<br>
  /// The total number of groups finded in the current match. This
  /// is because you can have more than one match in the string.
  /// - **int** - currentIndexInsideMatchsFindedLoop<br>
  /// The "global index" of the [groupsInCurrentMatch].
  void forEachNamedGroupMapper(
    final RegExp regex, {
    required final void Function(
      FindedGroup group,
      bool isFirst,
      bool isLast,
      int index,
      int matchsFinded,
      int groupsInCurrentMatch,
      int currentIndexInsideMatchsFindedLoop,
    ) onGroupFind,
  }) {
    final matchs = regex.allMatches(this);

    matchs.toList().forEachMapper((
      final RegExpMatch match,
      final bool isFirst,
      final bool isLast,
      final int index,
    ) {
      final namedGroups = match.groupsStats(regex.pattern);
      for (final entry in namedGroups.asMap().entries) {
        onGroupFind(entry.value, isFirst, isLast, index, matchs.length,
            namedGroups.length, entry.key);
      }
    });
  }

  /// Similar to `splitMapJoin`, but instead of returning a
  /// string will return whatever you want. So for each match or
  /// non match, you can return the type <T> you wan't. And in the
  /// end of the function, will return a list of the <T>'s you returned.
  List<T> splitMapCast<T>(
    RegExp pattern, {
    required T Function(Match group) onMatch,
    required T Function(String text) onNonMatch,
  }) {
    final List<T> response = [];
    splitMapJoin(pattern, onMatch: (final Match match) {
      onMatch(match);
      return '';
    }, onNonMatch: (final String text) {
      response.add(onNonMatch(text));
      return '';
    });
    return response;
  }

  // void forEachNamedGroup

  // void forEachNamedGroup(
  //   RegExp regex, {
  //   required void Function(FindedGroup group) onGroupFind,
  // }) {
  //   final matchs = regex.allMatches(this);
  //   matchs.toList().forEach((final RegExpMatch match) {
  //     final namedGroups = match.groupsStats(regex.pattern);
  //     for (final FindedGroup namedGroup in namedGroups) {
  //       onGroupFind(namedGroup);
  //     }
  //   });
  // }

  /// For each named group found in the text with the
  /// [regex], will call the [onGroupFind] with the [FindedGroup].
  void forEachNamedGroup(
    RegExp regex, {
    required void Function(FindedGroup group) onMatch,
    void Function(String text)? onNonMatch,
  }) {
    int startIndex = 0;
    final matchs = regex.allMatches(this);
    for (final RegExpMatch match in matchs) {
      final firstStart = substring(startIndex, match.start);
      onNonMatch?.call(firstStart);
      final findedGroups = match.groupsStats(regex.pattern);

      int groupStartIndex = 0;

      for (final FindedGroup group in findedGroups) {
        final fullText = group.fullMatchText;

        final beforeMatchString =
            fullText.substring(groupStartIndex, group.start);
        if (beforeMatchString.isNotEmpty) {
          onNonMatch?.call(beforeMatchString);
        }
        onMatch(group);
        groupStartIndex = group.end;

        /// Rest of string that dosent include match
        final String afterMatchString = fullText.substring(group.end);
        if (afterMatchString.isNotEmpty) {
          onNonMatch?.call(afterMatchString);
        }
      }

      startIndex = match.end;
    }

    onNonMatch?.call(substring(startIndex));
  }

  /// Equal to [splitMapCast], but instead of [onMatch] using
  /// a [Match] class will use a [FindedGroup] class.
  List<T> splitMapNamedGroupCast<T>(
    RegExp regex, {
    required T Function(FindedGroup group) onMatch,
    required T Function(String text) onNonMatch,
  }) {
    final List<T> items = [];
    int startIndex = 0;
    final matchs = regex.allMatches(this);
    for (final RegExpMatch match in matchs) {
      final firstStart = substring(startIndex, match.start);
      items.add(onNonMatch(firstStart));
      final findedGroups = match.groupsStats(regex.pattern);

      int groupStartIndex = 0;

      for (final FindedGroup group in findedGroups) {
        final fullText = group.fullMatchText;

        final beforeMatchString =
            fullText.substring(groupStartIndex, group.start);
        if (beforeMatchString.isNotEmpty) {
          items.add(onNonMatch(beforeMatchString));
        }
        items.add(onMatch(group));
        groupStartIndex = group.end;

        /// Rest of string that dosent include match
        final String afterMatchString = fullText.substring(group.end);
        if (afterMatchString.isNotEmpty) {
          items.add(onNonMatch(afterMatchString));
        }
      }

      startIndex = match.end;
    }

    items.add(onNonMatch(substring(startIndex)));
    return items;
  }

  List<T> mapSeparateStats<T>(
    List<FindedGroup> groups, {
    required T Function(FindedGroup group) onMatch,
    required T Function(String text) onNonMatch,
  }) {
    if (groups.isEmpty) return [onNonMatch(this)];

    final List<T> items = [];
    int currentIndex = 0;
    for (final group in groups) {
      final text = substring(currentIndex, group.start);
      items.add(onNonMatch(text));
      items.add(onMatch(group));

      currentIndex = group.globalEnd;
    }

    items.add(onNonMatch(substring(currentIndex)));

    return items;
  }
}

extension RegexExtension on RegExp {
  /// A default implementation of copyWith for [RegExp].
  ///
  /// This method is used to create a new [RegExp] with the same
  /// properties of the original, but with the given values replaced.
  ///
  /// Example:
  /// ```dart
  /// final regex = RegExp(r'(?<name>\w+)');
  /// final newRegex = regex.copyWith(caseSensitive: false);
  /// ```
  RegExp copyWith({
    String? pattern,
    bool? multiLine,
    bool? caseSensitive,
    bool? unicode,
    bool? dotAll,
  }) {
    return RegExp(
      pattern ?? this.pattern,
      multiLine: multiLine ?? isMultiLine,
      caseSensitive: caseSensitive ?? isCaseSensitive,
      unicode: unicode ?? isUnicode,
      dotAll: dotAll ?? isDotAll,
    );
  }
}

extension EnchantedRegexExtension on RegExpMatch {
  /// Used to get the [FindedGroup] in a match.
  ///
  /// Used internally in the enchated_regex package in multiple functions.
  List<FindedGroup> groupsStats(final String patternUsed) {
    final List<FindedGroup> findedGroups = [];

    for (final String groupName in groupNames) {
      final identifierString = r'\((\?|\\k)<' + groupName;
      final regexIdentifier = RegExp(identifierString);

      final matchs = regexIdentifier.allMatches(patternUsed);
      for (final RegExpMatch match in matchs) {
        final splitIndex = match.start;
        final firstPart = patternUsed.substring(0, splitIndex);
        final secondPart = patternUsed.substring(splitIndex);

        // The second part will be a look ahead
        final lockPattern = '$firstPart(?=$secondPart)';
        final lockAheadRegex = RegExp(lockPattern, multiLine: true);

        final capturedTextByRegex = input.substring(this.start, this.end);
        final response = lockAheadRegex.firstMatch(capturedTextByRegex)!;

        final String groupContent = namedGroup(groupName)!;
        final int start = response.text.length;
        final int end = response.text.length + groupContent.length;

        final group = FindedGroup(
          content: groupContent,
          fullMatchText: text,
          name: groupName,
          start: start,
          end: end,
          globalStart: this.start + start,
          globalEnd: this.start + end,
        );

        findedGroups.add(group);
      }
    }
    findedGroups.sort((a, b) => a.globalStart.compareTo(b.globalStart));

    return findedGroups;
  }
}

extension FindedGroupListExtension on List<FindedGroup> {
  /// Will return the first group with the name passed in the parameter.
  FindedGroup? whereGroupName(String name) =>
      singleWhereOrNull((element) => element.name == name);
}

/// This is the big star of this package. A class that delivers far away more information about the named group match then normal `Match` or `RegExpMatch` classes.
class FindedGroup {
  /// The name of the group founded. A.ka. the name of the group in the regex, what stays inside the `<>`.
  final String name;

  /// The content string of the named group founded.
  final String content;

  /// This is the index where the group starts inside the
  /// the regex match. Note, this value **is not** the index where
  /// the regex match starts, but where the `group starts`.
  ///
  /// For example: Maybe you are mapping diferent groups inside
  /// the same regex match, so, this value will be the start index
  /// of this group inside the regex match.
  final int start;

  /// This is the index where the group ends inside the
  /// the regex match. Note, this value **is not** the index where
  /// the regex match ends, but where the `group ends`.
  ///
  /// For example: Maybe you are mapping diferent groups inside
  /// the same regex match, so, this value will be the end index
  /// of this group inside the regex match.
  final int end;

  /// Where the `regex match` starts.<br>
  /// ⚠️ Note: This is not the index where the group starts,
  /// but where the regex match starts. Thoose values, where
  /// the match stats and where it ends, are inside the
  /// [FindedGroup.start] and [FindedGroup.end] variables.
  ///
  /// So, this is equivalent to default dart [Match.start] method.
  final int globalStart;

  /// Where the `regex match` ends.<br>
  /// ⚠️ Note: This is not the index where the group ends,
  /// but where the regex match ends. Thoose values, where
  /// the match stats and where it ends, are inside the
  /// [FindedGroup.start] and [FindedGroup.end] variables.
  ///
  /// So, this is equivalent to default dart [Match.end] method.
  final int globalEnd;

  /// The full match of the named group.
  /// Not only the group content, but the full match of the regex.
  final String fullMatchText;

  /// This is the big star of this package. A class that delivers far away more information about the named group match then normal `Match` or `RegExpMatch` classes.
  const FindedGroup({
    required this.name,
    required this.content,
    required this.fullMatchText,
    required this.start,
    required this.end,
    required this.globalStart,
    required this.globalEnd,
  });

  @override
  String toString() {
    return 'FindedGroup(name: $name, start: $start, end: $end, globalStart: $globalStart, globalEnd: $globalEnd, content: $content)';
  }

  /// Will create a exact copy changing only the parameters you passed in the copyWith function.
  FindedGroup copyWith({
    String? name,
    String? content,
    String? fullMatchText,
    int? start,
    int? end,
    int? globalStart,
    int? globalEnd,
  }) {
    return FindedGroup(
      name: name ?? this.name,
      content: content ?? this.content,
      fullMatchText: fullMatchText ?? this.fullMatchText,
      start: start ?? this.start,
      end: end ?? this.end,
      globalStart: globalStart ?? this.globalStart,
      globalEnd: globalEnd ?? this.globalEnd,
    );
  }
}

extension MatchListExtension on Iterable<Match> {
  /// Will print full list of matches but with line break between each match
  void printListWithLineBreak([String prefixMessage = '']) =>
      forEach((element) {
        log(prefixMessage + element.text);
      });

  /// Will print full list of matches
  void printList([String prefixMessage = '']) {
    final list = <String>[];
    forEach((element) {
      list.add('${element.text} ,');
    });
    log('$prefixMessage\n$list');
  }
}
