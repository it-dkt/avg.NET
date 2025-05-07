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
  `SORT_KEY` int(11) NOT NULL,
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
  `FLAG` bigint(20) unsigned NOT NULL DEFAULT '0',
  `TEXT` varchar(256) NOT NULL,
  `DEST_SCENE_ID` char(5) DEFAULT NULL,
  PRIMARY KEY (`SCENE_ID`,`COMMAND_ID`,`TARGET_ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

/*
 insert data
*/

INSERT INTO `COMMAND` VALUES
('00000', 'CHK', '調べる', 0),
('00000', 'TKT', '話す', 1),
('00000', 'USE', '使う', 1),
('00000', 'GOT', '行く', 10),
('00000', 'TKS', '見せる', 2);

INSERT INTO `MESSAGE` VALUES
('^不気味な洋館があります。', '00001', '000', '000', 0, 0, 0, 'getInitialCommands'),
('何を調べますか？', '00000', 'CHK', '000', 0, 0, 0, NULL),
('鍵が閉まっているようです。', '00001', 'CHK', '001', 0, 0, 0, NULL),
('鍵が落ちています。@あなたは、鍵を手に入れました！', '00001', 'CHK', '002', 0, 1, 0, NULL),
('洋館の鍵を開けました。', '00001', 'USE', '001', 1, 2, 0, NULL),
('何を使いますか？', '00000', 'USE', '000', 0, 0, 0, NULL),
('どこに行きますか？', '00000', 'GOT', '000', 0, 0, 0, NULL),
('^洋館の居間です。', '00002', '000', '000', 0, 0, 0, 'getInitialCommands'),
('特に何もないようです。', '00001', 'CHK', '002', 1, 0, 0, NULL),
('鍵を開けたので、中に入ることができます。', '00001', 'CHK', '001', 2, 0, 0, NULL),
('^男が来ました。@「ここで何をしている？」', '00002', 'CHK', '001', 0, 4, 0, 'showPerson'),
('何について話しますか？', '00000', 'TKT', '000', 0, 0, 0, NULL),
('「ここは、私の家だ。」', '00002', 'TKT', '001', 0, 0, 0, NULL),
('「私は、ここに住んでいるのだ。」', '00002', 'TKT', '002', 0, 0, 0, NULL),
('もう洋館の鍵は開いています。', '00001', 'USE', '001', 2, 0, 0, NULL),
('^寝室です。', '00003', '000', '000', 0, 0, 0, 'getInitialCommands'),
('^居間です。@男がいます。', '00002', '000', '000', 4, 0, 0, 'showPerson'),
('枕の下を調べましたが、特に何もないようです。', '00003', 'CHK', '001', 0, 0, 0, NULL),
('ベッドの下を調べましたが、何もないようです。', '00003', 'CHK', '002', 0, 0, 0, NULL),
('暖炉の中に、本があります。@あなたは、本を手に入れました！', '00003', 'CHK', '003', 0, 8, 0, NULL),
('何を見せますか？', '00000', 'TKS', '000', 0, 0, 0, NULL),
('ここでは使えません。', '00000', 'USE', '001', 0, 0, 0, NULL),
('ここでは使えません。', '00000', 'USE', '002', 0, 0, 0, NULL),
('もう何もないようです。', '00003', 'CHK', '003', 8, 0, 0, NULL),
('「私は、わからない。」', '00002', 'TKS', '001', 0, 0, 0, NULL),
('「それは、私の本だ。」;あなたは、本を男に返しました。@「ありがとう。」;「ソファの下にいいものがある。お返しにそれをあげよう。」@^男は行ってしまいました。', '00002', 'TKS', '002', 0, 16, 4, 'hidePerson'),
('特に何もないようです。', '00002', 'CHK', '001', 16, 0, 0, NULL),
('ソファの下に、宝物があります。@あなたは、宝物を手に入れました！', '00002', 'CHK', '002', 0, 96, 0, NULL),
('あなたは家に帰ろうとしましたが、@家までの道を忘れてしまいました。', '00001', 'GOT', 'F01', 0, 128, 64, NULL),
('もう何もないようです。', '00002', 'CHK', '002', 32, 0, 0, NULL),
('^あなたは宝物を手に入れたので、家に帰りました。@--おわり--', '00004', '000', '000', 0, 0, 0, 'clearGame'),
('ポケットの中に、家までの地図がありました。@これで家に帰ることができます！', '00001', 'CHK', '003', 0, 256, 128, NULL),
('調べるものがありません。', '00000', 'CHK', '999', 0, 0, 0, NULL),
('使うものがありません。', '00000', 'USE', '999', 0, 0, 0, NULL),
('話す相手が誰もいません。', '00000', 'TKT', '999', 0, 0, 0, NULL),
('行くところがありません。', '00000', 'GOT', '999', 0, 0, 0, NULL),
('見せるものを何も持っていません。。', '00000', 'TKS', '999', 0, 0, 0, NULL);

INSERT INTO `SCENE` VALUES
('00001', 0, '../scenes/00001.html'),
('00002', 0, '../scenes/00002.html'),
('00003', 0, '../scenes/00003.html'),
('00004', 0, '../scenes/00004.html');

INSERT INTO `TARGET` VALUES
('00001', 'CHK', '001', 0, '洋館', NULL),
('00001', 'CHK', '002', 0, '辺り', NULL),
('00002', 'CHK', '002', 16, 'ソファ', NULL),
('00000', 'USE', '001', 1, '鍵', NULL),
('00001', 'GOT', '001', 2, '洋館の中', '00002'),
('00002', 'CHK', '001', 0, 'ランプ', NULL),
('00002', 'TKT', '001', 0, '洋館', NULL),
('00002', 'TKT', '002', 0, '男', NULL),
('00002', 'GOT', '001', 0, '洋館から出る', '00001'),
('00002', 'GOT', '002', 0, '寝室', '00003'),
('00003', 'GOT', '001', 0, '居間', '00002'),
('00003', 'CHK', '001', 0, '枕', NULL),
('00003', 'CHK', '002', 0, 'ベッド', NULL),
('00003', 'CHK', '003', 0, '暖炉', NULL),
('00000', 'USE', '002', 8, '本', NULL),
('00000', 'TKS', '001', 1, '鍵', NULL),
('00000', 'TKS', '002', 8, '本', NULL),
('00001', 'GOT', 'F01', 64, '家に帰る', ''),
('00001', 'CHK', '003', 128, '服のポケット', NULL),
('00001', 'GOT', '002', 256, '家に帰る', '00004');

