
/*
 * Remove schema sys from search_path otherwise it causes BABEL-257 for some reason
 * Notice schema sys will be automatically added to implicitly-searched namespaces by
 * recomputeNamespacePath() in tsql dialect
 */
SELECT set_config('search_path', trim(leading 'sys, ' from current_setting('search_path')), false);
RESET client_min_messages;
