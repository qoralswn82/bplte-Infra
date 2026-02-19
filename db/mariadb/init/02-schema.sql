-- ============================================================
-- 02-schema.sql
-- 테이블 생성 (예시). 실제 DDL로 교체하여 사용하세요.
-- MySQL / MariaDB 공통 문법
-- ============================================================

USE `BPLTE`;

-- 사용자정보기본
CREATE TABLE TBL_USER
(
    USER_ID   VARCHAR(30)                          NOT NULL COMMENT '사용자_아이디'
        PRIMARY KEY,
    USER_NAME VARCHAR(30)                          NOT NULL COMMENT '사용자_이름',
    EMAIL     VARCHAR(64)                          NOT NULL COMMENT '이메일',
    SALT      CHAR(64)                             NOT NULL COMMENT 'SALT',
    PASSWORD  CHAR(64)                             NOT NULL COMMENT 'PASSWORD',
    DEL_YN    CHAR     DEFAULT 'N'                 NOT NULL COMMENT '삭제_여부',
    REG_DT    DATETIME DEFAULT CURRENT_TIMESTAMP() NOT NULL COMMENT '등록_일시',
    RGTR_ID   VARCHAR(30)                          NOT NULL COMMENT '등록자_아이디',
    MDFCN_DT  DATETIME DEFAULT CURRENT_TIMESTAMP() NOT NULL COMMENT '수정_일시',
    MDFR_ID   VARCHAR(30)                          NOT NULL COMMENT '수정자_아이디'
)
    COMMENT '사용자정보기본' COLLATE = UTF8MB4_UNICODE_CI;


-- 포스트기본
CREATE TABLE TBL_POST
(
    POST_NUMBER INT AUTO_INCREMENT NOT NULL COMMENT '포스트_번호' PRIMARY KEY,
    OWNER_USER_ID   VARCHAR(30)   NOT NULL COMMENT '소유자_사용자_아이디',
    TITLE VARCHAR(100) COMMENT '제목',
    CONTENT LONGTEXT                          COMMENT '내용',
    SEARCH_CONTENT LONGTEXT COMMENT '검색_내용',
    DEL_YN    CHAR     DEFAULT 'N'                 NOT NULL COMMENT '삭제_여부',
    REG_DT    DATETIME DEFAULT CURRENT_TIMESTAMP() NOT NULL COMMENT '등록_일시',
    RGTR_ID   VARCHAR(30)                          NOT NULL COMMENT '등록자_아이디',
    MDFCN_DT  DATETIME DEFAULT CURRENT_TIMESTAMP() NOT NULL COMMENT '수정_일시',
    MDFR_ID   VARCHAR(30)                          NOT NULL COMMENT '수정자_아이디'
)
    COMMENT '포스트기본' COLLATE = UTF8MB4_UNICODE_CI;

CREATE INDEX IDX_TBL_POST_OWNER_USER_ID ON TBL_POST (OWNER_USER_ID); 
