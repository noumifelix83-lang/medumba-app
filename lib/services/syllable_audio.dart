import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Segmentation d'un mot/phrase Medumba en syllabes enregistrées (bas/moyen/
/// montant/descendant/neutre), pour lire les mots avec les vrais
/// enregistrements plutôt que la synthèse vocale.
///
/// Porté depuis src/utils/syllableAudio.js (app web). La clé d'objet
/// Supabase Storage est l'encodage hexadécimal UTF-8 de la syllabe (les
/// caractères IPA comme ŋ, ɛ, α, ə, ʉ, ' sont refusés tels quels par
/// Supabase Storage).
///
/// Seules les syllabes de recorded_syllables.json ont un enregistrement réel
/// (sur les 1147 de syllable_tons.json) : sans ce filtre, une syllabe
/// pourrait matcher le texte sans que son audio existe.
class ToneMatch {
  final String root;
  final String tone; // 'bas' | 'moyen' | 'montant' | 'descendant' | 'neutre'
  const ToneMatch(this.root, this.tone);
}

/// Un segment de lecture : soit un clip audio réel (ToneMatch), soit un
/// texte à lire en synthèse vocale (segmentPhraseLenient uniquement).
class PlaySegment {
  final ToneMatch? audio;
  final String? tts;
  const PlaySegment.audio(ToneMatch m) : audio = m, tts = null;
  const PlaySegment.tts(String text) : audio = null, tts = text;
  bool get isAudio => audio != null;
}

const _toneKeys = ['bas', 'moyen', 'montant', 'descendant'];
final _nasalPrefixRe = RegExp(r'^[nmŋ][̀-ͯ᷀-᷿]?', caseSensitive: false);

class SyllableAudio {
  SyllableAudio._();
  static final SyllableAudio instance = SyllableAudio._();

  bool _loaded = false;
  Future<void>? _loading;
  final Map<String, ToneMatch> _toneVariantMap = {};
  final Map<String, Map<String, String>> _tonsByRoot = {};
  final Set<String> _recordedSet = {};

  /// Les 4 tons (bas/moyen/montant/descendant) + ipa pour une syllabe
  /// donnée, ou null si cette syllabe n'a pas d'enregistrement réel.
  Map<String, String>? tonsFor(String syllable) => _tonsByRoot[syllable.toLowerCase()];

  bool hasRecording(String syllable) => _recordedSet.contains(syllable.toLowerCase());

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    if (_loading != null) return _loading;
    _loading = _load();
    await _loading;
  }

  Future<void> _load() async {
    final tonsRaw = await rootBundle.loadString('assets/data/syllable_tons.json');
    final recordedRaw = await rootBundle.loadString('assets/data/recorded_syllables.json');
    final tons = json.decode(tonsRaw) as List<dynamic>;
    final recorded = (json.decode(recordedRaw) as List<dynamic>)
        .map((s) => (s as String).toLowerCase())
        .toSet();

    _recordedSet.addAll(recorded);

    for (final entry in tons) {
      final map = entry as Map<String, dynamic>;
      final root = (map['syllable'] as String).toLowerCase();
      if (!recorded.contains(root)) continue;
      for (final tone in _toneKeys) {
        final variant = map[tone] as String?;
        if (variant != null && variant.isNotEmpty) {
          _toneVariantMap[variant.toLowerCase()] = ToneMatch(map['syllable'] as String, tone);
        }
      }
      // Forme neutre (sans marque de ton) : beaucoup de mots du lexique
      // n'indiquent pas le ton explicitement. Correspond au segment
      // d'annonce de l'enregistrement original (avant les 4 tons).
      _toneVariantMap[root] = ToneMatch(map['syllable'] as String, 'neutre');

      _tonsByRoot[root] = {
        'ipa': map['ipa'] as String? ?? '',
        'bas': map['bas'] as String? ?? '',
        'moyen': map['moyen'] as String? ?? '',
        'montant': map['montant'] as String? ?? '',
        'descendant': map['descendant'] as String? ?? '',
      };
    }
    _loaded = true;
  }

  String toHexKey(String str) {
    final bytes = utf8.encode(str);
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  String syllableAudioUrl(String syllable) => Supabase.instance.client.storage
      .from('medumba-audio')
      .getPublicUrl('syllabes/${toHexKey(syllable)}.ogg');

  String toneAudioUrl(String syllable, String tone) => Supabase.instance.client.storage
      .from('medumba-audio')
      .getPublicUrl('syllabes/${toHexKey(syllable)}_$tone.ogg');

  // Backtracking mémoïsé : essaie tous les découpages possibles plutôt que
  // de s'engager sur le plus long match glouton (qui peut mener à une
  // impasse, ex: "tumə" -> "tum"+"ə"(invalide) alors que "tu"+"mə" fonctionne).
  List<ToneMatch>? _segmentSyllables(String str, Map<String, List<ToneMatch>?> memo) {
    if (str.isEmpty) return const [];
    if (memo.containsKey(str)) return memo[str];
    List<ToneMatch>? result;
    for (var len = str.length < 8 ? str.length : 8; len >= 1; len--) {
      final candidate = str.substring(0, len);
      final match = _toneVariantMap[candidate];
      if (match != null) {
        final rest = _segmentSyllables(str.substring(len), memo);
        if (rest != null) {
          result = [match, ...rest];
          break;
        }
      }
    }
    memo[str] = result;
    return result;
  }

  List<ToneMatch>? _segmentToken(String token) {
    final w = token.toLowerCase();
    final direct = _segmentSyllables(w, {});
    if (direct != null) return direct;
    final m = _nasalPrefixRe.matchAsPrefix(w);
    if (m != null && m.end < w.length) {
      final rest = _segmentSyllables(w.substring(m.end), {});
      if (rest != null) return rest; // préfixe nasal ignoré (pas de clip dédié)
    }
    return null;
  }

  List<String> _tokenize(String phrase) {
    return phrase
        .split(RegExp(r"[\s,.;:!?()/]+"))
        .where((t) => t.isNotEmpty)
        .map((t) => t.replaceAll('’', "'").replaceAll('‘', "'"))
        .toList();
  }

  /// Découpe une phrase entière en clips à jouer, ou null si un seul mot est
  /// impossible à décomposer avec les syllabes enregistrées (tout-ou-rien).
  List<ToneMatch>? segmentPhrase(String phrase) {
    final tokens = _tokenize(phrase);
    if (tokens.isEmpty) return null;
    final segments = <ToneMatch>[];
    for (final token in tokens) {
      final result = _segmentToken(token);
      if (result == null) return null;
      segments.addAll(result);
    }
    return segments;
  }

  /// Découpe "tolérante" : un mot non couvert ne fait pas échouer toute la
  /// phrase — il est marqué pour la synthèse vocale, le reste garde la
  /// vraie voix. Ne renvoie null que si RIEN n'est couvert (dans ce cas une
  /// seule synthèse vocale de la phrase entière sonne mieux qu'un TTS mot
  /// par mot haché).
  List<PlaySegment>? segmentPhraseLenient(String phrase) {
    final tokens = _tokenize(phrase);
    if (tokens.isEmpty) return null;
    final items = <PlaySegment>[];
    var anyAudio = false;
    for (final token in tokens) {
      final result = _segmentToken(token);
      if (result != null) {
        anyAudio = true;
        items.addAll(result.map((m) => PlaySegment.audio(m)));
      } else {
        items.add(PlaySegment.tts(token));
      }
    }
    return anyAudio ? items : null;
  }
}
