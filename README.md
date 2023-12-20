<style>
.heading-1{
  font-size: 350%!important;
}
</style>

<h1 class="heading-1"><img align="center" height="100" src="https://user-images.githubusercontent.com/84743905/174507937-c8637dd7-5a10-4c12-bf23-945c7872ace2.png"> Enchanted regex</h1>

Dart [regex api](https://api.flutter.dev/flutter/dart-core/RegExp-class.html) is a good solid base of a modern regex implementation. But it still lacks some more complex functions (such as better manipulating groups) and some auxiliary functions. Because of these "problems", this pacakge was created.

# • 🔗 Group manipulation
The auxiliar funcions and extensions that will help us to manipulate and map the named group in a regex match.

## String extensions


# • 🌟 About `FindedGroup` class. 
✨ This class will be used in the main functions of this package.

This is `the big star` of this package. A class that delivers far away more information about the named group match then normal `Match` or `RegExpMatch` classes. Dart already have named groups. But default funcions are really limited. We don't now when the match of a named group starts/ends. We only now it's content - don't even now what of the named group that content represents (there can be a lot of named groups in each string). For that reason, a lot of the funcions that malipulate will return a more complex object for each match. With more data about that match. That model is the `FindedGroup`.

## Atributes
With FindedGroup class you have access to the following parameters:
- **FindedGroup.name:**<br>
The name of the group founded. A.ka. the name of the group in the regex, what stays inside the `<>`.
- **FindedGroup.content:**<br>
The content string of the named group founded. *Does not* include the data in negative lookahead/lookbehind. 
- **FindedGroup.globalStart:**<br>
Where the `regex match` starts.<br>
⚠️ Note: This is not the index where the group starts,
but where the regex match starts. Thoose values, where
the match stats and where it ends, are inside the
[FindedGroup.start] and [FindedGroup.end] variables.<br>
So, this is equivalent to default dart [Match.start] method.
- **FindedGroup.globalEnd:**<br>
Where the `regex match` ends.<br>
⚠️ Note: This is not the index where the group ends,
but where the regex match ends. Thoose values, where
the match stats and where it ends, are inside the
[FindedGroup.start] and [FindedGroup.end] variables.<br>
So, this is equivalent to default dart [Match.end] method.
- **FindedGroup.start:**<br>
This is the index where the group starts inside the
the regex match. Note, this value **is not** the index where
the regex match starts, but where the `group starts`.<br>
For example: Maybe you are mapping diferent groups inside
the same regex match, so, this value will be the start index
of this group inside the regex match.
- **FindedGroup.end:**<br>
This is the index where the group ends inside the
the regex match. Note, this value **is not** the index where
the regex match ends, but where the `group ends`.<br>
For example: Maybe you are mapping diferent groups inside
the same regex match, so, this value will be the end index
of this group inside the regex match.

## Functions
- **FindedGroup.copyWith():**<br>
Will create a exact copy changing only the parameters you passed in the copyWith function.
 
 # • 🔧 Auxiliar funcions
Functions that will help you with extra features with regex.

## Get the text of a named group.
Get the full text founded in a `RegExpMatch` or even a `Match`. 
<br>PS: Yes, dart dosen't have this really simple funcion by default in it's Regex api...
```dart
final String source = 'Hello, my name is <name>';
final RegExp regex = RegExp(r'(?<name>\w+)');
final RegExpMatch? match = regex.firstMatch(source);
print(match?.text); // .text atribute
```

## Regex `copyWith` added.
A default implementation of copyWith for RegExp.

This method is used to create a new RegExp with the same
properties of the original, but with the given values replaced.
```dart
final regex = RegExp(r'(?<name>\w+)');
final newRegex = regex.copyWith(caseSensitive: false);
```

## Print list of matches
Use extensions to quickly print and see all matches.
You can `printList` and `printListWithLineBreak`.
```dart
final String source = 'Hello, my name is <name>';
final RegExp regex = RegExp(r'(?<name>\w+)');
final Iterable<RegExpMatch> matchs = regex.allMatches(source);

matchs.printListWithLineBreak();
matchs.printList();
```