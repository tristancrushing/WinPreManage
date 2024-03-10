SELECT
    urls.url AS "URL",
    datetime(visits.visit_time / 1000000 - 11644473600, 'unixepoch', 'localtime') AS "Visit Date",
    visits.visit_duration AS "Visit Duration (microseconds)",
    visits.visit_duration / 1000000 AS "Visit Duration (seconds)",
    (visits.visit_duration / 1000000) / 60 AS "Visit Duration (minutes)",
    (visits.visit_duration / 1000000) / 3600 AS "Visit Duration (hours)",
    urls.title AS "Title",
    visit_source.source AS "Visit Source"
FROM visits
JOIN urls ON visits.url = urls.id
LEFT JOIN visit_source ON visits.id = visit_source.id
ORDER BY visits.visit_time DESC;
