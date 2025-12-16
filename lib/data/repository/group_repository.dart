import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../service/auth_service.dart';
import '../model/group.dart';

class GroupRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  AuthService get _auth => Get.find<AuthService>();

  String? get _uid => _auth.user.value?.uid;

  // Retrieve groups from Firestore. If empty, seed default groups.
  Future<List<Group>> getGroups() async {
    if (_uid == null) return [];

    try {
      final collectionRef = _firestore
          .collection('users')
          .doc(_uid)
          .collection('groups');

      final snapshot = await collectionRef.get();

      if (snapshot.docs.isEmpty) {
        // Seed default groups
        await _seedDefaultGroups(collectionRef);
        // Re-fetch after seeding
        final newSnapshot = await collectionRef.get();
        return newSnapshot.docs
            .map((doc) => Group.fromMap(doc.data()))
            .toList();
      }

      return snapshot.docs.map((doc) => Group.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error fetching groups: $e');
      return [];
    }
  }

  Future<void> _seedDefaultGroups(CollectionReference collection) async {
    final defaultGroups = [
      Group(id: 'family', name: '가족', colorValue: 0xFFFFD1DC),
      Group(id: 'friend', name: '지인', colorValue: 0xFFFFF5BA),
      Group(id: 'work', name: '직장', colorValue: 0xFFD4F0F0),
      Group(id: 'etc', name: '기타', colorValue: 0xFFE0E0E0),
    ];

    final batch = _firestore.batch();
    for (var group in defaultGroups) {
      final docRef = collection.doc(group.id);
      batch.set(docRef, group.toMap());
    }
    await batch.commit();
  }

  Future<void> addGroup(Group group) async {
    if (_uid == null) return;
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('groups')
        .doc(group.id)
        .set(group.toMap());
  }

  Future<Group?> getGroup(String id) async {
    if (_uid == null) return null;
    try {
      final doc = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('groups')
          .doc(id)
          .get();

      if (doc.exists && doc.data() != null) {
        return Group.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateGroup(Group group) async {
    if (_uid == null) return;
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('groups')
        .doc(group.id)
        .update(group.toMap());
  }

  Future<void> deleteGroup(String id) async {
    if (_uid == null) return;
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('groups')
        .doc(id)
        .delete();
  }
}
