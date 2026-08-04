import 'package:flutter_test/flutter_test.dart';
import 'package:ecosim_flutter/features/auth/data/models/user_model.dart';

void main() {
  group('UserModel Tests', () {
    test('fromJson should parse correctly', () {
      final json = {'id': 'user-1', 'email': 'test@example.com'};
      final model = UserModel.fromJson(json);

      expect(model.id, 'user-1');
      expect(model.email, 'test@example.com');
    });

    test('toJson should convert correctly', () {
      final model = UserModel(id: 'user-2', email: 'test2@example.com');
      final json = model.toJson();

      expect(json['id'], 'user-2');
      expect(json['email'], 'test2@example.com');
    });
  });
}
