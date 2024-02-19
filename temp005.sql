-- User-defined function to check if the file exists and is recent
CREATE OR REPLACE FUNCTION FILE_EXISTS_AND_RECENT(file_path VARCHAR(100))
RETURNS BOOLEAN
SPECIFIC FILE_EXISTS_AND_RECENT
LANGUAGE SQL
DETERMINISTIC
NO EXTERNAL ACTION
BEGIN
    DECLARE v_exists INT;
    DECLARE v_last_modified TIMESTAMP;
    
    -- Check if file exists
    CALL SYSPROC.UTIL_FILE_EXISTS(file_path, v_exists);
    
    IF v_exists > 0 THEN
        -- Get last modified timestamp of the file
        CALL SYSPROC.UTIL_FILE_GET_ATTR(file_path, 'MODIFICATION_TIME', v_last_modified);
        
        -- Compare last modified timestamp with current timestamp
        IF v_last_modified > CURRENT_TIMESTAMP - 1 HOUR THEN
            RETURN TRUE; -- File exists and is recent
        ELSE
            RETURN FALSE; -- File exists but is not recent
        END IF;
    ELSE
        RETURN FALSE; -- File does not exist
    END IF;
END@

-- Procedure to load CSV data into the table
CREATE OR REPLACE PROCEDURE Load_CSV_Data(file_path VARCHAR(100), OUT rows_loaded INT)
LANGUAGE SQL
BEGIN
    DECLARE v_sqlcode INTEGER;
    DECLARE v_sqlstate CHAR(5);
    DECLARE v_rows_loaded INT;
    
    -- Check if the file exists and is recent
    IF FILE_EXISTS_AND_RECENT(file_path) THEN
        -- Initialize v_rows_loaded
        SET v_rows_loaded = 0;

        -- Load CSV data into the table
        CALL SYSPROC.ADMIN_CMD('IMPORT FROM ' || file_path || ' OF DEL MODIFIED BY COLDEL, SELECTCHARACTERSET=UTF8 INSERT INTO your_table');
        
        -- Get SQLCODE and SQLSTATE
        GET DIAGNOSTICS v_sqlcode = RETURNED_SQLCODE, v_sqlstate = RETURNED_SQLSTATE;
        
        -- Check for errors or warnings
        IF v_sqlcode < 0 THEN
            -- Log error message
            CALL dbms_output.put_line('Error occurred during CSV data loading: SQLCODE ' || v_sqlcode || ', SQLSTATE ' || v_sqlstate);
        ELSE
            -- Get the number of rows loaded
            SELECT COUNT(*) INTO v_rows_loaded FROM your_table;
            -- Log success message
            CALL dbms_output.put_line('CSV data loaded successfully. Rows loaded: ' || v_rows_loaded);
        END IF;
    ELSE
        -- Log error message
        CALL dbms_output.put_line('File does not exist or is not recent.');
    END IF;
    
    -- Return the number of rows loaded
    SET rows_loaded = v_rows_loaded;
END@
