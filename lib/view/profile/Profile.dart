import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/profile_viewmodel.dart';
import '../Orders/My_orders.dart';
import '../home/Myfavorates.dart';
import 'Myprofile.dart';
import 'Passchange.dart';
import 'Privacy_policy.dart';
import 'adress.dart';

class Profi extends StatefulWidget {
  Profi({
    super.key,
  });

  @override
  State<Profi> createState() => _ProfiState();
}

class _ProfiState extends State<Profi> {
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ProfileViewmodel>(
      context,
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: provider.loading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: EdgeInsets.all(18),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue.shade50,
                          border: Border.all(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: provider.profileImage != null
                              ? Image.memory(
                            provider.profileImage!,
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                          )
                              : provider.profileImageUrl.isNotEmpty
                              ? Image.network(
                            provider.profileImageUrl,
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                            loadingBuilder:
                                (context, child, progress) {
                              if (progress == null) {
                                return child;
                              }
                              return Center(
                                child:
                                CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              );
                            },
                            errorBuilder:
                                (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                size: 45,
                                color: Colors.blue,
                              );
                            },
                          )
                              : Icon(
                            Icons.person,
                            size: 45,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: provider.imageUploading
                              ? null
                              : () async {
                            await provider.pickProfileImage(
                              context,
                            );
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.blue,
                            radius: 14,
                            child: provider.imageUploading
                                ? Padding(
                              padding: EdgeInsets.all(3),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.name.text.isEmpty
                              ? "Customer"
                              : provider.name.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.email_outlined,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                provider.email.text,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                provider.phone.text.isEmpty
                                    ? "No phone number"
                                    : provider.phone.text,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Mypro(),
                        ),
                      );

                      if (!mounted) return;
                      await provider.getProfile();
                    },
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade50,
                      child: Icon(
                        Icons.person_outline,
                        color: Colors.blue,
                      ),
                    ),
                    title: Text(
                      "My Profile",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      "View and edit your profile",
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  Divider(height: 1, indent: 70),
                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Myordes(),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.shade50,
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        color: Colors.orange,
                      ),
                    ),
                    title: Text(
                      "My Orders",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      "Track and view your orders",
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  Divider(height: 1, indent: 70),
                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Fevorates(),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      backgroundColor: Colors.red.shade50,
                      child: Icon(
                        Icons.favorite_outline,
                        color: Colors.red,
                      ),
                    ),
                    title: Text(
                      "My Favorites",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      "View your favorite products",
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  Divider(height: 1, indent: 70),
                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Manageaddress(),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.shade50,
                      child: Icon(
                        Icons.location_on_outlined,
                        color: Colors.green,
                      ),
                    ),
                    title: Text(
                      "My Addresses",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      "Manage your delivery addresses",
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  Divider(height: 1, indent: 70),
                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Changepa(),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo.shade50,
                      child: Icon(
                        Icons.lock_outline,
                        color: Colors.indigo,
                      ),
                    ),
                    title: Text(
                      "Change Password",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      "Change your password",
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  Divider(height: 1, indent: 70),
                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Terms(
                            mdFilename: 'terms.md',
                          ),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.shade100,
                      child: Icon(
                        Icons.info_outline,
                        color: Colors.black87,
                      ),
                    ),
                    title: Text(
                      "Privacy Policy",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      "Terms and privacy policy",
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  Divider(height: 1, indent: 70),
                  ListTile(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: Text("Logout"),
                            content: Text(
                              "Are you sure you want to logout?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                },
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  Navigator.pop(dialogContext);
                                  await provider.signout(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text("Logout"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    leading: CircleAvatar(
                      backgroundColor: Colors.red.shade50,
                      child: Icon(
                        Icons.logout,
                        color: Colors.red,
                      ),
                    ),
                    title: Text(
                      "Logout",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                    subtitle: Text(
                      "Sign out from your account",
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}