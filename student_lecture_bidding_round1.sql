/*
PostgreSQL Backup
Database: postgres/public
Backup Time: 2019-11-11 23:55:27
*/


DROP TABLE IF EXISTS "public"."bid";
DROP TABLE IF EXISTS "public"."ballot";
DROP TABLE IF EXISTS "public"."class";
DROP TABLE IF EXISTS "public"."rounds";
DROP TABLE IF EXISTS "public"."prerequisite";
DROP TABLE IF EXISTS "public"."clash_mod_code";
DROP TABLE IF EXISTS "public"."games";
DROP TABLE IF EXISTS "public"."taken";
DROP TABLE IF EXISTS "public"."student";
DROP TABLE IF EXISTS "public"."studentinfo";
DROP TABLE IF EXISTS "public"."courses";
DROP TABLE IF EXISTS "public"."faculty";
DROP TABLE IF EXISTS "public"."admin";
DROP TABLE IF EXISTS "public"."users";
DROP FUNCTION IF EXISTS "public"."check_bidpoint()";
DROP FUNCTION IF EXISTS "public"."check_prerequisite()";
DROP FUNCTION IF EXISTS "public"."f_random_str(length int4)";
DROP FUNCTION IF EXISTS "public"."lecture_clash()";
DROP FUNCTION IF EXISTS "public"."require_lecture()";
DROP FUNCTION IF EXISTS "public"."t_func4()";
DROP FUNCTION IF EXISTS "public"."tutorial_clash()";
CREATE TABLE "admin" (
  "uname" varchar(30) COLLATE "pg_catalog"."default" NOT NULL
)
;
ALTER TABLE "admin" OWNER TO "postgres";
CREATE TABLE "ballot" (
  "uname" varchar(30) COLLATE "pg_catalog"."default" NOT NULL,
  "rank" int4,
  "module_code" varchar(30) COLLATE "pg_catalog"."default" NOT NULL,
  "rid" int4 NOT NULL,
  "session" int4 NOT NULL,
  "is_successful" bool DEFAULT false
)
;
ALTER TABLE "ballot" OWNER TO "postgres";
CREATE TABLE "bid" (
  "uname" varchar(30) COLLATE "pg_catalog"."default" NOT NULL,
  "bid" int4,
  "module_code" varchar(30) COLLATE "pg_catalog"."default" NOT NULL,
  "rid" int4 NOT NULL,
  "session" int4 NOT NULL,
  "is_successful" bool DEFAULT false
)
;
ALTER TABLE "bid" OWNER TO "postgres";
CREATE TABLE "clash_mod_code" (
  "module_code" varchar(30) COLLATE "pg_catalog"."default"
)
;
ALTER TABLE "clash_mod_code" OWNER TO "postgres";
CREATE TABLE "class" (
  "module_code" varchar(30) COLLATE "pg_catalog"."default" NOT NULL,
  "rid" int4 NOT NULL,
  "session" int4 NOT NULL,
  "quota" int4 NOT NULL,
  "week_day" int4 NOT NULL,
  "s_time" time(6) NOT NULL,
  "e_time" time(6) NOT NULL
)
;
ALTER TABLE "class" OWNER TO "postgres";
CREATE TABLE "courses" (
  "module_code" varchar(10) COLLATE "pg_catalog"."default" NOT NULL,
  "admin" varchar(30) COLLATE "pg_catalog"."default" NOT NULL,
  "fname" varchar(30) COLLATE "pg_catalog"."default" NOT NULL,
  "mc" int4 NOT NULL
)
;
ALTER TABLE "courses" OWNER TO "postgres";
CREATE TABLE "faculty" (
  "fname" varchar(30) COLLATE "pg_catalog"."default" NOT NULL
)
;
ALTER TABLE "faculty" OWNER TO "postgres";
CREATE TABLE "games" (
  "name" varchar(255) COLLATE "pg_catalog"."default",
  "price" int4
)
;
ALTER TABLE "games" OWNER TO "postgres";
CREATE TABLE "prerequisite" (
  "module_code" varchar(10) COLLATE "pg_catalog"."default" NOT NULL,
  "require" varchar(10) COLLATE "pg_catalog"."default" NOT NULL
)
;
ALTER TABLE "prerequisite" OWNER TO "postgres";
CREATE TABLE "rounds" (
  "rid" int4 NOT NULL,
  "admin" varchar(30) COLLATE "pg_catalog"."default" NOT NULL,
  "s_date" timestamp(6) NOT NULL,
  "e_date" timestamp(6) NOT NULL
)
;
ALTER TABLE "rounds" OWNER TO "postgres";
CREATE TABLE "student" (
  "uname" varchar(30) COLLATE "pg_catalog"."default" NOT NULL,
  "matric_no" varchar(10) COLLATE "pg_catalog"."default" NOT NULL,
  "bid_point" int4 NOT NULL,
  "authcode" varchar(255) COLLATE "pg_catalog"."default"
)
;
ALTER TABLE "student" OWNER TO "postgres";
CREATE TABLE "studentinfo" (
  "matric_no" varchar(10) COLLATE "pg_catalog"."default" NOT NULL,
  "cap" numeric(3,2) NOT NULL,
  "fname" varchar(30) COLLATE "pg_catalog"."default" NOT NULL,
  "rname" varchar(255) COLLATE "pg_catalog"."default" NOT NULL,
  "nusnetid" varchar(255) COLLATE "pg_catalog"."default" NOT NULL
)
;
ALTER TABLE "studentinfo" OWNER TO "postgres";
CREATE TABLE "taken" (
  "uname" varchar(30) COLLATE "pg_catalog"."default" NOT NULL,
  "module_code" varchar(10) COLLATE "pg_catalog"."default" NOT NULL
)
;
ALTER TABLE "taken" OWNER TO "postgres";
CREATE TABLE "users" (
  "uname" varchar(30) COLLATE "pg_catalog"."default" NOT NULL,
  "password" varchar(30) COLLATE "pg_catalog"."default" NOT NULL
)
;
ALTER TABLE "users" OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "check_bidpoint"()
  RETURNS "pg_catalog"."trigger" AS $BODY$
DECLARE
bid_previous INT;
bid_after    INT;
BEGIN

IF (NEW.bid IS NOT NULL AND OLD.bid IS NULL) THEN
     SELECT S.bid_point INTO bid_previous
     FROM Student S
     WHERE S.uname = NEW.uname
     LIMIT 1;
     UPDATE Student
     SET bid_point = bid_point - New.bid
     WHERE uname = NEW.uname 
     AND bid_point >= New.bid;
     SELECT U.bid_point 
     INTO bid_after
     FROM Student U
     WHERE U.uname = NEW.uname
     LIMIT 1;
     IF bid_previous = bid_after 
     THEN RAISE EXCEPTION 'Insufficient bid points left for %', NEW.uname;
     END IF;
     RETURN NEW;
ELSEIF (OLD.bid IS NOT NULL AND NEW.bid IS NULL) THEN
     UPDATE Student
     SET bid_point = bid_point + OLD.bid
     WHERE uname = OLD.uname;
     RETURN OLD;
ELSEIF (NEW.bid IS NOT NULL AND OLD.bid IS NOT NULL) THEN
    IF NEW.bid < OLD.bid THEN
        UPDATE Student
        SET bid_point = bid_point + OLD.bid - NEW.bid
        WHERE uname = NEW.uname;
        RETURN NEW;
    ELSEIF NEW.bid > OLD.bid THEN
        SELECT S.bid_point INTO bid_previous
        FROM Student S
        WHERE S.uname = NEW.uname
        LIMIT 1;
        UPDATE Student
        SET bid_point = bid_point - NEW.bid + OLD.bid
        WHERE uname = NEW.uname 
        AND bid_point >= New.bid - OLD.bid;
        SELECT U.bid_point 
        INTO bid_after
        FROM Student U
        WHERE U.uname = NEW.uname
        LIMIT 1;
        IF bid_previous = bid_after 
        THEN RAISE EXCEPTION 'Insufficient bid points left for %', NEW.uname;
        END IF;
        RETURN NEW;
    ELSE 
        RETURN NEW;
    END IF;

END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION "check_bidpoint"() OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "check_prerequisite"()
  RETURNS "pg_catalog"."trigger" AS $BODY$
DECLARE
counter_1 INT;
counter_2 INT;
BEGIN
WITH count1 AS (
SELECT COUNT(*)
      FROM (
      SELECT * FROM Prerequisite P
      WHERE P.module_code=NEW.module_code
    ) T
      INNER JOIN (
      SELECT * FROM Taken A
      WHERE A.uname=NEW.uname
    ) B
      ON T.require=B.module_code
),
     count2 AS (
      SELECT COUNT(*)
      FROM Prerequisite P
      WHERE P.module_code=NEW.module_code
)
       SELECT c1.count, c2.count INTO counter_1, counter_2
       FROM count1 c1, count2 c2;
       IF counter_1 < counter_2
       THEN RAISE EXCEPTION 'Module Prequisite is not fullfilled';
     END IF;
     RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION "check_prerequisite"() OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "f_random_str"("length" int4)
  RETURNS "pg_catalog"."varchar" AS $BODY$
DECLARE
result varchar(50);
BEGIN
SELECT array_to_string(ARRAY(SELECT chr((65 + round(random() * 25)) :: integer)
FROM generate_series(1,length)), '') INTO result;
return result;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION "f_random_str"("length" int4) OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "lecture_clash"()
  RETURNS "pg_catalog"."trigger" AS $BODY$
DECLARE
clash_mod_code VARCHAR(30);
round_start TIMESTAMP;
round_end  TIMESTAMP;
BEGIN

SELECT R.s_date,R.e_date INTO round_start, round_end
FROM Rounds R
WHERE R.rid = NEW.rid;

IF (NOW() BETWEEN round_start AND round_end) THEN
  WITH bidInfo AS (
    SELECT * FROM Class C
    WHERE C.module_code=NEW.module_code 
    AND C.rid=NEW.rid 
    AND C.session=NEW.session
  ), lecStatusRound AS (
    SELECT * FROM Bid i
      NATURAL JOIN Class
      WHERE NEW.rid = 1
      AND i.uname=NEW.uname
      AND i.rid=NEW.rid
    UNION
    SELECT * FROM Bid i
      NATURAL JOIN Class
      WHERE NEW.rid = 2
      AND ( i.uname=NEW.uname AND i.is_successful=TRUE and i.rid=1)
      OR ( i.uname=NEW.uname AND i.rid=2 )
  )
  SELECT lecStatusRound.module_code INTO clash_mod_code
  FROM bidInfo
  INNER JOIN 
  lecStatusRound
  ON lecStatusRound.week_day = bidInfo.week_day
  AND (
    bidInfo.s_time BETWEEN lecStatusRound.s_time AND lecStatusRound.e_time
    OR bidInfo.e_time BETWEEN lecStatusRound.s_time AND lecStatusRound.e_time
  ) 
  LIMIT 1;
  IF clash_mod_code IS NOT NULL
   THEN RAISE EXCEPTION 'time table clash with module %', clash_mod_code;
  END IF;
  RETURN NEW;
ELSE
    RAISE EXCEPTION 'This round is closed %', New.rid;
    RETURN NEW;
END IF;   
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION "lecture_clash"() OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "require_lecture"()
  RETURNS "pg_catalog"."trigger" AS $BODY$
DECLARE
has_lecture boolean;
BEGIN
  SELECT EXISTS(
  SELECT 1
FROM Bid B
WHERE B.module_code = NEW.module_code
  AND B.rid < 3
AND B.is_successful
  ) INTO has_lecture;
  IF has_lecture
  THEN RETURN NEW;
  ELSE RAISE EXCEPTION 'need to successfully bid lecture before tutorial';
  END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION "require_lecture"() OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "t_func4"()
  RETURNS "pg_catalog"."trigger" AS $BODY$ BEGIN
RAISE EXCEPTION 'Trigger 4'; RETURN NULL;
END; $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION "t_func4"() OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "tutorial_clash"()
  RETURNS "pg_catalog"."trigger" AS $BODY$
DECLARE
day integer;
start_time varchar(30);
end_time varchar(30);
has_clash boolean;
BEGIN
  IF NEW.is_successful = TRUE
  THEN
    SELECT week_day, s_time, e_time INTO day, start_time, end_time FROM Class 
    WHERE module_code = NEW.module_code
    AND rid = NEW.rid
    AND session = NEW.session;
    WITH all_class AS (
      SELECT module_code, rid, session FROM Ballot Ba WHERE Ba.uname = NEW.uname AND Ba.is_successful = TRUE
    ), all_time As (
      SELECT week_day, s_time, e_time FROM Class C, all_class
      WHERE C.module_code = all_class.module_code
      AND C.rid = all_class.rid
      AND C.session = all_class.session
    ) 
    SELECT (EXISTS (SELECT 1 FROM all_time WHERE
      day = all_time.week_day
      AND (start_time::time BETWEEN all_time.s_time AND all_time.e_time
      OR end_time::time BETWEEN all_time.s_time AND all_time.e_time)
      )
    ) INTO has_clash;
    IF has_clash
    THEN RAISE EXCEPTION 'module % clash with another tutorial at time from % to %', NEW.module_code, start_time, end_time;
    ELSE RETURN NEW;
    END IF;
  ELSE RETURN NEW;
  END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION "tutorial_clash"() OWNER TO "postgres";
BEGIN;
LOCK TABLE "public"."admin" IN SHARE MODE;
DELETE FROM "public"."admin";
INSERT INTO "public"."admin" ("uname") VALUES ('admin');
COMMIT;
BEGIN;
LOCK TABLE "public"."ballot" IN SHARE MODE;
DELETE FROM "public"."ballot";
INSERT INTO "public"."ballot" ("uname","rank","module_code","rid","session","is_successful") VALUES ('user', 3, 'cs2102', 3, 1, 't');
COMMIT;
BEGIN;
LOCK TABLE "public"."bid" IN SHARE MODE;
DELETE FROM "public"."bid";
COMMIT;
BEGIN;
LOCK TABLE "public"."clash_mod_code" IN SHARE MODE;
DELETE FROM "public"."clash_mod_code";
INSERT INTO "public"."clash_mod_code" ("module_code") VALUES ('cs2102');
COMMIT;
BEGIN;
LOCK TABLE "public"."class" IN SHARE MODE;
DELETE FROM "public"."class";
INSERT INTO "public"."class" ("module_code","rid","session","quota","week_day","s_time","e_time") VALUES ('cs2102', 1, 1, 50, 1, '08:00:00', '10:00:00'),('cs4000', 1, 1, 100, 7, '08:00:00', '10:00:00'),('cs2102', 2, 2, 100, 5, '14:00:00', '16:00:00'),('cs1231', 2, 1, 70, 5, '14:00:00', '16:00:00'),('cs1010', 2, 1, 1, 7, '08:00:00', '10:00:00'),('cs3000', 2, 1, 100, 7, '08:00:00', '10:00:00'),('cs4000', 2, 1, 100, 7, '01:01:01', '10:10:10'),('cs4000', 1, 2, 50, 1, '09:00:00', '11:00:00'),('cs2102', 3, 1, 50, 2, '14:00:00', '15:00:00'),('cs2102', 3, 2, 40, 2, '15:00:00', '16:00:00'),('cs4000', 3, 1, 20, 3, '10:00:00', '11:00:00'),('cs1111', 1, 1, 90, 1, '18:00:00', '21:00:00'),('cs1111', 1, 2, 90, 1, '19:00:00', '22:00:00'),('cs3000', 2, 2, 100, 7, '12:00:00', '14:00:00'),('cs3000', 2, 3, 30, 7, '13:00:00', '15:00:00'),('cs1111', 2, 1, 40, 1, '12:00:00', '14:00:00'),('cs1111', 2, 3, 40, 1, '09:00:00', '11:00:00'),('cs1111', 2, 4, 50, 1, '11:00:00', '13:00:00'),('cs2102', 3, 3, 20, 7, '09:00:00', '10:00:00'),('cs4000', 3, 2, 50, 2, '14:00:00', '16:00:00'),('cs2106', 1, 1, 100, 1, '09:00:00', '11:00:00'),('cs3235', 1, 1, 100, 3, '16:00:00', '18:00:00'),('cs2106', 1, 2, 40, 2, '14:00:00', '16:00:00'),('EE3123', 1, 1, 200, 5, '16:00:00', '18:00:00');
COMMIT;
BEGIN;
LOCK TABLE "public"."courses" IN SHARE MODE;
DELETE FROM "public"."courses";
INSERT INTO "public"."courses" ("module_code","admin","fname","mc") VALUES ('cs2102', 'admin', 'SOC', 4),('cs1231', 'admin', 'SOC', 4),('cs1010', 'admin', 'SOC', 4),('cs3000', 'admin', 'SOC', 4),('cs4000', 'admin', 'SOC', 4),('cs1020', 'admin', 'SOC', 10),('cs1222', 'admin', 'FOE', 4),('cs1223', 'admin', 'FOE', 4),('cs1111', 'admin', 'SOC', 5),('ee1501', 'admin', 'FOE', 4),('cs2040c', 'admin', 'SOC', 4),('cs2105', 'admin', 'SOC', 5),('EE3123', 'admin', 'FOE', 2),('cs3444', 'admin', 'SOC', 2),('cs3235', 'admin', 'SOC', 4),('cs2106', 'admin', 'SOC', 4);
COMMIT;
BEGIN;
LOCK TABLE "public"."faculty" IN SHARE MODE;
DELETE FROM "public"."faculty";
INSERT INTO "public"."faculty" ("fname") VALUES ('SOC'),('FOE'),('FASS');
COMMIT;
BEGIN;
LOCK TABLE "public"."games" IN SHARE MODE;
DELETE FROM "public"."games";
INSERT INTO "public"."games" ("name","price") VALUES ('asdf', 105),('asdf', 105),('shi yi xia', 99);
COMMIT;
BEGIN;
LOCK TABLE "public"."prerequisite" IN SHARE MODE;
DELETE FROM "public"."prerequisite";
INSERT INTO "public"."prerequisite" ("module_code","require") VALUES ('cs2102', 'cs1231'),('cs3000', 'cs1111'),('cs3235', 'cs2106');
COMMIT;
BEGIN;
LOCK TABLE "public"."rounds" IN SHARE MODE;
DELETE FROM "public"."rounds";
INSERT INTO "public"."rounds" ("rid","admin","s_date","e_date") VALUES (3, 'admin', '2020-11-16 09:00:00', '2020-11-20 11:59:59'),(2, 'admin', '2020-11-13 08:00:00', '2020-11-15 11:59:59'),(1, 'admin', '2019-11-04 08:00:00', '2020-11-12 11:59:59');
COMMIT;
BEGIN;
LOCK TABLE "public"."student" IN SHARE MODE;
DELETE FROM "public"."student";
INSERT INTO "public"."student" ("uname","matric_no","bid_point","authcode") VALUES ('user', 'A100', 1000, 'OROREIHHMJ');
COMMIT;
BEGIN;
LOCK TABLE "public"."studentinfo" IN SHARE MODE;
DELETE FROM "public"."studentinfo";
INSERT INTO "public"."studentinfo" ("matric_no","cap","fname","rname","nusnetid") VALUES ('A101', 2.00, 'FOE', 'Ye Guoquan', 'e0324531'),('A102', 0.00, 'FASS', 'Huang Xuankun', 'e0319118'),('A103', 4.00, 'SOC', 'Wei Feng', 'e0319031'),('A100', 4.00, 'SOC', 'Lebron James', 'e1111111'),('A104', 4.00, 'SOC', 'Yang Chenglong', 'e0175540');
COMMIT;
BEGIN;
LOCK TABLE "public"."taken" IN SHARE MODE;
DELETE FROM "public"."taken";
INSERT INTO "public"."taken" ("uname","module_code") VALUES ('user', 'cs1010'),('user', 'cs1231'),('user', 'cs2040c');
COMMIT;
BEGIN;
LOCK TABLE "public"."users" IN SHARE MODE;
DELETE FROM "public"."users";
INSERT INTO "public"."users" ("uname","password") VALUES ('admin', 'password1'),('user', 'password');
COMMIT;
ALTER TABLE "admin" ADD CONSTRAINT "admin_pkey" PRIMARY KEY ("uname");
ALTER TABLE "ballot" ADD CONSTRAINT "ballot_pkey" PRIMARY KEY ("uname", "module_code", "rid", "session");
ALTER TABLE "bid" ADD CONSTRAINT "bid_pkey" PRIMARY KEY ("uname", "module_code", "rid", "session");
ALTER TABLE "class" ADD CONSTRAINT "class_pkey" PRIMARY KEY ("module_code", "rid", "session");
ALTER TABLE "courses" ADD CONSTRAINT "courses_pkey" PRIMARY KEY ("module_code");
ALTER TABLE "faculty" ADD CONSTRAINT "faculty_pkey" PRIMARY KEY ("fname");
ALTER TABLE "prerequisite" ADD CONSTRAINT "prerequisite_pkey" PRIMARY KEY ("module_code", "require");
ALTER TABLE "rounds" ADD CONSTRAINT "rounds_pkey" PRIMARY KEY ("rid");
ALTER TABLE "student" ADD CONSTRAINT "student_pkey" PRIMARY KEY ("uname");
ALTER TABLE "studentinfo" ADD CONSTRAINT "studentinfo_pkey" PRIMARY KEY ("matric_no");
ALTER TABLE "taken" ADD CONSTRAINT "taken_pkey" PRIMARY KEY ("uname", "module_code");
ALTER TABLE "users" ADD CONSTRAINT "users_pkey" PRIMARY KEY ("uname");
ALTER TABLE "admin" ADD CONSTRAINT "admin_uname_fkey" FOREIGN KEY ("uname") REFERENCES "public"."users" ("uname") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "ballot" ADD CONSTRAINT "ballot_uname_module_code_rid_rank_key" UNIQUE ("uname", "module_code", "rid", "rank");
ALTER TABLE "ballot" ADD CONSTRAINT "ballot_rank_check" CHECK (((rank >= 1) AND (rank <= 20)));
ALTER TABLE "ballot" ADD CONSTRAINT "ballot_rid_check" CHECK ((rid = 3));
ALTER TABLE "ballot" ADD CONSTRAINT "ballot_module_code_fkey" FOREIGN KEY ("module_code", "rid", "session") REFERENCES "public"."class" ("module_code", "rid", "session") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "ballot" ADD CONSTRAINT "ballot_uname_fkey" FOREIGN KEY ("uname") REFERENCES "public"."student" ("uname") ON DELETE CASCADE ON UPDATE CASCADE;
CREATE TRIGGER "lecture_before_tut" BEFORE INSERT ON "ballot"
FOR EACH ROW
EXECUTE PROCEDURE "public"."require_lecture"();
CREATE TRIGGER "prevent_tutorial_clash" BEFORE UPDATE ON "ballot"
FOR EACH ROW
EXECUTE PROCEDURE "public"."tutorial_clash"();
CREATE TRIGGER "tutorial_clash_with_lecture" BEFORE INSERT ON "ballot"
FOR EACH ROW
EXECUTE PROCEDURE "public"."tutorial_clash"();
ALTER TABLE "bid" ADD CONSTRAINT "bid_rid_check" CHECK (((rid = 1) OR (rid = 2)));
ALTER TABLE "bid" ADD CONSTRAINT "bid_bid_check" CHECK ((bid > 0));
ALTER TABLE "bid" ADD CONSTRAINT "bid_module_code_fkey" FOREIGN KEY ("module_code", "rid", "session") REFERENCES "public"."class" ("module_code", "rid", "session") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "bid" ADD CONSTRAINT "bid_uname_fkey" FOREIGN KEY ("uname") REFERENCES "public"."student" ("uname") ON DELETE CASCADE ON UPDATE NO ACTION;
CREATE TRIGGER "check_bidpoint" BEFORE INSERT OR UPDATE OR DELETE ON "bid"
FOR EACH ROW
EXECUTE PROCEDURE "public"."check_bidpoint"();
CREATE TRIGGER "check_prerequisite" BEFORE INSERT ON "bid"
FOR EACH ROW
EXECUTE PROCEDURE "public"."check_prerequisite"();
CREATE TRIGGER "lecture_clash" BEFORE INSERT ON "bid"
FOR EACH ROW
EXECUTE PROCEDURE "public"."lecture_clash"();
ALTER TABLE "class" ADD CONSTRAINT "class_week_day_check" CHECK (((week_day >= 1) AND (week_day <= 7)));
ALTER TABLE "class" ADD CONSTRAINT "class_check" CHECK ((e_time > s_time));
ALTER TABLE "class" ADD CONSTRAINT "class_module_code_fkey" FOREIGN KEY ("module_code") REFERENCES "public"."courses" ("module_code") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "class" ADD CONSTRAINT "class_rid_fkey" FOREIGN KEY ("rid") REFERENCES "public"."rounds" ("rid") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "courses" ADD CONSTRAINT "courses_admin_fkey" FOREIGN KEY ("admin") REFERENCES "public"."admin" ("uname") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "courses" ADD CONSTRAINT "courses_fname_fkey" FOREIGN KEY ("fname") REFERENCES "public"."faculty" ("fname") ON DELETE CASCADE ON UPDATE NO ACTION;
CREATE TRIGGER "trig4" BEFORE INSERT OR UPDATE ON "games"
FOR EACH ROW
WHEN ((new.price > 100))
EXECUTE PROCEDURE "public"."t_func4"();
ALTER TABLE "prerequisite" ADD CONSTRAINT "prerequisite_check" CHECK (((module_code)::text <> (require)::text));
ALTER TABLE "prerequisite" ADD CONSTRAINT "prerequisite_module_code_fkey" FOREIGN KEY ("module_code") REFERENCES "public"."courses" ("module_code") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "prerequisite" ADD CONSTRAINT "prerequisite_require_fkey" FOREIGN KEY ("require") REFERENCES "public"."courses" ("module_code") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "rounds" ADD CONSTRAINT "rounds_rid_check" CHECK (((rid = 1) OR (rid = 2) OR (rid = 3)));
ALTER TABLE "rounds" ADD CONSTRAINT "rounds_admin_fkey" FOREIGN KEY ("admin") REFERENCES "public"."admin" ("uname") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "student" ADD CONSTRAINT "student_matric_no_key" UNIQUE ("matric_no");
ALTER TABLE "student" ADD CONSTRAINT "student_bid_point_check" CHECK ((bid_point >= 0));
ALTER TABLE "student" ADD CONSTRAINT "student_matric_no_fkey" FOREIGN KEY ("matric_no") REFERENCES "public"."studentinfo" ("matric_no") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "student" ADD CONSTRAINT "student_uname_fkey" FOREIGN KEY ("uname") REFERENCES "public"."users" ("uname") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "studentinfo" ADD CONSTRAINT "studentinfo_cap_check" CHECK (((cap >= (0)::numeric) AND (cap <= (5)::numeric)));
ALTER TABLE "studentinfo" ADD CONSTRAINT "studentinfo_fname_fkey" FOREIGN KEY ("fname") REFERENCES "public"."faculty" ("fname") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "taken" ADD CONSTRAINT "taken_module_code_fkey" FOREIGN KEY ("module_code") REFERENCES "public"."courses" ("module_code") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "taken" ADD CONSTRAINT "taken_uname_fkey" FOREIGN KEY ("uname") REFERENCES "public"."student" ("uname") ON DELETE CASCADE ON UPDATE NO ACTION;
