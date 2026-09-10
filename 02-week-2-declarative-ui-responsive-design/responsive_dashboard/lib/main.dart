import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

const kWideBreakpoint = 900.0; // poin 3: breakpoint jadi 1 konstanta

void main() => runApp(const DashboardApp());

class DashboardApp extends StatefulWidget {
  const DashboardApp({super.key});

  @override
  State<DashboardApp> createState() => _DashboardAppState();
}

class _DashboardAppState extends State<DashboardApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark, colorSchemeSeed: Colors.indigo),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: DashboardPage(
        isDark: isDark,
        onDarkChanged: (value) => setState(() => isDark = value),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    required this.isDark,
    required this.onDarkChanged,
    super.key,
  });
  final bool isDark;
  final ValueChanged<bool> onDarkChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          Row(
            children: [
              Icon(isDark ? Icons.dark_mode : Icons.light_mode),
              const SizedBox(width: 4),
              Semantics(
                label: isDark ? 'Ganti ke mode terang' : 'Ganti ke mode gelap',
                child: CupertinoSwitch(
                  value: isDark,
                  onChanged: onDarkChanged,
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          const ProfileHeader(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= kWideBreakpoint ? 2 : 1; // poin 3
                return GridView.count(
                  padding: const EdgeInsets.all(16),
                  crossAxisCount: columns,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.6,
                  children: const [
                    InfoCard(title: 'Assignments', value: '8'),
                    InfoCard(title: 'Attendance', value: '92%'),
                    InfoCard(title: 'Portfolio', value: 'Ready'),
                    InfoCard(title: 'Current week', value: '02'),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Profil mahasiswa',
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer, // poin 2: dari theme
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Theme.of(context).colorScheme.primary, // poin 2
              child: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.onPrimary, // poin 2
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Salma Nur Anindhia', 
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer, // poin 2
                        ),
                  ),
                  Text(
                    '244107020186, 3F', 
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer, // poin 2
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

class InfoCard extends StatelessWidget {
  const InfoCard({required this.title, required this.value, super.key});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title: $value',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            Expanded(child: Text(title)),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
          ]),
        ),
      ),
    );
  }
}