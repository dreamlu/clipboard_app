import 'package:clipboard/clipboard.dart';
import 'package:workmanager/workmanager.dart';

void callbackTask() {
  Workmanager.executeTask((task, inputData) {
    print("后台任务开始"); //simpleTask will be emitted here.
//    Clip.init();
//    Clip.monitor();
    return Future.value(true);
  });
}
