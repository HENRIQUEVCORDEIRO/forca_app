import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangman_game/data/entries_load_exception.dart';
import 'package:hangman_game/data/hangman_entries_repository.dart';
import 'package:hangman_game/domain/answer_category.dart';
import 'package:hangman_game/domain/difficulty.dart';

class _FakeAssetBundle extends AssetBundle {
  _FakeAssetBundle(this.content);

  final String? content;

  @override
  Future<ByteData> load(String key) async => throw UnimplementedError();

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final value = content;
    if (value == null) {
      throw StateError('AssetBundle não encontrou "$key".');
    }
    return value;
  }
}

AssetHangmanEntriesRepository _repo(String? json) =>
    AssetHangmanEntriesRepository(bundle: _FakeAssetBundle(json));

const _jsonValido = '''
{"entries":[
 {"answer":"CORAÇÃO","category":"animals","difficulty":"easy","hints":["primeira"]},
 {"answer":"PÉ HUMANO","category":"humanBody","difficulty":"hard","hints":["segunda"]}
]}''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('carregamento válido', () {
    test('converte cada entrada do JSON', () async {
      final entries = await _repo(_jsonValido).loadEntries();

      expect(entries, hasLength(2));
      expect(entries.first.answer, 'CORAÇÃO');
      expect(entries.first.category, AnswerCategory.animals);
      expect(entries.first.difficulty, Difficulty.easy);
      expect(entries.first.requiredLetters, {'C', 'O', 'R', 'A'});
      expect(entries.last.answer, 'PÉ HUMANO');
      expect(entries.last.category, AnswerCategory.humanBody);
      expect(entries.last.difficulty, Difficulty.hard);
    });

    test('a lista retornada é imutável', () async {
      final entries = await _repo(_jsonValido).loadEntries();
      expect(() => entries.removeAt(0), throwsUnsupportedError);
    });

    test('o assetPath padrão é o declarado no pubspec', () {
      expect(
        AssetHangmanEntriesRepository().assetPath,
        'assets/data/hangman_entries.json',
      );
    });
  });

  group('erros do carregamento', () {
    test('asset ausente ou ilegível', () async {
      await expectLater(
        _repo(null).loadEntries(),
        throwsA(
          isA<EntriesLoadException>().having(
            (error) => error.message,
            'message',
            contains('Não foi possível ler o asset'),
          ),
        ),
      );
    });

    test('JSON malformado', () async {
      await expectLater(
        _repo('{"entries": [').loadEntries(),
        throwsA(
          isA<EntriesLoadException>().having(
            (error) => error.message,
            'message',
            contains('não contém JSON válido'),
          ),
        ),
      );
    });

    test('raiz que não é um objeto', () async {
      await expectLater(
        _repo('[1,2,3]').loadEntries(),
        throwsA(
          isA<EntriesLoadException>().having(
            (error) => error.message,
            'message',
            contains('deveria ser um objeto JSON'),
          ),
        ),
      );
    });

    test('raiz sem a chave entries', () async {
      await expectLater(
        _repo('{"outros":[]}').loadEntries(),
        throwsA(
          isA<EntriesLoadException>().having(
            (error) => error.message,
            'message',
            contains('não tem a chave "entries"'),
          ),
        ),
      );
    });

    test('entries que não é uma lista', () async {
      await expectLater(
        _repo('{"entries": {"a": 1}}').loadEntries(),
        throwsA(
          isA<EntriesLoadException>().having(
            (error) => error.message,
            'message',
            contains('deveria ser uma lista'),
          ),
        ),
      );
    });

    test('lista final de entradas vazia', () async {
      await expectLater(
        _repo('{"entries":[]}').loadEntries(),
        throwsA(
          isA<EntriesLoadException>().having(
            (error) => error.message,
            'message',
            contains('A lista de entradas está vazia.'),
          ),
        ),
      );
    });
  });

  group('erros de entrada carregam o índice', () {
    Future<void> falha(String json, int indice, String trecho) async {
      await expectLater(
        _repo(json).loadEntries(),
        throwsA(
          isA<EntriesLoadException>()
              .having((error) => error.message, 'message', contains(trecho))
              .having((error) => error.entryIndex, 'entryIndex', indice),
        ),
      );
    }

    test('entrada que não é um objeto JSON', () {
      return falha('{"entries":["texto"]}', 0, 'deveria ser um objeto JSON');
    });

    test('categoria inválida na segunda entrada', () {
      return falha(
        '{"entries":['
            '{"answer":"A","category":"animals","difficulty":"easy","hints":["a"]},'
            '{"answer":"B","category":"games","difficulty":"easy","hints":["b"]}'
            ']}',
        1,
        'Categoria inválida',
      );
    });

    test('dificuldade inválida', () {
      return falha(
        '{"entries":[{"answer":"A","category":"animals",'
            '"difficulty":"impossible","hints":["a"]}]}',
        0,
        'Dificuldade inválida',
      );
    });

    test('lista de dicas vazia', () {
      return falha(
        '{"entries":[{"answer":"A","category":"animals",'
            '"difficulty":"easy","hints":[]}]}',
        0,
        'lista de dicas está vazia',
      );
    });

    test('campo obrigatório ausente', () {
      return falha(
        '{"entries":[{"answer":"A"}]}',
        0,
        'Campo obrigatório ausente',
      );
    });
  });

  group('asset real', () {
    test('carrega as 120 entradas pela declaração do pubspec', () async {
      final entries = await AssetHangmanEntriesRepository().loadEntries();

      expect(entries, hasLength(120));
      expect(
        entries.map((entry) => entry.category).toSet(),
        AnswerCategory.values.toSet(),
      );
      expect(
        entries.map((entry) => entry.difficulty).toSet(),
        Difficulty.values.toSet(),
      );
    });

    test('todas as entradas têm pistas e letras obrigatórias', () async {
      final entries = await AssetHangmanEntriesRepository().loadEntries();

      for (final entry in entries) {
        expect(entry.hints, isNotEmpty, reason: entry.answer);
        expect(entry.requiredLetters, isNotEmpty, reason: entry.answer);
      }
    });

    test('a decomposição preserva a grafia original', () async {
      final entries = await AssetHangmanEntriesRepository().loadEntries();

      for (final entry in entries) {
        expect(
          entry.characters.map((character) => character.original).join(),
          entry.answer,
          reason: entry.answer,
        );
      }
    });
  });
}
