import 'package:json_annotation/json_annotation.dart';

part 'result.g.dart';

Result getResultList(Map<String, dynamic> map) {
  Result result = Result.fromJson(map);
//  list.forEach((item) {
//    result.add(Result.fromJson(item));
//  });
  return result;
}

@JsonSerializable()
class Result {
  Result(this.status, this.msg, this.data);

  String status;
  String msg;
  Object data;

  factory Result.fromJson(Map<String, dynamic> srcJson) =>
      _$ResultFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ResultToJson(this);
}
