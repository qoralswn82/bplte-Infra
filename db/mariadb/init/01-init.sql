-- ============================================================
-- 01-init.sql
-- MySQL / MariaDB 공통: 스키마, 계정, 권한, 타임존
-- /docker-entrypoint-initdb.d/ 에서 컨테이너 최초 기동 시 1회 실행
-- ============================================================

-- 1. 스키마 생성 (이미 MYSQL_DATABASE로 생성된 경우 무시되도록) UTF-8을 4바이트로 인코딩(이모지, 모든 문자 안전하게 저장)  / 대소문자 구분  x 
CREATE DATABASE IF NOT EXISTS `BPLTE` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 2. 애플리케이션용 계정 생성 (MySQL 5.7+, MariaDB 10.2+ 공통 문법)
-- MYSQL_USER/MYSQL_PASSWORD 환경변수로 생성되는 계정과 중복되지 않도록 스키마별 계정 예시
CREATE USER IF NOT EXISTS 'bplte_admin'@'%' IDENTIFIED BY 'Admin1234!@';

-- 3. 해당 스키마에 대한 권한 부여
GRANT ALL PRIVILEGES ON `BPLTE`.* TO 'bplte_admin'@'%';
FLUSH PRIVILEGES;

-- 4. 타임존 설정 (세션 및 전역, MySQL/MariaDB 공통)
SET GLOBAL time_zone = 'Asia/Seoul';
SET time_zone = 'Asia/Seoul';

-- 사용할 스키마 지정 (이후 02-schema.sql 등에서 사용)
USE `BPLTE`;
