DROP TABLE IF EXISTS Users CASCADE;
CREATE TABLE Users (
	uname	varchar(30) PRIMARY KEY,
	password	varchar(30)
);

DROP TABLE IF EXISTS Admin CASCADE;
CREATE TABLE Admin (
	uname varchar(30) PRIMARY KEY REFERENCES Users ON DELETE CASCADE /* ISA Use*/
);

DROP TABLE IF EXISTS Faculty CASCADE;
CREATE TABLE Faculty(
	fname varchar(30) PRIMARY KEY
);

DROP TABLE IF EXISTS StudentInfo CASCADE;
CREATE TABLE StudentInfo(
	matric_no varchar(10) PRIMARY KEY,
	cap numeric(3, 2),
	fname varchar(30) NOT NULL REFERENCES Faculty, /* total participation to faculty*/
	CHECK (cap >= 0 and cap <= 5)
);

DROP TABLE IF EXISTS Student CASCADE;
CREATE TABLE Student(
	uname varchar(30) PRIMARY KEY REFERENCES Users ON DELETE CASCADE, /* ISA Use*/
	matric_no varchar(10) UNIQUE NOT NULL REFERENCES StudentInfo, /* key and total participation to student ino*/
	bid_point integer
);

DROP TABLE IF EXISTS Rounds CASCADE;
CREATE TABLE Rounds(
	rid integer PRIMARY KEY,
	admin varchar(30) NOT NULL REFERENCES Admin(uname), /* total participation to admin*/
	s_date date,
	e_date date
);

DROP TABLE IF EXISTS Courses CASCADE;
CREATE TABLE Courses(
	module_code varchar(10) PRIMARY KEY,
	admin varchar(30) NOT NULL REFERENCES Admin(uname), /* total participation to admin*/
	fname varchar(30) REFERENCES Faculty,
	mc integer
);

DROP TABLE IF EXISTS Prerequisite CASCADE;
CREATE TABLE Prerequisite(
	module_code varchar(10) REFERENCES Courses,
	require varchar(10) REFERENCES Courses,
	PRIMARY KEY(module_code, require)
);

DROP TABLE IF EXISTS Class CASCADE;
CREATE TABLE Class(
	module_code varchar(30),
	rid integer,
	quota integer,
	s_time time,
	e_time time,
	PRIMARY KEY(module_code, rid, s_time, e_time),
	FOREIGN KEY (module_code) REFERENCES Courses ON DELETE CASCADE, /* weak entity to Courses*/
	FOREIGN KEY (rid) REFERENCES Rounds ON DELETE CASCADE /* weak entity to Rounds*/
);

DROP TABLE IF EXISTS Lecture CASCADE;
CREATE TABLE Lecture(
	module_code varchar(30),
	rid integer,
	quota integer,
	s_time time,
	e_time time,
	PRIMARY KEY(module_code, rid, s_time, e_time),
	FOREIGN KEY(module_code, rid, s_time, e_time) REFERENCES Class(module_code, rid, s_time, e_time) ON DELETE CASCADE /* ISA class */
);

DROP TABLE IF EXISTS Tutorial CASCADE;
CREATE TABLE Tutorial(
	module_code varchar(30),
	rid integer,
	quota integer,
	s_time time,
	e_time time,
	PRIMARY KEY(module_code, rid, s_time, e_time),
	FOREIGN KEY(module_code, rid, s_time, e_time) REFERENCES Class(module_code, rid, s_time, e_time) ON DELETE CASCADE /* ISA clas*/
);

DROP TABLE IF EXISTS Bid CASCADE;
CREATE TABLE Bid(
	/* potential interesting query 1, select potential successful bid*/
	/* potential interesting constraint 1, check fulfil requirement(pre-requisite and mc limit) */
	/* potential interesting constraint 2, check clash*/
	uname varchar(30) REFERENCES Student,
	bid integer,
	module_code varchar(30),
	rid integer,
	s_time time,
	e_time time,
	is_successful boolean DEFAULT FALSE,
	PRIMARY KEY(module_code, rid, s_time, e_time, uname),
	FOREIGN KEY(module_code, rid, s_time, e_time) REFERENCES Lecture(module_code, rid, s_time, e_time)
);

DROP TABLE IF EXISTS Ballot CASCADE;
CREATE TABLE Ballot(
	/* potential interesting query 2, select potential successful ballot*/
	/* potential interesting constraint 3, check have successful bid on lecture*/
	uname varchar(30) REFERENCES Student,
	rank integer,
	module_code varchar(30),
	rid integer,
	s_time time,
	e_time time,
	is_successful boolean DEFAULT FALSE,
	PRIMARY KEY(module_code, rid, s_time, e_time, uname),
	FOREIGN KEY(module_code, rid, s_time, e_time) REFERENCES Lecture(module_code, rid, s_time, e_time)
);

DROP TABLE IF EXISTS Taken CASCADE;
CREATE TABLE Taken(
	uname varchar(30) REFERENCES Student,
	module_code varchar(10) REFERENCES Courses,
	PRIMARY KEY(uname, module_code)
)