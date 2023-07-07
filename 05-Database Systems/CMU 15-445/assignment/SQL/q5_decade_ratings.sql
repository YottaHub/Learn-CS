SELECT decade, ROUND(AVG(rating), 2) AS avg, MAX(rating), MIN(rating), COUNT(*)
FROM ratings AS r INNER JOIN (
    SELECT title_id, (premiered / 10) || '0s' AS decade
    FROM titles
    WHERE premiered) AS t
ON r.title_id = t.title_id
GROUP BY decade
ORDER BY avg DESC, decade;
