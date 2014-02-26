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
-- Table structure for table `go_firewall_interfaces`
--

DROP TABLE IF EXISTS `go_firewall_interfaces`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `go_firewall_interfaces` (
  `interface_id` int(20) unsigned NOT NULL auto_increment,
  `interface` varchar(50) NOT NULL,
  `command` enum('-A','-I') default '-I',
  `type` enum('INPUT','OUTPUT','FORWARD') default 'INPUT',
  `target` enum('ACCEPT','DROP','LOG','REJECT','DNAT','SNAT','MASQUERADE') default 'ACCEPT',
  `active` enum('N','Y') default 'N',
  PRIMARY KEY  (`interface_id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `go_firewall_interfaces`
--

LOCK TABLES `go_firewall_interfaces` WRITE;
/*!40000 ALTER TABLE `go_firewall_interfaces` DISABLE KEYS */;
INSERT INTO `go_firewall_interfaces` VALUES (1,'lo','-A','INPUT','ACCEPT','Y'),(4,'eth0','-A','INPUT','ACCEPT','N'),(3,'eth1','-A','INPUT','ACCEPT','N');
/*!40000 ALTER TABLE `go_firewall_interfaces` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2011-05-12 13:41:10
