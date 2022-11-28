import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ms_customer_app/models/wishlist_model.dart';
import 'package:ms_customer_app/providers/wish_provider.dart';
import 'package:ms_customer_app/widgets/appbar_widgets.dart';
import 'package:provider/provider.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({
    super.key,
  });

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.grey.shade200,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            leading: const AppBarBackButton(),
            centerTitle: true,
            title: const AppBarTitle(title: 'Wishlist'),
            actions: [
              context.watch<Wishlist>().getWishlistItems.isEmpty
                  ? const SizedBox()
                  : IconButton(
                      onPressed: () {
                        showCupertinoModalPopup<void>(
                          context: context,
                          builder: (BuildContext context) =>
                              CupertinoAlertDialog(
                            title: const Text('Clear Wishlist'),
                            content: const Text('You sure to clear Wishlist ?'),
                            actions: <CupertinoDialogAction>[
                              CupertinoDialogAction(
                                isDefaultAction: true,
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('No'),
                              ),
                              CupertinoDialogAction(
                                isDestructiveAction: true,
                                onPressed: () {
                                  context.read<Wishlist>().clearWishlist();
                                  Navigator.pop(context);
                                },
                                child: const Text('Yes'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.delete_forever,
                        color: Colors.black,
                      ),
                    ),
            ],
          ),
          body: context.watch<Wishlist>().getWishlistItems.isNotEmpty
              ? const WishlistItems()
              : const EmptyWishlist(),
        ),
      ),
    );
  }
}

class EmptyWishlist extends StatelessWidget {
  const EmptyWishlist({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            'Your Wishlist Is Empty !',
            style: TextStyle(fontSize: 30),
          ),
        ],
      ),
    );
  }
}

class WishlistItems extends StatelessWidget {
  const WishlistItems({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<Wishlist>(
      builder: (context, wishlist, child) {
        return ListView.builder(
          itemCount: wishlist.count,
          itemBuilder: (context, index) {
            final product = wishlist.getWishlistItems[index];
            return WishlistModel(product: product);
          },
        );
      },
    );
  }
}
