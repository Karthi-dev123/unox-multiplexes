DELIMITER // 

CREATE PROCEDURE MovieSearch(
    IN p_title VARCHAR(255),
    IN p_genre VARCHAR(255),
    IN p_status VARCHAR(255)
    )
    BEGIN
    -- nullif and set things ( for empty strings )
    SET p_title = NULLIF(TRIM(p_title),'');
    SET p_genre = NULLIF(TRIM(p_genre),''); 
    SET p_status = NULLIF(TRIM(p_status),''); 
    IF p_title IS NULL AND 
       p_genre IS NULL AND 
       p_status IS NULL 
       THEN 

       SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Provide at least one search criterion';
    END IF;
    /* So we gotta keep things optional 
    IS NULL OR goes somewhere here 
    title, genre,status, and release date

    
    things to print 
    
    */
    SELECT title , genre , status , release_date 
    FROM Movie
    WHERE (p_title IS NULL OR title LIKE CONCAT('%',p_title,'%'))
    AND (p_genre IS NULL OR genre = p_genre)
    AND (p_status IS NULL OR status = p_status)
    AND is_active = 1
    ORDER BY title ASC ; 




    END // 

DELIMITER ; 