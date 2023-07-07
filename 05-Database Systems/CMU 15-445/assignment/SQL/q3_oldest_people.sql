SELECT u.n, u.age
FROM (
    SELECT name AS n, died - born AS age
    FROM people
    WHERE born >= 1900 AND died IS NOT NULL
    UNION ALL
    SELECT name AS n, 2022 - born AS age
    FROM people
    WHERE born >= 1900 AND died IS NULL
) AS u
ORDER BY u.age DESC, u.n
LIMIT 20;
