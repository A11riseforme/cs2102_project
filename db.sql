
-- ----------------------------
-- Table structure for admin
-- ----------------------------
DROP TABLE IF EXISTS "public"."admin";
CREATE TABLE "public"."admin" (
  "uname" varchar(30) COLLATE "pg_catalog"."default" NOT NULL
)
;

-- ----------------------------
-- Records of admin
-- ----------------------------
INSERT INTO "public"."admin" VALUES ('admin');

-- ----------------------------
-- Table structure for ballot
-- ----------------------------
DROP TABLE IF EXISTS "public"."ballot";
CREATE TABLE "public"."ballot" (
  "uname" varchar(30) COLLATE "pg_catalog"."default" NOT NULL,
  "rank" int4,
  "module_code" varchar(30) COLLATE "pg_catalog"."default" NOT NULL,
  "rid" int4 NOT NULL,
  "session" int4 NOT NULL,
  "is_successful" bool DEFAULT false
)
;

-- ----------------------------
-- Records of ballot
-- ----------------------------
INSERT INTO "public"."ballot" VALUES ('user', 5, 'cs4000', 3, 1, 'f');
INSERT INTO "public"."ballot" VALUES ('user', 4, 'cs2102', 3, 2, 'f');
INSERT INTO "public"."ballot" VALUES ('user', 1, 'cs2102', 3, 3, 'f');
INSERT INTO "public"."ballot" VALUES ('user', 2, 'cs4000', 3, 2, 'f');
INSERT INTO "public"."ballot" VALUES ('user', 3, 'cs2102', 3, 1, 't');

-- ----------------------------
-- Table structure for bid
-- ----------------------------
DROP TABLE IF EXISTS "public"."bid";
CREATE TABLE "public"."bid" (
  "uname" varchar(30) COLLATE "pg_catalog"."default" NOT NULL,
  "bid" int4,
  "module_code" varchar(30) COLLATE "pg_catalog"."default" NOT NULL,
  "rid" int4 NOT NULL,
  "session" int4 NOT NULL,
  "is_successful" bool DEFAULT false
)
;

-- ----------------------------
-- Records of bid
-- ----------------------------
INSERT INTO "public"."bid" VALUES ('user', 150, 'cs4000', 1, 1, 't');
INSERT INTO "public"."bid" VALUES ('someone', 200, 'cs2102', 1, 1, 't');
INSERT INTO "public"."bid" VALUES ('user', 100, 'cs2102', 1, 1, 't');
INSERT INTO "public"."bid" VALUES ('user', 140, 'cs1111', 2, 1, 'f');

-- ----------------------------
-- Table structure for clash_mod_code
-- ----------------------------
DROP TABLE IF EXISTS "public"."clash_mod_code";
CREATE TABLE "public"."clash_mod_code" (
  "module_code" varchar(30) COLLATE "pg_catalog"."default"
)
;

-- ----------------------------
-- Records of clash_mod_code
-- ----------------------------
INSERT INTO "public"."clash_mod_code" VALUES ('cs2102');

-- ----------------------------
-- Table structure for class
-- ----------------------------
DROP TABLE IF EXISTS "public"."class";
CREATE TABLE "public"."class" (
  "module_code" varchar(30) COLLATE "pg_catalog"."default" NOT NULL,
  "rid" int4 NOT NULL,
  "session" int4 NOT NULL,
  "quota" int4 NOT NULL,
  "week_day" int4 NOT NULL,
  "s_time" time(6) NOT NULL,
  "e_time" time(6) NOT NULL
)
;

-- ----------------------------
-- Records of class
-- ----------------------------
INSERT INTO "public"."class" VALUES ('cs2102', 1, 1, 50, 1, '08:00:00', '10:00:00');
INSERT INTO "public"."class" VALUES ('cs4000', 1, 1, 100, 7, '08:00:00', '10:00:00');
INSERT INTO "public"."class" VALUES ('cs2102', 2, 2, 100, 5, '14:00:00', '16:00:00');
INSERT INTO "public"."class" VALUES ('cs1231', 2, 1, 70, 5, '14:00:00', '16:00:00');
INSERT INTO "public"."class" VALUES ('cs1010', 2, 1, 1, 7, '08:00:00', '10:00:00');
INSERT INTO "public"."class" VALUES ('cs3000', 2, 1, 100, 7, '08:00:00', '10:00:00');
INSERT INTO "public"."class" VALUES ('cs4000', 2, 1, 100, 7, '01:01:01', '10:10:10');
INSERT INTO "public"."class" VALUES ('cs4000', 1, 2, 50, 1, '09:00:00', '11:00:00');
INSERT INTO "public"."class" VALUES ('cs2102', 3, 1, 50, 2, '14:00:00', '15:00:00');
INSERT INTO "public"."class" VALUES ('cs2102', 3, 2, 40, 2, '15:00:00', '16:00:00');
INSERT INTO "public"."class" VALUES ('cs4000', 3, 1, 20, 3, '10:00:00', '11:00:00');
INSERT INTO "public"."class" VALUES ('cs1111', 1, 1, 90, 1, '18:00:00', '21:00:00');
INSERT INTO "public"."class" VALUES ('cs1111', 1, 2, 90, 1, '19:00:00', '22:00:00');
INSERT INTO "public"."class" VALUES ('cs3000', 2, 2, 100, 7, '12:00:00', '14:00:00');
INSERT INTO "public"."class" VALUES ('cs3000', 2, 3, 30, 7, '13:00:00', '15:00:00');
INSERT INTO "public"."class" VALUES ('cs1111', 2, 1, 40, 1, '12:00:00', '14:00:00');
INSERT INTO "public"."class" VALUES ('cs1111', 2, 3, 40, 1, '09:00:00', '11:00:00');
INSERT INTO "public"."class" VALUES ('cs1111', 2, 4, 50, 1, '11:00:00', '13:00:00');
INSERT INTO "public"."class" VALUES ('cs2102', 3, 3, 20, 7, '09:00:00', '10:00:00');
INSERT INTO "public"."class" VALUES ('cs4000', 3, 2, 50, 2, '14:00:00', '16:00:00');

-- ----------------------------
-- Table structure for courses
-- ----------------------------
DROP TABLE IF EXISTS "public"."courses";
CREATE TABLE "public"."courses" (
  "module_code" varchar(10) COLLATE "pg_catalog"."default" NOT NULL,
  "admin" varchar(30) COLLATE "pg_catalog"."default" NOT NULL,
  "fname" varchar(30) COLLATE "pg_catalog"."default" NOT NULL,
  "mc" int4 NOT NULL
)
;

-- ----------------------------
-- Records of courses
-- ----------------------------
INSERT INTO "public"."courses" VALUES ('cs2102', 'admin', 'SOC', 4);
INSERT INTO "public"."courses" VALUES ('cs1231', 'admin', 'SOC', 4);
INSERT INTO "public"."courses" VALUES ('cs1010', 'admin', 'SOC', 4);
INSERT INTO "public"."courses" VALUES ('cs3000', 'admin', 'SOC', 4);
INSERT INTO "public"."courses" VALUES ('cs4000', 'admin', 'SOC', 4);
INSERT INTO "public"."courses" VALUES ('cs1020', 'admin', 'SOC', 10);
INSERT INTO "public"."courses" VALUES ('cs1222', 'admin', 'FOE', 4);
INSERT INTO "public"."courses" VALUES ('cs1223', 'admin', 'FOE', 4);
INSERT INTO "public"."courses" VALUES ('cs1111', 'admin', 'SOC', 5);
INSERT INTO "public"."courses" VALUES ('ee1501', 'admin', 'FOE', 4);
INSERT INTO "public"."courses" VALUES ('cs2040c', 'admin', 'SOC', 4);
INSERT INTO "public"."courses" VALUES ('cs2105', 'admin', 'SOC', 5);
INSERT INTO "public"."courses" VALUES ('EE3123', 'admin', 'FOE', 2);

-- ----------------------------
-- Table structure for faculty
-- ----------------------------
DROP TABLE IF EXISTS "public"."faculty";
CREATE TABLE "public"."faculty" (
  "fname" varchar(30) COLLATE "pg_catalog"."default" NOT NULL
)
;

-- ----------------------------
-- Records of faculty
-- ----------------------------
INSERT INTO "public"."faculty" VALUES ('SOC');
INSERT INTO "public"."faculty" VALUES ('FOE');
INSERT INTO "public"."faculty" VALUES ('FASS');

-- ----------------------------
-- Table structure for games
-- ----------------------------
DROP TABLE IF EXISTS "public"."games";
CREATE TABLE "public"."games" (
  "name" varchar(255) COLLATE "pg_catalog"."default",
  "price" int4
)
;

-- ----------------------------
-- Records of games
-- ----------------------------
INSERT INTO "public"."games" VALUES ('asdf', 105);
INSERT INTO "public"."games" VALUES ('asdf', 105);
INSERT INTO "public"."games" VALUES ('shi yi xia', 99);

-- ----------------------------
-- Table structure for prerequisite
-- ----------------------------
DROP TABLE IF EXISTS "public"."prerequisite";
CREATE TABLE "public"."prerequisite" (
  "module_code" varchar(10) COLLATE "pg_catalog"."default" NOT NULL,
  "require" varchar(10) COLLATE "pg_catalog"."default" NOT NULL
)
;

-- ----------------------------
-- Records of prerequisite
-- ----------------------------
INSERT INTO "public"."prerequisite" VALUES ('cs2102', 'cs1231');
INSERT INTO "public"."prerequisite" VALUES ('cs3000', 'cs1111');

-- ----------------------------
-- Table structure for rounds
-- ----------------------------
DROP TABLE IF EXISTS "public"."rounds";
CREATE TABLE "public"."rounds" (
  "rid" int4 NOT NULL,
  "admin" varchar(30) COLLATE "pg_catalog"."default" NOT NULL,
  "s_date" timestamp(6) NOT NULL,
  "e_date" timestamp(6) NOT NULL
)
;

-- ----------------------------
-- Records of rounds
-- ----------------------------
INSERT INTO "public"."rounds" VALUES (1, 'admin', '2019-11-04 08:00:00', '2019-11-08 11:59:59');
INSERT INTO "public"."rounds" VALUES (2, 'admin', '2019-11-09 08:00:00', '2019-11-15 11:59:59');
INSERT INTO "public"."rounds" VALUES (3, 'admin', '2019-11-16 09:00:00', '2019-11-20 11:59:59');

-- ----------------------------
-- Table structure for student
-- ----------------------------
DROP TABLE IF EXISTS "public"."student";
CREATE TABLE "public"."student" (
  "uname" varchar(30) COLLATE "pg_catalog"."default" NOT NULL,
  "matric_no" varchar(10) COLLATE "pg_catalog"."default" NOT NULL,
  "bid_point" int4 NOT NULL,
  "authcode" varchar(255) COLLATE "pg_catalog"."default"
)
;

-- ----------------------------
-- Records of student
-- ----------------------------
INSERT INTO "public"."student" VALUES ('someone', 'A101', 500, NULL);
INSERT INTO "public"."student" VALUES ('user', 'A100', 1000, 'OROREIHHMJ');

-- ----------------------------
-- Table structure for studentinfo
-- ----------------------------
DROP TABLE IF EXISTS "public"."studentinfo";
CREATE TABLE "public"."studentinfo" (
  "matric_no" varchar(10) COLLATE "pg_catalog"."default" NOT NULL,
  "cap" numeric(3,2) NOT NULL,
  "fname" varchar(30) COLLATE "pg_catalog"."default" NOT NULL,
  "rname" varchar(255) COLLATE "pg_catalog"."default" NOT NULL
)
;

-- ----------------------------
-- Records of studentinfo
-- ----------------------------
INSERT INTO "public"."studentinfo" VALUES ('A101', 2.00, 'FOE', 'Ye Guoquan');
INSERT INTO "public"."studentinfo" VALUES ('A102', 0.00, 'FASS', 'Huang Xuankun');
INSERT INTO "public"."studentinfo" VALUES ('A1', 4.00, 'SOC', 'Wei Feng');
INSERT INTO "public"."studentinfo" VALUES ('A100', 4.00, 'SOC', 'Lebron James');

-- ----------------------------
-- Table structure for taken
-- ----------------------------
DROP TABLE IF EXISTS "public"."taken";
CREATE TABLE "public"."taken" (
  "uname" varchar(30) COLLATE "pg_catalog"."default" NOT NULL,
  "module_code" varchar(10) COLLATE "pg_catalog"."default" NOT NULL
)
;

-- ----------------------------
-- Records of taken
-- ----------------------------
INSERT INTO "public"."taken" VALUES ('user', 'cs1010');
INSERT INTO "public"."taken" VALUES ('user', 'cs1231');
INSERT INTO "public"."taken" VALUES ('user', 'cs2040c');

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS "public"."users";
CREATE TABLE "public"."users" (
  "uname" varchar(30) COLLATE "pg_catalog"."default" NOT NULL,
  "password" varchar(30) COLLATE "pg_catalog"."default" NOT NULL
)
;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO "public"."users" VALUES ('someone', 'someone');
INSERT INTO "public"."users" VALUES ('d', 'd');
INSERT INTO "public"."users" VALUES ('b', 'b');
INSERT INTO "public"."users" VALUES ('c', 'c');
INSERT INTO "public"."users" VALUES ('admin', 'password1');
INSERT INTO "public"."users" VALUES ('user', 'password');

-- ----------------------------
-- Function structure for check_bidpoint
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."check_bidpoint"();
CREATE OR REPLACE FUNCTION "public"."check_bidpoint"()
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

-- ----------------------------
-- Function structure for check_prerequisite
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."check_prerequisite"();
CREATE OR REPLACE FUNCTION "public"."check_prerequisite"()
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

-- ----------------------------
-- Function structure for f_random_str
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."f_random_str"("length" int4);
CREATE OR REPLACE FUNCTION "public"."f_random_str"("length" int4)
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

-- ----------------------------
-- Function structure for lecture_clash
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."lecture_clash"();
CREATE OR REPLACE FUNCTION "public"."lecture_clash"()
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

-- ----------------------------
-- Function structure for require_lecture
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."require_lecture"();
CREATE OR REPLACE FUNCTION "public"."require_lecture"()
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

-- ----------------------------
-- Function structure for t_func4
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."t_func4"();
CREATE OR REPLACE FUNCTION "public"."t_func4"()
  RETURNS "pg_catalog"."trigger" AS $BODY$ BEGIN
RAISE EXCEPTION 'Trigger 4'; RETURN NULL;
END; $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

-- ----------------------------
-- Function structure for tutorial_clash
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."tutorial_clash"();
CREATE OR REPLACE FUNCTION "public"."tutorial_clash"()
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

-- ----------------------------
-- Primary Key structure for table admin
-- ----------------------------
ALTER TABLE "public"."admin" ADD CONSTRAINT "admin_pkey" PRIMARY KEY ("uname");

-- ----------------------------
-- Triggers structure for table ballot
-- ----------------------------
CREATE TRIGGER "lecture_before_tut" BEFORE INSERT ON "public"."ballot"
FOR EACH ROW
EXECUTE PROCEDURE "public"."require_lecture"();
CREATE TRIGGER "prevent_tutorial_clash" BEFORE UPDATE ON "public"."ballot"
FOR EACH ROW
EXECUTE PROCEDURE "public"."tutorial_clash"();
CREATE TRIGGER "tutorial_clash_with_lecture" BEFORE INSERT ON "public"."ballot"
FOR EACH ROW
EXECUTE PROCEDURE "public"."tutorial_clash"();

-- ----------------------------
-- Uniques structure for table ballot
-- ----------------------------
ALTER TABLE "public"."ballot" ADD CONSTRAINT "ballot_uname_module_code_rid_rank_key" UNIQUE ("uname", "module_code", "rid", "rank");

-- ----------------------------
-- Checks structure for table ballot
-- ----------------------------
ALTER TABLE "public"."ballot" ADD CONSTRAINT "ballot_rank_check" CHECK (((rank >= 1) AND (rank <= 20)));
ALTER TABLE "public"."ballot" ADD CONSTRAINT "ballot_rid_check" CHECK ((rid = 3));

-- ----------------------------
-- Primary Key structure for table ballot
-- ----------------------------
ALTER TABLE "public"."ballot" ADD CONSTRAINT "ballot_pkey" PRIMARY KEY ("uname", "module_code", "rid", "session");

-- ----------------------------
-- Triggers structure for table bid
-- ----------------------------
CREATE TRIGGER "check_bidpoint" BEFORE INSERT OR UPDATE OR DELETE ON "public"."bid"
FOR EACH ROW
EXECUTE PROCEDURE "public"."check_bidpoint"();
CREATE TRIGGER "check_prerequisite" BEFORE INSERT ON "public"."bid"
FOR EACH ROW
EXECUTE PROCEDURE "public"."check_prerequisite"();
CREATE TRIGGER "lecture_clash" BEFORE INSERT ON "public"."bid"
FOR EACH ROW
EXECUTE PROCEDURE "public"."lecture_clash"();

-- ----------------------------
-- Checks structure for table bid
-- ----------------------------
ALTER TABLE "public"."bid" ADD CONSTRAINT "bid_rid_check" CHECK (((rid = 1) OR (rid = 2)));
ALTER TABLE "public"."bid" ADD CONSTRAINT "bid_bid_check" CHECK ((bid > 0));

-- ----------------------------
-- Primary Key structure for table bid
-- ----------------------------
ALTER TABLE "public"."bid" ADD CONSTRAINT "bid_pkey" PRIMARY KEY ("uname", "module_code", "rid", "session");

-- ----------------------------
-- Checks structure for table class
-- ----------------------------
ALTER TABLE "public"."class" ADD CONSTRAINT "class_week_day_check" CHECK (((week_day >= 1) AND (week_day <= 7)));
ALTER TABLE "public"."class" ADD CONSTRAINT "class_check" CHECK ((e_time > s_time));

-- ----------------------------
-- Primary Key structure for table class
-- ----------------------------
ALTER TABLE "public"."class" ADD CONSTRAINT "class_pkey" PRIMARY KEY ("module_code", "rid", "session");

-- ----------------------------
-- Primary Key structure for table courses
-- ----------------------------
ALTER TABLE "public"."courses" ADD CONSTRAINT "courses_pkey" PRIMARY KEY ("module_code");

-- ----------------------------
-- Primary Key structure for table faculty
-- ----------------------------
ALTER TABLE "public"."faculty" ADD CONSTRAINT "faculty_pkey" PRIMARY KEY ("fname");

-- ----------------------------
-- Triggers structure for table games
-- ----------------------------
CREATE TRIGGER "trig4" BEFORE INSERT OR UPDATE ON "public"."games"
FOR EACH ROW
WHEN ((new.price > 100))
EXECUTE PROCEDURE "public"."t_func4"();

-- ----------------------------
-- Checks structure for table prerequisite
-- ----------------------------
ALTER TABLE "public"."prerequisite" ADD CONSTRAINT "prerequisite_check" CHECK (((module_code)::text <> (require)::text));

-- ----------------------------
-- Primary Key structure for table prerequisite
-- ----------------------------
ALTER TABLE "public"."prerequisite" ADD CONSTRAINT "prerequisite_pkey" PRIMARY KEY ("module_code", "require");

-- ----------------------------
-- Checks structure for table rounds
-- ----------------------------
ALTER TABLE "public"."rounds" ADD CONSTRAINT "rounds_rid_check" CHECK (((rid = 1) OR (rid = 2) OR (rid = 3)));

-- ----------------------------
-- Primary Key structure for table rounds
-- ----------------------------
ALTER TABLE "public"."rounds" ADD CONSTRAINT "rounds_pkey" PRIMARY KEY ("rid");

-- ----------------------------
-- Uniques structure for table student
-- ----------------------------
ALTER TABLE "public"."student" ADD CONSTRAINT "student_matric_no_key" UNIQUE ("matric_no");

-- ----------------------------
-- Checks structure for table student
-- ----------------------------
ALTER TABLE "public"."student" ADD CONSTRAINT "student_bid_point_check" CHECK ((bid_point >= 0));

-- ----------------------------
-- Primary Key structure for table student
-- ----------------------------
ALTER TABLE "public"."student" ADD CONSTRAINT "student_pkey" PRIMARY KEY ("uname");

-- ----------------------------
-- Checks structure for table studentinfo
-- ----------------------------
ALTER TABLE "public"."studentinfo" ADD CONSTRAINT "studentinfo_cap_check" CHECK (((cap >= (0)::numeric) AND (cap <= (5)::numeric)));

-- ----------------------------
-- Primary Key structure for table studentinfo
-- ----------------------------
ALTER TABLE "public"."studentinfo" ADD CONSTRAINT "studentinfo_pkey" PRIMARY KEY ("matric_no");

-- ----------------------------
-- Primary Key structure for table taken
-- ----------------------------
ALTER TABLE "public"."taken" ADD CONSTRAINT "taken_pkey" PRIMARY KEY ("uname", "module_code");

-- ----------------------------
-- Primary Key structure for table users
-- ----------------------------
ALTER TABLE "public"."users" ADD CONSTRAINT "users_pkey" PRIMARY KEY ("uname");

-- ----------------------------
-- Foreign Keys structure for table admin
-- ----------------------------
ALTER TABLE "public"."admin" ADD CONSTRAINT "admin_uname_fkey" FOREIGN KEY ("uname") REFERENCES "public"."users" ("uname") ON DELETE CASCADE ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table ballot
-- ----------------------------
ALTER TABLE "public"."ballot" ADD CONSTRAINT "ballot_module_code_fkey" FOREIGN KEY ("module_code", "rid", "session") REFERENCES "public"."class" ("module_code", "rid", "session") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "public"."ballot" ADD CONSTRAINT "ballot_uname_fkey" FOREIGN KEY ("uname") REFERENCES "public"."student" ("uname") ON DELETE CASCADE ON UPDATE CASCADE;

-- ----------------------------
-- Foreign Keys structure for table bid
-- ----------------------------
ALTER TABLE "public"."bid" ADD CONSTRAINT "bid_module_code_fkey" FOREIGN KEY ("module_code", "rid", "session") REFERENCES "public"."class" ("module_code", "rid", "session") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "public"."bid" ADD CONSTRAINT "bid_uname_fkey" FOREIGN KEY ("uname") REFERENCES "public"."student" ("uname") ON DELETE CASCADE ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table class
-- ----------------------------
ALTER TABLE "public"."class" ADD CONSTRAINT "class_module_code_fkey" FOREIGN KEY ("module_code") REFERENCES "public"."courses" ("module_code") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "public"."class" ADD CONSTRAINT "class_rid_fkey" FOREIGN KEY ("rid") REFERENCES "public"."rounds" ("rid") ON DELETE CASCADE ON UPDATE CASCADE;

-- ----------------------------
-- Foreign Keys structure for table courses
-- ----------------------------
ALTER TABLE "public"."courses" ADD CONSTRAINT "courses_admin_fkey" FOREIGN KEY ("admin") REFERENCES "public"."admin" ("uname") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "public"."courses" ADD CONSTRAINT "courses_fname_fkey" FOREIGN KEY ("fname") REFERENCES "public"."faculty" ("fname") ON DELETE CASCADE ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table prerequisite
-- ----------------------------
ALTER TABLE "public"."prerequisite" ADD CONSTRAINT "prerequisite_module_code_fkey" FOREIGN KEY ("module_code") REFERENCES "public"."courses" ("module_code") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "public"."prerequisite" ADD CONSTRAINT "prerequisite_require_fkey" FOREIGN KEY ("require") REFERENCES "public"."courses" ("module_code") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table rounds
-- ----------------------------
ALTER TABLE "public"."rounds" ADD CONSTRAINT "rounds_admin_fkey" FOREIGN KEY ("admin") REFERENCES "public"."admin" ("uname") ON DELETE CASCADE ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table student
-- ----------------------------
ALTER TABLE "public"."student" ADD CONSTRAINT "student_matric_no_fkey" FOREIGN KEY ("matric_no") REFERENCES "public"."studentinfo" ("matric_no") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "public"."student" ADD CONSTRAINT "student_uname_fkey" FOREIGN KEY ("uname") REFERENCES "public"."users" ("uname") ON DELETE CASCADE ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table studentinfo
-- ----------------------------
ALTER TABLE "public"."studentinfo" ADD CONSTRAINT "studentinfo_fname_fkey" FOREIGN KEY ("fname") REFERENCES "public"."faculty" ("fname") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table taken
-- ----------------------------
ALTER TABLE "public"."taken" ADD CONSTRAINT "taken_module_code_fkey" FOREIGN KEY ("module_code") REFERENCES "public"."courses" ("module_code") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "public"."taken" ADD CONSTRAINT "taken_uname_fkey" FOREIGN KEY ("uname") REFERENCES "public"."student" ("uname") ON DELETE CASCADE ON UPDATE NO ACTION;
