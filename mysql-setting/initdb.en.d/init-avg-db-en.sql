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
 A Tale of Yatsuka Village (English version of 八束村奇譚)

 scenes
   00001 Village entrance        00007 Main Hall
   00002 Inn, guest room         00008 Sayo's house (abandoned)
   00003 Village crossroads      00009 Swamp shore
   00004 Village head's house    00010 Underground shrine
   00005 Old storehouse          00011 TRUE END
   00006 Yatsuka Shrine grounds  00012 BAD END

 flags (bit values)
      1  the landlady (Shizu) has withdrawn
      2  Misa's notebook
      4  heard about Misa from Shizu
      8  heard about Sayo's house from Old Otatsu
     16  Genzo went back into his house
     32  storehouse key
     64  old photo
    128  Sayo's comb
    256  charm
    512  Main Hall key
   1024  Genzo's diary (= night has fallen)
   2048  found the stone steps under the Main Hall floor
   4096  found the underground tunnel
   8192  opened the storehouse padlock

 item target ids (common, SCENE_ID = 00000)
   I01 Misa's notebook  I02 storehouse key  I03 old photo  I04 Sayo's comb
   I05 charm            I06 Main Hall key   I07 Genzo's diary
   Z99 end conversation (person mode only)

 translation notes
   - Keep the control characters ^ @ ; exactly as in the Japanese version.
     Never use them in the text itself (no semicolons in English sentences).
   - Apostrophes are escaped as '' (two single quotes).
*/

/*
 insert data
*/

INSERT INTO `COMMAND` (`SCENE_ID`, `COMMAND_ID`, `TEXT`, `MODE`, `SORT_KEY`)
VALUES
('00000','CHK','Check',0,0),
('00000','TLK','Talk',1,1),
('00000','USE','Use',0,1),
('00000','MOV','Go',2,10),
('00000','SHW','Show',1,2),
('00000','CNF','System',2,20);

INSERT INTO `MESSAGE` (`SCENE_ID`, `COMMAND_ID`, `TARGET_ID`, `FLAG`, `SET_FLAG`, `UNSET_FLAG`, `EVENT`, `TEXT`)
VALUES
-- common: initial / default messages of commands
('00000','CHK','000',0,0,0,NULL,'Check what?'),
('00000','USE','000',0,0,0,NULL,'Use what?'),
('00000','TLK','000',0,0,0,NULL,'Talk about what?'),
('00000','SHW','000',0,0,0,NULL,'Show what?'),
('00000','MOV','000',0,0,0,NULL,'Go where?'),
('00000','CNF','000',0,0,0,NULL,'What will you do?'),
('00000','CHK','999',0,0,0,NULL,'There is nothing to check.'),
('00000','USE','999',0,0,0,NULL,'You have nothing you can use.'),
('00000','TLK','999',0,0,0,NULL,'There is no one to talk to.'),
('00000','SHW','999',0,0,0,NULL,'You have nothing to show.'),
('00000','MOV','999',0,0,0,NULL,'There is nowhere to go.'),
('00000','CNF','SAV',0,0,0,'showSaveDialog','^'),
('00000','CNF','LOA',0,0,0,'showLoadDialog','^'),
('00000','CNF','TTL',0,0,0,'backToTitle','Returning to the title screen.@(Any unsaved progress will be lost.);^'),
('00000','TLK','Z99',0,0,0,'hidePerson','You end the conversation.^'),
-- common: items
('00000','CHK','I01',0,0,0,NULL,'Your sister Misa''s notebook.;"The Yatsuka Festival comes once every thirty-three years. On the night of the last festival, a village girl named Sayo vanished."@"Old Otatsu at the shrine knows something.";The last page is scrawled in a shaky hand...@"The village head has noticed me. The proof is in the storehouse."'),
('00000','CHK','I02',0,0,0,NULL,'An old iron key.@It seems to open the storehouse at the village head''s house.'),
('00000','CHK','I03',0,0,0,NULL,'A faded photograph. A girl in festival dress stands beside a young man.@On the back: "Yatsuka Festival, thirty-three years ago. Sayo and Genzo."'),
('00000','CHK','I04',0,0,0,NULL,'A black lacquered comb.@A single long black hair is tangled in it...'),
('00000','CHK','I05',0,0,0,NULL,'The charm Old Otatsu gave you.@It feels faintly warm in your hand.'),
('00000','CHK','I06',0,0,0,NULL,'A key with a tag that reads "Yatsuka Shrine, Main Hall".'),
('00000','CHK','I07',0,0,0,NULL,'Genzo''s diary.;"That night thirty-three years ago, Sayo rejected me. When I came to my senses, she was no longer moving.";"I called it Lady Yatsuka''s curse. Everyone in the village believed it.";"That scholar woman has dug too deep. This year''s bride will be her."'),
('00000','USE','I01',0,0,0,NULL,'You can''t use that here.'),
('00000','USE','I02',0,0,0,NULL,'You can''t use that here.'),
('00000','USE','I03',0,0,0,NULL,'You can''t use that here.'),
('00000','USE','I04',0,0,0,NULL,'You can''t use that here.'),
('00000','USE','I05',0,0,0,NULL,'You clutch the charm tightly.@You feel a little calmer.'),
('00000','USE','I06',0,0,0,NULL,'You can''t use that here.'),
('00000','USE','I07',0,0,0,NULL,'You can''t use that here.'),
('00000','SHW','I01',0,0,0,NULL,'They shake their head without a word.'),
('00000','SHW','I02',0,0,0,NULL,'They shake their head without a word.'),
('00000','SHW','I03',0,0,0,NULL,'They shake their head without a word.'),
('00000','SHW','I04',0,0,0,NULL,'They shake their head without a word.'),
('00000','SHW','I05',0,0,0,NULL,'They shake their head without a word.'),
('00000','SHW','I06',0,0,0,NULL,'They shake their head without a word.'),
('00000','SHW','I07',0,0,0,NULL,'They shake their head without a word.'),
-- 00001 Village entrance
('00001','000','000',0,0,0,'getInitialCommands','^A mountain road at dusk. The last bus pulls away.@So this is Yatsuka Village... the village where your sister vanished.'),
('00001','000','000',1024,0,0,'getInitialCommands','^The village entrance at night.@Festival music and the beat of drums echo in the distance.'),
('00001','CHK','001',0,0,0,NULL,'"Yatsuka Village" is carved into a moss-covered stone monument.@At its base lies an offering: a bundle of black hair...'),
('00001','CHK','002',0,0,0,NULL,'According to the timetable, the next bus leaves at six tomorrow morning.@There is no way out of this village tonight.'),
-- 00002 Inn, guest room
('00002','000','000',0,0,0,'showShizu','^The inn, "Yatsukaya".@The landlady greets you. "...Welcome. Thank you for coming all this way."'),
('00002','000','000',1,0,0,'getInitialCommands','^The guest room of the inn.@It smells of old tatami mats.'),
('00002','TLK','001',0,0,0,NULL,'"...I know of no such guest."@The landlady looks away.'),
('00002','TLK','001',4,0,0,NULL,'"Three days ago, Misa was taken away by men from the village head''s house.@There was nothing I could do..."'),
('00002','TLK','002',0,0,0,NULL,'"It is the great festival, held once every thirty-three years.@Please, do not go outside tonight, whatever happens."'),
('00002','TLK','003',2,0,0,NULL,'"Sayo...! Where did you hear that name...?"@The landlady turns pale.'),
('00002','TLK','003',4,0,0,NULL,'"Sayo was my childhood friend.@She disappeared on the night of the festival, thirty-three years ago..."'),
('00002','TLK','Z99',0,1,0,'hidePerson','"Your room is this way. Please make yourself comfortable.";The landlady withdraws.^'),
('00002','TLK','Z99',1,0,0,'hidePerson','The landlady bows and withdraws.^'),
('00002','SHW','I01',2,4,0,NULL,'"This is Misa''s...!";In a trembling voice, the landlady confesses.@"Three days ago, Misa was taken away by men from the village head''s house.";"Old Otatsu at the shrine must know something."'),
('00002','SHW','I03',0,0,0,NULL,'"That''s Sayo... and beside her is the village head, when he was young."@The landlady looks away from the photograph.'),
('00002','SHW','I07',0,0,0,NULL,'"How terrible... It wasn''t a curse. It was the village head who..."@The landlady breaks down in tears.'),
('00002','CHK','001',0,2,0,NULL,'Stuffed at the back of the closet is a notebook you recognize.@It''s your sister Misa''s notebook!'),
('00002','CHK','001',2,0,0,NULL,'Only futons are stored here.'),
('00002','CHK','002',0,0,0,NULL,'Halfway up the mountain, you can see a shrine gate.@Beyond it spreads a pitch-black swamp.'),
('00002','CHK','003',0,0,0,NULL,'The hanging scroll depicts a long-haired goddess.@It reads "Lady Yatsuka".'),
('00002','CHK','004',0,0,0,'showShizu','You ring the bell, and the landlady comes.^'),
-- 00003 Village crossroads
('00003','000','000',0,0,0,'getInitialCommands','^The village crossroads. Old houses line the street, wrapped in fog.@You feel someone watching you through a gap in the shutters.'),
('00003','000','000',1024,0,0,'getInitialCommands','^The crossroads at night.@Villagers carrying torches walk silently toward the shrine.'),
('00003','CHK','001',0,0,0,NULL,'Every house has its storm shutters closed.@From inside comes a low chanting, like a prayer for the dead...'),
('00003','CHK','001',1024,0,0,NULL,'The houses are empty.@Everyone seems to have gone to the festival.'),
('00003','CHK','002',0,0,0,NULL,'"The Great Yatsuka Festival of the Thirty-Third Year. To be held tonight."@"On the night of the festival, outsiders must not set foot outside."'),
('00003','CHK','003',0,0,0,NULL,'A signpost.@"Right: Yatsuka Shrine" "Left: Swamp"... A rope is strung across the path to the swamp.'),
('00003','MOV','006',0,0,0,NULL,'Villagers with torches are guarding the path to the swamp.@You can''t get any closer from here...'),
-- 00004 Village head's house
('00004','000','000',0,0,0,'showGenzo','^The village head''s house. A sharp-eyed old man stands before the gate.@"I am Genzo Yatsuka, the village head. What does an outsider want here?"'),
('00004','000','000',16,0,0,'getInitialCommands','^The village head''s house.@The gate is firmly shut.'),
('00004','000','000',1024,0,0,'getInitialCommands','^The house at night. There is no sign of anyone.@Everyone seems to have left for the festival.'),
('00004','TLK','001',0,0,0,NULL,'"Never heard of her."@Genzo''s voice is cold.'),
('00004','TLK','002',0,0,0,NULL,'"We offer a bride to Lady Yatsuka and pray for the village''s peace.@It is no concern of outsiders."'),
('00004','TLK','003',0,0,0,NULL,'"...Never speak that name again."@For an instant, fear flickers in Genzo''s eyes.'),
('00004','TLK','Z99',0,16,0,'hidePerson','"Stay in the inn until the festival is over.";Genzo disappears behind the gate.^'),
('00004','SHW','I01',0,16,0,'hidePerson','"...Where did you get that?"@The color drains from Genzo''s face.;"Get out!";Genzo disappears behind the gate.^'),
('00004','SHW','I03',0,0,0,NULL,'"...!"@Genzo tries to snatch the photograph.'),
('00004','CHK','001',0,0,0,NULL,'The gate is firmly shut.'),
('00004','CHK','002',0,0,0,NULL,'Following the wall around to the back, you see an old storehouse.@A heavy padlock hangs on its door.'),
('00004','CHK','002',8192,0,0,NULL,'The door of the storehouse out back is slightly open.'),
('00004','USE','I02',32,8192,0,NULL,'You put the key into the padlock of the storehouse out back. It falls open with a heavy clunk.'),
('00004','USE','I02',8192,0,0,NULL,'The storehouse padlock is already open.'),
-- 00005 Old storehouse
('00005','000','000',0,0,0,'getInitialCommands','^The storehouse is dim and smells of mold.@Shelves and wooden chests line the walls.'),
('00005','CHK','001',0,1024,0,NULL,'At the bottom of a chest, you find an old diary.@The cover reads "Genzo Yatsuka"...;Suddenly you realize that night has fallen outside.@In the distance, festival music begins to play...!'),
('00005','CHK','001',1024,0,0,NULL,'The chest is empty now.'),
('00005','CHK','002',0,512,0,NULL,'At the back of a shelf is a key with a tag.@"Yatsuka Shrine, Main Hall"... You got the Main Hall key.'),
('00005','CHK','002',512,0,0,NULL,'Nothing but old tools on the shelves.'),
('00005','CHK','003',0,0,0,NULL,'A white robe hangs on a kimono rack.@A bridal robe...? The name "Misa" is embroidered on the sleeve...'),
-- 00006 Yatsuka Shrine grounds
('00006','000','000',0,0,0,'getInitialCommands','^The grounds of Yatsuka Shrine.@Bundles of black hair sway from a rope strung across the shrine gate.'),
('00006','000','000',1024,0,0,'getInitialCommands','^The shrine grounds at night. Bonfires are burning.@A cold wind blows from deep inside the Main Hall.'),
('00006','CHK','001',0,0,0,NULL,'Seven bundles of black hair hang from the rope...@Only the place for an eighth is empty.'),
('00006','CHK','001',1024,0,0,NULL,'In the eighth place, a fresh bundle of black hair has been tied.@...It''s your sister''s hair.'),
('00006','CHK','002',0,0,0,NULL,'The door of the Main Hall is padlocked.'),
('00006','CHK','002',512,0,0,NULL,'The Main Hall key looks like it will fit.@But too many eyes are watching in daylight... Better wait for night.'),
('00006','CHK','002',1536,0,0,NULL,'No one is watching now.@You can get into the Main Hall.'),
('00006','CHK','003',0,0,0,'showOtatsu','You knock on the door of the shrine office, and a stooped old woman peers out.@"...Well now. You look just like Misa, you do."^'),
('00006','CHK','003',1024,0,0,'showOtatsu','"So you came..."@Old Otatsu was waiting for you.^'),
('00006','TLK','001',0,0,0,NULL,'"The goddess who dwells in the swamp. Every thirty-three years she takes a bride, and a lock of each bride''s hair is tied here."@"...Or so the village folk believe."'),
('00006','TLK','002',0,0,0,NULL,'"That girl was digging into the past.@...Genzo had his eye on her."'),
('00006','TLK','002',1024,0,0,NULL,'"Tonight that girl will be taken to the swamp as the bride.@Hurry...!"'),
('00006','TLK','003',0,0,0,NULL,'"Sayo... was my granddaughter.";"On the festival night thirty-three years ago, Sayo vanished.@Folk say it was the curse... but I never believed it."'),
('00006','TLK','Z99',0,0,0,'hidePerson','"Take care now."@Old Otatsu goes back into the shrine office.^'),
('00006','SHW','I01',2,8,0,NULL,'"...Sayo''s name is written here.";"Go and see Sayo''s house. The abandoned one at the edge of the village."@"If her comb is still there, bring it to me."'),
('00006','SHW','I01',8,0,0,NULL,'"Go and see Sayo''s house, at the edge of the village."'),
('00006','SHW','I03',0,0,0,NULL,'"That''s Sayo and Genzo.@...Back then, Genzo wouldn''t leave Sayo alone."'),
('00006','SHW','I04',128,256,0,NULL,'"Oh... Sayo''s comb..."@Old Otatsu holds the comb to her chest.;"Take this with you. Sayo will protect you."@You received a charm.;"If you go near the swamp, don''t you ever let go of it."@"The Main Hall key... Genzo took it from me."'),
('00006','SHW','I04',256,0,0,NULL,'"Don''t you ever let go of that charm."'),
('00006','SHW','I06',0,0,0,NULL,'"That''s the key to the Main Hall!@Come nightfall, there''ll be no one watching."'),
('00006','SHW','I07',0,0,0,NULL,'"So it was Genzo... who did that to Sayo...";"They say an old path runs from the back of the Main Hall down to the swamp."@"Take that diary and show it to the village folk."'),
-- 00007 Main Hall
('00007','000','000',0,0,0,'getInitialCommands','^Inside the Main Hall.@A statue of Lady Yatsuka is enshrined behind the altar.'),
('00007','CHK','001',0,2048,0,NULL,'A floorboard under the altar is slightly raised.;When you pull the board away, stone steps leading underground appear!'),
('00007','CHK','001',2048,0,0,NULL,'Beneath the altar, stone steps lead underground.'),
('00007','CHK','002',0,0,0,NULL,'A statue of a long-haired goddess.@For some reason, her eyes look wet...'),
('00007','CHK','003',0,0,0,NULL,'An old scroll.@"When the bride has been sent to the swamp, her hair shall be tied to the Yatsuka rope."'),
-- 00008 Sayo's house (abandoned)
('00008','000','000',0,0,0,'showKenta','^An abandoned house at the edge of the village. Sayo''s house.;A boy jumps out from the shadows.@"Wh-who are you?! One of the village head''s men?!"'),
('00008','000','000',32,0,0,'getInitialCommands','^A ruined, abandoned house.@The paper screens are torn, and dust lies thick on the floor.'),
('00008','TLK','001',0,0,0,NULL,'"You''re Misa''s... family? Really?"@The boy says his name is Kenta.'),
('00008','TLK','002',0,0,0,NULL,'"The village head is scary.@Misa was looking into his storehouse, too."'),
('00008','TLK','Z99',0,0,0,'hidePerson','"...I still don''t know if I can trust you."@Kenta hides in the shadows again.^'),
('00008','SHW','I01',2,32,0,'hidePerson','"That''s Misa''s notebook! You really are her family.";"She asked me to keep this. She said it''s the key to the village head''s storehouse."@You received the storehouse key!;"I-I have to go now... Please save Misa!"@Kenta runs off.^'),
('00008','CHK','001',0,64,0,NULL,'On the dusty family altar, a photograph lies face down.@You got an old photograph.'),
('00008','CHK','001',64,0,0,NULL,'A small memorial tablet.@It reads "Sayo".'),
('00008','CHK','002',0,128,0,NULL,'At the back of a dresser drawer is a black lacquered comb.@You got Sayo''s comb.'),
('00008','CHK','002',128,0,0,NULL,'The drawer is empty.'),
('00008','CHK','003',0,0,0,NULL,'For an instant, you think you see a long-haired girl reflected in the clouded mirror...'),
-- 00009 Swamp shore
('00009','000','000',0,0,0,'gotoBadEnd','You come out of the tunnel onto the shore of a fog-covered swamp.;The surface of the water ripples.@...come... come to me...;Countless white hands seize your ankles—^'),
('00009','000','000',256,0,0,'showGenzo','You come out of the tunnel onto the shore of the swamp.;The water stirs, but when the charm grows hot, it falls still.;On the shore stand villagers holding torches.@Your sister Misa, dressed in white, is being dragged toward the swamp!;"Stop!"@The man who turns around is Genzo.^'),
('00009','TLK','001',0,0,0,NULL,'"Misa!"@Misa is gagged and cannot speak.'),
('00009','TLK','002',0,0,0,NULL,'"Outsider... I''ll offer you to Lady Yatsuka as well."'),
('00009','TLK','003',0,0,0,NULL,'"Silence! Sayo was taken by Lady Yatsuka!"'),
('00009','TLK','Z99',0,0,0,NULL,'You can''t back down now!'),
('00009','SHW','I01',0,0,0,NULL,'"Who would believe a woman''s scribblings?"'),
('00009','SHW','I03',0,0,0,NULL,'"..."@Genzo''s hand trembles slightly.'),
('00009','SHW','I04',0,0,0,NULL,'"Sayo''s... comb..."@Genzo backs away.'),
('00009','SHW','I07',0,0,0,'gotoTrueEnd','You hold up the diary and read it aloud before the villagers.;The villagers begin to murmur.@"The village head did that to Sayo...?" "So it wasn''t a curse...?";"No! I... I...!"@Genzo staggers, and his foot slips at the edge of the swamp.;White hands reach up from the water and drag Genzo under.@"Sayo... forgive me...";...The swamp falls silent once more.^'),
-- 00010 Underground shrine
('00010','000','000',0,0,0,'getInitialCommands','^At the bottom of the stone steps is a damp cave.@A small shrine stands there, lit by candles.'),
('00010','CHK','001',0,0,0,NULL,'Deep inside the shrine lies a skeleton.;Beside it, a rotted bridal robe...@It is Sayo, who vanished thirty-three years ago. It was no curse.'),
('00010','CHK','002',0,4096,0,NULL,'A tunnel leads further in.@A foul wind... the smell of the swamp.;From far away come the sound of drums and voices.@The festival is just ahead!'),
('00010','CHK','002',4096,0,0,NULL,'The tunnel leads to the swamp.'),
('00010','CHK','003',0,0,0,NULL,'The walls are covered in marks, as if scratched by fingernails...'),
-- 00011 TRUE END
('00011','000','000',0,0,0,'showMisaEnding,clearGame,gotoEnding','^^Dawn. The bus stop at the village entrance.@Your sister Misa stands beside you.;"Thank you... for coming for me.";Old Otatsu laid Sayo''s bones to rest with loving care.@They say the Yatsuka Festival was never held again after that year.;You board the first bus of the morning.@Looking back, you think you see a long-haired girl standing in the fog.;— A Tale of Yatsuka Village  THE END —;^'),
-- 00012 BAD END
('00012','000','000',0,0,0,'clearGame,retryFromCave','^You are dragged down to the bottom of the swamp...@Cold. Dark. You can''t... breathe...;...come... stay here... forever...;— BAD END —@Never go near the swamp without the charm...;^');

INSERT INTO `SCENE` (`SCENE_ID`, `FLAG`, `PATH`)
VALUES
('00001',0,'../scenes/00001.html'),
('00002',0,'../scenes/00002.html'),
('00003',0,'../scenes/00003.html'),
('00004',0,'../scenes/00004.html'),
('00005',0,'../scenes/00005.html'),
('00006',0,'../scenes/00006.html'),
('00007',0,'../scenes/00007.html'),
('00008',0,'../scenes/00008.html'),
('00009',0,'../scenes/00009.html'),
('00010',0,'../scenes/00010.html'),
('00011',0,'../scenes/00011.html'),
('00012',0,'../scenes/00012.html');

INSERT INTO `TARGET` (`SCENE_ID`, `COMMAND_ID`, `TARGET_ID`, `FORBIDDEN`, `FLAG`, `TEXT`, `DEST_SCENE_ID`)
VALUES
-- common: items
('00000','CHK','I01',0,2,'Misa''s notebook',NULL),
('00000','CHK','I02',0,32,'Storehouse key',NULL),
('00000','CHK','I03',0,64,'Old photo',NULL),
('00000','CHK','I04',0,128,'Sayo''s comb',NULL),
('00000','CHK','I05',0,256,'Charm',NULL),
('00000','CHK','I06',0,512,'Main Hall key',NULL),
('00000','CHK','I07',0,1024,'Genzo''s diary',NULL),
('00000','USE','I01',0,2,'Misa''s notebook',NULL),
('00000','USE','I02',0,32,'Storehouse key',NULL),
('00000','USE','I03',0,64,'Old photo',NULL),
('00000','USE','I04',0,128,'Sayo''s comb',NULL),
('00000','USE','I05',0,256,'Charm',NULL),
('00000','USE','I06',0,512,'Main Hall key',NULL),
('00000','USE','I07',0,1024,'Genzo''s diary',NULL),
('00000','SHW','I01',0,2,'Misa''s notebook',NULL),
('00000','SHW','I02',0,32,'Storehouse key',NULL),
('00000','SHW','I03',0,64,'Old photo',NULL),
('00000','SHW','I04',0,128,'Sayo''s comb',NULL),
('00000','SHW','I05',0,256,'Charm',NULL),
('00000','SHW','I06',0,512,'Main Hall key',NULL),
('00000','SHW','I07',0,1024,'Genzo''s diary',NULL),
('00000','TLK','Z99',0,0,'End conversation',NULL),
('00000','CNF','SAV',1,0,'Save',NULL),
('00000','CNF','LOA',1,0,'Load',NULL),
('00000','CNF','TTL',1,0,'Back to title',NULL),
-- 00001 Village entrance
('00001','CHK','001',0,0,'Stone monument',NULL),
('00001','CHK','002',0,0,'Bus stop',NULL),
('00001','MOV','001',0,0,'Into the village','00003'),
-- 00002 Inn, guest room
('00002','CHK','001',0,0,'Closet',NULL),
('00002','CHK','002',0,0,'Window',NULL),
('00002','CHK','003',0,0,'Hanging scroll',NULL),
('00002','CHK','004',0,0,'Bell',NULL),
('00002','TLK','001',0,0,'Misa',NULL),
('00002','TLK','002',0,0,'Yatsuka Festival',NULL),
('00002','TLK','003',0,2,'Sayo',NULL),
('00002','MOV','001',0,0,'Crossroads','00003'),
-- 00003 Village crossroads
('00003','CHK','001',0,0,'Houses',NULL),
('00003','CHK','002',0,0,'Notice',NULL),
('00003','CHK','003',0,0,'Signpost',NULL),
('00003','MOV','001',0,0,'Village entrance','00001'),
('00003','MOV','002',0,0,'Inn','00002'),
('00003','MOV','003',0,0,'Village head''s house','00004'),
('00003','MOV','004',0,0,'Yatsuka Shrine','00006'),
('00003','MOV','005',0,8,'Sayo''s house','00008'),
('00003','MOV','006',1,1024,'Swamp',NULL),
-- 00004 Village head's house
('00004','CHK','001',0,0,'Gate',NULL),
('00004','CHK','002',0,0,'Wall',NULL),
('00004','TLK','001',0,0,'Misa',NULL),
('00004','TLK','002',0,0,'Yatsuka Festival',NULL),
('00004','TLK','003',0,2,'Sayo',NULL),
('00004','MOV','001',0,0,'Crossroads','00003'),
('00004','MOV','002',0,8192,'Storehouse','00005'),
-- 00005 Old storehouse
('00005','CHK','001',0,0,'Wooden chest',NULL),
('00005','CHK','002',0,0,'Shelves',NULL),
('00005','CHK','003',0,0,'White robe',NULL),
('00005','MOV','001',0,0,'Front of the house','00004'),
-- 00006 Yatsuka Shrine grounds
('00006','CHK','001',0,0,'Bundles of hair',NULL),
('00006','CHK','002',0,0,'Main Hall',NULL),
('00006','CHK','003',0,0,'Shrine office',NULL),
('00006','TLK','001',0,0,'Lady Yatsuka',NULL),
('00006','TLK','002',0,0,'Misa',NULL),
('00006','TLK','003',0,2,'Sayo',NULL),
('00006','MOV','001',0,0,'Crossroads','00003'),
('00006','MOV','002',0,1536,'Main Hall','00007'),
-- 00007 Main Hall
('00007','CHK','001',0,0,'Altar',NULL),
('00007','CHK','002',0,0,'Goddess statue',NULL),
('00007','CHK','003',0,0,'Scroll',NULL),
('00007','MOV','001',0,0,'Shrine grounds','00006'),
('00007','MOV','002',0,2048,'Underground','00010'),
-- 00008 Sayo's house
('00008','CHK','001',0,0,'Family altar',NULL),
('00008','CHK','002',0,0,'Dresser',NULL),
('00008','CHK','003',0,0,'Mirror stand',NULL),
('00008','TLK','001',0,0,'Misa',NULL),
('00008','TLK','002',0,0,'Village head',NULL),
('00008','MOV','001',0,0,'Crossroads','00003'),
-- 00009 Swamp shore
('00009','TLK','001',0,0,'Misa',NULL),
('00009','TLK','002',0,0,'Genzo',NULL),
('00009','TLK','003',0,0,'Sayo',NULL),
-- 00010 Underground shrine
('00010','CHK','001',0,0,'Shrine',NULL),
('00010','CHK','002',0,0,'Tunnel',NULL),
('00010','CHK','003',0,0,'Wall',NULL),
('00010','MOV','001',0,0,'Main Hall','00007'),
('00010','MOV','002',0,4096,'End of the tunnel','00009');
