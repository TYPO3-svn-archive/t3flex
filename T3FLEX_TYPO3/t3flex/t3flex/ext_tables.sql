#
# Table structure for table 'tx_t3flex_storedqueries'
#
CREATE TABLE tx_t3flex_storedqueries (
	uid int(11) NOT NULL auto_increment,
	pid int(11) DEFAULT '0' NOT NULL,
	tstamp int(11) DEFAULT '0' NOT NULL,
	crdate int(11) DEFAULT '0' NOT NULL,
	cruser_id int(11) DEFAULT '0' NOT NULL,
	deleted tinyint(4) DEFAULT '0' NOT NULL,
	title tinytext,
	parameters tinytext,
	query text,
	description text,
	
	PRIMARY KEY (uid),
	KEY parent (pid)
);