import 'package:square_web/constants/constants.dart';
import 'package:square_web/model/contact/contact_model.dart';

class SquareMember extends ContactModel {
  final MemberStatus memberStatus;

  SquareMember.fromMap(Map<String, dynamic> map)
      : this.memberStatus = MemberStatus.values.byName(map['squareMemberStatus']),
        super.fromMap(map);
}

enum SquareMemberType {
  normal,
  ai
}