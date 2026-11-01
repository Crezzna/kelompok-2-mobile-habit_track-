import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'models/habit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Habit Tracker',
      theme: ThemeData(
        // Menerapkan Palet "The Deep Focus" (Navy Blue, Soft Grey, Bright Orange)
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F172A), // Navy Blue dominan
          primary: const Color(0xFF0F172A),
          secondary: const Color(0xFFFF7A00), // Bright Orange aksen
          surface: const Color(0xFFF1F5F9),  // Soft Grey latar belakang
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const MainNavigationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  List<Habit> habits = [];
  
  // Data riwayat mingguan untuk Line Chart (Grafik Peningkatan)
  final List<FlSpot> weeklyTrendData = const [
    FlSpot(1, 40),
    FlSpot(2, 60),
    FlSpot(3, 50),
    FlSpot(4, 80),
    FlSpot(5, 70),
    FlSpot(6, 90),
    FlSpot(7, 100),
  ];

  void _addHabit(String name, String time) {
    setState(() {
      habits.add(Habit(id: DateTime.now().toString(), name: name, time: time, isCompleted: false));
    });
  }

  void _deleteHabit(int index) {
    setState(() {
      habits.removeAt(index);
    });
  }

  void _toggleHabit(int index, bool? value) {
    setState(() {
      habits[index].isCompleted = value ?? false;
    });

    // Cek apakah semua habit sudah selesai, jika ya, tampilkan Pop-up perayaan
    if (habits.isNotEmpty && habits.every((h) => h.isCompleted)) {
      _showCompletionDialog();
    }
  }

  void _resetDaily() {
    setState(() {
      for (var habit in habits) {
        habit.isCompleted = false;
      }
    });
  }

  // Pop-up ketika semua tugas hari ini selesai
  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.verified, color: Color(0xFFFF7A00), size: 28),
            SizedBox(width: 10),
            Text('Luar Biasa!', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Selamat! Anda telah menyelesaikan seluruh kebiasaan hari ini dengan sempurna. Pertahankan konsistensi Anda!',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7A00),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Keren!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HabitHomePage(
        habits: habits,
        onAddHabit: _addHabit,
        onDeleteHabit: _deleteHabit,
        onToggleHabit: _toggleHabit,
        onResetDaily: _resetDaily,
      ),
      HistoryStatsPage(habits: habits, weeklyData: weeklyTrendData),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFFF7A00).withValues(alpha: 0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Color(0xFF0F172A)),
            label: 'Rutinitas',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart, color: Color(0xFF0F172A)),
            label: 'Statistik & History',
          ),
        ],
      ),
    );
  }
}

class HabitHomePage extends StatelessWidget {
  final List<Habit> habits;
  final Function(String, String) onAddHabit;
  final Function(int) onDeleteHabit;
  final Function(int, bool?) onToggleHabit;
  final VoidCallback onResetDaily;

  const HabitHomePage({
    super.key,
    required this.habits,
    required this.onAddHabit,
    required this.onDeleteHabit,
    required this.onToggleHabit,
    required this.onResetDaily,
  });

  double get progressPercentage {
    if (habits.isEmpty) return 0.0;
    int completedCount = habits.where((h) => h.isCompleted).length;
    return completedCount / habits.length;
  }

  void _showAddDialog(BuildContext context) {
    final nameController = TextEditingController();
    final timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Tambah Kebiasaan Baru', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Kebiasaan',
                  prefixIcon: const Icon(Icons.task_alt, color: Color(0xFF0F172A)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFFF7A00), width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: timeController,
                decoration: InputDecoration(
                  labelText: 'Waktu (Contoh: 07:00 AM)',
                  prefixIcon: const Icon(Icons.access_time, color: Color(0xFF0F172A)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFFF7A00), width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7A00),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  onAddHabit(nameController.text, timeController.text.isEmpty ? 'Sepanjang Hari' : timeController.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int completedCount = habits.where((h) => h.isCompleted).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Soft Grey
      appBar: AppBar(
        title: const Text('Daily Habit Tracker', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0F172A), // Navy Blue
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFFF7A00)), // Bright Orange
            tooltip: 'Reset Harian',
            onPressed: onResetDaily,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Banner Navy Blue dengan Card Progres & Animasi Transisi
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Progres Hari Ini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF7A00).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${(progressPercentage * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF7A00)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('$completedCount dari ${habits.length} kebiasaan selesai', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 500),
                        tween: Tween<double>(begin: 0, end: progressPercentage),
                        builder: (context, value, _) => LinearProgressIndicator(
                          value: value,
                          backgroundColor: Colors.grey[200],
                          color: const Color(0xFFFF7A00), // Aksen Oranye
                          minHeight: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Daftar Rutinitas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                Text('${habits.length} Item', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: habits.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.checklist_rounded, size: 80, color: Color(0xFF0F172A)),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada kebiasaan.\nTekan tombol di bawah untuk menambah.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600], fontSize: 15),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: habits.length,
                    itemBuilder: (context, index) {
                      final habit = habits[index];
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Checkbox(
                            value: habit.isCompleted,
                            activeColor: const Color(0xFFFF7A00), // Oranye saat diceklis
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: (val) => onToggleHabit(index, val),
                          ),
                          title: Text(
                            habit.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              decoration: habit.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                              color: habit.isCompleted ? Colors.grey : const Color(0xFF0F172A),
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFFFF7A00)),
                                const SizedBox(width: 4),
                                Text(habit.time, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              ],
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                            onPressed: () => onDeleteHabit(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFF7A00), // Aksen Bright Orange Call-to-Action
        foregroundColor: Colors.white,
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Habit', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// ================= Halaman Statistik dengan Pie Chart & Line Chart =================
class HistoryStatsPage extends StatelessWidget {
  final List<Habit> habits;
  final List<FlSpot> weeklyData;

  const HistoryStatsPage({super.key, required this.habits, required this.weeklyData});

  @override
  Widget build(BuildContext context) {
    int total = habits.length;
    int completed = habits.where((h) => h.isCompleted).length;
    int uncompleted = total - completed;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Soft Grey
      appBar: AppBar(
        title: const Text('Statistik & History Pencapaian', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0F172A), // Navy Blue
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Grafik Performa Hari Ini (Pie Chart)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 12),
            total == 0
                ? Container(
                    height: 200,
                    alignment: Alignment.center,
                    child: const Text('Belum ada data untuk ditampilkan dalam diagram lingkaran.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                  )
                : Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 4,
                            centerSpaceRadius: 40,
                            sections: [
                              PieChartSectionData(
                                color: const Color(0xFFFF7A00), // Bright Orange
                                value: completed.toDouble(),
                                title: '$completed Selesai',
                                radius: 55,
                                titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              PieChartSectionData(
                                color: const Color(0xFF0F172A), // Navy Blue
                                value: uncompleted.toDouble(),
                                title: '$uncompleted Belum',
                                radius: 55,
                                titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: 24),
            const Text('Grafik Tren Peningkatan Mingguan (Line Chart)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 12),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (value, meta) {
                              return Text('${value.toInt()}%', style: const TextStyle(fontSize: 10, color: Colors.grey));
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text('H${value.toInt()}', style: const TextStyle(fontSize: 10, color: Colors.grey));
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: weeklyData,
                          isCurved: true,
                          color: const Color(0xFFFF7A00), // Bright Orange Line
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: const Color(0xFFFF7A00).withValues(alpha: 0.15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: const Color(0xFFFF7A00).withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.check_circle, color: Color(0xFFFF7A00)),
                      ),
                      title: const Text('Total Kebiasaan Selesai', style: TextStyle(fontWeight: FontWeight.w600)),
                      trailing: Text('$completed dari $total', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    const Divider(height: 24),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: const Color(0xFF0F172A).withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.analytics, color: Color(0xFF0F172A)),
                      ),
                      title: const Text('Persentase Keberhasilan', style: TextStyle(fontWeight: FontWeight.w600)),
                      trailing: Text('${total == 0 ? 0 : ((completed / total) * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFF7A00))),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}