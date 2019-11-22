CREATE OR REPLACE FUNCTION avoid_class_time_clash()
RETURNS TRIGGER AS $$
DECLARE
clash_mod_code VARCHAR(30),
clash_rnd_id INT,
clash_class_id INT;
BEGIN
      SELECT S.module_code, S.rid, S.cid INTO clash_mod_code, clash_rnd_id, clash_class_id
      FROM (
      SELECT * FROM has_class
      WHERE has_class.module_code=NEW.module_code AND has_class.rid = NEW.rid 
      AND has_class.cid = NEW.cid
    ) B
      INNER JOIN (
      SELECT * FROM bids
      NATURAL JOIN has_class
      WHERE bids.uname=NEW.uname
      AND is_successful=TRUE
    ) S
      ON S.week_day=B.week_day
      AND (
       B.s_time BETWEEN S.s_time AND S.e_time
       OR B.e_time BETWEEN S.s_time AND S.e_time
       OR S.s_time BETWEEN B.s_time AND B.e_time
       OR S.e_time BETWEEN B.s_time AND B.e_time
       ) LIMIT 1;
       IF clash_task_id IS NOT NULL
       THEN RAISE EXCEPTION 'time table clash with module % round % class % ', clash_mod_code, 
       clash_rnd_id, clash_class_id;
     END IF;
     RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER avoid_class_time_clash
BEFORE INSERT ON bids
FOR EACH ROW
EXECUTE PROCEDURE avoid_class_time_clash();