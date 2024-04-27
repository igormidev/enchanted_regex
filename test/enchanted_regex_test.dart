import 'package:enchanted_regex/enchanted_regex.dart';
import 'package:test/test.dart';

void main() {
  test('Should display forEachNamedGroup context text as expected ', () {
    final RegExp regExp = RegExp(r'{{[#\/]?(?<name>[a-zA-Z]+?)}}');
    final String source = '''Hello, {{name}}.

{{}}jasdjas kl {d{}} {{}} djdsamd {{}}s ajskdj {{}}''';

    final List<String> output = [];
    source.forEachNamedGroup(
      regExp,
      onMatch: (group) {
        output.add(group.content);
        // print('match "${group.content}"');
      },
      onNonMatch: (text) {
        output.add(text.content);
        // print('non match "${text.content}"');
      },
      willContainBeforeAndAfterContentAsNonMatch: false,
    );

    expect(output, [
      'Hello, ',
      'name',
      '''.

{{}}jasdjas kl {d{}} {{}} djdsamd {{}}s ajskdj {{}}'''
    ]);
  });

  test(
      'Should display forEachNamedGroup non match init and end index as expected ',
      () {
    final RegExp regExp = RegExp(r'{{[#\/]?(?<name>[a-zA-Z]+?)}}');
    final String source =
        '''Hello, {{name}}. Yes, my name is {{name}}. What about yours?''';

    final List<String> output = [];
    source.forEachNamedGroup(
      regExp,
      onMatch: (group) {
        output.add(group.content);
      },
      onNonMatch: (text) {
        output.add(
          source.substring(text.globalStart, text.globalEnd),
        );
      },
      willContainBeforeAndAfterContentAsNonMatch: false,
    );
    print('["${output.join('"]["')}"]');
    expect(output, [
      'Hello, ',
      'name',
      '. Yes, my name is ',
      'name',
      '. What about yours?',
    ]);
  });
}
