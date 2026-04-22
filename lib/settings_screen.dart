import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_manager.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final isDark = themeManager.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Mode Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.palette, color: themeManager.accentColor),
                      const SizedBox(width: 10),
                      const Text(
                        'Appearance',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: Text(
                      isDark ? 'Enabled' : 'Disabled',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    value: isDark,
                    activeColor: themeManager.accentColor,
                    secondary: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      color: themeManager.accentColor,
                    ),
                    onChanged: (value) {
                      themeManager.setThemeMode(
                        value ? ThemeMode.dark : ThemeMode.light,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Accent Color Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.color_lens, color: themeManager.accentColor),
                      const SizedBox(width: 10),
                      const Text(
                        'Accent Color',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Choose your favorite accent color:',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildColorOption(context, Colors.orange, 'Orange', themeManager),
                      _buildColorOption(context, Colors.blue, 'Blue', themeManager),
                      _buildColorOption(context, Colors.purple, 'Purple', themeManager),
                      _buildColorOption(context, Colors.green, 'Green', themeManager),
                      _buildColorOption(context, Colors.red, 'Red', themeManager),
                      _buildColorOption(context, Colors.teal, 'Teal', themeManager),
                      _buildColorOption(context, Colors.pink, 'Pink', themeManager),
                      _buildColorOption(context, Colors.indigo, 'Indigo', themeManager),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // About Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: themeManager.accentColor),
                      const SizedBox(width: 10),
                      const Text(
                        'About',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Version'),
                    subtitle: Text('2.0.0'),
                  ),
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Description'),
                    subtitle: Text(
                      'Speech to Indian Sign Language Translator with advanced features',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorOption(
    BuildContext context,
    Color color,
    String name,
    ThemeManager themeManager,
  ) {
    final isSelected = themeManager.accentColor.toARGB32() == color.toARGB32();

    return InkWell(
      onTap: () => themeManager.setAccentColor(color),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 32)
            : null,
      ),
    );
  }
}

