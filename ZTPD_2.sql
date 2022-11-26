------
--01--
------
CREATE TABLE MOVIES (
    ID NUMBER(12) PRIMARY KEY,
    TITLE VARCHAR2(400) NOT NULL,
    CATEGORY VARCHAR2(50),
    YEAR CHAR(4),
    CAST VARCHAR2(4000),
    DIRECTOR VARCHAR2(4000),
    STORY VARCHAR2(4000),
    PRICE NUMBER(5,2),
    COVER BLOB,
    MIME_TYPE VARCHAR2(50)
);

------
--02--
------
DESCRIBE DESCRIPTIONS;
DESCRIBE COVERS;

INSERT INTO MOVIES
SELECT  D.ID, D.TITLE, D.CATEGORY, SUBSTR(D.YEAR, 0, 4), D.CAST, D.DIRECTOR, D.STORY, D.PRICE, C.IMAGE, C.MIME_TYPE
FROM DESCRIPTIONS D FULL OUTER JOIN COVERS C ON  D.ID=C.MOVIE_ID;

SELECT * FROM MOVIES;

------
--03--
------

SELECT ID, TITLE
FROM MOVIES
WHERE COVER IS NULL;

------
--04--
------

SELECT ID, TITLE, DBMS_LOB.getlength(COVER) AS FILESIZE
FROM MOVIES
WHERE COVER IS NOT NULL;

------
--05--
------

SELECT ID, TITLE, DBMS_LOB.getlength(COVER) AS FILESIZE
FROM MOVIES
WHERE COVER IS NULL;

------
--06--
------

SELECT DIRECTORY_NAME, DIRECTORY_PATH FROM ALL_DIRECTORIES;

------
--07--
------

UPDATE MOVIES
SET COVER = EMPTY_BLOB(), MIME_TYPE='image/jpeg'
WHERE ID = 65;
COMMIT;

------
--08--
------

SELECT ID, TITLE, DBMS_LOB.getlength(COVER) AS FILESIZE
FROM MOVIES
WHERE ID IN (65, 66);

------
--09--
------

DECLARE
    lob BLOB;
    file BFILE := BFILENAME('ZSBD_DIR', 'escape.jpg');
BEGIN
    SELECT COVER INTO lob
    FROM MOVIES
    WHERE ID = 65
    FOR UPDATE;

    dbms_lob.fileopen(file, dbms_lob.file_readonly);
    dbms_lob.loadfromfile(lob, file, dbms_lob.getlength(file));
    dbms_lob.fileclose(file);

    COMMIT;
END;

------
--10--
------945

CREATE TABLE TEMP_COVERS (
    movie_id NUMBER(12),
    image BFILE,
    mime_type VARCHAR2(50)
);

------
--11--
------

INSERT INTO TEMP_COVERS VALUES (65, BFILENAME('ZSBD_DIR', 'eagles.jpg'), 'image/jpeg');
COMMIT;

------
--12--
------

SELECT movie_id, dbms_lob.getlength(image) AS FILESIZE
FROM TEMP_COVERS;

------
--13--
------

DECLARE
    typ VARCHAR2(50);
    lob BLOB;
    file BFILE;
BEGIN
    SELECT image, mime_type INTO file, typ
    FROM TEMP_COVERS;

    dbms_lob.createtemporary(lob, TRUE);

    dbms_lob.fileopen(file, dbms_lob.file_readonly);
    dbms_lob.loadfromfile(lob, file, dbms_lob.getlength(file));
    dbms_lob.fileclose(file);

    UPDATE MOVIES
    SET COVER=lob, MIME_TYPE=typ
    WHERE ID=65;

    COMMIT;

    dbms_lob.freetemporary(lob);
END;

------
--14--
------

SELECT ID, DBMS_LOB.getlength(COVER) AS FILESIZE
FROM MOVIES
WHERE ID IN (65, 66);

------
--15--
------

DROP TABLE MOVIES;
DROP TABLE TEMP_COVERS;
