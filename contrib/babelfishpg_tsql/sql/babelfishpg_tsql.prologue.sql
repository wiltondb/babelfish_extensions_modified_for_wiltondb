
/*
 * All objects created by the included files will be created in sys
 */

SELECT set_config('search_path', 'sys, '||current_setting('search_path'), false);