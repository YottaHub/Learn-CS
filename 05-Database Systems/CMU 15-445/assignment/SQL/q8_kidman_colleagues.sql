SELECT name
FROM people
WHERE person_id IN (
    SELECT person_id
    FROM crew
    WHERE (category = 'actor' OR category = 'actress') AND 
    title_id IN (
        SELECT title_id
        FROM people AS p, crew AS c
        WHERE name = 'Nicole Kidman' AND born = 1967 AND
        p.person_id = c.person_id))
ORDER BY name;
