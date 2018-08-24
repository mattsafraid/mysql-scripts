
-- Instance information
-- ------------------------------------

SELECT VARIABLE_NAME
 , SUBSTR(VARIABLE_VALUE, 1, 127) AS VARIABLE_VALUE 
FROM performance_schema.global_variables
WHERE VARIABLE_NAME IN (
  'bind_address'
, 'binlog_format'
, 'datadir'
, 'event_scheduler'
, 'gtid_mode'
, 'log_bin'
, 'max_connections'
, 'port'
, 'innodb_file_per_table'
, 'slow_query_log'
, 'socket'
, 'version'
, 'innodb_buffer_pool_instances'
, 'innodb_numa_interleave'
, 'large_pages'
, 'innodb_page_size'
);

SELECT VARIABLE_NAME
 , VARIABLE_VALUE/1024/1024 AS VARIABLE_VALUE 
FROM performance_schema.global_variables
WHERE VARIABLE_NAME IN (
  'key_buffer_size'
, 'innodb_buffer_pool_size'
, 'innodb_log_buffer_size'
, 'thread_stack'
);

\! df -TPh | grep data

SHOW SLAVE HOSTS;
SHOW SLAVE STATUS;


--
-- Database information
-- ------------------------------------


 -- 
 -- Schema character info
CREATE  TEMPORARY TABLE TMP_CHARS AS 
SELECT	`SCHEMA_NAME` AS DB
    ,	DEFAULT_CHARACTER_SET_NAME
	,	DEFAULT_COLLATION_NAME
FROM	information_schema.SCHEMATA
WHERE	SCHEMA_NAME NOT IN ('sys', 'mysql', 'information_schema', 'performance_schema');

-- Schema counts on object details
CREATE TEMPORARY TABLE TMP_TABLES AS 
SELECT	TABLE_SCHEMA                                                  AS DB
    ,	count(1)                                                      AS NUM_TABLES
    ,	sum( CASE WHEN ENGINE = 'InnoDB'          THEN 1 ELSE 0 END ) AS NUM_INNODB
    ,	sum( CASE WHEN ENGINE = 'MyISAM'          THEN 1 ELSE 0 END ) AS NUM_MYISAM
    ,	sum( CASE WHEN ROW_FORMAT = 'Dynamic'     THEN 1 ELSE 0 END ) AS NUM_DYNAMIC
    ,	sum( CASE WHEN ROW_FORMAT = 'Compressed'  THEN 1 ELSE 0 END ) AS NUM_COMPRESSED
    ,	sum( CASE WHEN ROW_FORMAT = 'Compact'     THEN 1 ELSE 0 END ) AS NUM_COMPACT
    ,	sum( DATA_LENGTH  )                                 AS DATA_LENGTH
    ,	sum( INDEX_LENGTH )                                 AS INDEX_LENGTH
    ,	sum( DATA_FREE    )                                 AS DATA_FREE
FROM        information_schema.TABLES
WHERE       TABLE_TYPE = 'BASE TABLE'
AND  TABLE_SCHEMA NOT IN ('sys', 'mysql', 'information_schema', 'performance_schema')
GROUP BY    TABLE_SCHEMA;

-- 
-- Schema count of unused indexes per schema
CREATE TEMPORARY TABLE TMP_UNUSED AS 
SELECT      object_schema               AS DB
        ,   count(1)                    AS NUM_UNUSED_INDEXES
FROM        sys.schema_unused_indexes
GROUP BY    object_schema;

--
-- Schema count of redundant indexes per schema
CREATE TEMPORARY TABLE TMP_REDUNDANT AS 
SELECT      table_schema                AS DB
        ,	count(1)                    AS NUM_REDUNDANT_INDEXES
FROM        sys.schema_redundant_indexes
GROUP BY    table_schema;

-- 
-- Schema count on objects
CREATE TEMPORARY TABLE TMP_OBJECTS AS 
SELECT  db                                                     AS DB
    ,   max( if( object_type = 'BASE TABLE',    `count`, 0 ) ) AS BASE_TABLE
    ,   max( if( object_type = 'INDEX (BTREE)', `count`, 0 ) ) AS INDEX_BTREE
    ,   max( if( object_type = 'VIEW',          `count`, 0 ) ) AS `VIEW`
    ,   max( if( object_type = 'TRIGGER',       `count`, 0 ) ) AS `TRIGGER`
    ,   max( if( object_type = 'FUNCTION',      `count`, 0 ) ) AS `FUNCTION`
    ,   max( if( object_type = 'PROCEDURE',     `count`, 0 ) ) AS `PROCEDURE`
    ,   max( if( object_type = 'EVENT',         `count`, 0 ) ) AS `EVENT`
FROM        sys.schema_object_overview
GROUP BY    db;


SELECT *
FROM        TMP_CHARS       A
INNER JOIN  TMP_TABLES      B ON A.DB = B.DB
INNER JOIN  TMP_OBJECTS     C ON A.DB = C.DB
LEFT JOIN  TMP_UNUSED      D ON A.DB = D.DB
LEFT JOIN  TMP_REDUNDANT   E ON A.DB = E.DB\G
