--- Team #7:
---     Zhen Wu (zhw87)
---     Sushruti Bansod (sdb88)


---DROP DATABASE ELEMENTS TO MAKE SURE THE SCHEMA IS CLEAR (E.G., TABLES, DOMAINS, ETC.)
DROP TABLE IF EXISTS FOREST CASCADE;
DROP TABLE IF EXISTS STATE CASCADE;
DROP TABLE IF EXISTS COVERAGE CASCADE;
DROP TABLE IF EXISTS ROAD CASCADE;
DROP TABLE IF EXISTS INTERSECTION CASCADE;
DROP TABLE IF EXISTS WORKER CASCADE;
DROP TABLE IF EXISTS SENSOR CASCADE;
DROP TABLE IF EXISTS REPORT CASCADE;
DROP DOMAIN IF EXISTS energy_dom;

CREATE DOMAIN energy_dom AS integer CHECK (value >= 0 AND value <= 100);

CREATE TABLE FOREST (
    forest_no       SERIAL,
    name            varchar(30) NOT NULL,
    area            real NOT NULL,
    acid_level      real NOT NULL,
    mbr_xmin        real NOT NULL,
    mbr_xmax        real NOT NULL,
    mbr_ymin        real NOT NULL,
    mbr_ymax        real NOT NULL,
    CONSTRAINT FOREST_PK PRIMARY KEY (forest_no),
    CONSTRAINT FOREST_UN1 UNIQUE (name),
    CONSTRAINT FOREST_UN2 UNIQUE (mbr_xmin, mbr_xmax, mbr_ymin, mbr_ymax),
    CONSTRAINT FOREST_CH CHECK (acid_level >= 0 AND acid_level <= 1)
);


CREATE TABLE STATE (
    name            varchar(30) NOT NULL,
    abbreviation    varchar(2),
    area            real NOT NULL,
    population      integer NOT NULL,
    CONSTRAINT STATE_PK PRIMARY KEY (abbreviation),
    CONSTRAINT STATE_UN UNIQUE (name)
);


CREATE TABLE COVERAGE (
    forest_no       SERIAL,
    state           varchar(2),
    percentage      real NOT NULL,
    area            real NOT NULL,
    CONSTRAINT COVERAGE_PK PRIMARY KEY (forest_no, state),
    CONSTRAINT COVERAGE_FK1 FOREIGN KEY (forest_no) REFERENCES FOREST(forest_no),
    CONSTRAINT COVERAGE_FK2 FOREIGN KEY (state) REFERENCES STATE(abbreviation)
);


CREATE TABLE ROAD (
    road_no varchar(10),
    name    varchar(30) NOT NULL,
    length  real NOT NULL,
    CONSTRAINT ROAD_PK PRIMARY KEY (road_no)
);


CREATE TABLE INTERSECTION (
    forest_no SERIAL,
    road_no   varchar(10),
    CONSTRAINT INTERSECTION_PK PRIMARY KEY (forest_no, road_no),
    CONSTRAINT INTERSECTION_FK1 FOREIGN KEY (forest_no) REFERENCES FOREST(forest_no),
    CONSTRAINT INTERSECTION_FK2 FOREIGN KEY (road_no) REFERENCES ROAD(road_no)
  );


CREATE TABLE WORKER (
    ssn  varchar(9) ,
    name varchar(30) NOT NULL,
    rank integer NOT NULL,
    employing_state varchar(2) NOT NULL,
    CONSTRAINT WORKER_PK PRIMARY KEY (ssn),
    CONSTRAINT WORKER_UN UNIQUE (name),
    CONSTRAINT WORKER_FK FOREIGN KEY (employing_state) REFERENCES STATE(abbreviation)
);


CREATE TABLE SENSOR
  (
    sensor_id SERIAL,
    x real NOT NULL,
    y real NOT NULL,
    last_charged timestamp NOT NULL,
    maintainer   varchar(9) DEFAULT NULL,
    last_read    timestamp NOT NULL,
    energy energy_dom NOT NULL,
    CONSTRAINT SENSOR_PK PRIMARY KEY (sensor_id),
    CONSTRAINT SENSOR_FK FOREIGN KEY (maintainer) REFERENCES WORKER(ssn),
    CONSTRAINT SENSOR_UN2 UNIQUE (x, y)
);

CREATE TABLE REPORT (
    sensor_id SERIAL,
    report_time timestamp NOT NULL,
    temperature real NOT NULL,
    CONSTRAINT REPORT_PK PRIMARY KEY (sensor_id, report_time),
    CONSTRAINT REPORT_FK FOREIGN KEY (sensor_id) REFERENCES SENSOR(sensor_id)
);

--------Question 1

--FOREST
ALTER TABLE FOREST DROP CONSTRAINT IF EXISTS FOREST_PK CASCADE;
ALTER TABLE FOREST ADD CONSTRAINT FOREST_PK PRIMARY KEY (forest_no) NOT DEFERRABLE;

ALTER TABLE FOREST DROP CONSTRAINT IF EXISTS FOREST_UN1 CASCADE;
ALTER TABLE FOREST ADD CONSTRAINT FOREST_UN1 UNIQUE (name) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE FOREST DROP CONSTRAINT IF EXISTS FOREST_UN2 CASCADE;
ALTER TABLE FOREST ADD CONSTRAINT FOREST_UN2 UNIQUE (mbr_xmin, mbr_xmax, mbr_ymin, mbr_ymax) DEFERRABLE INITIALLY DEFERRED;

--STATE
ALTER TABLE STATE DROP CONSTRAINT IF EXISTS STATE_PK CASCADE;
ALTER TABLE STATE ADD CONSTRAINT STATE_PK PRIMARY KEY (abbreviation) NOT DEFERRABLE;

ALTER TABLE STATE DROP CONSTRAINT IF EXISTS STATE_UN CASCADE;
ALTER TABLE STATE ADD CONSTRAINT STATE_UN UNIQUE (name) DEFERRABLE INITIALLY DEFERRED;

--COVERAGE
ALTER TABLE COVERAGE DROP CONSTRAINT IF EXISTS COVERAGE_PK CASCADE;
ALTER TABLE COVERAGE ADD CONSTRAINT COVERAGE_PK PRIMARY KEY (forest_no, state) NOT DEFERRABLE;

ALTER TABLE COVERAGE DROP CONSTRAINT IF EXISTS COVERAGE_FK1 CASCADE;
ALTER TABLE COVERAGE ADD CONSTRAINT COVERAGE_FK1 FOREIGN KEY (forest_no) REFERENCES FOREST(forest_no) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE COVERAGE DROP CONSTRAINT IF EXISTS COVERAGE_FK2 CASCADE;
ALTER TABLE COVERAGE ADD CONSTRAINT COVERAGE_FK2 FOREIGN KEY (state) REFERENCES STATE(abbreviation) DEFERRABLE INITIALLY IMMEDIATE;

--ROAD
ALTER TABLE ROAD DROP CONSTRAINT IF EXISTS ROAD_PK CASCADE;
ALTER TABLE ROAD ADD CONSTRAINT ROAD_PK PRIMARY KEY (road_no) NOT DEFERRABLE;

--INTERSECTION
ALTER TABLE INTERSECTION DROP CONSTRAINT IF EXISTS INTERSECTION_PK CASCADE;
ALTER TABLE INTERSECTION ADD CONSTRAINT INTERSECTION_PK PRIMARY KEY (forest_no, road_no) NOT DEFERRABLE;

ALTER TABLE INTERSECTION DROP CONSTRAINT IF EXISTS INTERSECTION_FK1 CASCADE;
ALTER TABLE INTERSECTION ADD CONSTRAINT INTERSECTION_FK1 FOREIGN KEY (forest_no) REFERENCES FOREST(forest_no) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE INTERSECTION DROP CONSTRAINT IF EXISTS INTERSECTION_FK2 CASCADE;
ALTER TABLE INTERSECTION ADD CONSTRAINT INTERSECTION_FK2 FOREIGN KEY (road_no) REFERENCES ROAD(road_no) DEFERRABLE INITIALLY IMMEDIATE;

--WORKER
ALTER TABLE WORKER DROP CONSTRAINT IF EXISTS WORKER_PK CASCADE;
ALTER TABLE WORKER ADD CONSTRAINT WORKER_PK PRIMARY KEY (ssn) NOT DEFERRABLE;

ALTER TABLE WORKER DROP CONSTRAINT IF EXISTS WORKER_UN CASCADE;
ALTER TABLE WORKER ADD CONSTRAINT WORKER_UN UNIQUE (name) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE WORKER DROP CONSTRAINT IF EXISTS WORKER_FK CASCADE;
ALTER TABLE WORKER ADD CONSTRAINT WORKER_FK FOREIGN KEY (employing_state) REFERENCES STATE(abbreviation) DEFERRABLE INITIALLY IMMEDIATE;

--SENSOR
ALTER TABLE SENSOR DROP CONSTRAINT IF EXISTS SENSOR_PK CASCADE;
ALTER TABLE SENSOR ADD CONSTRAINT SENSOR_PK PRIMARY KEY (sensor_id) NOT DEFERRABLE;

ALTER TABLE SENSOR DROP CONSTRAINT IF EXISTS SENSOR_FK CASCADE;
ALTER TABLE SENSOR ADD CONSTRAINT SENSOR_FK FOREIGN KEY (maintainer) REFERENCES WORKER(ssn) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE SENSOR DROP CONSTRAINT IF EXISTS SENSOR_UN2 CASCADE;
ALTER TABLE SENSOR ADD CONSTRAINT SENSOR_UN2 UNIQUE (x, y) DEFERRABLE INITIALLY DEFERRED;

--REPORT
ALTER TABLE REPORT DROP CONSTRAINT IF EXISTS REPORT_PK CASCADE;
ALTER TABLE REPORT ADD CONSTRAINT REPORT_PK PRIMARY KEY (sensor_id, report_time) NOT DEFERRABLE;

ALTER TABLE REPORT DROP CONSTRAINT IF EXISTS REPORT_FK CASCADE;
ALTER TABLE REPORT ADD CONSTRAINT REPORT_FK FOREIGN KEY (sensor_id) REFERENCES SENSOR(sensor_id) DEFERRABLE INITIALLY IMMEDIATE;

