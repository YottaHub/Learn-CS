SELECT p.name, COUNT(*)
FROM people as p INNER JOIN crew as c
ON p.person_id = c.person_id
GROUP BY p.person_id
ORDER BY COUNT(*) DESC
LIMIT 20;
