import 'package:degloor_one/backend/user_service.dart';
import 'package:degloor_one/core/api/api_client.dart';
import 'package:degloor_one/data/datasources/java_user_repository.dart';
import 'package:degloor_one/data/datasources/supabase_user_repository.dart';
import 'package:degloor_one/data/repositories/user_repository.dart';

/// Composition-root wiring for user profiles. Domain code takes
/// [UserRepository] and must not import this file.
///
/// Java owns the table when [JavaApiConfig.enabled]; otherwise showcase or
/// Supabase stays on [SupabaseUserRepository].
void bindUserService({UserRepository? repository}) {
  UserService.bind(
    repository ??
        (JavaApiConfig.enabled
            ? JavaUserRepository()
            : SupabaseUserRepository()),
  );
}
