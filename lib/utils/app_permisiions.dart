import 'package:permission_handler/permission_handler.dart';

class AppPermission {
  Future<bool> permissionHandler(context, {permissionName}) async {
    Map<PermissionGroup, PermissionStatus> permissions;

    switch (permissionName) {
      case 'camera':
        permissions = await PermissionHandler().requestPermissions([
          PermissionGroup.camera,
          PermissionGroup.storage,
        ]);
        if (permissions[PermissionGroup.camera] == PermissionStatus.granted &&
            permissions[PermissionGroup.storage] == PermissionStatus.granted) {
          return true;
        }
        return false;
        break;
      case 'location':
        permissions = await PermissionHandler().requestPermissions([
          PermissionGroup.locationAlways,
        ]);
        if (permissions[PermissionGroup.locationAlways] ==
            PermissionStatus.granted) {
          return true;
        }
        return false;
        break;
      // case 'ignoreBatteryOptimizations':
      //   permissions = await PermissionHandler().requestPermissions([
      //     PermissionGroup.ignoreBatteryOptimizations,
      //   ]);
      //   if (permissions[PermissionGroup.ignoreBatteryOptimizations] ==
      //       PermissionStatus.granted) {
      //     return true;
      //   }
      //   return false;
      //   break;
      default:
        permissions = await PermissionHandler().requestPermissions([
          PermissionGroup.storage,
          PermissionGroup.camera,
          PermissionGroup.locationAlways,
          PermissionGroup.phone,
        ]);

        // SharedPreferenceService utilities = locator<SharedPreferenceService>();
        // await utilities.getInstance();
        if (permissions[PermissionGroup.storage] == PermissionStatus.granted &&
            permissions[PermissionGroup.locationAlways] ==
                PermissionStatus.granted &&
            permissions[PermissionGroup.phone] == PermissionStatus.granted &&
            permissions[PermissionGroup.camera] == PermissionStatus.granted) {
          return true;
        } else {
          return false;
        }
        break;
    }
  }
}
