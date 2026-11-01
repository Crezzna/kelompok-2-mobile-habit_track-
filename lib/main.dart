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
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Widget untuk Navigasi Bawah (Dashboard & History)
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  List<Habit> habits = [];

  // Fungsi Tambah Kebiasaan Baru
  void _addHabit(String name, String time) {
    setState(() {
      habits.add(
        Habit(
          id: DateTime.now().toString(),
          name: name,
          time: time,
          isCompleted: false,
        ),
      );
    });
  }

  // Fungsi Hapus Kebiasaan
  void _deleteHabit(int index) {
    setState(() {
      habits.removeAt(index);
    });
  }

  // Fungsi Toggle Status Selesai
  void _toggleHabit(int index, bool? value) {
    setState(() {
      habits[index].isCompleted = value ?? false;
    });
  }

  // Fungsi Reset Harian
  void _resetDaily() {
    setState(() {
      for (var habit in habits) {
        habit.isCompleted = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HabitHomePage(
        habits: habits,
        onAddHabit: _addHabit,
        onDeleteHabit: _deleteHabit,
        onToggleHabit: _toggleHabit,
        onResetDaily: _resetDaily,
      ),
      HistoryStatsPage(habits: habits),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Rutinitas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistik & History',
          ),
        ],
      ),
    );
  }
}

// ================= HARI Halaman 1: Dashboard Utama =================
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
          title: const Text('Tambah Kebiasaan Baru'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama Kebiasaan'),
              ),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(labelText: 'Waktu (Contoh: 07:00 AM)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
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
      appBar: AppBar(
        title: const Text('Daily Habit Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Harian',
            onPressed: onResetDaily,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Progres Hari Ini', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('$completedCount dari ${habits.length} kebiasaan selesai', style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: progressPercentage,
                      backgroundColor: Colors.grey[200],
                      color: Colors.indigo,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('${(progressPercentage * 100).toStringAsFixed(0)}%', style: const TextStyle
                      (fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Daftar Rutinitas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: habits.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada kebiasaan.\nTekan tombol + di bawah untuk menambah.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: habits.length,
                      itemBuilder: (context, index) {
                        final habit = habits[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: Checkbox(
                              value: habit.isCompleted,
                              onChanged: (val) => onToggleHabit(index, val),
                            ),
                            title: Text(
                              habit.name,
                              style: TextStyle(
                                decoration: habit.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                                color: habit.isCompleted ? Colors.grey : Colors.black,
                              ),
                            ),
                            subtitle: Text('Waktu: ${habit.time}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => onDeleteHabit(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ================= Halaman 2: History & Statistik (Diagram) =================
class HistoryStatsPage extends StatelessWidget {
  final List<Habit> habits;

  const HistoryStatsPage({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    int total = habits.length;
    int completed = habits.where((h) => h.isCompleted).length;
    int uncompleted = total - completed;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik & History Pencapaian')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Grafik Performa Hari Ini', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            total == 0
                ? const Expanded(
                    child: Center(
                      child: Text('Belum ada data untuk ditampilkan dalam grafik.\nSilakan tambahkan kebiasaan terlebih dahulu.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                    ),
                  )
                : Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: [
                                PieChartSectionData(
                                  color: Colors.green,
                                  value: completed.toDouble(),
                                  title: '$completed Selesai',
                                  radius: 50,
                                  titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                PieChartSectionData(
                                  color: Colors.orangeAccent,
                                  value: uncompleted.toDouble(),
                                  title: '$uncompleted Belum',
                                  radius: 50,
                                  titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.check_circle, color: Colors.green),
                                  title: const Text('Total Kebiasaan Selesai'),
                                  trailing: Text('$completed dari $total', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                                const Divider(),
                                ListTile(
                                  leading: const Icon(Icons.analytics, color: Colors.indigo),
                                  title: const Text('Persentase Keberhasilan'),
                                  trailing: Text('${total == 0 ? 0 : ((completed / total) * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}