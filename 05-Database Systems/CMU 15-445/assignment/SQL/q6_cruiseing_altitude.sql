SELECT name, votes
FROM (
    SELECT title_id
    FROM people, crew
    WHERE name LIKE "%Cruise%" AND born = 1962 AND 
    people.person_id = crew.person_id) AS t, (
    SELECT titles.title_id, original_title AS name, votes AS votes
    FROM titles, ratings
    WHERE titles.title_id = ratings.title_id) AS v
WHERE t.title_id = v.title_id
ORDER BY votes DESC
LIMIT 10;
