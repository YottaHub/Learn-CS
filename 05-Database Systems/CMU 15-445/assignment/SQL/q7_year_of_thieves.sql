SELECT COUNT(*)
FROM titles
WHERE premiered = (
    SELECT premiered
    FROM titles
    WHERE original_title = 'Army of Thieves');
