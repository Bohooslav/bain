COPY bolls_verses(translation, book, chapter, verse, text) FROM '/home/b/imba/Bibles/w.csv' DELIMITER ',' CSV HEADER;


SELECT * FROM bolls_verses ORDER BY BOOK, CHAPTER, VERSE

SELECT translation, count(id) FROM bolls_verses GROUP BY translation
SELECT * FROM bolls_verses where translation='LXX' ORDER BY BOOK, CHAPTER, VERSE



COPY bolls_verses(translation, book, chapter, verse, text) FROM '/home/b/imba/Bibles/ylt.csv' DELIMITER ' ' CSV HEADER;

COPY bolls_verses(translation, book, chapter, verse, text) FROM '/home/b/imba/Bibles/UBIO.csv' DELIMITER '|' CSV HEADER;

COPY bolls_verses(translation, book, chapter, verse, text) FROM '/home/b/imba/Bibles/UKRK.csv' DELIMITER ',' CSV HEADER;

COPY bolls_verses(translation, book, chapter, verse, text) FROM '/home/b/imba/Bibles/LXX.csv' DELIMITER ' ' CSV HEADER;

COPY bolls_verses(translation, book, chapter, verse, text) FROM '/home/b/imba/Bibles/RST77.csv' DELIMITER ',' CSV HEADER;

COPY bolls_verses(translation, book, chapter, verse, text) FROM '/home/b/imba/Bibles/CUV.csv' DELIMITER ',' CSV HEADER;

COPY bolls_verses(translation, book, chapter, verse, text) FROM '/home/b/imba/Bibles/NT_Greek.csv' DELIMITER ' ' CSV HEADER;

COPY bolls_verses(translation, book, chapter, verse, text) FROM '/home/b/imba/Bibles/arabic.csv' DELIMITER ' ' CSV HEADER;

COPY bolls_verses(translation, book, chapter, verse, text) FROM '/home/b/imba/Bibles/NASB.csv' DELIMITER ' ' CSV HEADER;

UPDATE bolls_verses SET text = ('') where translation='' and book=66  and chapter=21 and verse=12

Select * from bolls_verses where translation=''NASB'' and book=66  and chapter=21 and verse=12
