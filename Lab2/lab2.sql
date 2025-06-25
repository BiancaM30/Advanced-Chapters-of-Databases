SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public';

SELECT * FROM geography_columns;

SELECT * FROM towns;

/* 1. Folosind tabela "towns", rezolvati urmatoarele:
1.1 Gasiti orasul sau orasele (numele si suprafata) ce au cea mai mare, respectiv cea mai mica suprafata, 
folosind o singura interogare*/
-- v1. using shape_area column directly
SELECT town, shape_area,
    CASE 
       WHEN shape_area = (SELECT MAX(shape_area) FROM towns) THEN 'Biggest town'
       WHEN shape_area = (SELECT MIN(shape_area) FROM towns) THEN 'Smallest town'
    END AS size_category
FROM towns
WHERE shape_area = (SELECT MAX(shape_area) FROM towns) 
OR shape_area = (SELECT MIN(shape_area) FROM towns);

-- v2. compute area with function
SELECT town, ST_Area(geom) AS computed_area,
       CASE 
           WHEN ST_Area(geom) = (SELECT MAX(ST_Area(geom)) FROM towns) THEN 'Biggest town'
           WHEN ST_Area(geom) = (SELECT MIN(ST_Area(geom)) FROM towns) THEN 'Smallest town'
       END AS size_category
FROM towns
WHERE ST_Area(geom) = (SELECT MAX(ST_Area(geom)) FROM towns)
   OR ST_Area(geom) = (SELECT MIN(ST_Area(geom)) FROM towns);


/* 1.2. Pentru orasele din tabela towns care au doar cresteri ale populatiei (vezi coloanele pop* sau popch*) 
gasiti lungimea perimetrului*/
-- v1. using shape_len column directly
SELECT town, popch80_90, popch90_00, popch00_10, shape_len AS perimeter_length
FROM towns
WHERE popch80_90 > 0 
  AND popch90_00 > 0 
  AND popch00_10 > 0;
  
-- v2. compute perimeter with function
SELECT town, popch80_90, popch90_00, popch00_10, ST_Perimeter(geom) AS perimeter_length
FROM towns
WHERE popch80_90 > 0 
  AND popch90_00 > 0 
  AND popch00_10 > 0;

/* 1.3. Verificati daca exista orase care au forma de poligon cu goluri (puteti returna true/false sau, 
numele oraselor, respectiv null, daca nu sunt)*/
SELECT town,
       CASE 
           WHEN ST_NumInteriorRings(geom) > 0 THEN 'True'
           ELSE 'False'
       END AS poly_with_holes
FROM towns
WHERE ST_GeometryType(geom) = 'ST_Polygon' OR ST_GeometryType(geom) = 'ST_MultiPolygon';


/* 2. Gasiti distanta minima (si numele celor 2 orase) intre orasele care au suparafata mai mare de 1500 de hectare 
si au o crestere a populatiei intre 2000 si 2010 mai mare de 2000 de locuitori (nu se considera distanta dintre 
oras cu el insusi)*/
SELECT t1.town AS town1, 
       t2.town AS town2, 
       ST_Distance(t1.geom, t2.geom) AS distance
FROM towns t1
JOIN towns t2 ON t1.gid < t2.gid  -- nu se considera distanta dintre oras cu el insusi
WHERE t1.shape_area > 15000000   
  AND t2.shape_area > 15000000
  AND t1.popch00_10 > 2000
  AND t2.popch00_10 > 2000
ORDER BY distance
LIMIT 1;


-- 2.1. Creati tabelele "streets" si "buildings" care sa contina cateva atribute nespatiale si cel putin un atribut spatial (geom).
CREATE TABLE streets (
    street_id serial PRIMARY KEY,
    name varchar(50),
    type varchar(20),  
    one_way boolean,  
    geom geometry(LINESTRING, 26986)
);

CREATE TABLE buildings (
    building_id serial PRIMARY KEY,
    type varchar(20),         
    year_built int,         
    geom geometry(POLYGON, 26986)
);

-- 2.2. Evidentiati printr-o interogare toate elementele "features" definite ca geometrii in schema curenta.
SELECT f_table_name AS table_name, f_geometry_column AS geometry_column, type
FROM geometry_columns
WHERE f_table_schema = 'public';


/* 3. Introduceti cel putin 10 inregistrari in fiecare din cele 2 tabele (streets si buildings)*/ 

-- This view calculates the bounding box for the geometry of towns, which can be used as the boundaries for generating streets 
-- and buildings within each town's area
CREATE VIEW town_bounds AS
SELECT town_id, town,
       ST_XMin(ST_Extent(geom)) AS min_x,
       ST_XMax(ST_Extent(geom)) AS max_x,
       ST_YMin(ST_Extent(geom)) AS min_y,
       ST_YMax(ST_Extent(geom)) AS max_y
FROM towns
GROUP BY town_id, town
LIMIT 5; 


-- Insert 75 streets. Random lines are generated starting from the bounding box of each town
INSERT INTO streets (name, type, one_way, geom)
SELECT 
    'Street_' || nextval('streets_street_id_seq') AS name,  
    CASE WHEN i % 4 = 1 THEN 'residential'
         WHEN i % 4 = 2 THEN 'commercial'
         WHEN i % 4 = 3 THEN 'highway'
         ELSE 'pedestrian' END AS type,
    CASE WHEN i % 2 = 0 THEN true ELSE false END AS one_way,  
    ST_MakeLine(
        ST_SetSRID(ST_MakePoint(min_x + random() * (max_x - min_x), min_y + random() * (max_y - min_y)), 26986),
        ST_SetSRID(ST_MakePoint(min_x + random() * (max_x - min_x), min_y + random() * (max_y - min_y)), 26986)
    ) AS geom
FROM town_bounds, generate_series(1, 15) AS i; 


-- Insert 125 buildings. Generates random x and y coordinates within the town's bounding box and buffers the point 
-- by 20 units to create a polygon around the point
INSERT INTO buildings (type, year_built, geom)
SELECT 
    CASE WHEN i % 6 = 1 THEN 'house'
         WHEN i % 6 = 2 THEN 'apartment'
         WHEN i % 6 = 3 THEN 'school'
         WHEN i % 6 = 4 THEN 'mall'
         WHEN i % 6 = 5 THEN 'office'
         ELSE 'institution' END AS type,
    1980 + floor(random() * 40)::int AS year_built,  
    ST_Buffer(
        ST_SetSRID(ST_MakePoint(
            min_x + random() * (max_x - min_x), 
            min_y + random() * (max_y - min_y)
        ), 26986),
        20 
    ) AS geom
FROM town_bounds, generate_series(1, 25) AS i;


-- 3.1 Se cer 3 interogari care sa foloseasca un join spatial (diferit pentru fiecare interogare) intre 
-- cel putin 2 din aceste 3 tabele, cu rezultat numeric

-- Number of buildings within 1000 meters of a street
SELECT s.name AS street_name, 
       COUNT(b.building_id) AS nearby_buildings
FROM streets s
JOIN buildings b ON ST_DWithin(s.geom, b.geom, 1000)  
GROUP BY s.name;

-- Total length of streets that intersect the boundaries of each town
SELECT t.town AS town_name, 
       SUM(ST_Length(s.geom)) AS total_street_length
FROM towns t
JOIN streets s ON ST_Intersects(t.geom, s.geom)  
GROUP BY t.town;

-- Number of streets crossing each town
SELECT t.town AS town_name, 
       COUNT(DISTINCT s.street_id) AS crossing_streets
FROM towns t
JOIN streets s ON ST_Crosses(t.geom, s.geom)  
GROUP BY t.town;


-- 3.2. Se cer 3 interogari care sa foloseasca un join spatial intre cel putin 2 din aceste 3 tabele, cu rezultat boolean 

-- Checks if each street has at least one other street that it crosses
SELECT s1.street_id, s1.name AS street_name,
       EXISTS (
           SELECT 1
           FROM streets s2
           WHERE s1.street_id <> s2.street_id
             AND ST_Crosses(s1.geom, s2.geom)
       ) AS crosses_another_street
FROM streets s1;

-- Check if each building has at least one street within 500 meters
SELECT b.building_id, 
       EXISTS (
           SELECT 1
           FROM streets s
           WHERE ST_DWithin(s.geom, b.geom, 500)
       ) AS street_nearby
FROM buildings b;

-- Check if each town contains any buildings
SELECT t.town, 
       EXISTS (
           SELECT 1
           FROM buildings b
           WHERE ST_Contains(t.geom, b.geom)
       ) AS has_buildings
FROM towns t;

select * from streets





