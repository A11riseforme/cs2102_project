DROP TABLE IF EXISTS Bid CASCADE;
DROP TABLE IF EXISTS Availability CASCADE;
DROP TABLE IF EXISTS Pet CASCADE;
DROP TABLE IF EXISTS Trains CASCADE;
DROP TABLE IF EXISTS Recommends CASCADE;
DROP TABLE IF EXISTS Work CASCADE;
DROP TABLE IF EXISTS Located CASCADE;
DROP TABLE IF EXISTS Offices CASCADE;
DROP TABLE IF EXISTS PetOwner CASCADE;
DROP TABLE IF EXISTS CareTaker CASCADE;
DROP TABLE IF EXISTS Customers CASCADE;
DROP TABLE IF EXISTS Workers CASCADE;
DROP TABLE IF EXISTS Users CASCADE;

CREATE TABLE Users (
  username     varchar(50) PRIMARY KEY,
  password     varchar(256) NOT NULL,
  isAdmin       integer NOT NULL 
);

CREATE TABLE Admins (
  username varchar(50) PRIMARY KEY REFERENCES Users(username)
)

CREATE TABLE Students (
  username varchar(50) PRIMARY KEY REFERENCES Users(username),
  matricID varchar(50) REFERENCES StudentInfo(matricID) UNIQUE
)

CREATE TABLE StudentInfo (
  matricID varchar(50) PRIMARY KEY ,
  cap numeric(2) NOT NULL,
  bidPoints integer NOT NULL,
  faculty varchar(50) NOT NULL,
  CHECK cap > 0
)

CREATE TABLE StudentModuleTaken(
  username varchar(50) REFERENCES Students(username),
  moduleCode varchar(50),
  PRIMARY KEY (username, moduleCode),
)

CREATE TABLE Faculty(
  name varchar(50) PRIMARY KEY,
) 

CREATE TABLE Creates (
  username varchar(50) PRIMARY KEY REFERENCES Admins(username),
  moduleCode varchar(50) 
  quota varchar(50) 
  prerequisite  varchar(50)[],
  PRIMARY KEY (modulecode, quota, prerequisite) REFERENCES Courses(modulecode, quota, prerequisite),
)

CREATE TABLE Courses (
  moduleCode varchar(50) PRIMARY KEY, 
  quota varchar(50) 
  prerequisite  varchar(50)[],
  faculty varchar(50) REFERENCES Faculty(name),
  mc integer,
  dayTimeBits integer,
  (quota, prerequisite) REFERENCES Creates(quota, prerequisite),
);

CREATE TABLE CourseAndRound (
  moduleCode varchar(50) REFERENCES Courses(moduleCode) ON DELETE CASCADE, 
  roundNumber Integer REFERENCES Rounds(roundNumber), 
  quota varchar(50)
  PRIMARY KEY (moduleCode, roundNumber),
)

CREATE TABLE Rounds (
  roundNumber  integer PRIMARY KEY,
  startTime DateTime,
  endTime DateTime,
);