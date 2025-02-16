import 'package:supabase/supabase.dart' show PostgrestException;
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  // 1. Check if user is in team_members table
  static Future<bool> isTeamMember(String phoneNumber) async {
    const HphoneNumber = '+919373398091';
    try {
      final response = await client
          .from('team_members')
          .select('id')
          .eq('phone_number', HphoneNumber)
          .maybeSingle(); // Use maybeSingle to handle cases where no user is found
      print(phoneNumber);
      if (response == null) {
        print(response);

        // No user found
        return false;
      } else {
        return true; // User found in team_members
      }
    } catch (e) {
      print('Error checking team member: $e');
      return false; // Handle error as not a team member for security
    }
  }

  // 2. Sign in with OTP
  static Future<bool> signInWithOTP(String phoneNumber) async {
    try {
      await client.auth
          .signInWithOtp(phone: phoneNumber); // Await the OTP sending
      return true; // Assume success if no exception is thrown during sending
    } on AuthException catch (error) {
      // Catch specific AuthException for OTP sending errors
      print('Supabase OTP Sign-in Error: ${error.message}');
      return false;
    } catch (e) {
      // Catch other potential errors
      print('Error signing in with OTP: $e');
      return false;
    }
  }

  // Get Current User ID
  static String? getCurrentUserId() {
    return client.auth.currentUser?.id;
  }

  // 3. Get Voter Issues (with optional category filter)
  // 3. Get Voter Issues (with optional category filter)
  static Future<List<Map<String, dynamic>>> getVoterIssues(
      {String? category}) async {
    try {
      PostgrestFilterBuilder<PostgrestList> query =
          client // Explicitly type as PostgrestFilterBuilder
              .from('voter_issues')
              .select('*');

      if (category != null && category != 'all') {
        query = query.eq('category', category); // Apply filter FIRST
      }

      final PostgrestTransformBuilder<PostgrestList>
          transformedQuery = // New variable for transformed query
          query.order('created_at', ascending: false); // Then apply order

      final response = await transformedQuery; // Await the transformed query

      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      } else if (response is PostgrestException) {
        // print('Supabase Error fetching voter issues: ${response.message}');
        return [];
      } else {
        print(
            'Supabase Error: Unexpected response format for voter issues: $response');
        return [];
      }
    } catch (e) {
      print('Error fetching voter issues: $e');
      return [];
    }
  }

  // 5. Update problem status to "processing" and set solver
  static Future<bool> setProblemToProcessing(
      String problemId, String solverId) async {
    try {
      final response = await client.from('voter_issues').update(
          {'status': 'processing', 'solver': solverId}).eq('id', problemId);

      if (response is PostgrestException) {
        print(
            'Supabase Error setting problem to processing: ${response.message}');
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print('Error setting problem to processing: $e');
      return false;
    }
  }

  // 6. Update problem status to "done"
  static Future<bool> setProblemToDone(String problemId) async {
    try {
      final response = await client
          .from('voter_issues')
          .update({'status': 'done'}).eq('id', problemId);

      if (response is PostgrestException) {
        print('Supabase Error setting problem to done: ${response.message}');
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print('Error setting problem to done: $e');
      return false;
    }
  }

  // 6. Update problem status to "pending" (Leave)
  static Future<bool> setProblemToPending(String problemId) async {
    try {
      final response = await client.from('voter_issues').update({
        'status': 'pending',
        'solver': null
      }) // Clear solver when leaving
          .eq('id', problemId);

      if (response is PostgrestException) {
        print('Supabase Error setting problem to pending: ${response.message}');
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print('Error setting problem to pending: $e');
      return false;
    }
  }

  // Sign Out
  static Future<void> signOut() async {
    await client.auth.signOut();
  }
}
