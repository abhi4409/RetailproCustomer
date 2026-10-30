import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/address_viewmodel.dart';
class Manageaddress extends StatefulWidget {
  Manageaddress({
    super.key,
  });
  @override
  State<Manageaddress> createState() => _ManageaddressState();
}

class _ManageaddressState extends State<Manageaddress> {
  Future addAddressDialog(AddressViewmodel provider) async {
    await provider.prepareAddAddress();

    if (!mounted) {
      return;
    }
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<AddressViewmodel>(
          builder: (context, provider, child) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                "Add New Address",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: provider.type,
                      decoration: InputDecoration(
                        labelText: "Address Type",
                        hintText: "Home / Work / Other",
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: provider.name,
                      decoration: InputDecoration(
                        labelText: "Full Name",
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: provider.address,
                      decoration: InputDecoration(
                        labelText: "Street Address",
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: provider.city,
                      decoration: InputDecoration(
                        labelText: "City / District",
                      ),
                    ),
                    SizedBox(height: 8),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: provider.setDefault,
                      title: Text(
                        "Set as default address",
                        style: TextStyle(fontSize: 14),
                      ),
                      onChanged: (value) {
                        provider.changeDefault(value ?? false);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    provider.clearControllers();
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await provider.addAddress(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void editAddressDialog(
      AddressViewmodel provider,
      String id,
      Map<String, dynamic> data,
      ) {
    provider.prepareEditAddress(data);

    showDialog(
      context: context,
      builder: (context) {
        return Consumer<AddressViewmodel>(
          builder: (context, provider, child) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                "Edit Address",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: provider.type,
                      decoration: InputDecoration(
                        labelText: "Address Type",
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: provider.name,
                      decoration: InputDecoration(
                        labelText: "Full Name",
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: provider.address,
                      decoration: InputDecoration(
                        labelText: "Street Address",
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: provider.city,
                      decoration: InputDecoration(
                        labelText: "City / District",
                      ),
                    ),
                    SizedBox(height: 8),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: provider.setDefault,
                      title: Text(
                        "Set as default address",
                        style: TextStyle(fontSize: 14),
                      ),
                      onChanged: (value) {
                        provider.changeDefault(value ?? false);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    provider.clearControllers();
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await provider.updateAddress(context, id);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text("Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AddressViewmodel>(context);
    var user = provider.user;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text(
            "Please login first",
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "My Addresses",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: provider.addressStream(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        snapshot.error.toString(),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_off_outlined,
                            size: 60,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 12),
                          Text(
                            "No address added yet",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  var docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final snap = docs[index];
                      var data = snap.data();
                      bool isDefault = data['isDefault'] ?? false;

                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: isDefault
                              ? BorderSide(color: Colors.blue.shade300, width: 1.5)
                              : BorderSide.none,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.blue.shade50,
                                    child: Icon(
                                      Icons.location_on_outlined,
                                      color: Colors.blue,
                                      size: 22,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              data['type']?.toString() ?? "Home",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            if (isDefault) ...[
                                              SizedBox(width: 8),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.green.shade50,
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(
                                                    color: Colors.green.shade300,
                                                  ),
                                                ),
                                                child: Text(
                                                  "Default",
                                                  style: TextStyle(
                                                    color: Colors.green.shade800,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          data['name']?.toString() ?? "",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          data['address']?.toString() ?? "",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        Text(
                                          data['city']?.toString() ?? "",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Divider(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      editAddressDialog(
                                        provider,
                                        snap.id,
                                        data,
                                      );
                                    },
                                    icon: Icon(Icons.edit_outlined, size: 16),
                                    label: Text("Edit"),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.blue,
                                      side: BorderSide(color: Colors.blue),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  OutlinedButton.icon(
                                    onPressed: () async {
                                      await provider.deleteAddress(
                                        snap.id,
                                        isDefault,
                                      );
                                    },
                                    icon: Icon(Icons.delete_outline, size: 16),
                                    label: Text("Delete"),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: BorderSide(color: Colors.red),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  addAddressDialog(provider);
                },
                icon: Icon(Icons.add, size: 20),
                label: Text(
                  "Add New Address",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}