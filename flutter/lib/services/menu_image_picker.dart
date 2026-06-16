import '../models/picked_image_file.dart';
import 'menu_image_picker_stub.dart'
    if (dart.library.html) 'menu_image_picker_web.dart' as platform;

Future<PickedImageFile?> pickMenuImage() => platform.pickMenuImage();
