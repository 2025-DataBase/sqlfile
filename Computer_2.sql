-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema Computer_2
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema Computer_2
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `Computer_2` DEFAULT CHARACTER SET utf8 ;
USE `Computer_2` ;

-- -----------------------------------------------------
-- Table `Computer_2`.`Team`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Computer_2`.`Team` (
  `team_id` BIGINT NOT NULL AUTO_INCREMENT,
  `team_name` VARCHAR(100) NOT NULL,
  `region` VARCHAR(100) NOT NULL COMMENT '활동지역',
  PRIMARY KEY (`team_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Computer_2`.`Demon`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Computer_2`.`Demon` (
  `demon_id` BIGINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  
  -- 노션 인덱스 수정 명칭에 맞게 원래의 rank->grade로 수정
  `grade` ENUM('SS', 'S', 'A', 'B', 'C') NOT NULL COMMENT '악마의 위험도. 초기값 C',
  `status` ENUM('ALIVE', 'DEAD') NOT NULL,
  `bounty` BIGINT NULL COMMENT '현상금. 초기값 null. 현상금 초깃값 팀원들과 상의',
  `civilian_kills` BIGINT NOT NULL COMMENT '민간인 킬 수',
  `civilian_injuries` BIGINT NOT NULL COMMENT '민간인 부상 입힌 수',
  PRIMARY KEY (`demon_id`))
ENGINE = InnoDB;

-- D. 정렬 및 등급 조회 (Ranking & Sorting)
-- 목적: S급, A급 등 악마를 등급별로 조회하거나, 등급순으로 정렬할 때 성능을 높입니다.
ALTER TABLE `Computer_2`.`Demon`
ADD INDEX `idx_demon_grade`(`grade` ASC);

-- -----------------------------------------------------
-- Table `Computer_2`.`Hunter`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Computer_2`.`Hunter` (
  `hunter_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '헌터의 ID',
  `team_id` BIGINT NOT NULL COMMENT '헌터는 반드시 하나의 team_ID를 참조함',
  `name` VARCHAR(100) NOT NULL,
  `status` ENUM('ALIVE', 'DEAD') NOT NULL COMMENT '생존상태. 현상금 분배 시 이 값이 DEAD면 분배 하지 않음',
  `demon_id` BIGINT NULL COMMENT '계약한 악마의 PK. 계약 하지 않으면 null',
  `contract_cost` VARCHAR(100) NULL COMMENT '계약 체결 비용(대가). 계약을 체결하지 않으면 null',
  `contract_power` VARCHAR(100) NULL COMMENT '계약에 따라 얻는 힘(능력). 계약을 체결하지 않으면 null',
  `contract_date` DATE NULL COMMENT '계약 체결 날짜. 계약을 체결하지 않으면 null',
  PRIMARY KEY (`hunter_id`),
  INDEX `team_ID_idx` (`team_id` ASC) ,
  INDEX `demon_id_idx` (`demon_id` ASC) ,
  CONSTRAINT `hunter_team_id`
    FOREIGN KEY (`team_id`)
    REFERENCES `Computer_2`.`Team` (`team_id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `hunter_demon_id`
    FOREIGN KEY (`demon_id`)
    REFERENCES `Computer_2`.`Demon` (`demon_id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE)
ENGINE = InnoDB;

-- A. 복합 인덱스 수정 및 human -> hunter 이름 수정
-- 목적: Human 테이블에서 "특정 팀"에 속해있으면서 "특정 상태(생존/사망 등)"인 사람을 찾을 때 사용합니다.
-- 효과: team_id로 먼저 거르고, 그 안에서 status로 한 번 더 빠르게 찾습니다.
ALTER TABLE `Computer_2`.`Hunter`
ADD INDEX `idx_hunter_team_status` (`tean_id` ASC, `status` ASC);

-- -----------------------------------------------------
-- Table `Computer_2`.`Mission`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Computer_2`.`Mission` (
  `mission_id` BIGINT NOT NULL AUTO_INCREMENT,
  `objective` VARCHAR(100) NOT NULL COMMENT '임무 목표',
  `state` ENUM('PLANNED', 'IN_PROGRESS', 'SUCCESS', 'FAIL') NOT NULL COMMENT '임무 진행 상태',
  `created_at` DATE NOT NULL COMMENT '생성 날짜',
  `due_date` DATE NOT NULL COMMENT '생성 마감',
  PRIMARY KEY (`mission_id`))
ENGINE = InnoDB;

-- C. 상태(State) 필터링 최적화
-- 목적: "현재 진행 중인 임무", "실패한 임무" 등 임무 상태별 조회를 빠르게 합니다.
ALTER TABLE `Computer_2`.`Mission`
ADD INDEX `idx_mission_status`(`state` ASC);

-- -----------------------------------------------------
-- Table `Computer_2`.`Mission_assignment`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Computer_2`.`Mission_assignment` (
  `team_id` BIGINT NOT NULL,
  `mission_id` BIGINT NOT NULL,
  
-- B. 외래키(FK) & 조인 성능 최적화
-- 목적: 특정 팀에게 할당된 임무 목록을 조회할 때 빠릅니다.
-- Mission이 아닌 Mission_assignment에 팀아이디에 대한 인덱스를 추가하였습니다.
-- 불필요한 Mission 테이블을 탐색하는거보다 이 테이블에서 거르는것이 더 효율적인 방법입니다.
 INDEX `team_id_idx` (`team_id` ASC) ,
 
 INDEX `mission_id_idx` (`mission_id` ASC) ,

  CONSTRAINT `assignment_team_id`
    FOREIGN KEY (`team_id`)
    REFERENCES `Computer_2`.`Team` (`team_id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `assignment_mission_id`
    FOREIGN KEY (`mission_id`)
    REFERENCES `Computer_2`.`Mission` (`mission_id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Computer_2`.`Battle`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Computer_2`.`Battle` (
  `mission_id` BIGINT NOT NULL,
  `battle_seq` BIGINT NOT NULL,
  `demon_id` BIGINT NOT NULL,
  
  -- 착오로 잘못 칭한 'HUMAN_WIN'->'HUNTER_WIN'으로 수정하였습니다.
  `outcome` ENUM('HUNTER_WIN', 'DEMON_WIN') NOT NULL,
  `location` VARCHAR(100) NOT NULL,
  `civilian_killed` BIGINT NOT NULL,
  `civilian_injured` BIGINT NOT NULL,
  PRIMARY KEY (`mission_id`, `battle_seq`),
  
  -- Mission 테이블 참조 외래 키 추가
  CONSTRAINT `fk_battle_mission_id`
    FOREIGN KEY (`mission_id`)
    REFERENCES `Computer_2`.`Mission` (`mission_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    
    CONSTRAINT `fk_battle_demon_id`
    FOREIGN KEY (`demon_id`)
    REFERENCES `Computer_2`.`Demon` (`demon_id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE
  )
ENGINE = InnoDB;

-- B. 외래키(FK) & 조인 성능 최적화
-- 목적: 특정 악마가 참여한 전투 기록을 조회할 때 빠릅니다.
ALTER TABLE `Computer_2`.`Battle`
ADD INDEX `idx_battle_demon` (`demon_id` ASC);

-- -----------------------------------------------------
-- Table `Computer_2`.`Reward`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Computer_2`.`Reward` (
  `reward_id` BIGINT NOT NULL AUTO_INCREMENT,
  `mission_id` BIGINT NOT NULL COMMENT 'Mission의 복합키',
  `battle_seq` BIGINT NOT NULL COMMENT 'Mission의 복합키',
  `team_id` BIGINT NOT NULL,
  `total_amount` BIGINT NOT NULL COMMENT '총현상금',
  PRIMARY KEY (`reward_id`),
  
  UNIQUE INDEX `reward_id_UNIQUE` (`reward_id` ASC) ,
  INDEX `mission_id_idx` (`mission_id` ASC) ,
  INDEX `battle_seq_idx` (`battle_seq` ASC) ,
  INDEX `team_id_idx` (`team_id` ASC) ,
  
  -- 복합키로 수정
--   CONSTRAINT `reward_mission_id`
--     FOREIGN KEY (`mission_id`)
--     REFERENCES `Computer_2`.`Battle` (`mission_id`)
--     ON DELETE CASCADE
--     ON UPDATE CASCADE,
--   CONSTRAINT `reward_battle_seq`
--     FOREIGN KEY (`battle_seq`)
--     REFERENCES `Computer_2`.`Battle` (`battle_seq`)
--     ON DELETE CASCADE
--     ON UPDATE CASCADE,

  CONSTRAINT `fk_Reward_Battle`
  FOREIGN KEY (`mission_id`, `battle_seq`)
  REFERENCES `Computer_2`.`Battle` (`mission_id`, `battle_seq`)
  ON DELETE CASCADE
  ON UPDATE CASCADE,

  CONSTRAINT `reward_team_id`
    FOREIGN KEY (`team_id`)
    REFERENCES `Computer_2`.`Team` (`team_id`)
    ON DELETE RESTRICT
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Computer_2`.`Battle_Participaton`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Computer_2`.`Battle_Participaton` (
  `mission_id` BIGINT NOT NULL,
  `battle_seq` BIGINT NOT NULL,
  `hunter_id` BIGINT NOT NULL,
  `participated_status` ENUM('ALIVE', 'DEAD') NOT NULL COMMENT '전투 후 헌터의 상태',
  PRIMARY KEY (`mission_id`, `battle_seq`, `hunter_id`),
  
 INDEX `battle_seq_idx` (`battle_seq` ASC) ,
  INDEX `hunter_id_idx` (`hunter_id` ASC) ,

  -- 복합키로 수정
--  CONSTRAINT `participation_mission_id`
--     FOREIGN KEY (`mission_id`)
--     REFERENCES `Computer_2`.`Battle` (`mission_id`)
--     ON DELETE CASCADE
--     ON UPDATE NO ACTION,
--   CONSTRAINT `participation_battle_seq`
--     FOREIGN KEY (`battle_seq`)
--     REFERENCES `Computer_2`.`Battle` (`battle_seq`)
--     ON DELETE CASCADE
--     ON UPDATE NO ACTION,

CONSTRAINT `fk_participation_battle`
  FOREIGN KEY (`mission_id`, `battle_seq`)
  REFERENCES `Computer_2`.`Battle` (`mission_id`, `battle_seq`)
  ON DELETE CASCADE
  ON UPDATE NO ACTION,
  
  CONSTRAINT `participation_hunter_id`
    FOREIGN KEY (`hunter_id`)
    REFERENCES `Computer_2`.`Hunter` (`hunter_id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Computer_2`.`Account`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Computer_2`.`Account` (
  `hunter_id` BIGINT NOT NULL,
  `balance` BIGINT NOT NULL COMMENT '현재 잔액',
  PRIMARY KEY (`hunter_id`),
  CONSTRAINT `account_hunter_id`
    FOREIGN KEY (`hunter_id`)
    REFERENCES `Computer_2`.`Hunter` (`hunter_id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- D. 정렬 및 등급 조회 (Ranking & Sorting)
-- 목적: 보유 금액이 많은 순(랭킹)으로 정렬하거나, 특정 금액 이상/이하의 계정을 찾을 때 빠릅니다.
ALTER TABLE `Computer_2`.`Account`
ADD INDEX `idx_account_balance`(`balance` ASC);

-- -----------------------------------------------------
-- Table `Computer_2`.`Reward_Distribution`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Computer_2`.`Reward_Distribution` (
  `reward_id` BIGINT NOT NULL COMMENT '복합키. {reward_id(Fk->Reward),\nhunter_id(FK->Hunter)}',
  `hunter_id` BIGINT NOT NULL COMMENT '복합키. {reward_id(Fk->Reward),\nhunter_id(FK->Hunter)}',
  
  -- 돈이 지급중인지, 지급 완료 되었는지 나타내는 state가 추가되었습니다. 
  `state` ENUM('IN_PROGRESS', 'SUCCESS') NOT NULL ,
  `distributer_amount` BIGINT NOT NULL,
  `distributed_at` DATE NOT NULL,
  PRIMARY KEY (`reward_id`, `hunter_id`),
  
  -- B. 외래키(FK) & 조인 성능 최적화
  -- 목적: 특정 헌터가 청구한 현상금 내역을 조회할 때 빠릅니다.
  INDEX `hunter_id_idx` (`hunter_id` ASC),

  CONSTRAINT `distribution_reward_id`
    FOREIGN KEY (`reward_id`)
    REFERENCES `Computer_2`.`Reward` (`reward_id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `distribution_hunter_id`
    FOREIGN KEY (`hunter_id`)
    REFERENCES `Computer_2`.`Hunter` (`hunter_id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- C. 상태(Status) 필터링 최적화
-- 목적: 정산/배분 데이터 중 "지급 대기중"이나 "지급 완료" 건을 빠르게 찾습니다
ALTER TABLE `Computer_2`.`Reward_Distribution`
ADD INDEX `idx_dist_status`(`state` ASC);


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
