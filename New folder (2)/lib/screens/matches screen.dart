import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'player_screen.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  List<Map<String, dynamic>> matches = [];
  Map<String, dynamic> streams = {};
  bool isLoading = true;
  String? error;

  static const String dbUrl = 'https://kora-score-2-default-rtdb.firebaseio.com';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() { isLoading = true; error = null; });
    try {
      final matchRes = await http.get(Uri.parse('$dbUrl/matches_db.json')).timeout(const Duration(seconds: 15));
      final streamRes = await http.get(Uri.parse('$dbUrl/streams.json')).timeout(const Duration(seconds: 15));

      if (matchRes.statusCode == 200) {
        final data = json.decode(matchRes.body) as Map<String, dynamic>?;
        final streamData = json.decode(streamRes.body) as Map<String, dynamic>?;

        final list = (data ?? {}).entries.map((e) => {
          'id': e.key,
          ...Map<String, dynamic>.from(e.value),
        }).toList();

        list.sort((a, b) => ((a['timestamp'] ?? 0) as int).compareTo((b['timestamp'] ?? 0) as int));

        setState(() {
          matches = list;
          streams = streamData ?? {};
          isLoading = false;
        });
      } else {
        setState(() { error = 'فشل الاتصال بالخادم'; isLoading = false; });
      }
    } catch (e) {
      setState(() { error = 'تحقق من اتصال الإنترنت'; isLoading = false; });
    }
  }

  Map<String, dynamic> getStatus(int? timestamp) {
    if (timestamp == null) return {'ok': false, 'label': 'لم تبدأ', 'isLive': false, 'isFinished': false};
    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = (timestamp - now) / 60000;
    if (diff > 20)   return {'ok': false, 'label': 'لم تبدأ',       'isLive': false, 'isFinished': false};
    if (diff > 0)    return {'ok': true,  'label': 'بعد قليل ⏳',   'isLive': false, 'isFinished': false};
    if (diff > -130) return {'ok': true,  'label': 'مباشر 🔴',      'isLive': true,  'isFinished': false};
    return              {'ok': false, 'label': 'انتهت',              'isLive': false, 'isFinished': true};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1e293b),
        title: const Text('💎 كورة سكور لايف', style: TextStyle(color: Color(0xFF38bdf8), fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF38bdf8)),
            onPressed: loadData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF38bdf8)))
          : error != null
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.wifi_off, color: Color(0xFF64748b), size: 64),
                  const SizedBox(height: 16),
                  Text(error!, style: const TextStyle(color: Color(0xFF94a3b8), fontSize: 16)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: loadData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38bdf8), foregroundColor: Colors.black),
                  ),
                ]))
              : matches.isEmpty
                  ? const Center(child: Text('لا توجد مباريات اليوم', style: TextStyle(color: Color(0xFF94a3b8), fontSize: 16)))
                  : RefreshIndicator(
                      onRefresh: loadData,
                      color: const Color(0xFF38bdf8),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: matches.length,
                        itemBuilder: (context, index) {
                          final m = matches[index];
                          final status = getStatus(m['timestamp'] as int?);
                          final matchStreams = (streams[m['id']] as Map?)?.cast<String, dynamic>() ?? {};
                          final s1 = matchStreams['s1'] as String? ?? '';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1e293b),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: status['isLive'] ? const Color(0xFFef4444) : const Color(0xFF334155),
                                width: status['isLive'] ? 1.5 : 1,
                              ),
                            ),
                            child: Column(children: [
                              // اسم البطولة
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF6a1b4d),
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                                ),
                                child: Text('🏆 ${m['league'] ?? ''}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Color(0xFFffd700), fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                              // الفرق والوقت
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                child: Row(children: [
                                  // الفريق الأول
                                  Expanded(child: Column(children: [
                                    CachedNetworkImage(imageUrl: m['img1'] ?? '', width: 50, height: 50,
                                        errorWidget: (c, u, e) => const Icon(Icons.sports_soccer, color: Colors.white54, size: 40)),
                                    const SizedBox(height: 6),
                                    Text(m['t1'] ?? '', textAlign: TextAlign.center,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  ])),
                                  // الوقت والحالة
                                  Column(children: [
                                    Text(m['time'] ?? '',
                                        style: const TextStyle(color: Color(0xFF38bdf8), fontWeight: FontWeight.bold, fontSize: 17)),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: status['isLive'] ? const Color(0xFFef4444) : const Color(0xFF0f172a),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: const Color(0xFF334155)),
                                      ),
                                      child: Text(status['label'],
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                    ),
                                  ]),
                                  // الفريق الثاني
                                  Expanded(child: Column(children: [
                                    CachedNetworkImage(imageUrl: m['img2'] ?? '', width: 50, height: 50,
                                        errorWidget: (c, u, e) => const Icon(Icons.sports_soccer, color: Colors.white54, size: 40)),
                                    const SizedBox(height: 6),
                                    Text(m['t2'] ?? '', textAlign: TextAlign.center,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  ])),
                                ]),
                              ),
                              // زرار المشاهدة
                              if (!status['isFinished'])
                                GestureDetector(
                                  onTap: () {
                                    if (status['ok'] && s1.isNotEmpty) {
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (_) => PlayerScreen(url: s1, title: '${m['t1']} × ${m['t2']}')));
                                    } else if (!status['ok']) {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                          content: Text('⚠️ البث سيتوفر قبل المباراة بـ 20 دقيقة'),
                                          backgroundColor: Color(0xFF334155)));
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                          content: Text('⚠️ رابط البث غير متوفر بعد'),
                                          backgroundColor: Color(0xFF334155)));
                                    }
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: status['ok'] ? const Color(0xFFef4444) : const Color(0xFF334155),
                                      borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
                                    ),
                                    child: Text(
                                      status['ok'] ? '▶  شاهد المباراة' : '🕐  ${m['time']}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF334155),
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
                                  ),
                                  child: const Text('انتهت المباراة', textAlign: TextAlign.center,
                                      style: TextStyle(color: Color(0xFF94a3b8), fontSize: 13)),
                                ),
                            ]),
                          );
                        },
                      ),
                    ),
    );
  }
}
