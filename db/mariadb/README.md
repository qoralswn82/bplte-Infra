# DBMS (MariaDB) Docker 환경

이 디렉터리는 MariaDB를 Docker로 띄우고, 스키마·계정·권한·타임존·테이블을 **최초 기동 시 한 번에** 적용하는 설정입니다.

---

## 목적
- 환경 구성의 재사용성 확보
- MSA 구조에서 DB 분리 / 이중화 구조 실험을 위한 환경 구성

---

## 목차
1. 디렉터리·파일 구성
2. 실행 방법(총 3가지)
    + a. 볼륨을 사용하는 방식 (데이터 영속)
    + b. 볼륨을 사용하지 않는 방식 (데이터 비영속)
    + c. Dockerfile 사용 (Compose 없이)
3. 두 Compose 파일(볼륨 사용여부)의 차이
4. 참고
    + a. 접속 정보 기본값 (init/01-init.sql 기준)
    + b. init 스크립트 다시 실행하려면
    + c. DBMS 변경 (MySQL 등)
    + d. 환경 변수 적용 방법

---

## 1. 디렉터리·파일 구성

```
dbms/
├── docker-compose.yml          # [1] 볼륨 사용 — 데이터 영속
├── docker-compose-no-volume.yml # [2] 볼륨 미사용 — 데이터 비영속
├── Dockerfile                  # 커스텀 이미지 빌드용 (init 포함)
├── init/                       # 최초 기동 시 실행되는 SQL
│   ├── 01-init.sql             # 스키마·계정·권한·타임존 (필수)
│   └── 02-schema.sql           # 테이블 DDL (추가용)
└── README.md
```

<table>
<tr><th>경로</th><th>설명</th></tr>
<tr><td><strong>docker-compose.yml</strong></td><td><strong>볼륨 사용.</strong> <code>db_data</code> named volume으로 DB 데이터 저장. 컨테이너 삭제 후에도 데이터 유지.</td></tr>
<tr><td><strong>docker-compose-no-volume.yml</strong></td><td><strong>볼륨 미사용.</strong> DB 데이터는 컨테이너 내부만 사용. 컨테이너 삭제 시 데이터 소멸.</td></tr>
<tr><td><strong>Dockerfile</strong></td><td>공식 <code>mariadb:11</code> 위에 <code>init/</code>을 복사한 이미지를 만들 때 사용. Compose 없이 <code>docker run</code>으로 쓸 때 사용.</td></tr>
<tr><td><strong>init/</strong></td><td>MariaDB가 <strong>최초 1회만</strong> 실행하는 스크립트 디렉터리. <code>./init</code>이 컨테이너의 <code>/docker-entrypoint-initdb.d</code>에 마운트됨.</td></tr>
<tr><td><strong>init/01-init.sql</strong></td><td>스키마 생성, 계정 생성, 권한 부여, 타임존(Asia/Seoul) 설정.</td></tr>
<tr><td><strong>init/02-schema.sql</strong></td><td>추가 테이블 DDL. 필요 시 여기에만 작성하면 됨.</td></tr>
</table>

---
## 2. 실행 방법(총 3가지)
### a. 볼륨을 사용하는 방식 (데이터 영속)

**파일:** `docker-compose.yml`

- **named volume `db_data`** 에 DB 데이터 저장.
- 컨테이너를 `down` 해도 데이터는 유지.
- `down -v` 로 볼륨까지 지우면 데이터 삭제 후, 다음 `up` 시 init이 다시 실행됨.

#### 실행

```bash
cd /Users/baekminju/Desktop/private/bplte/env/dbms
docker compose -f docker-compose.yml up -d
```

#### 내부 구성 (개념)

```
┌─────────────────────────────────────────────────────────┐
│  docker-compose.yml (볼륨 사용)                            │
├─────────────────────────────────────────────────────────┤
│  서비스: db (mariadb:11)                                  │
│    ├── 환경변수: MYSQL_ROOT_PASSWORD, MYSQL_DATABASE 등   │
│    ├── 포트: 3306 → 3306                                  │
│    ├── 볼륨 1: ./init → /docker-entrypoint-initdb.d      │
│    │         (init 스크립트, 읽기용 마운트)                 │
│    └── 볼륨 2: db_data → /var/lib/mysql                   │
│              (DB 데이터 저장, 영속)                        │
│                                                           │
│  volumes:                                                 │
│    db_data (named volume, Docker가 관리)                   │
└─────────────────────────────────────────────────────────┘
```




### b. 볼륨을 사용하지 않는 방식 (데이터 비영속)

**파일:** `docker-compose-no-volume.yml`

- **데이터 볼륨 없음.** DB 데이터는 컨테이너 내부(`/var/lib/mysql`)에만 존재.
- 컨테이너 삭제 시 **모든 데이터 삭제**.
- init 스크립트만 `./init` 마운트로 전달 (최초 기동 시 1회 실행).

#### 실행

```bash
cd /Users/baekminju/Desktop/private/bplte/env/dbms
docker compose -f docker-compose-no-volume.yml up -d
```

#### 내부 구성 (개념)

```
┌─────────────────────────────────────────────────────────┐
│  docker-compose-no-volume.yml (볼륨 미사용)               │
├─────────────────────────────────────────────────────────┤
│  서비스: db (mariadb:11)                                  │
│    ├── 환경변수: MYSQL_ROOT_PASSWORD 등                   │
│    ├── 포트: 3306 → 3306                                  │
│    └── 볼륨 1: ./init → /docker-entrypoint-initdb.d      │
│              (init 스크립트만 마운트)                      │
│                                                           │
│  데이터: 컨테이너 내부만 사용 → 컨테이너 삭제 시 소멸      │
└─────────────────────────────────────────────────────────┘
```




### c.Dockerfile 사용 (Compose 없이)

init을 **이미지 안에 포함**해 두고 `docker run`만 쓰고 싶을 때 사용.

```bash
docker build -t bplte-mariadb:local .
docker run -d --name bplte-mariadb -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=원하는비밀번호 \
  bplte-mariadb:local
```

---

## 3. 두 Compose 파일(볼륨 사용여부)의 차이

<table>
<tr><th>항목</th><th>docker-compose.yml (볼륨 사용)</th><th>docker-compose-no-volume.yml (볼륨 미사용)</th></tr>
<tr><td><strong>데이터 저장 위치</strong></td><td>named volume <code>db_data</code></td><td>컨테이너 내부만</td></tr>
<tr><td><strong>컨테이너 삭제 시</strong></td><td>데이터 유지</td><td>데이터 소멸</td></tr>
<tr><td><strong>볼륨 개수</strong></td><td>2개 (init 마운트 + db_data)</td><td>1개 (init 마운트만)</td></tr>
<tr><td><strong>용도</strong></td><td>개발/운영에서 데이터 유지</td><td>일회성·테스트·깨끗한 상태로 재시작</td></tr>
</table>

공통: `./init` 마운트, entrypoint(OS 타임존 설정), `mariadbd --default-time-zone=Asia/Seoul`, healthcheck.


---


## 4. 참고
### a. 접속 정보 기본값 (init/01-init.sql 기준)

<table>
<tr><th>항목</th><th>값</th></tr>
<tr><td>Host</td><td>localhost</td></tr>
<tr><td>Port</td><td>3306</td></tr>
<tr><td>Root 비밀번호</td><td>compose 환경변수 또는 기본값 (각 yml 참고)</td></tr>
<tr><td>스키마</td><td>BPLTE</td></tr>
<tr><td>앱 계정</td><td>bplte_admin / Admin1234!@</td></tr>
</table>



### b. init 스크립트 다시 실행하려면

- **볼륨 사용:** `docker compose -f docker-compose.yml down -v` 후 `up -d` (볼륨 삭제 시에만 init 재실행).
- **볼륨 미사용:** 컨테이너 삭제 후 `up -d` 하면 새 컨테이너에서 init이 1회 다시 실행됨.



### c. DBMS 변경 (MySQL 등)

- **Compose:** `image: mariadb:11` → `image: mysql:8` 등으로 변경.
- **Dockerfile:** `FROM mariadb:11` → `FROM mysql:8` 후 이미지 재빌드.

`MYSQL_*` 환경변수와 `/docker-entrypoint-initdb.d/` 동작은 MySQL/MariaDB 공통이므로 init SQL은 그대로 사용 가능합니다.



### d. 환경 변수 적용 방법

> ⚠️ --env-file 옵션 없이 실행 명령어 실행 시  기본적으로 **.env 파일 확인**

#### 옵션 사용 실행
```bash
cd /Users/baekminju/Desktop/private/bplte/env/dbms
docker compose -f docker-compose-no-volume.yml --env-file {.env 파일} up -d
```


#### 환경 변수 파일 미존재 시 우선순위
1. --env-file
2. shell 환경변수
3. .env 파일
4. 없으면 빈 문자열 --> ⚠️ warning 발생



