import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSettingsModel extends Model {}

abstract class LoadAllValuesUserModel extends UserSettingsModel {
  void loadAllUserValues() async {
    final SharedPreferences persistance = await SharedPreferences.getInstance();
  }
}
