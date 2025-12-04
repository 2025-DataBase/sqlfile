-- MySQL dump 10.13  Distrib 8.0.38, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: computer_2
-- ------------------------------------------------------
-- Server version	8.0.39

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `account`
--

DROP TABLE IF EXISTS `account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `account` (
  `hunter_id` bigint NOT NULL,
  `balance` bigint NOT NULL COMMENT '현재 잔액',
  PRIMARY KEY (`hunter_id`),
  KEY `idx_account_balance` (`balance`),
  CONSTRAINT `account_hunter_id` FOREIGN KEY (`hunter_id`) REFERENCES `hunter` (`hunter_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account`
--

LOCK TABLES `account` WRITE;
/*!40000 ALTER TABLE `account` DISABLE KEYS */;
/*!40000 ALTER TABLE `account` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `battle`
--

DROP TABLE IF EXISTS `battle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `battle` (
  `mission_id` bigint NOT NULL,
  `battle_seq` bigint NOT NULL,
  `demon_id` bigint NOT NULL,
  `outcome` enum('HUNTER_WIN','DEMON_WIN') NOT NULL,
  `location` varchar(100) NOT NULL,
  `civilian_killed` bigint NOT NULL,
  `civilian_injured` bigint NOT NULL,
  PRIMARY KEY (`mission_id`,`battle_seq`),
  KEY `idx_battle_demon` (`demon_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `battle`
--

LOCK TABLES `battle` WRITE;
/*!40000 ALTER TABLE `battle` DISABLE KEYS */;
/*!40000 ALTER TABLE `battle` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `battle_participaton`
--

DROP TABLE IF EXISTS `battle_participaton`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `battle_participaton` (
  `mission_id` bigint NOT NULL,
  `battle_seq` bigint NOT NULL,
  `hunter_id` bigint NOT NULL,
  `participated_status` enum('ALIVE','DEAD') NOT NULL COMMENT '전투 후 헌터의 상태',
  PRIMARY KEY (`mission_id`,`battle_seq`,`hunter_id`),
  KEY `battle_seq_idx` (`battle_seq`),
  KEY `hunter_id_idx` (`hunter_id`),
  CONSTRAINT `fk_participation_battle` FOREIGN KEY (`mission_id`, `battle_seq`) REFERENCES `battle` (`mission_id`, `battle_seq`) ON DELETE CASCADE,
  CONSTRAINT `participation_hunter_id` FOREIGN KEY (`hunter_id`) REFERENCES `hunter` (`hunter_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `battle_participaton`
--

LOCK TABLES `battle_participaton` WRITE;
/*!40000 ALTER TABLE `battle_participaton` DISABLE KEYS */;
/*!40000 ALTER TABLE `battle_participaton` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `demon`
--

DROP TABLE IF EXISTS `demon`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `demon` (
  `demon_id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `grade` enum('SS','S','A','B','C') NOT NULL COMMENT '악마의 위험도. 초기값 C',
  `status` enum('ALIVE','DEAD') NOT NULL,
  `bounty` bigint DEFAULT NULL COMMENT '현상금. 초기값 null. 현상금 초깃값 팀원들과 상의',
  `civilian_kills` bigint NOT NULL COMMENT '민간인 킬 수',
  `civilian_injuries` bigint NOT NULL COMMENT '민간인 부상 입힌 수',
  PRIMARY KEY (`demon_id`),
  KEY `idx_demon_grade` (`grade`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `demon`
--

LOCK TABLES `demon` WRITE;
/*!40000 ALTER TABLE `demon` DISABLE KEYS */;
/*!40000 ALTER TABLE `demon` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hunter`
--

DROP TABLE IF EXISTS `hunter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hunter` (
  `hunter_id` bigint NOT NULL AUTO_INCREMENT COMMENT '헌터의 ID',
  `team_id` bigint NOT NULL COMMENT '헌터는 반드시 하나의 team_ID를 참조함',
  `name` varchar(100) NOT NULL,
  `status` enum('ALIVE','DEAD') NOT NULL COMMENT '생존상태. 현상금 분배 시 이 값이 DEAD면 분배 하지 않음',
  `demon_id` bigint DEFAULT NULL COMMENT '계약한 악마의 PK. 계약 하지 않으면 null',
  `contract_cost` varchar(100) DEFAULT NULL COMMENT '계약 체결 비용(대가). 계약을 체결하지 않으면 null',
  `contract_power` varchar(100) DEFAULT NULL COMMENT '계약에 따라 얻는 힘(능력). 계약을 체결하지 않으면 null',
  `contract_date` date DEFAULT NULL COMMENT '계약 체결 날짜. 계약을 체결하지 않으면 null',
  PRIMARY KEY (`hunter_id`),
  KEY `team_ID_idx` (`team_id`),
  KEY `demon_id_idx` (`demon_id`),
  CONSTRAINT `hunter_demon_id` FOREIGN KEY (`demon_id`) REFERENCES `demon` (`demon_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `hunter_team_id` FOREIGN KEY (`team_id`) REFERENCES `team` (`team_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hunter`
--

LOCK TABLES `hunter` WRITE;
/*!40000 ALTER TABLE `hunter` DISABLE KEYS */;
/*!40000 ALTER TABLE `hunter` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trigger_random_team` BEFORE INSERT ON `hunter` FOR EACH ROW BEGIN
		-- 파이썬에서 team_id를 안보내거나 0으로 보낸 경우
		IF NEW.team_id IS NULL OR NEW.team_id = 0 THEN
        SET NEW.team_id = (
            SELECT t.team_id
            FROM team AS t -- team 테이블 라는 별명으로 사용
            ORDER BY RAND() -- 랜덤 함수
            LIMIT 1
        );
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `mission`
--

DROP TABLE IF EXISTS `mission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mission` (
  `mission_id` bigint NOT NULL AUTO_INCREMENT,
  `objective` varchar(100) NOT NULL COMMENT '임무 목표',
  `state` enum('PLANNED','IN_PROGRESS','SUCCESS','FAIL') NOT NULL COMMENT '임무 진행 상태',
  `created_at` date NOT NULL COMMENT '생성 날짜',
  `due_date` date NOT NULL COMMENT '생성 마감',
  PRIMARY KEY (`mission_id`),
  KEY `idx_mission_status` (`state`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mission`
--

LOCK TABLES `mission` WRITE;
/*!40000 ALTER TABLE `mission` DISABLE KEYS */;
/*!40000 ALTER TABLE `mission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mission_assignment`
--

DROP TABLE IF EXISTS `mission_assignment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mission_assignment` (
  `team_id` bigint NOT NULL,
  `mission_id` bigint NOT NULL,
  KEY `team_id_idx` (`team_id`),
  KEY `mission_id_idx` (`mission_id`),
  CONSTRAINT `assignment_mission_id` FOREIGN KEY (`mission_id`) REFERENCES `mission` (`mission_id`) ON DELETE CASCADE,
  CONSTRAINT `assignment_team_id` FOREIGN KEY (`team_id`) REFERENCES `team` (`team_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mission_assignment`
--

LOCK TABLES `mission_assignment` WRITE;
/*!40000 ALTER TABLE `mission_assignment` DISABLE KEYS */;
/*!40000 ALTER TABLE `mission_assignment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reward`
--

DROP TABLE IF EXISTS `reward`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reward` (
  `reward_id` bigint NOT NULL AUTO_INCREMENT,
  `mission_id` bigint NOT NULL COMMENT 'Mission의 복합키',
  `battle_seq` bigint NOT NULL COMMENT 'Mission의 복합키',
  `team_id` bigint NOT NULL,
  `total_amount` bigint NOT NULL COMMENT '총현상금',
  PRIMARY KEY (`reward_id`),
  UNIQUE KEY `reward_id_UNIQUE` (`reward_id`),
  KEY `mission_id_idx` (`mission_id`),
  KEY `battle_seq_idx` (`battle_seq`),
  KEY `team_id_idx` (`team_id`),
  KEY `fk_Reward_Battle` (`mission_id`,`battle_seq`),
  CONSTRAINT `fk_Reward_Battle` FOREIGN KEY (`mission_id`, `battle_seq`) REFERENCES `battle` (`mission_id`, `battle_seq`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `reward_team_id` FOREIGN KEY (`team_id`) REFERENCES `team` (`team_id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reward`
--

LOCK TABLES `reward` WRITE;
/*!40000 ALTER TABLE `reward` DISABLE KEYS */;
/*!40000 ALTER TABLE `reward` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reward_distribution`
--

DROP TABLE IF EXISTS `reward_distribution`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reward_distribution` (
  `reward_id` bigint NOT NULL COMMENT '복합키. {reward_id(Fk->Reward),\nhunter_id(FK->Hunter)}',
  `hunter_id` bigint NOT NULL COMMENT '복합키. {reward_id(Fk->Reward),\nhunter_id(FK->Hunter)}',
  `state` enum('IN_PROGRESS','SUCCESS') NOT NULL,
  `distributer_amount` bigint NOT NULL,
  `distributed_at` date NOT NULL,
  PRIMARY KEY (`reward_id`,`hunter_id`),
  KEY `hunter_id_idx` (`hunter_id`),
  KEY `idx_dist_status` (`state`),
  CONSTRAINT `distribution_hunter_id` FOREIGN KEY (`hunter_id`) REFERENCES `hunter` (`hunter_id`) ON DELETE CASCADE,
  CONSTRAINT `distribution_reward_id` FOREIGN KEY (`reward_id`) REFERENCES `reward` (`reward_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reward_distribution`
--

LOCK TABLES `reward_distribution` WRITE;
/*!40000 ALTER TABLE `reward_distribution` DISABLE KEYS */;
/*!40000 ALTER TABLE `reward_distribution` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `team`
--

DROP TABLE IF EXISTS `team`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `team` (
  `team_id` bigint NOT NULL AUTO_INCREMENT,
  `team_name` varchar(100) NOT NULL,
  `region` varchar(100) NOT NULL COMMENT '활동지역',
  PRIMARY KEY (`team_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `team`
--

LOCK TABLES `team` WRITE;
/*!40000 ALTER TABLE `team` DISABLE KEYS */;
/*!40000 ALTER TABLE `team` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'computer_2'
--

--
-- Dumping routines for database 'computer_2'
--
/*!50003 DROP PROCEDURE IF EXISTS `distribute_bounty` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `distribute_bounty`(IN p_battle_id INT)
BEGIN
    DECLARE v_outcome    VARCHAR(20);
    DECLARE v_mission_id INT;
    DECLARE v_bounty     INT;
    DECLARE v_n          INT;
    DECLARE v_share      INT;
    DECLARE v_done_cnt   INT;

     -- 1. 전투 + 악마 현상금 조회
    SELECT b.outcome, b.mission_id, d.bounty
      INTO v_outcome, v_mission_id, v_bounty
    FROM Battle b
      JOIN Demon d ON b.demon_id = d.demon_id
    WHERE b.battle_id = p_battle_id;

    IF v_outcome IS NULL THEN
    -- SQLSTATE '45000'은 MYSQL에서 사용자 정의 예외를 나타내는 표준 코드, 이 코드를 만나면 프로시저 즉시 종료
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '존재하지 않는 전투입니다.';
    END IF;

    -- 2. 이미 분배된 전투인지 확인
    SELECT COUNT(*)
      INTO v_done_cnt
    FROM Distribution
    WHERE battle_id = p_battle_id
      AND status = 'DONE';

    IF v_done_cnt > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '이미 보상 지급이 완료된 전투입니다.';
    END IF;

    -- 3. 승리 여부 확인
    IF v_outcome <> 'HUMAN_WIN' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'HUMAN_WIN 전투만 보상 지급할 수 있습니다.';
    END IF;

    -- 4. ACTIVE 헌터 수 조회(생존 헌터만 한에서 n빵. 사망자, 도망자 전부 제외)
    SELECT COUNT(*)
      INTO v_n
    FROM Distribution dist
      JOIN Human h ON dist.hunter_id = h.hunter_id
    WHERE dist.battle_id = p_battle_id
      AND h.status = 'ACTIVE';

    IF v_n = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '전투에 참여한 ACTIVE 헌터가 없어 보상을 지급할 수 없습니다.';
    END IF;

    -- 5. 1/n 분배액 계산
    SET v_share = v_bounty DIV v_n;

    START TRANSACTION;

        -- 6. Account 업데이트 (ACTIVE 헌터만)
        UPDATE Account a
          JOIN Distribution dist ON a.hunter_id = dist.hunter_id
          JOIN Human h ON h.hunter_id = dist.hunter_id
        SET a.balance      = a.balance + v_share,
            a.total_income = a.total_income + v_share,
            a.last_tx_type = 'IN',
            a.last_tx_amount = v_share,
            a.last_tx_desc  = CONCAT('전투 ', p_battle_id, ' 보상 분배'),
            a.updated_at    = NOW()
        WHERE dist.battle_id = p_battle_id
          AND h.status = 'ACTIVE';

        -- 7. Distribution 상태 DONE + share_amount 기록
        UPDATE Distribution dist
          JOIN Human h ON h.hunter_id = dist.hunter_id
        SET dist.share_amount   = v_share,
            dist.status         = 'DONE',
            dist.distributed_at = NOW()
        WHERE dist.battle_id = p_battle_id
          AND h.status = 'ACTIVE';

        -- 8. 미션 상태 SUCCESS로 변경
        IF v_mission_id IS NOT NULL THEN
            UPDATE Mission
            SET status = 'SUCCESS'
            WHERE mission_id = v_mission_id;
        END IF;

    COMMIT;

    -- Python에서 결과 받기용
    SELECT v_share AS share, v_n AS participant_count;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-12-05  5:46:55
