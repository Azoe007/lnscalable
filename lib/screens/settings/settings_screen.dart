import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/themes/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _downloadDirController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final downloadDir = prefs.getString(AppConstants.downloadDirKey) 
        ?? AppConstants.defaultDownloadDir;
    _downloadDirController.text = downloadDir;
  }

  Future void _saveDownloadDir(String dir) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.downloadDirKey, dir);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paramètres sauvegardés')),
      );
    }
  }

  @override
  void dispose() {
    _downloadDirController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réglages'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Download Directory
          _buildSection(
            title: 'Téléchargements',
            children: [
              TextField(
                controller: _downloadDirController,
                decoration: const InputDecoration(
                  labelText: 'Dossier de téléchargement',
                  hintText: '/storage/emulated/0/Download/LNCrawler',
                  prefixIcon: Icon(Icons.folder),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Les fichiers EPUB seront sauvegardés dans ce dossier',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _saveDownloadDir(_downloadDirController.text),
                icon: const Icon(Icons.save),
                label: const Text('Sauvegarder'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // About
          _buildSection(
            title: 'À propos',
            children: [
              const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Version'),
                subtitle: Text('1.0.0'),
              ),
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('Backend'),
                subtitle: const Text('http://localhost:8000'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Ouvrir les infos du backend
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Developer info
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.download,
                  size: 48,
                  color: AppColors.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 8),
                const Text(
                  'LNCrawler',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'v1.0.0 - Build 2024',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}