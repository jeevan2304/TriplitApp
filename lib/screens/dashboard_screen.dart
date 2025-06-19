import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _groupNameController = TextEditingController();
  final _memberEmailController = TextEditingController();

  final _tripNameController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  final _expenseTitleController = TextEditingController();
  final _expenseAmountController = TextEditingController();

  String? _currentGroupId;
  String? _currentTripId;

  Map<String, double> _debts = {};

  @override
  void initState() {
    super.initState();
    _loadDebts();
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _memberEmailController.dispose();
    _tripNameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _expenseTitleController.dispose();
    _expenseAmountController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Triplit Dashboard"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            tooltip: "View Debts",
            onPressed: _debts.isNotEmpty ? _showDebtDialog : null,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Create a Group",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(hintText: "Enter group name"),

            ),
            ElevatedButton(
              onPressed: _createGroup,
              child: const Text("Create Group"),
            ),
            const SizedBox(height: 20),
            if (_currentGroupId != null) ...[
              const Text("Add Members by Gmail", style: TextStyle(fontSize: 18)),
              TextField(
                controller: _memberEmailController,
                decoration: const InputDecoration(hintText: "Enter member Gmail"),
              ),
              ElevatedButton(
                onPressed: _addMemberToGroup,
                child: const Text("Add Member"),
              ),
              const SizedBox(height: 20),
              const Text("Plan a Trip", style: TextStyle(fontSize: 18)),
              TextField(
                controller: _tripNameController,
                decoration: const InputDecoration(hintText: "Enter trip name"),
              ),
              TextField(
                controller: _startDateController,
                decoration: const InputDecoration(hintText: "Enter start date (YYYY-MM-DD)"),
              ),
              TextField(
                controller: _endDateController,
                decoration: const InputDecoration(hintText: "Enter end date (YYYY-MM-DD)"),
              ),
              ElevatedButton(
                onPressed: _createTrip,
                child: const Text("Create Trip"),
              ),
              const SizedBox(height: 20),
              const Text("Add Expense", style: TextStyle(fontSize: 18)),
              TextField(
                controller: _expenseTitleController,
                decoration: const InputDecoration(hintText: "Enter expense title"),
              ),
              TextField(
                controller: _expenseAmountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: "Enter amount"),
              ),
              ElevatedButton(
                onPressed: _addExpense,
                child: const Text("Add Expense & Split"),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: error ? Colors.red : Colors.green,
    ));
  }

  Future<void> _createGroup() async {
    final groupName = _groupNameController.text.trim();
    final currentUser = _auth.currentUser;
    if (groupName.isEmpty || currentUser == null) {
      _showMessage("Group name cannot be empty.", error: true);
      return;
    }

    final docRef = await _firestore.collection('groups').add({
      'name': groupName,
      'createdBy': currentUser.uid,
      'members': [currentUser.email],
      'createdAt': FieldValue.serverTimestamp(),
    });

    _groupNameController.clear();
    setState(() => _currentGroupId = docRef.id);
    _showMessage("Group created successfully!");
  }

  Future<void> _addMemberToGroup() async {
    if (_currentGroupId == null) return;
    final email = _memberEmailController.text.trim();
    if (email.isEmpty) {
      _showMessage("Member email cannot be empty.", error: true);
      return;
    }

    await _firestore.collection('groups').doc(_currentGroupId).update({
      'members': FieldValue.arrayUnion([email])
    });

    _memberEmailController.clear();
    _showMessage("Member added successfully!");
  }

  Future<void> _createTrip() async {
    if (_currentGroupId == null) return;

    final tripName = _tripNameController.text.trim();
    final startDate = _startDateController.text.trim();
    final endDate = _endDateController.text.trim();

    if (tripName.isEmpty || startDate.isEmpty || endDate.isEmpty) {
      _showMessage("Trip details cannot be empty.", error: true);
      return;
    }

    final tripRef = await _firestore.collection('groups')
        .doc(_currentGroupId)
        .collection('trips')
        .add({
      'name': tripName,
      'startDate': startDate,
      'endDate': endDate,
      'createdAt': FieldValue.serverTimestamp(),
    });

    _tripNameController.clear();
    _startDateController.clear();
    _endDateController.clear();
    setState(() => _currentTripId = tripRef.id);
    _showMessage("Trip created successfully!");
  }

  Future<void> _addExpense() async {
    if (_currentGroupId == null || _currentTripId == null) return;

    final title = _expenseTitleController.text.trim();
    final amount = double.tryParse(_expenseAmountController.text.trim()) ?? 0;

    if (title.isEmpty || amount <= 0) {
      _showMessage("Invalid expense input.", error: true);
      return;
    }

    final groupDoc = await _firestore.collection('groups')
        .doc(_currentGroupId)
        .get();
    final members = List<String>.from(groupDoc.data()?['members'] ?? []);

    final perHead = amount / members.length;
    final splitDetails = { for (var m in members) m: perHead };

    // Generate a unique expense ID
    final expenseDoc = _firestore
        .collection('groups')
        .doc(_currentGroupId)
        .collection('trips')
        .doc(_currentTripId)
        .collection('expenses')
        .doc(); // creates a reference with an ID

    await expenseDoc.set({
      'expenseId': expenseDoc.id, // storing expense ID
      'title': title,
      'amount': amount,
      'paidBy': _auth.currentUser?.email,
      'splitBetween': members,
      'splitDetails': splitDetails,
      'createdAt': FieldValue.serverTimestamp(),
    });

    _expenseTitleController.clear();
    _expenseAmountController.clear();
    _showMessage("Expense added and split successfully!");
  }

  Future<Map<String, double>> _calculateUserDebtsByPerson() async {
    final userEmail = _auth.currentUser?.email;
    if (userEmail == null) return {};

    Map<String, double> debtMap = {};

    // Find all groups the user is part of
    final groupsSnapshot = await _firestore.collection('groups')
        .where('members', arrayContains: userEmail)
        .get();

    for (var groupDoc in groupsSnapshot.docs) {
      final groupId = groupDoc.id;

      // Fetch all trips in the group
      final tripsSnapshot = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('trips')
          .get();

      for (var tripDoc in tripsSnapshot.docs) {
        final tripId = tripDoc.id;

        // Fetch all expenses in the trip
        final expensesSnapshot = await _firestore
            .collection('groups')
            .doc(groupId)
            .collection('trips')
            .doc(tripId)
            .collection('expenses')
            .get();

        for (var expenseDoc in expensesSnapshot.docs) {
          final data = expenseDoc.data();
          final paidBy = data['paidBy'];
          final splitDetails = Map<String, dynamic>.from(data['splitDetails'] ?? {});

          if (paidBy != null &&
              paidBy != userEmail &&
              splitDetails.containsKey(userEmail)) {
            final amount = (splitDetails[userEmail] ?? 0).toDouble();
            debtMap[paidBy] = (debtMap[paidBy] ?? 0) + amount;
          }
        }
      }
    }

    return debtMap;
  }


  Future<void> _loadDebts() async {
    final debts = await _calculateUserDebtsByPerson();
    setState(() {
      _debts = debts;
    });

    if (_debts.isNotEmpty) {
      Future.delayed(Duration.zero, _showDebtDialog);
    }
  }

  void _showDebtDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("You owe your friends"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _debts.entries.map((entry) {
              return ListTile(
                leading: const Icon(Icons.money_off, color: Colors.red),
                title: Text(entry.key),
                subtitle: Text("₹${entry.value.toStringAsFixed(2)}"),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
