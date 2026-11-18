-- MySQL dump 10.13  Distrib 8.4.13, for macos15 (arm64)
--
-- Host: 127.0.0.1    Database: vetclinic_f5_source
-- ------------------------------------------------------
-- Server version	8.4.13

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `appointment`
--

DROP TABLE IF EXISTS `appointment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `appointment` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `appointment_date` date NOT NULL,
  `reason` varchar(255) NOT NULL,
  `fee` decimal(8,2) NOT NULL DEFAULT '500.00',
  `pet_id` bigint NOT NULL,
  `vet_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_appointment_pet_date` (`pet_id`,`appointment_date`),
  KEY `fk_appointment_vet` (`vet_id`),
  CONSTRAINT `fk_appointment_pet` FOREIGN KEY (`pet_id`) REFERENCES `pet` (`id`),
  CONSTRAINT `fk_appointment_vet` FOREIGN KEY (`vet_id`) REFERENCES `veterinarian` (`id`),
  CONSTRAINT `chk_appointment_fee` CHECK ((`fee` >= 0.00))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `appointment`
--

LOCK TABLES `appointment` WRITE;
/*!40000 ALTER TABLE `appointment` DISABLE KEYS */;
INSERT INTO `appointment` VALUES (1,'2026-11-12','Annual Checkup',500.00,5,1),(2,'2026-11-18','Vaccination Booster',750.00,1,2),(3,'2026-11-20','Dental Cleaning',1200.00,2,1);
/*!40000 ALTER TABLE `appointment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `clinic_account`
--

DROP TABLE IF EXISTS `clinic_account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clinic_account` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password_hash` varchar(100) NOT NULL,
  `role` varchar(30) NOT NULL,
  `enabled` bit(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  CONSTRAINT `chk_clinic_account_role` CHECK ((`role` in (_utf8mb4'READER',_utf8mb4'MANAGER')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clinic_account`
--

LOCK TABLES `clinic_account` WRITE;
/*!40000 ALTER TABLE `clinic_account` DISABLE KEYS */;
/*!40000 ALTER TABLE `clinic_account` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `owner`
--

DROP TABLE IF EXISTS `owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `owner` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `phone` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `owner`
--

LOCK TABLES `owner` WRITE;
/*!40000 ALTER TABLE `owner` DISABLE KEYS */;
INSERT INTO `owner` VALUES (1,'Maria Santos','09181112222'),(2,'Carlos Mendoza','09172223333'),(3,'Elena Cruz','09193334444');
/*!40000 ALTER TABLE `owner` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pet`
--

DROP TABLE IF EXISTS `pet`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pet` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `microchip_number` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL,
  `species` varchar(50) NOT NULL,
  `breed` varchar(100) DEFAULT NULL,
  `owner_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `microchip_number` (`microchip_number`),
  KEY `fk_pet_owner` (`owner_id`),
  CONSTRAINT `fk_pet_owner` FOREIGN KEY (`owner_id`) REFERENCES `owner` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pet`
--

LOCK TABLES `pet` WRITE;
/*!40000 ALTER TABLE `pet` DISABLE KEYS */;
INSERT INTO `pet` VALUES (1,'MC-1001','Buddy','Dog','Golden Retriever',1),(2,'MC-1002','Luna','Cat','Siamese',2),(3,'MC-1003','Max','Dog','German Shepherd',2),(4,'MC-1004','Milo','Cat','Persian',3),(5,'MC-1005','Bantay','Dog','Aspin',1);
/*!40000 ALTER TABLE `pet` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `pet_appointment_report`
--

DROP TABLE IF EXISTS `pet_appointment_report`;
/*!50001 DROP VIEW IF EXISTS `pet_appointment_report`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `pet_appointment_report` AS SELECT 
 1 AS `appointment_id`,
 1 AS `appointment_date`,
 1 AS `reason`,
 1 AS `pet_id`,
 1 AS `microchip_number`,
 1 AS `pet_name`,
 1 AS `species`,
 1 AS `owner_name`,
 1 AS `vet_name`,
 1 AS `specialty`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `veterinarian`
--

DROP TABLE IF EXISTS `veterinarian`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `veterinarian` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `specialty` varchar(100) DEFAULT NULL,
  `available_slots` int NOT NULL DEFAULT '3',
  PRIMARY KEY (`id`),
  CONSTRAINT `chk_vet_available_slots` CHECK ((`available_slots` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `veterinarian`
--

LOCK TABLES `veterinarian` WRITE;
/*!40000 ALTER TABLE `veterinarian` DISABLE KEYS */;
INSERT INTO `veterinarian` VALUES (1,'Dr. Reyes','Surgery',3),(2,'Dr. Villanueva','General Practice',3),(3,'Dr. Ramos','Dermatology',3);
/*!40000 ALTER TABLE `veterinarian` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Final view structure for view `pet_appointment_report`
--

/*!50001 DROP VIEW IF EXISTS `pet_appointment_report`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `pet_appointment_report` AS select `a`.`id` AS `appointment_id`,`a`.`appointment_date` AS `appointment_date`,`a`.`reason` AS `reason`,`p`.`id` AS `pet_id`,`p`.`microchip_number` AS `microchip_number`,`p`.`name` AS `pet_name`,`p`.`species` AS `species`,`o`.`name` AS `owner_name`,`v`.`name` AS `vet_name`,`v`.`specialty` AS `specialty` from (((`appointment` `a` join `pet` `p` on((`p`.`id` = `a`.`pet_id`))) left join `owner` `o` on((`o`.`id` = `p`.`owner_id`))) join `veterinarian` `v` on((`v`.`id` = `a`.`vet_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-18 18:08:23
