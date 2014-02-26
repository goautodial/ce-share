-- MySQL dump 10.11
--
-- Host: localhost    Database: asterisk
-- ------------------------------------------------------
-- Server version	5.0.77

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `go_firewall_rules`
--

DROP TABLE IF EXISTS `go_firewall_rules`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `go_firewall_rules` (
  `rule_id` int(20) unsigned NOT NULL auto_increment,
  `rule_number` varchar(20) NOT NULL,
  `command` enum('-A','-I') default '-I',
  `type` enum('INPUT','OUTPUT','FORWARD') default 'INPUT',
  `state` varchar(255) default NULL,
  `protocol` enum('icmp','tcp','udp','all') default 'all',
  `match_protocol` enum('N','Y') default 'N',
  `source` varchar(200) NOT NULL default '0.0.0.0/0',
  `destination` varchar(200) NOT NULL default '0.0.0.0/0',
  `port_from` varchar(200) default NULL,
  `port_to` varchar(200) default NULL,
  `target` enum('ACCEPT','DROP','LOG','REJECT','DNAT','SNAT','MASQUERADE') default 'ACCEPT',
  `active` enum('N','Y') default 'N',
  PRIMARY KEY  (`rule_id`)
) ENGINE=MyISAM AUTO_INCREMENT=17 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `go_firewall_rules`
--

LOCK TABLES `go_firewall_rules` WRITE;
/*!40000 ALTER TABLE `go_firewall_rules` DISABLE KEYS */;
INSERT INTO `go_firewall_rules` VALUES (1,'1','-A','INPUT','','all','N','0.0.0.0/0','0.0.0.0/0','50','','ACCEPT','Y'),(2,'1','-A','INPUT','','all','N','0.0.0.0/0','0.0.0.0/0','51','','ACCEPT','Y'),(3,'1','-A','INPUT','','udp','N','224.0.0.251','0.0.0.0/0','5353','','ACCEPT','Y'),(4,'1','-A','INPUT','','udp','Y','0.0.0.0/0','0.0.0.0/0','631','','ACCEPT','Y'),(5,'1','-A','INPUT','ESTABLISH,RELATED','all','N','0.0.0.0/0','0.0.0.0/0','','','ACCEPT','Y'),(7,'1','-A','INPUT','','udp','Y','0.0.0.0/0','0.0.0.0/0','5060','','ACCEPT','Y'),(8,'1','-A','INPUT','','udp','Y','0.0.0.0/0','0.0.0.0/0','4569','','ACCEPT','Y'),(9,'1','-A','INPUT','NEW','tcp','Y','0.0.0.0/0','0.0.0.0/0','21','','ACCEPT','Y'),(10,'1','-A','INPUT','NEW','tcp','Y','0.0.0.0/0','0.0.0.0/0','80','','ACCEPT','Y'),(11,'1','-A','INPUT','NEW','tcp','Y','0.0.0.0/0','0.0.0.0/0','22','','ACCEPT','Y'),(12,'1','-A','INPUT','NEW','tcp','Y','0.0.0.0/0','0.0.0.0/0','443','','ACCEPT','Y'),(13,'1','-A','INPUT','NEW','tcp','Y','0.0.0.0/0','0.0.0.0/0','4949','','ACCEPT','N'),(14,'1','-A','INPUT','','tcp','Y','0.0.0.0/0','0.0.0.0/0','3306','','ACCEPT','N'),(15,'1','-A','INPUT','NEW','tcp','Y','0.0.0.0/0','0.0.0.0/0','10000','','ACCEPT','Y'),(16,'1','-A','INPUT','','udp','Y','0.0.0.0/0','0.0.0.0/0','10000','65000','ACCEPT','Y');
/*!40000 ALTER TABLE `go_firewall_rules` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2011-05-12 13:41:22
