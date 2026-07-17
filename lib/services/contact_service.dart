import 'package:supabase_flutter/supabase_flutter.dart';

class ContactService {
  static final _db = Supabase.instance.client;

  static Future<bool> submitMessage({
    required String name,
    required String email,
    String? phone,
    required String message,
  }) async {
    try {
      await _db.from('contact_messages').insert({
        'name': name,
        'email': email,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        'message': message,
      });
      return true;
    } catch (_) {
      return false;
    }
  }
}
