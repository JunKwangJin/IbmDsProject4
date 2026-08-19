# IBM DB2 Data Studio – GADMIN 프로젝트 가이드

## 프로젝트 개요
- 환경: IBM DB2 Data Studio (Eclipse 기반)
- 주 스키마: GADMIN
- 파일 확장자
  - `.spsql` – 저장 프로시저 (Stored Procedure)
  - `.udfsql` – SQL UDF (User Defined Function)
  - `.pludfsql` – External (PL) UDF

---

## 파일 명명 규칙
```
SP_<도메인>_<화면ID>_<동작>.spsql
SF_<도메인>_<기능>.udfsql
```
- 도메인 예: MBC(모바일), FIN(재무), DRV(운전자), MAT(자재), SYS(시스템), TRV(여행)
- 동작 예: SELECT, UPDATE, INSERT, DELETE, PRINT, DDLB
- 버전 접미사: `_1`, `_2` 또는 `_I01`, `_U01`, `_D01`

---

## 저장 프로시저 구조 (표준 템플릿)

```sql
CREATE OR REPLACE PROCEDURE "GADMIN"."SP_XXX_YYY"
--/*******************************************************************************
--파일명    : GADMIN.SP_XXX_YYY
--생성일자  : YYYY.MM.DD
--생성자    : 전광진
--내용      : 한 줄 설명
-- INPUT   : IN_XXX   설명
-- OUTPUT  : OUT_CNT  처리 COUNT
--         : OUT_MSG  처리결과메시지
--*******************************************************************************/
(
      IN  IN_XXX   VARCHAR(N)
   , OUT OUT_CNT   VARCHAR(4)
   , OUT OUT_MSG   VARCHAR(10000)
)
  LANGUAGE SQL
MAIN: BEGIN ATOMIC
    ...
END MAIN
```

---

## 코딩 규칙

### 문장 종결
- 모든 SQL 문장 끝에 `;--` 를 붙인다 (Data Studio 파서 요구사항).

### 변수 선언 순서
1. 업무 변수 (`V_XXX`)
2. `SQLCODE`, `SQLSTATE`, `V_SQLSTATE`
3. CONDITION 선언
4. HANDLER 선언

### 변수 명명
| 용도 | 예 |
|------|-----|
| 입력 파라미터 | `IN_GISU`, `IN_FROMDATE` |
| 출력 파라미터 | `OUT_CNT`, `OUT_MSG` |
| 로컬 변수 | `V_START`, `V_CNT`, `V_KEY_MSG` |
| SQLSTATE 복사 | `V_SQLSTATE` |

### CONDITION 선언 (공통)
```sql
DECLARE LEN_UNDER  CONDITION FOR SQLSTATE '01004';-- 변수 길이 초과
DECLARE LEN_OVER   CONDITION FOR SQLSTATE '22001';-- 문자열 길이 초과
DECLARE NOT_NULL   CONDITION FOR SQLSTATE '23502';-- NOT NULL 위반
DECLARE ROW_DUO    CONDITION FOR SQLSTATE '23505';-- 중복 키
DECLARE NO_TABLE   CONDITION FOR SQLSTATE '42704';-- 테이블 없음
```

### HANDLER 선언 (공통)
```sql
DECLARE CONTINUE HANDLER FOR NOT FOUND   SET (V_SQLSTATE, OUT_MSG) = (SQLSTATE, '');--
DECLARE UNDO HANDLER FOR LEN_UNDER       SET (V_SQLSTATE, OUT_MSG) = (SQLSTATE, 'WRR02: ...');--
DECLARE UNDO HANDLER FOR NO_TABLE        SET (V_SQLSTATE, OUT_MSG) = (SQLSTATE, 'ERR01: ...');--
DECLARE UNDO HANDLER FOR NOT_NULL        SET (V_SQLSTATE, OUT_MSG) = (SQLSTATE, 'ERR02: ...');--
DECLARE UNDO HANDLER FOR ROW_DUO         SET (V_SQLSTATE, OUT_MSG) = (SQLSTATE, 'ERR03: ...');--
DECLARE UNDO HANDLER FOR LEN_OVER        SET (V_SQLSTATE, OUT_MSG) = (SQLSTATE, 'ERR04: ...');--
DECLARE UNDO HANDLER FOR SQLWARNING      SET (V_SQLSTATE, OUT_MSG) = (SQLSTATE, 'WRR99: ...');--
DECLARE UNDO HANDLER FOR SQLEXCEPTION    SET (V_SQLSTATE, OUT_MSG) = (SQLSTATE, 'ERR99: ...');--
```

### OUT_MSG 오류 코드 체계
| 코드 | 의미 |
|------|------|
| `ERR01` | 테이블 없음 |
| `ERR02` | NOT NULL 위반 |
| `ERR03` | 중복 키 |
| `ERR04` | 문자열 길이 초과 |
| `ERR10`~ | 업무 로직 오류 (프로시저별 정의) |
| `ERR99` | 알 수 없는 예외 |
| `WRR02` | 변수 길이 부족 (Warning) |
| `WRR99` | 기타 경고 |

### NOT FOUND 처리 패턴
```sql
SET V_SQLSTATE = '00000';--
SELECT ... INTO V_XXX FROM ... WHERE ...;--
IF V_SQLSTATE <> '00000' THEN
    SET OUT_MSG = 'ERR10: ...' ||CHR(13)|| '[SQLSTATE:'||V_SQLSTATE||']';--
    RETURN;--
END IF;--
```

---

## 주요 테이블
| 테이블 | 설명 | 주요 컬럼 |
|--------|------|-----------|
| `GADMIN.BSACC9` | 기수(회계기간) 마스터 | GISU(3자리 영패딩), START(YYYY-MM-DD), TERMINATION(YYYY-MM-DD) |
| `GADMIN.BSACC2` | 계정과목 | ACC_CD, ACC_NM, DRCR_GB |
| `GADMIN.MBC_BBS` | 모바일 게시판 | BBSID, BBS_TITLE, BBS_CONTENT |
| `GADMIN.MBC_USERS` | 모바일 사용자 | INSA_NO, INSA_NM, CELLPHONE |

### BSACC9 GISU 포맷
- 3자리 숫자, 앞 자리 0 패딩 (예: `'001'`, `'002'`)
- 이전/다음 기수 계산: `LPAD(INTEGER(GISU) ± 1, 3, '0')`
