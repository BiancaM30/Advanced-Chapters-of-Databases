CREATE OR REPLACE PROCEDURE DeleteNodeWithReassign (
    p_cod NUMBER 
) AS
    v_deleted_path VARCHAR2(500);
    v_parent_path VARCHAR2(500);
BEGIN
    -- get the path of the node to be deleted
    SELECT path_string
    INTO v_deleted_path
    FROM path_enum
    WHERE cod = p_cod;

    -- get the parent path of the node to be deleted
    SELECT SUBSTR(path_string, 1, INSTR(path_string, '#', -1, 1) - 1)
    INTO v_parent_path
    FROM path_enum
    WHERE cod = p_cod;

    -- update the path of all child nodes
    UPDATE path_enum
    SET 
        path_string = REPLACE(path_string, v_deleted_path || '#', v_parent_path || '#')
    WHERE path_string LIKE v_deleted_path || '#%';

    -- delete the node
    DELETE FROM path_enum
    WHERE cod = p_cod;

    COMMIT;
END;
