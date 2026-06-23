import 'package:taapdeel/viewobject/common/ps_object.dart';

abstract class PsMapObject<T> extends PsObject<T> {
  int? sorting;

  List<String> getIdList(List<T> mapList);
}
