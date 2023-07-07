SELECT group_concat(title, ', ')
FROM (SELECT DISTINCT title
    FROM akas, (SELECT title_id
        FROM titles
        WHERE original_title = "House of the Dragon" AND type = "tvSeries") AS t
    WHERE akas.title_id = t.title_id
    ORDER BY title);
    