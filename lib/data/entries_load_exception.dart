/// Erro lançado quando as entradas da forca não podem ser carregadas.
///
/// O carregamento é explícito sobre falhas: JSON malformado, campo ausente,
/// valor fora dos enums ou lista final vazia interrompem a leitura e chegam
/// até a camada de telas e estado nesta exceção, em vez de serem descartados
/// em silêncio.
class EntriesLoadException implements Exception {
  /// Descrição do que impediu o carregamento, em português.
  final String message;

  /// Posição da entrada que causou a falha, quando o problema está em um item
  /// específico da lista. `null` para falhas do carregamento como um todo.
  final int? entryIndex;

  /// Cria uma falha de carregamento.
  ///
  /// [message] explica em português o que deu errado. [entryIndex], quando
  /// informado, aponta a entrada problemática e passa a fazer parte da
  /// descrição produzida por [toString].
  const EntriesLoadException(this.message, {this.entryIndex});

  @override
  String toString() {
    final location = entryIndex == null
        ? ''
        : ' (entrada de índice $entryIndex)';
    return 'EntriesLoadException: $message$location';
  }
}
