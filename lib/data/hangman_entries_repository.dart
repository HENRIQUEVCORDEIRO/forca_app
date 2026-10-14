import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../domain/hangman_entry.dart';
import 'entries_load_exception.dart';

abstract class HangmanEntriesRepository {
  Future<List<HangmanEntry>> loadEntries();
}

class AssetHangmanEntriesRepository implements HangmanEntriesRepository {
  final AssetBundle _bundle;
  final String assetPath;

  AssetHangmanEntriesRepository({
    AssetBundle? bundle,
    this.assetPath = 'assets/data/hangman_entries.json',
  }) : _bundle = bundle ?? rootBundle;

  @override
  Future<List<HangmanEntry>> loadEntries() async {
    final content = await _readAsset();
    final decoded = _decode(content);
    final rawEntries = _readEntries(decoded);

    final entries = <HangmanEntry>[];
    for (var i = 0; i < rawEntries.length; i++) {
      final item = rawEntries[i];
      if (item is! Map<String, dynamic>) {
        throw EntriesLoadException(
          'A entrada de índice $i deveria ser um objeto JSON.',
          entryIndex: i,
        );
      }
      try {
        entries.add(HangmanEntry.fromJson(item));
      } on EntriesLoadException catch (error) {
        throw EntriesLoadException(error.message, entryIndex: i);
      }
    }

    if (entries.isEmpty) {
      throw EntriesLoadException('A lista de entradas está vazia.');
    }

    return List.unmodifiable(entries);
  }

  Future<String> _readAsset() async {
    try {
      return await _bundle.loadString(assetPath);
    } catch (error) {
      throw EntriesLoadException(
        'Não foi possível ler o asset "$assetPath": $error',
      );
    }
  }

  dynamic _decode(String content) {
    try {
      return jsonDecode(content);
    } on FormatException catch (error) {
      throw EntriesLoadException(
        'O asset "$assetPath" não contém JSON válido: ${error.message}',
      );
    }
  }

  List<dynamic> _readEntries(dynamic decoded) {
    if (decoded is! Map<String, dynamic>) {
      throw EntriesLoadException(
        'A raiz do asset "$assetPath" deveria ser um objeto JSON.',
      );
    }
    if (!decoded.containsKey('entries')) {
      throw EntriesLoadException(
        'A raiz do asset "$assetPath" não tem a chave "entries".',
      );
    }

    final entries = decoded['entries'];
    if (entries is! List) {
      throw EntriesLoadException(
        'A chave "entries" do asset "$assetPath" deveria ser uma lista.',
      );
    }
    return entries;
  }
}
