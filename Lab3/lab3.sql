-- Folosind tabelele si datele din fisierul strArb.sql se cere: 
SELECT * FROM produse;
SELECT * FROM structura;

SELECT COUNT(*) FROM produse;
SELECT COUNT(*) FROM structura;

-- 1. Sa se creeze o singura tabela cu toate aceste date organizate sub forma de "adjacency list"
DROP TABLE adj_list;

CREATE TABLE adj_list (
    cod NUMBER PRIMARY KEY,               
    codp NUMBER,
    denumire VARCHAR2(150) NOT NULL,      
    pozitia NUMBER,                       
    CHECK (cod <> codp),                  
    UNIQUE (cod, codp),
    CONSTRAINT fk_codp FOREIGN KEY (codp) REFERENCES adj_list(cod) ON DELETE CASCADE
);

ALTER TABLE adj_list DISABLE CONSTRAINT fk_codp;

INSERT INTO adj_list (cod, codp, denumire, pozitia)
SELECT s.cod, s.codp, p.denumire, s.pozitia
FROM structura s
LEFT JOIN produse p
ON s.cod = p.cod;

-- Adding root nodes with NULL parent
INSERT INTO adj_list (cod, codp, denumire, pozitia)
SELECT p.cod, NULL, p.denumire, NULL
FROM produse p
WHERE p.cod IN (
    SELECT codp
    FROM adj_list
    WHERE codp NOT IN (SELECT cod FROM adj_list)
    AND codp IS NOT NULL
);

ALTER TABLE adj_list ENABLE CONSTRAINT fk_codp;

-- select root nodes
SELECT * FROM adj_list WHERE codp IS NULL;

-- 2. Afisarea denumirii, denumirea parintelui si nivelul in arbore pentru toate obiectele pana la nivelul 5;
SELECT 
    a.cod AS node_id,
    a.denumire AS node_name,
    CONNECT_BY_ROOT a.cod AS root_node,
    CONNECT_BY_ROOT a.denumire AS root_name,
    PRIOR a.denumire AS parent_name,
    LEVEL AS tree_level
FROM 
    adj_list a
START WITH a.codp IS NULL 
CONNECT BY PRIOR a.cod = a.codp 
AND LEVEL <= 5 
ORDER SIBLINGS BY a.denumire;


-- 3. Cu ajutorul unei functii/proceduri, sa se transforme aceasta structura in format "path enumeration" 
-- (tabela noua, se poate folosi codificare suplimentara la nevoie, de exemplu separator de cale
DROP TABLE path_enum;

CREATE TABLE path_enum (
    cod NUMBER PRIMARY KEY,
    path_string VARCHAR2(500) NOT NULL,
    denumire VARCHAR2(150)
);

BEGIN
    GeneratePathEnumeration();
END;

SELECT * FROM path_enum;

-- 4. Pentru modelul "path enumeration" sa se scrie o functie care elimina un nod dat ca si parametru din 
-- structura cu pastrarea structurii de arbore (nu forest)

-- Metoda "Send the orphans to Grandmother": nodurile subordonatenodului sters devin noduri subordonates ale 
-- parintelui nodului sters (bunic)

SELECT * FROM path_enum;

BEGIN
    DeleteNodeWithReassign(1007);
END;

SELECT * FROM path_enum;

















