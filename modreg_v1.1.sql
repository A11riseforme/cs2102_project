DROP TABLE IF EXISTS Users CASCADE;
CREATE TABLE Users (
	uname	varchar(30) PRIMARY KEY,
	password	varchar(30)
);

DROP TABLE IF EXISTS Admin CASCADE;
CREATE TABLE Admin (
	uname varchar(30) PRIMARY KEY REFERENCES Users ON DELETE CASCADE /* ISA Use*/
);

DROP TABLE IF EXISTS Student CASCADE;
CREATE TABLE Student(
	uname varchar(30) PRIMARY KEY REFERENCES Users ON DELETE CASCADE, /* ISA Use*/
	matric_no varchar(10) UNIQUE NOT NULL REFERENCES StudentInfo, /* key and total participation to student ino*/
	bid_point integer
);

DROP TABLE IF EXISTS StudentInfo CASCADE;
CREATE TABLE StudentInfo(
	matric_no varchar(10) PRIMARY KEY,
	cap numeric(3, 2),
	fname varchar(30) NOT NULL REFERENCES Faculty, /* total participation to faculty*/
	CHECK (cap >= 0 and cap <= 5)
);

DROP TABLE IF EXISTS Faculty CASCADE;
CREATE TABLE Faculty(
	fname varchar(30) PRIMARY KEY
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
	fname varchar(30) NOT NULL REFERENCES Faculty, /* total participation to faculty */
	mc integer
);

DROP TABLE IF EXISTS Prerequisite CASCADE;
CREATE TABLE Prerequisite(
	module_code varchar(10) REFERENCES Courses,
	require varchar(10) REFERENCES Courses,
	PRIMARY KEY(module_code, require)
);

DROP TABLE IF EXISTS has_class CASCADE;
CREATE TABLE has_class(
	module_code VARCHAR(30) NOT NULL,
	rid INT NOT NULL,
       cid INT NOT NULL,
	quota INT NOT NULL,
	s_time TIME NOT NULL,
	e_time TIME NOT NULL,
       week_day INT NOT NULL,
	PRIMARY KEY(module_code, rid, cid),
	FOREIGN KEY (module_code) REFERENCES Courses
           ON UPDATE CASCADE 
           ON DELETE CASCADE, /* weak entity to Courses*/
	FOREIGN KEY (rid) REFERENCES Rounds 
           ON DELETE CASCADE, /* weak entity to Rounds*/
        CHECK (week_day >= 1 and week_day <= 7),
        CHECK (e_time > s_time)
);


DROP TABLE IF EXISTS bids CASCADE;
CREATE TABLE bids(
	uname VARCHAR(30) NOT NULL,
	bid_point INT NOT NULL,
	module_code VARCHAR(30) NOT NULL,
	rid INT NOT NULL,
        cid INT NOT NULL,
	is_successful BOOL NOT NULL,
	PRIMARY KEY(uname, module_code, rid, cid),
        FOREIGN KEY(uname) REFERENCES Student(uname)
           ON UPDATE CASCADE
           ON DELETE CASCADE,
	FOREIGN KEY(module_code, rid, cid) REFERENCES has_class(module_code, rid, cid)
           ON UPDATE CASCADE
           ON DELETE CASCADE,
        CHECK (bid > 0)
);


DROP TABLE IF EXISTS Taken CASCADE;
CREATE TABLE Taken(
	uname varchar(30) REFERENCES Student,
	module_code varchar(10) REFERENCES Courses,
	PRIMARY KEY(uname, module_code)
)