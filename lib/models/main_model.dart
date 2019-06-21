import 'package:scoped_model/scoped_model.dart';

import 'package:photo_gallery/models/user_settings_model.dart';

class MainModel extends Model with LoadAllValuesUserModel, UserSettingsModel {}
