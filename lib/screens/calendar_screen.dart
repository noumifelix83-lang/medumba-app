import 'package:flutter/material.dart';
import '../theme/colors.dart';

// Calendrier Medumba — semaine de 8 jours (source : METCHEZIN Franklin)

const _monthsMd  = ['Mbwogngà','Nkàgnὰ','Njwìdcu','Ntàŋmbwə','Nsônὰ','Ŋwα̂gnkun','Ntôngə̀fələ','Ncôcu','Njâgcu','Mbə̂\'nswə','Nsônα̌ndɔ','Ntòngǒdməsaŋə'];
const _monthsFr  = ['Janvier','Février','Mars','Avril','Mai','Juin','Juillet','Août','Septembre','Octobre','Novembre','Décembre'];
const _monthsEn  = ['January','February','March','April','May','June','July','August','September','October','November','December'];

const _daysMd = ["Ntα̂nla'", 'Nsigha', "Nsěmntə'", 'Nga', 'Nkɔ̂tʉ', 'Nzìnyam', "Ntα̂nbu'", "Ntα̂ntə'"];
const _daysFr = ['J1','J2','J3','J4','J5','J6','J7','J8'];

const _monthColors = [
  Color(0xFF0056D2), Color(0xFF7C3AED), Color(0xFF0891B2), Color(0xFF16A34A),
  Color(0xFFD97706), Color(0xFFDC2626), Color(0xFF0056D2), Color(0xFF7C3AED),
  Color(0xFF0891B2), Color(0xFF16A34A), Color(0xFFD97706), Color(0xFFDC2626),
];

int _daysInMonth(int year, int month) {
  return DateTime(year, month + 1, 0).day;
}

// Anchor: jeudi 12 mars 2026 = Nga (index 3). offset = 7
int _medumbaDayIndex(int year, int month, int day) {
  final d = DateTime(year, month + 1, day);
  final ms = d.millisecondsSinceEpoch;
  const msPerDay = 86400000;
  return ((ms ~/ msPerDay + 0.5).toInt() + 7) % 8;
}

int _firstDayOfMonth(int year, int month) => _medumbaDayIndex(year, month, 1);

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  bool _isFr = true;
  final _now = DateTime.now();
  late int _year, _month;
  int? _selected;
  String _legend = 'months'; // 'months' | 'days'

  @override
  void initState() {
    super.initState();
    _year  = _now.year;
    _month = _now.month - 1; // 0-indexed
  }

  void _prevMonth() => setState(() {
    if (_month == 0) { _year--; _month = 11; } else _month--;
    _selected = null;
  });
  void _nextMonth() => setState(() {
    if (_month == 11) { _year++; _month = 0; } else _month++;
    _selected = null;
  });

  bool _isToday(int d) =>
    d == _now.day && _month == _now.month - 1 && _year == _now.year;

  @override
  Widget build(BuildContext context) {
    final accent = _monthColors[_month];
    final totalDays = _daysInMonth(_year, _month);
    final firstDay  = _firstDayOfMonth(_year, _month);
    final prevDays  = _daysInMonth(_year, _month == 0 ? 11 : _month - 1);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(_isFr ? 'Calendrier Medumba' : 'Medumba Calendar',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: kInk)),
        actions: [
          TextButton(
            onPressed: () => setState(() => _isFr = !_isFr),
            child: Text(_isFr ? 'EN' : 'FR',
                style: const TextStyle(color: kBlue, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Navigation mois ──────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              border: Border.all(color: accent.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                color: accent, onPressed: _prevMonth,
              ),
              Expanded(child: Column(children: [
                Text(_monthsMd[_month],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: accent)),
                Text('${_isFr ? _monthsFr[_month] : _monthsEn[_month]} $_year',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kMuted)),
              ])),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                color: accent, onPressed: _nextMonth,
              ),
            ]),
          ),
          const SizedBox(height: 14),

          // ── En-têtes jours semaine (8 jours) ─────────────────────
          Row(children: List.generate(8, (i) => Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(_isFr ? _daysFr[i] : _daysMd[i],
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: _isFr ? 11 : 8, fontWeight: FontWeight.w800,
                    color: accent, letterSpacing: 0),
              ),
            ),
          ))),
          const Divider(height: 1),
          const SizedBox(height: 4),

          // ── Grille calendrier ─────────────────────────────────────
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8, mainAxisSpacing: 4, crossAxisSpacing: 4, childAspectRatio: 1,
            ),
            itemCount: firstDay + totalDays,
            itemBuilder: (_, i) {
              if (i < firstDay) {
                final d = prevDays - firstDay + i + 1;
                return Center(child: Text('$d',
                    style: const TextStyle(fontSize: 11, color: Color(0xFFCBD5E1))));
              }
              final day = i - firstDay + 1;
              final today = _isToday(day);
              final sel   = _selected == day;
              return GestureDetector(
                onTap: () => setState(() => _selected = _selected == day ? null : day),
                child: Container(
                  decoration: BoxDecoration(
                    color: today ? accent : (sel ? accent.withValues(alpha: 0.15) : null),
                    borderRadius: BorderRadius.circular(8),
                    border: sel && !today ? Border.all(color: accent, width: 1.5) : null,
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('$day',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700,
                            color: today ? Colors.white : kInk)),
                    if (_isFr)
                      Text(_daysMd[_medumbaDayIndex(_year, _month, day)],
                          style: TextStyle(
                              fontSize: 6, fontWeight: FontWeight.w600,
                              color: today ? Colors.white70 : kMuted)),
                  ]),
                ),
              );
            },
          ),
          const SizedBox(height: 14),

          // ── Info jour sélectionné ─────────────────────────────────
          if (_selected != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.08),
                border: Border.all(color: accent.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('$_selected ${_isFr ? _monthsFr[_month] : _monthsEn[_month]} $_year',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: accent)),
                const SizedBox(height: 4),
                Text(_isFr
                    ? 'Jour Medumba : ${_daysMd[_medumbaDayIndex(_year, _month, _selected!)]}'
                    : 'Medumba day: ${_daysMd[_medumbaDayIndex(_year, _month, _selected!)]}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kInk)),
                Text(_isFr
                    ? 'Mois Medumba : ${_monthsMd[_month]}'
                    : 'Medumba month: ${_monthsMd[_month]}',
                    style: const TextStyle(fontSize: 12, color: kMuted)),
              ]),
            ),
            const SizedBox(height: 14),
          ],

          // ── Légende ───────────────────────────────────────────────
          Row(children: [
            _LegBtn(label: _isFr ? 'Mois' : 'Months', active: _legend == 'months',
                color: accent, onTap: () => setState(() => _legend = 'months')),
            const SizedBox(width: 8),
            _LegBtn(label: _isFr ? 'Jours' : 'Days', active: _legend == 'days',
                color: accent, onTap: () => setState(() => _legend = 'days')),
          ]),
          const SizedBox(height: 10),

          if (_legend == 'months')
            GridView.builder(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 3.2,
              ),
              itemCount: 12,
              itemBuilder: (_, i) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _monthColors[i].withValues(alpha: 0.1),
                  border: Border.all(color: _monthColors[i].withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  Container(width: 8, height: 8,
                      decoration: BoxDecoration(color: _monthColors[i], shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(_monthsMd[i], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                        color: _monthColors[i])),
                    Text(_isFr ? _monthsFr[i] : _monthsEn[i],
                        style: const TextStyle(fontSize: 9, color: kMuted)),
                  ])),
                ]),
              ),
            )
          else
            Column(
              children: List.generate(8, (i) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.07),
                    border: Border.all(color: accent.withValues(alpha: 0.2)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(8)),
                      child: Center(child: Text('${i+1}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white))),
                    ),
                    const SizedBox(width: 10),
                    Text(_daysMd[i], style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: accent)),
                    const SizedBox(width: 8),
                    Text('(${_isFr ? "Jour" : "Day"} ${i+1})',
                        style: const TextStyle(fontSize: 11, color: kMuted)),
                  ]),
                ),
              )),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _LegBtn extends StatelessWidget {
  final String label; final bool active; final Color color; final VoidCallback onTap;
  const _LegBtn({required this.label, required this.active, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: active ? color : Colors.white,
        border: Border.all(color: active ? color : kBorder),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w700,
          color: active ? Colors.white : kMuted)),
    ),
  );
}
