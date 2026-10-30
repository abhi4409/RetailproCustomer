import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/profile_viewmodel.dart';

class Mypro extends StatefulWidget {
  Mypro({
    super.key,
  });

  @override
  State<Mypro> createState() => _MyproState();
}

class _MyproState extends State<Mypro> {
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ProfileViewmodel>(
      context,
    );

    if (provider.loading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          "Your Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.blue.shade100,
                    backgroundImage: provider.profileImage != null
                        ? MemoryImage(
                      provider.profileImage!,
                    )
                        : provider.profileImageUrl.isNotEmpty
                        ? NetworkImage(
                      provider.profileImageUrl,
                    )
                        : null,
                    child: provider.profileImage == null &&
                        provider.profileImageUrl.isEmpty
                        ? Icon(
                      Icons.person,
                      size: 70,
                      color: Colors.blue,
                    )
                        : null,
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
                        radius: 18,
                        child: provider.imageUploading
                            ? Padding(
                          padding: EdgeInsets.all(5),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                "Tap camera icon to change profile picture",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ),
            SizedBox(height: 25),
            Container(
              padding: EdgeInsets.all(18),
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
                  TextField(
                    controller: provider.name,
                    readOnly: !provider.edit,
                    decoration: InputDecoration(
                      labelText: "Name",
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: Colors.blue,
                      ),
                      filled: true,
                      fillColor: provider.edit
                          ? Colors.grey.shade50
                          : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 14),
                  TextField(
                    controller: provider.phone,
                    readOnly: !provider.edit,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Mobile Number",
                      prefixIcon: Icon(
                        Icons.phone_outlined,
                        color: Colors.blue,
                      ),
                      filled: true,
                      fillColor: provider.edit
                          ? Colors.grey.shade50
                          : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 14),
                  TextField(
                    controller: provider.email,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: Colors.blue,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 14),
                  TextField(
                    controller: provider.role,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Role",
                      prefixIcon: Icon(
                        Icons.verified_user_outlined,
                        color: Colors.blue,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 25),
            SizedBox(
              height: 48,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (!provider.edit) {
                    provider.enableEdit();
                  } else {
                    await provider.updateProfile(
                      context,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(
                  provider.edit ? Icons.save : Icons.edit,
                  size: 20,
                ),
                label: Text(
                  provider.edit ? "Save Profile" : "Edit Profile",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}