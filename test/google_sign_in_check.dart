import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  test('GoogleSignIn constructor check', () {
    final googleSignIn = GoogleSignIn(clientId: 'test');
    expect(googleSignIn, isNotNull);
  });
}
