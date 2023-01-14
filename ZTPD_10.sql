------
--01--
------

CREATE TABLE CYTATY AS SELECT * FROM ZSBD_TOOLS.cytaty;

------
--02--
------

SELECT AUTOR, TEKST 
FROM CYTATY
WHERE LOWER(TEKST) LIKE '%pesymista%' AND LOWER(tekst) LIKE '%optymista%';

------
--03--
------

CREATE INDEX CYTATY_TEKST_INDEX
ON CYTATY(TEKST)
INDEXTYPE IS CTXSYS.CONTEXT;

------
--04--
------

SELECT AUTOR, TEKST 
FROM CYTATY
WHERE CONTAINS(TEKST 'pesymista AND optymista', 1) > 0;

------
--05--
------
SELECT AUTOR, TEKST
FROM CYTATY
WHERE CONTAINS(TEKST 'pesymista ~ optymista', 1) > 0;

------
--06--
------
SELECT AUTOR, TEKST
FROM CYTATY
WHERE CONTAINS(TEKST 'NEAR((pesymista, optymista), 3)', 1) > 0;

------
--07--
------
SELECT AUTOR, TEKST
FROM CYTATY
WHERE CONTAINS(TEKST 'NEAR((pesymista, optymista), 10)', 1) > 0;

------
--08--
------
SELECT AUTOR, TEKST
FROM CYTATY
WHERE CONTAINS(TEKST 'życi%', 1) > 0;

------
--09--
------
SELECT AUTOR, TEKST, SCORE(1) AS DOPASOWANIE
FROM CYTATY
WHERE CONTAINS(TEKST, 'życi%', 1) > 0;

------
--10--
------
SELECT AUTOR, TEKST, SCORE(1) AS DOPASOWANIE
FROM CYTATY
WHERE CONTAINS(TEKST, 'życi%', 1) > 0 AND ROWNUM <= 1
ORDER BY 3 DESC;

------
--11--
------
SELECT AUTOR, TEKST 
FROM CYTATY
WHERE CONTAINS(TEKST, 'FUZZY(PROBLEM)', 1) > 0;

------
--12--
------
INSERT INTO CYTATY VALUES(
    1000, 
    'Bertrand Russell',
    'To smutne, że głupcy są tacy pewni siebie, a ludzie rozsądni tacy pełni wątpliwości.'
);
COMMIT;

------
--13--
------
SELECT AUTOR, TEKST 
FROM CYTATY
WHERE CONTAINS(TEKST, 'głupcy', 1) > 0;

------
--14--
------
SELECT TOKEN_TEXT 
FROM DR$CYTATY_TEKST_IDX$I
WHERE TOKEN_TEXT = 'głupcy';

------
--15--
------
DROP INDEX CYTATY_TEKST_IDX;
CREATE INDEX CYTATY_TEKST_IDX
ON CYTATY(TEKST)
INDEXTYPE IS CTXSYS.CONTEXT;

------
--16--
------
SELECT AUTOR, TEKST
FROM CYTATY
WHERE CONTAINS(TEKST, 'głupcy', 1) > 0;

------
--17--
------
DROP INDEX CYTATY_TEKST_IDX;
DROP TABLE CYTATY;

---------------------------------------

------
--01--
------
CREATE TABLE QUOTES 
AS SELECT * FROM ZSBD_TOOLS.QUOTES;

------
--02--
------
CREATE INDEX QUOTES_TEXT_IDX ON QUOTES(TEXT) INDEXTYPE IS CTXSYS.CONTEXT;

------
--03--
------
SELECT AUTOR, TEXT
FROM QUOTES
WHERE CONTAINS(TEXT, 'work', 1) > 0;

SELECT AUTOR, TEXT
FROM QUOTES
WHERE CONTAINS(TEXT, '$work', 1) > 0;

SELECT AUTOR, TEXT
FROM QUOTES
WHERE CONTAINS(TEXT, 'working', 1) > 0;

SELECT AUTOR, TEXT
FROM QUOTES
WHERE CONTAINS(TEXT, '$working', 1) > 0;

------
--04--
------
SELECT AUTHOR, TEXT 
FROM QUOTES
WHERE CONTAINS(TEXT, 'it', 1) > 0;

------
--05--
------
SELECT * 
FROM CTX_STOPLISTS;

------
--06--
------
SELECT * 
FROM CTX_STOPWORDS;

------
--07--
------
DROP INDEX QUOTES_TEXT_IDX;
CREATE INDEX QUOTES_TEXT_IDX
ON QUOTES(TEXT) 
INDEXTYPE IS CTXSYS.CONTEXT PATAMETERS ('stoplist CTXSYS.EMPTY_STOPLIST');

------
--08--
------
Tak

------
--09--
------
SELECT AUTHOR, TEXT
FROM QUOTES
WHERE CONTAINS(TEXT, 'fool or humans', 1) > 0;

------
--10--
------
SELECT AUTHOR, TEXT
FROM QUOTES
WHERE CONTAINS(TEXT, 'fool or computer', 1) > 0;

------
--11--
------
SELECT AUTHOR, TEXT
FROM QUOTES
WHERE CONTAINS(TEXT, '(fool and computer) within sentence', 1) > 0;

------
--12--
------
DROP INDEX QUOTES_TEXT_IDX;

------
--13--
------
BEGIN
    CTX_DLL.CREATE_SECTION_GROUP('nullgroup', 'NULL_SECTION_GROUP');
    CTX_DLL.CREATE_SECTION_GROUP('nullgroup', 'SENTENCE');
    CTX_DLL.CREATE_SECTION_GROUP('nullgroup', 'PARAGRAPH');
END;

------
--14--
------
CREATE INDEX QUOTES_TEXT_IDX
ON QUOTES(TEXT)
INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS ('stoplist CTXSYS.EMPTY_STOPLIST section group nullgroup');

------
--15--
------
SELECT AUTHOR, TEXT 
FROM QUOTES
WHERE CONTAINS(TEXT, '(fool and humans) within sentence', 1) > 0;

------
--16--
------
SELECT AUTHOR, TEXT
FROM QUOTES
WHERE CONTAINS(TEXT, '(fool and computer) within sentence', 1) > 0;

------
--17--
------
DROP INDEX QUOTES_TEXT_IDX;
BEGIN
    CTX_DLL.CREATE_PREFERENCE('lex_z_m', 'BASIC_LEXER');
    CTX_DLL.SET_ATTRIBUTE('lex_z_m', 'printjoints', '_-');
    CTX_DLL.SET_ATTRIBUTE('lex_z_m', 'index_text', 'YES');
END;
CREATE INDEX QUOTES_TEXT_IDX
ON QUOTES(TEXT)
INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS('stoplist CTXSYS.EMPTY_STOPLIST section group nullgroup LEXER lex_z_m');

------
--18--
------
Nie

------
--19--
------
SELECT AUTHOR, TEXT
FROM QUOTES
WHERE CONTAINS(TEXT, 'non\-humans', 1) > 0;