import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'syllable_audio.dart';

/// Lecture audio Medumba : mélange vrais enregistrements de syllabes et
/// synthèse vocale mot par mot selon ce qui est couvert, plutôt que
/// d'abandonner toute la phrase dès qu'un seul mot manque.
///
/// Porté depuis src/utils/medumbaAudio.js (app web) — sans le manifeste
/// STORAGE_FILES historique (mots "exacts") ni les clips de nombres
/// pré-découpés, qui n'ont pas d'équivalent utile ici.
class MedumbaAudioService {
  MedumbaAudioService._();
  static final MedumbaAudioService instance = MedumbaAudioService._();

  final AudioPlayer _player = AudioPlayer();
  final FlutterTts _tts = FlutterTts();
  bool _ttsReady = false;
  int _playToken = 0;

  Future<void> _ensureTts() async {
    if (_ttsReady) return;
    await _tts.awaitSpeakCompletion(true);
    _ttsReady = true;
  }

  /// Stoppe toute lecture (clip réel ou TTS) en cours immédiatement.
  Future<void> stop() async {
    _playToken++; // invalide toute boucle de lecture en cours
    try { await _player.stop(); } catch (_) {}
    try { await _tts.stop(); } catch (_) {}
  }

  Future<bool> _playUrlAndWait(String url) async {
    try {
      await _player.setUrl(url);
    } catch (_) {
      return false;
    }
    final done = Completer<void>();
    late final StreamSubscription sub;
    sub = _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed && !done.isCompleted) {
        sub.cancel();
        done.complete();
      }
    });
    try {
      await _player.play();
    } catch (_) {
      await sub.cancel();
      if (!done.isCompleted) done.complete();
      return false;
    }
    await done.future;
    return true;
  }

  /// Joue un clip audio précis (URL Supabase Storage) directement, sans
  /// passer par la segmentation — utilisé quand l'utilisateur sélectionne
  /// explicitement un ton donné dans le Syllabaire.
  Future<bool> playUrl(String url) async {
    final myToken = ++_playToken;
    try { await _player.stop(); } catch (_) {}
    try { await _tts.stop(); } catch (_) {}
    if (myToken != _playToken) return false;
    return _playUrlAndWait(url);
  }

  Future<void> _speak(String text) async {
    await _ensureTts();
    try {
      await _tts.setLanguage('fr-FR');
      await _tts.setSpeechRate(0.42);
      await _tts.speak(text);
    } catch (_) {}
  }

  /// Joue un mot ou une phrase Medumba. Les syllabes couvertes par un vrai
  /// enregistrement sont enchaînées ; les mots non couverts basculent en
  /// synthèse vocale individuellement, sans faire échouer toute la phrase.
  /// Repli sur une synthèse vocale de la phrase entière si rien n'est
  /// couvert du tout. `onStart` est appelé dès que la lecture démarre
  /// (pour l'indicateur visuel côté appelant).
  Future<void> playWord(String word, {VoidCallback? onStart}) async {
    if (word.trim().isEmpty) return;
    final myToken = ++_playToken;
    try { await _player.stop(); } catch (_) {}
    try { await _tts.stop(); } catch (_) {}

    await SyllableAudio.instance.ensureLoaded();
    if (myToken != _playToken) return; // supplanté par un appel plus récent

    final items = SyllableAudio.instance.segmentPhraseLenient(word);
    onStart?.call();

    if (items == null) {
      await _speak(word);
      return;
    }

    for (final item in items) {
      if (myToken != _playToken) return;
      if (item.isAudio) {
        final m = item.audio!;
        final url = SyllableAudio.instance.toneAudioUrl(m.root, m.tone);
        await _playUrlAndWait(url); // clip manquant : on continue au suivant
      } else {
        await _speak(item.tts!);
      }
    }
  }
}
