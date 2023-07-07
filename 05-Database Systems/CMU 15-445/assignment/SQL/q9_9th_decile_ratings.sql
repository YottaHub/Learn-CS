SELECT name, ROUND(avg, 2) AS avg_2
FROM (SELECT name, avg, NTILE(10) OVER(
        ORDER BY avg) AS decile
    FROM (
        SELECT name, AVG(rating) AS avg
        FROM ratings AS r JOIN (
            SELECT name, person_id, i.title_id
            FROM titles AS t JOIN (
                SELECT name, people.person_id, title_id
                FROM people, crew
                WHERE born = 1955 AND people.person_id = crew.person_id) AS i
            ON t.title_id = i.title_id
            WHERE type = "movie") AS m
        ON r.title_id = m.title_id
        GROUP BY person_id))
WHERE decile = 9
ORDER BY avg_2 DESC, name;
