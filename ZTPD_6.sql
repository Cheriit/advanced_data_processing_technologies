

------
--1A--
------

select lpad('-',2*(level-1),'|-') || t.owner||'.'||t.type_name||' (FINAL:'||t.final||
', INSTANTIABLE:'||t.instantiable||', ATTRIBUTES:'||t.attributes||', METHODS:'||t.methods||')'
from all_types t
start with t.type_name = 'ST_GEOMETRY'
connect by prior t.type_name = t.supertype_name
 and prior t.owner = t.owner;

 ------
 --1B--
 ------

select distinct m.method_name
from all_type_methods m
where m.type_name like 'ST_POLYGON'
and m.owner = 'MDSYS'
order by 1;

------
--1C--
------
CREATE TABLE MYST_MAJOR_CITIES (
    FIPS_CNTRY VARCHAR2(2),
    CITY_NAME VARCHAR2(40),
    STGEOM ST_POINT
);

------
--1D--
------
DESCRIBE MAJOR_CITIES;

INSERT INTO MYST_MAJOR_CITIES
SELECT FIPS_CNTRY, CITY_NAME, ST_Point(GEOM) FROM MAJOR_CITIES;

SELECT * FROM MYST_MAJOR_CITIES;

------
--2A--
------

INSERT INTO MYST_MAJOR_CITIES
VALUES ('PL', 'Szczyrk', ST_POINT(SDO_GEOMETRY('POINT(19.036107 49.718655)', 8307)));

------
--2B--
------
DESCRIBE RIVERS;

SELECT NAME, SDO_UTIL.TO_WKTGEOMETRY(GEOM) AS WKT
FROM RIVERS;

------
--2C--
------
SELECT SDO_UTIL.TO_GMLGEOMETRY(ST_POINT.GET_SDO_GEOM(STGEOM)) GML
FROM MYST_MAJOR_CITIES
WHERE CITY_NAME LIKE 'Szczyrk';

------
--3A--
------
CREATE TABLE MYST_COUNTRY_BOUNDARIES
(
    FIPS_CNTRY VARCHAR2(2),
    CNTRY_NAME VARCHAR2(40),
    STGEOM ST_MULTIPOLYGON
);

------
--3B--
------
INSERT INTO MYST_COUNTRY_BOUNDARIES
SELECT FIPS_CNTRY, CNTRY_NAME, ST_Multipolygon(GEOM) FROM COUNTRY_BOUNDARIES;

------
--3C--
------
SELECT B.STGEOM.ST_GEOMETRYTYPE() TYPE, COUNT(*) COUNT
FROM MYST_COUNTRY_BOUNDARIES B
GROUP BY B.STGEOM.ST_GEOMETRYTYPE();

------
--3D--
------
SELECT B.STGEOM.ST_ISSIMPLE()
FROM MYST_COUNTRY_BOUNDARIES B;

------
--4A--
------
SELECT B.CNTRY_NAME, COUNT(*)
FROM MYST_COUNTRY_BOUNDARIES B, MYST_MAJOR_CITIES C
WHERE B.STGEOM.ST_CONTAINS(C.STGEOM) = 1
GROUP BY B.CNTRY_NAME;

------
--4B--
------
SELECT A.CNTRY_NAME A_NAME, B.CNTRY_NAME B_NAME
FROM MYST_COUNTRY_BOUNDARIES A, MYST_MAJOR_CITIES B
WHERE  B.CNTRY_NAME = 'Czech Republic' AND A.STGEOM.ST_TOUCHES(B.STGEOM) = 1;

------
--4C--
------
SELECT A.CNTRY_NAME, B.NAME
FROM MYST_COUNTRY_BOUNDARIES A, RIVERS B
WHERE A.CNTRY_NAME = 'Czech Republic' AND A.STGEOM.ST_INTERSECTS(ST_LINESTRING(B.GEOM)) = 1;

------
--4D--
------
SELECT SUM(B.STGEOM.ST_AREA()) POWIERZCHNIA FROM MYST_COUNTRY_BOUNDARIES B WHERE  B.cntry_name ='Czech Republic' OR  B.cntry_name ='Slovakia';

------
--4E--
------
SELECT B.STGEOM OBJEKT, B.STGEOM.ST_DIFFERENCE(ST_GEOMETRY(A.GEOM)).ST_GEOMETRYTYPE() WEGRY_BEZ
FROM WATER_BODIES A, MYST_COUNTRY_BOUNDARIES B
WHERE B.CNTRY_NAME = 'Hungary' AND A.NAME = 'Balaton';

------
--5A--
------
EXPLAIN PLAN FOR
SELECT A.CNTRY_NAME, COUNT(*)
FROM MYST_COUNTRY_BOUNDARIES A, MYST_MAJOR_CITIES B
WHERE SDO_WITHIN_DISTANCE(B.STGEOM, A.STGEOM, 'distance=100 unit=km') = 'TRUE' AND A.cntry_name = 'Poland'
GROUP BY A.cntry_name;

SELECT plan_table_output FROM table(dbms_xplan.display('plan_table', null, 'basic'));

------
--5B--
------
INSERT INTO USER_SDO_GEOM_METADATA
SELECT 'MYST_MAJOR_CITIES', 'STGEOM', T.DIMINFO, T.SRID
FROM   ALL_SDO_GEOM_METADATA T WHERE  T.TABLE_NAME = 'MAJOR_CITIES';

INSERT INTO USER_SDO_GEOM_METADATA
SELECT 'MYST_COUNTRY_BOUNDARIES', 'STGEOM', T.DIMINFO, T.SRID
FROM   ALL_SDO_GEOM_METADATA T WHERE  T.TABLE_NAME = 'COUNTRY_BOUNDARIES';

------
--5C--
------
CREATE INDEX MYST_MAJOR_CITIES_IDX on MYST_MAJOR_CITIES(STGEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX;

CREATE INDEX MYST_COUNTRY_BOUNDARIES_IDX on MYST_COUNTRY_BOUNDARIES(STGEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX;

------
--5D--
------
EXPLAIN PLAN FOR
SELECT A.CNTRY_NAME, COUNT(*)
FROM MYST_COUNTRY_BOUNDARIES A, MYST_MAJOR_CITIES B
WHERE SDO_WITHIN_DISTANCE(B.STGEOM, A.STGEOM, 'distance=100 unit=km') = 'TRUE' AND A.cntry_name = 'Poland'
GROUP BY A.cntry_name;

SELECT plan_table_output FROM table(dbms_xplan.display('plan_table', null, 'basic'));

SELECT A.CNTRY_NAME, COUNT(*)
FROM MYST_COUNTRY_BOUNDARIES A, MYST_MAJOR_CITIES B
WHERE SDO_WITHIN_DISTANCE(B.STGEOM, A.STGEOM, 'distance=100 unit=km') = 'TRUE' AND A.cntry_name = 'Poland'
GROUP BY A.cntry_name;
