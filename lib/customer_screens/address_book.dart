import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ms_customer_app/customer_screens/add_address.dart';
import 'package:ms_customer_app/providers/id_provider.dart';
import 'package:ms_customer_app/widgets/appbar_widgets.dart';
import 'package:ms_customer_app/widgets/yellow_button.dart';
import 'package:provider/provider.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

class AddressBook extends StatefulWidget {
  const AddressBook({super.key});

  @override
  State<AddressBook> createState() => _AddressBookState();
}

class _AddressBookState extends State<AddressBook> {
  late String docId;
  @override
  void initState() {
    docId = context.read<IdProvider>().getData;
    super.initState();
  }

  Future dfAddressFalse(dynamic item) async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection('customers')
          .doc(docId)
          .collection('address')
          .doc(item.id);
      transaction.update(documentReference, {
        'default': false,
      });
    });
  }

  Future dfAddressTrue(dynamic customer) async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection('customers')
          .doc(docId)
          .collection('address')
          .doc(customer['addressid']);
      transaction.update(documentReference, {
        'default': true,
      });
    });
  }

  Future updateProfile(dynamic customer) async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection('customers').doc(docId);
      transaction.update(documentReference, {
        'address':
            '${customer['country']} ${customer['state']} ${customer['city']}',
        'phone': customer['phone'],
      });
    });
  }

  void showProgress() {
    ProgressDialog progress = ProgressDialog(context: context);
    progress.show(max: 100, msg: 'please wait ..', progressBgColor: Colors.red);
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> addressStream = FirebaseFirestore.instance
        .collection('customers')
        .doc(docId)
        .collection('address')
        .snapshots();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: const AppBarBackButton(),
        title: const AppBarTitle(title: 'Address Book'),
      ),
      body: SafeArea(
          child: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: addressStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Material(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'You have\'nt set \n\n an address yet',
                      style: GoogleFonts.acme(
                        fontSize: 26,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var customer = snapshot.data!.docs[index];
                    return Dismissible(
                      key: UniqueKey(),
                      onDismissed: (direction) async => await FirebaseFirestore
                          .instance
                          .runTransaction((transaction) async {
                        DocumentReference docReference = FirebaseFirestore
                            .instance
                            .collection('customers')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .collection('address')
                            .doc(customer['addressid']);
                        transaction.delete(docReference);
                      }),
                      child: GestureDetector(
                        onTap: () async {
                          showProgress();
                          for (var item in snapshot.data!.docs) {
                            await dfAddressFalse(item);
                          }

                          await dfAddressTrue(customer).whenComplete(
                              () async => await updateProfile(customer));

                          Future.delayed(const Duration(microseconds: 100))
                              .whenComplete(() => Navigator.pop(context));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            color: customer['default'] == true
                                ? Colors.white
                                : Colors.yellow,
                            child: ListTile(
                              trailing: customer['default'] == true
                                  ? const Icon(
                                      Icons.home,
                                      color: Colors.brown,
                                    )
                                  : const SizedBox(),
                              title: SizedBox(
                                height: 70,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${customer['firstname']} ${customer['lastname']}',
                                    ),
                                    Text(
                                      customer['phone'],
                                    ),
                                  ],
                                ),
                              ),
                              subtitle: SizedBox(
                                height: 50,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'City/State : ${customer['city']} ${customer['state']}',
                                    ),
                                    Text(
                                      'Country : ${customer['country']}',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          YellowButton(
            label: 'Add New Address',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddAddress(),
                ),
              );
            },
            width: 0.8,
          ),
        ],
      )),
    );
  }
}
