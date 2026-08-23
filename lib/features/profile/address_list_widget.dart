import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/address_service.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/components/degloor_app_bar.dart';
import 'package:degloor_one/components/empty_state_view.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:degloor_one/features/profile/address_list_model.dart';
export 'package:degloor_one/features/profile/address_list_model.dart';

class AddressListWidget extends StatefulWidget {
  const AddressListWidget({super.key});

  static String routeName = 'AddressList';
  static String routePath = '/addressList';

  @override
  State<AddressListWidget> createState() => _AddressListWidgetState();
}

class _AddressListWidgetState extends State<AddressListWidget> {
  late AddressListModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  Future<List<AddressesRow>>? _addressesFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddressListModel());
    _fetchAddresses();
  }

  void _fetchAddresses() {
    setState(() {
      _addressesFuture = AddressService.instance.listForUser(currentUserUid);
    });
  }

  Future<void> _deleteAddress(String id) async {
    try {
      await AddressService.instance.delete(id: id, userId: currentUserUid);
      _fetchAddresses();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address deleted')),
      );
    } catch (e) {
      AppLogger.error('Error deleting address', e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLogger.userFacingMessage(
              e,
              fallback: 'Unable to delete the address. Please try again.',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _setDefaultAddress(String id) async {
    try {
      await AddressService.instance.setDefault(id: id, userId: currentUserUid);
      _fetchAddresses();
    } catch (e) {
      AppLogger.error('Error setting default address', e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLogger.userFacingMessage(
              e,
              fallback: 'Unable to update the default address. Please try again.',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _openAddAddress() async {
    await context.pushNamed('AddAddress');
    _fetchAddresses();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      appBar: degloorAppBar(context, title: 'Saved Addresses'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddAddress,
        backgroundColor: theme.primary,
        icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
        label: const Text('Add New', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: FutureBuilder<List<AddressesRow>>(
              future: _addressesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
                    ),
                  );
                }
                final addresses = snapshot.data ?? [];
                if (addresses.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.location_off_rounded,
                    title: 'No addresses yet',
                    description:
                        'Save home or work so checkout can deliver around Degloor.',
                    buttonText: 'Add address',
                    onTap: _openAddAddress,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                  itemCount: addresses.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12.0),
                  itemBuilder: (context, index) {
                    final addr = addresses[index];
                    return Card(
                      elevation: 0,
                      color: theme.secondaryBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: theme.alternate),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                addr.title ?? 'Address',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                            if (addr.isDefault)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'DEFAULT',
                                  style: TextStyle(
                                    color: theme.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            addr.addressText ?? '',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (val) {
                            if (val == 'delete') _deleteAddress(addr.id);
                            if (val == 'default') _setDefaultAddress(addr.id);
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'default',
                              child: Text('Set as Default'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
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
        ),
      ),
    );
  }
}
