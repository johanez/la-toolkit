import 'package:la_toolkit/utils/StringUtils.dart';
import 'package:la_toolkit/utils/mapUtils.dart';
import 'package:test/test.dart';

void main() {
  test('Capitalize strings', () {
    String string = 'abc';
    expect(StringUtils.capitalize(string), equals('Abc'));
  });

  test('Capitalize strings', () {
    String string = 'a';
    expect(StringUtils.capitalize(string), equals('A'));
  });

  test('Capitalize empty strings', () {
    String string = "";
    expect(StringUtils.capitalize(string), equals(""));
  });

  test(
      'Given two LatLng points should generate LatLng variables for all services',
      () {
    // collectory uses the center:
    //   collectionsMap.centreMapLon=-8.66
    //   collectionsMap.centreMapLat=36.224
    // collectionsMap.defaultZoom=4
    // regions uses:
    //   map.bounds=[26.943, -18.848, 43.948, 4.805]
    // spatial
    //   lat: 38.8794495
    //   lng: -6.9706535
    //   zoom: 5
    //   defaultareas:
    //     - name: 'España'
    //       fqs: ['longitude:[-19.556 TO 5.493]', 'latitude:[26.588 TO 44.434]']
    //       wkt: 'POLYGON((-19.556 26.588, 5.493 26.588, 5.493 44.434, -19.556 44.434, -19.556 26.588))'
    //       areaSqKm: 4491002.4759
    //       bbox: [-19.556, 26.588, 5.493, 44.434]
    // List<double> mapBounds1stPoint = [44.4806, -19.4184];
    // List<double> mapBounds2ndPoint = [26.6767, 5.7989];

    List<double> mapBounds1stPoint = [40.0, 20.0];
    List<double> mapBounds2ndPoint = [20.0, 10.0];

    var invVariables = MapUtils.toInvVariables(mapBounds1stPoint[0],
        mapBounds1stPoint[1], mapBounds2ndPoint[0], mapBounds2ndPoint[1]);
    expect(invVariables['LA_collectory_map_centreMapLat'], equals(30));
    expect(invVariables['LA_collectory_map_centreMapLng'], equals(15));
    expect(invVariables['LA_spatial_map_lan'], equals(30));
    expect(invVariables['LA_spatial_map_lng'], equals(15));
    expect(invVariables["LA_regions_map_bounds"],
        equals('[40.0, 20.0, 20.0, 10.0]'));
    expect(invVariables["LA_spatial_map_areaSqKm"], equals(2390918.8297587633));
    expect(invVariables["LA_spatial_map_bbox"],
        equals('[40.0, 20.0, 20.0, 10.0]'));
    // print(invVariables);
  });
  test('Area calculation', () {
    const world = {
      'type': 'Polygon',
      'coordinates': [
        [
          [-180, -90],
          [-180, 90],
          [180, 90],
          [180, -90],
          [-180, -90]
        ]
      ]
    };
    expect(MapUtils.areaKm2(world), equals(511207893.3958111));
  });
}
