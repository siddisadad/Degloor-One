import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      _addressesFuture = AddressesTable().queryRows(
        queryFn: (q) => q.eq('user_id', currentUserUid).order('created_at', ascending: false),
      );
    });
  }

  Future<void> _deleteAddress(String id) async {
    await AddressesTable().delete(matchingRows: (q) => q.eq('id', id));
    _fetchAddresses();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Address deleted')),
    );
  }

  Future<void> _setDefaultAddress(String id) async {
    // 1. Reset all others
    await AddressesTable().update(
      data: {'is_default': false},
      matchingRows: (q) => q.eq('user_id', currentUserUid),
    );
    // 2. Set this one
    await AddressesTable().update(
      data: {'is_default': true},
      matchingRows: (q) => q.eq('id', id),
    );
    _fetchAddresses();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        automaticallyImplyLeading: true,
        title: Text(
          'Saved Addresses',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                font: GoogleFonts.inter(),
                color: Colors.white,
                fontSize: 22.0,
              ),
        ),
        actions: [],
        centerTitle: false,
        elevation: 2.0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.pushNamed('AddAddress');
          _fetchAddresses();
        },
        backgroundColor: FlutterFlowTheme.of(context).primary,
        icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
        label: const Text('Add New', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        top: true,
        child: FutureBuilder<List<AddressesRow>>(
          future: _addressesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final addresses = snapshot.data ?? [];
            if (addresses.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_off_rounded, size: 64, color: FlutterFlowTheme.of(context).secondaryText),
                    const SizedBox(height: 16),
                    Text('No addresses saved yet.', style: FlutterFlowTheme.of(context).bodyMedium),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: addresses.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12.0),
              itemBuilder: (context, index) {
                final addr = addresses[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Row(
                      children: [
                        Text(addr.title ?? 'Address', style: const TextStyle(fontWeight: FontWeight.bold)),
                        if (addr.isDefault == true)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('DEFAULT', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(addr.addressText ?? ''),
                        if (addr.latitude != null && addr.longitude != null)
                          Text('Coords: ${addr.latitude?.toStringAsFixed(4)}, ${addr.longitude?.toStringAsFixed(4)}',
                               style: FlutterFlowTheme.of(context).labelSmall),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (val) {
                        if (val == 'delete') _deleteAddress(addr.id);
                        if (val == 'default') _setDefaultAddress(addr.id);
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'default', child: Text('Set as Default')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
