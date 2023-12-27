import 'package:app_backend/controller/trekko.dart';
import 'package:app_backend/model/account/account_data.dart';

class LinkedTrekko implements Trekko {

  final AccountData accountData;

  LinkedTrekko(this.accountData);

  void test() {

  }
}