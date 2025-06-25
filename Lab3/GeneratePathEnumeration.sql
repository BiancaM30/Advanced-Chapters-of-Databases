CREATE OR REPLACE PROCEDURE GeneratePathEnumeration IS
BEGIN
    INSERT INTO path_enum (cod, path_string, denumire)
    SELECT 
        cod,
        SYS_CONNECT_BY_PATH(denumire, '#') AS path_string, 
        denumire
    FROM 
        adj_list
    START WITH codp IS NULL
    CONNECT BY PRIOR cod = codp;
END;
/
