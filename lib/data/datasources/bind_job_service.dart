import 'package:degloor_one/backend/job_service.dart';
import 'package:degloor_one/core/api/api_client.dart';
import 'package:degloor_one/data/datasources/java_job_repository.dart';
import 'package:degloor_one/data/datasources/supabase_job_repository.dart';
import 'package:degloor_one/data/repositories/job_repository.dart';

/// Composition-root wiring for jobs. Domain code takes [JobRepository]
/// and must not import this file.
///
/// Java owns the tables when [JavaApiConfig.enabled]; otherwise showcase or
/// Supabase stays on [SupabaseJobRepository].
void bindJobService({JobRepository? repository}) {
  JobService.bind(
    repository ??
        (JavaApiConfig.enabled ? JavaJobRepository() : SupabaseJobRepository()),
  );
}
