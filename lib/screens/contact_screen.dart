import 'package:flutter/material.dart';
import '../services/contact_service.dart';

const _faq = [
  [
    "L'application est-elle gratuite ?", 'Is the app free?',
    '100% gratuite pour le lancement — toutes les leçons, le dictionnaire, le comptage et les vidéos sont accessibles sans frais.',
    '100% free for the launch — all lessons, the dictionary, counting and videos are available at no cost.',
  ],
  [
    'Comment prendre un cours avec un enseignant ?', 'How do I book a class with a teacher?',
    'Rendez-vous dans la section Classes de la landing page web et contactez directement un enseignant certifié CEPOM.',
    'Go to the Classes section on the web landing page and contact a CEPOM-certified teacher directly.',
  ],
  [
    "Qu'est-ce que le CEPOM ?", 'What is CEPOM?',
    "L'organisme partenaire qui certifie les enseignants de l'application.",
    'The partner organization that certifies the teachers on the app.',
  ],
  [
    'Sur quelles plateformes est disponible Medumba.AI ?', 'What platforms is Medumba.AI available on?',
    "L'application est disponible sur navigateur web et sur Android dès maintenant ; iOS arrive bientôt.",
    'The app is available in your web browser and on Android right now; iOS is coming soon.',
  ],
];

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});
  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  bool _isFr = true;
  int? _openFaq;
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  String _status = 'idle'; // idle | sending | sent | error

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty || _emailCtrl.text.trim().isEmpty || _messageCtrl.text.trim().isEmpty) return;
    setState(() => _status = 'sending');
    final ok = await ContactService.submitMessage(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      message: _messageCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _status = ok ? 'sent' : 'error');
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF0056D2);
    const ink = Color(0xFF0F172A);
    const muted = Color(0xFF64748B);
    const sand = Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(96),
        child: Container(
          color: blue,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
              child: Row(children: [
                IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.of(context).pop()),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_isFr ? 'AIDE' : 'HELP',
                      style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                  Text(_isFr ? '💬 Contact & FAQ' : '💬 Contact & FAQ',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                ])),
                TextButton(
                  onPressed: () => setState(() => _isFr = !_isFr),
                  child: Text(_isFr ? 'EN' : 'FR', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                ),
              ]),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // FAQ
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: sand, width: 1.5)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('FAQ', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: ink)),
              const SizedBox(height: 8),
              ...List.generate(_faq.length, (i) {
                final f = _faq[i];
                final open = _openFaq == i;
                return Column(children: [
                  InkWell(
                    onTap: () => setState(() => _openFaq = open ? null : i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(children: [
                        Expanded(child: Text(_isFr ? f[0] : f[1], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: ink))),
                        Icon(open ? Icons.remove : Icons.add, size: 18, color: muted),
                      ]),
                    ),
                  ),
                  if (open)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(_isFr ? f[2] : f[3], style: const TextStyle(fontSize: 12.5, color: muted, height: 1.6)),
                    ),
                  if (i < _faq.length - 1) Divider(height: 1, color: sand),
                ]);
              }),
            ]),
          ),
          const SizedBox(height: 14),

          // Contact form
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: sand, width: 1.5)),
            child: _status == 'sent'
                ? Column(children: [
                    const Text('✅', style: TextStyle(fontSize: 32)),
                    const SizedBox(height: 8),
                    Text(_isFr ? 'Message envoyé, merci !' : 'Message sent, thank you!',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: ink)),
                  ])
                : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_isFr ? 'Nous contacter' : 'Contact us',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: ink)),
                    const SizedBox(height: 12),
                    TextField(controller: _nameCtrl, decoration: InputDecoration(hintText: _isFr ? 'Nom' : 'Name', border: const OutlineInputBorder())),
                    const SizedBox(height: 10),
                    TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'Email', border: OutlineInputBorder())),
                    const SizedBox(height: 10),
                    TextField(controller: _phoneCtrl, keyboardType: TextInputType.phone, decoration: InputDecoration(hintText: _isFr ? 'Téléphone (optionnel)' : 'Phone (optional)', border: const OutlineInputBorder())),
                    const SizedBox(height: 10),
                    TextField(controller: _messageCtrl, maxLines: 4, decoration: InputDecoration(hintText: _isFr ? 'Votre message' : 'Your message', border: const OutlineInputBorder())),
                    const SizedBox(height: 12),
                    if (_status == 'error')
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(_isFr ? "Erreur d'envoi. Réessayez." : 'Failed to send. Please try again.',
                            style: const TextStyle(color: Colors.red, fontSize: 12)),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _status == 'sending' ? null : _submit,
                        style: ElevatedButton.styleFrom(backgroundColor: blue, padding: const EdgeInsets.symmetric(vertical: 14)),
                        child: Text(_status == 'sending' ? (_isFr ? 'Envoi…' : 'Sending…') : (_isFr ? 'Envoyer' : 'Send'),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ]),
          ),
        ],
      ),
    );
  }
}
