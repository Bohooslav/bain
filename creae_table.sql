COPY bolls_verses(translation, book, chapter, verse, text) FROM '/home/b/imba/Bibles/w.csv' DELIMITER ',' CSV HEADER;
COPY bolls_verses(translation, book, chapter, verse, text) FROM '/home/b/imba/Bibles/LUT.csv' DELIMITER '	' CSV HEADER;
COPY bolls_verses(translation, book, chapter, verse, text) FROM '/home/b/imba/Bibles/web.csv' DELIMITER '|' CSV HEADER;


SELECT * FROM bolls_verses ORDER BY BOOK, CHAPTER, VERSE

SELECT translation, count(id) FROM bolls_verses GROUP BY translation
SELECT * FROM bolls_verses where translation='LXX' ORDER BY BOOK, CHAPTER, VERSE

UPDATE bolls_verses SET text = ('') where translation='' and book=66  and chapter=21 and verse=12

\copy auth_user(id, password, last_login, is_superuser, username, first_name, last_name, email, is_staff, is_active, date_joined) FROM '/home/b/data-1583933238173.csv' DELIMITER ',' CSV HEADER;

psql    --host=bollsdb.cekf5swxirfn.us-east-2.rds.amazonaws.com    --port=5432    --username=postgres    --password    --dbname=bain

#8q^EMgAxWbmLGEp

\copy bolls_bookmarks(id,color,note,user_id,verse_id,date) FROM '/home/b/Downloads/bolls_bookmarks.csv' DELIMITER ',' CSV HEADER;

\copy bolls_verses(translation, book, chapter, verse, text) FROM '/home/b/imba/Bibles/verses.csv' DELIMITER '|' CSV HEADER;

\copy bolls_verses(translation, book, chapter, verse, text) FROM '/home/b/verses.csv' DELIMITER ';' CSV HEADER;


\copy (Select * From bolls_verses) To '/home/b/test.csv' With CSV DELIMITER '|';