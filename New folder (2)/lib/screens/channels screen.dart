import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'player_screen.dart';

class ChannelsScreen extends StatefulWidget {
  const ChannelsScreen({super.key});

  @override
  State<ChannelsScreen> createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends State<ChannelsScreen> {
  List<Map<String, dynamic>> channels = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadChannels();
  }

  Future<void> loadChannels() async {
    setState(() { isLoading = true; error = null; });
    try {
      final res = await http.get(
        Uri.parse('https://kora-score-2-default-rtdb.firebaseio.com/channels_db.json'),
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>?;
        setState(() {
          channels = (data ?? {}).values.map((e) => Map<String, dynamic>.from(e)).toList();
          isLoading = false;
        });
      } else {
        setState(() { error = 'فشل الاتصال'; isLoading = false; });
      }
    } catch (e) {
      setState(() { error = 'تحقق من اتصال الإنترنت'; isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1e293b),
        title: const Text('📡 القنوات الناقلة',
            style: TextStyle(color: Color(0xFF06b6d4), fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF06b6d4)),
            onPressed: loadChannels,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF06b6d4)))
          : error != null
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.wifi_off, color: Color(0xFF64748b), size: 64),
                  const SizedBox(height: 16),
                  Text(error!, style: const TextStyle(color: Color(0xFF94a3b8))),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: loadChannels,
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF06b6d4), foregroundColor: Colors.black),
                  ),
                ]))
              : channels.isEmpty
                  ? const Center(
                      child: Text('لا توجد قنوات مضافة حالياً',
                          style: TextStyle(color: Color(0xFF94a3b8), fontSize: 16)))
                  : RefreshIndicator(
                      onRefresh: loadChannels,
                      color: const Color(0xFF06b6d4),
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: channels.length,
                        itemBuilder: (context, index) {
                          final c = channels[index];
                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PlayerScreen(
                                  url: c['link'] ?? '',
                                  title: c['name'] ?? '',
                                ),
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF1e293b),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF334155)),
                              ),
                              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                CachedNetworkImage(
                                  imageUrl: c['logo'] ?? '',
                                  width: 50, height: 50,
                                  fit: BoxFit.contain,
                                  errorWidget: (ctx, url, err) =>
                                      const Icon(Icons.tv, color: Color(0xFF38bdf8), size: 40),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    c['name'] ?? '',
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ]),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
