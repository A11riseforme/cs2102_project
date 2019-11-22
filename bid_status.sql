WITH bidsWithThrs AS (
	SELECT
		*,
	CASE
			
			WHEN G.threshold = G.bid THEN
			'Pending' 
			WHEN G.threshold < G.bid THEN
			'Successful' ELSE'Pending' 
		END AS status 
	FROM
		(
		SELECT
			P1.uname,
			P1.bid,
			P1.module_code,
			P1.rid,
			P1.SESSION,
			C.threshold 
		FROM
			(
			SELECT
				* 
			FROM
				(
				SELECT ROW_NUMBER
					( ) OVER ( PARTITION BY module_code, rid, SESSION ORDER BY bid DESC ) AS priority,
					T.* 
				FROM
					(
					SELECT
						I.uname,
						I.bid,
						I.module_code,
						I.rid,
						I.SESSION,
						C.quota 
					FROM
						Bid I
					NATURAL JOIN CLASS C 
					WHERE
						I.is_successful = FALSE 
					) AS T 
				) x 
			WHERE
				x.priority > 0 
			) AS P1
			INNER JOIN (
			SELECT
				module_code,
				rid,
				SESSION,
				bid AS threshold 
			FROM
				(
				SELECT
					* 
				FROM
					(
					SELECT ROW_NUMBER
						( ) OVER ( PARTITION BY module_code, rid, SESSION ORDER BY bid DESC ) AS priority,
						T.* 
					FROM
						(
						SELECT
							I.uname,
							I.bid,
							I.module_code,
							I.rid,
							I.SESSION,
							C.quota 
						FROM
							Bid I
						NATURAL JOIN CLASS C 
						WHERE
							I.is_successful = FALSE 
						) AS T 
					) x 
				WHERE
					x.priority > 0 
				) AS E 
			WHERE
				E.priority = E.quota 
			) AS C ON P1.module_code = C.module_code 
			AND P1.rid = C.rid 
			AND P1.SESSION = C.SESSION 
			AND P1.bid >= C.threshold 
		) AS G 
	),
	bidsWithoutThrs AS (
	SELECT
		*,
	CASE
			
			WHEN P.threshold IS NULL THEN
			'Successful' ELSE'Pending' 
		END AS status 
	FROM
		(
		SELECT
			* 
		FROM
			(
			SELECT
				P1.uname,
				P1.bid,
				P1.module_code,
				P1.rid,
				P1.SESSION,
				C.threshold 
			FROM
				(
				SELECT
					* 
				FROM
					(
					SELECT ROW_NUMBER
						( ) OVER ( PARTITION BY module_code, rid, SESSION ORDER BY bid DESC ) AS priority,
						T.* 
					FROM
						(
						SELECT
							I.uname,
							I.bid,
							I.module_code,
							I.rid,
							I.SESSION,
							C.quota 
						FROM
							Bid I
						NATURAL JOIN CLASS C 
						WHERE
							I.is_successful = FALSE 
						) AS T 
					) x 
				WHERE
					x.priority > 0 
				) AS P1
				LEFT JOIN (
				SELECT
					module_code,
					rid,
					SESSION,
					bid AS threshold 
				FROM
					(
					SELECT
						* 
					FROM
						(
						SELECT ROW_NUMBER
							( ) OVER ( PARTITION BY module_code, rid, SESSION ORDER BY bid DESC ) AS priority,
							T.* 
						FROM
							(
							SELECT
								I.uname,
								I.bid,
								I.module_code,
								I.rid,
								I.SESSION,
								C.quota 
							FROM
								Bid I
							NATURAL JOIN CLASS C 
							WHERE
								I.is_successful = FALSE 
							) AS T 
						) x 
					WHERE
						x.priority > 0 
					) AS E 
				WHERE
					E.priority = E.quota 
				) AS C ON P1.module_code = C.module_code 
				AND P1.rid = C.rid 
				AND P1.SESSION = C.SESSION 
			) AS T 
		WHERE
			T.threshold IS NULL 
		) AS P 
	) SELECT
	x.module_code,
	x.rid,
	x.SESSION,
	x.uname,
	x.matric_no,
	x.cap,
	x.sfname,
	x.mfname,
	x.threshold,
	x.bid,
	x.status 
FROM
	(
	SELECT ROW_NUMBER
		( ) OVER ( PARTITION BY module_code, rid, SESSION ORDER BY bid DESC ) AS P,
		T.* 
	FROM
		(
		SELECT
			BC.module_code,
			BC.rid,
			BC.SESSION,
			BC.uname,
			SD.matric_no,
			SD.cap,
			SD.fname AS sfname,
			BC.mfname,
			BC.bid,
			BC.status,
			BC.threshold 
		FROM
			(
			SELECT
				B.module_code,
				B.rid,
				B.SESSION,
				B.uname,
				B.bid,
				B.status,
				C1.fname AS mfname,
				B.threshold 
			FROM
				( SELECT * FROM bidsWithThrs B1 UNION SELECT * FROM bidsWithoutThrs B2 ) AS B
				NATURAL JOIN Courses C1 
			WHERE
				C1.module_code = B.module_code 
			) AS BC
			NATURAL JOIN ( SELECT * FROM Student S1 NATURAL JOIN StudentInfo S2 WHERE S1.matric_no = S2.matric_no ) AS SD 
		WHERE
			SD.uname = BC.uname 
		) AS T 
	) x 
WHERE
	x.P > 0;