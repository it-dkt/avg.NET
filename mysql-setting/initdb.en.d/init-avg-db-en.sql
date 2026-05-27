SET NAMES 'utf8mb4';

CREATE USER 'avguser'@'%' IDENTIFIED BY 'avgpass';
CREATE DATABASE avg_db CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
GRANT SELECT ON avg_db.* TO 'avguser'@'%';

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

USE avg_db;

/*
 create tables
*/
DROP TABLE IF EXISTS `COMMAND`;
CREATE TABLE `COMMAND` (
  `SCENE_ID` char(5) NOT NULL,
  `COMMAND_ID` char(3) NOT NULL,
  `TEXT` varchar(256) NOT NULL,
  `MODE` int NOT NULL,
  `SORT_KEY` int NOT NULL,
  PRIMARY KEY (`SCENE_ID`,`COMMAND_ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `MESSAGE`;
CREATE TABLE `MESSAGE` (
  `TEXT` varchar(512) NOT NULL,
  `SCENE_ID` char(5) NOT NULL,
  `COMMAND_ID` char(3) NOT NULL,
  `TARGET_ID` char(3) NOT NULL,
  `FLAG` bigint(20) unsigned NOT NULL DEFAULT '0',
  `SET_FLAG` bigint(20) unsigned NOT NULL DEFAULT '0',
  `UNSET_FLAG` bigint(20) unsigned NOT NULL DEFAULT '0',
  `EVENT` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`SCENE_ID`,`COMMAND_ID`,`TARGET_ID`,`FLAG`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `SCENE`;
CREATE TABLE `SCENE` (
  `SCENE_ID` char(5) NOT NULL,
  `FLAG` bigint(20) unsigned NOT NULL DEFAULT '0',
  `PATH` varchar(256) NOT NULL,
  PRIMARY KEY (`SCENE_ID`,`FLAG`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `TARGET`;
CREATE TABLE `TARGET` (
  `SCENE_ID` char(5) NOT NULL,
  `COMMAND_ID` char(3) NOT NULL,
  `TARGET_ID` char(3) NOT NULL,
  `FORBIDDEN` bit NOT NULL,
  `FLAG` bigint(20) unsigned NOT NULL DEFAULT '0',
  `TEXT` varchar(256) NOT NULL,
  `DEST_SCENE_ID` char(5) DEFAULT NULL,
  PRIMARY KEY (`SCENE_ID`,`COMMAND_ID`,`TARGET_ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

/*
 insert data
*/

INSERT INTO `COMMAND` (`SCENE_ID`, `COMMAND_ID`, `TEXT`, `MODE`, `SORT_KEY`)
VALUES
('00000','CHK','check',0,0),
('00000','TLK','talk',1,1),
('00000','USE','use',0,1),
('00000','MOV','go',2,10),
('00000','SHW','show',1,2);

INSERT INTO `MESSAGE` (`SCENE_ID`, `COMMAND_ID`, `TARGET_ID`, `FLAG`, `SET_FLAG`, `UNSET_FLAG`, `EVENT`, `TEXT`)
VALUES
('00000','CHK','000',0,0,0,NULL,'Check what?'),
('00000','USE','000',0,0,0,NULL,'Use what?'),
('00000','MOV','000',0,0,0,NULL,'Go where?'),
('00000','TLK','000',0,0,0,NULL,'Talk about what?'),
('00000','SHW','000',0,0,0,NULL,'Show what?'),
('00000','USE','001',0,0,0,NULL,'You can''t use it here.'),
('00000','USE','002',0,0,0,NULL,'You can''t use it here.'),
('00000','CHK','999',0,0,0,NULL,'There is nothing to check.'),
('00000','USE','999',0,0,0,NULL,'You have nothing to use.'),
('00000','TLK','999',0,0,0,NULL,'There is nobody to talk.'),
('00000','MOV','999',0,0,0,NULL,'There is no place to go.'),
('00000','SHW','999',0,0,0,NULL,'You have nothing to show.'),
('00001','000','000',0,0,0,'getInitialCommands','^There is a weird house.'),
('00001','CHK','001',0,0,0,NULL,'The door is locked.'),
('00001','CHK','002',0,1,0,NULL,'There is a key.@You''ve got a key!'),
('00001','USE','001',1,2,0,NULL,'You opened the door.'),
('00001','CHK','002',1,0,0,NULL,'There is nothing special.'),
('00001','CHK','001',2,0,0,NULL,'You unlocked the door, so you can go in the house.'),
('00001','USE','001',2,0,0,NULL,'The door of the house was already unlocked.'),
('00001','MOV','002',0,128,64,NULL,'You were going home.@But you fogot the way to home.'),
('00001','CHK','003',0,256,128,NULL,'You''ve found a map in your pocket.@You can go home now!'),
('00002','000','000',0,0,0,'getInitialCommands','^Here is a living room'),
('00002','CHK','001',0,4,0,'showPerson','^A man has come.@''What are you doing here?'''),
('00002','TLK','001',0,0,0,NULL,'''This is my house.'''),
('00002','TLK','002',0,0,0,NULL,'''I live in here.'''),
('00002','000','000',4,0,0,'showPerson','^Living room.@There is the man.'),
('00002','SHW','001',0,0,0,NULL,'''I don''t know.'''),
('00002','SHW','002',0,16,4,'hidePerson','''This is my book.'';You gave back the book to tha man.@''Thank you'';''There is something nice under the sofa. I give you that.''@^The man has gone.'),
('00002','CHK','001',16,0,0,NULL,'There is nothing special'),
('00002','CHK','002',0,96,0,NULL,'There is a treasure under the sofa.@You''ve got a treasure!'),
('00002','CHK','002',32,0,0,NULL,'There is nothing any more.'),
('00003','000','000',0,0,0,'getInitialCommands','^Here is a bedroom.'),
('00003','CHK','001',0,0,0,NULL,'You checked out the pillow. But there was nothing special.'),
('00003','CHK','002',0,0,0,NULL,'You checked out the bed.  But there was nothing special.'),
('00003','CHK','003',0,8,0,NULL,'There is a book in the fireplace.@You''ve got a book!'),
('00003','CHK','003',8,0,0,NULL,'There is nothing no more.'),
('00004','000','000',0,0,0,'clearGame','^You went home with a treasure.@--The End--');

INSERT INTO `SCENE` (`SCENE_ID`, `FLAG`, `PATH`)
VALUES
('00001',0,'../scenes/00001.html'),
('00002',0,'../scenes/00002.html'),
('00003',0,'../scenes/00003.html'),
('00004',0,'../scenes/00004.html');

INSERT INTO `TARGET` (`SCENE_ID`, `COMMAND_ID`, `TARGET_ID`, `FORBIDDEN`, `FLAG`, `TEXT`, `DEST_SCENE_ID`)
VALUES
('00000','SHW','001',0,1,'key',NULL),
('00000','SHW','002',0,8,'book',NULL),
('00000','USE','001',0,1,'key',NULL),
('00000','USE','002',0,8,'book',NULL),
('00001','CHK','001',0,0,'house',NULL),
('00001','CHK','002',0,0,'around there',NULL),
('00001','CHK','003',0,128,'pocket',NULL),
('00001','MOV','001',0,2,'house','00002'),
('00001','MOV','002',1,64,'home',NULL),
('00001','MOV','003',0,256,'home','00004'),
('00002','CHK','001',0,0,'lamp',NULL),
('00002','CHK','002',0,16,'sofa',NULL),
('00002','MOV','001',0,0,'out','00001'),
('00002','MOV','002',0,0,'bedroom','00003'),
('00002','TLK','001',0,0,'house',NULL),
('00002','TLK','002',0,0,'man',NULL),
('00003','CHK','001',0,0,'pillow',NULL),
('00003','CHK','002',0,0,'bed',NULL),
('00003','CHK','003',0,0,'fireplace',NULL),
('00003','MOV','001',0,0,'living room','00002');

