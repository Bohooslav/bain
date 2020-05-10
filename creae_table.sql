COPY bolls_verses(translation, book, chapter, verse, text) FROM '/home/b/imba/Bibles/w.csv' DELIMITER ',' CSV HEADER;
COPY bolls_verses(translation, book, chapter, verse, text) FROM '/home/b/imba/Bibles/LUT.csv' DELIMITER '	' CSV HEADER;
COPY bolls_verses(translation, book, chapter, verse, text) FROM '/home/b/Bibles/meng.csv' DELIMITER '|' CSV HEADER;


SELECT * FROM bolls_verses ORDER BY BOOK, CHAPTER, VERSE

SELECT translation, count(id) FROM bolls_verses GROUP BY translation
-- SELECT book_number, count(chapter) FROM verses where verse = 1 GROUP BY book_number;
SELECT * FROM bolls_verses where translation='LXX' ORDER BY BOOK, CHAPTER, VERSE

UPDATE bolls_verses SET text = ('') where translation='' and book=66  and chapter=21 and verse=12

\copy auth_user(id, password, last_login, is_superuser, username, first_name, last_name, email, is_staff, is_active, date_joined) FROM '/home/b/data-1583933238173.csv' DELIMITER ',' CSV HEADER;

psql    --host=bollsdb.cekf5swxirfn.us-east-2.rds.amazonaws.com    --port=5432    --username=postgres    --password    --dbname=bain

#8q^EMgAxWbmLGEp

\copy bolls_bookmarks(id,color,note,user_id,verse_id,date) FROM '/home/b/Downloads/bolls_bookmarks.csv' DELIMITER ',' CSV HEADER;

\copy bolls_verses(translation, book, chapter, verse, text) FROM '/home/b/Bibles/verses.csv' DELIMITER '|' CSV HEADER;

\copy (Select * From bolls_verses) To '/home/b/test.csv' With CSV DELIMITER '|';


-- Fix broken sequences
CREATE OR REPLACE FUNCTION "reset_sequence" (tablename text, columnname text)
RETURNS "pg_catalog"."void" AS
$body$
DECLARE
BEGIN
    EXECUTE 'SELECT setval( pg_get_serial_sequence(''' || tablename || ''', ''' || columnname || '''),
    (SELECT COALESCE(MAX(id)+1,1) FROM ' || tablename || '), false)';
END;
$body$  LANGUAGE 'plpgsql';

select table_name || '_' || column_name || '_seq', reset_sequence(table_name, column_name) from information_schema.columns where column_default like 'nextval%';