# MariaDB 기반 이미지 (MySQL 호환: mysql:8.0 등으로 교체 가능)
# MySQL/MariaDB 공식 이미지는 동일하게 /docker-entrypoint-initdb.d/ 사용
FROM mariadb:11.2

# 1. root 비밀번호 (실행 시 -e MYSQL_ROOT_PASSWORD=xxx 로 덮어쓰기 권장)
ENV MYSQL_ROOT_PASSWORD=gkfls5511

# 선택: 환경변수로 스키마/계정 미리 지정 시 자동 생성됨 (init 스크립트와 중복 가능)
# ENV MYSQL_DATABASE=BPTLE
# ENV MYSQL_USER=bplte_admin
# ENV MYSQL_PASSWORD=Admin1234!@

# 2~6. 초기화 스크립트: 스키마/계정/권한/타임존/테이블은 init SQL에서 수행
# 알파벳 순서로 실행됨 (01-init.sql -> 02-schema.sql)
COPY init/ /docker-entrypoint-initdb.d/

# 기본 포트 (변경 시 docker run -p 로 매핑)
EXPOSE 3306
