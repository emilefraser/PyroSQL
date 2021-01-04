DECLARE @pwoof TABLE(
	ID INT,
	DurkahDurkah VARCHAR(500)
)

INSERT INTO @pwoof
VALUES (1,'Hello world!')
	, (2,'Hello world!')
	, (3,'Durk Durk Bak-Akah')
	, (4,'Durk Durk Bak-Aah')

-- Compare strings, returns the strings
SELECT m.DurkahDurkah
	, m1.DurkahDurkah
FROM @pwoof m
	INNER JOIN @pwoof m1 ON m.DurkahDurkah = m1.DurkahDurkah
WHERE m.ID = 1
	AND m1.ID = 2

-- Different strings return nothing
SELECT m.DurkahDurkah
	, m1.DurkahDurkah
FROM @pwoof m
	INNER JOIN @pwoof m1 ON m.DurkahDurkah = m1.DurkahDurkah
WHERE m.ID = 3
	AND m1.ID = 4
