import 'package:cloud_firestore/cloud_firestore.dart';

class databaseService {
  final String? uid;
  databaseService({this.uid});

//reference for collections

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("groups");

  //updating the userdata

  Future savingUserData(String fullName, String email) async {
    return await userCollection.doc(uid).set({
      "fullName": fullName,
      "email": email,
      "groups": [],
      "profilePic": "",
      "uid": uid
    });
  }
  //getting user data

  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

//get user groups
  getUserGroups() async {
    return userCollection.doc(uid).snapshots();
  }

  //creating a group'

  Future CreateGroup(String UserName, String id, String groupName) async {
    DocumentReference groupdocumentReference = await groupCollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$UserName",
      "members": [],
      "groupId": "",
      "recentMessage": null,
      "recentMessageSenders": null,
    });

    //update the members
    await groupdocumentReference.update({
      "members": FieldValue.arrayUnion([
        "($uid)_$UserName",
      ]),
      "groupId": groupdocumentReference.id,
    });

    DocumentReference userDocumentReference = await userCollection.doc(uid);
    return await userDocumentReference.update({
      "groups": FieldValue.arrayUnion(
        ["${groupdocumentReference.id}_$groupName"],
      )
    });
  }

  //getting the chat
  getChats(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  Future getGroupAdmin(String groupId) async {
    DocumentReference d = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot['admin'];
  }

  //get group members
  getGroupMembers(String groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }
}