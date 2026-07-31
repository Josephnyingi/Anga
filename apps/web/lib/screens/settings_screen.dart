import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../utils/app_state.dart';
import 'debug_screen.dart';

/// Settings screen, backed by the shared AppState so changes here actually
/// take effect elsewhere in the app (location, units, forecast period, dark
/// mode) rather than living in screen-local variables nobody else reads.
class SettingsScreen extends StatefulWidget {
  final void Function(bool)? setTheme;

  const SettingsScreen({super.key, this.setTheme});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // If the farmer searched a location beyond the original two towns, include
  // it here too so the dropdown's value always matches one of its items.
  List<String> get _locations {
    const base = ['Machakos', 'Vhembe'];
    return base.contains(AppState.selectedLocation) ? base : [...base, AppState.selectedLocation];
  }
  String _selectedLanguage = 'English';

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(start: AppState.startDate, end: AppState.endDate),
    );
    if (picked != null) {
      setState(() {
        AppState.startDate = picked.start;
        AppState.endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildSectionCard(
              title: 'Location Preferences',
              icon: Icons.location_on,
              children: [
                _buildDropdownRow('Preferred Location', AppState.selectedLocation, _locations, (value) {
                  setState(() {
                    AppState.selectedLocation = value!;
                    if (value == 'Machakos' || value == 'Vhembe') {
                      // Switching back to a default town: clear any searched
                      // coordinates so the backend uses its whitelist path.
                      AppState.selectedLat = null;
                      AppState.selectedLon = null;
                    }
                  });
                }),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'Forecast Period',
              icon: Icons.calendar_today,
              children: [_buildDateRangeRow()],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'Units & Measurements',
              icon: Icons.straighten,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Use Celsius (°C)'),
                  value: AppState.isCelsius,
                  onChanged: (value) => setState(() => AppState.isCelsius = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Use Millimeters (mm)'),
                  value: AppState.isMillimeters,
                  onChanged: (value) => setState(() => AppState.isMillimeters = value),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'Notifications',
              icon: Icons.notifications,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Enable Notifications'),
                  subtitle: const Text('Receive weather alerts and updates'),
                  value: AppState.enableNotifications,
                  onChanged: (value) => setState(() => AppState.enableNotifications = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Severe Weather Alerts'),
                  subtitle: const Text('Get real-time extreme weather warnings'),
                  value: AppState.enableExtremeAlerts,
                  onChanged: (value) => setState(() => AppState.enableExtremeAlerts = value),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'Appearance',
              icon: Icons.palette,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Switch between light and dark themes'),
                  value: isDarkMode,
                  onChanged: (value) {
                    setState(() => AppState.isDarkMode = value);
                    widget.setTheme?.call(value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'Language',
              icon: Icons.language,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Language'),
                  subtitle: Text(_selectedLanguage),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _showLanguagePicker,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'About',
              icon: Icons.info_outline,
              children: [
                const ListTile(contentPadding: EdgeInsets.zero, title: Text('App Version'), subtitle: Text('1.0.0')),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showComingSoon('Privacy Policy'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showComingSoon('Terms of Service'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildActionButtons(),
            const SizedBox(height: 24),
            _buildDeveloperSection(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showLogoutDialog,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(Icons.person, size: 32, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ANGA User',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text('Location: ${AppState.selectedLocation}',
                    style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownRow(String label, String value, List<String> options, void Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            onChanged: onChanged,
            items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangeRow() {
    final fmt = DateFormat('MMM dd, yyyy');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _dateChip('From', fmt.format(AppState.startDate))),
            const SizedBox(width: 12),
            Expanded(child: _dateChip('To', fmt.format(AppState.endDate))),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _selectDateRange,
            icon: const Icon(Icons.edit_calendar),
            label: const Text('Change Date Range'),
          ),
        ),
      ],
    );
  }

  Widget _dateChip(String label, String date) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text(date, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _saveSettings,
            icon: const Icon(Icons.save),
            label: const Text('Apply Settings'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _showResetConfirmation,
            icon: const Icon(Icons.restore),
            label: const Text('Reset to Defaults'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeveloperSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.developer_mode, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                const Text('Developer Options', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('DEV',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Access API configuration, connectivity testing, and platform information for development and troubleshooting.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DebugScreen())),
                icon: const Icon(Icons.bug_report),
                label: const Text('Open Debug Configuration'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings applied successfully'), behavior: SnackBarBehavior.floating),
    );
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to their default values?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetSettings();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _resetSettings() {
    setState(() {
      AppState.selectedLocation = 'Machakos';
      AppState.startDate = DateTime.now();
      AppState.endDate = DateTime.now().add(const Duration(days: 6));
      AppState.isCelsius = true;
      AppState.isMillimeters = true;
      AppState.enableNotifications = true;
      AppState.enableExtremeAlerts = true;
      AppState.isDarkMode = false;
    });
    widget.setTheme?.call(false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings reset to defaults'), behavior: SnackBarBehavior.floating),
    );
  }

  void _showLanguagePicker() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Language'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              setState(() => _selectedLanguage = 'English');
              Navigator.pop(context);
            },
            child: const Text('English'),
          ),
          SimpleDialogOption(
            onPressed: () {
              setState(() => _selectedLanguage = 'Swahili');
              Navigator.pop(context);
            },
            child: const Text('Swahili'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$feature coming soon!')));
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
