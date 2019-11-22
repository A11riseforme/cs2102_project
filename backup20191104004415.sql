/*
PostgreSQL Backup
Database: postgres/public
Backup Time: 2019-11-04 00:44:16
*/

DROP TABLE IF EXISTS "public"."admins";
DROP TABLE IF EXISTS "public"."students";
DROP TABLE IF EXISTS "public"."studentsinfo";
DROP TABLE IF EXISTS "public"."users";
DROP FUNCTION IF EXISTS "public"."f_random_str(length int4)";
CREATE TABLE "admins" (
  "username" varchar(50) COLLATE "pg_catalog"."default" NOT NULL
)
;
ALTER TABLE "admins" OWNER TO "postgres";
CREATE TABLE "students" (
  "username" varchar(50) COLLATE "pg_catalog"."default" NOT NULL,
  "matricid" varchar(50) COLLATE "pg_catalog"."default",
  "authcode" varchar(20) COLLATE "pg_catalog"."default"
)
;
ALTER TABLE "students" OWNER TO "postgres";
CREATE TABLE "studentsinfo" (
  "matricid" varchar(50) COLLATE "pg_catalog"."default" NOT NULL,
  "cap" numeric(2) NOT NULL,
  "bidpoints" int4 NOT NULL,
  "realname" varchar(50) COLLATE "pg_catalog"."default" NOT NULL,
  "faculty" varchar(50) COLLATE "pg_catalog"."default" NOT NULL
)
;
ALTER TABLE "studentsinfo" OWNER TO "postgres";
CREATE TABLE "users" (
  "username" varchar(50) COLLATE "pg_catalog"."default" NOT NULL,
  "password" varchar(256) COLLATE "pg_catalog"."default" NOT NULL,
  "isAdmin" int4 NOT NULL
)
;
ALTER TABLE "users" OWNER TO "postgres";
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
BEGIN;
LOCK TABLE "public"."admins" IN SHARE MODE;
DELETE FROM "public"."admins";
COMMIT;
BEGIN;
LOCK TABLE "public"."students" IN SHARE MODE;
DELETE FROM "public"."students";
INSERT INTO "public"."students" ("username","matricid","authcode") VALUES ('e0175540', 'A0167107H', 'CRQHKCAYNJ');
COMMIT;
BEGIN;
LOCK TABLE "public"."studentsinfo" IN SHARE MODE;
DELETE FROM "public"."studentsinfo";
INSERT INTO "public"."studentsinfo" ("matricid","cap","bidpoints","realname","faculty") VALUES ('A0167107H', 2, 1200, 'Yang Chenglong', 'SOC');
COMMIT;
BEGIN;
LOCK TABLE "public"."users" IN SHARE MODE;
DELETE FROM "public"."users";
INSERT INTO "public"."users" ("username","password","isAdmin") VALUES ('admin', 'password', 1),('e0175540', 'password1', 0);
COMMIT;
ALTER TABLE "admins" ADD CONSTRAINT "admins_pkey" PRIMARY KEY ("username");
ALTER TABLE "students" ADD CONSTRAINT "students_pkey" PRIMARY KEY ("username");
ALTER TABLE "studentsinfo" ADD CONSTRAINT "studentsinfo_pkey" PRIMARY KEY ("matricid");
ALTER TABLE "users" ADD CONSTRAINT "users_pkey" PRIMARY KEY ("username");
ALTER TABLE "admins" ADD CONSTRAINT "admins_username_fkey" FOREIGN KEY ("username") REFERENCES "public"."users" ("username") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "students" ADD CONSTRAINT "students_matricid_key" UNIQUE ("matricid");
ALTER TABLE "students" ADD CONSTRAINT "students_matricid_fkey" FOREIGN KEY ("matricid") REFERENCES "public"."studentsinfo" ("matricid") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "students" ADD CONSTRAINT "students_username_fkey" FOREIGN KEY ("username") REFERENCES "public"."users" ("username") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "studentsinfo" ADD CONSTRAINT "studentsinfo_cap_check" CHECK ((cap > (0)::numeric));
