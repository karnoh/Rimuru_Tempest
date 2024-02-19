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
