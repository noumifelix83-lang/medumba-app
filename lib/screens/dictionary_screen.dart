import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';
import '../services/medumba_audio_service.dart';
import '../services/syllable_audio.dart';

class _Entry {
  final String medumba, fr;
  const _Entry(this.medumba, this.fr);
}

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});
  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  bool _isFr = true;
  bool _searchFr = true;
  String _query = '';
  final _ctrl = TextEditingController();
  List<_Entry> _dict = [];
  bool _loading = true;
  String? _speaking;

  @override
  void initState() {
    super.initState();
    _loadDict();
  }

  Future<void> _playEntry(String medumba) async {
    setState(() => _speaking = medumba);
    await MedumbaAudioService.instance.playWord(medumba);
    if (mounted) setState(() => _speaking = null);
  }

  Future<void> _loadDict() async {
    await SyllableAudio.instance.ensureLoaded();
    final raw = await rootBundle.loadString('assets/data/dictionary.json');
    final list = json.decode(raw) as List<dynamic>;
    if (!mounted) return;
    setState(() {
      _dict = list
          .map((e) => _Entry(e['medumba'] as String, e['french'] as String))
          .where((e) => SyllableAudio.instance.hasRealVoice(e.medumba))
          .toList();
      _loading = false;
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    MedumbaAudioService.instance.stop();
    super.dispose();
  }

  List<_Entry> get _results {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _dict;
    return _dict.where((e) {
      final haystack = (_searchFr ? e.fr : e.medumba).toLowerCase();
      return haystack.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF7C3AED);
    final results = _results;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(_isFr ? 'Dictionnaire' : 'Dictionary',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: kInk)),
        actions: [
          TextButton(
            onPressed: () => setState(() => _isFr = !_isFr),
            child: Text(_isFr ? 'EN' : 'FR',
                style: const TextStyle(color: kBlue, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              // ── Barre de recherche ────────────────────────────────────
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(children: [
                  TextField(
                    controller: _ctrl,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: _searchFr
                          ? (_isFr ? 'Chercher en français…' : 'Search in French…')
                          : (_isFr ? 'Chercher en Medumba…' : 'Search in Medumba…'),
                      hintStyle: const TextStyle(color: kMuted, fontSize: 14),
                      prefixIcon: const Icon(Icons.search_rounded, color: kMuted),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, color: kMuted, size: 18),
                              onPressed: () { _ctrl.clear(); setState(() => _query = ''); })
                          : null,
                      filled: true, fillColor: const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    _DirBtn(label: _isFr ? 'Français → Medumba' : 'French → Medumba',
                        active: _searchFr, color: accent,
                        onTap: () => setState(() { _searchFr = true; })),
                    const SizedBox(width: 8),
                    _DirBtn(label: _isFr ? 'Medumba → Français' : 'Medumba → French',
                        active: !_searchFr, color: accent,
                        onTap: () => setState(() { _searchFr = false; })),
                  ]),
                ]),
              ),
              // ── Compteur ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(children: [
                  Text('${results.length} ${_isFr ? "résultat(s)" : "result(s)"}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kMuted)),
                  const Spacer(),
                  Text('${_dict.length} ${_isFr ? "mots" : "words"} au total',
                      style: const TextStyle(fontSize: 11, color: kMuted)),
                ]),
              ),
              // ── Liste ─────────────────────────────────────────────────
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemCount: results.length,
                  itemBuilder: (_, i) {
                    final e = results[i];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: kBorder),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 1))],
                      ),
                      child: Row(children: [
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(e.medumba,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: accent)),
                            const SizedBox(height: 2),
                            Text(e.fr,
                                style: const TextStyle(fontSize: 13, color: kMuted, fontWeight: FontWeight.w500)),
                          ]),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('MD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: accent.withValues(alpha: 0.7))),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => _playEntry(e.medumba),
                          child: Container(
                            width: 34, height: 34,
                            decoration: BoxDecoration(
                              color: _speaking == e.medumba ? accent.withValues(alpha: 0.12) : const Color(0xFFF8FAFC),
                              border: Border.all(color: _speaking == e.medumba ? accent : kBorder, width: 1.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _speaking == e.medumba ? Icons.volume_up : Icons.volume_down,
                              size: 17,
                              color: accent,
                            ),
                          ),
                        ),
                      ]),
                    );
                  },
                ),
              ),
            ]),
    );
  }
}

class _DirBtn extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;
  const _DirBtn({required this.label, required this.active, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active ? color : Colors.white,
          border: Border.all(color: active ? color : kBorder),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label, textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                color: active ? Colors.white : kMuted)),
      ),
    ),
  );
}
