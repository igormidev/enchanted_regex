import 'package:enchanted_regex/enchanted_regex.dart';
import 'package:test/test.dart';

void main() {
  test('forEachNamedGroup', () {
    final RegExp regExp = RegExp(r'{{[#\/]?(?<name>[a-zA-Z]+?)}}');
    final String source = '''Hello, {{name}}.

{{}}jasdjas kl {d{}} {{}} djdsamd {{}}s ajskdj {{}}''';

    source.forEachNamedGroup(
      regExp,
      onMatch: (group) {
        print('match "${group.content}"');
      },
      onNonMatch: (text) {
        print('non match "$text"');
      },
      willContainBeforeAndAfterContentAsNonMatch: false,
    );
  });
}
