------
--01--
------

CREATE TABLE DOKUMENTY (
    ID NUMBER(12) PRIMARY KEY,
    DOKUMENT CLOB
);

------
--02--
------

DECLARE
    lob clob := '';
    counter number := 0;
BEGIN
    LOOP
        lob := lob || 'Oto tekst. ';
        counter := counter + 1;
        IF counter LIKE 10000 THEN
            EXIT;
        END IF;
    END LOOP;
    INSERT INTO DOKUMENTY
    VALUES (1, lob);
END;

------
--03--
------

SELECT * FROM DOKUMENTY;

SELECT UPPER(DOKUMENT) FROM DOKUMENTY;

SELECT LENGTH(DOKUMENT) FROM DOKUMENTY;

SELECT DBMS_LOB.getlength(DOKUMENT) FROM DOKUMENTY;

------
--04--
------
INSERT INTO DOKUMENTY
VALUES (2, EMPTY_CLOB());

------
--05--
------
INSERT INTO DOKUMENTY
VALUES (3, NULL);

------
--06--
------

SELECT * FROM DOKUMENTY;

SELECT UPPER(DOKUMENT) FROM DOKUMENTY;

SELECT LENGTH(DOKUMENT) FROM DOKUMENTY;

SELECT DBMS_LOB.getlength(DOKUMENT) FROM DOKUMENTY;

------
--07--
------
SELECT DIRECTORY_NAME, DIRECTORY_PATH FROM ALL_DIRECTORIES;

------
--08--
------
DECLARE
    lob CLOB;
    file BFILE := BFILENAME('ZSBD_DIR', 'dokument.txt');
    doffset integer := 1;
    soffset integer := 1;
    langctx integer := 0;
    warn integer := null;
BEGIN
    SELECT DOKUMENT INTO lob
    FROM DOKUMENTY
    WHERE ID = 2
    FOR UPDATE;

    dbms_lob.fileopen(file, dbms_lob.file_readonly);
    dbms_lob.loadclobfromfile(lob, file, DBMS_LOB.LOBMAXSIZE, doffset, soffset, 873, langctx, warn);
    dbms_lob.fileclose(file);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Status operacji: '||warn);
END;

------
--09--
------

UPDATE DOKUMENTY
SET DOKUMENT = TO_CLOB(BFILENAME('ZSBD_DIR', 'dokument.txt'), 873)
WHERE ID=3;

------
--10--
------
SELECT * FROM DOKUMENTY;

------
--11--
------
SELECT ID, DBMS_LOB.getlength(DOKUMENT) FROM DOKUMENTY;

------
--12--
------
DROP TABLE DOKUMENTY;

------
--13--
------
CREATE OR REPLACE PROCEDURE CLOB_CENSOR
(input IN OUT clob, hide IN VARCHAR2)
IS
    dot VARCHAR2(100) := '.............................';
    position number := 0;
BEGIN
    LOOP
        position := INSTR (input, hide);
        IF position LIKE 0 THEN
            EXIT;
        END IF;
        DBMS_LOB.WRITE(input, length(hide), position, dot);
    END LOOP;
END;

------
--14--
------
CREATE TABLE BIOGRAPHIES AS SELECT * FROM ZSBD_TOOLS.BIOGRAPHIES;

SELECT * FROM BIOGRAPHIES;

DECLARE
    lob clob;
BEGIN
    SELECT BIO INTO lob FROM BIOGRAPHIES FOR UPDATE;
    CLOB_CENSOR(lob, 'Wikipedia');
    COMMIT;
END;

------
--15--
------
DROP TABLE BIOGRAPHIES;
