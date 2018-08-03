-- tweak-indexes.sql
-- Shows options for using indexes in MySQL.

-- Sample table
-- Using Auto generated column, >= 5.7.6
CREATE TABLE IF NOT EXISTS INDEXTESTER (
  ID INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
  BIRTH_DATE   DATE,
  FIRST_NAME   VARCHAR (127),
  LAST_NAME    VARCHAR (127),
  EMAIL_NAME   VARCHAR (127),
  EMAIL_DOMAIN VARCHAR (127),
  FULL_NAME    VARCHAR (255) GENERATED ALWAYS AS concat(FIRST_NAME, LAST_NAME) STORED,
  EMAIL        VARCHAR (255) AS concat(EMAIL_NAME, '@', EMAIL_DOMAIN) VIRTUAL,
  INDEX        IDX_DOB (BIRTH_DATE)
);

-- * Auto-generated column: 
-- col_name data_type [GENERATED ALWAYS] AS (expression)
--   [VIRTUAL | STORED] [NOT NULL | NULL]
--   [UNIQUE [KEY]] [[PRIMARY] KEY]
--   [COMMENT 'string']


-- 
-- Leading index
-- Created only with the initial X characters from a character column.
-- Fixed CHAR records offer greater search performance.
-- Example: Only 5 starting characters from LAST_NAME
-- ---------------------------------------------------------------------------
CREATE INDEX IDX_LASTNAME_FIVE
  ON INDEXTESTER( LAST_NAME(5) );


-- 
-- Function-based index
-- Although MySQL does not offer such a construct we can use a virtual column
-- ---------------------------------------------------------------------------
CREATE INDEX IDX_FB_EMAIL 
  USING BTREE 
  ON INDEXTESTER(EMAIL) 
  COMMENT 'My fb-index comment';


-- 
-- Invisible index
-- Index is still maintained but not visible to the optimizer. 
-- ---------------------------------------------------------------------------
ALTER TABLE INDEXTESTER ALTER INDEX IDX_DOB INVISIBLE;


-- Cleanup
DROP TABLE IF EXISTS INDEXTESTER;
