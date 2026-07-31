import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PtdApp());
}

// ─── Types ─────────────────────────────────────────────────────────────────────

enum ThemeKey { yellow, green, blue, pink, purple, peach, white }

class TaskGroup {
  final String id;
  final String name;
  final ThemeKey theme;
  final String date;

  TaskGroup({required this.id, required this.name, required this.theme, required this.date});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'theme': theme.name,
        'date': date,
      };

  factory TaskGroup.fromJson(Map<String, dynamic> json) => TaskGroup(
        id: json['id'],
        name: json['name'],
        theme: ThemeKey.values.firstWhere((e) => e.name == json['theme']),
        date: json['date'],
      );
}

class Task {
  final String id;
  final String groupId;
  final String text;
  final bool completed;

  Task({required this.id, required this.groupId, required this.text, required this.completed});

  Map<String, dynamic> toJson() => {
        'id': id,
        'groupId': groupId,
        'text': text,
        'completed': completed,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        groupId: json['groupId'],
        text: json['text'],
        completed: json['completed'],
      );
}

// ─── Themes ────────────────────────────────────────────────────────────────────

class ThemeColors {
  final String label;
  final Color swatch;
  final Color cardStart;
  final Color cardEnd;
  final Color inner;
  final Color text;
  final Color sub;
  final Color accent;
  final Color border;
  final Color check;
  final List<Color> pageBg;
  final Color stroke;

  const ThemeColors({
    required this.label, required this.swatch, required this.cardStart, required this.cardEnd,
    required this.inner, required this.text, required this.sub, required this.accent,
    required this.border, required this.check, required this.pageBg, required this.stroke,
  });
}

final Map<ThemeKey, ThemeColors> themes = {
  ThemeKey.yellow: const ThemeColors(
    label: 'Sunny', swatch: Color(0xFFFEF08A), cardStart: Color(0xFFFEF9C3), cardEnd: Color(0xFFFFFBEB),
    inner: Color(0xFFFEFCE8), text: Color(0xFF713F12), sub: Color(0xFFA16207), accent: Color(0xFFFDE047),
    border: Color(0xFFFEF08A), check: Color(0xFFFACC15), pageBg: [Color(0xFFFEFCE8), Color(0xFFFFFBEB), Color(0xFFFFF7ED)],
    stroke: Color(0xFFFACC15),
  ),
  ThemeKey.green: const ThemeColors(
    label: 'Mint', swatch: Color(0xFFBBF7D0), cardStart: Color(0xFFDCFCE7), cardEnd: Color(0xFFECFDF5),
    inner: Color(0xFFF0FDF4), text: Color(0xFF14532D), sub: Color(0xFF15803D), accent: Color(0xFF86EFAC),
    border: Color(0xFFBBF7D0), check: Color(0xFF4ADE80), pageBg: [Color(0xFFF0FDF4), Color(0xFFECFDF5), Color(0xFFF0FDFA)],
    stroke: Color(0xFF4ADE80),
  ),
  ThemeKey.blue: const ThemeColors(
    label: 'Sky', swatch: Color(0xFFBFDBFE), cardStart: Color(0xFFDBEAFE), cardEnd: Color(0xFFEEF2FF),
    inner: Color(0xFFEFF6FF), text: Color(0xFF1E3A8A), sub: Color(0xFF1D4ED8), accent: Color(0xFF93C5FD),
    border: Color(0xFFBFDBFE), check: Color(0xFF60A5FA), pageBg: [Color(0xFFEFF6FF), Color(0xFFEEF2FF), Color(0xFFF5F3FF)],
    stroke: Color(0xFF60A5FA),
  ),
  ThemeKey.pink: const ThemeColors(
    label: 'Blossom', swatch: Color(0xFFFBCFE8), cardStart: Color(0xFFFCE7F3), cardEnd: Color(0xFFFFF1F2),
    inner: Color(0xFFFDF2F8), text: Color(0xFF831843), sub: Color(0xFFBE185D), accent: Color(0xFFF9A8D4),
    border: Color(0xFFFBCFE8), check: Color(0xFFF472B6), pageBg: [Color(0xFFFDF2F8), Color(0xFFFFF1F2), Color(0xFFFDF4FF)],
    stroke: Color(0xFFF472B6),
  ),
  ThemeKey.purple: const ThemeColors(
    label: 'Lavender', swatch: Color(0xFFE9D5FF), cardStart: Color(0xFFF3E8FF), cardEnd: Color(0xFFF5F3FF),
    inner: Color(0xFFFAF5FF), text: Color(0xFF581C87), sub: Color(0xFF7E22CE), accent: Color(0xFFD8B4FE),
    border: Color(0xFFE9D5FF), check: Color(0xFFC084FC), pageBg: [Color(0xFFFAF5FF), Color(0xFFF5F3FF), Color(0xFFFDF4FF)],
    stroke: Color(0xFFC084FC),
  ),
  ThemeKey.peach: const ThemeColors(
    label: 'Peach', swatch: Color(0xFFFED7AA), cardStart: Color(0xFFFFEDD5), cardEnd: Color(0xFFFFFBEB),
    inner: Color(0xFFFFF7ED), text: Color(0xFF7C2D12), sub: Color(0xFFC2410C), accent: Color(0xFFFDBA74),
    border: Color(0xFFFED7AA), check: Color(0xFFFB923C), pageBg: [Color(0xFFFFF7ED), Color(0xFFFFFBEB), Color(0xFFFEFCE8)],
    stroke: Color(0xFFFB923C),
  ),
  ThemeKey.white: const ThemeColors(
    label: 'Cloud', swatch: Color(0xFFF1F5F9), cardStart: Color(0xFFF8FAFC), cardEnd: Color(0xFFF9FAFB),
    inner: Color(0xFFFFFFFF), text: Color(0xFF1E293B), sub: Color(0xFF64748B), accent: Color(0xFFE2E8F0),
    border: Color(0xFFE2E8F0), check: Color(0xFF94A3B8), pageBg: [Color(0xFFF8FAFC), Color(0xFFF9FAFB), Color(0xFFFAFAFA)],
    stroke: Color(0xFF94A3B8),
  ),
};

// ─── Utilities ─────────────────────────────────────────────────────────────────

String toDateStr(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
String getToday() => toDateStr(DateTime.now());
String getCutoff() => toDateStr(DateTime.now().subtract(const Duration(days: 30)));
String formatDate(String s) {
  final d = DateTime.parse(s);
  return DateFormat('EEEE, MMMM d').format(d);
}
String uid() => DateTime.now().microsecondsSinceEpoch.toString();

// ─── Background Painter ────────────────────────────────────────────────────────
class DotPatternPainter extends CustomPainter {
  final Color color;
  DotPatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const double spacing = 20.0;
    for (double i = 0; i < size.width; i += spacing) {
      for (double j = 0; j < size.height; j += spacing) {
        canvas.drawCircle(Offset(i, j), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── App Root ──────────────────────────────────────────────────────────────────

class PtdApp extends StatelessWidget {
  const PtdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.nunitoTextTheme(Theme.of(context).textTheme),
        useMaterial3: true,
      ),
      home: const RootApp(),
    );
  }
}

class RootApp extends StatefulWidget {
  const RootApp({super.key});

  @override
  State<RootApp> createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  String navPage = 'tasks';
  String? navGroupId;
  String navFrom = 'tasks';

  List<TaskGroup> groups = [];
  List<Task> tasks = [];
  bool showCreate = false;
  String createDate = getToday();
  String calDate = getToday();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final cutoff = getCutoff();
    
    final groupsJson = prefs.getString('ptd-groups');
    if (groupsJson != null) {
      final List decoded = jsonDecode(groupsJson);
      groups = decoded.map((e) => TaskGroup.fromJson(e)).where((g) => g.date.compareTo(cutoff) >= 0).toList();
    }
    
    final tasksJson = prefs.getString('ptd-tasks');
    if (tasksJson != null) {
      final Set<String> groupIds = groups.map((e) => e.id).toSet();
      final List decoded = jsonDecode(tasksJson);
      tasks = decoded.map((e) => Task.fromJson(e)).where((t) => groupIds.contains(t.groupId)).toList();
    }
    setState(() {});
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ptd-groups', jsonEncode(groups.map((e) => e.toJson()).toList()));
    await prefs.setString('ptd-tasks', jsonEncode(tasks.map((e) => e.toJson()).toList()));
  }

  void _handleCreate(String name, ThemeKey theme) {
    final g = TaskGroup(id: uid(), name: name, theme: theme, date: createDate);
    setState(() {
      groups.add(g);
      showCreate = false;
      navPage = 'group';
      navGroupId = g.id;
      navFrom = navPage == 'calendar' ? 'calendar' : 'tasks';
    });
    _saveData();
  }

  void _deleteGroup(String id) {
    setState(() {
      groups.removeWhere((g) => g.id == id);
      tasks.removeWhere((t) => t.groupId == id);
    });
    _saveData();
  }

  void _openFAB() {
    setState(() {
      createDate = navPage == 'calendar' ? calDate : getToday();
      showCreate = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (navPage == 'group' && navGroupId != null) {
      final groupIndex = groups.indexWhere((g) => g.id == navGroupId);
      if (groupIndex == -1) {
        WidgetsBinding.instance.addPostFrameCallback((_) => setState(() => navPage = 'tasks'));
        return const Scaffold();
      }
      final group = groups[groupIndex];
      final groupTasks = tasks.where((t) => t.groupId == group.id).toList();

      return Stack(
        children: [
          GroupDetailScreen(
            group: group,
            tasks: groupTasks,
            onBack: () => setState(() => navPage = navFrom),
            onToggle: (id) {
              setState(() {
                final idx = tasks.indexWhere((t) => t.id == id);
                tasks[idx] = Task(id: tasks[idx].id, groupId: tasks[idx].groupId, text: tasks[idx].text, completed: !tasks[idx].completed);
              });
              _saveData();
            },
            onEdit: (id, text) {
              setState(() {
                final idx = tasks.indexWhere((t) => t.id == id);
                tasks[idx] = Task(id: tasks[idx].id, groupId: tasks[idx].groupId, text: text, completed: tasks[idx].completed);
              });
              _saveData();
            },
            onDelete: (id) {
              setState(() => tasks.removeWhere((t) => t.id == id));
              _saveData();
            },
            onAdd: (text) {
              setState(() => tasks.add(Task(id: uid(), groupId: group.id, text: text, completed: false)));
              _saveData();
            },
          ),
          if (showCreate)
            CreateGroupModal(
              onClose: () => setState(() => showCreate = false),
              onCreate: _handleCreate,
            ),
        ],
      );
    }

    final pageBg = navPage == 'tasks'
        ? const [Color.fromARGB(255, 246, 225, 231), Color.fromARGB(255, 200, 144, 169), Color.fromARGB(255, 109, 74, 118)]
        : const [Color.fromARGB(255, 0, 0, 0), Color(0xFFEEF2FF), Color.fromARGB(255, 5, 1, 26)];

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: pageBg)),
          ),
          CustomPaint(painter: DotPatternPainter(const Color.fromRGBO(160, 140, 220, 0.15)), size: Size.infinite),
          SafeArea(
            child: Column(
              children: [
                _buildTopNav(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
                    child: navPage == 'tasks'
                        ? TasksPage(
                            groups: groups,
                            tasks: tasks,
                            onOpen: (id) => setState(() { navPage = 'group'; navGroupId = id; navFrom = 'tasks'; }),
                            onDelete: _deleteGroup,
                          )
                        : CalendarPage(
                            groups: groups,
                            tasks: tasks,
                            onOpen: (id) => setState(() { navPage = 'group'; navGroupId = id; navFrom = 'calendar'; }),
                            onDelete: _deleteGroup,
                            selectedDate: calDate,
                            setSelectedDate: (d) => setState(() => calDate = d),
                          ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 32,
            right: 24,
            child: FloatingActionButton(
              onPressed: _openFAB,
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                width: 56, height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [Color(0xFFF472B6), Color(0xFFA855F7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),
          ),
          if (showCreate)
            CreateGroupModal(
              onClose: () => setState(() => showCreate = false),
              onCreate: _handleCreate,
            ),
        ],
      ),
    );
  }

  Widget _buildTopNav() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.55),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.7)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: ['tasks', 'calendar'].map((p) {
            final isSel = navPage == p;
            return GestureDetector(
              onTap: () => setState(() => navPage = p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isSel ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSel ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : [],
                ),
                child: Row(
                  children: [
                    Icon(p == 'tasks' ? Icons.check_box_outlined : Icons.calendar_today_outlined, 
                         size: 16, color: isSel ? (p == 'tasks' ? Colors.purple[600] : Colors.indigo[600]) : Colors.blueGrey),
                    const SizedBox(width: 8),
                    Text(p == 'tasks' ? 'Tasks' : 'Calendar', 
                         style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isSel ? (p == 'tasks' ? Colors.purple[600] : Colors.indigo[600]) : Colors.blueGrey)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─── Pages ─────────────────────────────────────────────────────────────────────

class TasksPage extends StatelessWidget {
  final List<TaskGroup> groups;
  final List<Task> tasks;
  final Function(String) onOpen;
  final Function(String) onDelete;

  const TasksPage({super.key, required this.groups, required this.tasks, required this.onOpen, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final today = getToday();
    final dayGroups = groups.where((g) => g.date == today).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(formatDate(today).toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFD8B4FE), letterSpacing: 1.5)),
        const SizedBox(height: 4),
        const Text('Today', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
        const SizedBox(height: 20),
        if (dayGroups.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 80),
            child: Center(
              child: Column(
                children: [
                  const Text('🌸', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  const Text('No task groups yet', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black38)),
                  Text('Tap + to create your first group', style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.3))),
                ],
              ),
            ),
          )
        else
          ...dayGroups.map((g) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GroupCard(group: g, tasks: tasks.where((t) => t.groupId == g.id).toList(), onClick: () => onOpen(g.id), onDelete: () => onDelete(g.id)),
          )),
      ],
    );
  }
}

class CalendarPage extends StatefulWidget {
  final List<TaskGroup> groups;
  final List<Task> tasks;
  final Function(String) onOpen;
  final Function(String) onDelete;
  final String selectedDate;
  final Function(String) setSelectedDate;

  const CalendarPage({super.key, required this.groups, required this.tasks, required this.onOpen, required this.onDelete, required this.selectedDate, required this.setSelectedDate});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late int viewYear;
  late int viewMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    viewYear = now.year;
    viewMonth = now.month;
  }

  void prev() {
    setState(() {
      if (viewMonth == 1) { viewYear--; viewMonth = 12; }
      else { viewMonth--; }
    });
  }

  void next() {
    setState(() {
      if (viewMonth == 12) { viewYear++; viewMonth = 1; }
      else { viewMonth++; }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selGroups = widget.groups.where((g) => g.date == widget.selectedDate).toList();
    final cutoff = getCutoff();
    final todayStr = getToday();
    final daysInMonth = DateTime(viewYear, viewMonth + 1, 0).day;
    final firstDow = DateTime(viewYear, viewMonth, 1).weekday % 7; // Sunday=0
    final monthName = DateFormat('MMMM yyyy').format(DateTime(viewYear, viewMonth));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SCHEDULE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFA5B4FC), letterSpacing: 1.5)),
        const Text('Calendar', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
        const Text('Last 30 days · future dates', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.65),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE0E7FF)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(icon: const Icon(Icons.chevron_left, color: Colors.blueGrey), onPressed: prev),
                  Text(monthName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                  IconButton(icon: const Icon(Icons.chevron_right, color: Colors.blueGrey), onPressed: next),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'].map((d) => 
                  Expanded(child: Text(d, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))))
                ).toList(),
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1),
                itemCount: firstDow + daysInMonth,
                itemBuilder: (context, index) {
                  if (index < firstDow) return const SizedBox();
                  final day = index - firstDow + 1;
                  final d = '$viewYear-${viewMonth.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
                  final disabled = d.compareTo(cutoff) < 0;
                  final isToday = d == todayStr;
                  final isSel = d == widget.selectedDate;
                  final dots = widget.groups.where((g) => g.date == d).take(3).map((g) => themes[g.theme]!.accent).toList();

                  return GestureDetector(
                    onTap: disabled ? null : () => widget.setSelectedDate(d),
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isSel ? const Color(0xFFC7D2FE) : (isToday ? const Color(0xFFFCE7F3) : Colors.transparent),
                        borderRadius: BorderRadius.circular(12),
                        border: isToday && !isSel ? Border.all(color: const Color(0xFFF9A8D4)) : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('$day', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: disabled ? const Color(0xFFE2E8F0) : (isSel ? const Color(0xFF3730A3) : (isToday ? const Color(0xFFDB2777) : const Color(0xFF475569))))),
                          if (dots.isNotEmpty && !disabled)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: dots.map((c) => Container(margin: const EdgeInsets.symmetric(horizontal: 1), width: 4, height: 4, decoration: BoxDecoration(color: c, shape: BoxShape.circle))).toList(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(formatDate(widget.selectedDate), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
        const SizedBox(height: 12),
        if (selGroups.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Center(
              child: Column(
                children: [
                  const Text('', style: TextStyle(fontSize: 32)),// sticker was giving error 
                  const SizedBox(height: 8),
                  const Text('No groups for this day', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black38)),
                  Text('Tap + to add one', style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.3))),
                ],
              ),
            ),
          )
        else
          ...selGroups.map((g) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GroupCard(group: g, tasks: widget.tasks.where((t) => t.groupId == g.id).toList(), onClick: () => widget.onOpen(g.id), onDelete: () => widget.onDelete(g.id)),
          )),
      ],
    );
  }
}

// ─── Components ────────────────────────────────────────────────────────────────

class GroupCard extends StatelessWidget {
  final TaskGroup group;
  final List<Task> tasks;
  final VoidCallback onClick;
  final VoidCallback onDelete;

  const GroupCard({super.key, required this.group, required this.tasks, required this.onClick, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final t = themes[group.theme]!;
    final done = tasks.where((tk) => tk.completed).length;
    final total = tasks.length;
    final pct = total > 0 ? (done / total) : 0.0;

    return GestureDetector(
      onTap: onClick,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [t.cardStart, t.cardEnd], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: t.border),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(group.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: t.text)),
                          Text('$done/$total done', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: t.sub)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, right: 20.0),
                      child: SizedBox(
                        width: 44, height: 44,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(value: 1, strokeWidth: 3.5, color: Colors.white.withOpacity(0.6)),
                            CircularProgressIndicator(value: pct, strokeWidth: 3.5, color: t.stroke, backgroundColor: Colors.transparent),
                            Center(child: Text('${(pct * 100).round()}%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: t.sub))),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                if (tasks.isEmpty)
                  Text('No tasks yet — tap to add some', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: t.sub))
                else ...[
                  ...tasks.take(4).map((task) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Container(width: 6, height: 6, decoration: BoxDecoration(color: task.completed ? const Color(0xFFE2E8F0) : t.accent, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(task.text, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, decoration: task.completed ? TextDecoration.lineThrough : null, color: task.completed ? const Color(0xFF94A3B8) : t.sub))),
                      ],
                    ),
                  )),
                  if (tasks.length > 4)
                    Text('+${tasks.length - 4} more', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: t.sub))
                ]
              ],
            ),
            Positioned(
              top: -8, right: -8,
              child: IconButton(
                icon: const Icon(Icons.close, size: 16, color: Colors.black26),
                onPressed: onDelete,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class GroupDetailScreen extends StatefulWidget {
  final TaskGroup group;
  final List<Task> tasks;
  final VoidCallback onBack;
  final Function(String) onToggle;
  final Function(String, String) onEdit;
  final Function(String) onDelete;
  final Function(String) onAdd;

  const GroupDetailScreen({super.key, required this.group, required this.tasks, required this.onBack, required this.onToggle, required this.onEdit, required this.onDelete, required this.onAdd});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final TextEditingController _controller = TextEditingController();

  void submit() {
    final v = _controller.text.trim();
    if (v.isNotEmpty) {
      widget.onAdd(v);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = themes[widget.group.theme]!;
    final done = widget.tasks.where((tk) => tk.completed).length;

    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: t.pageBg))),
          CustomPaint(painter: DotPatternPainter(const Color.fromRGBO(0, 0, 0, 0.08)), size: Size.infinite),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: widget.onBack,
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(color: t.inner, borderRadius: BorderRadius.circular(16), border: Border.all(color: t.border)),
                          child: Icon(Icons.arrow_back, size: 20, color: t.text),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.group.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: t.text)),
                            Text('$done/${widget.tasks.length} done · ${formatDate(widget.group.date)}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: t.sub)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.tasks.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(value: widget.tasks.isNotEmpty ? (done / widget.tasks.length) : 0, minHeight: 6, backgroundColor: t.accent.withOpacity(0.3), color: t.accent),
                    ),
                  ),
                Expanded(
                  child: widget.tasks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('✨', style: TextStyle(fontSize: 36)),
                              const SizedBox(height: 12),
                              Text('No tasks yet — add one below!', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: t.sub)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                          itemCount: widget.tasks.length,
                          itemBuilder: (context, index) {
                            final task = widget.tasks[index];
                            return TaskItemWidget(task: task, themeColor: t, onToggle: () => widget.onToggle(task.id), onEdit: (text) => widget.onEdit(task.id, text), onDelete: () => widget.onDelete(task.id));
                          },
                        ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [t.pageBg.first, t.pageBg.first.withOpacity(0)])),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: t.inner, borderRadius: BorderRadius.circular(16), border: Border.all(color: t.border, width: 2), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))]),
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline, size: 20, color: t.sub),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onSubmitted: (_) => submit(),
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: t.text),
                        decoration: InputDecoration(hintText: 'Add task to ${widget.group.name}…', hintStyle: const TextStyle(color: Colors.black26), border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                      ),
                    ),
                    GestureDetector(
                      onTap: submit,
                      child: Text('Add', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: t.sub)),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class TaskItemWidget extends StatefulWidget {
  final Task task;
  final ThemeColors themeColor;
  final VoidCallback onToggle;
  final Function(String) onEdit;
  final VoidCallback onDelete;

  const TaskItemWidget({super.key, required this.task, required this.themeColor, required this.onToggle, required this.onEdit, required this.onDelete});

  @override
  State<TaskItemWidget> createState() => _TaskItemWidgetState();
}

class _TaskItemWidgetState extends State<TaskItemWidget> {
  bool editing = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.task.text);
  }

  void commit() {
    final v = _controller.text.trim();
    if (v.isNotEmpty) widget.onEdit(v);
    else _controller.text = widget.task.text;
    setState(() => editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.themeColor;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: t.inner, borderRadius: BorderRadius.circular(16), border: Border.all(color: t.border)),
      child: Row(
        children: [
          GestureDetector(
            onTap: widget.onToggle,
            child: Container(
              width: 20, height: 20,
              decoration: BoxDecoration(color: widget.task.completed ? t.check : Colors.transparent, shape: BoxShape.circle, border: Border.all(color: widget.task.completed ? t.check : Colors.black26, width: 2)),
              child: widget.task.completed ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: editing
                ? TextField(
                    controller: _controller,
                    autofocus: true,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: t.text),
                    decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                    onSubmitted: (_) => commit(),
                    onEditingComplete: commit,
                  )
                : GestureDetector(
                    onTap: () { if (!widget.task.completed) setState(() => editing = true); },
                    child: Text(widget.task.text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, decoration: widget.task.completed ? TextDecoration.lineThrough : null, color: widget.task.completed ? const Color(0xFF94A3B8) : t.text)),
                  ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: Colors.black26),
            onPressed: widget.onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          )
        ],
      ),
    );
  }
}

class CreateGroupModal extends StatefulWidget {
  final VoidCallback onClose;
  final Function(String, ThemeKey) onCreate;

  const CreateGroupModal({super.key, required this.onClose, required this.onCreate});

  @override
  State<CreateGroupModal> createState() => _CreateGroupModalState();
}

class _CreateGroupModalState extends State<CreateGroupModal> {
  String name = '';
  ThemeKey selectedTheme = ThemeKey.yellow;

  @override
  Widget build(BuildContext context) {
    final t = themes[selectedTheme]!;

    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('New Task Group', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                const Text('Pick a theme, then give it a name', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: ThemeKey.values.map((key) {
                    final th = themes[key]!;
                    final isSel = selectedTheme == key;
                    return GestureDetector(
                      onTap: () => setState(() => selectedTheme = key),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(color: th.swatch, borderRadius: BorderRadius.circular(12), border: Border.all(color: isSel ? const Color(0xFF64748B) : Colors.transparent, width: 2)),
                            child: isSel ? const Icon(Icons.check, size: 16, color: Color(0xFF475569)) : null,
                          ),
                          const SizedBox(height: 4),
                          Text(th.label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(color: t.inner, borderRadius: BorderRadius.circular(16), border: Border.all(color: t.border, width: 2)),
                  child: TextField(
                    onChanged: (v) => setState(() => name = v),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: t.text),
                    decoration: InputDecoration(hintText: 'Group name (e.g. Study, GYM…)', hintStyle: const TextStyle(color: Color(0xFFCBD5E1)), border: InputBorder.none),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(gradient: LinearGradient(colors: [t.cardStart, t.cardEnd]), borderRadius: BorderRadius.circular(16), border: Border.all(color: t.border)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name.isEmpty ? 'Group Name' : name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.text)),
                      Text('0 tasks · ${formatDate(getToday())}', style: TextStyle(fontSize: 12, color: t.sub)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: widget.onClose,
                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.grey[200], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextButton(
                        onPressed: name.trim().isEmpty ? null : () => widget.onCreate(name.trim(), selectedTheme),
                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: name.trim().isEmpty ? Colors.grey[100] : t.accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        child: Text('Create Group', style: TextStyle(fontWeight: FontWeight.bold, color: name.trim().isEmpty ? Colors.grey[400] : t.text)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}