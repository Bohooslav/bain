COPY bolls_verses(translation, book, chapter, verse, text) FROM '/home/b/imba/Bibles/w.csv' DELIMITER ',' CSV HEADER;

SELECT * FROM bolls_verses ORDER BY BOOK, CHAPTER, VERSE

SELECT translation, count(id) FROM bolls_verses GROUP BY translation
SELECT * FROM bolls_verses where translation='LXX' ORDER BY BOOK, CHAPTER, VERSE

UPDATE bolls_verses SET text = ('') where translation='' and book=66  and chapter=21 and verse=12

INSERT INTO auth_permission VALUES
(5,'Can add log entry',2,'add_logentry'),
(6,'Can change log entry',2,'change_logentry'),
(7,'Can delete log entry',2,'delete_logentry'),
(8,'Can view log entry',2,'view_logentry'),
(9,'Can add permission',3,'add_permission'),
(10,'Can change permission',3,'change_permission'),
(11,'Can delete permission',3,'delete_permission'),
(12,'Can view permission',3,'view_permission'),
(13,'Can add group',4,'add_group'),
(14,'Can change group',4,'change_group'),
(15,'Can delete group',4,'delete_group'),
(16,'Can view group',4,'view_group'),
(17,'Can add user',5,'add_user'),
(18,'Can change user',5,'change_user'),
(19,'Can delete user',5,'delete_user'),
(20,'Can view user',5,'view_user'),
(21,'Can add content type',6,'add_contenttype'),
(22,'Can change content type',6,'change_contenttype'),
(23,'Can delete content type',6,'delete_contenttype'),
(24,'Can view content type',6,'view_contenttype'),
(25,'Can add session',7,'add_session'),
(26,'Can change session',7,'change_session'),
(27,'Can delete session',7,'delete_session'),
(28,'Can view session',7,'view_session'),
(29,'Can add verses',8,'add_verses'),
(30,'Can change verses',8,'change_verses'),
(31,'Can delete verses',8,'delete_verses'),
(32,'Can view verses',8,'view_verses');