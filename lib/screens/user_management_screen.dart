import 'dart:io';

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/validations_util.dart';
import '../widgets/validation_dialog.dart';
import '../models/profile_model.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../widgets/user_card.dart';
import 'notifications_screen.dart';
import 'package:image_picker/image_picker.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  UserManagementScreenState createState() => UserManagementScreenState();
}

class UserManagementScreenState extends State<UserManagementScreen> {
  late Future<List<User>> users;
  final List<String> roles = ["SUPERVISOR"];
  XFile? _selectedUserPhoto;
  List<XFile> _userPhotos = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    users = fetchUsers();
  }

  Future<List<User>> fetchUsers() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final response = await apiService.fetchData('users');
    return (response as List).map((data) => User.fromJson(data)).toList();
  }

  Future<void> addUser(BuildContext context, String userName, String email,
      String password, String roles, String fullName) async {
    final authService = Provider.of<AuthService>(context, listen: false);

    List<String> userRoles =
        roles.split(',').map((role) => role.trim()).toList();

    final result = await authService.registerUser(
        email, password, userName, fullName, userRoles, _selectedUserPhoto);

    if (!result['ok']) {
      print('error in adding user in user management screen');
    }
    List<User> updatedUsers = await fetchUsers();

    setState(() {
      users = Future.value(updatedUsers);
    });
  }

  Future<void> registerFace(User user) async {
    if (_userPhotos.length < 4 || user.id == null) {
      return;
    }
    final String userId = user.id!;
    final apiService = Provider.of<ApiService>(context, listen: false);

    final success = await apiService.registerFace(_userPhotos, userId);

    if (!mounted) return;
    if (success) {
      const ValidationDialog(
        title: 'todo chido',
        content: 'Try again, please',
        textButton: 'Ok',
      ).show(context);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UserManagementScreen()),
      );
    } else {
      const ValidationDialog(
        title: 'Something went wrong',
        content: 'Try again, please',
        textButton: 'Ok',
      ).show(context);
    }

    List<User> updatedUsers = await fetchUsers();
    setState(() {
      users = Future.value(updatedUsers);
      _userPhotos = [];
    });
  }

  Future<void> _showUserDialog(User user) async {
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Add Face to models'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: List.generate(4, (index) {
                        if (index < _userPhotos.length) {
                          return SizedBox(
                            width: 80,
                            height: 80,
                            child: Image.file(
                              File(_userPhotos[index].path),
                              fit: BoxFit.cover,
                            ),
                          );
                        } else {
                          return const SizedBox(
                            width: 80,
                            height: 80,
                            child: Icon(
                              Icons.image,
                              size: 80,
                              color: Colors.grey,
                            ),
                          );
                        }
                      }),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Take Photo'),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? photo =
                            await picker.pickImage(source: ImageSource.camera);
                        if (photo != null && _userPhotos.length < 4) {
                          setState(() {
                            _userPhotos.add(photo);
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Select from gallery'),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? photo =
                            await picker.pickImage(source: ImageSource.gallery);
                        if (photo != null && _userPhotos.length < 4) {
                          setState(() {
                            _userPhotos.add(photo);
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    setState(() {
                      _userPhotos.clear();
                    });
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text('Add Faces'),
                  onPressed: () {
                    registerFace(user);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
    //_selectedUserPhoto = null;
  }

  Future<void> _pickImage(Function setState) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _selectedUserPhoto = image;
    });
  }

  void _showAddUserDialog() async {
    String? userName;
    String? userEmail;
    String? password;
    String? userRoles;
    String? userFullName;
    String? imageError;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add User'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'User'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a username';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            userName = value;
                          },
                        ),
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an email';
                            } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(value)) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            userEmail = value;
                          },
                        ),
                        TextFormField(
                          decoration:
                              const InputDecoration(labelText: 'Password'),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            } else if (value.length < 6) {
                              return 'Password must be at least 6 characters long';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            password = value;
                          },
                        ),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Roles'),
                          items: roles.map((role) {
                            return DropdownMenuItem<String>(
                              value: role,
                              child: Text(role),
                            );
                          }).toList(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a role';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            userRoles = value;
                          },
                        ),
                        TextFormField(
                          decoration:
                              const InputDecoration(labelText: 'FullName'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the full name';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            userFullName = value;
                          },
                        ),
                        const SizedBox(height: 20),
                        _selectedUserPhoto != null
                            ? SizedBox(
                                width: 150,
                                height: 150,
                                child: Image.file(
                                  File(_selectedUserPhoto!.path),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image,
                                    size: 150,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'No image selected',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                        if (imageError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              imageError!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Select from Gallery'),
                          onPressed: () async {
                            await _pickImage(setState);
                            setState(() {
                              imageError = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    setState(() {
                      _selectedUserPhoto = null;
                    });
                    print(_selectedUserPhoto);
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text('Add'),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_selectedUserPhoto == null) {
                        setState(() {
                          imageError = 'Please select an image';
                        });
                        return;
                      }

                      addUser(
                        context,
                        userName ?? '',
                        userEmail ?? '',
                        password ?? '',
                        userRoles ?? '',
                        userFullName ?? '',
                      );
                      Navigator.of(context).pop();
                      setState(() {
                        _selectedUserPhoto = null;
                      });
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'VERIFIED':
        return Colors.green;
      case 'UNVERIFIED':
        return Colors.lightGreenAccent;
      case 'UNKNOWN':
        return Colors.orange;
      case 'Intruder':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset(
          fit: BoxFit.cover,
          'assets/logo1.png',
        ),
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications), //
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NotificationsScreen()),
              );
            },
          ),
          IconButton(
              icon: const Icon(Icons.add), onPressed: _showAddUserDialog),
        ],
      ),
      body: FutureBuilder<List<User>>(
        future: users,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found'));
          } else {
            //List<User> userList = snapshot.data!;

            final familyMembers =
                snapshot.data!.where((user) => user.isFamilyMember).toList();
            final otherMembers =
                snapshot.data!.where((user) => !user.isFamilyMember).toList();

            return ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Family members',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                ...familyMembers.map((user) => UserCard(
                      imageUrl: user.profile?.imageUrl,
                      name: user.profile!.fullName,
                      status: user.profile!.status,
                      statusColor: getStatusColor(user.profile!.status),
                      onTap: user.profile!.status.startsWith('UNVERIFIED')
                          ? () => _showUserDialog(user)
                          : null,
                    )),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Other members',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                ...otherMembers.map((user) => UserCard(
                      imageUrl: user.profile?.imageUrl,
                      name: user.profile!.fullName,
                      status: user.profile!.status,
                      statusColor: getStatusColor(user.profile!.status),
                      onTap: user.profile!.status.startsWith('UNVERIFIED')
                          ? () => _showUserDialog(user)
                          : null,
                    )),
              ],
            );
          }
        },
      ),
    );
  }
}
