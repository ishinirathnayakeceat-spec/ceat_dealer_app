import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/profile_service.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({Key? key}) : super(key: key);

  @override
  _ProfileSettingsPageState createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  Map<String, dynamic>? _profileDetails;
  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _loadProfileDetails();
  }

  Future<void> _loadProfileDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? dealerCode = prefs.getString('dealerCode');

    if (dealerCode != null) {
      try {
        final profile = await _profileService.fetchProfileDetails(dealerCode);
        setState(() {
          _profileDetails = profile;
        });
      } catch (e) {
        print("Error fetching profile details: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Profile Settings",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF003566),
        elevation: 4,
        centerTitle: true,
      ),
      body: _profileDetails == null
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("Profile"),
                    _buildModernProfileCard(),
                    const SizedBox(height: 24),
                    // _sectionTitle("Account Settings"),
                    // _buildAccountSettingsCard(),
                    // const SizedBox(height: 24),
                    // _sectionTitle("Security"),
                    // _buildChangePasswordCard(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xFF003566),
        ),
      ),
    );
  }

  Widget _buildModernProfileCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      shadowColor: Colors.grey.withOpacity(0.2),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF000000).withOpacity(0.9),
              const Color(0xFF154FA3).withOpacity(0.9),
              const Color(0xFF000000).withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileRow(
                icon: Icons.person_outline,
                label: "Dealer Code",
                value: _profileDetails?['zsDelCode']?.toString() ?? 'N/A',
              ),
              const Divider(height: 1, thickness: 1, color: Colors.grey),
              _buildProfileRow(
                icon: Icons.storefront_outlined,
                label: "Dealer Name",
                value: _profileDetails?['zsName'] ?? 'N/A',
              ),
              const Divider(height: 1, thickness: 1, color: Colors.grey),
              _buildProfileRow(
                icon: Icons.email_outlined,
                label: "Sales Person",
                value: _profileDetails?['name'] ?? 'N/A',
              ),
              const Divider(height: 1, thickness: 1, color: Colors.grey),
              _buildProfileRow(
                icon: Icons.email_outlined,
                label: "Sales Person Contact No",
                value: _profileDetails?['mobile'] != null
                    ? _profileDetails!['mobile']
                        .toString()
                        .replaceFirst('94', '0')
                    : 'N/A',
              ),
              const Divider(height: 1, thickness: 1, color: Colors.grey),
              _buildProfileRow(
                icon: Icons.email_outlined,
                label: "Email",
                value: _profileDetails?['zsEmail'] ?? 'N/A',
              ),
              const Divider(height: 1, thickness: 1, color: Colors.grey),
              _buildProfileRow(
                icon: Icons.location_on_outlined,
                label: "Address",
                value:
                    "${_profileDetails?['zsAddress1'] ?? 'N/A'}, ${_profileDetails?['zsAddress2'] ?? ''}, ${_profileDetails?['zsAddress3'] ?? ''}"
                        .trim(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFEF7300),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettingsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      shadowColor: Colors.grey.withOpacity(0.2),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // _settingsOption(
            //   icon: Icons.email_outlined,
            //   label: "Change Email",
            //   onPressed: () {},
            // ),
            // const Divider(height: 1, thickness: 1),
            // _settingsOption(
            //   icon: Icons.phone_android_outlined,
            //   label: "Change Phone Number",
            //   onPressed: () {},
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildChangePasswordCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      shadowColor: Colors.grey.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _settingsOption(
          icon: Icons.lock_outline,
          label: "Change Password",
          onPressed: () {},
        ),
      ),
    );
  }

  Widget _settingsOption({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: const Color(0xFF003566).withOpacity(0.1),
        child: Icon(icon, color: const Color(0xFFEF7300), size: 28),
      ),
      title: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing:
          Icon(Icons.chevron_right, color: Colors.grey.shade700, size: 28),
      onTap: onPressed,
    );
  }
}
