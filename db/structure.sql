CREATE TABLE `channel` (
  `chanid` int(11) NOT NULL,
  `channum` varchar(255) collate utf8_unicode_ci default NULL,
  `callsign` varchar(255) collate utf8_unicode_ci default NULL,
  `name` varchar(255) collate utf8_unicode_ci default NULL,
  `visible` tinyint(1) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`chanid`),
  KEY `index_channels_on_channum` (`channum`),
  KEY `index_channels_on_visible` (`visible`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `program` (
  `id` int(11) NOT NULL auto_increment,
  `chanid` int(11) default NULL,
  `starttime` datetime default NULL,
  `endtime` datetime default NULL,
  `title` varchar(255) collate utf8_unicode_ci default NULL,
  `subtitle` varchar(255) collate utf8_unicode_ci default NULL,
  `description` varchar(255) collate utf8_unicode_ci default NULL,
  `category` varchar(255) collate utf8_unicode_ci default NULL,
  `category_type` varchar(255) collate utf8_unicode_ci default NULL,
  `airdate` date default NULL,
  `stars` float default NULL,
  `previouslyshown` tinyint(1) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `index_programs_on_chanid` (`chanid`),
  KEY `index_programs_on_starttime` (`starttime`),
  KEY `index_programs_on_endtime` (`endtime`),
  KEY `index_programs_on_title` (`title`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) collate utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO schema_migrations (version) VALUES ('20120313201753');

INSERT INTO schema_migrations (version) VALUES ('20120313205151');

INSERT INTO schema_migrations (version) VALUES ('20120316190143');

INSERT INTO schema_migrations (version) VALUES ('20120316190647');
