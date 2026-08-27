import 'package:degloor_one/components/button/button_widget.dart';
import 'package:degloor_one/components/location_item/location_item_widget.dart';
import 'package:degloor_one/components/slider/slider_widget.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_google_map.dart' hide LatLng;
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'location_radius_selector_widget.dart' show LocationRadiusSelectorWidget;
import 'package:flutter/material.dart';

class LocationRadiusSelectorModel
    extends FlutterFlowModel<LocationRadiusSelectorWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for Button.
  late ButtonModel buttonModel1;
  // State field(s) for Map Google Map widget.
  LatLng? mapGoogleMapsCenter;
  final mapGoogleMapsController = Completer<GoogleMapController>();
  // Model for Slider.
  late SliderModel sliderModel;
  // Model for LocationItem.
  late LocationItemModel locationItemModel1;
  // Model for LocationItem.
  late LocationItemModel locationItemModel2;
  // Model for LocationItem.
  late LocationItemModel locationItemModel3;
  // Model for Button.
  late ButtonModel buttonModel2;

  @override
  void initState(BuildContext context) {
    buttonModel1 = createModel(context, () => ButtonModel());
    sliderModel = createModel(context, () => SliderModel());
    locationItemModel1 = createModel(context, () => LocationItemModel());
    locationItemModel2 = createModel(context, () => LocationItemModel());
    locationItemModel3 = createModel(context, () => LocationItemModel());
    buttonModel2 = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    buttonModel1.dispose();
    sliderModel.dispose();
    locationItemModel1.dispose();
    locationItemModel2.dispose();
    locationItemModel3.dispose();
    buttonModel2.dispose();
  }
}
