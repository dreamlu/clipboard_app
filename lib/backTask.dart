import 'package:workmanager/workmanager.dart';

void callbackTask() {
  Workmanager.executeTask((task, inputData) {
    print("后台任务开始"); //simpleTask will be emitted here.
    return Future.value(true);
  });
}
