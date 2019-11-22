WITH Rank AS (
	SELECT
	  ROW_NUMBER() OVER (PARTITION BY (B.module_code, B.rid, B.session) ORDER BY B.rank) AS R,
	  B.*
	FROM
	  Ballot B
) SELECT Rank.uname, Rank.module_code, Rank.rid, Rank.session FROM Rank WHERE Rank.R <= (SELECT C.quota FROM Class C 
	WHERE C.module_code = Rank.module_code
	AND C.rid = Rank.rid
	AND C.session = Rank.session
	);
