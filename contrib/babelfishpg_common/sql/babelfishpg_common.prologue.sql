/*
 * All objects created by the included files will be created in sys
 */


CREATE SCHEMA sys;
GRANT USAGE ON SCHEMA sys TO PUBLIC;


SELECT set_config('search_path', 'sys, '||current_setting('search_path'), false);