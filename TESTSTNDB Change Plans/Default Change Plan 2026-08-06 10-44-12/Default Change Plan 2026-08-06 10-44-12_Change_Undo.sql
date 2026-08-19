-- <ScriptOptions statementTerminator="@" />
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN0101_CHOICE_SELECT"
(
    IN IN_FROMDATE VARCHAR(10),
    IN IN_TODATE VARCHAR(10),
    IN IN_ACC_NM VARCHAR(60),
    IN IN_ACC_CD VARCHAR(10),
    IN IN_JEUNGBING_DOC VARCHAR(15),
    IN IN_MANAGE_ITEM VARCHAR(45),
    IN IN_MANAGE_CD VARCHAR(9),
    IN IN_ACC_CONT VARCHAR(300),
    IN IN_DRCR_GB VARCHAR(6),
    IN IN_FROM_ACC_NO VARCHAR(4),
    IN IN_TO_ACC_NO VARCHAR(4),
    IN IN_PRICE VARCHAR(13),
    IN IN_USER_ID VARCHAR(25)
)
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE SQLSTATE CHAR(5) DEFAULT '00000';--
    DECLARE CURSOR_ACC CURSOR WITH RETURN FOR
	SELECT '' AS STATUS, '0' AS CK, ROWNUMBER() OVER() AS ROWNUM, A.*, B.GAP_AMT
	  FROM GADMIN.ACCOU1 A
	        LEFT OUTER JOIN
	        ( SELECT DATE, ACC_NO, COALESCE(SUM(DR_AMT),0) - COALESCE(SUM(CR_AMT),0) AS GAP_AMT
	            FROM GADMIN.ACCOU1
	           WHERE 1 = 1
	             AND DRCR_GB IN ('차변','대변')
	          GROUP BY DATE, ACC_NO
	         ) B  ON (A.DATE = B.DATE AND A.ACC_NO = B.ACC_NO)
	WHERE 1 = 1
	  AND A.DATE BETWEEN IN_FROMDATE AND IN_TODATE
	  AND COALESCE(A.ACC_NM,'') LIKE '%'||COALESCE(IN_ACC_NM,'')||'%'
	  AND COALESCE(A.ACC_CD,'') LIKE '%'||COALESCE(IN_ACC_CD,'')||'%'
	  AND COALESCE(A.JEUNGBING_DOC,'') LIKE '%'||COALESCE(IN_JEUNGBING_DOC,'')||'%'
	  AND COALESCE(A.MANAGE_ITEM_1,'') LIKE '%'||COALESCE(IN_MANAGE_ITEM,'')||'%'
	  AND COALESCE(A.ACC_CONT,'') LIKE '%'||COALESCE(IN_ACC_CONT,'')||'%'
	  AND COALESCE(A.DRCR_GB,'') LIKE  '%'||COALESCE(IN_DRCR_GB,'')||'%'
	  AND COALESCE(A.ACC_NO,'000') BETWEEN IN_FROM_ACC_NO AND IN_TO_ACC_NO
	 ORDER BY A.DATE, A.ACC_NO, A.ROW_ID;--

	DECLARE CURSOR_ACC1 CURSOR WITH RETURN FOR
	SELECT '' AS STATUS, '0' AS CK, ROWNUMBER() OVER() AS ROWNUM, A.*, B.GAP_AMT
	  FROM GADMIN.ACCOU1 A
	        LEFT OUTER JOIN
	        ( SELECT DATE, ACC_NO, COALESCE(SUM(DR_AMT),0) - COALESCE(SUM(CR_AMT),0) AS GAP_AMT
	            FROM GADMIN.ACCOU1
	           WHERE 1 = 1
	             AND DRCR_GB IN ('차변','대변')
	          GROUP BY DATE, ACC_NO
	         ) B  ON (A.DATE = B.DATE AND A.ACC_NO = B.ACC_NO)
	WHERE 1 = 1
	  AND A.DATE BETWEEN IN_FROMDATE AND IN_TODATE
	  AND COALESCE(A.ACC_NM,'') LIKE '%'||COALESCE(IN_ACC_NM,'')||'%'
	  AND COALESCE(A.ACC_CD,'') LIKE '%'||COALESCE(IN_ACC_CD,'')||'%'
	  AND COALESCE(A.JEUNGBING_DOC,'') LIKE '%'||COALESCE(IN_JEUNGBING_DOC,'')||'%'
	  AND COALESCE(A.MANAGE_ITEM_1,'') LIKE '%'||COALESCE(IN_MANAGE_ITEM,'')||'%'
	  AND COALESCE(A.ACC_CONT,'') LIKE '%'||COALESCE(IN_ACC_CONT,'')||'%'
	  AND COALESCE(A.DRCR_GB,'') LIKE  '%'||COALESCE(IN_DRCR_GB,'')||'%'
	  AND COALESCE(A.ACC_NO,'000') BETWEEN IN_FROM_ACC_NO AND IN_TO_ACC_NO
	  AND COALESCE(A.PRICE,0) = CAST(IN_PRICE as decimal(13,0))
	  ORDER BY A.DATE, A.ACC_NO, A.ROW_ID;--

    P1: BEGIN
         --DATA SELECT
        IF IN_PRICE = '0' OR IN_PRICE = '0.0' THEN
            OPEN CURSOR_ACC;--
        ELSE
        	OPEN CURSOR_ACC1;--
        END IF;        --

   END P1;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN0101_DRCR_SUM"
(IN IN_FROMDATE VARCHAR(10),
 IN IN_TODATE   VARCHAR(10),
 IN IN_ACCNO    VARCHAR(3),
 IN IN_USER_ID  VARCHAR(25))
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE SQLSTATE CHAR(5) DEFAULT '00000';--
    DECLARE   V_YEAR      VARCHAR(4) DEFAULT '';--
    DECLARE   V_MONTH     VARCHAR(2) DEFAULT '';--
    DECLARE   V_DAY       VARCHAR(2) DEFAULT '';--
    DECLARE   V_GISU      VARCHAR(3) DEFAULT '';--

    DECLARE   V_DR_TOT_AMT   DECIMAL(15,0) DEFAULT 0.0;--
    DECLARE   V_DR_DAE_AMT   DECIMAL(15,0) DEFAULT 0.0;--
    DECLARE   V_DR_AMT       DECIMAL(15,0) DEFAULT 0.0;--
    DECLARE   V_ACC_CD       VARCHAR(10) DEFAULT '';--
    DECLARE   V_ACC_NM       VARCHAR(60) DEFAULT '';--
    DECLARE   V_CR_AMT       DECIMAL(15,0) DEFAULT 0.0;--
    DECLARE   V_CR_DAE_AMT   DECIMAL(15,0) DEFAULT 0.0;--
    DECLARE   V_CR_TOT_AMT   DECIMAL(15,0) DEFAULT 0.0;--

    DECLARE   V_AFTER_AMT    DECIMAL(15,0) DEFAULT 0.0;--
    DECLARE   V_AFTER_DAY_DR_AMT DECIMAL(15,0) DEFAULT 0.0;--
    DECLARE   V_AFTER_DAY_CR_AMT DECIMAL(15,0) DEFAULT 0.0;--
    DECLARE   V_AFTER_ACC_DR_AMT DECIMAL(15,0) DEFAULT 0.0;--
    DECLARE   V_AFTER_ACC_CR_AMT DECIMAL(15,0) DEFAULT 0.0;--
    DECLARE   V_AFTER_DAY      VARCHAR(10) DEFAULT '';--
    DECLARE   V_BEFOR_AMT     DECIMAL(15,0) DEFAULT 0.0;--
    DECLARE   V_BEFOR_DR_AMT  DECIMAL(15,0) DEFAULT 0.0;--
    DECLARE   V_BEFOR_CR_AMT  DECIMAL(15,0) DEFAULT 0.0;--
    DECLARE   V_DR_00            DECIMAL(20,0) DEFAULT 0.0;--
    DECLARE   V_CR_00            DECIMAL(20,0) DEFAULT 0.0;--
    DECLARE   V_LASTDAY        VARCHAR(20)   DEFAULT '';--
    DECLARE   V_CASH_JANGO_AMT  DECIMAL(20,0) DEFAULT 0.0;--

    DECLARE GLOBAL TEMPORARY TABLE SESSION.TEMP
    (
        DR_TOT_AMT   DECIMAL(15,0),
        DR_DAE_AMT   DECIMAL(15,0),
        DR_AMT       DECIMAL(15,0),
        ACC_CD       VARCHAR(10),
        ACC_NM       VARCHAR(60),
        CR_AMT       DECIMAL(15,0),
        CR_DAE_AMT   DECIMAL(15,0),
        CR_TOT_AMT   DECIMAL(15,0)
    )  ON COMMIT PRESERVE ROWS
  WITH REPLACE
  NOT LOGGED;--


	SET V_YEAR = SUBSTR(IN_FROMDATE,1,4);--

    P1: BEGIN

		SELECT GISU INTO V_GISU
		  FROM GADMIN.BSACC9
		 WHERE START <= IN_FROMDATE
		   AND TERMINATION >= IN_TODATE;--

		IF ( IN_ACCNO = '' )  THEN
                --계정과목별 일계표내역
                INSERT INTO SESSION.TEMP
                SELECT A.* FROM (
                select coalesce(sum(dr_amt),0) as dr_total_amt, coalesce(sum(DR_AMT),0) as d_dr_amt, 0 as d_amt, ACC_cd, ACC_NM, 0 as c_amt, coalesce(sum(CR_AMT),0) as d_cr_amt, coalesce(sum(cr_amt),0) as cr_total_amt
                  from GADMIN.ACCOU1
                where DATE BETWEEN IN_FROMDATE AND IN_TODATE
                  and DRCR_GB IN ('차변','대변')
                  and ACC_NO LIKE IN_ACCNO||'%'
                group by ACC_cd, ACC_NM
                union all
                select coalesce(sum(dr_amt),0) as dr_total_amt, 0 as d_dr_amt, coalesce(SUM(DR_AMT),0) as d_amt, ACC_cd, ACC_NM,  coalesce(SUM(cr_amt),0) as c_amt, 0 as d_cr_amt, coalesce(sum(cr_amt),0) as cr_total_amt
                  from GADMIN.ACCOU1
                where DATE BETWEEN IN_FROMDATE AND IN_TODATE
                  and DRCR_GB IN ('입금','출금')
                  and ACC_NO LIKE IN_ACCNO||'%'
                group by ACC_cd, ACC_NM ) A
                ORDER BY ACC_CD;--
         ELSE
                --계정과목별 일계표내역
                INSERT INTO SESSION.TEMP
                SELECT A.* FROM (
                select coalesce(sum(dr_amt),0) as dr_total_amt, coalesce(sum(DR_AMT),0) as d_dr_amt, 0 as d_amt, ACC_cd, ACC_NM, 0 as c_amt, coalesce(sum(CR_AMT),0) as d_cr_amt, coalesce(sum(cr_amt),0) as cr_total_amt
                  from GADMIN.ACCOU1
                where DATE BETWEEN IN_FROMDATE AND IN_TODATE
                  and DRCR_GB IN ('차변','대변')
                  and ACC_NO = IN_ACCNO
                group by ACC_cd, ACC_NM
                union all
                select coalesce(sum(dr_amt),0) as dr_total_amt, 0 as d_dr_amt, coalesce(SUM(DR_AMT),0) as d_amt, ACC_cd, ACC_NM,  coalesce(SUM(cr_amt),0) as c_amt, 0 as d_cr_amt, coalesce(sum(cr_amt),0) as cr_total_amt
                  from GADMIN.ACCOU1
                where DATE BETWEEN IN_FROMDATE AND IN_TODATE
                  and DRCR_GB IN ('입금','출금')
                  and ACC_NO = IN_ACCNO
                group by ACC_cd, ACC_NM ) A
                ORDER BY ACC_CD;--

         END IF;--

		INSERT INTO SESSION.TEMP
		SELECT coalesce(SUM(DR_TOT_AMT),0), coalesce(SUM(DR_DAE_AMT),0), coalesce(SUM(DR_AMT),0), '', '집계',coalesce(SUM(CR_AMT),0), coalesce(SUM(CR_DAE_AMT),0), coalesce(SUM(CR_TOT_AMT),0)
		  FROM SESSION.TEMP;--

		--개수 찾기
		SELECT GISU INTO V_GISU
		  FROM GADMIN.BSACC9
		 WHERE START <= IN_FROMDATE
		   AND TERMINATION >= IN_TODATE;--

		--전월잔고(현금) 금액 계산 V_AFTER_DAY_DR_AMT
		SELECT DR_00, CR_00 INTO V_DR_00, V_CR_00
		  FROM GADMIN.HAPJAN
		 WHERE YEAR = V_GISU
		   AND ACC_CD = '1110101';--;--

		SET V_AFTER_DAY_DR_AMT = V_DR_00 - V_CR_00; --해당년도 전기이월 금액(현금)

        IF SUBSTRING(IN_FROMDATE,6,5) = '01-01' THEN
            --01-01 이면 전기 이월금액
        ELSE
            -- 조회기간의 TODATE 전날 구하기
            SELECT SUBSTRING(TO_DATE(IN_FROMDATE,'YYYY-MM-DD') - 1,1,10) INTO V_LASTDAY
              FROM SYSIBM.SYSDUMMY1;--

            -- 01-01부터 조회시작 전일까지 현금입출납금 계산  (전기이월 금액 + 입금 - 출금) : 합잔금액 사용 안함 - 전표 수정시 누락 우려 있음
            SELECT COALESCE(SUM(CR_AMT) - SUM(DR_AMT),0) + V_AFTER_DAY_DR_AMT INTO V_AFTER_DAY_DR_AMT
              FROM GADMIN.ACCOU1 A
             WHERE DATE BETWEEN SUBSTRING(IN_FROMDATE,1,4)||'-01-01' AND V_LASTDAY
                AND A.DRCR_GB IN ('입금','출금')
                ;--
        END IF;--

		--금월잔고(현금) 금액 계산 V_BEFOR_AMT
		/*
		SELECT DR_AMT , CR_AMT INTO V_DR_AMT, V_CR_AMT    --금월 현금 내역
		  FROM SESSION.TEMP
		 WHERE ACC_NM = '집계';--
		 */
		IF ( IN_ACCNO = '' )  THEN
             select coalesce(SUM(DR_AMT),0),  coalesce(SUM(cr_amt),0)  INTO V_DR_AMT, V_CR_AMT
               from GADMIN.ACCOU1
              where DATE BETWEEN IN_FROMDATE AND IN_TODATE
                and DRCR_GB IN ('입금','출금') ;--
        ELSE
             select coalesce(SUM(DR_AMT),0),  coalesce(SUM(cr_amt),0)  INTO V_DR_AMT, V_CR_AMT
               from GADMIN.ACCOU1
              where DATE BETWEEN IN_FROMDATE AND IN_TODATE
                and DRCR_GB IN ('입금','출금')
                and ACC_NO BETWEEN '001' AND IN_ACCNO
              --group by ACC_cd, ACC_NM
              ;--
        END IF;--

		SET V_CR_AMT = V_CR_AMT - V_DR_AMT; -- 입출금 합계 차액 계산
		SET V_CASH_JANGO_AMT = V_CR_AMT + V_AFTER_DAY_DR_AMT;-- 입출금 차액 + 전월이월금액

    END P1;--

    P2: BEGIN

		DECLARE CURSOR_TEMP CURSOR WITH RETURN FOR
		SELECT CR_AMT AS IN_AMT, DR_AMT AS OUT_AMT, V_CASH_JANGO_AMT AS JANGO, DR_DAE_AMT AS DR_AMT, CR_DAE_AMT AS CR_AMT
		  FROM SESSION.TEMP
		 WHERE ACC_NM = '집계' ;--

		OPEN CURSOR_TEMP;--
   END P2;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN0101_DRCR_SUM2"
(IN IN_FROMDATE VARCHAR(10),
 IN IN_TODATE   VARCHAR(10),
 IN IN_FROM_ACCNO    VARCHAR(3),
 IN IN_TO_ACCNO    VARCHAR(3),
 IN IN_USER_ID  VARCHAR(25))
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE SQLSTATE CHAR(5) DEFAULT '00000';--
    DECLARE   V_YEAR      VARCHAR(4) DEFAULT '';--
    DECLARE   V_MONTH     VARCHAR(2) DEFAULT '';--
    DECLARE   V_DAY       VARCHAR(2) DEFAULT '';--
    DECLARE   V_GISU      VARCHAR(3) DEFAULT '';--

    DECLARE   V_DR_TOT_AMT   DECIMAL(15,0) DEFAULT 0.0;--
    DECLARE   V_DR_DAE_AMT   DECIMAL(15,0) DEFAULT 0.0;--
    DECLARE   V_DR_AMT       DECIMAL(15,0) DEFAULT 0.0;--
    DECLARE   V_ACC_CD       VARCHAR(10) DEFAULT '';--
    DECLARE   V_ACC_NM       VARCHAR(60) DEFAULT '';--
    DECLARE   V_CR_AMT       DECIMAL(15,0) DEFAULT 0.0;--
    DECLARE   V_CR_DAE_AMT   DECIMAL(15,0) DEFAULT 0.0;--
    DECLARE   V_CR_TOT_AMT   DECIMAL(15,0) DEFAULT 0.0;--

    DECLARE   V_AFTER_AMT    DECIMAL(15,0) DEFAULT 0.0;--
    DECLARE   V_AFTER_DAY_DR_AMT DECIMAL(15,0) DEFAULT 0.0;--
    DECLARE   V_AFTER_DAY_CR_AMT DECIMAL(15,0) DEFAULT 0.0;--
    DECLARE   V_AFTER_ACC_DR_AMT DECIMAL(15,0) DEFAULT 0.0;--
    DECLARE   V_AFTER_ACC_CR_AMT DECIMAL(15,0) DEFAULT 0.0;--
    DECLARE   V_AFTER_DAY      VARCHAR(10) DEFAULT '';--
    DECLARE   V_BEFOR_AMT     DECIMAL(15,0) DEFAULT 0.0;--
    DECLARE   V_BEFOR_DR_AMT  DECIMAL(15,0) DEFAULT 0.0;--
    DECLARE   V_BEFOR_CR_AMT  DECIMAL(15,0) DEFAULT 0.0;--
    DECLARE   V_DR_00            DECIMAL(20,0) DEFAULT 0.0;--
    DECLARE   V_CR_00            DECIMAL(20,0) DEFAULT 0.0;--
    DECLARE   V_LASTDAY        VARCHAR(20)   DEFAULT '';--
    DECLARE   V_CASH_JANGO_AMT  DECIMAL(20,0) DEFAULT 0.0;--

    DECLARE GLOBAL TEMPORARY TABLE SESSION.TEMP
    (
        DR_TOT_AMT   DECIMAL(15,0),
        DR_DAE_AMT   DECIMAL(15,0),
        DR_AMT       DECIMAL(15,0),
        ACC_CD       VARCHAR(10),
        ACC_NM       VARCHAR(60),
        CR_AMT       DECIMAL(15,0),
        CR_DAE_AMT   DECIMAL(15,0),
        CR_TOT_AMT   DECIMAL(15,0)
    )  ON COMMIT PRESERVE ROWS
  WITH REPLACE
  NOT LOGGED;--


	SET V_YEAR = SUBSTR(IN_FROMDATE,1,4);--

    P1: BEGIN

		SELECT GISU INTO V_GISU
		  FROM GADMIN.BSACC9
		 WHERE START <= IN_FROMDATE
		   AND TERMINATION >= IN_TODATE;--

        --계정과목별 일계표내역
        INSERT INTO SESSION.TEMP
        SELECT A.* FROM (
        select coalesce(sum(dr_amt),0) as dr_total_amt, coalesce(sum(DR_AMT),0) as d_dr_amt, 0 as d_amt, ACC_cd, ACC_NM, 0 as c_amt, coalesce(sum(CR_AMT),0) as d_cr_amt, coalesce(sum(cr_amt),0) as cr_total_amt
          from GADMIN.ACCOU1
        where DATE BETWEEN IN_FROMDATE AND IN_TODATE
          and DRCR_GB IN ('차변','대변')
          and ACC_NO BETWEEN IN_FROM_ACCNO AND IN_TO_ACCNO
        group by ACC_cd, ACC_NM
        union all
        select coalesce(sum(dr_amt),0) as dr_total_amt, 0 as d_dr_amt, coalesce(SUM(DR_AMT),0) as d_amt, ACC_cd, ACC_NM,  coalesce(SUM(cr_amt),0) as c_amt, 0 as d_cr_amt, coalesce(sum(cr_amt),0) as cr_total_amt
          from GADMIN.ACCOU1
        where DATE BETWEEN IN_FROMDATE AND IN_TODATE
          and DRCR_GB IN ('입금','출금')
          and ACC_NO BETWEEN IN_FROM_ACCNO AND IN_TO_ACCNO
        group by ACC_cd, ACC_NM ) A
        ORDER BY ACC_CD;--

		INSERT INTO SESSION.TEMP
		SELECT coalesce(SUM(DR_TOT_AMT),0), coalesce(SUM(DR_DAE_AMT),0), coalesce(SUM(DR_AMT),0), '', '집계',coalesce(SUM(CR_AMT),0), coalesce(SUM(CR_DAE_AMT),0), coalesce(SUM(CR_TOT_AMT),0)
		  FROM SESSION.TEMP;--

		--개수 찾기
		SELECT GISU INTO V_GISU
		  FROM GADMIN.BSACC9
		 WHERE START <= IN_FROMDATE
		   AND TERMINATION >= IN_TODATE;--

		--전월잔고(현금) 금액 계산 V_AFTER_DAY_DR_AMT
		SELECT DR_00, CR_00 INTO V_DR_00, V_CR_00
		  FROM GADMIN.HAPJAN
		 WHERE YEAR = V_GISU
		   AND ACC_CD = '1110101';--;--

		SET V_AFTER_DAY_DR_AMT = V_DR_00 - V_CR_00; --해당년도 전기이월 금액(현금)

        IF SUBSTRING(IN_FROMDATE,6,5) = '01-01' THEN
            --01-01 이면 전기 이월금액
        ELSE
            -- 조회기간의 TODATE 전날 구하기
            SELECT SUBSTRING(TO_DATE(IN_FROMDATE,'YYYY-MM-DD') - 1,1,10) INTO V_LASTDAY
              FROM SYSIBM.SYSDUMMY1;--

            -- 01-01부터 조회시작 전일까지 현금입출납금 계산  (전기이월 금액 + 입금 - 출금) : 합잔금액 사용 안함 - 전표 수정시 누락 우려 있음
            SELECT COALESCE(SUM(CR_AMT) - SUM(DR_AMT),0) + V_AFTER_DAY_DR_AMT INTO V_AFTER_DAY_DR_AMT
              FROM GADMIN.ACCOU1 A
             WHERE DATE BETWEEN SUBSTRING(IN_FROMDATE,1,4)||'-01-01' AND V_LASTDAY
                AND A.DRCR_GB IN ('입금','출금')
                ;--
        END IF;--

		--금월잔고(현금) 금액 계산 V_BEFOR_AMT
		SELECT DR_AMT , CR_AMT INTO V_DR_AMT, V_CR_AMT    --금월 현금 내역
		  FROM SESSION.TEMP
		 WHERE ACC_NM = '집계';--

		SET V_CR_AMT = V_CR_AMT - V_DR_AMT; -- 입출금 합계 차액 계산
		SET V_CASH_JANGO_AMT = V_CR_AMT + V_AFTER_DAY_DR_AMT;-- 입출금 차액 + 전월이월금액

    END P1;--

    P2: BEGIN

		DECLARE CURSOR_TEMP CURSOR WITH RETURN FOR
		SELECT CR_AMT AS IN_AMT, DR_AMT AS OUT_AMT, V_CASH_JANGO_AMT AS JANGO, DR_DAE_AMT AS DR_AMT, CR_DAE_AMT AS CR_AMT
		  FROM SESSION.TEMP
		 WHERE ACC_NM = '집계' ;--

		OPEN CURSOR_TEMP;--
   END P2;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN0101_IN_CASH_PRINT"
(
    IN IN_FROMDATE VARCHAR(10)
  , IN IN_TODATE   VARCHAR(10)
  , IN IN_ACCNO    VARCHAR(3)
  , IN IN_USER_ID  VARCHAR(25)
)
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN
    DECLARE SQLSTATE CHAR(5) DEFAULT '00000';--

    DECLARE V_CNT INT DEFAULT 0;--
    DECLARE V_CNT_MAX INT DEFAULT 0;--
    DECLARE V_ROW INT DEFAULT 0;--
    DECLARE V_DATE VARCHAR(10) DEFAULT '';--
    DECLARE V_ACC_NO VARCHAR(3) DEFAULT '';--

    DECLARE GLOBAL TEMPORARY TABLE SESSION.TEMP
    (   ROWNUM      VARCHAR(4),
        DATE		DATE,
        ACC_NO		VARCHAR(4),
        DRCR_GB		VARCHAR(6),
        ACC_CD		VARCHAR(10),
        ACC_NM		VARCHAR(60),
        ACC_CONT	VARCHAR(300),
        PRICE		DECIMAL(13,0),
        MANAGE		VARCHAR(9),
        MANAGE_CD_1	VARCHAR(9),
        MANAGE_ITEM_1	VARCHAR(45),
        MANAGE_CD_2	VARCHAR(9),
        MANAGE_ITEM_2	VARCHAR(90),
        PURCH		VARCHAR(1),
        JEUNGBING_DOC	VARCHAR(15),
        ROW_ID		BIGINT,
        DR_AMT		DECIMAL(13,0),
        CR_AMT		DECIMAL(13,0)
     )  ON COMMIT PRESERVE ROWS
  WITH REPLACE
  NOT LOGGED;--

    P1: BEGIN
         --DATA SELECT
        INSERT INTO SESSION.TEMP ( SELECT VARCHAR_FORMAT(ROW_NUMBER() OVER(PARTITION BY DATE ORDER BY DATE, ACC_NO),'999') AS ROWNUM,
                                          DATE,
                                          ACC_NO,
                                          DRCR_GB,
                                          ACC_CD,
                                          ACC_NM,
                                          ACC_CONT,
                                          PRICE,
                                          MANAGE,
                                          MANAGE_CD_1,
                                          MANAGE_ITEM_1,
                                          MANAGE_CD_2,
                                          GADMIN.SF_STRINGSLENCUT(MANAGE_ITEM_2,22,'STRING') AS MANAGE_ITEM_2,
                                          PURCH,
                                          JEUNGBING_DOC,
                                          ROW_ID,
                                          DR_AMT,
                                          CR_AMT
                                     FROM GADMIN.ACCOU1
                                    WHERE DATE BETWEEN IN_FROMDATE AND IN_TODATE
                                      AND ACC_NO LIKE IN_ACCNO || '%'
                                      AND DRCR_GB IN ('입금'));--

   END P1;--

    P2: BEGIN
/*        DECLARE V_HDPAGE_ROW INTEGER DEFAULT 21;--
        DECLARE V_SEPAGE_ROW INTEGER DEFAULT 23;--
         FOR ACCOU_BLK AS SELECT DATE, MAX(ACC_NO) AS ACC_NO, COUNT(*) + ROUND((COUNT(DISTINCT DATE||ACC_NO)+2.0)/2.0) + CEILING(REAL(REAL(COUNT(*) - V_HDPAGE_ROW) / REAL(V_SEPAGE_ROW) )) AS CNT FROM SESSION.TEMP WHERE DATE BETWEEN IN_FROMDATE AND IN_TODATE AND DRCR_GB IN ('입금') GROUP BY DATE
        DO
        SET V_CNT = ACCOU_BLK.CNT;--
        SET V_DATE = ACCOU_BLK.DATE;--
        SET V_ACC_NO = ACCOU_BLK.ACC_NO;--

        IF  V_CNT <= V_HDPAGE_ROW THEN SET V_CNT_MAX = V_HDPAGE_ROW ; -- 첫번째 페이지가  Full 작거나 같으면
        ELSEIF (V_CNT > V_HDPAGE_ROW AND MOD((V_CNT - V_HDPAGE_ROW), V_SEPAGE_ROW) = 0 ) THEN  SET V_CNT_MAX = V_CNT ; -- 두번쨰 페이지 부터 Full페이지 이면
        ELSEIF (V_CNT > V_HDPAGE_ROW) THEN SET V_CNT_MAX = (CEILING(REAL(REAL(V_CNT - V_HDPAGE_ROW) / REAL(V_SEPAGE_ROW) )) * V_SEPAGE_ROW + V_HDPAGE_ROW);-- 두번쨰 페이지 부터 Full페이지가 아니면
        END IF;--

        SET V_ROW = V_CNT + 1;--
        WHILE (V_ROW <= V_CNT_MAX) DO
             INSERT INTO SESSION.TEMP VALUES ('ZZZ', V_DATE, V_ACC_NO, varchar_format(v_cnt,'000'), varchar_format(v_cnt,'000'), varchar_format(v_cnt,'000'), '', 0, '', '', '', '', '', '', '', 0, 0, 0);--
             SET V_ROW = V_ROW + 1;--
        END WHILE;--
        END FOR;--
*/

    END P2;--

    P3: BEGIN
        DECLARE CURSOR_ACC CURSOR WITH RETURN FOR
	     SELECT ROWNUM,
                DATE,
                ACC_NO,
                DRCR_GB,
                ACC_CD,
                ACC_NM,
                ACC_CONT,
                PRICE,
                MANAGE,
                MANAGE_CD_1,
                MANAGE_ITEM_1,
                MANAGE_CD_2,
                MANAGE_ITEM_2,
                PURCH,
                JEUNGBING_DOC,
                ROW_ID,
                DR_AMT,
                CR_AMT
	       FROM SESSION.TEMP
	      ORDER BY DATE, (CASE WHEN ACC_NO = '' THEN '999' ELSE ACC_NO END), COALESCE(ROWNUM,'99999')
	      ;--
	OPEN CURSOR_ACC ;--
   END P3;--


END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN0101_MOVECOPY"
(
      IN IN_JOB VARCHAR(1)
    , IN IN_ROW_ID VARCHAR(20)
    , IN IN_DATE  VARCHAR(10)
    , IN IN_ACC_NO VARCHAR(4)
    , IN IN_USER_ID VARCHAR(25)
)
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE SQLSTATE CHAR(5) DEFAULT '00000';--
    DECLARE V_ACC_NO BIGINT DEFAULT '000';--
    P1: BEGIN
        IF IN_JOB = '0' THEN  --전표이동

            UPDATE GADMIN.ACCOU1
                SET DATE = IN_DATE
                   , ACC_NO = IN_ACC_NO
                   , M_USER = IN_USER_ID
                   , M_DATE = NOW
            WHERE ROW_ID = IN_ROW_ID;--

        ELSEIF IN_JOB = '1' THEN  --전표복사

            SET V_ACC_NO = GADMIN.SF_FIN_ACC_ROW_ID();--

            INSERT INTO GADMIN.ACCOU1
                  (DATE, ACC_NO,    DRCR_GB, ACC_CD, ACC_NM, ACC_CONT, PRICE, MANAGE, MANAGE_CD_1, MANAGE_ITEM_1, MANAGE_CD_2, MANAGE_ITEM_2, PURCH, JEUNGBING_DOC, ROW_ID, C_USER, C_DATE, M_USER, M_DATE, DR_AMT, CR_AMT )
            SELECT IN_DATE, IN_ACC_NO, DRCR_GB, ACC_CD, ACC_NM, ACC_CONT, PRICE, MANAGE, MANAGE_CD_1, MANAGE_ITEM_1, MANAGE_CD_2, MANAGE_ITEM_2, PURCH, JEUNGBING_DOC, V_ACC_NO, IN_USER_ID, NOW, M_USER, M_DATE, DR_AMT, CR_AMT
              FROM GADMIN.ACCOU1
             WHERE ROW_ID = IN_ROW_ID;--

        END IF;--
   END P1;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN0101_OUT_CASH_PRINT"
(
    IN IN_FROMDATE VARCHAR(10) -- yyyymmdd 형식
  , IN IN_TODATE VARCHAR(10) -- yyyymmdd 형식
  , IN IN_ACCNO VARCHAR(3)
  , IN IN_USER_ID VARCHAR(25)  -- yyyymmdd 형식
)
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN
    DECLARE SQLSTATE CHAR(5) DEFAULT '00000';--

    DECLARE V_CNT INT DEFAULT 0;--
    DECLARE V_CNT_MAX INT DEFAULT 0;--
    DECLARE V_ROW INT DEFAULT 0;--
    DECLARE V_DATE VARCHAR(10) DEFAULT '';--
    DECLARE V_ACC_NO VARCHAR(3) DEFAULT '';--

    DECLARE GLOBAL TEMPORARY TABLE SESSION.TEMP
    (   ROWNUM      VARCHAR(4),
        DATE		DATE,
        ACC_NO		VARCHAR(4),
        DRCR_GB		VARCHAR(6),
        ACC_CD		VARCHAR(10),
        ACC_NM		VARCHAR(60),
        ACC_CONT	VARCHAR(300),
        PRICE		DECIMAL(13,0),
        MANAGE		VARCHAR(9),
        MANAGE_CD_1	VARCHAR(9),
        MANAGE_ITEM_1	VARCHAR(45),
        MANAGE_CD_2	VARCHAR(9),
        MANAGE_ITEM_2	VARCHAR(90),
        PURCH		VARCHAR(1),
        JEUNGBING_DOC	VARCHAR(15),
        ROW_ID		BIGINT,
        DR_AMT		DECIMAL(13,0),
        CR_AMT		DECIMAL(13,0)
     )  ON COMMIT PRESERVE ROWS
  WITH REPLACE
  NOT LOGGED;--

    P1: BEGIN
         --DATA SELECT
        INSERT INTO SESSION.TEMP ( SELECT VARCHAR_FORMAT(ROW_NUMBER() OVER(PARTITION BY DATE ORDER BY DATE, ACC_NO),'999') AS ROWNUM,
                                          DATE,
                                          ACC_NO,
                                          DRCR_GB,
                                          ACC_CD,
                                          ACC_NM,
                                          ACC_CONT,
                                          PRICE,
                                          MANAGE,
                                          MANAGE_CD_1,
                                          MANAGE_ITEM_1,
                                          MANAGE_CD_2,
                                          GADMIN.SF_STRINGSLENCUT(MANAGE_ITEM_2,22,'STRING') AS MANAGE_ITEM_2,
                                          PURCH,
                                          JEUNGBING_DOC,
                                          ROW_ID,
                                          DR_AMT,
                                          CR_AMT
                                     FROM GADMIN.ACCOU1
                                    WHERE DATE BETWEEN IN_FROMDATE AND IN_TODATE
                                      AND ACC_NO LIKE IN_ACCNO||'%'
                                      AND DRCR_GB IN ('출금'));--

   END P1;--

    P2: BEGIN
/*        DECLARE V_HDPAGE_ROW INTEGER DEFAULT 21;--
        DECLARE V_SEPAGE_ROW INTEGER DEFAULT 23;--
         FOR ACCOU_BLK AS SELECT DATE, MAX(ACC_NO) AS ACC_NO, COUNT(*) + ROUND((COUNT(DISTINCT DATE||ACC_NO)+2.0)/2.0) + CEILING(REAL(REAL(COUNT(*) - V_HDPAGE_ROW) / REAL(V_SEPAGE_ROW) )) AS CNT FROM SESSION.TEMP WHERE DATE BETWEEN IN_FROMDATE AND IN_TODATE AND DRCR_GB IN ('출금') GROUP BY DATE
        DO
        SET V_CNT = ACCOU_BLK.CNT;--
        SET V_DATE = ACCOU_BLK.DATE;--
        SET V_ACC_NO = ACCOU_BLK.ACC_NO;--

        IF  V_CNT <= V_HDPAGE_ROW THEN SET V_CNT_MAX = V_HDPAGE_ROW ; -- 첫번째 페이지가  Full 작거나 같으면
        ELSEIF (V_CNT > V_HDPAGE_ROW AND MOD((V_CNT - V_HDPAGE_ROW), V_SEPAGE_ROW) = 0 ) THEN  SET V_CNT_MAX = V_CNT ; -- 두번쨰 페이지 부터 Full페이지 이면
        ELSEIF (V_CNT > V_HDPAGE_ROW) THEN SET V_CNT_MAX = (CEILING(REAL(REAL(V_CNT - V_HDPAGE_ROW) / REAL(V_SEPAGE_ROW) )) * V_SEPAGE_ROW + V_HDPAGE_ROW);-- 두번쨰 페이지 부터 Full페이지가 아니면
        END IF;--

        SET V_ROW = V_CNT + 1;--
        WHILE (V_ROW <= V_CNT_MAX) DO
             INSERT INTO SESSION.TEMP VALUES ('ZZZ', V_DATE, V_ACC_NO, varchar_format(v_cnt,'000'), varchar_format(v_cnt,'000'), varchar_format(v_cnt,'000'), '', 0, '', '', '', '', '', '', '', 0, 0, 0);--
             SET V_ROW = V_ROW + 1;--
        END WHILE;--
        END FOR;--
*/
    END P2;--

    P3: BEGIN
        DECLARE CURSOR_ACC CURSOR WITH RETURN FOR
	     SELECT ROWNUM,
                DATE,
                ACC_NO,
                DRCR_GB,
                ACC_CD,
                ACC_NM,
                ACC_CONT,
                PRICE,
                MANAGE,
                MANAGE_CD_1,
                MANAGE_ITEM_1,
                MANAGE_CD_2,
                MANAGE_ITEM_2,
                PURCH,
                JEUNGBING_DOC,
                ROW_ID,
                DR_AMT,
                CR_AMT
	       FROM SESSION.TEMP
	      ORDER BY DATE, (CASE WHEN ACC_NO = '' THEN '999' ELSE ACC_NO END), COALESCE(ROWNUM,'99999')
	      ;--
	OPEN CURSOR_ACC ;--
   END P3;--


END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN0101_SELECT" (
    IN IN_DATE VARCHAR(10),
    IN IN_ACCNO VARCHAR(4),
    IN IN_USER_ID VARCHAR(25)
)
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL
MAIN: BEGIN
    DECLARE SQLSTATE CHAR(5) DEFAULT '00000';--

    /*
	DECLARE CURSOR_ACC1 CURSOR WITH RETURN FOR
	SELECT '' AS STATUS, '0' AS CK, ROWNUMBER() OVER() AS ROWNUM, A.* FROM GADMIN.ACCOU1 A
	WHERE DATE = IN_DATE;--
	*/

    DECLARE CURSOR_ACC1 CURSOR WITH RETURN FOR
	SELECT '' AS STATUS, '0' AS CK, ROWNUMBER() OVER() AS ROWNUM, A.*, COALESCE(B.GAP_AMT,0) AS GAP_AMT
	  FROM GADMIN.ACCOU1 A
	        LEFT OUTER JOIN
	        ( SELECT DATE, ACC_NO, COALESCE(SUM(DR_AMT),0) - COALESCE(SUM(CR_AMT),0) AS GAP_AMT
	            FROM GADMIN.ACCOU1
	           WHERE 1 = 1
	             AND DRCR_GB IN ('차변','대변')
	          GROUP BY DATE, ACC_NO
	         ) B  ON (A.DATE = B.DATE AND A.ACC_NO = B.ACC_NO)
	WHERE A.DATE = IN_DATE
	ORDER BY DATE, ACC_NO, ROW_ID;--

	DECLARE CURSOR_ACC2 CURSOR WITH RETURN FOR
	SELECT '' AS STATUS, '0' AS CK, ROWNUMBER() OVER() AS ROWNUM, A.*, COALESCE(B.GAP_AMT,0) AS GAP_AMT
	  FROM GADMIN.ACCOU1 A
	        LEFT OUTER JOIN
	        ( SELECT DATE, ACC_NO, COALESCE(SUM(DR_AMT),0) - COALESCE(SUM(CR_AMT),0) AS GAP_AMT
	            FROM GADMIN.ACCOU1
	           WHERE 1 = 1
	             AND DRCR_GB IN ('차변','대변')
	          GROUP BY DATE, ACC_NO
	         ) B  ON (A.DATE = B.DATE AND A.ACC_NO = B.ACC_NO)
	WHERE A.DATE = IN_DATE
	  AND A.ACC_NO = IN_ACCNO
	  ORDER BY DATE, ACC_NO, ROW_ID;--

    P1: BEGIN
        IF IN_ACCNO = '' OR IN_ACCNO = '000' OR IN_ACCNO = '0' THEN
            OPEN CURSOR_ACC1;--
        ELSE
            OPEN CURSOR_ACC2;--
	    END IF;--
   END P1;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN0101_TAB01_PRINT"
(
    IN IN_FROMDATE VARCHAR(10), -- yyyymmdd 형식
    IN IN_TODATE   VARCHAR(10),
    IN IN_ACCNO    VARCHAR(3),
    IN IN_USER_ID VARCHAR(25)
)
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN
    DECLARE SQLSTATE CHAR(5) DEFAULT '00000';--

    DECLARE V_CNT INT DEFAULT 0;--
    DECLARE V_CNT_MAX INT DEFAULT 0;--
    DECLARE V_ROW INT DEFAULT 0;--
    DECLARE V_DATE VARCHAR(10) DEFAULT '';--
    DECLARE V_ACC_NO VARCHAR(3) DEFAULT '';--

    DECLARE GLOBAL TEMPORARY TABLE SESSION.TEMP
    (   ROWNUM      VARCHAR(4),
        DATE		DATE,
        ACC_NO		VARCHAR(4),
        DRCR_GB		VARCHAR(6),
        ACC_CD		VARCHAR(10),
        ACC_NM		VARCHAR(60),
        ACC_CONT	VARCHAR(300),
        PRICE		DECIMAL(13,0),
        MANAGE		VARCHAR(9),
        MANAGE_CD_1	VARCHAR(9),
        MANAGE_ITEM_1	VARCHAR(45),
        MANAGE_CD_2	VARCHAR(9),
        MANAGE_ITEM_2	VARCHAR(90),
        PURCH		VARCHAR(1),
        JEUNGBING_DOC	VARCHAR(15),
        ROW_ID		BIGINT,
        DR_AMT		DECIMAL(13,0),
        CR_AMT		DECIMAL(13,0)
     )  ON COMMIT PRESERVE ROWS
  WITH REPLACE
  NOT LOGGED;--

    P1: BEGIN
         --DATA SELECT
        INSERT INTO SESSION.TEMP ( SELECT VARCHAR_FORMAT(ROW_NUMBER() OVER(PARTITION BY DATE ORDER BY DATE, ACC_NO),'999') AS ROWNUM,
                                          DATE,
                                          ACC_NO,
                                          DRCR_GB,
                                          ACC_CD,
                                          ACC_NM,
                                          ACC_CONT,
                                          PRICE,
                                          MANAGE,
                                          MANAGE_CD_1,
                                          MANAGE_ITEM_1,
                                          MANAGE_CD_2, GADMIN.SF_STRINGSLENCUT(MANAGE_ITEM_2,22,'STRING') AS MANAGE_ITEM_2,
                                          PURCH,
                                          JEUNGBING_DOC,
                                          ROW_ID,
                                          DR_AMT,
                                          CR_AMT
                                     FROM GADMIN.ACCOU1
                                    WHERE DATE BETWEEN IN_FROMDATE AND IN_TODATE
                                      AND ACC_NO LIKE IN_ACCNO ||'%'
                                      AND DRCR_GB IN ('차변','대변'));--

   END P1;--

    P2: BEGIN
/*        DECLARE V_HDPAGE_ROW INTEGER DEFAULT 21;--
        DECLARE V_SEPAGE_ROW INTEGER DEFAULT 23;--
         FOR ACCOU_BLK AS SELECT DATE, MAX(ACC_NO) AS ACC_NO, COUNT(*) + ROUND((COUNT(DISTINCT DATE||ACC_NO)+2.0)/2.0) + CEILING(REAL(REAL(COUNT(*) - V_HDPAGE_ROW) / REAL(V_SEPAGE_ROW) )) AS CNT FROM SESSION.TEMP WHERE DATE BETWEEN IN_FROMDATE AND IN_TODATE AND DRCR_GB IN ('차변','대변') GROUP BY DATE
        DO
        SET V_CNT = ACCOU_BLK.CNT;--
        SET V_DATE = ACCOU_BLK.DATE;--
        SET V_ACC_NO = ACCOU_BLK.ACC_NO;--

        IF  V_CNT <= V_HDPAGE_ROW THEN SET V_CNT_MAX = V_HDPAGE_ROW ; -- 첫번째 페이지가  Full 작거나 같으면
        ELSEIF (V_CNT > V_HDPAGE_ROW AND MOD((V_CNT - V_HDPAGE_ROW), V_SEPAGE_ROW) = 0 ) THEN  SET V_CNT_MAX = V_CNT ; -- 두번쨰 페이지 부터 Full페이지 이면
        ELSEIF (V_CNT > V_HDPAGE_ROW) THEN SET V_CNT_MAX = (CEILING(REAL(REAL(V_CNT - V_HDPAGE_ROW) / REAL(V_SEPAGE_ROW) )) * V_SEPAGE_ROW + V_HDPAGE_ROW);-- 두번쨰 페이지 부터 Full페이지가 아니면
        END IF;--

        SET V_ROW = V_CNT + 1;--
        WHILE (V_ROW <= V_CNT_MAX) DO
             INSERT INTO SESSION.TEMP VALUES ('ZZZ', V_DATE, V_ACC_NO, varchar_format(v_cnt,'000'), varchar_format(v_cnt,'000'), varchar_format(v_cnt,'000'), '', 0, '', '', '', '', '', '', '', 0, 0, 0);--
             SET V_ROW = V_ROW + 1;--
        END WHILE;--
        END FOR;--
*/

    END P2;--

    P3: BEGIN
        DECLARE CURSOR_ACC CURSOR WITH RETURN FOR
	     SELECT ROWNUM,
                DATE,
                ACC_NO,
                DRCR_GB,
                ACC_CD,
                ACC_NM,
                ACC_CONT,
                PRICE,
                MANAGE,
                MANAGE_CD_1,
                MANAGE_ITEM_1,
                MANAGE_CD_2,
                MANAGE_ITEM_2,
                PURCH,
                JEUNGBING_DOC,
                ROW_ID,
                DR_AMT,
                CR_AMT
	       FROM SESSION.TEMP
	      ORDER BY DATE, (CASE WHEN ACC_NO = '' THEN '999' ELSE ACC_NO END), COALESCE(ROWNUM,'99999')
	      ;--
	OPEN CURSOR_ACC ;--
   END P3;--


END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN0101_TAB01_PRINT_AAA"
(
    IN IN_FROMDATE VARCHAR(10), -- yyyymmdd 형식
    IN IN_TODATE   VARCHAR(10),
    IN IN_USER_ID VARCHAR(25)
)
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE SQLSTATE CHAR(5) DEFAULT '00000';--

    DECLARE V_CNT INT DEFAULT 0;--
    DECLARE V_CNT_MAX INT DEFAULT 0;--
    DECLARE V_ROW INT DEFAULT 0;--
    DECLARE V_DATE VARCHAR(10) DEFAULT '';--
    P1: BEGIN
         --DATA SELECT
        DECLARE P_QUERY_STRING VARCHAR(10000);--
        DECLARE CURSOR_ACC CURSOR WITH RETURN TO CLIENT FOR S1;--

        SELECT COUNT(*),MAX(DATE) INTO V_CNT, V_DATE
         FROM GADMIN.ACCOU1
        WHERE DATE BETWEEN IN_FROMDATE AND IN_TODATE
          AND DRCR_GB IN ('차변','대변');--

        IF (V_CNT <= 11) THEN SET V_CNT_MAX = V_CNT - 11;--
        ELSEIF (V_CNT > 11) THEN SET V_CNT_MAX = (CEILING((REAL(V_CNT) - 11) / 12 ) * 12 + 11)
        ;--
        END IF;--
        SET P_QUERY_STRING =
        'SELECT * FROM (
         SELECT ROWNUMBER() OVER() AS ROWNUM,
                DATE,
                ACC_NO,
                DRCR_GB,
                ACC_CD,
                ACC_NM,
                ACC_CONT,
                PRICE,
                MANAGE_CD_1,
                MANAGE_ITEM_1,
                MANAGE_CD_2,
                MANAGE_ITEM_2,
                JEUNGBING_DOC,
                ROW_ID,
                DR_AMT,
                CR_AMT
         FROM GADMIN.ACCOU1
        WHERE DATE BETWEEN '''||IN_FROMDATE||''' AND '''||IN_TODATE||'''
          AND DRCR_GB IN (''차변'',''대변'')';--
        SET V_ROW = V_CNT + 1;--
        WHILE (V_ROW <= V_CNT_MAX) DO
             SET P_QUERY_STRING = P_QUERY_STRING ||CHR(13)||'UNION ALL
             SELECT '''||V_ROW||''', '''||V_DATE||''',  '' '',  '' '',  '' '',  '' '',  '' '',  0,  '' '',  '' '',  '' '',  '' '',  '' '',  0,  0,  0 FROM SYSIBM.SYSDUMMY1';--
             SET V_ROW = V_ROW + 1;--
        END WHILE;--

        SET P_QUERY_STRING = P_QUERY_STRING ||CHR(13)||') ORDER BY DATE, (CASE WHEN ACC_NO = '''' THEN ''999'' ELSE ACC_NO END), ROWNUM';--


	    PREPARE S1 FROM P_QUERY_STRING;	 --
    	OPEN CURSOR_ACC;--
   END P1;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN0101_TAB01_PRINT_OLD"
(
    IN IN_DATE VARCHAR(10) -- yyyymmdd 형식
       , IN_USER_ID VARCHAR(25)  -- yyyymmdd 형식
)
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE SQLSTATE CHAR(5) DEFAULT '00000';--
    P1: BEGIN
         --DATA SELECT
		DECLARE CURSOR_ACC CURSOR WITH RETURN FOR
        SELECT ROWNUMBER() OVER() AS ROWNUM, * FROM GADMIN.ACCOU1
        WHERE DATE = IN_DATE
          AND DRCR_GB IN ('차변','대변');--
	OPEN CURSOR_ACC;--
   END P1;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN0101_TAB01_PRINT02"
(
    IN IN_FROMDATE VARCHAR(10), -- yyyymmdd 형식
    IN IN_TODATE   VARCHAR(10),
    IN IN_ACC_NM   VARCHAR(60),
    IN IN_ACC_CD   VARCHAR(10),
    IN IN_JEUNGBING_DOC  VARCHAR(15),
    IN IN_MANAGE_ITEM  VARCHAR(90),
    IN IN_MANAGE_CD  VARCHAR(9),
    IN IN_ACC_CONT  VARCHAR(300),
    IN IN_DRCR_GB  VARCHAR(6),
    IN IN_FROM_ACC_NO  VARCHAR(4),
    IN IN_TO_ACC_NO  VARCHAR(4),
    IN IN_PRICE  VARCHAR(13),
    IN IN_USER_ID VARCHAR(25)
)
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN
    DECLARE SQLSTATE CHAR(5) DEFAULT '00000';--

    DECLARE V_CNT INT DEFAULT 0;--
    DECLARE V_CNT_MAX INT DEFAULT 0;--
    DECLARE V_ROW INT DEFAULT 0;--
    DECLARE V_DATE VARCHAR(10) DEFAULT '';--

    P1: BEGIN
         --DATA SELECT
        DECLARE CURSOR_ACC CURSOR WITH RETURN FOR
        WITH ACC_LIST AS (
    	                   SELECT ROW_NUMBER() OVER(PARTITION BY DATE ORDER BY DATE, ACC_NO) AS ROWNUM,
                                  DATE,
                                  ACC_NO,
                                  DRCR_GB,
                                  ACC_CD,
                                  ACC_NM,
                                  ACC_CONT,
                                  PRICE,
                                  MANAGE,
                                  MANAGE_CD_1,
                                  MANAGE_ITEM_1,
                                  MANAGE_CD_2,
                                  MANAGE_ITEM_2,
                                  PURCH,
                                  JEUNGBING_DOC,
                                  ROW_ID,
                                  DR_AMT,
                                  CR_AMT
	                         FROM GADMIN.ACCOU1
	                        WHERE DATE BETWEEN IN_FROMDATE AND IN_TODATE),

	         ACC_SUM AS (
                       	  SELECT DATE,
                                 SUM(CASE WHEN DRCR_GB = '입금' THEN CR_AMT ELSE 0 END) AS SUM_IN,
                                 SUM(CASE WHEN DRCR_GB = '출금' THEN DR_AMT ELSE 0 END) AS SUM_OUT,
                                 SUM(CASE WHEN DRCR_GB = '차변' THEN DR_AMT ELSE 0 END) AS SUM_DR,
                                 SUM(CASE WHEN DRCR_GB = '대변' THEN CR_AMT ELSE 0 END) AS SUM_CR
                            FROM GADMIN.ACCOU1
                           WHERE DATE BETWEEN IN_FROMDATE AND IN_TODATE
           	               GROUP BY DATE),

	         ACC_TOT AS (
                       	  SELECT SUM(CASE WHEN DRCR_GB = '입금' THEN CR_AMT ELSE 0 END) AS TOT_IN,
                                 SUM(CASE WHEN DRCR_GB = '출금' THEN DR_AMT ELSE 0 END) AS TOT_OUT,
                                 SUM(CASE WHEN DRCR_GB = '차변' THEN DR_AMT ELSE 0 END) AS TOT_DR,
                                 SUM(CASE WHEN DRCR_GB = '대변' THEN CR_AMT ELSE 0 END) AS TOT_CR
                            FROM GADMIN.ACCOU1
                           WHERE DATE BETWEEN IN_FROMDATE AND IN_TODATE)

	     SELECT ROWNUM,
                VARCHAR_FORMAT(L.DATE,'YYYY-MM-DD') AS DATE,
                ACC_NO,
                DRCR_GB,
                ACC_CD,
                ACC_NM,
                ACC_CONT,
                PRICE,
                MANAGE,
                MANAGE_CD_1,
                MANAGE_ITEM_1,
                MANAGE_CD_2,
                MANAGE_ITEM_2,
                PURCH,
                JEUNGBING_DOC,
                ROW_ID,
                DR_AMT,
                CR_AMT,
                SUM_IN,
                SUM_OUT,
                SUM_DR,
                SUM_CR,
                TOT_IN,
                TOT_OUT,
                TOT_DR,
                TOT_CR
	       FROM ACC_LIST AS L
	       LEFT OUTER JOIN ACC_SUM AS S
	         ON L.DATE = S.DATE
	       LEFT OUTER JOIN ACC_TOT AS T
	         ON 1=1
	      WHERE L.DATE BETWEEN IN_FROMDATE AND IN_TODATE
	      /*
	        AND ACC_NM LIKE IN_ACC_NM
	        AND ACC_CD LIKE IN_ACC_CD
	        AND JEUNGBING_DOC LIKE IN_JEUNGBING_DOC
	        AND MANAGE_ITEM_1 LIKE IN_MANAGE_ITEM
	        AND MANAGE_CD_1 LIKE IN_MANAGE_CD
	        AND ACC_CONT LIKE IN_ACC_CONT
	        AND DRCR_GB LIKE IN_DRCR_GB
	        AND ACC_NO BETWEEN IN_FROM_ACC_NO AND IN_TO_ACC_NO
	        */
	        AND COALESCE(ACC_NM,'') LIKE '%'||COALESCE(IN_ACC_NM,'')||'%'
	        AND COALESCE(ACC_CD,'') LIKE '%'||COALESCE(IN_ACC_CD,'')||'%'
	        AND COALESCE(JEUNGBING_DOC,'') LIKE '%'||COALESCE(IN_JEUNGBING_DOC,'')||'%'
	        AND COALESCE(MANAGE_ITEM_1,'') LIKE '%'||COALESCE(IN_MANAGE_ITEM,'')||'%'
	        AND COALESCE(MANAGE_CD_1,'') LIKE '%'||COALESCE(IN_MANAGE_CD,'')||'%'
	        AND COALESCE(ACC_CONT,'') LIKE '%'||COALESCE(IN_ACC_CONT,'')||'%'
	        AND COALESCE(DRCR_GB,'') LIKE  '%'||COALESCE(IN_DRCR_GB,'')||'%'
	        AND ACC_NO BETWEEN IN_FROM_ACC_NO AND IN_TO_ACC_NO
	        AND PRICE LIKE IN_PRICE
	      ORDER BY L.DATE, ACC_NO, ROWNUM
	      ;--
	OPEN CURSOR_ACC ;--
   END P1;--


END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN0101_TAB01_PRINT02_OLD"
(
    IN IN_FROMDATE VARCHAR(10), -- yyyymmdd 형식
    IN IN_TODATE   VARCHAR(10),
    IN IN_USER_ID VARCHAR(25)
)
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN
    DECLARE SQLSTATE CHAR(5) DEFAULT '00000';--

    DECLARE V_CNT INT DEFAULT 0;--
    DECLARE V_CNT_MAX INT DEFAULT 0;--
    DECLARE V_ROW INT DEFAULT 0;--
    DECLARE V_DATE VARCHAR(10) DEFAULT '';--

    P1: BEGIN
         --DATA SELECT
        DECLARE CURSOR_ACC CURSOR WITH RETURN FOR
        WITH ACC_LIST AS (
    	                   SELECT ROW_NUMBER() OVER(PARTITION BY DATE ORDER BY DATE, ACC_NO) AS ROWNUM,
                                  DATE,
                                  ACC_NO,
                                  DRCR_GB,
                                  ACC_CD,
                                  ACC_NM,
                                  ACC_CONT,
                                  PRICE,
                                  MANAGE,
                                  MANAGE_CD_1,
                                  MANAGE_ITEM_1,
                                  MANAGE_CD_2,
                                  MANAGE_ITEM_2,
                                  PURCH,
                                  JEUNGBING_DOC,
                                  ROW_ID,
                                  DR_AMT,
                                  CR_AMT
	                         FROM GADMIN.ACCOU1
	                        WHERE DATE BETWEEN IN_FROMDATE AND IN_TODATE),

	         ACC_SUM AS (
                       	  SELECT DATE,
                                 SUM(CASE WHEN DRCR_GB = '입금' THEN CR_AMT ELSE 0 END) AS SUM_IN,
                                 SUM(CASE WHEN DRCR_GB = '출금' THEN DR_AMT ELSE 0 END) AS SUM_OUT,
                                 SUM(CASE WHEN DRCR_GB = '차변' THEN DR_AMT ELSE 0 END) AS SUM_DR,
                                 SUM(CASE WHEN DRCR_GB = '대변' THEN CR_AMT ELSE 0 END) AS SUM_CR
                            FROM GADMIN.ACCOU1
                           WHERE DATE BETWEEN IN_FROMDATE AND IN_TODATE
           	               GROUP BY DATE),

	         ACC_TOT AS (
                       	  SELECT SUM(CASE WHEN DRCR_GB = '입금' THEN CR_AMT ELSE 0 END) AS TOT_IN,
                                 SUM(CASE WHEN DRCR_GB = '출금' THEN DR_AMT ELSE 0 END) AS TOT_OUT,
                                 SUM(CASE WHEN DRCR_GB = '차변' THEN DR_AMT ELSE 0 END) AS TOT_DR,
                                 SUM(CASE WHEN DRCR_GB = '대변' THEN CR_AMT ELSE 0 END) AS TOT_CR
                            FROM GADMIN.ACCOU1
                           WHERE DATE BETWEEN IN_FROMDATE AND IN_TODATE)

	     SELECT ROWNUM,
                VARCHAR_FORMAT(L.DATE,'YYYY-MM-DD') AS DATE,
                ACC_NO,
                DRCR_GB,
                ACC_CD,
                ACC_NM,
                ACC_CONT,
                PRICE,
                MANAGE,
                MANAGE_CD_1,
                MANAGE_ITEM_1,
                MANAGE_CD_2,
                MANAGE_ITEM_2,
                PURCH,
                JEUNGBING_DOC,
                ROW_ID,
                DR_AMT,
                CR_AMT,
                SUM_IN,
                SUM_OUT,
                SUM_DR,
                SUM_CR,
                TOT_IN,
                TOT_OUT,
                TOT_DR,
                TOT_CR
	       FROM ACC_LIST AS L
	       LEFT OUTER JOIN ACC_SUM AS S
	         ON L.DATE = S.DATE
	       LEFT OUTER JOIN ACC_TOT AS T
	         ON 1=1
	      WHERE L.DATE BETWEEN IN_FROMDATE AND IN_TODATE
	      ORDER BY L.DATE, ACC_NO, ROWNUM
	      ;--
	OPEN CURSOR_ACC ;--
   END P1;--


END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN0101_TAB01_SELECT"
(
    IN IN_DATE VARCHAR(10) -- yyyymmdd 형식
       , IN_USER_ID VARCHAR(25)  -- yyyymmdd 형식
)
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE SQLSTATE CHAR(5) DEFAULT '00000';--
    P1: BEGIN
         --DATA SELECT
		DECLARE CURSOR_ACC CURSOR WITH RETURN FOR
        SELECT ROWNUMBER() OVER() AS ROWNUM, * FROM GADMIN.ACCOU1
        WHERE DATE = IN_DATE;--
	OPEN CURSOR_ACC;--
   END P1;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN0101_TAB02_SELECT"
(
      IN IN_FROMDATE VARCHAR(10) -- yyyymmdd 형식
    , IN IN_TODATE VARCHAR(10)
    , IN IN_USER_ID VARCHAR(25)  -- yyyymmdd 형식
)
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE SQLSTATE CHAR(5) DEFAULT '00000';--
    P1: BEGIN
         --DATA SELECT
		DECLARE CURSOR_ACC CURSOR WITH RETURN FOR
        SELECT '' AS CK, ROWNUMBER() OVER() AS ROWNUM, * FROM GADMIN.ACCOU1
        WHERE DATE BETWEEN IN_FROMDATE AND IN_TODATE;--
	OPEN CURSOR_ACC;--
   END P1;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN0101_UPDATE"
(
    IN IN_STATUS VARCHAR(10),
    IN IN_ROW_ID VARCHAR(20),
    IN IN_DATE VARCHAR(10),
    IN IN_ACC_NO VARCHAR(4),
    IN IN_DRCR_GB VARCHAR(6),
    IN IN_ACC_CD VARCHAR(10),
    IN IN_ACC_NM VARCHAR(60),
    IN IN_ACC_CONT VARCHAR(300),
    IN IN_PRICE VARCHAR(13),
    IN IN_JEUNGBING_DOC VARCHAR(15),
    IN IN_MANAGE_CD_1 VARCHAR(9),
    IN IN_MANAGE_ITEM_1 VARCHAR(45),
    IN IN_MANAGE_CD_2 VARCHAR(9),
    IN IN_MANAGE_ITEM_2 VARCHAR(90),
    IN IN_DR_AMT VARCHAR(13),
    IN IN_CR_AMT VARCHAR(13),
    IN IN_USER_ID VARCHAR(25)
)
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL
MAIN: BEGIN
    DECLARE SQLSTATE CHAR(5) DEFAULT '00000';--
    DECLARE   V_ROW_ID         BIGINT DEFAULT 0;--
    DECLARE   V_PRICE          DECIMAL(13,0) DEFAULT 0.0;--
    DECLARE   V_DR_AMT         DECIMAL(13,0) DEFAULT 0.0;--
    DECLARE   V_CR_AMT         DECIMAL(13,0) DEFAULT 0.0;--
    P1: BEGIN
        IF IN_ROW_ID = '' THEN
            SET IN_ROW_ID = '0';--
        END IF;--
        SET V_ROW_ID = CAST(IN_ROW_ID AS BIGINT);--
        SET V_PRICE = CAST(IN_PRICE AS DECIMAL(13,0));--
        SET V_DR_AMT = CAST(IN_DR_AMT AS DECIMAL(13,0));--
        SET V_CR_AMT = CAST(IN_CR_AMT AS DECIMAL(13,0));--
        IF IN_STATUS = '추가' THEN
            --추가
            SELECT COALESCE(MAX(ROW_ID),0) + 1  INTO V_ROW_ID
              FROM GADMIN.ACCOU1;--

            INSERT INTO GADMIN.ACCOU1 ( ROW_ID, DATE, ACC_NO, DRCR_GB, ACC_CD, ACC_NM, ACC_CONT, PRICE, JEUNGBING_DOC, MANAGE_CD_1, MANAGE_ITEM_1, MANAGE_CD_2, MANAGE_ITEM_2, DR_AMT, CR_AMT, C_USER, C_DATE, M_USER, M_DATE)
            VALUES( V_ROW_ID, IN_DATE, IN_ACC_NO, IN_DRCR_GB, IN_ACC_CD, IN_ACC_NM, IN_ACC_CONT, V_PRICE, IN_JEUNGBING_DOC, IN_MANAGE_CD_1, IN_MANAGE_ITEM_1, IN_MANAGE_CD_2, IN_MANAGE_ITEM_2, V_DR_AMT, V_CR_AMT, IN_USER_ID, NOW, NULL, NULL);--

        ELSEIF IN_STATUS = '수정' THEN
            --수정
            UPDATE GADMIN.ACCOU1
               SET DATE = IN_DATE,
                    ACC_NO = IN_ACC_NO,
                    DRCR_GB = IN_DRCR_GB,
                    ACC_CD = IN_ACC_CD,
                    ACC_NM = IN_ACC_NM,
                    ACC_CONT = IN_ACC_CONT,
                    PRICE = V_PRICE,
                    JEUNGBING_DOC = IN_JEUNGBING_DOC,
                    MANAGE_CD_1 = IN_MANAGE_CD_1,
                    MANAGE_ITEM_1 = IN_MANAGE_ITEM_1,
                    MANAGE_CD_2 = IN_MANAGE_CD_2,
                    MANAGE_ITEM_2 = IN_MANAGE_ITEM_2,
                    DR_AMT = V_DR_AMT,
                    CR_AMT = V_CR_AMT,
                    M_USER = IN_USER_ID,
                    M_DATE = NOW
              WHERE ROW_ID = V_ROW_ID;--

        ELSEIF IN_STATUS = '삭제' THEN
	        --삭제
	        DELETE GADMIN.ACCOU1
	         WHERE ROW_ID = V_ROW_ID;--

	    END IF;--

    END P1;--   END P1;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN0201_TAB1_SELECT"
(
    IN IN_FROMDATE VARCHAR(10), -- yyyy-mm-dd 형식
       IN_TODATE   VARCHAR(10),
       IN_USER_ID  VARCHAR(25)
)
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE SQLSTATE CHAR(5) DEFAULT '00000';--
    DECLARE   V_DATE           DATE;--
    DECLARE   V_SANGHO_CD      VARCHAR(21) DEFAULT '';--
    DECLARE   V_PRODUC_NM      VARCHAR(60) DEFAULT '';--
    DECLARE   V_CNT            INTEGER DEFAULT 0;--

--    DECLARE GLOBAL TEMPORARY TABLE SESSION.TEMP
--    (
--        SANGHO_CD  VARCHAR(9),
--        SANGHO     VARCHAR(45),
--        DATE       DATE,
--        PRODUC_NO  VARCHAR(21),
--        PRODUC_NM  VARCHAR(60),
--        SPEC       VARCHAR(30),
--        AMT        DECIMAL(12,2),
--        CLASS      VARCHAR(30)
--    )  ON COMMIT PRESERVE ROWS
--  WITH REPLACE
--  NOT LOGGED;--

    P1: BEGIN


	DECLARE C_JAGUMA1 CURSOR FOR
	SELECT DATE, SANGHO_CD
      FROM GADMIN.JAGUMA1
     WHERE DATE BETWEEN IN_FROMDATE AND IN_TODATE
	 GROUP BY DATE, SANGHO_CD;--
	 --ORDER BY DATE, SANGHO_CD;    --

    DELETE GADMIN.EBUS_FIN0201
     WHERE USER_ID = IN_USER_ID;--

       OPEN C_JAGUMA1;--

        FETCH FROM C_JAGUMA1 INTO V_DATE, V_SANGHO_CD;--
	    WHILE (SQLSTATE = '00000' )
	    DO
            -- 데이터 추가
            INSERT INTO GADMIN.EBUS_FIN0201(SANGHO_CD, SANGHO, DATE, PRODUC_NO, PRODUC_NM, SPEC, AMT, CLASS, USER_ID)   --SESSION.TEMP
            SELECT A.SANGHO_CD, A.SANGHO, A.DATE, A.PRODUC_NO, A.PRODUC_NM, B.SPEC, SUM(A.SUPPLY_PRICE) AS AMT, B.CLASS, IN_USER_ID
              FROM GADMIN.JAGUMA1 A
                       LEFT OUTER JOIN GADMIN.BSJAJA B ON ( A.PRODUC_NO = B.PRODUC_NO )
             WHERE A.DATE =  V_DATE
               AND A.SANGHO_CD = V_SANGHO_CD
            GROUP BY A.SANGHO_CD, A.SANGHO, A.DATE, A.PRODUC_NO, A.PRODUC_NM, B.SPEC, B.CLASS;--

             --소계 추가
           	SET V_CNT = 0;--

			SELECT COUNT(*) INTO V_CNT
              FROM (
	              SELECT A.SANGHO_CD, A.SANGHO, A.DATE, A.PRODUC_NO, A.PRODUC_NM, B.SPEC, SUM(A.SUPPLY_PRICE) AS AMT, B.CLASS
	              FROM GADMIN.JAGUMA1 A
	                       LEFT OUTER JOIN GADMIN.BSJAJA B ON ( A.PRODUC_NO = B.PRODUC_NO )
	             WHERE A.DATE =  V_DATE
	               AND A.SANGHO_CD = V_SANGHO_CD
	            GROUP BY A.SANGHO_CD, A.SANGHO, A.DATE, A.PRODUC_NO, A.PRODUC_NM, B.SPEC, B.CLASS);--

           	IF V_CNT > 1 THEN

                    --첫번째 품명 가져오기
                    SELECT A.PRODUC_NM INTO V_PRODUC_NM
                      FROM GADMIN.JAGUMA1 A
                     WHERE A.DATE = V_DATE
                       AND A.SANGHO_CD = V_SANGHO_CD
                      ORDER BY PRODUC_NO
                      FETCH FIRST 1 ROWS ONLY;--

                    -- 소계 저장 :다수
                    INSERT INTO GADMIN.EBUS_FIN0201(SANGHO_CD, SANGHO, DATE, PRODUC_NO, PRODUC_NM, SPEC, AMT, CLASS, USER_ID)  --SESSION.TEMP
                    SELECT A.SANGHO_CD, A.SANGHO, A.DATE, '소계' AS PRODUC_NO, V_PRODUC_NM || '외 ' || TO_CHAR(V_CNT - 1) || '건' AS PRODUC_NM, '' AS SPEC, SUM(A.SUPPLY_PRICE) AS AMT, '' AS CLASS, IN_USER_ID
                      FROM GADMIN.JAGUMA1 A
                     WHERE A.DATE = V_DATE
                       AND A.SANGHO_CD = V_SANGHO_CD
                    GROUP BY A.SANGHO_CD, A.SANGHO, A.DATE;--

                ELSE
                    -- 소계 저장 : 1건
                    INSERT INTO GADMIN.EBUS_FIN0201(SANGHO_CD, SANGHO, DATE, PRODUC_NO, PRODUC_NM, SPEC, AMT, CLASS, USER_ID) --SESSION.TEMP
                    SELECT A.SANGHO_CD, A.SANGHO, A.DATE, '소계' AS PRODUC_NO, A.PRODUC_NM, '' AS SPEC, SUM(A.SUPPLY_PRICE) AS AMT, '' AS CLASS, IN_USER_ID
                      FROM GADMIN.JAGUMA1 A
                     WHERE A.DATE = V_DATE
                       AND A.SANGHO_CD = V_SANGHO_CD
                    GROUP BY A.SANGHO_CD, A.SANGHO, A.DATE, A.PRODUC_NO, A.PRODUC_NM;--

                END IF;--
			FETCH FROM C_JAGUMA1 INTO V_DATE, V_SANGHO_CD;--
		END WHILE;--

        --합계 저장
        INSERT INTO GADMIN.EBUS_FIN0201(SANGHO_CD, SANGHO, DATE, PRODUC_NO, PRODUC_NM, SPEC, AMT, CLASS, USER_ID)  --SESSION.TEMP
        SELECT '합계' AS SANGHO_CD, '' AS SANGHO, TO_DATE(NULL) AS DATE, '' AS PRODUC_NO, '' AS PRODUC_NM, '' AS SPEC, SUM(A.SUPPLY_PRICE) AS AMT, '' AS CLASS, IN_USER_ID
          FROM GADMIN.JAGUMA1 A
         WHERE A.DATE BETWEEN IN_FROMDATE AND IN_TODATE; --

      CLOSE C_JAGUMA1;  --

    END P1;--

    P2: BEGIN

		DECLARE CURSOR_TEMP CURSOR WITH RETURN FOR
		SELECT *
		  FROM GADMIN.EBUS_FIN0201  --SESSION.TEMP
		 ORDER BY DATE, SANGHO_CD;--

		OPEN CURSOR_TEMP;--
    END P2;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN0201_UPDATE" (
    IN IN_DATE VARCHAR(10), -- yyyy-mm-dd 형식
       IN_USER_ID  VARCHAR(25)
)
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE SQLSTATE CHAR(5) DEFAULT '00000';--
    DECLARE   V_DATE           DATE;--
    DECLARE   V_ACC_NO         VARCHAR(10) DEFAULT '';--
    DECLARE   V_ACC_NM         VARCHAR(60) DEFAULT '';--
    DECLARE   V_DRCR_GB        VARCHAR(6) DEFAULT '';--
    DECLARE   V_ACC_CONT       VARCHAR(300) DEFAULT '';--
    DECLARE   V_DR_AMT         DECIMAL(15,5) DEFAULT 0.0;--
    DECLARE   V_CR_AMT         DECIMAL(15,5) DEFAULT 0.0;--
    DECLARE   V_MANAGE_CD_1    VARCHAR(9) DEFAULT '';--
    DECLARE   V_MANAGE_ITEM_1  VARCHAR(45) DEFAULT '';--
    DECLARE   V_USER_ID        VARCHAR(25) DEFAULT '';--
    DECLARE   V_ACC_NUM        INTEGER DEFAULT 0;--
    DECLARE   V_ROW_ID         BIGINT DEFAULT 0;--

    P1: BEGIN

	DECLARE C_EBUS_FIN0201_UPDATE CURSOR FOR
        SELECT DATE, ACC_NO, ACC_NM, DRCR_GB, ACC_CONT, DR_AMT, CR_AMT, MANAGE_CD_1, MANAGE_ITEM_1, USER_ID
          FROM GADMIN.EBUS_FIN0202
         WHERE USER_ID = IN_USER_ID;--

       OPEN C_EBUS_FIN0201_UPDATE;--

       -- 전표 번호 생성
       SELECT LPAD(TO_CHAR(TO_NUMBER(COALESCE(MAX(ACC_NO),'0')) + 1),3,'0') INTO V_ACC_NUM
         FROM GADMIN.ACCOU1
        WHERE DATE = IN_DATE;--

       -- ROW_ID 등록
       SELECT MAX(ROW_ID) + 1 INTO V_ROW_ID
         FROM GADMIN.ACCOU1;--

        FETCH FROM C_EBUS_FIN0201_UPDATE INTO V_DATE, V_ACC_NO, V_ACC_NM, V_DRCR_GB, V_ACC_CONT, V_DR_AMT, V_CR_AMT, V_MANAGE_CD_1, V_MANAGE_ITEM_1, V_USER_ID;--
	    WHILE (SQLSTATE = '00000' )
	    DO
	        IF V_DRCR_GB = '차변' THEN
                --차변 등록
                INSERT INTO GADMIN.ACCOU1(DATE, ACC_NO, DRCR_GB, ACC_CD, ACC_NM, ACC_CONT, PRICE, MANAGE, MANAGE_CD_1, MANAGE_ITEM_1, MANAGE_CD_2, MANAGE_ITEM_2, PURCH, JEUNGBING_DOC, ROW_ID, DR_AMT, CR_AMT, C_USER, C_DATE, M_USER, M_DATE)
                VALUES( VARCHAR_FORMAT(V_DATE,'YYYY-MM-DD HH24:MI:SS'), V_ACC_NUM, V_DRCR_GB, V_ACC_NO, V_ACC_NM, V_ACC_CONT, V_DR_AMT, '', V_MANAGE_CD_1, V_MANAGE_ITEM_1, '', '', '', '', V_ROW_ID, V_DR_AMT, V_CR_AMT, CURRENT TIMESTAMP, V_USER_ID, null, '');--
            ELSE
                --대변 등록
                INSERT INTO GADMIN.ACCOU1(DATE, ACC_NO, DRCR_GB, ACC_CD, ACC_NM, ACC_CONT, PRICE, MANAGE, MANAGE_CD_1, MANAGE_ITEM_1, MANAGE_CD_2, MANAGE_ITEM_2, PURCH, JEUNGBING_DOC, ROW_ID, DR_AMT, CR_AMT, C_USER, C_DATE, M_USER, M_DATE)
                VALUES(VARCHAR_FORMAT(V_DATE,'YYYY-MM-DD HH24:MI:SS'), V_ACC_NUM, V_DRCR_GB, V_ACC_NO, V_ACC_NM, V_ACC_CONT, V_CR_AMT, '', V_MANAGE_CD_1, V_MANAGE_ITEM_1, '', '', '', '', V_ROW_ID, V_DR_AMT, V_CR_AMT, CURRENT TIMESTAMP, V_USER_ID, null, '');--

               -- 전표 번호 생성
               SELECT LPAD(TO_CHAR(TO_NUMBER(COALESCE(MAX(ACC_NO),'0')) + 1),3,'0') INTO V_ACC_NUM
                 FROM GADMIN.ACCOU1
                WHERE DATE = V_DATE;--

            END IF;--
            -- ROW_ID 등록
            SELECT MAX(ROW_ID) + 1 INTO V_ROW_ID
             FROM GADMIN.ACCOU1;--

			FETCH FROM C_EBUS_FIN0201_UPDATE INTO V_DATE, V_ACC_NO, V_ACC_NM, V_DRCR_GB, V_ACC_CONT, V_DR_AMT, V_CR_AMT, V_MANAGE_CD_1, V_MANAGE_ITEM_1, V_USER_ID;--

        END WHILE;--

        CLOSE C_EBUS_FIN0201_UPDATE;  --

    END P1;--

END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN0301_TAB01_SELECT"
(
      IN IN_FROMDATE VARCHAR(10)
    , IN IN_TODATE  VARCHAR(10)
    , IN IN_USER_ID VARCHAR(25)
)
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE SQLSTATE CHAR(5) DEFAULT '00000';--
    P1: BEGIN
         --DATA SELECT
		DECLARE CURSOR_ACC CURSOR WITH RETURN FOR
        SELECT '' AS CK, ROWNUMBER() OVER() AS ROWNUM, * FROM GADMIN.ACCOU1
        WHERE DATE BETWEEN IN_FROMDATE AND IN_TODATE;--
	OPEN CURSOR_ACC;--
   END P1;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN0301_TAB02_MOVECOPY" (
      IN IN_JOB VARCHAR(1)
    , IN IN_ROW_ID VARCHAR(20)
    , IN IN_DATE  VARCHAR(10)
    , IN IN_ACC_NO VARCHAR(4)
    , IN IN_USER_ID VARCHAR(25)
)
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE SQLSTATE CHAR(5) DEFAULT '00000';--
    DECLARE V_ACC_NO BIGINT DEFAULT '000';--
    P1: BEGIN
--        SELECT LPAD(CAST(COALESCE(MAX(CAST(ACC_NO AS INTEGER)),0) + 1 AS VARCHAR),'3','0') INTO V_ACC_NO
--          FROM GADMIN.ACCOU1
--         WHERE 1 = 1
--           AND DATE = IN_DATE;--

        IF IN_JOB = '0' THEN  --전표이동

            UPDATE GADMIN.ACCOU1
                SET DATE = IN_DATE
                   , ACC_NO = IN_ACC_NO
                   , M_USER = IN_USER_ID
                   , M_DATE = NOW
            WHERE ROW_ID = IN_ROW_ID;--

        ELSEIF IN_JOB = '1' THEN  --전표복사

            SET V_ACC_NO = GADMIN.SF_FIN_ACC_ROW_ID();--

            INSERT INTO GADMIN.ACCOU1
                  (DATE, ACC_NO,    DRCR_GB, ACC_CD, ACC_NM, ACC_CONT, PRICE, MANAGE, MANAGE_CD_1, MANAGE_ITEM_1, MANAGE_CD_2, MANAGE_ITEM_2, PURCH, JEUNGBING_DOC, ROW_ID, C_USER, C_DATE, M_USER, M_DATE, DR_AMT, CR_AMT )
            SELECT IN_DATE, IN_ACC_NO, DRCR_GB, ACC_CD, ACC_NM, ACC_CONT, PRICE, MANAGE, MANAGE_CD_1, MANAGE_ITEM_1, MANAGE_CD_2, MANAGE_ITEM_2, PURCH, JEUNGBING_DOC, V_ACC_NO, IN_USER_ID, NOW, M_USER, M_DATE, DR_AMT, CR_AMT
              FROM GADMIN.ACCOU1
             WHERE ROW_ID = IN_ROW_ID;--

        END IF;--
   END P1;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN0401_TAB01_SELECT"
(IN IN_DATE VARCHAR(10), IN IN_USER_ID VARCHAR(25))
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE SQLSTATE CHAR(5) DEFAULT '00000';--
    DECLARE   V_YEAR      VARCHAR(4) DEFAULT '';--
    DECLARE   V_MONTH     VARCHAR(2) DEFAULT '';--
    DECLARE   V_DAY       VARCHAR(2) DEFAULT '';--
    DECLARE   V_GISU      VARCHAR(3) DEFAULT '';--

    DECLARE   V_DR_TOT_AMT   DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   V_DR_DAE_AMT   DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   V_DR_AMT       DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   V_ACC_CD       VARCHAR(10) DEFAULT '';--
    DECLARE   V_ACC_NM       VARCHAR(60) DEFAULT '';--
    DECLARE   V_CR_AMT       DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   V_CR_DAE_AMT   DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   V_CR_TOT_AMT   DECIMAL(20,5) DEFAULT 0.0;--

    DECLARE   V_AFTER_AMT    DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   V_AFTER_DAY_DR_AMT DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   V_AFTER_DAY_CR_AMT DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   V_AFTER_ACC_DR_AMT DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   V_AFTER_ACC_CR_AMT DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   V_AFTER_DAY      VARCHAR(10) DEFAULT '';--
    DECLARE   V_BEFOR_AMT     DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   V_BEFOR_DR_AMT  DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   V_BEFOR_CR_AMT  DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   V_DR_00            DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   V_CR_00            DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   V_LASTDAY        VARCHAR(20)   DEFAULT '';--

    DECLARE GLOBAL TEMPORARY TABLE SESSION.TEMP
    (
        DR_TOT_AMT   DECIMAL(20,5),
        DR_DAE_AMT   DECIMAL(20,5),
        DR_AMT       DECIMAL(20,5),
        ACC_CD       VARCHAR(10),
        ACC_NM       VARCHAR(60),
        CR_AMT       DECIMAL(20,5),
        CR_DAE_AMT   DECIMAL(20,5),
        CR_TOT_AMT   DECIMAL(20,5)
    )  ON COMMIT PRESERVE ROWS
  WITH REPLACE
  NOT LOGGED;--


	SET V_YEAR = SUBSTR(IN_DATE,1,4);--

    P1: BEGIN
		SET V_YEAR = SUBSTRING(IN_DATE,1,4);--
		SET V_MONTH = SUBSTRING(IN_DATE,6,2);--

		SELECT GISU INTO V_GISU
		  FROM GADMIN.BSACC9
		 WHERE START <= IN_DATE
		   AND TERMINATION >= IN_DATE;--

		--계정과목별 일계표내역
		INSERT INTO SESSION.TEMP
		SELECT sum(dr_total_amt) AS dr_total_amt, sum(d_dr_amt) AS d_dr_amt, sum(d_amt) AS d_amt, ACC_CD, ACC_NM, sum(c_amt) AS c_amt, sum(d_cr_amt) AS d_cr_amt, sum(cr_total_amt ) AS cr_total_amt
		  FROM (
		select sum(dr_amt) as dr_total_amt, sum(DR_AMT) as d_dr_amt, 0 as d_amt, ACC_cd, ACC_NM, 0 as c_amt, sum(CR_AMT) as d_cr_amt, sum(cr_amt) as cr_total_amt
		  from GADMIN.ACCOU1
		where DATE = IN_DATE
		  and DRCR_GB IN ('차변','대변')
		group by ACC_cd, ACC_NM
		union all
		select sum(dr_amt) as dr_total_amt, 0 as d_dr_amt, SUM(DR_AMT) as d_amt, ACC_cd, ACC_NM,  SUM(cr_amt) as c_amt, 0 as d_cr_amt, sum(cr_amt) as cr_total_amt
		  from GADMIN.ACCOU1
		where DATE = IN_DATE
		  and DRCR_GB IN ('입금','출금')
		group by ACC_cd, ACC_NM ) A
		GROUP BY ACC_CD, ACC_NM
		;--

		INSERT INTO SESSION.TEMP
		SELECT SUM(DR_TOT_AMT), SUM(DR_DAE_AMT), SUM(DR_AMT), '', '금일소계',SUM(CR_AMT), SUM(CR_DAE_AMT), SUM(CR_TOT_AMT)
		  FROM SESSION.TEMP;--

		--개수 찾기
		SELECT GISU INTO V_GISU
		  FROM GADMIN.BSACC9
		 WHERE START <= IN_DATE
		   AND TERMINATION >= IN_DATE;--

		--전월잔고(현금) 금액 계산 V_AFTER_DAY_DR_AMT
		SELECT DR_00, CR_00 INTO V_DR_00, V_CR_00
		  FROM GADMIN.HAPJAN
		 WHERE YEAR = V_GISU
		   AND ACC_CD = '1110101';--;--

		SET V_AFTER_DAY_DR_AMT = V_DR_00 - V_CR_00; --해당년도 전기이월 금액(현금)

        IF SUBSTRING(IN_DATE,6,5) = '01-01' THEN
            --01-01 이면 전기 이월금액
        ELSE
            -- 조회기간의 TODATE 전날 구하기
            SELECT SUBSTRING(TO_DATE(IN_DATE,'YYYY-MM-DD') - 1,1,10) INTO V_LASTDAY
              FROM SYSIBM.SYSDUMMY1;--

            -- 01-01부터 조회시작 전일까지 현금입출납금 계산  (전기이월 금액 + 입금 - 출금) : 합잔금액 사용 안함 - 전표 수정시 누락 우려 있음
            SELECT COALESCE(SUM(CR_AMT) - SUM(DR_AMT),0) + V_AFTER_DAY_DR_AMT INTO V_AFTER_DAY_DR_AMT
              FROM GADMIN.ACCOU1 A
             WHERE DATE BETWEEN SUBSTRING(IN_DATE,1,4)||'-01-01' AND V_LASTDAY
                AND A.DRCR_GB IN ('입금','출금');--
        END IF;--

		--SET V_AFTER_DAY_DR_AMT = V_DR_00 - V_CR_00; --해당년도 전기이월 금액(현금)

		--금월잔고(현금) 금액 계산 V_BEFOR_AMT
		SELECT DR_AMT , CR_AMT INTO V_DR_AMT, V_CR_AMT    --금월 현금 내역
		  FROM SESSION.TEMP
		 WHERE ACC_NM = '금일소계';--

		SET V_CR_AMT = V_CR_AMT - V_DR_AMT; -- 입출금 합계 차액 계산
		SET V_BEFOR_AMT = V_CR_AMT + V_AFTER_DAY_DR_AMT;-- 입출금 차액 + 전월이월금액

		 --금월잔고/전월잔고 저장
		INSERT INTO SESSION.TEMP
		SELECT V_BEFOR_AMT, 0, V_BEFOR_AMT , '', '금일잔고/전일잔고', V_AFTER_DAY_DR_AMT, 0, V_AFTER_DAY_DR_AMT
		  FROM SESSION.TEMP
		 WHERE ACC_NM = '금일소계'
		 ;--


		 -- 합계 계산
		INSERT INTO SESSION.TEMP
		SELECT SUM(DR_TOT_AMT), SUM(DR_DAE_AMT), SUM(DR_AMT), '', '합계', SUM(CR_AMT), SUM(CR_DAE_AMT), SUM(CR_TOT_AMT)
		  FROM SESSION.TEMP
		 WHERE ACC_NM IN ('금일소계','금일잔고/전일잔고');--

    END P1;--

    P2: BEGIN

		DECLARE CURSOR_TEMP CURSOR WITH RETURN FOR
		SELECT *
		  FROM SESSION.TEMP;--

		OPEN CURSOR_TEMP;--
   END P2;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN0401_TAB02_SELECT"
(IN IN_DATE VARCHAR(10), IN IN_ACC_CD VARCHAR(10), IN IN_USER_ID VARCHAR(25))
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE SQLSTATE CHAR(5) DEFAULT '00000';--

    DECLARE GLOBAL TEMPORARY TABLE SESSION.TEMP
    (
        DATE           VARCHAR(10),
        ACC_NO          VARCHAR(4),
        DRCR_GB         VARCHAR(6),
        ACC_CD          VARCHAR(10),
        ACC_NM          VARCHAR(60),
        ACC_CONT        VARCHAR(60),
        DR_AMT          DECIMAL(15,5),
        CR_AMT          DECIMAL(15,5),
        MANAGE_CD_1     VARCHAR(9),
        MANAGE_ITEM_1   VARCHAR(45),
        NAMAGE_CD_2     VARCHAR(9),
        MANAGE_ITEM_2   VARCHAR(90)
    )  ON COMMIT PRESERVE ROWS
  WITH REPLACE
  NOT LOGGED;--

    P1: BEGIN
         --DATA SELECT
		DECLARE CURSOR_ACC CURSOR WITH RETURN FOR
		SELECT A.DATE, A.ACC_NO, A.DRCR_GB, A.ACC_CD, A.ACC_NM, A.ACC_CONT, A.DR_AMT, A.CR_AMT, A.MANAGE_CD_1, A.MANAGE_ITEM_1, A.MANAGE_CD_1, A.MANAGE_ITEM_2
          FROM GADMIN.ACCOU1 A
         WHERE A.DATE = IN_DATE
           AND A.ACC_CD = IN_ACC_CD
         ORDER BY 1,2;--
	OPEN CURSOR_ACC;		--

    END P1;--

END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN0501_TAB02_PRINT"
(
    IN IN_FROMDATE VARCHAR(10),
    IN IN_TODATE   VARCHAR(10),
    IN IN_ACCCD    VARCHAR(10),
    IN IN_USER_ID VARCHAR(25)
)
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN
    DECLARE SQLSTATE CHAR(5) DEFAULT '00000';--

    DECLARE V_CNT INT DEFAULT 0;--

    DECLARE GLOBAL TEMPORARY TABLE SESSION.TEMP
    (
        ROW_NUM         BIGINT,
        DATE           VARCHAR(10),
        ACC_NO          VARCHAR(4),
        DRCR_GB         VARCHAR(6),
        ACC_CD          VARCHAR(10),
        ACC_NM          VARCHAR(60),
        ACC_CONT        VARCHAR(300),
        PRICE           DECIMAL(13,0),
        MANAGE          VARCHAR(9),
        MANAGE_CD_1     VARCHAR(9),
        MANAGE_ITEM_1   VARCHAR(45),
        MANAGE_CD_2     VARCHAR(9),
        MANAGE_ITEM_2   VARCHAR(90),
        PURCH           VARCHAR(1),
        JEUNGBING_DOC   VARCHAR(15),
        ROW_ID          BIGINT,
        DR_AMT          DECIMAL(13,0),
        CR_AMT          DECIMAL(13,0),
        SUM_IN          DECIMAL(13,0),
        SUM_OUT         DECIMAL(13,0),
        SUM_DR          DECIMAL(13,0),
        SUM_CR          DECIMAL(13,0),
        TOT_IN          DECIMAL(13,0),
        TOT_OUT         DECIMAL(13,0),
        TOT_DR          DECIMAL(13,0),
        TOT_CR          DECIMAL(13,0)
    )  ON COMMIT PRESERVE ROWS
      WITH REPLACE
      NOT LOGGED;--

    P1: BEGIN

        SELECT COUNT(*) INTO V_CNT FROM TABLE(GADMIN.SF_FIN_LEVELUP_TO_ACC(IN_ACCCD));--

        IF V_CNT < 1 THEN
               INSERT INTO SESSION.TEMP
                WITH ACC_LIST AS (
                                   SELECT ROW_NUMBER() OVER(PARTITION BY DATE ORDER BY DATE, ACC_NO) AS ROWNUM,
                                          DATE,
                                          ACC_NO,
                                          DRCR_GB,
                                          ACC_CD,
                                          ACC_NM,
                                          ACC_CONT,
                                          PRICE,
                                          MANAGE,
                                          MANAGE_CD_1,
                                          MANAGE_ITEM_1,
                                          MANAGE_CD_2,
                                          MANAGE_ITEM_2,
                                          PURCH,
                                          JEUNGBING_DOC,
                                          ROW_ID,
                                          DR_AMT,
                                          CR_AMT
                                     FROM GADMIN.ACCOU1
                                    WHERE DATE BETWEEN IN_FROMDATE AND IN_TODATE),

                     ACC_SUM AS (
                                  SELECT DATE,
                                         SUM(CASE WHEN DRCR_GB = '입금' THEN CR_AMT ELSE 0 END) AS SUM_IN,
                                         SUM(CASE WHEN DRCR_GB = '출금' THEN DR_AMT ELSE 0 END) AS SUM_OUT,
                                         SUM(CASE WHEN DRCR_GB = '차변' THEN DR_AMT ELSE 0 END) AS SUM_DR,
                                         SUM(CASE WHEN DRCR_GB = '대변' THEN CR_AMT ELSE 0 END) AS SUM_CR
                                    FROM GADMIN.ACCOU1
                                   WHERE DATE BETWEEN IN_FROMDATE AND IN_TODATE
                                   GROUP BY DATE),

                     ACC_TOT AS (
                                  SELECT SUM(CASE WHEN DRCR_GB = '입금' THEN CR_AMT ELSE 0 END) AS TOT_IN,
                                         SUM(CASE WHEN DRCR_GB = '출금' THEN DR_AMT ELSE 0 END) AS TOT_OUT,
                                         SUM(CASE WHEN DRCR_GB = '차변' THEN DR_AMT ELSE 0 END) AS TOT_DR,
                                         SUM(CASE WHEN DRCR_GB = '대변' THEN CR_AMT ELSE 0 END) AS TOT_CR
                                    FROM GADMIN.ACCOU1
                                   WHERE DATE BETWEEN IN_FROMDATE AND IN_TODATE)
                 SELECT ROWNUM,
                        VARCHAR_FORMAT(L.DATE,'YYYY-MM-DD') AS DATE,
                        ACC_NO,
                        DRCR_GB,
                        ACC_CD,
                        ACC_NM,
                        ACC_CONT,
                        PRICE,
                        MANAGE,
                        MANAGE_CD_1,
                        MANAGE_ITEM_1,
                        MANAGE_CD_2,
                        MANAGE_ITEM_2,
                        PURCH,
                        JEUNGBING_DOC,
                        ROW_ID,
                        DR_AMT,
                        CR_AMT,
                        SUM_IN,
                        SUM_OUT,
                        SUM_DR,
                        SUM_CR,
                        TOT_IN,
                        TOT_OUT,
                        TOT_DR,
                        TOT_CR
                   FROM ACC_LIST AS L
                   LEFT OUTER JOIN ACC_SUM AS S
                     ON L.DATE = S.DATE
                   LEFT OUTER JOIN ACC_TOT AS T
                     ON 1=1
                  WHERE L.DATE BETWEEN IN_FROMDATE AND IN_TODATE
                    AND L.ACC_CD LIKE IN_ACCCD
                  ORDER BY L.DATE, ACC_NO, ROWNUM
                  ;--
    ELSE
                INSERT INTO SESSION.TEMP
                WITH ACC_LIST AS (
                                   SELECT ROW_NUMBER() OVER(PARTITION BY DATE ORDER BY DATE, ACC_NO) AS ROWNUM,
                                          DATE,
                                          ACC_NO,
                                          DRCR_GB,
                                          ACC_CD,
                                          ACC_NM,
                                          ACC_CONT,
                                          PRICE,
                                          MANAGE,
                                          MANAGE_CD_1,
                                          MANAGE_ITEM_1,
                                          MANAGE_CD_2,
                                          MANAGE_ITEM_2,
                                          PURCH,
                                          JEUNGBING_DOC,
                                          ROW_ID,
                                          DR_AMT,
                                          CR_AMT
                                     FROM GADMIN.ACCOU1
                                    WHERE DATE BETWEEN IN_FROMDATE AND IN_TODATE),

                     ACC_SUM AS (
                                  SELECT DATE,
                                         SUM(CASE WHEN DRCR_GB = '입금' THEN CR_AMT ELSE 0 END) AS SUM_IN,
                                         SUM(CASE WHEN DRCR_GB = '출금' THEN DR_AMT ELSE 0 END) AS SUM_OUT,
                                         SUM(CASE WHEN DRCR_GB = '차변' THEN DR_AMT ELSE 0 END) AS SUM_DR,
                                         SUM(CASE WHEN DRCR_GB = '대변' THEN CR_AMT ELSE 0 END) AS SUM_CR
                                    FROM GADMIN.ACCOU1
                                   WHERE DATE BETWEEN IN_FROMDATE AND IN_TODATE
                                   GROUP BY DATE),

                     ACC_TOT AS (
                                  SELECT SUM(CASE WHEN DRCR_GB = '입금' THEN CR_AMT ELSE 0 END) AS TOT_IN,
                                         SUM(CASE WHEN DRCR_GB = '출금' THEN DR_AMT ELSE 0 END) AS TOT_OUT,
                                         SUM(CASE WHEN DRCR_GB = '차변' THEN DR_AMT ELSE 0 END) AS TOT_DR,
                                         SUM(CASE WHEN DRCR_GB = '대변' THEN CR_AMT ELSE 0 END) AS TOT_CR
                                    FROM GADMIN.ACCOU1
                                   WHERE DATE BETWEEN IN_FROMDATE AND IN_TODATE)
                 SELECT ROWNUM,
                        VARCHAR_FORMAT(L.DATE,'YYYY-MM-DD') AS DATE,
                        ACC_NO,
                        L.DRCR_GB,
                        L.ACC_CD,
                        L.ACC_NM,
                        ACC_CONT,
                        PRICE,
                        MANAGE,
                        MANAGE_CD_1,
                        MANAGE_ITEM_1,
                        MANAGE_CD_2,
                        MANAGE_ITEM_2,
                        PURCH,
                        JEUNGBING_DOC,
                        ROW_ID,
                        DR_AMT,
                        CR_AMT,
                        SUM_IN,
                        SUM_OUT,
                        SUM_DR,
                        SUM_CR,
                        TOT_IN,
                        TOT_OUT,
                        TOT_DR,
                        TOT_CR
                   FROM ACC_LIST AS L
                   INNER JOIN TABLE(GADMIN.SF_FIN_LEVELUP_TO_ACC(IN_ACCCD)) B ON (L.ACC_CD = B.ACC_CD)
                   LEFT OUTER JOIN ACC_SUM AS S
                     ON L.DATE = S.DATE
                   LEFT OUTER JOIN ACC_TOT AS T
                     ON 1=1
                  WHERE L.DATE BETWEEN IN_FROMDATE AND IN_TODATE
                  ORDER BY L.DATE, ACC_NO, ROWNUM
                  ;--
    END IF;--
   END P1;--

   P2: BEGIN

            DECLARE CURSOR_TEMP CURSOR WITH RETURN FOR
            SELECT * FROM SESSION.TEMP
            ;--

            OPEN CURSOR_TEMP;--

   END P2;--

END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN0501_TAB02_SELECT"
(IN IN_FROMDATE VARCHAR(10), IN IN_TODATE VARCHAR(10), IN IN_ACC_CD VARCHAR(10), IN IN_USER_ID VARCHAR(25))
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE   V_CNT             INTEGER DEFAULT 0;--

    DECLARE GLOBAL TEMPORARY TABLE SESSION.TEMP
    (
        DATE           DATE,
        ACC_NO          VARCHAR(4),
        DRCR_GB         VARCHAR(6),
        ACC_CD          VARCHAR(10),
        ACC_NM          VARCHAR(60),
        ACC_CONT        VARCHAR(300),
        DR_AMT          DECIMAL(13,0),
        CR_AMT          DECIMAL(13,0),
        MANAGE_CD_1     VARCHAR(9),
        MANAGE_ITEM_1   VARCHAR(45),
        MANAGE_CD_2     VARCHAR(9),
        MANAGE_ITEM_2   VARCHAR(90)
    )  ON COMMIT PRESERVE ROWS
  WITH REPLACE
  NOT LOGGED;--

  P1: BEGIN

        SELECT COUNT(*) INTO V_CNT FROM TABLE(GADMIN.SF_FIN_LEVELUP_TO_ACC(IN_ACC_CD));--

        IF V_CNT < 1 THEN

            INSERT INTO SESSION.TEMP
            SELECT A.DATE, A.ACC_NO, A.DRCR_GB, A.ACC_CD, A.ACC_NM, A.ACC_CONT, A.DR_AMT, A.CR_AMT, A.MANAGE_CD_1, A.MANAGE_ITEM_1, A.MANAGE_CD_2, A.MANAGE_ITEM_2
              FROM GADMIN.ACCOU1 A
             WHERE A.DATE BETWEEN IN_FROMDATE AND IN_TODATE
               AND A.ACC_CD LIKE IN_ACC_CD
             ORDER BY 1,2;--

        ELSE

            INSERT INTO SESSION.TEMP
            SELECT A.DATE, A.ACC_NO, A.DRCR_GB, A.ACC_CD, A.ACC_NM, A.ACC_CONT, A.DR_AMT, A.CR_AMT, A.MANAGE_CD_1, A.MANAGE_ITEM_1, A.MANAGE_CD_2, A.MANAGE_ITEM_2
              FROM GADMIN.ACCOU1 A,  TABLE(GADMIN.SF_FIN_LEVELUP_TO_ACC(IN_ACC_CD)) B
             WHERE 1 = 1
               AND A.DATE BETWEEN IN_FROMDATE AND IN_TODATE
               AND A.ACC_CD = B.ACC_CD
              -- AND A.ACC_CD LIKE IN_ACC_CD
             ORDER BY 1,2;--

        END IF; --
 END P1;--

 P2: BEGIN

        DECLARE CURSOR_TEMP CURSOR WITH RETURN FOR
        SELECT * FROM SESSION.TEMP
        ;--

        OPEN CURSOR_TEMP;--

END P2;--

END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN0601_TAB02_SELECT" (IN IN_FROMDATE
VARCHAR(10), IN IN_TODATE VARCHAR(10), IN IN_ACC_CD VARCHAR(10), IN IN_USER_ID
VARCHAR(25))
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE SQLSTATE CHAR(5) DEFAULT '00000';--

    DECLARE GLOBAL TEMPORARY TABLE SESSION.TEMP
    (
        DATE           VARCHAR(10),
        ACC_NO          VARCHAR(4),
        DRCR_GB         VARCHAR(6),
        ACC_CD          VARCHAR(10),
        ACC_NM          VARCHAR(60),
        ACC_CONT        VARCHAR(60),
        DR_AMT          DECIMAL(15,5),
        CR_AMT          DECIMAL(15,5),
        MANAGE_CD_1     VARCHAR(9),
        MANAGE_ITEM_1   VARCHAR(45),
        NAMAGE_CD_2     VARCHAR(9),
        MANAGE_ITEM_2   VARCHAR(90)
    )  ON COMMIT PRESERVE ROWS
  WITH REPLACE
  NOT LOGGED;--

    P1: BEGIN
         --DATA SELECT
      DECLARE CURSOR_ACC CURSOR WITH RETURN FOR
      SELECT * FROM (
      SELECT VARCHAR_FORMAT(A.DATE, 'YYYY-MM-DD') AS DATE, A.ACC_NO, A.DRCR_GB, A.ACC_CD, A.ACC_NM, A.ACC_CONT, A.CR_AMT AS IN_AMT, A.DR_AMT AS OUT_AMT, A.MANAGE_CD_1, A.MANAGE_ITEM_1, A.MANAGE_CD_1, A.MANAGE_ITEM_2
          FROM GADMIN.ACCOU1 A
         WHERE A.DATE BETWEEN IN_FROMDATE AND IN_TODATE
           AND A.ACC_CD LIKE IN_ACC_CD||'%'
           AND DRCR_GB IN ('입금','출금')
         ORDER BY 1,2)

         ;--
   OPEN CURSOR_ACC;      --

    END P1;--

END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN0701_TAB01_PRINT"
(IN IN_FROMDATE VARCHAR(10), IN IN_TODATE VARCHAR(10), IN IN_USER_ID VARCHAR(25))
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE   SQLSTATE         CHAR(5) DEFAULT '00000';--
    DECLARE   V_LAST_DAY        VARCHAR(10) DEFAULT ''; --
    DECLARE   V_YEAR            VARCHAR(4) DEFAULT '';--
    DECLARE   V_MONTH           VARCHAR(2) DEFAULT '';--
    DECLARE   V_DAY             VARCHAR(10)   DEFAULT '';--
    DECLARE   V_GISU            VARCHAR(3) DEFAULT '';--
    DECLARE   V_CUR_ACC_CD      VARCHAR(10)   DEFAULT '';--
    DECLARE   V_CUR_ACC_NM      VARCHAR(60)   DEFAULT '';--
    DECLARE   V_CUR_DRCR_GB     VARCHAR(6)   DEFAULT '';--

    DECLARE   V_YIWOL_AMT       DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   V_JAN_TOT_AMT     DECIMAL(20,5) DEFAULT 0.0;--

    DECLARE   V_DATE            VARCHAR(10)   DEFAULT '';--
    DECLARE   V_ACC_NO          VARCHAR(4)    DEFAULT '';--
    DECLARE   V_ACC_CD          VARCHAR(10)   DEFAULT '';--
    DECLARE   V_ACC_NM          VARCHAR(60)   DEFAULT '';--
    DECLARE   V_ACC_CONT        VARCHAR(300)  DEFAULT '';--
    DECLARE   V_IN_AMT          DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   V_OUT_AMT         DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   V_JAN_AMT         DECIMAL(20,5) DEFAULT 0.0;--

    DECLARE   V_DR_00           DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   V_CR_00           DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   V_DR_AMT          DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   V_CR_AMT          DECIMAL(20,5) DEFAULT 0.0;--

    DECLARE GLOBAL TEMPORARY TABLE SESSION.TEMP
    (
        DATE           VARCHAR(10),
        ACC_CD          VARCHAR(10),
        ACC_NM          VARCHAR(60),
        ACC_CONT        VARCHAR(300),
        DR_AMT          DECIMAL(20,5),
        CR_AMT          DECIMAL(20,5),
        JAN_AMT         DECIMAL(20,5)
    )  ON COMMIT PRESERVE ROWS
  WITH REPLACE
  NOT LOGGED;--

--개수 찾기
SELECT GISU INTO V_GISU
  FROM GADMIN.BSACC9
 WHERE START <= IN_FROMDATE
   AND TERMINATION >= IN_TODATE;--


    SET V_MONTH = SUBSTRING(IN_FROMDATE,6,2);		   --

    SELECT SUBSTRING(TO_DATE(IN_FROMDATE,'YYYY-MM-DD') - 1,1,10) INTO V_LAST_DAY
      FROM SYSIBM.SYSDUMMY1;--

P1: BEGIN

    DECLARE C_CHONGGAE CURSOR FOR
    SELECT A.ACC_CD, A.ACC_NM, B.DRCR_GB
      FROM GADMIN.HAPJAN A
            INNER JOIN
            ( SELECT ACC_CD, ACC_NM, DRCR_GB
                FROM GADMIN.BSACC2
               WHERE 1 = 1
                 --AND ACC_INPUT = 'Y'
                 AND HAPJAN_DISP != 'N'
                 ) B ON ( A.ACC_CD = B.ACC_CD )
     WHERE YEAR = V_GISU
    ORDER BY ACC_CD;--

    OPEN C_CHONGGAE;--

    FETCH FROM C_CHONGGAE INTO V_CUR_ACC_CD, V_CUR_ACC_NM, V_CUR_DRCR_GB;--

    SET V_DAY = V_DATE;--

    WHILE (SQLSTATE = '00000' )
    DO


    --전월이월 금액 찾기
    SELECT COALESCE(DR_00, 0), COALESCE(CR_00, 0) INTO V_DR_00, V_CR_00
      FROM GADMIN.HAPJAN A
            LEFT OUTER JOIN GADMIN.BSACC2 B ON (A.ACC_CD = B.ACC_CD)
     WHERE YEAR = V_GISU
       AND A.ACC_CD = V_CUR_ACC_CD
       AND B.ACC_GB IN ('자산','부채','자본');--

    IF SUBSTRING(IN_FROMDATE, 6, 5) = '01-01' THEN
        SET V_DR_AMT = V_DR_00 + 0;--
        SET V_CR_AMT = V_CR_00 + 0;--
    ELSE
            IF V_CUR_ACC_CD = '1110101' THEN
                 SELECT COALESCE(SUM(CR_AMT),0) + COALESCE(V_DR_00, 0), COALESCE(SUM(DR_AMT),0) + COALESCE(V_CR_00, 0) INTO V_DR_AMT, V_CR_AMT
                   FROM GADMIN.ACCOU1
                  WHERE 1 = 1
                    AND DRCR_GB IN ('입금','출금')
                    AND DATE BETWEEN SUBSTRING(IN_FROMDATE,1,4)||'-01-01' AND V_LAST_DAY
                 ;--
            ELSE
                 SELECT COALESCE(SUM(DR_AMT),0) + COALESCE(V_DR_00, 0), COALESCE(SUM(CR_AMT),0) + COALESCE(V_CR_00, 0) INTO V_DR_AMT, V_CR_AMT
                   FROM GADMIN.ACCOU1
                  WHERE 1 = 1
                    AND DATE BETWEEN SUBSTRING(IN_FROMDATE,1,4)||'-01-01' AND V_LAST_DAY
                    AND ACC_CD = V_CUR_ACC_CD;--
            END IF;--
    END IF; --

	IF V_CUR_DRCR_GB = '차변' THEN
    	SET V_YIWOL_AMT = V_DR_AMT - V_CR_AMT;--

        IF V_CUR_ACC_CD = '1110101' THEN
            --차변계정 현금
            INSERT INTO SESSION.TEMP
            SELECT DATE, ACC_CD, ACC_NM, ACC_CONT, DR_AMT, CR_AMT, SUM(DR_AMT - CR_AMT) OVER(ORDER BY DATE) FROM
            (
                      SELECT IN_FROMDATE AS DATE, 000 AS ROW_ID,  V_CUR_ACC_CD AS ACC_CD, V_CUR_ACC_NM AS ACC_NM, '전기이월' AS ACC_CONT, V_YIWOL_AMT AS DR_AMT, 0 AS CR_AMT, V_YIWOL_AMT AS JAN_AMT
                        FROM SYSIBM.SYSDUMMY1
                      UNION ALL
                      SELECT VARCHAR_FORMAT(A.DATE, 'YYYY-MM-DD') AS DATE, MAX(B.ROW_ID) AS ROW_ID, V_CUR_ACC_CD AS ACC_CD, V_CUR_ACC_NM AS ACC_NM, '일계표에서' AS ACC_CONT, SUM(CR_AMT) AS DR_AMT, SUM(DR_AMT) AS CR_AMT, SUM(DR_AMT - CR_AMT) AS JAN_AMT
                        FROM GADMIN.ACCOU1 A,
                            (
                                SELECT B.DATE, C.ROW_ID, B.ACC_CONT FROM GADMIN.ACCOU1 B,
                                    ( SELECT DATE, MAX(ACC_NO) AS ACC_NO, MAX(ROW_ID) AS ROW_ID  FROM GADMIN.ACCOU1 WHERE DRCR_GB IN ('입금','출금')  AND DATE BETWEEN IN_FROMDATE AND IN_TODATE GROUP BY DATE  ) C
                                 WHERE B.DRCR_GB IN ('입금','출금')
                                   AND B.DATE = C.DATE
                                   AND B.ROW_ID = C.ROW_ID
                             ) B
                      WHERE A.DRCR_GB IN ('입금','출금')
                         AND A.DATE BETWEEN IN_FROMDATE AND IN_TODATE
                         AND A.DATE = B.DATE
                    GROUP BY VARCHAR_FORMAT(A.DATE, 'YYYY-MM-DD')
                    ORDER BY DATE, ROW_ID
            ) A;--
        ELSE
            --차변계정 현금이외
    	    SET V_YIWOL_AMT = V_DR_AMT - V_CR_AMT;--

            INSERT INTO SESSION.TEMP
            SELECT DATE, ACC_CD, ACC_NM, ACC_CONT, DR_AMT, CR_AMT, SUM(DR_AMT - CR_AMT) OVER(ORDER BY DATE) FROM
            (
                      SELECT IN_FROMDATE AS DATE, 000 AS ROW_ID,  V_CUR_ACC_CD AS ACC_CD, V_CUR_ACC_NM AS ACC_NM, '전기이월' AS ACC_CONT, V_YIWOL_AMT AS DR_AMT, 0 AS CR_AMT, V_YIWOL_AMT AS JAN_AMT
                        FROM SYSIBM.SYSDUMMY1
                      UNION ALL
--                      SELECT VARCHAR_FORMAT(A.DATE, 'YYYY-MM-DD') AS DATE, MAX(B.ROW_ID) AS ROW_ID, V_CUR_ACC_CD AS ACC_CD, V_CUR_ACC_NM AS ACC_NM, MAX(B.ACC_CONT) AS ACC_CONT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, SUM(CR_AMT - DR_AMT) AS JAN_AMT
                      SELECT VARCHAR_FORMAT(A.DATE, 'YYYY-MM-DD') AS DATE, MAX(B.ROW_ID) AS ROW_ID, V_CUR_ACC_CD AS ACC_CD, V_CUR_ACC_NM AS ACC_NM, '일계표에서' AS ACC_CONT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, SUM(DR_AMT - CR_AMT) AS JAN_AMT
                        FROM GADMIN.ACCOU1 A,
                            (
                                SELECT B.DATE, C.ROW_ID, B.ACC_CONT FROM GADMIN.ACCOU1 B,
                                    ( SELECT DATE, MAX(ACC_NO) AS ACC_NO, MAX(ROW_ID) AS ROW_ID
                                        FROM GADMIN.ACCOU1
                                       WHERE  ACC_CD = V_CUR_ACC_CD
                                         AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                                         GROUP BY DATE  ) C
                                 WHERE B.ACC_CD = V_CUR_ACC_CD
                                   AND B.DATE = C.DATE
                                   AND B.ROW_ID = C.ROW_ID
                             ) B
                      WHERE  A.ACC_CD = V_CUR_ACC_CD
                         AND A.DATE BETWEEN IN_FROMDATE AND IN_TODATE
                         AND A.DATE = B.DATE
                    GROUP BY VARCHAR_FORMAT(A.DATE, 'YYYY-MM-DD')
                    ORDER BY DATE, ROW_ID
            ) A;--
        END IF;--

    ELSE
        --대변 계정
    	SET V_YIWOL_AMT = V_CR_AMT - V_DR_AMT;--

    	INSERT INTO SESSION.TEMP
        SELECT DATE, ACC_CD, ACC_NM, ACC_CONT, DR_AMT, CR_AMT, SUM(CR_AMT - DR_AMT) OVER(ORDER BY DATE) FROM
        (
                  SELECT IN_FROMDATE AS DATE, 000 AS ROW_ID,  V_CUR_ACC_CD AS ACC_CD, V_CUR_ACC_NM AS ACC_NM, '전기이월' AS ACC_CONT, 0 AS DR_AMT, V_YIWOL_AMT AS CR_AMT, V_YIWOL_AMT AS JAN_AMT
                    FROM SYSIBM.SYSDUMMY1
                  UNION ALL
                  SELECT VARCHAR_FORMAT(A.DATE, 'YYYY-MM-DD') AS DATE, MAX(B.ROW_ID) AS ROW_ID, V_CUR_ACC_CD AS ACC_CD, V_CUR_ACC_NM AS ACC_NM, '일계표에서' AS ACC_CONT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, SUM(CR_AMT - DR_AMT) AS JAN_AMT
                    FROM GADMIN.ACCOU1 A,
                        (
                            SELECT B.DATE, C.ROW_ID, B.ACC_CONT FROM GADMIN.ACCOU1 B,
                                ( SELECT DATE, MAX(ACC_NO) AS ACC_NO, MAX(ROW_ID) AS ROW_ID
                                    FROM GADMIN.ACCOU1
                                   WHERE  ACC_CD = V_CUR_ACC_CD
                                     AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                                     GROUP BY DATE  ) C
                             WHERE B.ACC_CD = V_CUR_ACC_CD
                               AND B.DATE = C.DATE
                               AND B.ROW_ID = C.ROW_ID
                         ) B
                  WHERE  A.ACC_CD = V_CUR_ACC_CD
                     AND A.DATE BETWEEN IN_FROMDATE AND IN_TODATE
                     AND A.DATE = B.DATE
                GROUP BY VARCHAR_FORMAT(A.DATE, 'YYYY-MM-DD')
                ORDER BY DATE, ROW_ID
        ) A;--

    END IF;	   --

    INSERT INTO SESSION.TEMP
    SELECT '' AS DATE, ACC_CD, '' AS ACC_NM, '월계' AS ACC_CONT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, NULL AS JAN_AMT
       FROM SESSION.TEMP
      WHERE ACC_CD = V_CUR_ACC_CD
      GROUP BY ACC_CD;--

    IF V_CUR_DRCR_GB = '차변' THEN
        IF V_CUR_ACC_CD = '1110101' THEN   --현금
             INSERT INTO SESSION.TEMP
             SELECT '' AS DATE, '1110101' AS ACC_CD, '' AS ACC_NM, '누계' AS ACC_CONT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, SUM(JAN_AMT) AS JAN_AMT
               FROM (
                         SELECT '' AS DATE, '1110101' AS ACC_CD, '' AS ACC_NM, '누계' AS ACC_CONT, V_CR_00 AS DR_AMT, V_DR_00 AS CR_AMT, (V_CR_00 + V_DR_00) AS JAN_AMT
                           FROM SYSIBM.SYSDUMMY1
                         UNION ALL
                         SELECT '' AS DATE, '1110101' AS ACC_CD, '' AS ACC_NM, '누계' AS ACC_CONT, SUM(CR_AMT) AS DR_AMT, SUM(DR_AMT) AS CR_AMT, SUM(CR_AMT - DR_AMT) AS JAN_AMT
                           FROM GADMIN.ACCOU1
                          WHERE 1 = 1
                            AND DRCR_GB IN ('입금','출금')
                            AND DATE BETWEEN SUBSTRING(IN_FROMDATE,1,4)||'-01-01' AND IN_TODATE )
             ;--
        ELSE
             INSERT INTO SESSION.TEMP
             SELECT '' AS DATE, V_CUR_ACC_CD AS ACC_CD, '' AS ACC_NM, '누계' AS ACC_CONT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, SUM(JAN_AMT) AS JAN_AMT
               FROM (
                         SELECT '' AS DATE, V_CUR_ACC_CD AS ACC_CD, '' AS ACC_NM, '누계' AS ACC_CONT, V_DR_00 AS DR_AMT, V_CR_00 AS CR_AMT, (V_DR_00 + V_CR_00) AS JAN_AMT
                           FROM SYSIBM.SYSDUMMY1
                         UNION ALL
                         SELECT '' AS DATE, ACC_CD, '' AS ACC_NM, '누계' AS ACC_CONT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, SUM(DR_AMT - CR_AMT)  AS JAN_AMT
                           FROM GADMIN.ACCOU1
                          WHERE 1 = 1
                            AND DATE BETWEEN SUBSTRING(IN_FROMDATE,1,4)||'-01-01' AND IN_TODATE
                            AND ACC_CD = V_CUR_ACC_CD
                          GROUP BY ACC_CD )
              ;--
        END IF;--
    ELSE
             INSERT INTO SESSION.TEMP
             SELECT '' AS DATE, V_CUR_ACC_CD AS ACC_CD, '' AS ACC_NM, '누계' AS ACC_CONT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, SUM(JAN_AMT) AS JAN_AMT
               FROM (
                         SELECT '' AS DATE, V_CUR_ACC_CD AS ACC_CD, '' AS ACC_NM, '누계' AS ACC_CONT, V_DR_00 AS DR_AMT, V_CR_00 AS CR_AMT, (V_DR_00 + V_CR_00) AS JAN_AMT
                           FROM SYSIBM.SYSDUMMY1
                         UNION ALL
                         SELECT '' AS DATE, ACC_CD, '' AS ACC_NM, '누계' AS ACC_CONT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, SUM(CR_AMT - DR_AMT) AS JAN_AMT
                           FROM GADMIN.ACCOU1
                          WHERE 1 = 1
                            AND DATE BETWEEN SUBSTRING(IN_FROMDATE,1,4)||'-01-01' AND IN_TODATE
                            AND ACC_CD = V_CUR_ACC_CD
                         GROUP BY ACC_CD )
             ;--
    END IF;--

    FETCH FROM C_CHONGGAE INTO V_CUR_ACC_CD, V_CUR_ACC_NM, V_CUR_DRCR_GB;--

    END WHILE;--

    CLOSE C_CHONGGAE;--

END P1;--

P2: BEGIN

    DECLARE CURSOR_TEMP CURSOR WITH RETURN FOR
    SELECT DATE, ACC_CD, ACC_NM, ACC_CONT, DR_AMT, CR_AMT, JAN_AMT
      FROM SESSION.TEMP
     WHERE NOT( DR_AMT = 0 AND CR_AMT = 0 );--

    OPEN CURSOR_TEMP;--
END P2;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN0701_TAB01_SELECT"
(IN IN_FROMDATE VARCHAR(10), IN IN_TODATE VARCHAR(10), IN IN_USER_ID VARCHAR(25))
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE   SQLSTATE         CHAR(5) DEFAULT '00000';--
    DECLARE   V_LAST_DAY        VARCHAR(10) DEFAULT ''; --
    DECLARE   V_YEAR            VARCHAR(4) DEFAULT '';--
    DECLARE   V_MONTH           VARCHAR(2) DEFAULT '';--
    DECLARE   V_DAY             VARCHAR(10)   DEFAULT '';--
    DECLARE   V_GISU            VARCHAR(3) DEFAULT '';--
    DECLARE   V_CUR_ACC_CD      VARCHAR(10)   DEFAULT '';--
    DECLARE   V_CUR_ACC_NM      VARCHAR(60)   DEFAULT '';--
    DECLARE   V_CUR_DRCR_GB     VARCHAR(6)   DEFAULT '';--

    DECLARE   V_YIWOL_AMT       DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   V_JAN_TOT_AMT     DECIMAL(20,5) DEFAULT 0.0;--

    DECLARE   V_DATE            VARCHAR(10)   DEFAULT '';--
    DECLARE   V_ACC_NO          VARCHAR(4)    DEFAULT '';--
    DECLARE   V_ACC_CD          VARCHAR(10)   DEFAULT '';--
    DECLARE   V_ACC_NM          VARCHAR(60)   DEFAULT '';--
    DECLARE   V_ACC_CONT        VARCHAR(300)  DEFAULT '';--
    DECLARE   V_IN_AMT          DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   V_OUT_AMT         DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   V_JAN_AMT         DECIMAL(20,5) DEFAULT 0.0;--

    DECLARE   V_DR_00           DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   V_CR_00           DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   V_DR_AMT          DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   V_CR_AMT          DECIMAL(20,5) DEFAULT 0.0;--

    DECLARE GLOBAL TEMPORARY TABLE SESSION.TEMP
    (
        DATE           VARCHAR(10),
        ACC_CD          VARCHAR(10),
        ACC_NM          VARCHAR(60),
        ACC_CONT        VARCHAR(300),
        DR_AMT          DECIMAL(20,5),
        CR_AMT          DECIMAL(20,5),
        JAN_AMT         DECIMAL(20,5)
    )  ON COMMIT PRESERVE ROWS
  WITH REPLACE
  NOT LOGGED;--

--개수 찾기
SELECT GISU INTO V_GISU
  FROM GADMIN.BSACC9
 WHERE START <= IN_FROMDATE
   AND TERMINATION >= IN_TODATE;--


    SET V_MONTH = SUBSTRING(IN_FROMDATE,6,2);		   --

    SELECT SUBSTRING(TO_DATE(IN_FROMDATE,'YYYY-MM-DD') - 1,1,10) INTO V_LAST_DAY
      FROM SYSIBM.SYSDUMMY1;--

P1: BEGIN

    DECLARE C_CHONGGAE CURSOR FOR
    SELECT A.ACC_CD, A.ACC_NM, B.DRCR_GB
      FROM GADMIN.HAPJAN A
            INNER JOIN
            ( SELECT ACC_CD, ACC_NM, DRCR_GB
                FROM GADMIN.BSACC2
               WHERE 1 = 1
                 --AND ACC_INPUT = 'Y'
                 AND HAPJAN_DISP != 'N'
                 ) B ON ( A.ACC_CD = B.ACC_CD )
     WHERE YEAR = V_GISU
    ORDER BY ACC_CD;--

    OPEN C_CHONGGAE;--

    FETCH FROM C_CHONGGAE INTO V_CUR_ACC_CD, V_CUR_ACC_NM, V_CUR_DRCR_GB;--

    SET V_DAY = V_DATE;--

    WHILE (SQLSTATE = '00000' )
    DO


    --전월이월 금액 찾기
    SELECT COALESCE(DR_00, 0), COALESCE(CR_00, 0) INTO V_DR_00, V_CR_00
      FROM GADMIN.HAPJAN A
            LEFT OUTER JOIN GADMIN.BSACC2 B ON (A.ACC_CD = B.ACC_CD)
     WHERE YEAR = V_GISU
       AND A.ACC_CD = V_CUR_ACC_CD
       AND B.ACC_GB IN ('자산','부채','자본');--

    IF SUBSTRING(IN_FROMDATE, 6, 5) = '01-01' THEN
        SET V_DR_AMT = V_DR_00 + 0;--
        SET V_CR_AMT = V_CR_00 + 0;--
    ELSE
            IF V_CUR_ACC_CD = '1110101' THEN
                 SELECT COALESCE(SUM(CR_AMT),0) + COALESCE(V_DR_00, 0), COALESCE(SUM(DR_AMT),0) + COALESCE(V_CR_00, 0) INTO V_DR_AMT, V_CR_AMT
                   FROM GADMIN.ACCOU1
                  WHERE 1 = 1
                    AND DRCR_GB IN ('입금','출금')
                    AND DATE BETWEEN SUBSTRING(IN_FROMDATE,1,4)||'-01-01' AND V_LAST_DAY
                 ;--
            ELSE
                 SELECT COALESCE(SUM(DR_AMT),0) + COALESCE(V_DR_00, 0), COALESCE(SUM(CR_AMT),0) + COALESCE(V_CR_00, 0) INTO V_DR_AMT, V_CR_AMT
                   FROM GADMIN.ACCOU1
                  WHERE 1 = 1
                    AND DATE BETWEEN SUBSTRING(IN_FROMDATE,1,4)||'-01-01' AND V_LAST_DAY
                    AND ACC_CD = V_CUR_ACC_CD;--
            END IF;--
    END IF; --

	IF V_CUR_DRCR_GB = '차변' THEN
    	SET V_YIWOL_AMT = V_DR_AMT - V_CR_AMT;--

        IF V_CUR_ACC_CD = '1110101' THEN
            --차변계정 현금
            INSERT INTO SESSION.TEMP
            SELECT DATE, ACC_CD, ACC_NM, ACC_CONT, DR_AMT, CR_AMT, SUM(DR_AMT - CR_AMT) OVER(ORDER BY DATE) AS JAN_AMT FROM
            (
                      SELECT IN_FROMDATE AS DATE, 000 AS ROW_ID,  V_CUR_ACC_CD AS ACC_CD, V_CUR_ACC_NM AS ACC_NM, '전기이월' AS ACC_CONT, V_YIWOL_AMT AS DR_AMT, 0 AS CR_AMT, V_YIWOL_AMT AS JAN_AMT
                        FROM SYSIBM.SYSDUMMY1
                      UNION ALL
                      SELECT VARCHAR_FORMAT(A.DATE, 'YYYY-MM-DD') AS DATE, MAX(B.ROW_ID) AS ROW_ID, V_CUR_ACC_CD AS ACC_CD, V_CUR_ACC_NM AS ACC_NM, '일계표에서' AS ACC_CONT, SUM(CR_AMT) AS DR_AMT, SUM(DR_AMT) AS CR_AMT, SUM(DR_AMT - CR_AMT) AS JAN_AMT
                        FROM GADMIN.ACCOU1 A,
                            (
                                SELECT B.DATE, C.ROW_ID, B.ACC_CONT FROM GADMIN.ACCOU1 B,
                                    ( SELECT DATE, MAX(ACC_NO) AS ACC_NO, MAX(ROW_ID) AS ROW_ID  FROM GADMIN.ACCOU1 WHERE DRCR_GB IN ('입금','출금')  AND DATE BETWEEN IN_FROMDATE AND IN_TODATE GROUP BY DATE  ) C
                                 WHERE B.DRCR_GB IN ('입금','출금')
                                   AND B.DATE = C.DATE
                                   AND B.ROW_ID = C.ROW_ID
                             ) B
                      WHERE A.DRCR_GB IN ('입금','출금')
                         AND A.DATE BETWEEN IN_FROMDATE AND IN_TODATE
                         AND A.DATE = B.DATE
                    GROUP BY VARCHAR_FORMAT(A.DATE, 'YYYY-MM-DD')
                    ORDER BY DATE, ROW_ID
            ) A;--
        ELSE
            --차변계정 현금이외
    	    SET V_YIWOL_AMT = V_DR_AMT - V_CR_AMT;--

            INSERT INTO SESSION.TEMP
            SELECT DATE, ACC_CD, ACC_NM, ACC_CONT, DR_AMT, CR_AMT, SUM(DR_AMT - CR_AMT) OVER(ORDER BY DATE) AS JAN_AMT FROM
            (
                      SELECT IN_FROMDATE AS DATE, 000 AS ROW_ID,  V_CUR_ACC_CD AS ACC_CD, V_CUR_ACC_NM AS ACC_NM, '전기이월' AS ACC_CONT, V_YIWOL_AMT AS DR_AMT, 0 AS CR_AMT, V_YIWOL_AMT AS JAN_AMT
                        FROM SYSIBM.SYSDUMMY1
                      UNION ALL
                      /*
--                      SELECT VARCHAR_FORMAT(A.DATE, 'YYYY-MM-DD') AS DATE, MAX(B.ROW_ID) AS ROW_ID, V_CUR_ACC_CD AS ACC_CD, V_CUR_ACC_NM AS ACC_NM, MAX(B.ACC_CONT) AS ACC_CONT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, SUM(CR_AMT - DR_AMT) AS JAN_AMT
                      SELECT VARCHAR_FORMAT(A.DATE, 'YYYY-MM-DD') AS DATE, MAX(B.ROW_ID) AS ROW_ID, V_CUR_ACC_CD AS ACC_CD, V_CUR_ACC_NM AS ACC_NM, '일계표에서' AS ACC_CONT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, SUM(DR_AMT - CR_AMT) AS JAN_AMT
                        FROM GADMIN.ACCOU1 A,
                            (
                                SELECT B.DATE, C.ROW_ID, B.ACC_CONT FROM GADMIN.ACCOU1 B,
                                    ( SELECT DATE, MAX(ACC_NO) AS ACC_NO, MAX(ROW_ID) AS ROW_ID
                                        FROM GADMIN.ACCOU1
                                       WHERE  ACC_CD = V_CUR_ACC_CD
                                         AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                                         GROUP BY DATE  ) C
                                 WHERE B.ACC_CD = V_CUR_ACC_CD
                                   AND B.DATE = C.DATE
                                   AND B.ROW_ID = C.ROW_ID
                             ) B
                      WHERE  A.ACC_CD = V_CUR_ACC_CD
                         AND A.DATE BETWEEN IN_FROMDATE AND IN_TODATE
                         AND A.DATE = B.DATE
                    GROUP BY VARCHAR_FORMAT(A.DATE, 'YYYY-MM-DD')
                    ORDER BY DATE, ROW_ID
                    */

--                      SELECT VARCHAR_FORMAT(A.DATE, 'YYYY-MM-DD') AS DATE, MAX(B.ROW_ID) AS ROW_ID, V_CUR_ACC_CD AS ACC_CD, V_CUR_ACC_NM AS ACC_NM, MAX(B.ACC_CONT) AS ACC_CONT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, SUM(CR_AMT - DR_AMT) AS JAN_AMT
                      SELECT VARCHAR_FORMAT(A.DATE, 'YYYY-MM-DD') AS DATE, MAX(A.ROW_ID) AS ROW_ID, V_CUR_ACC_CD AS ACC_CD, V_CUR_ACC_NM AS ACC_NM, '일계표에서' AS ACC_CONT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, SUM(DR_AMT - CR_AMT) AS JAN_AMT
                        FROM GADMIN.ACCOU1 A
                      WHERE  A.ACC_CD = V_CUR_ACC_CD
                         AND A.DATE BETWEEN IN_FROMDATE AND IN_TODATE
                    GROUP BY VARCHAR_FORMAT(A.DATE, 'YYYY-MM-DD')
                    ORDER BY DATE, ROW_ID
            ) A;--
        END IF;--

    ELSE
        --대변 계정
    	SET V_YIWOL_AMT = V_CR_AMT - V_DR_AMT;--

    	INSERT INTO SESSION.TEMP
        SELECT DATE, ACC_CD, ACC_NM, ACC_CONT, DR_AMT, CR_AMT, SUM(CR_AMT - DR_AMT) OVER(ORDER BY DATE) AS JAN_AMT FROM
        (
        /*
                  SELECT IN_FROMDATE AS DATE, 000 AS ROW_ID,  V_CUR_ACC_CD AS ACC_CD, V_CUR_ACC_NM AS ACC_NM, '전기이월' AS ACC_CONT, 0 AS DR_AMT, V_YIWOL_AMT AS CR_AMT, V_YIWOL_AMT AS JAN_AMT
                    FROM SYSIBM.SYSDUMMY1
                  UNION ALL
                  SELECT VARCHAR_FORMAT(A.DATE, 'YYYY-MM-DD') AS DATE, MAX(B.ROW_ID) AS ROW_ID, V_CUR_ACC_CD AS ACC_CD, V_CUR_ACC_NM AS ACC_NM, '일계표에서' AS ACC_CONT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, SUM(CR_AMT - DR_AMT) AS JAN_AMT
                    FROM GADMIN.ACCOU1 A,
                        (
                            SELECT B.DATE, C.ROW_ID, B.ACC_CONT FROM GADMIN.ACCOU1 B,
                                ( SELECT DATE, MAX(ACC_NO) AS ACC_NO, MAX(ROW_ID) AS ROW_ID
                                    FROM GADMIN.ACCOU1
                                   WHERE  ACC_CD = V_CUR_ACC_CD
                                     AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                                     GROUP BY DATE  ) C
                             WHERE B.ACC_CD = V_CUR_ACC_CD
                               AND B.DATE = C.DATE
                               AND B.ROW_ID = C.ROW_ID
                         ) B
                  WHERE  A.ACC_CD = V_CUR_ACC_CD
                     AND A.DATE BETWEEN IN_FROMDATE AND IN_TODATE
                     AND A.DATE = B.DATE
                GROUP BY VARCHAR_FORMAT(A.DATE, 'YYYY-MM-DD')
                ORDER BY DATE, ROW_ID
                */

                  SELECT IN_FROMDATE AS DATE, 000 AS ROW_ID,  V_CUR_ACC_CD AS ACC_CD, V_CUR_ACC_NM AS ACC_NM, '전기이월' AS ACC_CONT, 0 AS DR_AMT, V_YIWOL_AMT AS CR_AMT, V_YIWOL_AMT AS JAN_AMT
                    FROM SYSIBM.SYSDUMMY1
                  UNION ALL
                  SELECT VARCHAR_FORMAT(A.DATE, 'YYYY-MM-DD') AS DATE, MAX(A.ROW_ID) AS ROW_ID, V_CUR_ACC_CD AS ACC_CD, V_CUR_ACC_NM AS ACC_NM, '일계표에서' AS ACC_CONT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, SUM(CR_AMT - DR_AMT) AS JAN_AMT
                    FROM GADMIN.ACCOU1 A
                  WHERE  A.ACC_CD = V_CUR_ACC_CD
                     AND A.DATE BETWEEN IN_FROMDATE AND IN_TODATE
                GROUP BY VARCHAR_FORMAT(A.DATE, 'YYYY-MM-DD')
                ORDER BY DATE, ROW_ID

        ) A;--

    END IF;	   --

    INSERT INTO SESSION.TEMP
    --SELECT '' AS DATE, '' AS ACC_CD, '월계' AS ACC_NM, '' AS ACC_CONT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, NULL AS JAN_AMT
    SELECT '' AS DATE, ACC_CD, ACC_NM, '월계' AS ACC_CONT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, 0 AS JAN_AMT
       FROM SESSION.TEMP
      WHERE ACC_CD = V_CUR_ACC_CD
    GROUP BY ACC_CD, ACC_NM;--

    IF V_CUR_DRCR_GB = '차변' THEN
        IF V_CUR_ACC_CD = '1110101' THEN   --현금
             INSERT INTO SESSION.TEMP
             --SELECT '' AS DATE, '' AS ACC_CD, '누계' AS ACC_NM, '' AS ACC_CONT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, SUM(JAN_AMT) AS JAN_AMT
             SELECT '' AS DATE, ACC_CD, ACC_NM, '누계' AS ACC_CONT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, SUM(JAN_AMT) AS JAN_AMT
               FROM (
                         --SELECT '' AS DATE, '1110101' AS ACC_CD, '' AS ACC_NM, '누계' AS ACC_CONT, V_CR_00 AS DR_AMT, V_DR_00 AS CR_AMT, (V_CR_00 + V_DR_00) AS JAN_AMT
                         SELECT '' AS DATE, '1110101' AS ACC_CD, '현금' AS ACC_NM, '누계' AS ACC_CONT, V_CR_00 AS DR_AMT, V_DR_00 AS CR_AMT, (V_CR_00 + V_DR_00) AS JAN_AMT
                           FROM SYSIBM.SYSDUMMY1
                         UNION ALL
                         --SELECT '' AS DATE, '1110101' AS ACC_CD, '' AS ACC_NM, '누계' AS ACC_CONT, SUM(CR_AMT) AS DR_AMT, SUM(DR_AMT) AS CR_AMT, SUM(CR_AMT - DR_AMT) AS JAN_AMT
                         SELECT '' AS DATE, '1110101' AS ACC_CD, '현금' AS ACC_NM, '누계' AS ACC_CONT, SUM(CR_AMT) AS DR_AMT, SUM(DR_AMT) AS CR_AMT, SUM(CR_AMT - DR_AMT) AS JAN_AMT
                           FROM GADMIN.ACCOU1
                          WHERE 1 = 1
                            AND DRCR_GB IN ('입금','출금')
                            AND DATE BETWEEN SUBSTRING(IN_FROMDATE,1,4)||'-01-01' AND IN_TODATE )
             GROUP BY ACC_CD, ACC_NM
             ;--
        ELSE
             INSERT INTO SESSION.TEMP
             --SELECT '' AS DATE, '' AS ACC_CD, '누계' AS ACC_NM, '' AS ACC_CONT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, SUM(JAN_AMT) AS JAN_AMT
             SELECT '' AS DATE, ACC_CD, ACC_NM, '누계' AS ACC_CONT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, SUM(JAN_AMT) AS JAN_AMT
               FROM (
                         --SELECT '' AS DATE, V_CUR_ACC_CD AS ACC_CD, '' AS ACC_NM, '누계' AS ACC_CONT, V_DR_00 AS DR_AMT, V_CR_00 AS CR_AMT, (V_DR_00 + V_CR_00) AS JAN_AMT
                         SELECT '' AS DATE, V_CUR_ACC_CD AS ACC_CD, V_CUR_ACC_NM AS ACC_NM, '누계' AS ACC_CONT, V_DR_00 AS DR_AMT, V_CR_00 AS CR_AMT, (V_DR_00 + V_CR_00) AS JAN_AMT
                           FROM SYSIBM.SYSDUMMY1
                         UNION ALL
                         --SELECT '' AS DATE, ACC_CD, '' AS ACC_NM, '누계' AS ACC_CONT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, SUM(DR_AMT - CR_AMT)  AS JAN_AMT
                         SELECT '' AS DATE, ACC_CD, ACC_NM, '누계' AS ACC_CONT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, SUM(DR_AMT - CR_AMT)  AS JAN_AMT
                           FROM GADMIN.ACCOU1
                          WHERE 1 = 1
                            AND DATE BETWEEN SUBSTRING(IN_FROMDATE,1,4)||'-01-01' AND IN_TODATE
                            AND ACC_CD = V_CUR_ACC_CD
                          GROUP BY ACC_CD, ACC_NM )
             GROUP BY ACC_CD, ACC_NM
              ;--
        END IF;--
    ELSE
             INSERT INTO SESSION.TEMP
             --SELECT '' AS DATE, '' AS ACC_CD, '누계' AS ACC_NM, '' AS ACC_CONT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, SUM(JAN_AMT) AS JAN_AMT
             SELECT '' AS DATE, ACC_CD, ACC_NM, '누계' AS ACC_CONT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, SUM(JAN_AMT) AS JAN_AMT
               FROM (
                         --SELECT '' AS DATE, V_CUR_ACC_CD AS ACC_CD, '' AS ACC_NM, '누계' AS ACC_CONT, V_DR_00 AS DR_AMT, V_CR_00 AS CR_AMT, (V_DR_00 + V_CR_00) AS JAN_AMT
                         SELECT '' AS DATE, V_CUR_ACC_CD AS ACC_CD, V_CUR_ACC_NM AS ACC_NM, '누계' AS ACC_CONT, V_DR_00 AS DR_AMT, V_CR_00 AS CR_AMT, (V_DR_00 + V_CR_00) AS JAN_AMT
                           FROM SYSIBM.SYSDUMMY1
                         UNION ALL
                         --SELECT '' AS DATE, ACC_CD, '' AS ACC_NM, '누계' AS ACC_CONT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, SUM(CR_AMT - DR_AMT) AS JAN_AMT
                         SELECT '' AS DATE, ACC_CD, ACC_NM, '누계' AS ACC_CONT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, SUM(CR_AMT - DR_AMT) AS JAN_AMT
                           FROM GADMIN.ACCOU1
                          WHERE 1 = 1
                            AND DATE BETWEEN SUBSTRING(IN_FROMDATE,1,4)||'-01-01' AND IN_TODATE
                            AND ACC_CD = V_CUR_ACC_CD
                         GROUP BY ACC_CD, ACC_NM )
             GROUP BY ACC_CD, ACC_NM
             ;--
    END IF;--

/*
    IF V_CUR_DRCR_GB = '차변' THEN
        IF V_CUR_ACC_CD = '1110101' THEN   --현금
             INSERT INTO SESSION.TEMP
             SELECT '' AS DATE, '' AS ACC_CD, '누계' AS ACC_NM, '' AS ACC_CONT, SUM(CR_AMT) + V_CR_00 AS DR_AMT, SUM(DR_AMT) + V_DR_00 AS CR_AMT, SUM(CR_AMT - DR_AMT) + (V_CR_00 + V_DR_00) AS JAN_AMT
               FROM GADMIN.ACCOU1
              WHERE 1 = 1
                AND DRCR_GB IN ('입금','출금')
                AND DATE BETWEEN SUBSTRING(IN_FROMDATE,1,4)||'-01-01' AND IN_TODATE
             ;--
        ELSE
             INSERT INTO SESSION.TEMP
             SELECT '' AS DATE, '' AS ACC_CD, '누계' AS ACC_NM, '' AS ACC_CONT, SUM(DR_AMT) + V_DR_00 AS DR_AMT, SUM(CR_AMT) + V_CR_00 AS CR_AMT, SUM(DR_AMT - CR_AMT) + (V_DR_00 + V_CR_00) AS JAN_AMT
               FROM GADMIN.ACCOU1
              WHERE 1 = 1
                AND DATE BETWEEN SUBSTRING(IN_FROMDATE,1,4)||'-01-01' AND IN_TODATE
                AND ACC_CD = V_CUR_ACC_CD;--
        END IF;--
    ELSE
             INSERT INTO SESSION.TEMP
             SELECT '' AS DATE, '' AS ACC_CD, '누계' AS ACC_NM, '' AS ACC_CONT, SUM(DR_AMT) + V_DR_00 AS DR_AMT, SUM(CR_AMT) + V_CR_00 AS CR_AMT, SUM(CR_AMT - DR_AMT) + (V_CR_00 + V_DR_00) AS JAN_AMT
               FROM GADMIN.ACCOU1
              WHERE 1 = 1
                AND DATE BETWEEN SUBSTRING(IN_FROMDATE,1,4)||'-01-01' AND IN_TODATE
                AND ACC_CD = V_CUR_ACC_CD;--
    END IF;--
  */
    FETCH FROM C_CHONGGAE INTO V_CUR_ACC_CD, V_CUR_ACC_NM, V_CUR_DRCR_GB;--

    END WHILE;--

    CLOSE C_CHONGGAE;--

END P1;--

P2: BEGIN

    DECLARE CURSOR_TEMP CURSOR WITH RETURN FOR
    SELECT *
      FROM SESSION.TEMP
     WHERE 1 = 1
       --AND NOT( DR_AMT = 0 AND CR_AMT = 0 )
       ;--

    OPEN CURSOR_TEMP;--
END P2;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN0701_TAB02_SELECT"
(IN IN_DATE VARCHAR(10), IN IN_ACC_CD VARCHAR(10), IN IN_USER_ID VARCHAR(25))
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE SQLSTATE CHAR(5) DEFAULT '00000';--

    DECLARE GLOBAL TEMPORARY TABLE SESSION.TEMP
    (
        DATE           VARCHAR(10),
        ACC_NO          VARCHAR(4),
        DRCR_GB         VARCHAR(6),
        ACC_CD          VARCHAR(10),
        ACC_NM          VARCHAR(60),
        ACC_CONT        VARCHAR(60),
        DR_AMT          DECIMAL(15,5),
        CR_AMT          DECIMAL(15,5),
        MANAGE_CD_1     VARCHAR(9),
        MANAGE_ITEM_1   VARCHAR(45),
        NAMAGE_CD_2     VARCHAR(9),
        MANAGE_ITEM_2   VARCHAR(90)
    )  ON COMMIT PRESERVE ROWS
  WITH REPLACE
  NOT LOGGED;--

    P1: BEGIN
         --DATA SELECT
		DECLARE CURSOR_ACC CURSOR WITH RETURN FOR
		SELECT * FROM (
                        SELECT ACC_CD, ACC_NM, VARCHAR_FORMAT(A.DATE, 'YYYY-MM-DD') AS DATE, A.ACC_NO, A.DRCR_GB,A.ACC_CONT, A.DR_AMT, A.CR_AMT, A.MANAGE_CD_1, A.MANAGE_ITEM_1, A.MANAGE_CD_1, A.MANAGE_ITEM_2
                          FROM GADMIN.ACCOU1 A
                         --WHERE A.DATE BETWEEN IN_FROMDATE AND IN_TODATE
                         WHERE A.DATE = IN_DATE
                        UNION ALL
                        SELECT '1110101' AS ACC_CD, '현          금' AS ACC_NM, VARCHAR_FORMAT(B.DATE, 'YYYY-MM-DD') AS DATE, B.ACC_NO, B.DRCR_GB, B.ACC_CONT, B.CR_AMT AS DR_AMT, B.DR_AMT AS CR_AMT, B.MANAGE_CD_1, B.MANAGE_ITEM_1, B.MANAGE_CD_1, B.MANAGE_ITEM_2
                          FROM GADMIN.ACCOU1 B
                         --WHERE DATE BETWEEN IN_FROMDATE AND IN_TODATE
                         WHERE DATE = IN_DATE
                           AND DRCR_GB IN ('입금','출금')
                           AND ACC_CD IS NOT NULL
                       )
        WHERE ACC_CD = IN_ACC_CD
       ORDER BY 1,2
         ;--
	OPEN CURSOR_ACC;		--

    END P1;--

END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN0801_TAB01_PRINT"
(IN IN_FROMDATE VARCHAR(10),
 IN IN_TODATE VARCHAR(10),
 IN IN_FROMACCCD VARCHAR(7),
 IN IN_TOACCCD VARCHAR(7),
 IN IN_USER_ID VARCHAR(25))
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE   SQLSTATE          CHAR(5) DEFAULT '00000';--
        DECLARE   FROM_PRE_DAY       VARCHAR(10) DEFAULT '';--

    DECLARE GLOBAL TEMPORARY TABLE SESSION.TEMP
    (
        LEVELUP_CD      VARCHAR(10),
        LEVELUP_ACC     VARCHAR(60),
        ACC_CD          VARCHAR(10),
        ACC_NM          VARCHAR(60),
        YI_AMT          DECIMAL(15,0),
        DR_AMT          DECIMAL(15,0),
        CR_AMT          DECIMAL(15,0),
        JAN_AMT         DECIMAL(15,0)
    )  ON COMMIT PRESERVE ROWS
  WITH REPLACE
  NOT LOGGED;--

P1: BEGIN


    IF SUBSTRING(IN_FROMDATE,6,5) > '01-01' THEN
        SELECT TO_CHAR(TO_DATE(IN_FROMDATE, 'YYYY-MM-DD') -1, 'YYYY-MM-DD') INTO FROM_PRE_DAY FROM SYSIBM.SYSDUMMY1;--
    ELSE
        SET FROM_PRE_DAY = IN_FROMDATE;--
    END IF;--

    INSERT INTO SESSION.TEMP
    SELECT A.LEVELUP_CD, A.LEVELUP_ACC, A.ACC_CD, B.ACC_NM, SUM(YI_AMT) AS YI_AMT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT,
            CASE B.DRCR_GB WHEN '차변' THEN SUM(YI_AMT + DR_AMT - CR_AMT)
                            WHEN '입금' THEN SUM(YI_AMT + DR_AMT - CR_AMT)
                            WHEN '출금' THEN SUM(YI_AMT + DR_AMT - CR_AMT)
                            WHEN '대변' THEN SUM(YI_AMT + CR_AMT - DR_AMT)
                            END AS JAN_AMT
      FROM (
                SELECT '1110100' AS LEVELUP_CD, '현금및현금성자산' AS LEVELUP_ACC, '1110101' AS ACC_CD, '현          금' AS ACC_NM, 0 AS YI_AMT, SUM(CR_AMT) AS DR_AMT, SUM(DR_AMT) AS CR_AMT
                  FROM GADMIN.ACCOU1
                 WHERE DRCR_GB IN ('입금','출금')
                    AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                UNION ALL
                SELECT B.LEVELUP_CD, B.LEVELUP_ACC, A.ACC_CD, A.ACC_NM, 0 AS YI_AMT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT
                   FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                  WHERE A.ACC_CD = B.ACC_CD
                     AND A.DATE BETWEEN IN_FROMDATE AND IN_TODATE
                  GROUP BY B.LEVELUP_CD, B.LEVELUP_ACC, A.ACC_CD, A.ACC_NM
                UNION ALL
                SELECT LEVELUP_CD, LEVELUP_ACC, ACC_CD, ACC_NM, SUM(YI_AMT) AS YI_AMT , 0 AS DR_AMT, 0 AS CR_AMT
                  FROM (
                            SELECT B.LEVELUP_CD, B.LEVELUP_ACC, A.ACC_CD, A.ACC_NM, CASE B.DRCR_GB  WHEN '차변' THEN DR_AMT - CR_AMT ELSE CR_AMT - DR_AMT END YI_AMT , 0 AS DR_AMT, 0 AS CR_AMT
                              FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(SUBSTRING((FROM_PRE_DAY),1,4)||'-01-01')) A, GADMIN.BSACC2 B
                             WHERE A.ACC_CD = B.ACC_CD
                               AND NOT (A.DR_AMT = 0 AND A.CR_AMT = 0)
                            UNION ALL
                            SELECT B.LEVELUP_CD, B.LEVELUP_ACC, A.ACC_CD, A.ACC_NM, CASE B.DRCR_GB  WHEN '차변' THEN DR_AMT - CR_AMT ELSE CR_AMT - DR_AMT END YI_AMT , 0 AS DR_AMT, 0 AS CR_AMT
                              FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                             WHERE A.ACC_CD = B.ACC_CD
                               AND DATE BETWEEN SUBSTRING((FROM_PRE_DAY),1,4)||'-01-01' AND FROM_PRE_DAY
                               AND NOT (A.DR_AMT = 0 AND A.CR_AMT = 0)
                            UNION ALL
                            SELECT '1110100', '현금및현금성자산', '1110101', '현          금', COALESCE(SUM(CR_AMT) - SUM(DR_AMT),0) AS YI_AMT , 0 AS DR_AMT, 0 AS CR_AMT
                              FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                             WHERE A.ACC_CD = B.ACC_CD
                               AND DATE BETWEEN SUBSTRING((FROM_PRE_DAY),1,4)||'-01-01' AND FROM_PRE_DAY
                               AND A.DRCR_GB IN ('출금','입금')
                               AND NOT (A.DR_AMT = 0 AND A.CR_AMT = 0)
                         )
                GROUP BY LEVELUP_CD, LEVELUP_ACC, ACC_CD, ACC_NM
            ) A, GADMIN.BSACC2 B
      WHERE A.ACC_CD = B.ACC_CD
        AND A.ACC_CD >= IN_FROMACCCD
        AND A.ACC_CD <= IN_TOACCCD
    GROUP BY A.LEVELUP_CD, A.LEVELUP_ACC, A.ACC_CD, B.ACC_NM, B.DRCR_GB
    ORDER BY 3,4
    ;--



END P1;--

P2: BEGIN
    DECLARE CURSOR_TEMP CURSOR WITH RETURN FOR
    SELECT CASE WHEN LEVELUP_CD ='9999999' THEN '' ELSE LEVELUP_CD END  AS LEVELUP_CD, LEVELUP_ACC, ACC_CD, ACC_NM, YI_AMT, DR_AMT, CR_AMT, JAN_AMT
      FROM (
                SELECT *
                  FROM SESSION.TEMP
                ORDER BY LEVELUP_CD
            );--
/*
    SELECT *
      FROM SESSION.TEMP
    ORDER BY LEVELUP_CD
    ;--
  */
    OPEN CURSOR_TEMP;--
END P2;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN0801_TAB01_PRINT_20211019"
(IN IN_FROMDATE VARCHAR(10),
 IN IN_TODATE VARCHAR(10),
 IN IN_FROMACCCD VARCHAR(7),
 IN IN_TOACCCD VARCHAR(7),
 IN IN_USER_ID VARCHAR(25))
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE   SQLSTATE          CHAR(5) DEFAULT '00000';--

    DECLARE GLOBAL TEMPORARY TABLE SESSION.TEMP
    (
        LEVELUP_CD      VARCHAR(10),
        LEVELUP_ACC     VARCHAR(60),
        ACC_CD          VARCHAR(10),
        ACC_NM          VARCHAR(60),
        YI_AMT          DECIMAL(15,0),
        DR_AMT          DECIMAL(15,0),
        CR_AMT          DECIMAL(15,0),
        JAN_AMT         DECIMAL(15,0)
    )  ON COMMIT PRESERVE ROWS
  WITH REPLACE
  NOT LOGGED;--

P1: BEGIN

    INSERT INTO SESSION.TEMP
    SELECT A.LEVELUP_CD, A.LEVELUP_ACC, A.ACC_CD, A.ACC_NM, SUM(YI_AMT) AS YI_AMT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT,
            CASE B.DRCR_GB WHEN '차변' THEN SUM(YI_AMT + DR_AMT - CR_AMT)
                            WHEN '입금' THEN SUM(YI_AMT + DR_AMT - CR_AMT)
                            WHEN '출금' THEN SUM(YI_AMT + DR_AMT - CR_AMT)
                            WHEN '대변' THEN SUM(YI_AMT + CR_AMT - DR_AMT)
                            END AS JAN_AMT
      FROM (
                SELECT '1110100' AS LEVELUP_CD, '현금및현금등가물' AS LEVELUP_ACC, '1110101' AS ACC_CD, '현금' AS ACC_NM, 0 AS YI_AMT, SUM(CR_AMT) AS DR_AMT, SUM(DR_AMT) AS CR_AMT
                  FROM GADMIN.ACCOU1
                 WHERE DRCR_GB IN ('입금','출금')
                    AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                UNION ALL
                SELECT B.LEVELUP_CD, B.LEVELUP_ACC, A.ACC_CD, REPLACE(A.ACC_NM,' ','') AS ACC_NM, 0 AS YI_AMT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT
                   FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                  WHERE A.ACC_CD = B.ACC_CD
                     AND A.DATE BETWEEN IN_FROMDATE AND IN_TODATE
                  GROUP BY B.LEVELUP_CD, B.LEVELUP_ACC, A.ACC_CD, A.ACC_NM
                UNION ALL
                SELECT B.LEVELUP_CD, B.LEVELUP_ACC, A.ACC_CD, REPLACE(A.ACC_NM,' ','') AS ACC_NM, CASE B.DRCR_GB  WHEN '차변' THEN DR_AMT - CR_AMT ELSE CR_AMT - DR_AMT END YI_AMT , 0 AS DR_AMT, 0 AS CR_AMT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE A.ACC_CD = B.ACC_CD
                   AND NOT (A.DR_AMT = 0 AND A.CR_AMT = 0)
            ) A, GADMIN.BSACC2 B
      WHERE A.ACC_CD = B.ACC_CD
        AND A.ACC_CD >= IN_FROMACCCD
        AND A.ACC_CD <= IN_TOACCCD
    GROUP BY A.LEVELUP_CD, A.LEVELUP_ACC, A.ACC_CD, A.ACC_NM, B.DRCR_GB
    ORDER BY 3,4
    ;--
/*
     --소계
    INSERT INTO SESSION.TEMP
    SELECT LEVELUP_CD, LEVELUP_ACC, '' AS ACC_CD, '소계' AS ACC_NM, SUM(YI_AMT) AS YI_AMT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, SUM(JAN_AMT) AS JAN_AMT
       FROM SESSION.TEMP
      GROUP BY LEVELUP_CD, LEVELUP_ACC
      ;--

    -- 합계
    INSERT INTO SESSION.TEMP
    SELECT '9999999'  AS LEVELUP_CD, '' AS LEVELUP_ACC, '' AS ACC_CD, '합계' AS ACC_NM, SUM(YI_AMT) AS YI_AMT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, SUM(JAN_AMT) AS JAN_AMT
      FROM SESSION.TEMP
      WHERE ACC_NM = '소계';--
*/

END P1;--

P2: BEGIN

    DECLARE CURSOR_TEMP CURSOR WITH RETURN FOR
    SELECT CASE WHEN LEVELUP_CD ='9999999' THEN '' ELSE LEVELUP_CD END  AS LEVELUP_CD, LEVELUP_ACC, ACC_CD, ACC_NM, YI_AMT, DR_AMT, CR_AMT, JAN_AMT
      FROM (
                SELECT *
                  FROM SESSION.TEMP
                ORDER BY LEVELUP_CD
            );--
/*
    SELECT *
      FROM SESSION.TEMP
    ORDER BY LEVELUP_CD
    ;--
  */
    OPEN CURSOR_TEMP;--
END P2;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN0801_TAB01_SELECT"
(IN IN_FROMDATE VARCHAR(10),
IN IN_TODATE VARCHAR(10), IN IN_FROMACCCD VARCHAR(7), IN IN_TOACCCD VARCHAR(7), IN IN_USER_ID VARCHAR(25))
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE   SQLSTATE          CHAR(5) DEFAULT '00000';--
    DECLARE   FROM_PRE_DAY       VARCHAR(10) DEFAULT '';--

    DECLARE GLOBAL TEMPORARY TABLE SESSION.TEMP
    (
        LEVELUP_CD      VARCHAR(10),
        LEVELUP_ACC     VARCHAR(60),
        LEVELUP_CD_T    VARCHAR(10),
        LEVELUP_ACC_T   VARCHAR(60),
        ACC_CD          VARCHAR(10),
        ACC_NM          VARCHAR(60),
        YI_AMT          DECIMAL(15,0),
        DR_AMT          DECIMAL(15,0),
        CR_AMT          DECIMAL(15,0),
        JAN_AMT         DECIMAL(15,0)
    )  ON COMMIT PRESERVE ROWS
  WITH REPLACE
  NOT LOGGED;--

P1: BEGIN

/*
    INSERT INTO SESSION.TEMP
    SELECT A.LEVELUP_CD, A.LEVELUP_ACC, A.ACC_CD, A.ACC_NM, SUM(YI_AMT) AS YI_AMT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT,
            CASE B.DRCR_GB WHEN '차변' THEN SUM(YI_AMT + DR_AMT - CR_AMT)
                            WHEN '입금' THEN SUM(YI_AMT + DR_AMT - CR_AMT)
                            WHEN '출금' THEN SUM(YI_AMT + DR_AMT - CR_AMT)
                            WHEN '대변' THEN SUM(YI_AMT + CR_AMT - DR_AMT)
                            END AS JAN_AMT
      FROM (
                SELECT '1110100' AS LEVELUP_CD, '현금및현금성자산' AS LEVELUP_ACC, '1110101' AS ACC_CD, '현          금' AS ACC_NM, 0 AS YI_AMT, SUM(CR_AMT) AS DR_AMT, SUM(DR_AMT) AS CR_AMT
                  FROM GADMIN.ACCOU1
                 WHERE DRCR_GB IN ('입금','출금')
                    AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                UNION ALL
                SELECT B.LEVELUP_CD, B.LEVELUP_ACC, A.ACC_CD, A.ACC_NM, 0 AS YI_AMT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT
                   FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                  WHERE A.ACC_CD = B.ACC_CD
                     AND A.DATE BETWEEN IN_FROMDATE AND IN_TODATE
                  GROUP BY B.LEVELUP_CD, B.LEVELUP_ACC, A.ACC_CD, A.ACC_NM
                UNION ALL
                SELECT B.LEVELUP_CD, B.LEVELUP_ACC, A.ACC_CD, A.ACC_NM, CASE B.DRCR_GB  WHEN '차변' THEN DR_AMT - CR_AMT ELSE CR_AMT - DR_AMT END YI_AMT , 0 AS DR_AMT, 0 AS CR_AMT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE A.ACC_CD = B.ACC_CD
                   AND NOT (A.DR_AMT = 0 AND A.CR_AMT = 0)
            ) A, GADMIN.BSACC2 B
      WHERE A.ACC_CD = B.ACC_CD
        AND A.ACC_CD >= IN_FROMACCCD
        AND A.ACC_CD <= IN_TOACCCD
    GROUP BY A.LEVELUP_CD, A.LEVELUP_ACC, A.ACC_CD, A.ACC_NM, B.DRCR_GB
    ORDER BY 3,4
    ;--
*/

    IF SUBSTRING(IN_FROMDATE,6,5) > '01-01' THEN
        SELECT TO_CHAR(TO_DATE(IN_FROMDATE, 'YYYY-MM-DD') -1, 'YYYY-MM-DD') INTO FROM_PRE_DAY FROM SYSIBM.SYSDUMMY1;--
    ELSE
        SET FROM_PRE_DAY = IN_FROMDATE;--
    END IF;--

    INSERT INTO SESSION.TEMP
--    SELECT A.LEVELUP_CD, A.LEVELUP_ACC, A.ACC_CD, A.ACC_NM, SUM(YI_AMT) AS YI_AMT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT,
    SELECT A.LEVELUP_CD, A.LEVELUP_ACC, A.LEVELUP_CD AS LEVELUP_CD_T , A.LEVELUP_ACC AS LEVELUP_ACC_T, A.ACC_CD, B.ACC_NM, SUM(YI_AMT) AS YI_AMT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT,
            CASE B.DRCR_GB WHEN '차변' THEN SUM(YI_AMT + DR_AMT - CR_AMT)
                            WHEN '입금' THEN SUM(YI_AMT + DR_AMT - CR_AMT)
                            WHEN '출금' THEN SUM(YI_AMT + DR_AMT - CR_AMT)
                            WHEN '대변' THEN SUM(YI_AMT + CR_AMT - DR_AMT)
                            END AS JAN_AMT
      FROM (
                SELECT '1110100' AS LEVELUP_CD, '현금및현금성자산' AS LEVELUP_ACC, '1110101' AS ACC_CD, '현          금' AS ACC_NM, 0 AS YI_AMT, SUM(CR_AMT) AS DR_AMT, SUM(DR_AMT) AS CR_AMT
                  FROM GADMIN.ACCOU1
                 WHERE DRCR_GB IN ('입금','출금')
                    AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                UNION ALL
                SELECT B.LEVELUP_CD, B.LEVELUP_ACC, A.ACC_CD, A.ACC_NM, 0 AS YI_AMT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT
                   FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                  WHERE A.ACC_CD = B.ACC_CD
                     AND A.DATE BETWEEN IN_FROMDATE AND IN_TODATE
                  GROUP BY B.LEVELUP_CD, B.LEVELUP_ACC, A.ACC_CD, A.ACC_NM
                UNION ALL
                SELECT LEVELUP_CD, LEVELUP_ACC, ACC_CD, ACC_NM, SUM(YI_AMT) AS YI_AMT , 0 AS DR_AMT, 0 AS CR_AMT
                  FROM (
                            SELECT B.LEVELUP_CD, B.LEVELUP_ACC, A.ACC_CD, A.ACC_NM, CASE B.DRCR_GB  WHEN '차변' THEN DR_AMT - CR_AMT ELSE CR_AMT - DR_AMT END YI_AMT , 0 AS DR_AMT, 0 AS CR_AMT
                              FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(SUBSTRING((FROM_PRE_DAY),1,4)||'-01-01')) A, GADMIN.BSACC2 B
                             WHERE A.ACC_CD = B.ACC_CD
                               AND NOT (A.DR_AMT = 0 AND A.CR_AMT = 0)
                            UNION ALL
                            SELECT B.LEVELUP_CD, B.LEVELUP_ACC, A.ACC_CD, A.ACC_NM, CASE B.DRCR_GB  WHEN '차변' THEN DR_AMT - CR_AMT ELSE CR_AMT - DR_AMT END YI_AMT , 0 AS DR_AMT, 0 AS CR_AMT
                              FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                             WHERE A.ACC_CD = B.ACC_CD
                               AND DATE BETWEEN SUBSTRING((FROM_PRE_DAY),1,4)||'-01-01' AND FROM_PRE_DAY
                               AND NOT (A.DR_AMT = 0 AND A.CR_AMT = 0)
                            UNION ALL
                            SELECT '1110100', '현금및현금성자산', '1110101', '현          금', COALESCE(SUM(CR_AMT) - SUM(DR_AMT),0) AS YI_AMT , 0 AS DR_AMT, 0 AS CR_AMT
                              FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                             WHERE A.ACC_CD = B.ACC_CD
                               AND DATE BETWEEN SUBSTRING((FROM_PRE_DAY),1,4)||'-01-01' AND FROM_PRE_DAY
                               AND A.DRCR_GB IN ('출금','입금')
                               AND NOT (A.DR_AMT = 0 AND A.CR_AMT = 0)
                         )
                GROUP BY LEVELUP_CD, LEVELUP_ACC, ACC_CD, ACC_NM
            ) A, GADMIN.BSACC2 B
      WHERE A.ACC_CD = B.ACC_CD
        AND A.ACC_CD >= IN_FROMACCCD
        AND A.ACC_CD <= IN_TOACCCD
    GROUP BY A.LEVELUP_CD, A.LEVELUP_ACC, A.ACC_CD, B.ACC_NM, B.DRCR_GB
    ORDER BY 3,4
    ;--

     --소계
    INSERT INTO SESSION.TEMP
    SELECT LEVELUP_CD, LEVELUP_ACC, '' AS LEVELUP_CD_T, '         소계' AS LEVELUP_ACC_T, '' AS ACC_CD, '' AS ACC_NM, SUM(YI_AMT) AS YI_AMT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, SUM(JAN_AMT) AS JAN_AMT
       FROM SESSION.TEMP
      GROUP BY LEVELUP_CD, LEVELUP_ACC
      ;--

    -- 합계
    INSERT INTO SESSION.TEMP
    SELECT '9999999'  AS LEVELUP_CD, '' AS LEVELUP_ACC, '' AS LEVELUP_CD_T, '         합계' AS LEVELUP_ACC_T, '' AS ACC_CD, '' AS ACC_NM, SUM(YI_AMT) AS YI_AMT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, SUM(JAN_AMT) AS JAN_AMT
      FROM SESSION.TEMP
      WHERE TRIM(LEVELUP_ACC_T) = '소계';--


END P1;--

P2: BEGIN

    DECLARE CURSOR_TEMP CURSOR WITH RETURN FOR
    SELECT CASE WHEN LEVELUP_CD ='9999999' THEN '' ELSE LEVELUP_CD END  AS LEVELUP_CD, LEVELUP_ACC, LEVELUP_CD_T, LEVELUP_ACC_T, ACC_CD, ACC_NM, YI_AMT, DR_AMT, CR_AMT, JAN_AMT
      FROM (
                SELECT *
                  FROM SESSION.TEMP
                ORDER BY LEVELUP_CD
            )
    ;--

    OPEN CURSOR_TEMP;--
END P2;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN0801_TAB02_PRINT" (IN IN_FROMDATE
VARCHAR(10), IN IN_TODATE VARCHAR(10), IN IN_ACC_CD VARCHAR(10), IN IN_USER_ID
VARCHAR(25))
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE   SQLSTATE          CHAR(5) DEFAULT '00000';--
    DECLARE   V_YEAR            VARCHAR(4) DEFAULT '';--
    DECLARE   V_MONTH           VARCHAR(2) DEFAULT '';--
    DECLARE   V_DAY             VARCHAR(10)   DEFAULT '';--
    DECLARE   V_GISU            VARCHAR(3) DEFAULT '';--
    DECLARE   V_CUR_ACC_CD      VARCHAR(10)   DEFAULT '';--
    DECLARE   V_CUR_ACC_NM      VARCHAR(60)   DEFAULT '';--
    DECLARE   V_CUR_DRCR_GB     VARCHAR(6)   DEFAULT '';--

    DECLARE   V_YIWOL_AMT       DECIMAL(15,0) DEFAULT 0.0;--
    DECLARE   V_JAN_TOT_AMT     DECIMAL(15,0) DEFAULT 0.0;--

    DECLARE   V_DATE            VARCHAR(10)   DEFAULT '';--
    DECLARE   V_ACC_NO          VARCHAR(4)    DEFAULT '';--
    DECLARE   V_ACC_CD          VARCHAR(10)   DEFAULT '';--
    DECLARE   V_ACC_NM          VARCHAR(60)   DEFAULT '';--
    DECLARE   V_ACC_CONT        VARCHAR(300)  DEFAULT '';--
    DECLARE   V_IN_AMT          DECIMAL(15,0) DEFAULT 0.0;--
    DECLARE   V_OUT_AMT         DECIMAL(15,0) DEFAULT 0.0;--
    DECLARE   V_JAN_AMT         DECIMAL(15,0) DEFAULT 0.0;--

    DECLARE   V_DR_AMT          DECIMAL(15,0) DEFAULT 0.0;--
    DECLARE   V_CR_AMT          DECIMAL(15,0) DEFAULT 0.0;--

    DECLARE GLOBAL TEMPORARY TABLE SESSION.TEMP
    (
        DATE		    VARCHAR(10),
        ACC_CD          VARCHAR(10),
        ACC_NM          VARCHAR(60),
        ACC_NO          VARCHAR(4),
        ACC_CONT        VARCHAR(300),
        MANAGE_ITEM_1   VARCHAR(40),
        MANAGE_ITEM_2   VARCHAR(90),
        DR_AMT          DECIMAL(20,5),
        CR_AMT          DECIMAL(20,5),
        JAN_AMT         DECIMAL(20,5)
    )  ON COMMIT PRESERVE ROWS
  WITH REPLACE
  NOT LOGGED;--

--개수 찾기
SELECT GISU INTO V_GISU
  FROM GADMIN.BSACC9
 WHERE START <= IN_FROMDATE
   AND TERMINATION >= IN_FROMDATE;--

    SET V_MONTH = SUBSTRING(IN_FROMDATE,6,2);		   --

P1: BEGIN

    INSERT INTO SESSION.TEMP
    SELECT DATE, ACC_CD, ACC_NM, ACC_NO, ACC_CONT, MANAGE_ITEM_1, MANAGE_ITEM_2, DR_AMT, CR_AMT,
           SUM(CASE WHEN DRCR_GB = '차변' OR DRCR_GB = '출금' THEN DR_AMT - CR_AMT ELSE CR_AMT - DR_AMT END)  OVER(PARTITION BY ACC_CD ORDER BY ACC_CD, DATE, ACC_NO, ROWNUMBER()OVER()) JAN_AMT
      FROM (
		    SELECT A.DRCR_GB, C.ACC_CD, C.ACC_NM, C.DATE, C.ACC_NO, C.ACC_CONT, MANAGE_ITEM_1, MANAGE_ITEM_2, COALESCE(C.DR_AMT,0) AS DR_AMT, COALESCE(C.CR_AMT,0) AS CR_AMT,
		    	CASE WHEN A.DRCR_GB = '차변' OR A.DRCR_GB = '출금'  THEN COALESCE(C.JAN_AMT,0) + COALESCE(C.DR_AMT,0) - COALESCE(C.CR_AMT,0)
		    			ELSE COALESCE(C.JAN_AMT,0) + COALESCE(C.CR_AMT,0) - COALESCE(C.DR_AMT,0) END AS JAN_AMT
		      FROM
		            (
		              SELECT  LEVELUP_CD, LEVELUP_ACC, ACC_CD, ACC_NM, DRCR_GB
		                FROM GADMIN.BSACC2
		               WHERE 1 = 1
		                 AND ACC_INPUT != 'N'
		                 --AND HAPJAN_DISP != 'N'
		               ORDER BY LEVELUP_CD, LEVELUP_ACC, ACC_CD, ACC_NM
		            ) A
             		 LEFT OUTER JOIN (
                                SELECT Y.ACC_CD, Y.ACC_NM, SUBSTRING(IN_FROMDATE,1,7)||'-00' AS DATE, '000' AS ACC_NO, '전기이월' AS ACC_CONT, '' AS MANAGE_ITEM_1,'' AS MANAGE_ITEM_2, Y.DR_AMT, Y.CR_AMT,
                                    CASE WHEN Y.DRCR_GB = '차변' OR Y.DRCR_GB = '출금' THEN Y.DR_AMT - Y.CR_AMT ELSE Y.CR_AMT - Y.DR_AMT END AS JAN_AMT
                                  FROM (
                                        SELECT A.ACC_CD, A.ACC_NM, A.DRCR_GB,
                                                  CASE WHEN V_MONTH = '01' THEN DR_00
                                                        WHEN V_MONTH = '02' THEN DR_01
                                                        WHEN V_MONTH = '03' THEN DR_02
                                                        WHEN V_MONTH = '04' THEN DR_03
                                                        WHEN V_MONTH = '05' THEN DR_04
                                                        WHEN V_MONTH = '06' THEN DR_05
                                                        WHEN V_MONTH = '07' THEN DR_06
                                                        WHEN V_MONTH = '08' THEN DR_07
                                                        WHEN V_MONTH = '09' THEN DR_08
                                                        WHEN V_MONTH = '10' THEN DR_09
                                                        WHEN V_MONTH = '11' THEN DR_10
                                                        WHEN V_MONTH = '12' THEN DR_11
                                                    END AS DR_AMT,
                                                  CASE WHEN V_MONTH = '01' THEN CR_00
                                                        WHEN V_MONTH = '02' THEN CR_01
                                                        WHEN V_MONTH = '03' THEN CR_02
                                                        WHEN V_MONTH = '04' THEN CR_03
                                                        WHEN V_MONTH = '05' THEN CR_04
                                                        WHEN V_MONTH = '06' THEN CR_05
                                                        WHEN V_MONTH = '07' THEN CR_06
                                                        WHEN V_MONTH = '08' THEN CR_07
                                                        WHEN V_MONTH = '09' THEN CR_08
                                                        WHEN V_MONTH = '10' THEN CR_09
                                                        WHEN V_MONTH = '11' THEN CR_10
                                                        WHEN V_MONTH = '12' THEN CR_11
                                                    END AS CR_AMT
                                          FROM GADMIN.HAPJAN A
                                                INNER JOIN
                                                ( SELECT *
                                                    FROM GADMIN.BSACC2
                                                   WHERE 1 = 1
                                                     AND ACC_GB IN ('자산','부채','자본')
                                                ) B ON ( A.ACC_CD = B.ACC_CD )
                                         WHERE YEAR = V_GISU
                            ) Y
      				  UNION ALL
                      SELECT A.ACC_CD, A.ACC_NM, VARCHAR_FORMAT(A.DATE, 'YYYY-MM-DD') AS DATE, A.ACC_NO, A.ACC_CONT, A.MANAGE_ITEM_1, A.MANAGE_ITEM_2,  A.DR_AMT, A.CR_AMT,
                      		CASE WHEN B.DRCR_GB = '차변' OR B.DRCR_GB = '출금' THEN A.DR_AMT - A.CR_AMT ELSE A.CR_AMT - A.DR_AMT END AS JAN_AMT
                        FROM GADMIN.ACCOU1 A LEFT OUTER JOIN GADMIN.BSACC2 B ON (A.ACC_CD = B.ACC_CD)
                       WHERE DATE BETWEEN IN_FROMDATE AND IN_TODATE
                         AND A.ACC_CD IS NOT NULL
                      UNION ALL
                      SELECT '1110101' AS ACC_CD, '현          금' AS ACC_NM, VARCHAR_FORMAT(B.DATE, 'YYYY-MM-DD') AS DATE, B.ACC_NO, B.ACC_CONT,  B.MANAGE_ITEM_1, B.MANAGE_ITEM_2, B.CR_AMT AS DR_AMT, B.DR_AMT AS CR_AMT, B.CR_AMT - B.DR_AMT AS JAN_AMT
                        FROM GADMIN.ACCOU1 B
                        WHERE DATE BETWEEN IN_FROMDATE AND IN_TODATE
                          AND DRCR_GB IN ('입금','출금')
                          AND ACC_CD IS NOT NULL
            ) C ON ( A.ACC_CD = C.ACC_CD )
    WHERE 1 = 1
      AND A.ACC_CD IS NOT NULL
      AND A.ACC_CD LIKE IN_ACC_CD )
      A
	WHERE 1 = 1
      AND A.ACC_CD IS NOT NULL;--

     --월계
    INSERT INTO SESSION.TEMP
    SELECT SUBSTRING(DATE,1,7)||'-88' AS DATE,  ACC_CD, ACC_NM, '' AS ACC_NO, '                   월계' AS ACC_CONT, '' AS MANAGE_ITEM_1, '' AS MANAGE_ITEM_2, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, 0 AS JAN_AMT
      FROM SESSION.TEMP
     WHERE ACC_CONT != '전기이월'
    GROUP BY SUBSTRING(DATE,1,7),  ACC_CD, ACC_NM;--

    -- 누계 PRINT
    INSERT INTO SESSION.TEMP
    SELECT SUBSTRING(DATE,1,7)||'-99' AS DATE,  A.ACC_CD, A.ACC_NM, '' AS ACC_NO, '                   누계'  AS ACC_CONT, '' AS MANAGE_ITEM_1, '' AS MANAGE_ITEM_2,
                                                                                                           SUM(DR_AMT) OVER(PARTITION BY A.ACC_CD, A.ACC_NM ORDER BY DATE) AS DR_AMT,
                                                                                                           SUM(CR_AMT) OVER(PARTITION BY A.ACC_CD, A.ACC_NM ORDER BY DATE) AS CR_AMT,
           CASE WHEN B.DRCR_GB = '차변' OR B.DRCR_GB = '출금'
                 THEN  (SUM(DR_AMT) OVER(PARTITION BY A.ACC_CD, A.ACC_NM ORDER BY DATE)) - (SUM(CR_AMT) OVER(PARTITION BY A.ACC_CD, A.ACC_NM ORDER BY DATE))
                 ELSE  (SUM(CR_AMT) OVER(PARTITION BY A.ACC_CD, A.ACC_NM ORDER BY DATE)) - (SUM(DR_AMT) OVER(PARTITION BY A.ACC_CD, A.ACC_NM ORDER BY DATE)) END  AS JAN_AMT
       FROM  (
                            SELECT SUBSTRING(DATE,1,7) AS DATE,  ACC_CD, ACC_NM, '' AS ACC_NO, '' AS ACC_CONT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, 0 AS JAN_AMT
                              FROM SESSION.TEMP
                             WHERE TRIM(ACC_CONT) != '월계'
                            GROUP BY SUBSTRING(DATE,1,7),  ACC_CD, ACC_NM
              )   A  LEFT OUTER JOIN GADMIN.BSACC2 B ON (A.ACC_CD = B.ACC_CD)
      WHERE 1 = 1 ;--


END P1;--

P2: BEGIN

    /*
    DECLARE CURSOR_TEMP CURSOR WITH RETURN FOR
    SELECT *
      FROM SESSION.TEMP
    WHERE 1 = 1
      --AND ACC_CD != '1110101'
    ORDER BY ACC_CD,DATE;--
    */
    DECLARE CURSOR_TEMP CURSOR WITH RETURN FOR
    SELECT CASE WHEN SUBSTRING(DATE,9,2) = '88' OR SUBSTRING(DATE,9,2) = '99' OR SUBSTRING(DATE,9,2) = '00' THEN '' ELSE DATE END AS DATE,
            CASE WHEN SUBSTRING(DATE,9,2) = '88' OR SUBSTRING(DATE,9,2) = '99' OR SUBSTRING(DATE,9,2) = '00' THEN '' ELSE DATE END AS DATE_T,
            ACC_CD, ACC_NM,
            CASE WHEN ACC_NO = '000' THEN '' ELSE ACC_NO END AS ACC_NO, ACC_CONT, MANAGE_ITEM_2, DR_AMT, CR_AMT, JAN_AMT
                /*
                CASE WHEN SUBSTRING(DATE,9,2) = '88' OR SUBSTRING(DATE,9,2) = '99' OR SUBSTRING(DATE,9,2) = '00' THEN '' ELSE DATE END AS DATE,  ACC_CD, ACC_NM, ACC_NO,
                 --GADMIN.SF_STRINGSLENCUT(ACC_CONT,20,'STRING') AS ACC_CONT,
                  ACC_CONT,
                 --MANAGE_ITEM_1, GADMIN.SF_STRINGSLENCUT(MANAGE_ITEM_2,14,'STRING') AS MANAGE_ITEM_2,
                 MANAGE_ITEM_2,
                 DR_AMT, CR_AMT, JAN_AMT
                 */
       FROM  (
                    SELECT *
                      FROM SESSION.TEMP
                    WHERE 1 = 1
                      --AND ACC_CD != '1110101'
                    ORDER BY DATE,ACC_CD, ACC_NO
               )
               ;--

    OPEN CURSOR_TEMP;--
END P2;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN0801_TAB02_SELECT"
(IN IN_FROMDATE VARCHAR(10), IN IN_TODATE VARCHAR(10), IN_ACC_CD VARCHAR(10), IN IN_USER_ID VARCHAR(25))
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE   SQLSTATE          CHAR(5) DEFAULT '00000';--
    DECLARE   V_YEAR            VARCHAR(4) DEFAULT '';--
    DECLARE   V_MONTH           VARCHAR(2) DEFAULT '';--
    DECLARE   V_DAY             VARCHAR(10)   DEFAULT '';--
    DECLARE   V_GISU            VARCHAR(3) DEFAULT '';--
    DECLARE   V_CUR_ACC_CD      VARCHAR(10)   DEFAULT '';--
    DECLARE   V_CUR_ACC_NM      VARCHAR(60)   DEFAULT '';--
    DECLARE   V_CUR_DRCR_GB     VARCHAR(6)   DEFAULT '';--

    DECLARE   V_YIWOL_AMT       DECIMAL(15,0) DEFAULT 0.0;--
    DECLARE   V_JAN_TOT_AMT     DECIMAL(15,0) DEFAULT 0.0;--

    DECLARE   V_DATE            VARCHAR(10)   DEFAULT '';--
    DECLARE   V_ACC_NO          VARCHAR(4)    DEFAULT '';--
    DECLARE   V_ACC_CD          VARCHAR(10)   DEFAULT '';--
    DECLARE   V_ACC_NM          VARCHAR(60)   DEFAULT '';--
    DECLARE   V_ACC_CONT        VARCHAR(300)  DEFAULT '';--
    DECLARE   V_IN_AMT          DECIMAL(15,0) DEFAULT 0.0;--
    DECLARE   V_OUT_AMT         DECIMAL(15,0) DEFAULT 0.0;--
    DECLARE   V_JAN_AMT         DECIMAL(15,0) DEFAULT 0.0;--

    DECLARE   V_DR_AMT          DECIMAL(15,0) DEFAULT 0.0;--
    DECLARE   V_CR_AMT          DECIMAL(15,0) DEFAULT 0.0;--

    DECLARE GLOBAL TEMPORARY TABLE SESSION.TEMP
    (
        DATE		    VARCHAR(10),
        DATE_T		    VARCHAR(10),
        ACC_CD          VARCHAR(10),
        ACC_NM          VARCHAR(60),
        ACC_NO          VARCHAR(4),
        ACC_CONT        VARCHAR(300),
        MANAGE_ITEM_2   VARCHAR(90),
        DR_AMT          DECIMAL(20,5),
        CR_AMT          DECIMAL(20,5),
        JAN_AMT         DECIMAL(20,5)
    )  ON COMMIT PRESERVE ROWS
  WITH REPLACE
  NOT LOGGED;--

--개수 찾기
SELECT GISU INTO V_GISU
  FROM GADMIN.BSACC9
 WHERE START <= IN_FROMDATE
   AND TERMINATION >= IN_FROMDATE;--

    SET V_MONTH = SUBSTRING(IN_FROMDATE,6,2);		   --

P1: BEGIN

    INSERT INTO SESSION.TEMP
    SELECT DATE, DATE AS DATE_T, ACC_CD, ACC_NM, ACC_NO, ACC_CONT, MANAGE_ITEM_2, DR_AMT, CR_AMT,
           SUM(CASE WHEN DRCR_GB = '차변' OR DRCR_GB = '출금' THEN DR_AMT - CR_AMT ELSE CR_AMT - DR_AMT END)  OVER(PARTITION BY ACC_CD ORDER BY ACC_CD, DATE, ACC_NO, ROWNUMBER()OVER()) JAN_AMT
      FROM (
		    SELECT A.DRCR_GB, C.ACC_CD, C.ACC_NM, C.DATE, C.ACC_NO, C.ACC_CONT, MANAGE_ITEM_2,  COALESCE(C.DR_AMT,0) AS DR_AMT, COALESCE(C.CR_AMT,0) AS CR_AMT,
		    	CASE WHEN A.DRCR_GB = '차변' OR A.DRCR_GB = '출금'  THEN COALESCE(C.JAN_AMT,0) + COALESCE(C.DR_AMT,0) - COALESCE(C.CR_AMT,0)
		    			ELSE COALESCE(C.JAN_AMT,0) + COALESCE(C.CR_AMT,0) - COALESCE(C.DR_AMT,0) END AS JAN_AMT
		      FROM
		            (
		              SELECT  LEVELUP_CD, LEVELUP_ACC, ACC_CD, ACC_NM, DRCR_GB
		                FROM GADMIN.BSACC2
		               WHERE 1 = 1
		                 AND ACC_INPUT != 'N'
		                 --AND HAPJAN_DISP != 'N'
		               ORDER BY LEVELUP_CD, LEVELUP_ACC, ACC_CD, ACC_NM
		            ) A
             		 LEFT OUTER JOIN (
                                SELECT Y.ACC_CD, Y.ACC_NM, SUBSTRING(IN_FROMDATE,1,7)||'-00' AS DATE, '000' AS ACC_NO, '전기이월' AS ACC_CONT, '' AS MANAGE_ITEM_2, Y.DR_AMT, Y.CR_AMT,
                                    CASE WHEN Y.DRCR_GB = '차변' OR Y.DRCR_GB = '출금' THEN Y.DR_AMT - Y.CR_AMT ELSE Y.CR_AMT - Y.DR_AMT END AS JAN_AMT
                                  FROM (
                                        SELECT A.ACC_CD, A.ACC_NM, A.DRCR_GB,
                                                  CASE WHEN V_MONTH = '01' THEN DR_00
                                                        WHEN V_MONTH = '02' THEN DR_01
                                                        WHEN V_MONTH = '03' THEN DR_02
                                                        WHEN V_MONTH = '04' THEN DR_03
                                                        WHEN V_MONTH = '05' THEN DR_04
                                                        WHEN V_MONTH = '06' THEN DR_05
                                                        WHEN V_MONTH = '07' THEN DR_06
                                                        WHEN V_MONTH = '08' THEN DR_07
                                                        WHEN V_MONTH = '09' THEN DR_08
                                                        WHEN V_MONTH = '10' THEN DR_09
                                                        WHEN V_MONTH = '11' THEN DR_10
                                                        WHEN V_MONTH = '12' THEN DR_11
                                                    END AS DR_AMT,
                                                  CASE WHEN V_MONTH = '01' THEN CR_00
                                                        WHEN V_MONTH = '02' THEN CR_01
                                                        WHEN V_MONTH = '03' THEN CR_02
                                                        WHEN V_MONTH = '04' THEN CR_03
                                                        WHEN V_MONTH = '05' THEN CR_04
                                                        WHEN V_MONTH = '06' THEN CR_05
                                                        WHEN V_MONTH = '07' THEN CR_06
                                                        WHEN V_MONTH = '08' THEN CR_07
                                                        WHEN V_MONTH = '09' THEN CR_08
                                                        WHEN V_MONTH = '10' THEN CR_09
                                                        WHEN V_MONTH = '11' THEN CR_10
                                                        WHEN V_MONTH = '12' THEN CR_11
                                                    END AS CR_AMT
                                          FROM GADMIN.HAPJAN A
                                                INNER JOIN
                                                ( SELECT *
                                                    FROM GADMIN.BSACC2
                                                   WHERE 1 = 1
                                                     AND ACC_GB IN ('자산','부채','자본')
                                                ) B ON ( A.ACC_CD = B.ACC_CD )
                                         WHERE YEAR = V_GISU
                            ) Y
      				  UNION ALL
                      SELECT A.ACC_CD, A.ACC_NM, VARCHAR_FORMAT(A.DATE, 'YYYY-MM-DD') AS DATE, A.ACC_NO, A.ACC_CONT, A.MANAGE_ITEM_2, A.DR_AMT, A.CR_AMT,
                      		CASE WHEN B.DRCR_GB = '차변' OR B.DRCR_GB = '출금' THEN A.DR_AMT - A.CR_AMT ELSE A.CR_AMT - A.DR_AMT END AS JAN_AMT
                        FROM GADMIN.ACCOU1 A LEFT OUTER JOIN GADMIN.BSACC2 B ON (A.ACC_CD = B.ACC_CD)
                       WHERE DATE BETWEEN IN_FROMDATE AND IN_TODATE
                         AND A.ACC_CD IS NOT NULL
                      UNION ALL
                      SELECT '1110101' AS ACC_CD, '현          금' AS ACC_NM, VARCHAR_FORMAT(B.DATE, 'YYYY-MM-DD') AS DATE, B.ACC_NO, B.ACC_CONT, B.MANAGE_ITEM_2, B.CR_AMT AS DR_AMT, B.DR_AMT AS CR_AMT, B.CR_AMT - B.DR_AMT AS JAN_AMT
                        FROM GADMIN.ACCOU1 B
                        WHERE DATE BETWEEN IN_FROMDATE AND IN_TODATE
                          AND DRCR_GB IN ('입금','출금')
                          AND ACC_CD IS NOT NULL
            ) C ON ( A.ACC_CD = C.ACC_CD )
    WHERE 1 = 1
      AND A.ACC_CD IS NOT NULL
      AND A.ACC_CD LIKE IN_ACC_CD )
      A
	WHERE 1 = 1
      AND A.ACC_CD IS NOT NULL;--

     --월계
    INSERT INTO SESSION.TEMP
    SELECT SUBSTRING(DATE,1,7)||'-88' AS DATE, '월계' AS DATE_T, ACC_CD, ACC_NM, '' AS ACC_NO, '' AS ACC_CONT, '' AS MANAGE_ITEM_2, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, 0 AS JAN_AMT
      FROM SESSION.TEMP
     WHERE ACC_CONT != '전기이월'
    GROUP BY SUBSTRING(DATE,1,7),  ACC_CD, ACC_NM;--

    -- 누계
    INSERT INTO SESSION.TEMP
    SELECT SUBSTRING(DATE,1,7)||'-99' AS DATE, '누계' AS DATE_T, A.ACC_CD, A.ACC_NM, '' AS ACC_NO, ''  AS ACC_CONT, '' AS MANAGE_ITEM_2,
                                                                                                           SUM(DR_AMT) OVER(PARTITION BY A.ACC_CD, A.ACC_NM ORDER BY DATE) AS DR_AMT,
                                                                                                           SUM(CR_AMT) OVER(PARTITION BY A.ACC_CD, A.ACC_NM ORDER BY DATE) AS CR_AMT,
           CASE WHEN B.DRCR_GB = '차변' OR B.DRCR_GB = '출금'
                 THEN  (SUM(DR_AMT) OVER(PARTITION BY A.ACC_CD, A.ACC_NM ORDER BY DATE)) - (SUM(CR_AMT) OVER(PARTITION BY A.ACC_CD, A.ACC_NM ORDER BY DATE))
                 ELSE  (SUM(CR_AMT) OVER(PARTITION BY A.ACC_CD, A.ACC_NM ORDER BY DATE)) - (SUM(DR_AMT) OVER(PARTITION BY A.ACC_CD, A.ACC_NM ORDER BY DATE)) END  AS JAN_AMT
       FROM  (
                SELECT DATE, ACC_CD, ACC_NM, '' AS ACC_NO, '' AS ACC_CONT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, 0 AS JAN_AMT
                  FROM (
                            --SELECT SUBSTRING(DATE,1,7) AS DATE,  ACC_CD, ACC_NM, '' AS ACC_NO, '' AS ACC_CONT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, 0 AS JAN_AMT
                            SELECT SUBSTRING(DATE,1,7) AS DATE,  ACC_CD, ACC_NM, '' AS ACC_NO, '' AS ACC_CONT, DR_AMT, CR_AMT, 0 AS JAN_AMT
                              FROM SESSION.TEMP
                             WHERE DATE_T != '월계'
                            --GROUP BY SUBSTRING(DATE,1,7), ACC_CD, ACC_NM
                         )
                GROUP BY DATE, ACC_CD, ACC_NM
              )   A  LEFT OUTER JOIN GADMIN.BSACC2 B ON (A.ACC_CD = B.ACC_CD)
      WHERE 1 = 1  ;--




END P1;--

P2: BEGIN

    DECLARE CURSOR_TEMP CURSOR WITH RETURN FOR
    SELECT DATE,
            --CASE WHEN SUBSTRING(DATE,9,2) = '88' OR SUBSTRING(DATE,9,2) = '99' OR SUBSTRING(DATE,9,2) = '00' THEN '' ELSE DATE END AS 
            DATE_T,
            ACC_CD, ACC_NM,
            CASE WHEN ACC_NO = '000' THEN '' ELSE ACC_NO END AS ACC_NO, ACC_CONT, MANAGE_ITEM_2, DR_AMT, CR_AMT, JAN_AMT
       FROM  (
                    SELECT *
                      FROM SESSION.TEMP
                    WHERE 1 = 1
                      --AND ACC_CD != '1110101'
                    ORDER BY DATE,ACC_CD, ACC_NO
               )
               ;--
    /*
    SELECT *
      FROM SESSION.TEMP
    WHERE 1 = 1
      --AND ACC_CD != '1110101'
    ORDER BY DATE,ACC_CD, ACC_NO ;--
    */

    OPEN CURSOR_TEMP;--
END P2;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN0801_TAB03_SELECT"
(IN IN_FROMDATE VARCHAR(10), IN IN_TODATE VARCHAR(10),IN IN_FROMACCCD VARCHAR(7), IN IN_TOACCCD VARCHAR(7), IN IN_USER_ID VARCHAR(25))
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE   SQLSTATE          CHAR(5) DEFAULT '00000';--
    DECLARE   V_YEAR            VARCHAR(4) DEFAULT '';--
    DECLARE   V_MONTH           VARCHAR(2) DEFAULT '';--
    DECLARE   V_DAY             VARCHAR(10)   DEFAULT '';--
    DECLARE   V_GISU            VARCHAR(3) DEFAULT '';--
    DECLARE   V_CUR_ACC_CD      VARCHAR(10)   DEFAULT '';--
    DECLARE   V_CUR_ACC_NM      VARCHAR(60)   DEFAULT '';--
    DECLARE   V_CUR_DRCR_GB     VARCHAR(6)   DEFAULT '';--

    DECLARE   V_YIWOL_AMT       DECIMAL(15,0) DEFAULT 0.0;--
    DECLARE   V_JAN_TOT_AMT     DECIMAL(15,0) DEFAULT 0.0;--

    DECLARE   V_DATE            VARCHAR(10)   DEFAULT '';--
    DECLARE   V_ACC_NO          VARCHAR(4)    DEFAULT '';--
    DECLARE   V_ACC_CD          VARCHAR(10)   DEFAULT '';--
    DECLARE   V_ACC_NM          VARCHAR(60)   DEFAULT '';--
    DECLARE   V_ACC_CONT        VARCHAR(300)  DEFAULT '';--
    DECLARE   V_IN_AMT          DECIMAL(15,0) DEFAULT 0.0;--
    DECLARE   V_OUT_AMT         DECIMAL(15,0) DEFAULT 0.0;--
    DECLARE   V_JAN_AMT         DECIMAL(15,0) DEFAULT 0.0;--

    DECLARE   V_DR_AMT          DECIMAL(15,0) DEFAULT 0.0;--
    DECLARE   V_CR_AMT          DECIMAL(15,0) DEFAULT 0.0;--

    DECLARE GLOBAL TEMPORARY TABLE SESSION.TEMP
    (
        DATE		    VARCHAR(10),
        DATE_T		    VARCHAR(10),
        ACC_CD          VARCHAR(10),
        ACC_NM          VARCHAR(60),
        ACC_CD_T        VARCHAR(10),
        ACC_NM_T        VARCHAR(60),
        ACC_NO          VARCHAR(4),
        ACC_CONT        VARCHAR(300),
        DR_AMT          DECIMAL(20,5),
        CR_AMT          DECIMAL(20,5),
        JAN_AMT         DECIMAL(20,5)
    )  ON COMMIT PRESERVE ROWS
  WITH REPLACE
  NOT LOGGED;--

--개수 찾기
SELECT GISU INTO V_GISU
  FROM GADMIN.BSACC9
 WHERE START <= IN_FROMDATE
   AND TERMINATION >= IN_FROMDATE;--

    SET V_MONTH = SUBSTRING(IN_FROMDATE,6,2);		   --

P1: BEGIN

    INSERT INTO SESSION.TEMP
    SELECT DATE, DATE AS DATE_T, ACC_CD, ACC_NM, ACC_CD AS ACC_CD_T, ACC_NM AS ACC_NM_T, ACC_NO, ACC_CONT, DR_AMT, CR_AMT,
           SUM(CASE WHEN DRCR_GB = '차변' OR DRCR_GB = '출금' THEN DR_AMT - CR_AMT ELSE CR_AMT - DR_AMT END)  OVER(PARTITION BY ACC_CD ORDER BY ACC_CD, DATE, ACC_NO, ROWNUMBER()OVER()) JAN_AMT
      FROM (
		    SELECT A.DRCR_GB, C.ACC_CD, C.ACC_NM, C.DATE, C.ACC_NO, C.ACC_CONT, COALESCE(C.DR_AMT,0) AS DR_AMT, COALESCE(C.CR_AMT,0) AS CR_AMT,
		    	CASE WHEN A.DRCR_GB = '차변' OR A.DRCR_GB = '출금'  THEN COALESCE(C.JAN_AMT,0) + COALESCE(C.DR_AMT,0) - COALESCE(C.CR_AMT,0)
		    			ELSE COALESCE(C.JAN_AMT,0) + COALESCE(C.CR_AMT,0) - COALESCE(C.DR_AMT,0) END AS JAN_AMT
		      FROM
		            (
		              SELECT  LEVELUP_CD, LEVELUP_ACC, ACC_CD, ACC_NM, DRCR_GB
		                FROM GADMIN.BSACC2
		               WHERE 1 = 1
		                 AND ACC_INPUT != 'N'
		                 --AND HAPJAN_DISP != 'N'
		               ORDER BY LEVELUP_CD, LEVELUP_ACC, ACC_CD, ACC_NM
		            ) A
             		 LEFT OUTER JOIN (
                                SELECT Y.ACC_CD, Y.ACC_NM, SUBSTRING(IN_FROMDATE,1,7)||'-00' AS DATE, '000' AS ACC_NO, '전기이월' AS ACC_CONT, Y.DR_AMT, Y.CR_AMT,
                                    CASE WHEN Y.DRCR_GB = '차변' OR Y.DRCR_GB = '출금' THEN Y.DR_AMT - Y.CR_AMT ELSE Y.CR_AMT - Y.DR_AMT END AS JAN_AMT
                                  FROM (
                                        SELECT A.ACC_CD, A.ACC_NM, A.DRCR_GB,
                                                  CASE WHEN V_MONTH = '01' THEN DR_00
                                                        WHEN V_MONTH = '02' THEN DR_01
                                                        WHEN V_MONTH = '03' THEN DR_02
                                                        WHEN V_MONTH = '04' THEN DR_03
                                                        WHEN V_MONTH = '05' THEN DR_04
                                                        WHEN V_MONTH = '06' THEN DR_05
                                                        WHEN V_MONTH = '07' THEN DR_06
                                                        WHEN V_MONTH = '08' THEN DR_07
                                                        WHEN V_MONTH = '09' THEN DR_08
                                                        WHEN V_MONTH = '10' THEN DR_09
                                                        WHEN V_MONTH = '11' THEN DR_10
                                                        WHEN V_MONTH = '12' THEN DR_11
                                                    END AS DR_AMT,
                                                  CASE WHEN V_MONTH = '01' THEN CR_00
                                                        WHEN V_MONTH = '02' THEN CR_01
                                                        WHEN V_MONTH = '03' THEN CR_02
                                                        WHEN V_MONTH = '04' THEN CR_03
                                                        WHEN V_MONTH = '05' THEN CR_04
                                                        WHEN V_MONTH = '06' THEN CR_05
                                                        WHEN V_MONTH = '07' THEN CR_06
                                                        WHEN V_MONTH = '08' THEN CR_07
                                                        WHEN V_MONTH = '09' THEN CR_08
                                                        WHEN V_MONTH = '10' THEN CR_09
                                                        WHEN V_MONTH = '11' THEN CR_10
                                                        WHEN V_MONTH = '12' THEN CR_11
                                                    END AS CR_AMT
                                          FROM GADMIN.HAPJAN A
                                                INNER JOIN
                                                ( SELECT *
                                                    FROM GADMIN.BSACC2
                                                   WHERE 1 = 1
                                                     AND ACC_GB IN ('자산','부채','자본')
                                                ) B ON ( A.ACC_CD = B.ACC_CD )
                                         WHERE YEAR = V_GISU
                                           AND A.ACC_CD >= IN_FROMACCCD
                                           AND A.ACC_CD <= IN_TOACCCD
                                           AND A.ACC_CD != '1110101'   --현금 제외
                            ) Y
      				  UNION ALL
                      SELECT A.ACC_CD, A.ACC_NM, VARCHAR_FORMAT(A.DATE, 'YYYY-MM-DD') AS DATE, A.ACC_NO, A.ACC_CONT, A.DR_AMT, A.CR_AMT,
                      		CASE WHEN B.DRCR_GB = '차변' OR B.DRCR_GB = '출금' THEN A.DR_AMT - A.CR_AMT ELSE A.CR_AMT - A.DR_AMT END AS JAN_AMT
                        FROM GADMIN.ACCOU1 A LEFT OUTER JOIN GADMIN.BSACC2 B ON (A.ACC_CD = B.ACC_CD)
                       WHERE DATE BETWEEN IN_FROMDATE AND IN_TODATE
                         AND A.ACC_CD IS NOT NULL
                         AND A.ACC_CD >= IN_FROMACCCD
                         AND A.ACC_CD <= IN_TOACCCD
                      /*
                      UNION ALL
                      SELECT '1110101' AS ACC_CD, '현          금' AS ACC_NM, VARCHAR_FORMAT(B.DATE, 'YYYY-MM-DD') AS DATE, B.ACC_NO, B.ACC_CONT, B.CR_AMT AS DR_AMT, B.DR_AMT AS CR_AMT, B.CR_AMT - B.DR_AMT AS JAN_AMT
                        FROM GADMIN.ACCOU1 B
                        WHERE DATE BETWEEN IN_FROMDATE AND IN_TODATE
                          AND DRCR_GB IN ('입금','출금')
                          AND ACC_CD IS NOT NULL
                      */
            ) C ON ( A.ACC_CD = C.ACC_CD )
    WHERE 1 = 1
      AND A.ACC_CD IS NOT NULL )
      A
	WHERE 1 = 1
	  AND NOT( DR_AMT = 0 AND CR_AMT = 0 )
	  AND A.ACC_CD >= IN_FROMACCCD
      AND A.ACC_CD <= IN_TOACCCD
      AND A.ACC_CD IS NOT NULL;--

     --월계
    INSERT INTO SESSION.TEMP
    SELECT SUBSTRING(DATE,1,7)||'-88' AS DATE, '월계' AS DATE_T,  ACC_CD, ACC_NM,  '' AS ACC_CD_T, '' AS ACC_NM_T, '' AS ACC_NO, '' AS ACC_CONT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, 0 AS JAN_AMT
      FROM SESSION.TEMP
     WHERE ACC_CONT != '전기이월'
    GROUP BY SUBSTRING(DATE,1,7),  ACC_CD, ACC_NM;--


    -- 누계
    INSERT INTO SESSION.TEMP
    SELECT SUBSTRING(DATE,1,7)||'-99' AS DATE,  '누계' AS DATE_T, A.ACC_CD, A.ACC_NM, '' AS ACC_CD_T, '' AS ACC_NM_T, '' AS ACC_NO, ''  AS ACC_CONT, SUM(DR_AMT) OVER(PARTITION BY A.ACC_CD, A.ACC_NM ORDER BY DATE) AS DR_AMT,
                                                                                                           SUM(CR_AMT) OVER(PARTITION BY A.ACC_CD, A.ACC_NM ORDER BY DATE) AS CR_AMT,
           CASE WHEN B.DRCR_GB = '차변' OR B.DRCR_GB = '출금'
                 THEN  (SUM(DR_AMT) OVER(PARTITION BY A.ACC_CD, A.ACC_NM ORDER BY DATE)) - (SUM(CR_AMT) OVER(PARTITION BY A.ACC_CD, A.ACC_NM ORDER BY DATE))
                 ELSE  (SUM(CR_AMT) OVER(PARTITION BY A.ACC_CD, A.ACC_NM ORDER BY DATE)) - (SUM(DR_AMT) OVER(PARTITION BY A.ACC_CD, A.ACC_NM ORDER BY DATE)) END  AS JAN_AMT
       FROM  (
                SELECT DATE, ACC_CD, ACC_NM, '' AS ACC_NO, '' AS ACC_CONT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, 0 AS JAN_AMT
                  FROM (
                            SELECT SUBSTRING(DATE,1,7) AS DATE,  ACC_CD, ACC_NM, '' AS ACC_NO, '' AS ACC_CONT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, 0 AS JAN_AMT
                              FROM SESSION.TEMP
                             WHERE DATE_T != '월계'
                            GROUP BY SUBSTRING(DATE,1,7),  ACC_CD, ACC_NM
                         )
                GROUP BY DATE, ACC_CD, ACC_NM
              )   A  LEFT OUTER JOIN GADMIN.BSACC2 B ON (A.ACC_CD = B.ACC_CD)
      WHERE 1 = 1
        --AND SUBSTRING(ACC_CONT,4,4) = '월계'
      ;--

END P1;--

P2: BEGIN


    /*
    DECLARE CURSOR_TEMP CURSOR WITH RETURN FOR
    SELECT *
      FROM SESSION.TEMP
    WHERE 1 = 1
      --AND ACC_CD != '1110101'
    ORDER BY ACC_CD,DATE ;--
    */
    DECLARE CURSOR_TEMP CURSOR WITH RETURN FOR
    SELECT CASE WHEN SUBSTRING(DATE,9,2) = '88' OR SUBSTRING(DATE,9,2) = '99' OR SUBSTRING(DATE,9,2) = '00' THEN '' ELSE DATE END AS DATE,
            CASE WHEN SUBSTRING(DATE,9,2) = '88' OR SUBSTRING(DATE,9,2) = '99' OR SUBSTRING(DATE,9,2) = '00'THEN '' ELSE DATE END AS DATE_T,
            ACC_CD, ACC_NM, ACC_CD_T, ACC_NM_T, ACC_NO, ACC_CONT, DR_AMT, CR_AMT, JAN_AMT
       FROM  (
                    SELECT *
                      FROM SESSION.TEMP
                    WHERE 1 = 1
                      --AND ACC_CD != '1110101'
                    ORDER BY ACC_CD, DATE
               )
               ;--

    OPEN CURSOR_TEMP;--
END P2;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN0801_TAB04_DDLB"
(IN IN_FROMDATE VARCHAR(10),
 IN IN_TODATE VARCHAR(10),
 IN IN_ACCCD  VARCHAR(10),
 IN IN_USER_ID VARCHAR(25))
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE   SQLSTATE          CHAR(5) DEFAULT '00000';--
    DECLARE   V_YEAR            VARCHAR(4) DEFAULT '';--
    DECLARE   V_GISU            VARCHAR(4) DEFAULT '';--

    DECLARE GLOBAL TEMPORARY TABLE SESSION.TEMP
    (
        DATE		    VARCHAR(10),
        ACC_NO          VARCHAR(3),
        ACC_CD          VARCHAR(10),
        ACC_NM          VARCHAR(60),
        ACC_CONT        VARCHAR(300),
        MANAGE_CD_1     VARCHAR(9),
        MANAGE_ITEM_1   VARCHAR(45),
        MANAGE_CD_2     VARCHAR(9),
        MANAGE_ITEM_2   VARCHAR(90),
        DR_AMT          DECIMAL(15,0),
        CR_AMT          DECIMAL(15,0),
        JAN_AMT         DECIMAL(15,0)
    )  ON COMMIT PRESERVE ROWS
  WITH REPLACE
  NOT LOGGED;--

--개수 찾기
SELECT GISU INTO V_GISU
  FROM GADMIN.BSACC9
 WHERE START <= IN_FROMDATE
   AND TERMINATION >= IN_FROMDATE
;--

P1: BEGIN
    DECLARE CURSOR_MAN2 CURSOR WITH RETURN FOR
    WITH MAN_DDLB AS
    (
    SELECT DISTINCT MANAGE_CD_2, MANAGE_ITEM_2
    FROM (
            SELECT '' AS MANAGE_CD_2, '' AS MANAGE_ITEM_2 FROM SYSIBM.SYSDUMMY1
            UNION ALL
            SELECT MANAGE_2 AS MANAGE_CD_2, ITEM_2 AS MANAGE_ITEM_2
              FROM GADMIN.TRADEKYE A, GADMIN.BSACC2 B   -- 관리항목2의 명칭이 다른것이 있어 BSACC8를 이용함
            WHERE 1 = 1
              AND A.ACC_CD = B.ACC_CD
              AND YEAR = V_GISU
              AND A.ACC_CD = IN_ACCCD
              AND (A.DR_00 <> 0 OR A.CR_00 <> 0)
            UNION ALL
            SELECT A.MANAGE_CD_2, A.MANAGE_ITEM_2
              FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
            WHERE 1 = 1
              AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
              AND A.ACC_CD = IN_ACCCD
              AND A.ACC_CD = B.ACC_CD
              AND (A.DR_AMT <> 0 OR A.CR_AMT <> 0)
         )
    )
    SELECT MANAGE_CD_2, MANAGE_ITEM_2
      FROM (
                SELECT *
                  FROM MAN_DDLB
                WHERE 1 = 1
                ORDER BY regexp_replace(MANAGE_ITEM_2,'\(.\)|\(..\)|[[:punct:]]|[0-9]|Ⅰ|Ⅱ|Ⅲ|Ⅳ|Ⅴ|Ⅵ|Ⅶ|Ⅷ|Ⅸ|Ⅹ| ')
                        , MANAGE_CD_2 -- (주)와 같은 머리말 뺴고 명칭으로만 정렬(21.9.2/전광진)
           )
    ;--

    OPEN CURSOR_MAN2;--
END P1;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN0801_TAB04_PRINT"
(IN IN_FROMDATE VARCHAR(10),
 IN IN_TODATE VARCHAR(10),
 IN IN_ACCCD  VARCHAR(10),
 IN IN_MANAGE_CD_2 VARCHAR(9),
 IN IN_USER_ID VARCHAR(25))
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE   SQLSTATE          CHAR(5) DEFAULT '00000';--
    DECLARE   V_YEAR            VARCHAR(4) DEFAULT '';--
    DECLARE   V_GISU            VARCHAR(4) DEFAULT '';--
    DECLARE   V_MANAGE_CD_1     VARCHAR(9) DEFAULT '';--

    DECLARE GLOBAL TEMPORARY TABLE SESSION.TEMP
    (
        DATE		      VARCHAR(10),
        DATE_T		      VARCHAR(10),
        ACC_NO            VARCHAR(3),
        ACC_NO_T          VARCHAR(3),
        ACC_CD            VARCHAR(10),
        ACC_NM            VARCHAR(60),
        ACC_CONT          VARCHAR(300),
        MANAGE_CD_1       VARCHAR(9),
        MANAGE_ITEM_1     VARCHAR(45),
        MANAGE_CD_1_T     VARCHAR(9),
        MANAGE_ITEM_1_T   VARCHAR(45),
        MANAGE_CD_2       VARCHAR(9),
        MANAGE_ITEM_2     VARCHAR(90),
        MANAGE_CD_2_T     VARCHAR(9),
        MANAGE_ITEM_2_T   VARCHAR(90),
        DR_AMT            DECIMAL(15,0),
        CR_AMT            DECIMAL(15,0),
        JAN_AMT           DECIMAL(15,0)
    )  ON COMMIT PRESERVE ROWS
  WITH REPLACE
  NOT LOGGED;--

--개수 찾기
SELECT GISU INTO V_GISU
  FROM GADMIN.BSACC9
 WHERE START <= IN_FROMDATE
   AND TERMINATION >= IN_FROMDATE
;--

SELECT MANAGE_CD_1 INTO V_MANAGE_CD_1 FROM GADMIN.BSACC2 WHERE ACC_CD = IN_ACCCD;--

P1: BEGIN

    INSERT INTO SESSION.TEMP
    SELECT DATE, DATE AS DATE_T, ACC_NO, ACC_NO AS ACC_N0_T, ACC_CD, ACC_NM, ACC_CONT, MANAGE_CD_1, MANAGE_ITEM_1, MANAGE_CD_1 AS MANAGE_CD_1_T, MANAGE_ITEM_1 AS MANAGE_ITEM_1_T, MANAGE_CD_2, MANAGE_ITEM_2, MANAGE_CD_2 AS MANAGE_CD_2_T , MANAGE_ITEM_2 AS MANAGE_ITEM_2_T, DR_AMT, CR_AMT,
            SUM(JAN_AMT)  OVER (PARTITION BY SUBSTRING(DATE,1,4), MANAGE_CD_1, MANAGE_CD_2 ORDER BY DATE, ROWNUMBER()OVER()) AS JAN_AMT
    FROM (
--            SELECT SUBSTRING(IN_FROMDATE,1,7)||'-00' AS DATE, '' AS ACC_NO, A.ACC_CD, A.ACC_NM, '전기이월' AS ACC_CONT, MANAGE_1 AS MANAGE_CD_1, ITEM_1 AS MANAGE_ITEM_1, MANAGE_2 AS MANAGE_CD_2, ITEM_2 AS MANAGE_ITEM_2, DR_00 AS DR_AMT, CR_00 AS CR_AMT,
--                    CASE WHEN B.DRCR_GB = '차변' OR B.DRCR_GB = '출금' THEN  DR_00 - CR_00  ELSE CR_00 - DR_00 END AS JAN_AMT
            SELECT SUBSTRING(IN_FROMDATE,1,7)||'-00' AS DATE, '' AS ACC_NO, A.ACC_CD, A.ACC_NM, '전기이월' AS ACC_CONT, C.MANAGE_CD_1, C.MANAGE_ITEM_1, C.MANAGE_CD_2, C.MANAGE_ITEM_2, DR_00 AS DR_AMT, CR_00 AS CR_AMT,
                    CASE WHEN B.DRCR_GB = '차변' OR B.DRCR_GB = '출금' THEN  DR_00 - CR_00  ELSE CR_00 - DR_00 END AS JAN_AMT
              FROM GADMIN.TRADEKYE A, GADMIN.BSACC2 B,
                    (
                        SELECT MANAGE_CD AS MANAGE_CD_1, MANAGE_ITEM AS MANAGE_ITEM_1, DETAIL_CD AS MANAGE_CD_2, DETAIL_ITEM AS MANAGE_ITEM_2 FROM GADMIN.BSACC8
                        UNION ALL
                        SELECT '300' AS MANAGE_CD_1, '매입처' AS MANAGE_ITEM_1, SANGHO_CD AS MANAGE_CD_2, SANGHO AS MANAGE_ITEM_2 FROM GADMIN.BSTRADE
                        UNION ALL
                        SELECT '400' AS MANAGE_CD_1, '매출처' AS MANAGE_ITEM_1, SANGHO_CD AS MANAGE_CD_2, SANGHO AS MANAGE_ITEM_2 FROM GADMIN.BSTRADE
                   ) C
            WHERE 1 = 1
              AND A.ACC_CD = B.ACC_CD
              AND B.ACC_GB  IN ('자산','부채','자본')
              AND A.MANAGE_1 = C.MANAGE_CD_1
              AND A.MANAGE_2 = C.MANAGE_CD_2
              AND YEAR = V_GISU
              AND A.ACC_CD = IN_ACCCD
              AND A.MANAGE_2 LIKE IN_MANAGE_CD_2
            UNION ALL
            SELECT TO_CHAR(DATE,'YYYY-MM-DD'), ACC_NO, A.ACC_CD, A.ACC_NM, ACC_CONT, C.MANAGE_CD_1, C.MANAGE_ITEM_1, C.MANAGE_CD_2, C.MANAGE_ITEM_2, DR_AMT, CR_AMT,
                    CASE WHEN B.DRCR_GB = '차변' OR B.DRCR_GB = '출금' THEN  DR_AMT - CR_AMT  ELSE CR_AMT - DR_AMT END AS JAN_AMT
              FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B,
                    (
                        SELECT MANAGE_CD AS MANAGE_CD_1, MANAGE_ITEM AS MANAGE_ITEM_1, DETAIL_CD AS MANAGE_CD_2, DETAIL_ITEM AS MANAGE_ITEM_2 FROM GADMIN.BSACC8
                        UNION ALL
                        SELECT '300' AS MANAGE_CD_1, '매입처' AS MANAGE_ITEM_1, SANGHO_CD AS MANAGE_CD_2, SANGHO AS MANAGE_ITEM_2 FROM GADMIN.BSTRADE
                        UNION ALL
                        SELECT '400' AS MANAGE_CD_1, '매출처' AS MANAGE_ITEM_1, SANGHO_CD AS MANAGE_CD_2, SANGHO AS MANAGE_ITEM_2 FROM GADMIN.BSTRADE
                   ) C
            WHERE 1 = 1
              AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
              AND A.ACC_CD = IN_ACCCD
              AND A.ACC_CD = B.ACC_CD
              AND A.ACC_CD = B.ACC_CD
              AND A.MANAGE_CD_1 = C.MANAGE_CD_1
              AND A.MANAGE_CD_2 = C.MANAGE_CD_2
              AND A.MANAGE_CD_2 LIKE IN_MANAGE_CD_2
         )
      ORDER BY MANAGE_CD_1, MANAGE_CD_2, DATE
    ;--

   IF V_MANAGE_CD_1 = '300' OR V_MANAGE_CD_1 = '400' THEN
           INSERT INTO SESSION.TEMP
           SELECT SUBSTRING(DATE,1,7)||'-88' AS DATE, '' AS DATE_T, '' AS ACC_NO, '' AS ACC_NO_T, A.ACC_CD, A.ACC_NM, '                 월계' AS ACC_CONT, A.MANAGE_CD_1, A.MANAGE_ITEM_1, '' AS MANAGE_CD_1_T, '' AS MANAGE_ITEM_1_T, A.MANAGE_CD_2, B.SANGHO , '' AS MANAGE_CD_2_T, '' AS MANAGE_ITEM_2_T ,  SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, 0 AS JAN_AMT
             FROM SESSION.TEMP A, GADMIN.BSTRADE B
            WHERE 1 = 1
              --AND A.MANAGE_CD_1 = B.MANAGE_CD
              AND A.MANAGE_CD_2 = B.SANGHO_CD
           GROUP BY SUBSTRING(DATE,1,7), A.ACC_CD, A.ACC_NM, A.MANAGE_CD_1, A.MANAGE_ITEM_1 , A.MANAGE_CD_2, B.SANGHO
           ;--

   ELSE
           INSERT INTO SESSION.TEMP
           SELECT SUBSTRING(DATE,1,7)||'-88' AS DATE, '' AS DATE_T, '' AS ACC_NO, '' AS ACC_NO_T, A.ACC_CD, A.ACC_NM, '                 월계' AS ACC_CONT, A.MANAGE_CD_1, B.MANAGE_ITEM, '' AS MANAGE_CD_1_T, '' AS MANAGE_ITEM_1_T, A.MANAGE_CD_2, B.DETAIL_ITEM, '' AS MANAGE_CD_2_T, '' AS MANAGE_ITEM_2_T ,  SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, 0 AS JAN_AMT
             FROM SESSION.TEMP A, GADMIN.BSACC8 B
            WHERE 1 = 1
              AND A.MANAGE_CD_1 = B.MANAGE_CD
              AND A.MANAGE_CD_2 = B.DETAIL_CD
           GROUP BY SUBSTRING(DATE,1,7), A.ACC_CD, A.ACC_NM, A.MANAGE_CD_1, B.MANAGE_ITEM , A.MANAGE_CD_2, B.DETAIL_ITEM
           ;--
   END IF ;--

    INSERT INTO SESSION.TEMP
    SELECT SUBSTRING(DATE,1,7)||'-99' AS DATE, DATE_T, '' AS ACC_NO, ACC_NO_T, A.ACC_CD, A.ACC_NM, '                 누계' AS ACC_CONT,  A.MANAGE_CD_1, A.MANAGE_ITEM_1,  MANAGE_CD_1_T, '' AS MANAGE_ITEM_1_T, A.MANAGE_CD_2, A.MANAGE_ITEM_2, MANAGE_CD_2_T, MANAGE_ITEM_2_T ,
                  SUM(DR_AMT) OVER(PARTITION BY A.MANAGE_CD_1, A.MANAGE_CD_2 ORDER BY SUBSTRING(DATE,1,7)) AS DR_AMT,
                  SUM(CR_AMT) OVER(PARTITION BY A.MANAGE_CD_1, A.MANAGE_CD_2 ORDER BY SUBSTRING(DATE,1,7)) AS CR_AMT,
                  SUM(CASE WHEN B.DRCR_GB = '차변' OR B.DRCR_GB = '출금' THEN  DR_AMT - CR_AMT ELSE CR_AMT - DR_AMT END)
                           OVER(PARTITION BY A.MANAGE_CD_1, A.MANAGE_CD_2  ORDER BY SUBSTRING(DATE,1,7)) AS JAN_AMT
     FROM SESSION.TEMP A, GADMIN.BSACC2 B
    WHERE 1 = 1
      AND A.ACC_CD = B.ACC_CD
      AND TRIM(ACC_CONT) = '월계'
     ;--


END P1;--

P2: BEGIN

    DECLARE CURSOR_TEMP CURSOR WITH RETURN FOR
    SELECT CASE WHEN SUBSTRING(DATE,9,2) = '88' OR SUBSTRING(DATE,9,2) = '99' OR SUBSTRING(DATE,9,2) = '00' THEN '' ELSE DATE END  AS DATE, DATE_T, ACC_NO, ACC_NO_T, MANAGE_CD_1, MANAGE_ITEM_1, MANAGE_CD_1_T, MANAGE_ITEM_1_T, MANAGE_CD_2, MANAGE_ITEM_2, MANAGE_CD_2_T, MANAGE_ITEM_2_T, MANAGE_ITEM_2_2, ACC_CONT, DR_AMT, CR_AMT, JAN_AMT
      FROM (
                SELECT DATE, DATE_T, ACC_NO, ACC_NO_T, MANAGE_CD_1, MANAGE_ITEM_1, MANAGE_CD_2, MANAGE_ITEM_2, MANAGE_CD_1_T, MANAGE_ITEM_1_T, MANAGE_CD_2_T, MANAGE_ITEM_2_T, regexp_replace(MANAGE_ITEM_2,'\(.\)|\(..\)|[[:punct:]]|[0-9]|Ⅰ|Ⅱ|Ⅲ|Ⅳ|Ⅴ|Ⅵ|Ⅶ|Ⅷ|Ⅸ|Ⅹ| ') AS MANAGE_ITEM_2_2, ACC_CONT, DR_AMT, CR_AMT, JAN_AMT
                  FROM SESSION.TEMP
                WHERE 1 = 1
                  AND NOT( DR_AMT = 0 AND CR_AMT = 0 )
                ORDER BY MANAGE_CD_2, regexp_replace(MANAGE_ITEM_2,'\(.\)|\(..\)|[[:punct:]]|[0-9]|Ⅰ|Ⅱ|Ⅲ|Ⅳ|Ⅴ|Ⅵ|Ⅶ|Ⅷ|Ⅸ|Ⅹ| '), DATE, ACC_NO
           )
    ;--

    OPEN CURSOR_TEMP;--
END P2;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN0801_TAB04_SELECT"
(IN IN_FROMDATE VARCHAR(10),
 IN IN_TODATE VARCHAR(10),
 IN IN_ACCCD  VARCHAR(10),
 IN IN_MANAGE_CD_2 VARCHAR(9),
 IN IN_USER_ID VARCHAR(25))
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE   SQLSTATE          CHAR(5) DEFAULT '00000';--
    DECLARE   V_YEAR            VARCHAR(4) DEFAULT '';--
    DECLARE   V_GISU            VARCHAR(4) DEFAULT '';--
    DECLARE   V_MANAGE_CD_1     VARCHAR(9) DEFAULT '';--

    DECLARE GLOBAL TEMPORARY TABLE SESSION.TEMP
    (
        DATE		      VARCHAR(10),
        DATE_T		      VARCHAR(10),
        ACC_NO            VARCHAR(3),
        ACC_NO_T          VARCHAR(3),
        ACC_CD            VARCHAR(10),
        ACC_NM            VARCHAR(60),
        ACC_CONT          VARCHAR(300),
        MANAGE_CD_1       VARCHAR(9),
        MANAGE_ITEM_1     VARCHAR(45),
        MANAGE_CD_1_T     VARCHAR(9),
        MANAGE_ITEM_1_T   VARCHAR(45),
        MANAGE_CD_2       VARCHAR(9),
        MANAGE_ITEM_2     VARCHAR(90),
        MANAGE_CD_2_T     VARCHAR(9),
        MANAGE_ITEM_2_T   VARCHAR(90),
        DR_AMT            DECIMAL(15,0),
        CR_AMT            DECIMAL(15,0),
        JAN_AMT           DECIMAL(15,0)
    )  ON COMMIT PRESERVE ROWS
  WITH REPLACE
  NOT LOGGED;--

--개수 찾기
SELECT GISU INTO V_GISU
  FROM GADMIN.BSACC9
 WHERE START <= IN_FROMDATE
   AND TERMINATION >= IN_FROMDATE
;--

SELECT MANAGE_CD_1 INTO V_MANAGE_CD_1 FROM GADMIN.BSACC2 WHERE ACC_CD = IN_ACCCD;--

P1: BEGIN

    INSERT INTO GADMIN.TEMP_TEMP
--    SELECT 
    SELECT DATE, DATE AS DATE_T, ACC_NO, ACC_NO AS ACC_N0_T, ACC_CD, ACC_NM, ACC_CONT, MANAGE_CD_1, MANAGE_ITEM_1, MANAGE_CD_1 AS MANAGE_CD_1_T, MANAGE_ITEM_1 AS MANAGE_ITEM_1_T, MANAGE_CD_2, MANAGE_ITEM_2, MANAGE_CD_2 AS MANAGE_CD_2_T , MANAGE_ITEM_2 AS MANAGE_ITEM_2_T, DR_AMT, CR_AMT,
            SUM(JAN_AMT)  OVER (PARTITION BY SUBSTRING(DATE,1,4), MANAGE_CD_1, MANAGE_CD_2 ORDER BY DATE, ROWNUMBER()OVER()) AS JAN_AMT
    FROM (
--            SELECT SUBSTRING(IN_FROMDATE,1,7)||'-00' AS DATE, '' AS ACC_NO, A.ACC_CD, A.ACC_NM, '전기이월' AS ACC_CONT, MANAGE_1 AS MANAGE_CD_1, ITEM_1 AS MANAGE_ITEM_1, MANAGE_2 AS MANAGE_CD_2, ITEM_2 AS MANAGE_ITEM_2, DR_00 AS DR_AMT, CR_00 AS CR_AMT,
--                    CASE WHEN B.DRCR_GB = '차변' OR B.DRCR_GB = '출금' THEN  DR_00 - CR_00  ELSE CR_00 - DR_00 END AS JAN_AMT
            SELECT SUBSTRING(IN_FROMDATE,1,7)||'-00' AS DATE, '' AS ACC_NO, A.ACC_CD, A.ACC_NM, '전기이월' AS ACC_CONT, C.MANAGE_CD_1, C.MANAGE_ITEM_1, C.MANAGE_CD_2, C.MANAGE_ITEM_2, DR_00 AS DR_AMT, CR_00 AS CR_AMT,
                    CASE WHEN B.DRCR_GB = '차변' OR B.DRCR_GB = '출금' THEN  DR_00 - CR_00  ELSE CR_00 - DR_00 END AS JAN_AMT
              FROM GADMIN.TRADEKYE A, GADMIN.BSACC2 B,
                    (
                        SELECT MANAGE_CD AS MANAGE_CD_1, MANAGE_ITEM AS MANAGE_ITEM_1, DETAIL_CD AS MANAGE_CD_2, DETAIL_ITEM AS MANAGE_ITEM_2 FROM GADMIN.BSACC8
                        UNION ALL
                        SELECT '300' AS MANAGE_CD_1, '매입처' AS MANAGE_ITEM_1, SANGHO_CD AS MANAGE_CD_2, SANGHO AS MANAGE_ITEM_2 FROM GADMIN.BSTRADE
                        UNION ALL
                        SELECT '400' AS MANAGE_CD_1, '매출처' AS MANAGE_ITEM_1, SANGHO_CD AS MANAGE_CD_2, SANGHO AS MANAGE_ITEM_2 FROM GADMIN.BSTRADE
                   ) C
            WHERE 1 = 1
              AND A.ACC_CD = B.ACC_CD
              AND B.ACC_GB  IN ('자산','부채','자본')
              AND A.MANAGE_1 = C.MANAGE_CD_1
              AND A.MANAGE_2 = C.MANAGE_CD_2
              AND YEAR = V_GISU
              AND A.ACC_CD = IN_ACCCD
              AND A.MANAGE_2 LIKE IN_MANAGE_CD_2
            UNION ALL
            SELECT TO_CHAR(DATE,'YYYY-MM-DD'), ACC_NO, A.ACC_CD, A.ACC_NM, ACC_CONT, C.MANAGE_CD_1, C.MANAGE_ITEM_1, C.MANAGE_CD_2, C.MANAGE_ITEM_2, DR_AMT, CR_AMT,
                    CASE WHEN B.DRCR_GB = '차변' OR B.DRCR_GB = '출금' THEN  DR_AMT - CR_AMT  ELSE CR_AMT - DR_AMT END AS JAN_AMT
              FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B,
                    (
                        SELECT MANAGE_CD AS MANAGE_CD_1, MANAGE_ITEM AS MANAGE_ITEM_1, DETAIL_CD AS MANAGE_CD_2, DETAIL_ITEM AS MANAGE_ITEM_2 FROM GADMIN.BSACC8
                        UNION ALL
                        SELECT '300' AS MANAGE_CD_1, '매입처' AS MANAGE_ITEM_1, SANGHO_CD AS MANAGE_CD_2, SANGHO AS MANAGE_ITEM_2 FROM GADMIN.BSTRADE
                        UNION ALL
                        SELECT '400' AS MANAGE_CD_1, '매출처' AS MANAGE_ITEM_1, SANGHO_CD AS MANAGE_CD_2, SANGHO AS MANAGE_ITEM_2 FROM GADMIN.BSTRADE
                   ) C
            WHERE 1 = 1
              AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
              AND A.ACC_CD = IN_ACCCD
              AND A.ACC_CD = B.ACC_CD
              AND A.ACC_CD = B.ACC_CD
              AND A.MANAGE_CD_1 = C.MANAGE_CD_1
              AND A.MANAGE_CD_2 = C.MANAGE_CD_2
              AND A.MANAGE_CD_2 LIKE IN_MANAGE_CD_2
         )
      ORDER BY MANAGE_CD_1, MANAGE_CD_2, DATE
    ;--

   IF V_MANAGE_CD_1 = '300' OR V_MANAGE_CD_1 = '400' THEN
           INSERT INTO GADMIN.TEMP_TEMP
           SELECT SUBSTRING(DATE,1,7)||'-88' AS DATE, '' AS DATE_T, '' AS ACC_NO, '' AS ACC_NO_T, A.ACC_CD, A.ACC_NM, '' AS ACC_CONT, A.MANAGE_CD_1, A.MANAGE_ITEM_1, '' AS MANAGE_CD_1_T, '월계' AS MANAGE_ITEM_1_T, A.MANAGE_CD_2, B.SANGHO , '' AS MANAGE_CD_2_T, '' AS MANAGE_ITEM_2_T ,  SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, 0 AS JAN_AMT
             FROM GADMIN.TEMP_TEMP A, GADMIN.BSTRADE B
            WHERE 1 = 1
              --AND A.MANAGE_CD_1 = B.MANAGE_CD
              AND A.MANAGE_CD_2 = B.SANGHO_CD
           GROUP BY SUBSTRING(DATE,1,7), A.ACC_CD, A.ACC_NM, A.MANAGE_CD_1, A.MANAGE_ITEM_1 , A.MANAGE_CD_2, B.SANGHO
           ;--

   ELSE
           INSERT INTO GADMIN.TEMP_TEMP
           SELECT SUBSTRING(DATE,1,7)||'-88' AS DATE, '' AS DATE_T, '' AS ACC_NO, '' AS ACC_NO_T, A.ACC_CD, A.ACC_NM, '' AS ACC_CONT, A.MANAGE_CD_1, B.MANAGE_ITEM, '' AS MANAGE_CD_1_T, '월계' AS MANAGE_ITEM_1_T, A.MANAGE_CD_2, B.DETAIL_ITEM, '' AS MANAGE_CD_2_T, '' AS MANAGE_ITEM_2_T ,  SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT, 0 AS JAN_AMT
             FROM GADMIN.TEMP_TEMP A, GADMIN.BSACC8 B
            WHERE 1 = 1
              AND A.MANAGE_CD_1 = B.MANAGE_CD
              AND A.MANAGE_CD_2 = B.DETAIL_CD
           GROUP BY SUBSTRING(DATE,1,7), A.ACC_CD, A.ACC_NM, A.MANAGE_CD_1, B.MANAGE_ITEM , A.MANAGE_CD_2, B.DETAIL_ITEM
           ;--
   END IF ;--

    INSERT INTO GADMIN.TEMP_TEMP
    SELECT SUBSTRING(DATE,1,7)||'-99' AS DATE, DATE_T, '' AS ACC_NO, ACC_NO_T, A.ACC_CD, A.ACC_NM, '' AS ACC_CONT,  A.MANAGE_CD_1, A.MANAGE_ITEM_1,  MANAGE_CD_1_T, '누계' AS MANAGE_ITEM_1_T, A.MANAGE_CD_2, A.MANAGE_ITEM_2, MANAGE_CD_2_T, MANAGE_ITEM_2_T ,
                  SUM(DR_AMT) OVER(PARTITION BY A.MANAGE_CD_1, A.MANAGE_CD_2 ORDER BY SUBSTRING(DATE,1,7)) AS DR_AMT,
                  SUM(CR_AMT) OVER(PARTITION BY A.MANAGE_CD_1, A.MANAGE_CD_2 ORDER BY SUBSTRING(DATE,1,7)) AS CR_AMT,
                  SUM(CASE WHEN B.DRCR_GB = '차변' OR B.DRCR_GB = '출금' THEN  DR_AMT - CR_AMT ELSE CR_AMT - DR_AMT END)
                           OVER(PARTITION BY A.MANAGE_CD_1, A.MANAGE_CD_2  ORDER BY SUBSTRING(DATE,1,7)) AS JAN_AMT
     FROM GADMIN.TEMP_TEMP A, GADMIN.BSACC2 B
    WHERE 1 = 1
      AND A.ACC_CD = B.ACC_CD
      AND MANAGE_ITEM_1_T = '월계'
     ;--


END P1;--

P2: BEGIN

    DECLARE CURSOR_TEMP CURSOR WITH RETURN FOR
    SELECT CASE WHEN SUBSTRING(DATE,9,2) = '88' OR SUBSTRING(DATE,9,2) = '99' OR SUBSTRING(DATE,9,2) = '00' THEN '' ELSE DATE END AS DATE, DATE_T, ACC_NO, ACC_NO_T, MANAGE_CD_1, MANAGE_ITEM_1, MANAGE_CD_1_T, MANAGE_ITEM_1_T, MANAGE_CD_2, MANAGE_ITEM_2, MANAGE_CD_2_T, MANAGE_ITEM_2_T, MANAGE_ITEM_2_2, ACC_CONT, DR_AMT, CR_AMT, JAN_AMT
      FROM (
                SELECT DATE, DATE_T, ACC_NO, ACC_NO_T, MANAGE_CD_1, MANAGE_ITEM_1, MANAGE_CD_2, MANAGE_ITEM_2, MANAGE_CD_1_T, MANAGE_ITEM_1_T, MANAGE_CD_2_T, MANAGE_ITEM_2_T, regexp_replace(MANAGE_ITEM_2,'\(.\)|\(..\)|[[:punct:]]|[0-9]|Ⅰ|Ⅱ|Ⅲ|Ⅳ|Ⅴ|Ⅵ|Ⅶ|Ⅷ|Ⅸ|Ⅹ| ') AS MANAGE_ITEM_2_2, ACC_CONT, DR_AMT, CR_AMT, JAN_AMT
                  FROM GADMIN.TEMP_TEMP
                WHERE 1 = 1
--                  AND NOT( DR_AMT = 0 AND CR_AMT = 0 )
                ORDER BY MANAGE_CD_2, regexp_replace(MANAGE_ITEM_2,'\(.\)|\(..\)|[[:punct:]]|[0-9]|Ⅰ|Ⅱ|Ⅲ|Ⅳ|Ⅴ|Ⅵ|Ⅶ|Ⅷ|Ⅸ|Ⅹ| '), DATE, ACC_NO
           )
    ;--

    OPEN CURSOR_TEMP;--
END P2;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN0801_TAB05_SELECT"
(IN IN_FROMDATE VARCHAR(10), IN IN_TODATE VARCHAR(10), IN IN_FROMACCCD VARCHAR(7), IN IN_TOACCCD VARCHAR(7),  IN IN_USER_ID VARCHAR(25))
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE   SQLSTATE          CHAR(5) DEFAULT '00000';--

    DECLARE GLOBAL TEMPORARY TABLE SESSION.TEMP
    (
        ACC_CD          VARCHAR(10),
        ACC_NM          VARCHAR(60),
        MANAGE_1        VARCHAR(9),
        ITEM_1          VARCHAR(100),
        MANAGE_2        VARCHAR(9),
        ITEM_2          VARCHAR(100),
        ACC_CD_T          VARCHAR(10),
        ACC_NM_T          VARCHAR(60),
        MANAGE_1_T        VARCHAR(9),
        ITEM_1_T          VARCHAR(100),
        MANAGE_2_T        VARCHAR(9),
        ITEM_2_T          VARCHAR(100),
        JAN_AMT         DECIMAL(20,5),
        PRE_AMT         DECIMAL(20,5)
    )  ON COMMIT PRESERVE ROWS
  WITH REPLACE
  NOT LOGGED;	--

P1: BEGIN

    INSERT INTO SESSION.TEMP
        SELECT *
       FROM (
                SELECT ACC_CD, ACC_NM, MANAGE_CD_1, MANAGE_ITEM_1, MANAGE_CD_2, MANAGE_ITEM_2, ACC_CD AS ACC_CD_T, ACC_NM AS ACC_NM_T, MANAGE_CD_1 AS MANAGE_1_T , MANAGE_ITEM_1 AS ITEM_1_T, MANAGE_CD_2 AS MANAGE_2_T, MANAGE_ITEM_2 AS ITEM_2_T, SUM(JAN_AMT) + SUM(PRE_AMT) AS JAN_AMT,  SUM(PRE_AMT) AS PRE_AMT
                  FROM (
                            SELECT A.ACC_CD, A.ACC_NM, A.MANAGE_CD_1, A.MANAGE_ITEM_1, A.MANAGE_CD_2, A.MANAGE_ITEM_2, CASE WHEN A.DRCR_GB = '차변' OR A.DRCR_GB = '출금' THEN SUM(DR_AMT - CR_AMT)
                                                                                                                                         ELSE SUM(CR_AMT - DR_AMT) END AS JAN_AMT, 0 AS PRE_AMT
                              FROM (
                                        SELECT A.DATE, A.ACC_CD, A.ACC_NM, B.DRCR_GB, A.MANAGE_CD_1, A.MANAGE_ITEM_1, A.MANAGE_CD_2, A.MANAGE_ITEM_2, DR_AMT, CR_AMT
                                           FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                                          WHERE A.ACC_CD = B.ACC_CD
                                    ) A
                             WHERE 1 = 1
                                AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                                AND LENGTH(COALESCE(A.MANAGE_CD_1,'')) > 1
                            GROUP BY A.ACC_CD, A.ACC_NM,  A.MANAGE_CD_1, A.MANAGE_ITEM_1, A.MANAGE_CD_2, A.MANAGE_ITEM_2, A.DRCR_GB
                            UNION ALL
                            SELECT B.ACC_CD, B.ACC_NM, B.MANAGE_1, B.ITEM_1, B.MANAGE_2, B.ITEM_2, 0 AS JAN_AMT, CASE WHEN B.DRCR_GB = '차변' OR B.DRCR_GB = '출금' THEN SUM(B.DR_AMT) - SUM(B.CR_AMT)
                                                                                                                                   ELSE SUM(B.CR_AMT) - SUM(B.DR_AMT) END AS PRE_AMT
                              FROM (
                                        SELECT B.ACC_CD, B.ACC_NM, C.DRCR_GB, B.MANAGE_1, B.ITEM_1, B.MANAGE_2, B.ITEM_2, DR_AMT, CR_AMT
                                           FROM TABLE(GADMIN.SF_FIN_PRE_MANAGE_SELECT(IN_FROMDATE)) B, GADMIN.BSACC2 C
                                          WHERE B.ACC_CD = C.ACC_CD
                                    ) B
                            GROUP BY B.ACC_CD, B.ACC_NM, B.MANAGE_1, B.ITEM_1, B.MANAGE_2, B.ITEM_2, B.DRCR_GB
                        )
                 GROUP BY ACC_CD, ACC_NM, MANAGE_CD_1, MANAGE_ITEM_1, MANAGE_CD_2, MANAGE_ITEM_2
             ) A
     WHERE 1 = 1
       AND NOT (JAN_AMT = 0 AND PRE_AMT = 0)
       AND ACC_CD < '3000000'
       AND ACC_CD >= IN_FROMACCCD  --추가 211022
       AND ACC_CD <= IN_TOACCCD    --추가 211022
    ORDER BY ACC_CD, MANAGE_CD_1
    /*
    SELECT *
       FROM (
                SELECT ACC_CD, ACC_NM, MANAGE_CD_1, MANAGE_ITEM_1, MANAGE_CD_2, MANAGE_ITEM_2, SUM((DR_AMT - CR_AMT) + (BE_DR_AMT - BE_CR_AMT)) AS JAN_AMT,  MAX(BE_DR_AMT - BE_CR_AMT) AS PRE_AMT
                  FROM (
                            SELECT A.ACC_CD, A.ACC_NM, A.MANAGE_CD_1, A.MANAGE_ITEM_1, A.MANAGE_CD_2, A.MANAGE_ITEM_2, SUM(A.DR_AMT) AS DR_AMT, SUM(A.CR_AMT) AS CR_AMT, 0 AS BE_DR_AMT, 0 AS BE_CR_AMT
                              FROM (
                                        SELECT A.DATE, A.ACC_CD, A.ACC_NM, A.MANAGE_CD_1, A.MANAGE_ITEM_1, A.MANAGE_CD_2, A.MANAGE_ITEM_2, CASE B.DRCR_GB WHEN '차변' THEN A.DR_AMT ELSE A.CR_AMT END AS DR_AMT
                                                , CASE B.DRCR_GB WHEN '차변' THEN A.CR_AMT ELSE A.DR_AMT END AS CR_AMT
                                           FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                                          WHERE A.ACC_CD = B.ACC_CD
                                    ) A
                             WHERE 1 = 1
                                AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                                AND LENGTH(COALESCE(A.MANAGE_CD_1,'')) > 1
                            GROUP BY A.ACC_CD, A.ACC_NM, A.MANAGE_CD_1, A.MANAGE_ITEM_1, A.MANAGE_CD_2, A.MANAGE_ITEM_2
                            UNION ALL
                            SELECT B.ACC_CD, B.ACC_NM, B.MANAGE_1, B.ITEM_1, B.MANAGE_2, B.ITEM_2, 0 AS DR_AMT, 0 AS CR_AMT, SUM(B.DR_AMT) AS BE_DR_AMT, SUM(B.CR_AMT) AS BE_CR_AMT
                              FROM (
                                        SELECT B.ACC_CD, B.ACC_NM, B.MANAGE_1, B.ITEM_1, B.MANAGE_2, B.ITEM_2, CASE C.DRCR_GB WHEN '차변' THEN B.DR_AMT ELSE B.CR_AMT END AS DR_AMT
                                                , CASE C.DRCR_GB WHEN '차변' THEN B.CR_AMT ELSE B.DR_AMT END AS CR_AMT
                                           FROM TABLE(GADMIN.SF_FIN_PRE_MANAGE_SELECT(IN_FROMDATE)) B, GADMIN.BSACC2 C
                                          WHERE B.ACC_CD = C.ACC_CD
                                    ) B
                            GROUP BY B.ACC_CD, B.ACC_NM, B.MANAGE_1, B.ITEM_1, B.MANAGE_2, B.ITEM_2
                        )
                 GROUP BY ACC_CD, ACC_NM, MANAGE_CD_1, MANAGE_ITEM_1, MANAGE_CD_2, MANAGE_ITEM_2
             ) A
     WHERE 1 = 1
       AND NOT (JAN_AMT = 0 AND PRE_AMT = 0)
    ORDER BY ACC_CD, MANAGE_CD_1
    */
    ;    --

    INSERT INTO SESSION.TEMP
    SELECT ACC_CD, ACC_NM, '' AS MANAGE_1, '' AS ITEM_1, '' AS MANAGE_2, '' AS ITEM_2, '' AS ACC_CD_T, '                    소계' AS ACC_NM_T, '' AS MANAGE_1_T, '' AS ITEM_1_T, '' AS MANAGE_2_T, '' AS ITEM_2_T ,SUM(JAN_AMT) AS JAN_AMT, SUM(PRE_AMT) AS PRE_AMT
      FROM SESSION.TEMP
    GROUP BY ACC_CD, ACC_NM;--

END P1;--

P2: BEGIN

    DECLARE CURSOR_TEMP CURSOR WITH RETURN FOR
    SELECT *
      FROM SESSION.TEMP
    ORDER BY ACC_CD;--

    OPEN CURSOR_TEMP;--
END P2;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN0901_TAB01_01_SELECT"
( IN IN_FROMDATE VARCHAR(10)
, IN IN_TODATE VARCHAR(10)
, IN IN_ACC_CD VARCHAR(10)
, IN IN_YEAR VARCHAR(3)
, IN IN_USER_ID VARCHAR(25)
)
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL
MAIN: BEGIN

    DECLARE SQLSTATE CHAR(5) DEFAULT '00000';--

    P1: BEGIN
		DECLARE CURSOR_FIN CURSOR WITH RETURN FOR
        SELECT A.MANAGE_ITEM_1, A.MANAGE_CD_1, JUN_AMT, DR_AMT, CR_AMT, CASE B.DRCR_GB WHEN '차변' THEN JUN_AMT + DR_AMT - CR_AMT ELSE JUN_AMT + CR_AMT - DR_AMT END AS JAN_AMT
          FROM (
                    SELECT ACC_CD, MANAGE_ITEM_1, MANAGE_CD_1, SUM(JUN_AMT) AS JUN_AMT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT
                      FROM (
                                SELECT ACC_CD, ITEM_1 AS MANAGE_ITEM_1, MANAGE_1 AS MANAGE_CD_1, SUM(CASE DRCR_GB WHEN '차변' THEN ( DR_00 - CR_00 )  ELSE ( CR_00 - DR_00 ) END) AS JUN_AMT, 0 AS DR_AMT, 0 AS CR_AMT
                                  FROM GADMIN.TRADEKYE A
                                 WHERE 1 = 1
                                   AND ACC_CD LIKE IN_ACC_CD
                                   AND YEAR = IN_YEAR
                                   AND CASE DRCR_GB WHEN '차변' THEN ( DR_00 - CR_00 )  ELSE ( CR_00 - DR_00 ) END <> 0
                                GROUP BY ACC_CD, MANAGE_1, ITEM_1
                                UNION ALL
                                SELECT ACC_CD, MANAGE_ITEM_1, MANAGE_CD_1, 0 AS JUN_AMT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT
                                  FROM GADMIN.ACCOU1 A
                                 WHERE 1 = 1
                                   AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                                   AND A.ACC_CD LIKE IN_ACC_CD
                                 GROUP BY ACC_CD, MANAGE_ITEM_1, MANAGE_CD_1
                            )
                    GROUP BY ACC_CD, MANAGE_ITEM_1, MANAGE_CD_1
               ) A
               LEFT OUTER JOIN GADMIN.BSACC2 B ON ( A.ACC_CD = B.ACC_CD)
       ;--

	    OPEN CURSOR_FIN;--
    END P1;--

END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN0901_TAB01_02_SELECT"
( IN IN_FROMDATE VARCHAR(10)
, IN IN_TODATE VARCHAR(10)
, IN IN_ACC_CD VARCHAR(10)
, IN IN_MANAGE_CD_1 VARCHAR(9)
, IN IN_YEAR VARCHAR(3)
, IN IN_USER_ID VARCHAR(25)
)
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL
MAIN: BEGIN

    DECLARE SQLSTATE CHAR(5) DEFAULT '00000';--

    P1: BEGIN
		DECLARE CURSOR_FIN CURSOR WITH RETURN FOR
        SELECT A.MANAGE_ITEM_1, A.MANAGE_CD_1, A.MANAGE_ITEM_2, A.MANAGE_CD_2, JUN_AMT, DR_AMT, CR_AMT, CASE B.DRCR_GB WHEN '차변' THEN JUN_AMT + DR_AMT - CR_AMT ELSE JUN_AMT + CR_AMT - DR_AMT END AS JAN_AMT
          FROM (
                    SELECT ACC_CD, MANAGE_ITEM_1, MANAGE_CD_1, MANAGE_ITEM_2, MANAGE_CD_2, SUM(JUN_AMT) AS JUN_AMT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT
                      FROM (
                                SELECT ACC_CD, ITEM_1 AS MANAGE_CD_1, MANAGE_1 AS MANAGE_ITEM_1, ITEM_2 AS MANAGE_CD_2, MANAGE_2 AS MANAGE_ITEM_2, SUM(CASE DRCR_GB WHEN '차변' THEN ( DR_00 - CR_00 )  ELSE ( CR_00 - DR_00 ) END) AS JUN_AMT, 0 AS DR_AMT, 0 AS CR_AMT
                                  FROM GADMIN.TRADEKYE A
                                 WHERE 1 = 1
                                   AND ACC_CD = IN_ACC_CD
                                   AND ITEM_1 LIKE IN_MANAGE_CD_1
                                   AND YEAR = IN_YEAR
                                   AND CASE DRCR_GB WHEN '차변' THEN ( DR_00 - CR_00 )  ELSE ( CR_00 - DR_00 ) END <> 0
                                GROUP BY ACC_CD, MANAGE_1, ITEM_1, MANAGE_2, ITEM_2
                                UNION ALL
                                SELECT ACC_CD, MANAGE_ITEM_1, MANAGE_CD_1, MANAGE_ITEM_2, MANAGE_CD_2, 0 AS JUN_AMT, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT
                                  FROM GADMIN.ACCOU1 A
                                 WHERE 1 = 1
                                   AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                                   AND A.ACC_CD LIKE IN_ACC_CD
                                   AND MANAGE_CD_1 LIKE IN_MANAGE_CD_1
                                 GROUP BY ACC_CD, MANAGE_ITEM_1, MANAGE_CD_1, MANAGE_ITEM_2, MANAGE_CD_2
                            )
                    GROUP BY ACC_CD, MANAGE_ITEM_1, MANAGE_CD_1, MANAGE_ITEM_2, MANAGE_CD_2
               ) A
               LEFT OUTER JOIN GADMIN.BSACC2 B ON ( A.ACC_CD = B.ACC_CD)
        ORDER BY A.MANAGE_ITEM_1, A.MANAGE_CD_1, A.MANAGE_ITEM_2, A.MANAGE_CD_2
       ;--

	    OPEN CURSOR_FIN;--
    END P1;--

END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN0901_TAB03_SELECT" (IN IN_FROMDATE
VARCHAR(10), IN IN_TODATE VARCHAR(10), IN IN_USER_ID VARCHAR(25))
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE   SQLSTATE          CHAR(5) DEFAULT '00000';--

    DECLARE GLOBAL TEMPORARY TABLE SESSION.TEMP
    (
        ACC_CD          VARCHAR(10),
        ACC_NM          VARCHAR(60),
        MANAGE_1        VARCHAR(9),
        ITEM_1          VARCHAR(100),
        MANAGE_2        VARCHAR(9),
        ITEM_2          VARCHAR(100),
        JAN_AMT         DECIMAL(20,5),
        PRE_AMT         DECIMAL(20,5)
    )  ON COMMIT PRESERVE ROWS
  WITH REPLACE
  NOT LOGGED;	--

P1: BEGIN

    INSERT INTO SESSION.TEMP
    SELECT *
       FROM (
                SELECT ACC_CD, ACC_NM, MANAGE_CD_1, MANAGE_ITEM_1, MANAGE_CD_2, MANAGE_ITEM_2, SUM((DR_AMT - CR_AMT) + (BE_DR_AMT - BE_CR_AMT)) AS JAN_AMT,  MAX(BE_DR_AMT - BE_CR_AMT) AS PRE_AMT
                  FROM (
                            SELECT A.ACC_CD, A.ACC_NM, A.MANAGE_CD_1, A.MANAGE_ITEM_1, A.MANAGE_CD_2, A.MANAGE_ITEM_2, SUM(A.DR_AMT) AS DR_AMT, SUM(A.CR_AMT) AS CR_AMT, 0 AS BE_DR_AMT, 0 AS BE_CR_AMT
                              FROM (
                                        SELECT A.DATE, A.ACC_CD, A.ACC_NM, A.MANAGE_CD_1, A.MANAGE_ITEM_1, A.MANAGE_CD_2, A.MANAGE_ITEM_2, CASE B.DRCR_GB WHEN '차변' THEN A.DR_AMT ELSE A.CR_AMT END AS DR_AMT
                                                , CASE B.DRCR_GB WHEN '차변' THEN A.CR_AMT ELSE A.DR_AMT END AS CR_AMT
                                           FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                                          WHERE A.ACC_CD = B.ACC_CD
                                    ) A
                             WHERE 1 = 1
                                AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                                AND LENGTH(COALESCE(A.MANAGE_CD_1,'')) > 1
                            GROUP BY A.ACC_CD, A.ACC_NM, A.MANAGE_CD_1, A.MANAGE_ITEM_1, A.MANAGE_CD_2, A.MANAGE_ITEM_2
                            UNION ALL
                            SELECT B.ACC_CD, B.ACC_NM, B.MANAGE_1, B.ITEM_1, B.MANAGE_2, B.ITEM_2, 0 AS DR_AMT, 0 AS CR_AMT, SUM(B.DR_AMT) AS BE_DR_AMT, SUM(B.CR_AMT) AS BE_CR_AMT
                              FROM (
                                        SELECT B.ACC_CD, B.ACC_NM, B.MANAGE_1, B.ITEM_1, B.MANAGE_2, B.ITEM_2, CASE C.DRCR_GB WHEN '차변' THEN B.DR_AMT ELSE B.CR_AMT END AS DR_AMT
                                                , CASE C.DRCR_GB WHEN '차변' THEN B.CR_AMT ELSE B.DR_AMT END AS CR_AMT
                                           FROM TABLE(GADMIN.SF_FIN_PRE_MANAGE_SELECT(IN_FROMDATE)) B, GADMIN.BSACC2 C
                                          WHERE B.ACC_CD = C.ACC_CD
                                    ) B
                            GROUP BY B.ACC_CD, B.ACC_NM, B.MANAGE_1, B.ITEM_1, B.MANAGE_2, B.ITEM_2
                        )
                 GROUP BY ACC_CD, ACC_NM, MANAGE_CD_1, MANAGE_ITEM_1, MANAGE_CD_2, MANAGE_ITEM_2
             ) A
     WHERE 1 = 1
       AND NOT (JAN_AMT = 0 AND PRE_AMT = 0)
    ORDER BY ACC_CD, MANAGE_CD_1;    --

    INSERT INTO SESSION.TEMP
    SELECT ACC_CD, ACC_NM, '' AS MANAGE_1, ' 소  계 ' AS ITEM_1, '' AS MANAGE_2, '' AS ITEM_2, SUM(JAN_AMT) AS JAN_AMT, SUM(PRE_AMT) AS PRE_AMT
      FROM SESSION.TEMP
    GROUP BY ACC_CD, ACC_NM;--

END P1;--

P2: BEGIN

    DECLARE CURSOR_TEMP CURSOR WITH RETURN FOR
    SELECT *
      FROM SESSION.TEMP
    ORDER BY ACC_CD;--

    OPEN CURSOR_TEMP;--
END P2;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN1101_TAB01_HAP_SELECT"
(IN IN_FROMDATE VARCHAR(10), IN IN_TODATE VARCHAR(10), IN IN_USER_ID VARCHAR(25))
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE   SQLSTATE          CHAR(5) DEFAULT '00000';--
    DECLARE   TOT_JS_DR               DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   TOT_BJ_CR               DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   TOT_SON_DR               DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   TOT_SON_CR               DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   JAN_JS_DR               DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   JAN_BJ_CR               DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   JAN_SON_DR               DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   JAN_SON_CR               DECIMAL(20,5) DEFAULT 0.0;--

    DECLARE GLOBAL TEMPORARY TABLE SESSION.TEMP
    (
        DR_JAN_AMT      DECIMAL(20,5) DEFAULT 0,
        DR_AMT          DECIMAL(20,5) DEFAULT 0,
        ACC_CD          VARCHAR(10)   DEFAULT '',
        ACC_NM          VARCHAR(60)   DEFAULT '',
        CR_AMT		    DECIMAL(20,5) DEFAULT 0,
        CR_JAN_AMT      DECIMAL(20,5) DEFAULT 0
    )  ON COMMIT PRESERVE ROWS
  WITH REPLACE
  NOT LOGGED;--

P1: BEGIN

    INSERT INTO SESSION.TEMP
        WITH HAP_ACC AS (
            SELECT CASE B.DRCR_GB WHEN '차변'THEN A.DR_AMT - A.CR_AMT ELSE 0 END AS DR_JAN_AMT, A.DR_AMT, B.ACC_CD, B.ACC_NM,  A.CR_AMT, (CASE B.DRCR_GB WHEN '대변'THEN A.CR_AMT - A.DR_AMT ELSE 0 END) AS CR_JAN_AMT, (case when CHAGAM_GB = '차감' then -1 else 1 end) as sign, b.levelup_cd as levelup_cd
               FROM (
                                SELECT A.ACC_CD, MAX(A.ACC_NM) AS ACC_NM, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT   --일반계정 집계
                                  FROM (
                                             SELECT ACC_CD, ACC_NM, DR_AMT, CR_AMT
                                               FROM GADMIN.ACCOU1
                                              WHERE DATE BETWEEN IN_FROMDATE AND IN_TODATE
                                             UNION ALL
                                             SELECT '1110101' AS ACC_CD, '현          금 ' AS ACC_NM, SUM(CR_AMT) AS DR_AMT, SUM(DR_AMT) AS CR_AMT   --현금계정 집계
                                               FROM GADMIN.ACCOU1
                                              WHERE DRCR_GB IN ('입금','출금')
                                                AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                                             UNION ALL
                                             SELECT ACC_CD, ACC_NM, DR_AMT, CR_AMT                  --전기이월 포함
                                               FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_FROMDATE))
                                        ) A, GADMIN.BSACC2 B
                         WHERE 1 = 1
                           AND A.ACC_CD = B.ACC_CD
                        GROUP BY A.ACC_CD
                    ) A RIGHT OUTER JOIN GADMIN.BSACC2 B ON A.ACC_CD = B.ACC_CD

        )
        SELECT 0 AS DR_JAN_AMT,
                (SELECT coalesce(SUM(sign * DR_AMT),0)
                  FROM HAP_ACC
                 START WITH acc_cd = main.acc_cd
               CONNECT BY PRIOR acc_cd = LEVELUP_CD
               ) as DR_AMT
             , ACC_CD, ACC_NM
             , (SELECT coalesce(SUM(sign * CR_AMT),0)
                  FROM HAP_ACC
                 START WITH acc_cd = main.acc_cd
               CONNECT BY PRIOR acc_cd = LEVELUP_CD
               ) as CR_AMT,
               0 AS CR_JAN_AMT
          FROM HAP_ACC main
--         START WITH coalesce(LEVELUP_CD,'')=''
--        CONNECT BY PRIOR acc_cd = LEVELUP_CD --order by acc_cd
        UNION ALL
        SELECT SUM(DR_JAN_AMT) AS DR_JAN_AMT, SUM(DR_AMT) AS DR_AMT, '9999999' AS ACC_CD, '합          계 ' AS ACC_NM, SUM(CR_AMT) AS CR_AMT, SUM(CR_JAN_AMT) AS CR_JAN_AMT
         FROM HAP_ACC
        ;--



END P1;--
P2: BEGIN

    DECLARE CURSOR_TEMP CURSOR WITH RETURN FOR
    SELECT *
      FROM (
             SELECT CASE DRCR_GB WHEN '차변' THEN coalesce(DR_AMT - CR_AMT,0) END AS DR_JAN_AMT, DR_AMT, ACC_CD, ACC_NM, CR_AMT, CASE DRCR_GB WHEN '대변' THEN coalesce(CR_AMT - DR_AMT,0) END AS CR_JAN_AMT, CHULRYEOK_CD
               FROM (
                                 SELECT A.*, B.CHULRYEOK_CD, B.DRCR_GB
                                   FROM SESSION.TEMP A, GADMIN.BSACC2 B
                                 WHERE 1 = 1
                                   AND A.ACC_CD = B.ACC_CD
                                   AND B.ACC_CD != '7300909'
                                 UNION ALL
                                 SELECT A.*, '9000000', ''
                                   FROM SESSION.TEMP A
                                  WHERE A.ACC_CD = '9000000'
                              )
             WHERE 1 = 1
               AND NOT ( DR_AMT = 0 AND CR_AMT = 0 )
             UNION ALL
             SELECT A.DR_JAN_AMT, A.DR_AMT, A.ACC_CD, A.ACC_NM, A.CR_AMT, A.CR_JAN_AMT, '9999999' AS CHULRYEOK_CD
               FROM SESSION.TEMP A
              WHERE A.ACC_CD = '9999999'
    )
    ORDER BY CHULRYEOK_CD
    ;--

    OPEN CURSOR_TEMP;--
END P2;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN1101_TAB01_NEW_SELECT"
(IN IN_FROMDATE VARCHAR(10), IN IN_TODATE VARCHAR(10), IN IN_USER_ID VARCHAR(25))
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE   SQLSTATE          CHAR(5) DEFAULT '00000';--

    DECLARE GLOBAL TEMPORARY TABLE SESSION.TEMP
    (
        DR_JAN_AMT      DECIMAL(20,5) DEFAULT 0,
        DR_AMT          DECIMAL(20,5) DEFAULT 0,
        ACC_CD          VARCHAR(10)   DEFAULT '',
        ACC_NM          VARCHAR(60)   DEFAULT '',
        CR_AMT		    DECIMAL(20,5) DEFAULT 0,
        CR_JAN_AMT      DECIMAL(20,5) DEFAULT 0
    )  ON COMMIT PRESERVE ROWS
  WITH REPLACE
  NOT LOGGED;--

P1: BEGIN

    INSERT INTO SESSION.TEMP
    SELECT CASE B.DRCR_GB WHEN '차변'THEN A.DR_AMT - A.CR_AMT ELSE 0 END AS DR_JAN_AMT, A.DR_AMT, A.ACC_CD, A.ACC_NM,  A.CR_AMT, CASE B.DRCR_GB WHEN '대변'THEN A.CR_AMT - A.DR_AMT ELSE 0 END AS CR_JAN_AMT
       FROM (
                        SELECT A.ACC_CD, A.ACC_NM, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT   --일반계정 집계
                          FROM (
                                     SELECT ACC_CD, ACC_NM, DR_AMT, CR_AMT
                                       FROM GADMIN.ACCOU1
                                      WHERE DATE BETWEEN IN_FROMDATE AND IN_TODATE
                                     UNION ALL
                                     SELECT '1110101' AS ACC_CD, '현          금 ' AS ACC_NM, SUM(CR_AMT) AS DR_AMT, SUM(DR_AMT) AS CR_AMT   --현금계정 집계
                                       FROM GADMIN.ACCOU1
                                      WHERE DRCR_GB IN ('입금','출금')
                                        AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                                     UNION ALL
                                     SELECT ACC_CD, ACC_NM, DR_AMT, CR_AMT                  --전기이월 포함
                                       FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_FROMDATE))
                                ) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                GROUP BY A.ACC_CD, A.ACC_NM
            ) A, GADMIN.BSACC2 B
     WHERE A.ACC_CD = B.ACC_CD
       AND B.HAPJAN_DISP != 'N'
       AND NOT EXISTS (SELECT *   FROM GADMIN.BSACC2 C WHERE B.ACC_CD = C.ACC_CD AND C.HAPJAN_DISP = 'N')
       AND NOT (A.DR_AMT = 0 AND A.CR_AMT = 0)
    ORDER BY B.CHULRYEOK_CD    -- 출력순서
    ;--

    -- 절대 자산 집계 순서 바꾸면 안됨!!!!!!!!!!
    --(자        산)
    INSERT INTO SESSION.TEMP
    SELECT SUM(A.DR_AMT) - SUM(A.CR_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '1000000' AS ACC_CD, '(자        산)' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT, 0 AS CR_JAN_AMT
      FROM SESSION.TEMP A
     WHERE A.ACC_CD LIKE '1%' ;--

    --(유 동  자 산)
    INSERT INTO SESSION.TEMP
    SELECT SUM(A.DR_AMT) - SUM(A.CR_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '1100000' AS ACC_CD, 'Ⅰ.유 동 자 산' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT, 0 AS CR_JAN_AMT
      FROM SESSION.TEMP A
     WHERE A.ACC_CD LIKE '11%' ;--

    --(당 좌  자 산)
    INSERT INTO SESSION.TEMP
    SELECT SUM(A.DR_AMT) - SUM(A.CR_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '1110000' AS ACC_CD, '(당 좌  자 산)' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT, 0 AS CR_JAN_AMT
      FROM SESSION.TEMP A
     WHERE A.ACC_CD LIKE '111%' ;--

    --현금및현금등가물
    INSERT INTO SESSION.TEMP
    SELECT SUM(A.DR_AMT) - SUM(A.CR_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '1110100' AS ACC_CD, '현금및현금성자산' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT, 0 AS CR_JAN_AMT
      FROM SESSION.TEMP A
     WHERE A.ACC_CD LIKE '11101%' ;--

    --단기 금융 상품
    INSERT INTO SESSION.TEMP
    SELECT SUM(A.DR_AMT) - SUM(A.CR_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '1110200' AS ACC_CD, '단기 금융 상품' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT, 0 AS CR_JAN_AMT
      FROM SESSION.TEMP A
     WHERE A.ACC_CD LIKE '11102%' ;--

    --매  출  채  권
    INSERT INTO SESSION.TEMP
    SELECT SUM(A.DR_AMT) - SUM(A.CR_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '1110400' AS ACC_CD, '매  출  채  권' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT, 0 AS CR_JAN_AMT
      FROM SESSION.TEMP A
     WHERE A.ACC_CD LIKE '11104%' ;--

    --임원종업원단기대여금
    INSERT INTO SESSION.TEMP
    SELECT SUM(A.DR_AMT) - SUM(A.CR_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '1110800' AS ACC_CD, '임원종업원단기대여금' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT, 0 AS CR_JAN_AMT
      FROM SESSION.TEMP A
     WHERE A.ACC_CD LIKE '11108%' ;--

    --(재 고  자 산)
    INSERT INTO SESSION.TEMP
    SELECT SUM(A.DR_AMT) - SUM(A.CR_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '1120000' AS ACC_CD, '(재 고  자 산)' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT, 0 AS CR_JAN_AMT
      FROM SESSION.TEMP A
     WHERE A.ACC_CD LIKE '112%' ;          --

    --저    장    품
    INSERT INTO SESSION.TEMP
    SELECT SUM(A.DR_AMT) - SUM(A.CR_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '1120100' AS ACC_CD, '저    장    품' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT, 0 AS CR_JAN_AMT
      FROM SESSION.TEMP A
     WHERE A.ACC_CD LIKE '11201%' ;          --

    --(고 정  자 산)
    INSERT INTO SESSION.TEMP
    SELECT SUM(A.DR_AMT) - SUM(A.CR_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '1200000' AS ACC_CD, 'Ⅱ.비 유 동 자 산' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT, 0 AS CR_JAN_AMT
      FROM SESSION.TEMP A
     WHERE A.ACC_CD LIKE '12%' ;--

    --(투 자  자 산)
    INSERT INTO SESSION.TEMP
    SELECT SUM(A.DR_AMT) - SUM(A.CR_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '1210000' AS ACC_CD, '(투 자  자 산)' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT, 0 AS CR_JAN_AMT
      FROM SESSION.TEMP A
     WHERE A.ACC_CD LIKE '121%' ;--

    --장 기 금융상품
    INSERT INTO SESSION.TEMP
    SELECT SUM(A.DR_AMT) - SUM(A.CR_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '1210600' AS ACC_CD, '장 기 금융상품' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT, 0 AS CR_JAN_AMT
      FROM SESSION.TEMP A
     WHERE A.ACC_CD LIKE '12106%' ;     --

    --투 자 유가증권
    INSERT INTO SESSION.TEMP
    SELECT SUM(A.DR_AMT) - SUM(A.CR_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '1210700' AS ACC_CD, '투 자 유가증권' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT, 0 AS CR_JAN_AMT
      FROM SESSION.TEMP A
     WHERE A.ACC_CD LIKE '12107%' ;     --

    --(유 형  자 산)
    INSERT INTO SESSION.TEMP
    SELECT SUM(A.DR_AMT) - SUM(A.CR_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '1220000' AS ACC_CD, '(유 형  자 산)' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT, 0 AS CR_JAN_AMT
      FROM SESSION.TEMP A
     WHERE A.ACC_CD LIKE '122%' ;--

    --업 무 용 차 량
    INSERT INTO SESSION.TEMP
    SELECT SUM(A.DR_AMT) - SUM(A.CR_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '1220900' AS ACC_CD, '업 무 용 차 량' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT, 0 AS CR_JAN_AMT
      FROM SESSION.TEMP A
     WHERE A.ACC_CD LIKE '12209%' ;--

    --감가상각누계액(업무)
    INSERT INTO SESSION.TEMP
    SELECT 0 AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '1221000' AS ACC_CD, '감가상각누계액(업무)' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT, SUM(A.CR_AMT) - SUM(A.DR_AMT) AS CR_JAN_AMT
      FROM SESSION.TEMP A
     WHERE A.ACC_CD LIKE '12210%' ;--

    --감가상각누계액(집기비품)
    INSERT INTO SESSION.TEMP
    SELECT 0 AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '1221600' AS ACC_CD, '감가상각누계액(집기비품)' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT, SUM(A.CR_AMT) - SUM(A.DR_AMT) AS CR_JAN_AMT
      FROM SESSION.TEMP A
     WHERE A.ACC_CD LIKE '12216%' ;--

    --구    축    물
    INSERT INTO SESSION.TEMP
    SELECT SUM(A.DR_AMT) - SUM(A.CR_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '1221700' AS ACC_CD, '구    축    물' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT, 0 AS CR_JAN_AMT
      FROM SESSION.TEMP A
     WHERE A.ACC_CD LIKE '12217%' ;--

    --감가상각누계액(구축물)
    INSERT INTO SESSION.TEMP
    SELECT 0 AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '1221800' AS ACC_CD, '감가상각누계액(구축물)' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT, SUM(A.CR_AMT) - SUM(A.DR_AMT) AS CR_JAN_AMT
      FROM SESSION.TEMP A
     WHERE A.ACC_CD LIKE '12218%' ;--

    --(기타비유동자산)
    INSERT INTO SESSION.TEMP
    SELECT SUM(A.DR_AMT) - SUM(A.CR_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '1240000' AS ACC_CD, '(기타비유동자산)' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT, 0 AS CR_JAN_AMT
      FROM SESSION.TEMP A
     WHERE A.ACC_CD LIKE '124%' ;--

    --자산총계
    INSERT INTO SESSION.TEMP
    SELECT 0 AS DR_JAN_AMT, SUM(A.DR_AMT) - SUM(A.CR_AMT) AS DR_AMT, '1999999' AS ACC_CD, '자 산 총 계(Ⅰ+Ⅱ)' AS ACC_NM, 0 AS CR_AMT, 0 AS CR_JAN_AMT
      FROM (
        SELECT SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT
          FROM GADMIN.ACCOU1 A
         WHERE 1 = 1
           AND SUBSTRING(A.ACC_CD,1,1) = '1'
           AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
        UNION ALL
        SELECT SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT
          FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_FROMDATE))
         WHERE SUBSTRING(ACC_CD,1,1) = '1'
        UNION ALL
        SELECT
        --'1110101' AS ACC_CD, '현          금 ' AS ACC_NM,
        SUM(CR_AMT) AS DR_AMT, SUM(DR_AMT) AS CR_AMT   --현금계정 집계
        FROM GADMIN.ACCOU1
        WHERE DRCR_GB IN ('입금','출금')
        AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
        ) A;--

    --(부        채)
    INSERT INTO SESSION.TEMP
    SELECT 0 AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '2000000' AS ACC_CD, '(부        채)' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT, SUM(A.CR_AMT) - SUM(A.DR_AMT) AS CR_JAN_AMT
      FROM (
        SELECT SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT
          FROM GADMIN.ACCOU1 A
         WHERE 1 = 1
           AND SUBSTRING(A.ACC_CD,1,1) = '2'
           AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
        UNION ALL
        SELECT SUM(DR_AMT), SUM(CR_AMT)
          FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_FROMDATE))
         WHERE SUBSTRING(ACC_CD,1,1) = '2'
        ) A;     --

    --Ⅰ.유 동 부 채
    INSERT INTO SESSION.TEMP
    SELECT 0 AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '2100000' AS ACC_CD, 'Ⅰ.유 동 부 채' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT,  SUM(A.CR_AMT) - SUM(A.DR_AMT) AS CR_JAN_AMT
      FROM SESSION.TEMP A
     WHERE A.ACC_CD LIKE '21%' ;     --

    --미  지  급  금
    INSERT INTO SESSION.TEMP
    SELECT 0 AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '2100300' AS ACC_CD, '미  지  급  금' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT,  SUM(A.CR_AMT) - SUM(A.DR_AMT) AS CR_JAN_AMT
      FROM SESSION.TEMP A
     WHERE A.ACC_CD LIKE '21003%' ;          --

    --미 지 급 비 용
    INSERT INTO SESSION.TEMP
    SELECT 0 AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '2100500' AS ACC_CD, '미 지 급 비 용' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT,  SUM(A.CR_AMT) - SUM(A.DR_AMT) AS CR_JAN_AMT
      FROM SESSION.TEMP A
     WHERE A.ACC_CD LIKE '21005%' ;  --

    --유동성장기부채
    INSERT INTO SESSION.TEMP
    SELECT 0 AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '2101200' AS ACC_CD, '유동성장기부채' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT,  SUM(A.CR_AMT) - SUM(A.DR_AMT) AS CR_JAN_AMT
      FROM SESSION.TEMP A
     WHERE A.ACC_CD LIKE '21012%' ;  --

    --Ⅱ.비 유 동 부 채
    INSERT INTO SESSION.TEMP
    SELECT 0 AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '2200000' AS ACC_CD, 'Ⅱ.비 유 동 부 채' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT,  SUM(A.CR_AMT) - SUM(A.DR_AMT) AS CR_JAN_AMT
      FROM SESSION.TEMP A
     WHERE A.ACC_CD LIKE '22%' ;  --

    --퇴직연금운용자산
    INSERT INTO SESSION.TEMP
    SELECT 0 AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '2200700' AS ACC_CD, '퇴직연금운용자산' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT,  SUM(A.CR_AMT) - SUM(A.DR_AMT) AS CR_JAN_AMT
      FROM SESSION.TEMP A
     WHERE A.ACC_CD LIKE '22007%' ;  --

    --Ⅲ.자  본  금
    INSERT INTO SESSION.TEMP
    SELECT 0 AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '3100000' AS ACC_CD, 'Ⅲ.자  본  금' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT,  SUM(A.CR_AMT) - SUM(A.DR_AMT) AS CR_JAN_AMT
      FROM SESSION.TEMP A
     WHERE A.ACC_CD LIKE '31%' ;  --

    --Ⅵ.기타포괄손익누계액
    INSERT INTO SESSION.TEMP
    SELECT 0 AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '3260000' AS ACC_CD, 'Ⅵ.기타포괄손익누계액' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT,  SUM(A.CR_AMT) - SUM(A.DR_AMT) AS CR_JAN_AMT
      FROM SESSION.TEMP A
     WHERE A.ACC_CD LIKE '326%' ;  --

    --당기말미처분이익잉여금
    INSERT INTO SESSION.TEMP
    SELECT 0 AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '3300900' AS ACC_CD, '당기말미처분이익잉여금' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT,  SUM(A.CR_AMT) - SUM(A.DR_AMT) AS CR_JAN_AMT
      FROM (
                SELECT 0 AS DR_JAN_AMT, 0 AS DR_AMT, SUM(A.CR_AMT) AS CR_AMT,  SUM(A.CR_AMT) AS CR_JAN_AMT
                  FROM SESSION.TEMP A
                 WHERE ACC_CD = '3300901'   --이월이익잉여금
                 UNION ALL
                SELECT 0 AS DR_JAN_AMT, 0 AS DR_AMT, CU_TOT AS CR_AMT,  CU_TOT AS CR_JAN_AMT
                  FROM GADMIN.EBUS_FIN_INCOME
                 WHERE ACC_CD = '7300909'   --당기순이익
            ) A
            ;--

    --Ⅶ.이 익 잉 여 금
    INSERT INTO SESSION.TEMP
    SELECT 0 AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '3300000' AS ACC_CD, 'Ⅶ.이 익 잉 여 금' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT,  SUM(A.CR_AMT) - SUM(A.DR_AMT) AS CR_JAN_AMT
      FROM SESSION.TEMP A
     WHERE A.ACC_CD LIKE '33%' ;  --


    --자본총계
    INSERT INTO SESSION.TEMP
    SELECT 0 AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '3000000' AS ACC_CD, '(자        본)' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT, SUM(A.CR_AMT) - SUM(A.DR_AMT) AS CR_JAN_AMT
      FROM (
                SELECT SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT
                  FROM GADMIN.ACCOU1 A
                 WHERE 1 = 1
                   AND SUBSTRING(A.ACC_CD,1,1) = '3'
                   AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                UNION ALL
                SELECT 0 AS DR_AMT, CU_TOT AS CR_AMT  --당기순이익
                   FROM GADMIN.EBUS_FIN_INCOME
                  WHERE ACC_CD = '7300909'
                UNION ALL
                SELECT SUM(DR_AMT), SUM(CR_AMT)
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_FROMDATE))
                 WHERE SUBSTRING(ACC_CD,1,1) = '3'
            ) A;      --

    --부채자본총계
    INSERT INTO SESSION.TEMP
    SELECT SUM(DR_JAN_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '3999999' AS ACC_CD, '부채와 자본총계' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT, SUM(A.CR_AMT) - SUM(A.DR_AMT) AS CR_JAN_AMT
      FROM (
                SELECT * FROM SESSION.TEMP WHERE ACC_CD = '2000000'
                UNION ALL
                SELECT * FROM SESSION.TEMP WHERE ACC_CD = '3000000'
            ) A ;          --

    --Ⅰ.매  출  액
    INSERT INTO SESSION.TEMP
    SELECT SUM(DR_JAN_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '6100000' AS ACC_CD, 'Ⅰ.매  출  액' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT, SUM(A.CR_AMT) - SUM(A.DR_AMT) AS CR_JAN_AMT
      FROM (
                SELECT * FROM SESSION.TEMP WHERE ACC_CD LIKE '61%'
            ) A ;  --

    --(운송원가및주택분양원가)
    INSERT INTO SESSION.TEMP
    SELECT SUM(DR_JAN_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '6200000' AS ACC_CD, '(운송원가및주택분양원가)' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT, SUM(A.CR_JAN_AMT) AS CR_JAN_AMT
      FROM (
                SELECT * FROM SESSION.TEMP WHERE ACC_CD = '6220000'
                UNION ALL
                SELECT * FROM SESSION.TEMP WHERE ACC_CD = '6230000'
            ) A ;        --

     --(매   출   액)
    INSERT INTO SESSION.TEMP
    SELECT SUM(DR_JAN_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '6300000' AS ACC_CD, 'Ⅲ.매 출 총 손 익' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT, SUM(A.CR_AMT) - SUM(A.DR_AMT) AS CR_JAN_AMT
      FROM (
                SELECT * FROM SESSION.TEMP WHERE ACC_CD = '6100000'
                UNION ALL
                SELECT * FROM SESSION.TEMP WHERE ACC_CD = '6200000'
                UNION ALL
                SELECT 0 AS DR_JAN_AMT, SUM(DR_AMT) AS DR_AMT, A.ACC_CD, A.ACC_NM, 0 AS CR_AMT, 0 AS CR_JAN_AMT
                  FROM (
                        --당기
                        SELECT A.ACC_CD, A.ACC_NM, SUM(A.DR_AMT - A.CR_AMT) AS DR_AMT
                          FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                         WHERE 1 = 1
                           AND A.ACC_CD = B.ACC_CD
                           AND B.ACC_GB = '원가'
                           AND A.ACC_CD LIKE '6%'
                           AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                         GROUP BY A.ACC_CD, A.ACC_NM
                          UNION ALL
                        SELECT A.ACC_CD, A.ACC_NM, SUM(A.DR_AMT - A.CR_AMT) AS DR_AMT
                          FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_FROMDATE)) A, GADMIN.BSACC2 B
                         WHERE 1 = 1
                           AND A.ACC_CD = B.ACC_CD
                           AND B.ACC_GB = '원가'
                           AND A.ACC_CD LIKE '6%'
                         GROUP BY A.ACC_CD, A.ACC_NM
                              ) A, GADMIN.BSACC2 B
                    WHERE A.ACC_CD = B.ACC_CD
                GROUP BY A.ACC_CD, A.ACC_NM
            ) A ;          --

     --Ⅱ.운 송 원 가
    INSERT INTO SESSION.TEMP
    SELECT SUM(DR_JAN_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '6200000' AS ACC_CD, 'Ⅱ.운 송 원 가' AS ACC_NM, 0 AS CR_AMT, 0 AS CR_JAN_AMT
      FROM (
                SELECT 0 AS DR_JAN_AMT, SUM(DR_AMT) AS DR_AMT, A.ACC_CD, A.ACC_NM, 0 AS CR_AMT, 0 AS CR_JAN_AMT
                  FROM (
                        --당기
                        SELECT A.ACC_CD, A.ACC_NM, SUM(A.DR_AMT - A.CR_AMT) AS DR_AMT
                          FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                         WHERE 1 = 1
                           AND A.ACC_CD = B.ACC_CD
                           AND B.ACC_GB = '원가'
                           AND A.ACC_CD LIKE '6%'
                           AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                         GROUP BY A.ACC_CD, A.ACC_NM
                          UNION ALL
                        SELECT A.ACC_CD, A.ACC_NM, SUM(A.DR_AMT - A.CR_AMT) AS DR_AMT
                          FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_FROMDATE)) A, GADMIN.BSACC2 B
                         WHERE 1 = 1
                           AND A.ACC_CD = B.ACC_CD
                           AND B.ACC_GB = '원가'
                           AND A.ACC_CD LIKE '6%'
                         GROUP BY A.ACC_CD, A.ACC_NM
                              ) A, GADMIN.BSACC2 B
                    WHERE A.ACC_CD = B.ACC_CD
                GROUP BY A.ACC_CD, A.ACC_NM
            ) A ;          --

     --Ⅰ.재  료  비
    INSERT INTO SESSION.TEMP
    SELECT SUM(DR_JAN_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '6220000' AS ACC_CD, 'Ⅰ.재  료  비' AS ACC_NM, 0 AS CR_AMT, 0 AS CR_JAN_AMT
      FROM (
                SELECT * FROM SESSION.TEMP WHERE ACC_CD LIKE '622%'
            ) A
    ;          --

     --상    여    금*
    INSERT INTO SESSION.TEMP
    SELECT SUM(DR_JAN_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '6230200' AS ACC_CD, '상    여    금*' AS ACC_NM, 0 AS CR_AMT, 0 AS CR_JAN_AMT
      FROM (
                SELECT * FROM SESSION.TEMP WHERE ACC_CD LIKE '62302%'
            ) A
    ;          --

     --Ⅱ.노  무  비
    INSERT INTO SESSION.TEMP
    SELECT SUM(DR_JAN_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '6230000' AS ACC_CD, 'Ⅱ.노  무  비' AS ACC_NM, 0 AS CR_AMT, 0 AS CR_JAN_AMT
      FROM (
                SELECT * FROM SESSION.TEMP WHERE ACC_CD LIKE '623%'
            ) A
    ;          --

     --급         여*
    INSERT INTO SESSION.TEMP
    SELECT SUM(DR_JAN_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '6230100' AS ACC_CD, '급         여*' AS ACC_NM, 0 AS CR_AMT, 0 AS CR_JAN_AMT
      FROM (
                SELECT * FROM SESSION.TEMP WHERE ACC_CD LIKE '62301%'
            ) A
    ;          --

     --복 리 후 생 비*
    INSERT INTO SESSION.TEMP
    SELECT SUM(DR_JAN_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '6230600' AS ACC_CD, '복 리 후 생 비*' AS ACC_NM, 0 AS CR_AMT, 0 AS CR_JAN_AMT
      FROM (
                SELECT * FROM SESSION.TEMP WHERE ACC_CD LIKE '62306%'
            ) A
    ;          --

     --복리후생비(정비)+
    INSERT INTO SESSION.TEMP
    SELECT SUM(DR_JAN_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '6230610' AS ACC_CD, '복리후생비(정비)+' AS ACC_NM, 0 AS CR_AMT, 0 AS CR_JAN_AMT
      FROM (
                SELECT * FROM SESSION.TEMP WHERE ACC_CD LIKE '623061%'
            ) A
    ;          --

     --복리후생비(운전)+
    INSERT INTO SESSION.TEMP
    SELECT SUM(DR_JAN_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '6230620' AS ACC_CD, '복리후생비(운전)+' AS ACC_NM, 0 AS CR_AMT, 0 AS CR_JAN_AMT
      FROM (
                SELECT * FROM SESSION.TEMP WHERE ACC_CD LIKE '623062%'
            ) A
    ;          --

     --Ⅲ.경       비
    INSERT INTO SESSION.TEMP
    SELECT SUM(DR_JAN_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '6240000' AS ACC_CD, 'Ⅲ.경       비' AS ACC_NM, 0 AS CR_AMT, 0 AS CR_JAN_AMT
      FROM (
                SELECT * FROM SESSION.TEMP WHERE ACC_CD LIKE '624%'
            ) A
    ;          --

     --보    험    료*
    INSERT INTO SESSION.TEMP
    SELECT SUM(DR_JAN_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '6240100' AS ACC_CD, '보    험    료*' AS ACC_NM, 0 AS CR_AMT, 0 AS CR_JAN_AMT
      FROM (
                SELECT * FROM SESSION.TEMP WHERE ACC_CD LIKE '62401%'
            ) A
    ;          --

     --차 량 정 비 비*
    INSERT INTO SESSION.TEMP
    SELECT SUM(DR_JAN_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '6241000' AS ACC_CD, '차 량 정 비 비*' AS ACC_NM, 0 AS CR_AMT, 0 AS CR_JAN_AMT
      FROM (
                SELECT * FROM SESSION.TEMP WHERE ACC_CD LIKE '6241%'
            ) A
    ;          --

    --Ⅳ.판매비와관리비
    INSERT INTO SESSION.TEMP
    SELECT SUM(DR_JAN_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '6400000' AS ACC_CD, 'Ⅳ.판매비와관리비' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT, 0 AS CR_JAN_AMT
      FROM SESSION.TEMP A
      WHERE ACC_CD LIKE '64%' ;--

    --급          여*
    INSERT INTO SESSION.TEMP
    SELECT SUM(DR_JAN_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '6400200' AS ACC_CD, '급          여*' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT, 0 AS CR_JAN_AMT
      FROM SESSION.TEMP A
      WHERE ACC_CD LIKE '64002%' ;--

    --상    여    금*
    INSERT INTO SESSION.TEMP
    SELECT SUM(DR_JAN_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '6400400' AS ACC_CD, '상    여    금*' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT, 0 AS CR_JAN_AMT
      FROM SESSION.TEMP A
      WHERE ACC_CD LIKE '64004%' ;--

    --복 리 후 생 비*
    INSERT INTO SESSION.TEMP
    SELECT SUM(DR_JAN_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '6400800' AS ACC_CD, '복 리 후 생 비*' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT, 0 AS CR_JAN_AMT
      FROM SESSION.TEMP A
      WHERE ACC_CD LIKE '64008%' ;--


    --복리후생비(직원)+
    INSERT INTO SESSION.TEMP
    SELECT SUM(DR_JAN_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '6400810' AS ACC_CD, '복리후생비(직원)+' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT, 0 AS CR_JAN_AMT
      FROM SESSION.TEMP A
      WHERE ACC_CD LIKE '640081%' ;--

    --복리후생비(임원)+
    INSERT INTO SESSION.TEMP
    SELECT SUM(DR_JAN_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '6400820' AS ACC_CD, '복리후생비(임원)+' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT, 0 AS CR_JAN_AMT
      FROM SESSION.TEMP A
      WHERE ACC_CD LIKE '640082%' ;--

    --수 도 광 열 비*
    INSERT INTO SESSION.TEMP
    SELECT SUM(DR_JAN_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '6401000' AS ACC_CD, '수 도 광 열 비*' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT, 0 AS CR_JAN_AMT
      FROM SESSION.TEMP A
      WHERE ACC_CD LIKE '640100%' ;--

    --세 금 과 공 과
    INSERT INTO SESSION.TEMP
    SELECT SUM(DR_JAN_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '6401300' AS ACC_CD, '세 금 과 공 과' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT, 0 AS CR_JAN_AMT
      FROM SESSION.TEMP A
      WHERE ACC_CD LIKE '640130%' ;--

    --지 급 임 차 료
    INSERT INTO SESSION.TEMP
    SELECT SUM(DR_JAN_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '6403300' AS ACC_CD, '지 급 임 차 료' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT, 0 AS CR_JAN_AMT
      FROM SESSION.TEMP A
      WHERE ACC_CD LIKE '640330%' ;--

    --Ⅴ.영 업 손 익

    INSERT INTO SESSION.TEMP
    SELECT 0 AS DR_JAN_AMT, SUM(COALESCE(DR_AMT,0)) AS DR_AMT, '6500000' AS ACC_CD, 'Ⅴ.영 업 손 익' AS ACC_NM, SUM(COALESCE(CR_AMT,0)) AS CR_AMT, (SUM(COALESCE(CR_AMT,0)) - SUM(COALESCE(DR_AMT,0))) AS CR_JAN_AMT
      FROM (
                SELECT * FROM SESSION.TEMP WHERE ACC_CD = '6400000'  --판매비와관리비
                UNION ALL
                SELECT * FROM SESSION.TEMP WHERE ACC_CD = '6300000'  -- 매출 총이익
            ) A
        ;--

    --Ⅵ.영 업 외 수 익
    INSERT INTO SESSION.TEMP
    SELECT SUM(DR_JAN_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '6600000' AS ACC_CD, 'Ⅵ.영 업 외 수 익' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT, SUM(A.CR_AMT) AS CR_JAN_AMT
      FROM SESSION.TEMP A
      WHERE ACC_CD LIKE '66%' ;--

    --Ⅶ.영 업 외 비 용
    INSERT INTO SESSION.TEMP
    SELECT SUM(DR_JAN_AMT) AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '6700000' AS ACC_CD, 'Ⅶ.영 업 외 비 용' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT, SUM(A.CR_AMT) AS CR_JAN_AMT
      FROM SESSION.TEMP A
      WHERE ACC_CD LIKE '67%' ;--

    --(손        익)

    INSERT INTO SESSION.TEMP
    SELECT 0 AS DR_JAN_AMT, A.DR_AMT AS DR_AMT, '6000000' AS ACC_CD, '(손        익)' AS ACC_NM, CR_AMT AS CR_AMT, (CR_AMT - DR_AMT) AS CR_JAN_AMT
      FROM (
                SELECT SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT
                  FROM (
                            SELECT COALESCE(DR_AMT,0) AS DR_AMT, COALESCE(CR_AMT,0) AS CR_AMT FROM SESSION.TEMP WHERE ACC_CD = '6500000'  --매출 총이익
                            UNION ALL
                            SELECT COALESCE(DR_AMT,0) AS DR_AMT, COALESCE(CR_AMT,0) AS CR_AMT FROM SESSION.TEMP WHERE ACC_CD = '6600000'  --판매비와관리비
                            UNION ALL
                            SELECT COALESCE(DR_AMT,0) AS DR_AMT, COALESCE(CR_AMT,0) AS CR_AMT FROM SESSION.TEMP WHERE ACC_CD = '6700000'  --Ⅶ.영 업 외 비 용
                        )
            ) A
        ;--


    --Ⅷ.경 상 이 익
    INSERT INTO SESSION.TEMP
    SELECT 0 AS DR_JAN_AMT, SUM(A.DR_AMT) AS DR_AMT, '6800000' AS ACC_CD, 'Ⅷ.경 상 이 익' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT, SUM(A.CR_AMT) - SUM(A.DR_AMT) AS CR_JAN_AMT
      FROM (
                SELECT * FROM SESSION.TEMP WHERE ACC_CD = '6300000'
                UNION ALL
                SELECT * FROM SESSION.TEMP WHERE ACC_CD = '6400000'
                UNION ALL
                SELECT * FROM SESSION.TEMP WHERE ACC_CD = '6600000'
                UNION ALL
                SELECT * FROM SESSION.TEMP WHERE ACC_CD = '6700000'
            ) A ;--

    --합계
    INSERT INTO SESSION.TEMP
    SELECT SUM(DR_JAN_AMT) AS DR_JAN_AMT, SUM(DR_AMT) AS DR_AMT, '9000000' AS ACC_CD, '합  계' AS ACC_NM, SUM(A.CR_AMT) AS CR_AMT, SUM(CR_JAN_AMT) AS CR_JAN_AMT
      FROM (
                SELECT DR_JAN_AMT, DR_AMT, CR_AMT, CR_JAN_AMT FROM SESSION.TEMP WHERE ACC_CD = '1000000'
                UNION ALL
                SELECT DR_JAN_AMT, DR_AMT, CR_AMT, CR_JAN_AMT FROM SESSION.TEMP WHERE ACC_CD = '3999999'
                UNION ALL
                SELECT DR_JAN_AMT, DR_AMT, CR_AMT - CR_JAN_AMT, CR_JAN_AMT - CR_JAN_AMT FROM SESSION.TEMP WHERE ACC_CD = '6000000'

            ) A ;      --

END P1;--
P2: BEGIN

    DECLARE CURSOR_TEMP CURSOR WITH RETURN FOR
    SELECT DR_JAN_AMT, DR_AMT, ACC_CD, ACC_NM, CR_AMT, CR_JAN_AMT
      FROM (
                        SELECT A.*, B.CHULRYEOK_CD
                          FROM SESSION.TEMP A, GADMIN.BSACC2 B
                        WHERE 1 = 1
                          AND A.ACC_CD = B.ACC_CD
                        UNION ALL
                        SELECT A.*, '9000000'
                          FROM SESSION.TEMP A
                         WHERE A.ACC_CD = '9000000'
                     )
    WHERE 1 = 1
      AND NOT ( DR_AMT = 0 AND CR_AMT = 0 )
    ORDER BY CHULRYEOK_CD
    ;--

    OPEN CURSOR_TEMP;--
END P2;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN1101_TAB01_SELECT"
(IN IN_FROMDATE VARCHAR(10), IN IN_TODATE VARCHAR(10), IN IN_USER_ID VARCHAR(25))
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE   SQLSTATE          CHAR(5) DEFAULT '00000';--
    DECLARE   TOT_JS_DR               DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   TOT_BJ_CR               DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   TOT_SON_DR               DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   TOT_SON_CR               DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   JAN_JS_DR               DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   JAN_BJ_CR               DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   JAN_SON_DR               DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   JAN_SON_CR               DECIMAL(20,5) DEFAULT 0.0;--

    DECLARE GLOBAL TEMPORARY TABLE SESSION.TEMP
    (
        DR_JAN_AMT      DECIMAL(20,5) DEFAULT 0,
        DR_AMT          DECIMAL(20,5) DEFAULT 0,
        ACC_CD          VARCHAR(10)   DEFAULT '',
        ACC_NM          VARCHAR(60)   DEFAULT '',
        CR_AMT		    DECIMAL(20,5) DEFAULT 0,
        CR_JAN_AMT      DECIMAL(20,5) DEFAULT 0
    )  ON COMMIT PRESERVE ROWS
  WITH REPLACE
  NOT LOGGED;--

P1: BEGIN

    INSERT INTO SESSION.TEMP
        WITH HAP_ACC AS (
            SELECT CASE B.DRCR_GB WHEN '차변'THEN A.DR_AMT - A.CR_AMT ELSE 0 END AS DR_JAN_AMT, A.DR_AMT, B.ACC_CD, B.ACC_NM,  A.CR_AMT, (CASE B.DRCR_GB WHEN '대변'THEN A.CR_AMT - A.DR_AMT ELSE 0 END) AS CR_JAN_AMT, (case when CHAGAM_GB = '차감' then -1 else 1 end) as sign, b.levelup_cd as levelup_cd
               FROM (
                                SELECT A.ACC_CD, MAX(A.ACC_NM) AS ACC_NM, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT   --일반계정 집계
                                  FROM (
                                             SELECT ACC_CD, ACC_NM, DR_AMT, CR_AMT
                                               FROM GADMIN.ACCOU1
                                              WHERE DATE BETWEEN IN_FROMDATE AND IN_TODATE
                                             UNION ALL
                                             SELECT '1110101' AS ACC_CD, '현          금 ' AS ACC_NM, SUM(CR_AMT) AS DR_AMT, SUM(DR_AMT) AS CR_AMT   --현금계정 집계
                                               FROM GADMIN.ACCOU1
                                              WHERE DRCR_GB IN ('입금','출금')
                                                AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                                             UNION ALL
                                             SELECT ACC_CD, ACC_NM, DR_AMT, CR_AMT                  --전기이월 포함
                                               FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_FROMDATE))
                                        ) A, GADMIN.BSACC2 B
                         WHERE 1 = 1
                           AND A.ACC_CD = B.ACC_CD
                        GROUP BY A.ACC_CD
                    ) A RIGHT OUTER JOIN GADMIN.BSACC2 B ON A.ACC_CD = B.ACC_CD

        )
        SELECT 0 AS DR_JAN_AMT,
                (SELECT coalesce(SUM(sign * DR_AMT),0)
                  FROM HAP_ACC
                 START WITH acc_cd = main.acc_cd
               CONNECT BY PRIOR acc_cd = LEVELUP_CD
               ) as DR_AMT
             , ACC_CD, ACC_NM
             , (SELECT coalesce(SUM(sign * CR_AMT),0)
                  FROM HAP_ACC
                 START WITH acc_cd = main.acc_cd
               CONNECT BY PRIOR acc_cd = LEVELUP_CD
               ) as CR_AMT,
               0 AS CR_JAN_AMT
          FROM HAP_ACC main
--         START WITH coalesce(LEVELUP_CD,'')=''
--        CONNECT BY PRIOR acc_cd = LEVELUP_CD --order by acc_cd
        UNION ALL
        SELECT SUM(DR_JAN_AMT) AS DR_JAN_AMT, SUM(DR_AMT) AS DR_AMT, '9999999' AS ACC_CD, '합          계 ' AS ACC_NM, SUM(CR_AMT) AS CR_AMT, SUM(CR_JAN_AMT) AS CR_JAN_AMT
         FROM HAP_ACC
        ;--



END P1;--
P2: BEGIN

    DECLARE CURSOR_TEMP CURSOR WITH RETURN FOR
    SELECT DR_JAN_AMT, DR_AMT, ACC_CD, ACC_NM, CR_AMT, CR_JAN_AMT
      FROM (
             SELECT CASE DRCR_GB WHEN '차변' THEN coalesce(DR_AMT - CR_AMT,0) END AS DR_JAN_AMT, DR_AMT, ACC_CD, ACC_NM, CR_AMT, CASE DRCR_GB WHEN '대변' THEN coalesce(CR_AMT - DR_AMT,0) END AS CR_JAN_AMT, CHULRYEOK_CD
               FROM (
                                 SELECT A.*, B.CHULRYEOK_CD, B.DRCR_GB
                                   FROM SESSION.TEMP A, GADMIN.BSACC2 B
                                 WHERE 1 = 1
                                   AND A.ACC_CD = B.ACC_CD
                                   AND B.ACC_CD != '7300909'
                                 UNION ALL
                                 SELECT A.*, '9000000', ''
                                   FROM SESSION.TEMP A
                                  WHERE A.ACC_CD = '9000000'
                              )
             WHERE 1 = 1
               AND NOT ( DR_AMT = 0 AND CR_AMT = 0 )
             UNION ALL
             SELECT A.DR_JAN_AMT, A.DR_AMT, A.ACC_CD, A.ACC_NM, A.CR_AMT, A.CR_JAN_AMT, '9999999' AS CHULRYEOK_CD
               FROM SESSION.TEMP A
              WHERE A.ACC_CD = '9999999'
    )
    ORDER BY CHULRYEOK_CD
    ;--

    OPEN CURSOR_TEMP;--
END P2;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN1101_TAB01_SELECT_OLD"
(IN IN_FROMDATE VARCHAR(10), IN IN_TODATE VARCHAR(10), IN IN_USER_ID VARCHAR(25))
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE   SQLSTATE          CHAR(5) DEFAULT '00000';--
    DECLARE   TOT_JS_DR               DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   TOT_BJ_CR               DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   TOT_SON_DR               DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   TOT_SON_CR               DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   JAN_JS_DR               DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   JAN_BJ_CR               DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   JAN_SON_DR               DECIMAL(20,5) DEFAULT 0.0;--
    DECLARE   JAN_SON_CR               DECIMAL(20,5) DEFAULT 0.0;--

    DECLARE GLOBAL TEMPORARY TABLE SESSION.TEMP
    (
        DR_JAN_AMT      DECIMAL(20,5) DEFAULT 0,
        DR_AMT          DECIMAL(20,5) DEFAULT 0,
        ACC_CD          VARCHAR(10)   DEFAULT '',
        ACC_NM          VARCHAR(60)   DEFAULT '',
        CR_AMT		    DECIMAL(20,5) DEFAULT 0,
        CR_JAN_AMT      DECIMAL(20,5) DEFAULT 0
    )  ON COMMIT PRESERVE ROWS
  WITH REPLACE
  NOT LOGGED;--

P1: BEGIN

    INSERT INTO SESSION.TEMP
        WITH HAP_ACC AS (
            SELECT CASE B.DRCR_GB WHEN '차변'THEN A.DR_AMT - A.CR_AMT ELSE 0 END AS DR_JAN_AMT, A.DR_AMT, B.ACC_CD, B.ACC_NM,  A.CR_AMT, (CASE B.DRCR_GB WHEN '대변'THEN A.CR_AMT - A.DR_AMT ELSE 0 END) AS CR_JAN_AMT, (case when CHAGAM_GB = '차감' then -1 else 1 end) as sign, b.levelup_cd as levelup_cd
               FROM (
                                SELECT A.ACC_CD, MAX(A.ACC_NM) AS ACC_NM, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT   --일반계정 집계
                                  FROM (
                                             SELECT ACC_CD, ACC_NM, DR_AMT, CR_AMT
                                               FROM GADMIN.ACCOU1
                                              WHERE DATE BETWEEN IN_FROMDATE AND IN_TODATE
                                             UNION ALL
                                             SELECT '1110101' AS ACC_CD, '현          금 ' AS ACC_NM, SUM(CR_AMT) AS DR_AMT, SUM(DR_AMT) AS CR_AMT   --현금계정 집계
                                               FROM GADMIN.ACCOU1
                                              WHERE DRCR_GB IN ('입금','출금')
                                                AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                                             UNION ALL
                                             SELECT ACC_CD, ACC_NM, DR_AMT, CR_AMT                  --전기이월 포함
                                               FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_FROMDATE))
                                        ) A, GADMIN.BSACC2 B
                         WHERE 1 = 1
                           AND A.ACC_CD = B.ACC_CD
                        GROUP BY A.ACC_CD
                    ) A RIGHT OUTER JOIN GADMIN.BSACC2 B ON A.ACC_CD = B.ACC_CD

        )
        SELECT 0 AS DR_JAN_AMT,
                (SELECT coalesce(SUM(sign * DR_AMT),0)
                  FROM HAP_ACC
                 START WITH acc_cd = main.acc_cd
               CONNECT BY PRIOR acc_cd = LEVELUP_CD
               ) as DR_AMT
             , ACC_CD, ACC_NM
             , (SELECT coalesce(SUM(sign * CR_AMT),0)
                  FROM HAP_ACC
                 START WITH acc_cd = main.acc_cd
               CONNECT BY PRIOR acc_cd = LEVELUP_CD
               ) as CR_AMT,
               0 AS CR_JAN_AMT
          FROM HAP_ACC main
         START WITH coalesce(LEVELUP_CD,'')=''
        CONNECT BY PRIOR acc_cd = LEVELUP_CD order by acc_cd
        ;--


END P1;--
P2: BEGIN

    DECLARE CURSOR_TEMP CURSOR WITH RETURN FOR
    SELECT CASE DRCR_GB WHEN '차변' THEN coalesce(DR_AMT - CR_AMT,0) END AS DR_JAN_AMT, DR_AMT, ACC_CD, ACC_NM, CR_AMT, CASE DRCR_GB WHEN '대변' THEN coalesce(CR_AMT - DR_AMT,0) END AS CR_JAN_AMT
      FROM (
                        SELECT A.*, B.CHULRYEOK_CD, B.DRCR_GB
                          FROM SESSION.TEMP A, GADMIN.BSACC2 B
                        WHERE 1 = 1
                          AND A.ACC_CD = B.ACC_CD
                          AND B.ACC_CD != '7300909'
                        UNION ALL
                        SELECT A.*, '9000000', ''
                          FROM SESSION.TEMP A
                         WHERE A.ACC_CD = '9000000'
                     )
    WHERE 1 = 1
      AND NOT ( DR_AMT = 0 AND CR_AMT = 0 )
    ORDER BY CHULRYEOK_CD
    ;--

    OPEN CURSOR_TEMP;--
END P2;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN1101_TAB02_SELECT"
(IN IN_FROMDATE VARCHAR(10), IN IN_TODATE VARCHAR(10), IN IN_PRE_FROMDATE VARCHAR(10), IN IN_PRE_TODATE VARCHAR(10), IN IN_USER_ID VARCHAR(25))
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE   SQLSTATE          CHAR(5) DEFAULT '00000';--

P1: BEGIN
    DELETE FROM GADMIN.EBUS_FIN_INCOME;--

    INSERT INTO GADMIN.EBUS_FIN_INCOME
        WITH SON_ACC AS (
            SELECT B.DRCR_GB, CASE B.DRCR_GB WHEN '차변'THEN A.DR_AMT - A.CR_AMT ELSE 0 END AS DR_JAN_AMT, A.DR_AMT, B.ACC_CD, B.ACC_NM,  A.CR_AMT, (CASE B.DRCR_GB WHEN '대변'THEN A.CR_AMT - A.DR_AMT ELSE 0 END) AS CR_JAN_AMT, (case when CHAGAM_GB = '차감' then -1 else 1 end) as sign, b.levelup_cd as levelup_cd
               FROM (
                                SELECT A.ACC_CD, MAX(A.ACC_NM) AS ACC_NM, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT   --일반계정 집계
                                  FROM (
                                             SELECT ACC_CD, ACC_NM, DR_AMT, CR_AMT
                                               FROM GADMIN.ACCOU1
                                              WHERE DATE BETWEEN IN_FROMDATE AND IN_TODATE
                                             UNION ALL
                                             SELECT '1110101' AS ACC_CD, '현          금 ' AS ACC_NM, SUM(CR_AMT) AS DR_AMT, SUM(DR_AMT) AS CR_AMT   --현금계정 집계
                                               FROM GADMIN.ACCOU1
                                              WHERE DRCR_GB IN ('입금','출금')
                                                AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                                             UNION ALL
                                             SELECT ACC_CD, ACC_NM, DR_AMT, CR_AMT                  --전기이월 포함
                                               FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_FROMDATE))
                                        ) A, GADMIN.BSACC2 B
                         WHERE 1 = 1
                           AND A.ACC_CD = B.ACC_CD
                        GROUP BY A.ACC_CD
                    ) A RIGHT OUTER JOIN GADMIN.BSACC2 B ON A.ACC_CD = B.ACC_CD

        ),
        SON_ACC2 AS (
            SELECT B.DRCR_GB, CASE B.DRCR_GB WHEN '차변'THEN A.DR_AMT - A.CR_AMT ELSE 0 END AS DR_JAN_AMT, A.DR_AMT, B.ACC_CD, B.ACC_NM,  A.CR_AMT, (CASE B.DRCR_GB WHEN '대변'THEN A.CR_AMT - A.DR_AMT ELSE 0 END) AS CR_JAN_AMT, (case when CHAGAM_GB = '차감' then -1 else 1 end) as sign, b.levelup_cd as levelup_cd
               FROM (
                                SELECT A.ACC_CD, MAX(A.ACC_NM) AS ACC_NM, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT   --일반계정 집계
                                  FROM (
                                             SELECT ACC_CD, ACC_NM, DR_AMT, CR_AMT
                                               FROM GADMIN.ACCOU1
                                              WHERE DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                                             UNION ALL
                                             SELECT '1110101' AS ACC_CD, '현          금 ' AS ACC_NM, SUM(CR_AMT) AS DR_AMT, SUM(DR_AMT) AS CR_AMT   --현금계정 집계
                                               FROM GADMIN.ACCOU1
                                              WHERE DRCR_GB IN ('입금','출금')
                                                AND DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                                             UNION ALL
                                             SELECT ACC_CD, ACC_NM, DR_AMT, CR_AMT                  --전기이월 포함
                                               FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_PRE_FROMDATE))
                                        ) A, GADMIN.BSACC2 B
                         WHERE 1 = 1
                           AND A.ACC_CD = B.ACC_CD
                        GROUP BY A.ACC_CD
                    ) A RIGHT OUTER JOIN GADMIN.BSACC2 B ON A.ACC_CD = B.ACC_CD
        )
        SELECT A.ACC_CD, A.ACC_NM, A.CU_AMT, A.CU_TOT, A.BE_AMT, A.BE_TOT, NOW, IN_USER_ID, NULL, NULL
          FROM (
                SELECT A.ACC_CD, MAX(A.ACC_NM) AS ACC_NM,
                       coalesce(CASE WHEN SONIK_DISP !='R' THEN SUM(CU_AMT) END,0) AS CU_AMT, coalesce(CASE WHEN SONIK_DISP ='R' THEN SUM(CU_AMT) END,0) AS CU_TOT,
                       coalesce(CASE WHEN SONIK_DISP !='R' THEN SUM(BE_AMT) END,0) AS BE_AMT, coalesce(CASE WHEN SONIK_DISP ='R' THEN SUM(BE_AMT) END,0) AS BE_TOT
                  FROM (
                        SELECT ACC_CD, ACC_NM
                             , (SELECT coalesce(SUM(sign * DR_AMT),0)
                                  FROM SON_ACC
                                 START WITH acc_cd = main.acc_cd
                               CONNECT BY PRIOR acc_cd = LEVELUP_CD
                               ) as CU_DR_AMT
                             , (SELECT coalesce(SUM(sign * CR_AMT),0)
                                  FROM SON_ACC
                                 START WITH acc_cd = main.acc_cd
                               CONNECT BY PRIOR acc_cd = LEVELUP_CD
                               ) as CU_CR_AMT,
                               CASE WHEN DRCR_GB IN ('차변','출금') THEN
                                     (SELECT coalesce(SUM(sign * DR_AMT),0)
                                          FROM SON_ACC
                                         START WITH acc_cd = main.acc_cd
                                       CONNECT BY PRIOR acc_cd = LEVELUP_CD
                                       ) -
                                    (SELECT coalesce(SUM(sign * CR_AMT),0)
                                          FROM SON_ACC
                                         START WITH acc_cd = main.acc_cd
                                       CONNECT BY PRIOR acc_cd = LEVELUP_CD
                                       )
                                ELSE
                                    (SELECT coalesce(SUM(sign * CR_AMT),0)
                                          FROM SON_ACC
                                         START WITH acc_cd = main.acc_cd
                                       CONNECT BY PRIOR acc_cd = LEVELUP_CD
                                       ) -
                                     (SELECT coalesce(SUM(sign * DR_AMT),0)
                                          FROM SON_ACC
                                         START WITH acc_cd = main.acc_cd
                                       CONNECT BY PRIOR acc_cd = LEVELUP_CD
                                       )
                                END CU_AMT, 0 AS BE_DR_AMT, 0 AS BE_CR_AMT , 0 AS BE_AMT
                          FROM SON_ACC main
                         START WITH coalesce(LEVELUP_CD,'')='6000000'
                        CONNECT BY PRIOR acc_cd = LEVELUP_CD
                        UNION ALL
                        SELECT ACC_CD, ACC_NM, 0 AS CU_DR_AMT, 0 AS CU_CR_AMT , 0 AS CU_AMT
                             , (SELECT coalesce(SUM(sign * DR_AMT),0)
                                  FROM SON_ACC2
                                 START WITH acc_cd = main.acc_cd
                               CONNECT BY PRIOR acc_cd = LEVELUP_CD
                               ) as BE_DR_AMT
                             , (SELECT coalesce(SUM(sign * CR_AMT),0)
                                  FROM SON_ACC2
                                 START WITH acc_cd = main.acc_cd
                               CONNECT BY PRIOR acc_cd = LEVELUP_CD
                               ) as BE_CR_AMT,
                               CASE WHEN DRCR_GB IN ('차변','출금') THEN
                                     (SELECT coalesce(SUM(sign * DR_AMT),0)
                                          FROM SON_ACC2
                                         START WITH acc_cd = main.acc_cd
                                       CONNECT BY PRIOR acc_cd = LEVELUP_CD
                                       ) -
                                    (SELECT coalesce(SUM(sign * CR_AMT),0)
                                          FROM SON_ACC2
                                         START WITH acc_cd = main.acc_cd
                                       CONNECT BY PRIOR acc_cd = LEVELUP_CD
                                       )
                                ELSE
                                    (SELECT coalesce(SUM(sign * CR_AMT),0)
                                          FROM SON_ACC2
                                         START WITH acc_cd = main.acc_cd
                                       CONNECT BY PRIOR acc_cd = LEVELUP_CD
                                       ) -
                                     (SELECT coalesce(SUM(sign * DR_AMT),0)
                                          FROM SON_ACC2
                                         START WITH acc_cd = main.acc_cd
                                       CONNECT BY PRIOR acc_cd = LEVELUP_CD
                                       )
                                END BE_AMT
                          FROM SON_ACC2 main
                         START WITH coalesce(LEVELUP_CD,'')='6000000'
                        CONNECT BY PRIOR acc_cd = LEVELUP_CD
                ) A
                LEFT OUTER JOIN GADMIN.BSACC2 B ON (A.ACC_CD = B.ACC_CD)
                WHERE 1 = 1
                  AND B.SONIK_DISP != 'N'
                GROUP BY A.ACC_CD, B.SONIK_DISP
            ) A
            WHERE A.CU_AMT + A.CU_TOT + A.BE_AMT + A.BE_TOT != 0 ;--


END P1;--

P2: BEGIN

    DECLARE CURSOR_TEMP CURSOR WITH RETURN FOR
    SELECT ACC_CD, CHULRYEOK_GWAMOK AS ACC_NM, CU_AMT, CU_TOT, BE_AMT, BE_TOT,
            (CU_AMT + CU_TOT) - (BE_AMT + BE_TOT) AS UPDOWN_AMT,
            coalesce(TRUNC( CASE BE_AMT + BE_TOT WHEN 0 THEN NULL
                                 ELSE ((CU_AMT + CU_TOT) - (BE_AMT + BE_TOT)) / (BE_AMT + BE_TOT) * 100
            END, 2),0) AS UPDOWN_RATE
      FROM (
                        SELECT A.*, B.CHULRYEOK_CD, B.CHULRYEOK_GWAMOK
                          FROM GADMIN.EBUS_FIN_INCOME A, GADMIN.BSACC2 B
                        WHERE 1 = 1
                          AND A.ACC_CD = B.ACC_CD
                        UNION ALL
                        SELECT A.*, '9000000', ''
                          FROM GADMIN.EBUS_FIN_INCOME A
                         WHERE A.ACC_CD = '9000000'
                     )
    ORDER BY CHULRYEOK_CD
    ;--

    OPEN CURSOR_TEMP;--
END P2;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN1101_TAB02_SELECT_OLD"
(IN IN_FROMDATE VARCHAR(10), IN IN_TODATE VARCHAR(10), IN IN_PRE_FROMDATE VARCHAR(10), IN IN_PRE_TODATE VARCHAR(10), IN IN_USER_ID VARCHAR(25))
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE   SQLSTATE          CHAR(5) DEFAULT '00000';--

P1: BEGIN

    DELETE FROM GADMIN.EBUS_FIN_INCOME;--

    INSERT INTO GADMIN.EBUS_FIN_INCOME
    SELECT A.ACC_CD, A.ACC_NM, SUM(CU_AMT) AS CU_AMT, SUM(CU_TOT) AS CU_TOT, SUM(BE_AMT) AS BE_AMT, SUM(BE_TOT) AS BE_TOT, NOW, IN_USER_ID, NULL, NULL
       FROM (
                --당기 손익계산서
                SELECT A.ACC_CD, A.ACC_NM, CU_AMT, CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM (
                          --일반계정
                          --운수수입
                          SELECT A.ACC_CD, A.ACC_NM, SUM(CR_AMT) - SUM(DR_AMT) AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                            FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                           WHERE 1 = 1
                             AND A.ACC_CD = B.ACC_CD
                             AND A.DATE BETWEEN IN_FROMDATE AND IN_TODATE
                             AND B.ACC_GB = '수익'
                             AND SUBSTRING(A.ACC_CD,1,2) = '61'
                            GROUP BY A.ACC_CD, A.ACC_NM
                          UNION ALL
                          --일반관리비
                          SELECT A.ACC_CD, A.ACC_NM, SUM(DR_AMT) - SUM(CR_AMT) AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                            FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                           WHERE 1 = 1
                             AND A.ACC_CD = B.ACC_CD
                             AND A.DATE BETWEEN IN_FROMDATE AND IN_TODATE
                             AND B.ACC_GB = '비용'
                             AND SUBSTRING(A.ACC_CD,1,2) = '64'
                           GROUP BY A.ACC_CD, A.ACC_NM
                           UNION ALL
                          --영업외 수익
                          SELECT A.ACC_CD, A.ACC_NM, SUM(CR_AMT) - SUM(DR_AMT) AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                            FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                           WHERE 1 = 1
                             AND A.ACC_CD = B.ACC_CD
                             AND A.DATE BETWEEN IN_FROMDATE AND IN_TODATE
                             AND B.ACC_GB = '수익'
                             AND SUBSTRING(A.ACC_CD,1,2) = '66'
                          GROUP BY A.ACC_CD, A.ACC_NM
                          UNION ALL
                          --영업외 비용
                          SELECT A.ACC_CD, A.ACC_NM, SUM(DR_AMT) - SUM(CR_AMT) AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                            FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                           WHERE 1 = 1
                             AND A.ACC_CD = B.ACC_CD
                             AND A.DATE BETWEEN IN_FROMDATE AND IN_TODATE
                             AND B.ACC_GB = '비용'
                             AND SUBSTRING(A.ACC_CD,1,2) = '67'
                           GROUP BY A.ACC_CD, A.ACC_NM
                           UNION ALL
                          --특별이익
                          SELECT A.ACC_CD, A.ACC_NM, SUM(CR_AMT) - SUM(DR_AMT) AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                            FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                           WHERE 1 = 1
                             AND A.ACC_CD = B.ACC_CD
                             AND A.DATE BETWEEN IN_FROMDATE AND IN_TODATE
                             AND B.ACC_GB = '수익'
                             AND SUBSTRING(A.ACC_CD,1,2) = '69'
                          GROUP BY A.ACC_CD, A.ACC_NM
                          UNION ALL
                          --법인세
                          SELECT A.ACC_CD, A.ACC_NM, SUM(DR_AMT) - SUM(CR_AMT) AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                            FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                           WHERE 1 = 1
                             AND A.ACC_CD = B.ACC_CD
                             AND A.DATE BETWEEN IN_FROMDATE AND IN_TODATE
                             AND B.ACC_GB = '비용'
                             AND A.ACC_CD = '7200100'
                          GROUP BY A.ACC_CD, A.ACC_NM
                        ) A
                        UNION ALL
                --전기 손익계산서
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, BE_AMT, BE_TOT
                  FROM (
                          --일반계정
                          --운수수입
                          SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, SUM(CR_AMT) - SUM(DR_AMT) AS BE_AMT, 0 AS BE_TOT
                            FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                           WHERE 1 = 1
                             AND A.ACC_CD = B.ACC_CD
                             AND A.DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                             AND B.ACC_GB = '수익'
                             AND SUBSTRING(A.ACC_CD,1,2) = '61'
                            GROUP BY A.ACC_CD, A.ACC_NM
                          UNION ALL
                          --일반관리비
                          SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, SUM(DR_AMT) - SUM(CR_AMT) AS CU_AMT, 0 AS CU_TOT
                            FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                           WHERE 1 = 1
                             AND A.ACC_CD = B.ACC_CD
                             AND A.DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                             AND B.ACC_GB = '비용'
                             AND SUBSTRING(A.ACC_CD,1,2) = '64'
                           GROUP BY A.ACC_CD, A.ACC_NM
                           UNION ALL
                          --영업외 수익
                          SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, SUM(CR_AMT) - SUM(DR_AMT) AS CU_AMT, 0 AS CU_TOT
                            FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                           WHERE 1 = 1
                             AND A.ACC_CD = B.ACC_CD
                             AND A.DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                             AND B.ACC_GB = '수익'
                             AND SUBSTRING(A.ACC_CD,1,2) = '66'
                          GROUP BY A.ACC_CD, A.ACC_NM
                          UNION ALL
                          --영업외 비용
                          SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, SUM(DR_AMT) - SUM(CR_AMT) AS CU_AMT, 0 AS CU_TOT
                            FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                           WHERE 1 = 1
                             AND A.ACC_CD = B.ACC_CD
                             AND A.DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                             AND B.ACC_GB = '비용'
                             AND SUBSTRING(A.ACC_CD,1,2) = '67'
                           GROUP BY A.ACC_CD, A.ACC_NM
                           UNION ALL
                          --특별이익
                          SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, SUM(CR_AMT) - SUM(DR_AMT) AS CU_AMT, 0 AS CU_TOT
                            FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                           WHERE 1 = 1
                             AND A.ACC_CD = B.ACC_CD
                             AND A.DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                             AND B.ACC_GB = '수익'
                             AND SUBSTRING(A.ACC_CD,1,2) = '69'
                          GROUP BY A.ACC_CD, A.ACC_NM
                          UNION ALL
                          --법인세
                          SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, SUM(DR_AMT) - SUM(CR_AMT) AS CU_AMT, 0 AS CU_TOT
                            FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                           WHERE 1 = 1
                             AND A.ACC_CD = B.ACC_CD
                             AND A.DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                             AND B.ACC_GB = '비용'
                             AND A.ACC_CD = '7200100'
                          GROUP BY A.ACC_CD, A.ACC_NM
                        ) A
             ) A, GADMIN.BSACC2 B
     WHERE A.ACC_CD = B.ACC_CD
       --AND B.SONIK_DISP != 'N'
       --AND NOT EXISTS (SELECT *   FROM GADMIN.BSACC2 C WHERE B.ACC_CD = C.ACC_CD AND C.HAPJAN_DISP = 'N')
       --AND NOT (A.DR_AMT = 0 AND A.CR_AMT = 0)
    GROUP BY A.ACC_CD, A.ACC_NM
    --ORDER BY B.CHULRYEOK_CD    -- 출력순서
    ;--

    --매출액
    --운수수입
    INSERT INTO GADMIN.EBUS_FIN_INCOME
    SELECT ACC_CD, ACC_NM, SUM(CU_AMT) AS CU_AMT, SUM(CU_TOT) AS CU_TOT, SUM(BE_AMT) AS BE_AMT, SUM(BE_TOT) AS BE_TOT, NOW, IN_USER_ID, NULL, NULL
       FROM (
                SELECT '6100000' AS ACC_CD, '(매   출   액)' AS ACC_NM, 0 AS CU_AMT, SUM(CU_AMT) AS CU_TOT, 0 AS BE_AMT, SUM(BE_AMT) AS BE_TOT
                  FROM GADMIN.EBUS_FIN_INCOME
                 WHERE ACC_CD LIKE '61%'
                UNION ALL
                SELECT '6100100' AS ACC_CD, '운  수  수  입' AS ACC_NM, 0 AS CU_AMT, SUM(CU_AMT) AS CU_TOT, 0 AS BE_AMT, SUM(BE_AMT) AS BE_TOT
                  FROM GADMIN.EBUS_FIN_INCOME
                 WHERE ACC_CD LIKE '61%'
             )
    GROUP BY ACC_CD, ACC_NM
       ;--

    --(운송원가및주택분양원가)
    INSERT INTO GADMIN.EBUS_FIN_INCOME
    SELECT ACC_CD, ACC_NM, SUM(CU_AMT) AS CU_AMT, SUM(CU_TOT) AS CU_TOT, SUM(BE_AMT) AS BE_AMT, SUM(BE_TOT) AS BE_TOT, NOW, IN_USER_ID, NULL, NULL
       FROM (
                --당기
                SELECT '6200000' AS ACC_CD, '(운송원가및주택분양원가)' AS ACC_NM, 0 AS CU_AMT, SUM(DR_AMT) - SUM(CR_AMT) AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND A.DATE BETWEEN IN_FROMDATE AND IN_TODATE
                   AND B.ACC_GB = '원가'
                   AND SUBSTRING(A.ACC_CD,1,2) = '62'
                UNION ALL
                --전기
                SELECT '6200000' AS ACC_CD, '(운송원가및주택분양원가)' AS ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, SUM(DR_AMT) - SUM(CR_AMT) AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND A.DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                   AND B.ACC_GB = '원가'
                   AND SUBSTRING(A.ACC_CD,1,2) = '62'
             )
    GROUP BY ACC_CD, ACC_NM
       ;                  --

    --매출  총이익
    INSERT INTO GADMIN.EBUS_FIN_INCOME
    SELECT '6300000' AS ACC_CD, '(매출  총이익)' AS ACC_NM, 0 AS CU_AMT, A.CU_TOT - B.CU_TOT, 0 AS BE_AMT, A.BE_TOT - B.BE_TOT AS BE_TOT, NOW, IN_USER_ID, NULL, NULL
       FROM (
                SELECT *    --매출액
                  FROM GADMIN.EBUS_FIN_INCOME
                 WHERE ACC_CD = '6100000' ) A,
             (  SELECT *    --운수원가
                  FROM GADMIN.EBUS_FIN_INCOME
                 WHERE ACC_CD = '6200000'  ) B
       ;--

    --일반관리비
    INSERT INTO GADMIN.EBUS_FIN_INCOME
    SELECT  ACC_CD, ACC_NM, SUM(CU_AMT) AS CU_AMT, SUM(CU_TOT) AS CU_TOT, SUM(BE_AMT) AS BE_AMT, SUM(BE_TOT) AS BE_TOT, NOW, IN_USER_ID, NULL, NULL
       FROM (
                SELECT '6400000' AS ACC_CD, '(일반  관리비)' AS ACC_NM, 0 AS CU_AMT, SUM(CU_AMT) AS CU_TOT, 0 AS BE_AMT, SUM(BE_AMT) AS BE_TOT
                  FROM GADMIN.EBUS_FIN_INCOME
                 WHERE ACC_CD LIKE '64%'
             )
    GROUP BY ACC_CD, ACC_NM
    ;--

    --영업이익
    INSERT INTO GADMIN.EBUS_FIN_INCOME
    SELECT '6500000' AS ACC_CD, '(영 업  이 익)' AS ACC_NM, 0 AS CU_AMT, A.CU_TOT - B.CU_TOT, 0 AS BE_AMT, A.BE_TOT - B.BE_TOT AS BE_TOT, NOW, IN_USER_ID, NULL, NULL
       FROM (
                SELECT *    --매출총이익
                  FROM GADMIN.EBUS_FIN_INCOME
                 WHERE ACC_CD = '6300000' ) A,
             (  SELECT *    --일반관리비
                  FROM GADMIN.EBUS_FIN_INCOME
                 WHERE ACC_CD = '6400000'  ) B
       ;--

    --영업외 수익
    INSERT INTO GADMIN.EBUS_FIN_INCOME
    SELECT '6600000' AS ACC_CD, '(영업 외 수익)' AS ACC_NM, SUM(CU_AMT) AS CU_AMT, SUM(CU_TOT) AS CU_TOT, SUM(BE_AMT) AS BE_AMT, SUM(BE_TOT) AS BE_TOT, NOW, IN_USER_ID, NULL, NULL
       FROM (
                SELECT '6600000' AS ACC_CD, '(영업 외 수익)' AS ACC_NM, 0 AS CU_AMT, SUM(CU_AMT) AS CU_TOT, 0 AS BE_AMT, SUM(BE_AMT) AS BE_TOT
                  FROM GADMIN.EBUS_FIN_INCOME
                 WHERE ACC_CD LIKE '66%'
             )
       ;--

    --영업외 비용
    INSERT INTO GADMIN.EBUS_FIN_INCOME
    SELECT '6700000' AS ACC_CD, '(영업 외 비용)' AS ACC_NM, SUM(CU_AMT) AS CU_AMT, SUM(CU_TOT) AS CU_TOT, SUM(BE_AMT) AS BE_AMT, SUM(BE_TOT) AS BE_TOT, NOW, IN_USER_ID, NULL, NULL
       FROM (
                SELECT '6700000' AS ACC_CD, '(영업 외 비용)' AS ACC_NM, 0 AS CU_AMT, SUM(CU_AMT) AS CU_TOT, 0 AS BE_AMT, SUM(BE_AMT) AS BE_TOT
                  FROM GADMIN.EBUS_FIN_INCOME
                 WHERE ACC_CD LIKE '67%'
             )
       ;--

    --경상이익
    INSERT INTO GADMIN.EBUS_FIN_INCOME
    SELECT '6800000' AS ACC_CD, '(경 상  이 익)' AS ACC_NM, 0 AS CU_AMT, A.CU_TOT + B.CU_TOT - C.CU_TOT, 0 AS BE_AMT, A.BE_TOT + B.BE_TOT - C.BE_TOT AS BE_TOT, NOW, IN_USER_ID, NULL, NULL
       FROM (
                SELECT *    --영업이익
                  FROM GADMIN.EBUS_FIN_INCOME
                 WHERE ACC_CD = '6500000' ) A,
             (  SELECT *    --영업외수익
                  FROM GADMIN.EBUS_FIN_INCOME
                 WHERE ACC_CD = '6600000'  ) B,
             (  SELECT *    --영업외비용
                  FROM GADMIN.EBUS_FIN_INCOME
                 WHERE ACC_CD = '6700000'  ) C

       ;--

    --특별이익
    INSERT INTO GADMIN.EBUS_FIN_INCOME
    SELECT '6900000' AS ACC_CD, '(특 별  이 익)' AS ACC_NM, SUM(CU_AMT) AS CU_AMT, SUM(CU_TOT) AS CU_TOT, SUM(BE_AMT) AS BE_AMT, SUM(BE_TOT) AS BE_TOT, NOW, IN_USER_ID, NULL, NULL
       FROM (
                SELECT '6900000' AS ACC_CD, '(특 별  이 익)' AS ACC_NM, 0 AS CU_AMT, SUM(CU_AMT) AS CU_TOT, 0 AS BE_AMT, SUM(BE_AMT) AS BE_TOT
                  FROM GADMIN.EBUS_FIN_INCOME
                 WHERE ACC_CD LIKE '69%'
             )
    ;--

    --법인세
    INSERT INTO GADMIN.EBUS_FIN_INCOME
    SELECT '7200000' AS ACC_CD, '(법 인 세  등)' AS ACC_NM, SUM(CU_AMT) AS CU_AMT, SUM(CU_TOT) AS CU_TOT, SUM(BE_AMT) AS BE_AMT, SUM(BE_TOT) AS BE_TOT, NOW, IN_USER_ID, NULL, NULL
       FROM (
                SELECT '7200000' AS ACC_CD, '(법 인 세  등)' AS ACC_NM, 0 AS CU_AMT, SUM(CU_AMT) AS CU_TOT, 0 AS BE_AMT, SUM(BE_AMT) AS BE_TOT
                  FROM GADMIN.EBUS_FIN_INCOME
                 WHERE ACC_CD LIKE '72%'
             )
    ;--

    --당기순이익
    INSERT INTO GADMIN.EBUS_FIN_INCOME
    SELECT '7300909' AS ACC_CD, '(당기 순 이익)' AS ACC_NM, 0 AS CU_AMT, A.CU_TOT + B.CU_TOT - C.CU_TOT, 0 AS BE_AMT, A.BE_TOT + B.BE_TOT - C.BE_TOT AS BE_TOT, NOW, IN_USER_ID, NULL, NULL
       FROM (
                SELECT ACC_CD, ACC_NM, COALESCE(CU_AMT,0) AS CU_AMT, COALESCE(CU_TOT,0) AS CU_TOT, COALESCE(BE_AMT,0) AS BE_AMT, COALESCE(BE_TOT,0) AS BE_TOT, NULL, NULL, NULL, NULL  --경상이익
                  FROM GADMIN.EBUS_FIN_INCOME
                 WHERE ACC_CD = '6800000' ) A,
             (  SELECT ACC_CD, ACC_NM, COALESCE(CU_AMT,0) AS CU_AMT, COALESCE(CU_TOT,0) AS CU_TOT, COALESCE(BE_AMT,0) AS BE_AMT, COALESCE(BE_TOT,0) AS BE_TOT, NULL, NULL, NULL, NULL  --특별이익
                  FROM GADMIN.EBUS_FIN_INCOME
                 WHERE ACC_CD = '6900000'  ) B,
             (  SELECT ACC_CD, ACC_NM, COALESCE(CU_AMT,0) AS CU_AMT, COALESCE(CU_TOT,0) AS CU_TOT, COALESCE(BE_AMT,0) AS BE_AMT, COALESCE(BE_TOT,0) AS BE_TOT, NULL, NULL, NULL, NULL    --법인세
                  FROM GADMIN.EBUS_FIN_INCOME
                 WHERE ACC_CD = '7200000'  ) C
       ;    --

END P1;--

P2: BEGIN

    DECLARE CURSOR_TEMP CURSOR WITH RETURN FOR
    SELECT ACC_CD, CHULRYEOK_GWAMOK AS ACC_NM, CU_AMT, CU_TOT, BE_AMT, BE_TOT,
            (CU_AMT + CU_TOT) - (BE_AMT + BE_TOT) AS UPDOWN_AMT,
            TRUNC( CASE BE_AMT + BE_TOT WHEN 0 THEN NULL
                                 ELSE ((CU_AMT + CU_TOT) - (BE_AMT + BE_TOT)) / (BE_AMT + BE_TOT) * 100
            END, 2) AS UPDOWN_RATE
      FROM (
                        SELECT A.*, B.CHULRYEOK_CD, B.CHULRYEOK_GWAMOK
                          FROM GADMIN.EBUS_FIN_INCOME A, GADMIN.BSACC2 B
                        WHERE 1 = 1
                          AND A.ACC_CD = B.ACC_CD
                        UNION ALL
                        SELECT A.*, '9000000', ''
                          FROM GADMIN.EBUS_FIN_INCOME A
                         WHERE A.ACC_CD = '9000000'
                     )
    ORDER BY CHULRYEOK_CD
    ;--

    OPEN CURSOR_TEMP;--
END P2;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN1101_TAB03_SELECT"
(IN IN_FROMDATE VARCHAR(10), IN IN_TODATE VARCHAR(10), IN IN_PRE_FROMDATE VARCHAR(10), IN IN_PRE_TODATE VARCHAR(10), IN IN_USER_ID VARCHAR(25))
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE   SQLSTATE          CHAR(5) DEFAULT '00000';--

    DECLARE GLOBAL TEMPORARY TABLE SESSION.TEMP
    (
        ACC_CD          VARCHAR(20)   DEFAULT '',
        ACC_NM          VARCHAR(60)   DEFAULT '',
        CU_AMT		    DECIMAL(20,5) DEFAULT 0,
        CU_TOT          DECIMAL(20,5) DEFAULT 0,
        BE_AMT          DECIMAL(20,5) DEFAULT 0,
        BE_TOT          DECIMAL(20,5) DEFAULT 0
    )  ON COMMIT PRESERVE ROWS
  WITH REPLACE
  NOT LOGGED;--

P1: BEGIN

    INSERT INTO SESSION.TEMP
                    WITH JAE_ACC AS (
                        SELECT B.DRCR_GB, CASE B.DRCR_GB WHEN '차변'THEN A.DR_AMT - A.CR_AMT ELSE 0 END AS DR_JAN_AMT, A.DR_AMT, B.ACC_CD, B.ACC_NM,  A.CR_AMT, (CASE B.DRCR_GB WHEN '대변'THEN A.CR_AMT - A.DR_AMT ELSE 0 END) AS CR_JAN_AMT, (case when CHAGAM_GB = '차감' then -1 else 1 end) as sign, b.levelup_cd as levelup_cd
                           FROM (
                                            SELECT A.ACC_CD, MAX(A.ACC_NM) AS ACC_NM, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT   --일반계정 집계
                                              FROM (
                                                         SELECT ACC_CD, ACC_NM, DR_AMT, CR_AMT
                                                           FROM GADMIN.ACCOU1
                                                          WHERE DATE BETWEEN IN_FROMDATE AND IN_TODATE
                                                         UNION ALL
                                                         SELECT '1110101' AS ACC_CD, '현          금 ' AS ACC_NM, SUM(CR_AMT) AS DR_AMT, SUM(DR_AMT) AS CR_AMT   --현금계정 집계
                                                           FROM GADMIN.ACCOU1
                                                          WHERE DRCR_GB IN ('입금','출금')
                                                            AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                                                         UNION ALL
                                                         SELECT ACC_CD, ACC_NM, DR_AMT, CR_AMT                  --전기이월 포함
                                                           FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_FROMDATE))
                                                         UNION ALL
                                                         SELECT '3300909' AS ACC_CD, '((당기순이익))' AS ACC_NM, 0 AS DR_AMT, S.CU_TOT AS CR_AMT
                                                           FROM GADMIN.EBUS_FIN_INCOME S
                                                          WHERE S.ACC_CD = '7300909'
                                                    ) A, GADMIN.BSACC2 B
                                     WHERE 1 = 1
                                       AND A.ACC_CD = B.ACC_CD
                                    GROUP BY A.ACC_CD
                                ) A RIGHT OUTER JOIN GADMIN.BSACC2 B ON A.ACC_CD = B.ACC_CD

                    ),
                    JAE_ACC2 AS (
                        SELECT B.DRCR_GB, CASE B.DRCR_GB WHEN '차변'THEN A.DR_AMT - A.CR_AMT ELSE 0 END AS DR_JAN_AMT, A.DR_AMT, B.ACC_CD, B.ACC_NM,  A.CR_AMT, (CASE B.DRCR_GB WHEN '대변'THEN A.CR_AMT - A.DR_AMT ELSE 0 END) AS CR_JAN_AMT, (case when CHAGAM_GB = '차감' then -1 else 1 end) as sign, b.levelup_cd as levelup_cd
                           FROM (
                                            SELECT A.ACC_CD, MAX(A.ACC_NM) AS ACC_NM, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT   --일반계정 집계
                                              FROM (
                                                         SELECT ACC_CD, ACC_NM, DR_AMT, CR_AMT
                                                           FROM GADMIN.ACCOU1
                                                          WHERE DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                                                         UNION ALL
                                                         SELECT '1110101' AS ACC_CD, '현          금 ' AS ACC_NM, SUM(CR_AMT) AS DR_AMT, SUM(DR_AMT) AS CR_AMT   --현금계정 집계
                                                           FROM GADMIN.ACCOU1
                                                          WHERE DRCR_GB IN ('입금','출금')
                                                            AND DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                                                         UNION ALL
                                                         SELECT ACC_CD, ACC_NM, DR_AMT, CR_AMT                  --전기이월 포함
                                                           FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_PRE_FROMDATE))
                                                         UNION ALL
                                                         SELECT '3300909' AS ACC_CD, '((당기순이익))' AS ACC_NM, 0 AS DR_AMT, S.BE_TOT AS CR_AMT
                                                           FROM GADMIN.EBUS_FIN_INCOME S
                                                          WHERE S.ACC_CD = '7300909'
                                                    ) A, GADMIN.BSACC2 B
                                     WHERE 1 = 1
                                       AND A.ACC_CD = B.ACC_CD
                                    GROUP BY A.ACC_CD
                                ) A RIGHT OUTER JOIN GADMIN.BSACC2 B ON A.ACC_CD = B.ACC_CD

                    )
                    SELECT ACC_CD, ACC_NM, CU_AMT, CU_TOT, BE_AMT, BE_TOT
                       FROM (
                            SELECT A.ACC_CD, MAX(A.ACC_NM) AS ACC_NM
                                   , coalesce(CASE WHEN DAECHA_CHECK = 'L' THEN  coalesce(SUM(A.CU_AMT),0) END, 0) AS CU_AMT,  coalesce(CASE WHEN DAECHA_CHECK = 'R' THEN  coalesce(SUM(A.CU_AMT),0) END, 0) AS CU_TOT
                                   , coalesce(CASE WHEN DAECHA_CHECK = 'L' THEN  coalesce(SUM(A.BE_AMT),0) END, 0) AS BE_AMT, coalesce(CASE WHEN DAECHA_CHECK = 'R' THEN  coalesce(SUM(A.BE_AMT),0) END, 0) AS BE_TOT
                               FROM (
                            SELECT ACC_CD, ACC_NM,
                                   CASE WHEN DRCR_GB IN ('차변','출금') THEN
                                         (SELECT coalesce(SUM(sign * DR_AMT),0)
                                              FROM JAE_ACC
                                             START WITH acc_cd = main.acc_cd
                                           CONNECT BY PRIOR acc_cd = LEVELUP_CD
                                           ) -
                                        (SELECT coalesce(SUM(sign * CR_AMT),0)
                                              FROM JAE_ACC
                                             START WITH acc_cd = main.acc_cd
                                           CONNECT BY PRIOR acc_cd = LEVELUP_CD
                                           )
                                    ELSE
                                        (SELECT coalesce(SUM(sign * CR_AMT),0)
                                              FROM JAE_ACC
                                             START WITH acc_cd = main.acc_cd
                                           CONNECT BY PRIOR acc_cd = LEVELUP_CD
                                           ) -
                                         (SELECT coalesce(SUM(sign * DR_AMT),0)
                                              FROM JAE_ACC
                                             START WITH acc_cd = main.acc_cd
                                           CONNECT BY PRIOR acc_cd = LEVELUP_CD
                                           )
                                    END AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                              FROM JAE_ACC main
                             START WITH coalesce(LEVELUP_CD,'')=''
                            CONNECT BY PRIOR acc_cd = LEVELUP_CD
                            UNION ALL
                            SELECT ACC_CD, ACC_NM
                                    , 0 AS CU_AMT, 0 AS CU_TOT,
                                   CASE WHEN DRCR_GB IN ('차변','출금') THEN
                                         (SELECT coalesce(SUM(sign * DR_AMT),0)
                                              FROM JAE_ACC2
                                             START WITH acc_cd = main.acc_cd
                                           CONNECT BY PRIOR acc_cd = LEVELUP_CD
                                           ) -
                                        (SELECT coalesce(SUM(sign * CR_AMT),0)
                                              FROM JAE_ACC2
                                             START WITH acc_cd = main.acc_cd
                                           CONNECT BY PRIOR acc_cd = LEVELUP_CD
                                           )
                                    ELSE
                                        (SELECT coalesce(SUM(sign * CR_AMT),0)
                                              FROM JAE_ACC2
                                             START WITH acc_cd = main.acc_cd
                                           CONNECT BY PRIOR acc_cd = LEVELUP_CD
                                           ) -
                                         (SELECT coalesce(SUM(sign * DR_AMT),0)
                                              FROM JAE_ACC2
                                             START WITH acc_cd = main.acc_cd
                                           CONNECT BY PRIOR acc_cd = LEVELUP_CD
                                           )
                                    END AS BE_AMT, 0 AS BE_TOT
                              FROM JAE_ACC2 main
                             START WITH coalesce(LEVELUP_CD,'')=''
                            CONNECT BY PRIOR acc_cd = LEVELUP_CD
                            ) A LEFT OUTER JOIN GADMIN.BSACC2 B ON (A.ACC_CD = B.ACC_CD)
                     WHERE 1 = 1
                       AND B.ACC_GB IN ('자산','부채','자본')
                       AND B.DAECHA_CHECK != 'N'
                    GROUP BY A.ACC_CD, B.DRCR_GB, B.DAECHA_CHECK
                    )
           WHERE 1 = 1
             AND CU_AMT + CU_TOT + BE_AMT + BE_TOT != 0
        ;--
END P1;--

P2: BEGIN

    DECLARE CURSOR_TEMP CURSOR WITH RETURN FOR
    SELECT ACC_CD, ACC_NM, CASE WHEN ACC_GB = '자산' THEN ( CASE WHEN DRCR_GB = '차변' THEN CU_AMT ELSE CU_AMT * -1 END)
                                ELSE (CASE WHEN ACC_GB = '부채' OR  ACC_GB = '자본' THEN ( CASE WHEN DRCR_GB = '대변' THEN CU_AMT ELSE CU_AMT * -1 END) ELSE CU_AMT END)
                             END AS CU_AMT, CU_TOT,
                              CASE WHEN ACC_GB = '자산' THEN ( CASE WHEN DRCR_GB = '차변' THEN BE_AMT ELSE BE_AMT * -1 END)
                                ELSE (CASE WHEN ACC_GB = '부채' OR  ACC_GB = '자본' THEN ( CASE WHEN DRCR_GB = '대변' THEN BE_AMT ELSE BE_AMT * -1 END) ELSE BE_AMT END)
                             END AS BE_AMT, BE_TOT,
            (CU_AMT + CU_TOT) - (BE_AMT + BE_TOT) AS UPDOWN_AMT,
            TRUNC( CASE BE_AMT + BE_TOT WHEN 0 THEN NULL
                                 ELSE ((CU_AMT + CU_TOT) - (BE_AMT + BE_TOT)) / (BE_AMT + BE_TOT) * 100
            END, 2) AS UPDOWN_RATE
      FROM (
                        SELECT A.*, B.CHULRYEOK_CD, B.ACC_GB, B.DRCR_GB
                           FROM SESSION.TEMP A, GADMIN.BSACC2 B
                        WHERE 1 = 1
                          AND A.ACC_CD = B.ACC_CD
                          AND B.DAECHA_CHECK != 'N'

                     )
    WHERE NOT (CU_AMT = 0 AND CU_TOT = 0 AND BE_AMT = 0 AND BE_TOT = 0)
    ORDER BY CHULRYEOK_CD
    ;--

    OPEN CURSOR_TEMP;--
END P2;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN1101_TAB03_SELECT_OLD"
(IN IN_FROMDATE VARCHAR(10), IN IN_TODATE VARCHAR(10), IN IN_PRE_FROMDATE VARCHAR(10), IN IN_PRE_TODATE VARCHAR(10), IN IN_USER_ID VARCHAR(25))
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE   SQLSTATE          CHAR(5) DEFAULT '00000';--

    DECLARE GLOBAL TEMPORARY TABLE SESSION.TEMP
    (
        ACC_CD          VARCHAR(20)   DEFAULT '',
        ACC_NM          VARCHAR(60)   DEFAULT '',
        CU_AMT		    DECIMAL(20,5) DEFAULT 0,
        CU_TOT          DECIMAL(20,5) DEFAULT 0,
        BE_AMT          DECIMAL(20,5) DEFAULT 0,
        BE_TOT          DECIMAL(20,5) DEFAULT 0
    )  ON COMMIT PRESERVE ROWS
  WITH REPLACE
  NOT LOGGED;--

P1: BEGIN

    INSERT INTO SESSION.TEMP
    SELECT A.ACC_CD, '  '||A.ACC_NM AS ACC_NM, SUM(CU_AMT) AS CU_AMT, SUM(CU_TOT) AS CU_TOT, SUM(BE_AMT) AS BE_AMT, SUM(BE_TOT) AS BE_TOT
      FROM (
            --당기
            SELECT A.ACC_CD, A.ACC_NM, SUM(A.DR_AMT - A.CR_AMT) AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
              FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
             WHERE 1 = 1
               AND A.ACC_CD = B.ACC_CD
               AND B.ACC_GB = '자산'
               AND A.ACC_CD LIKE '1%'
               AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
             GROUP BY A.ACC_CD, A.ACC_NM
             UNION ALL
             SELECT '1110101' AS ACC_CD, '현          금' AS ACC_NM, SUM(A.CR_AMT - A.DR_AMT) AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
               FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
              WHERE 1 = 1
                AND A.ACC_CD = B.ACC_CD
                AND A.DRCR_GB IN ('입금','출금')
                AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
              GROUP BY A.ACC_CD, A.ACC_NM
              UNION ALL
            SELECT A.ACC_CD, A.ACC_NM, SUM(A.DR_AMT - A.CR_AMT) AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
              FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_FROMDATE)) A, GADMIN.BSACC2 B
             WHERE 1 = 1
               AND A.ACC_CD = B.ACC_CD
               AND B.ACC_GB = '자산'
               AND A.ACC_CD LIKE '1%'
             GROUP BY A.ACC_CD, A.ACC_NM
             UNION ALL
            SELECT '3300909' AS ACC_CD, A.ACC_NM, CU_AMT, CU_TOT, BE_AMT, BE_TOT
              FROM GADMIN.EBUS_FIN_INCOME A
             WHERE A.ACC_CD = '7300909'
             UNION ALL
             --전기
            SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, SUM(A.DR_AMT - A.CR_AMT) AS BE_AMT, 0 AS BE_TOT
              FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
             WHERE 1 = 1
               AND A.ACC_CD = B.ACC_CD
               AND B.ACC_GB = '자산'
               AND A.ACC_CD LIKE '1%'
               AND DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
             GROUP BY A.ACC_CD, A.ACC_NM
             UNION ALL
             SELECT '1110101' AS ACC_CD, '현          금' AS ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, SUM(A.CR_AMT - A.DR_AMT) AS BE_AMT, 0 AS BE_TOT
               FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
              WHERE 1 = 1
                AND A.ACC_CD = B.ACC_CD
                AND A.DRCR_GB IN ('입금','출금')
               AND DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
              GROUP BY A.ACC_CD, A.ACC_NM
              UNION ALL
            SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, SUM(A.DR_AMT - A.CR_AMT) AS BE_AMT, 0 AS BE_TOT
              FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_PRE_FROMDATE)) A, GADMIN.BSACC2 B
             WHERE 1 = 1
               AND A.ACC_CD = B.ACC_CD
               AND B.ACC_GB = '자산'
               AND A.ACC_CD LIKE '1%'
             GROUP BY A.ACC_CD, A.ACC_NM
             ) A, GADMIN.BSACC2 B
        WHERE A.ACC_CD = B.ACC_CD
          AND NOT (CU_AMT = 0 AND CU_TOT = 0 AND BE_AMT = 0 AND BE_TOT = 0)
    GROUP BY A.ACC_CD, A.ACC_NM;--

--자산   8,022,813,907
    INSERT INTO SESSION.TEMP
    SELECT  '1000000' AS ACC_CD, '(자        산)' AS ACC_NM, SUM(CU_AMT) AS CU_AMT, SUM(CU_TOT) AS CU_TOT, SUM(BE_AMT) AS BE_AMT, SUM(BE_TOT) AS BE_TOT
      FROM (
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, SUM(A.DR_AMT - A.CR_AMT) AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND A.ACC_CD LIKE '1%'
                   AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                 UNION ALL
                 SELECT '1110101' AS ACC_CD, '현          금' AS ACC_NM, 0 AS CU_AMT, SUM(A.CR_AMT - A.DR_AMT) AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                   FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                  WHERE 1 = 1
                    AND A.ACC_CD = B.ACC_CD
                    AND A.DRCR_GB IN ('입금','출금')
                    AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                  GROUP BY A.ACC_CD, A.ACC_NM
                  UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, SUM(A.DR_AMT - A.CR_AMT) AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND A.ACC_CD LIKE '1%'
                 GROUP BY A.ACC_CD, A.ACC_NM
                UNION ALL
                --전기
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, SUM(A.DR_AMT - A.CR_AMT) AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND A.ACC_CD LIKE '1%'
                   AND DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                 UNION ALL
                 SELECT '1110101' AS ACC_CD, '현          금' AS ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, SUM(A.CR_AMT - A.DR_AMT) AS BE_TOT
                   FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                  WHERE 1 = 1
                    AND A.ACC_CD = B.ACC_CD
                    AND A.DRCR_GB IN ('입금','출금')
                    AND DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                  GROUP BY A.ACC_CD, A.ACC_NM
                  UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, SUM(A.DR_AMT - A.CR_AMT) AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_PRE_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND A.ACC_CD LIKE '1%'
                 GROUP BY A.ACC_CD, A.ACC_NM
             ) A, GADMIN.BSACC2 B
        WHERE A.ACC_CD = B.ACC_CD;--


 --(유 동  자 산)  1100000  1,653,196,746
    INSERT INTO SESSION.TEMP
    SELECT  '1100000' AS ACC_CD, '(유 동  자 산)' AS ACC_NM, SUM(CU_AMT) AS AMT, SUM(CU_TOT) AS CU_TOT, SUM(BE_AMT) AS BE_AMT, SUM(BE_TOT) AS BE_TOT
      FROM (
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, SUM(A.DR_AMT - A.CR_AMT) AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND A.ACC_CD LIKE '11%'
                   AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                 UNION ALL
                 SELECT '1110101' AS ACC_CD, '현          금' AS ACC_NM, 0 AS CU_AMT, SUM(A.CR_AMT - A.DR_AMT) AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                   FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                  WHERE 1 = 1
                    AND A.ACC_CD = B.ACC_CD
                    AND A.DRCR_GB IN ('입금','출금')
                    AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                  GROUP BY A.ACC_CD, A.ACC_NM
                  UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, SUM(A.DR_AMT - A.CR_AMT) AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND A.ACC_CD LIKE '11%'
                 GROUP BY A.ACC_CD, A.ACC_NM
                UNION ALL
                --전기
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, SUM(A.DR_AMT - A.CR_AMT) AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND A.ACC_CD LIKE '11%'
                   AND DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                 UNION ALL
                 SELECT '1110101' AS ACC_CD, '현          금' AS ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, SUM(A.CR_AMT - A.DR_AMT) AS BE_TOT
                   FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                  WHERE 1 = 1
                    AND A.ACC_CD = B.ACC_CD
                    AND A.DRCR_GB IN ('입금','출금')
                    AND DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                  GROUP BY A.ACC_CD, A.ACC_NM
                  UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, SUM(A.DR_AMT - A.CR_AMT) AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_PRE_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND A.ACC_CD LIKE '11%'
                 GROUP BY A.ACC_CD, A.ACC_NM         ) A, GADMIN.BSACC2 B
        WHERE A.ACC_CD = B.ACC_CD;--



 --(당 좌  자 산)  1100000  1,200,164,450
    INSERT INTO SESSION.TEMP
    SELECT  '1110000' AS ACC_CD, '(당 좌  자 산)' AS ACC_NM, SUM(CU_AMT) AS CU_AMT, SUM(CU_TOT) AS CU_TOT, SUM(BE_AMT) AS BE_AMT, SUM(BE_TOT) AS BE_TOT
      FROM (
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, SUM(A.DR_AMT - A.CR_AMT) AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND A.ACC_CD LIKE '111%'
                   AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                 UNION ALL
                 SELECT '1110101' AS ACC_CD, '현          금' AS ACC_NM, 0 AS CU_AMT, SUM(A.CR_AMT - A.DR_AMT) AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                   FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                  WHERE 1 = 1
                    AND A.ACC_CD = B.ACC_CD
                    AND A.DRCR_GB IN ('입금','출금')
                    AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                  GROUP BY A.ACC_CD, A.ACC_NM
                  UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, SUM(A.DR_AMT - A.CR_AMT) AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND A.ACC_CD LIKE '111%'
                 GROUP BY A.ACC_CD, A.ACC_NM
            --전기
            UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, SUM(A.DR_AMT - A.CR_AMT) AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND A.ACC_CD LIKE '111%'
                   AND DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                 UNION ALL
                 SELECT '1110101' AS ACC_CD, '현          금' AS ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, SUM(A.CR_AMT - A.DR_AMT) AS BE_TOT
                   FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                  WHERE 1 = 1
                    AND A.ACC_CD = B.ACC_CD
                    AND A.DRCR_GB IN ('입금','출금')
                    AND DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                  GROUP BY A.ACC_CD, A.ACC_NM
                  UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, SUM(A.DR_AMT - A.CR_AMT) AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_PRE_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND A.ACC_CD LIKE '111%'
                 GROUP BY A.ACC_CD, A.ACC_NM
             ) A, GADMIN.BSACC2 B
        WHERE A.ACC_CD = B.ACC_CD;--

--  현금및현금등가물  1100100  234,388,369
    INSERT INTO SESSION.TEMP
    SELECT  '1110100' AS ACC_CD, '  현금및현금등가물' AS ACC_NM, SUM(CU_AMT) AS CU_AMT, SUM(CU_TOT) AS CU_TOT, SUM(BE_AMT) AS BE_AMT, SUM(BE_TOT) AS BE_TOT
      FROM (
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, SUM(A.DR_AMT - A.CR_AMT) AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND A.ACC_CD LIKE '11101%'
                   AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                 UNION ALL
                 SELECT '1110101' AS ACC_CD, '현          금' AS ACC_NM, 0 AS CU_AMT, SUM(A.CR_AMT - A.DR_AMT) AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                   FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                  WHERE 1 = 1
                    AND A.ACC_CD = B.ACC_CD
                    AND A.DRCR_GB IN ('입금','출금')
                    AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                  GROUP BY A.ACC_CD, A.ACC_NM
                  UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, SUM(A.DR_AMT - A.CR_AMT) AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND A.ACC_CD LIKE '11101%'
                 GROUP BY A.ACC_CD, A.ACC_NM
             UNION ALL
             --전기
             SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, SUM(A.DR_AMT - A.CR_AMT) AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND A.ACC_CD LIKE '11101%'
                   AND DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                 UNION ALL
                 SELECT '1110101' AS ACC_CD, '현          금' AS ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, SUM(A.CR_AMT - A.DR_AMT) AS BE_TOT
                   FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                  WHERE 1 = 1
                    AND A.ACC_CD = B.ACC_CD
                    AND A.DRCR_GB IN ('입금','출금')
                    AND DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                  GROUP BY A.ACC_CD, A.ACC_NM
                  UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, SUM(A.DR_AMT - A.CR_AMT) AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_PRE_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND A.ACC_CD LIKE '11101%'
                 GROUP BY A.ACC_CD, A.ACC_NM
             ) A, GADMIN.BSACC2 B
        WHERE A.ACC_CD = B.ACC_CD;--


--  매  출  채  권  1110400
    INSERT INTO SESSION.TEMP
    SELECT '1110400' AS ACC_CD, ' '||'매  출  채  권' AS ACC_NM, SUM(CU_AMT) AS CU_AMT, SUM(CU_TOT) AS CU_TOT, SUM(BE_AMT) AS BE_AMT, SUM(BE_TOT) AS BE_TOT
      FROM (
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, SUM(A.DR_AMT - A.CR_AMT) AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND B.CHULRYEOK_CD LIKE '1110400%'
                   AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                 UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS AMT, SUM(A.DR_AMT - A.CR_AMT) AS TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND B.CHULRYEOK_CD LIKE '1110400%'
                 GROUP BY A.ACC_CD, A.ACC_NM
                UNION ALL
                --전기
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, SUM(A.DR_AMT - A.CR_AMT) AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND B.CHULRYEOK_CD LIKE '1110400%'
                   AND DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                 UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS AMT, 0 AS TOT, 0 AS BE_AMT, SUM(A.DR_AMT - A.CR_AMT) AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_PRE_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND B.CHULRYEOK_CD LIKE '1110400%'
                 GROUP BY A.ACC_CD, A.ACC_NM
             ) A, GADMIN.BSACC2 B
        WHERE A.ACC_CD = B.ACC_CD;--


--  임원종업원단기대여금  1110800  271,527
    INSERT INTO SESSION.TEMP
    SELECT  '1110800' AS ACC_CD, ' '||'임원종업원단기대여금' AS ACC_NM, SUM(CU_AMT) AS CU_AMT, SUM(CU_TOT) AS CU_TOT, SUM(BE_AMT) AS BE_AMT, SUM(BE_TOT) AS BE_TOT
      FROM (
                SELECT A.ACC_CD, A.ACC_NM, SUM(A.DR_AMT - A.CR_AMT) AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND A.ACC_CD LIKE '11108%'
                   AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                 UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, SUM(A.DR_AMT - A.CR_AMT) AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND A.ACC_CD LIKE '11108%'
                 GROUP BY A.ACC_CD, A.ACC_NM
                UNION ALL
                --전기
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, SUM(A.DR_AMT - A.CR_AMT) AS BE_AMT, 0 AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND A.ACC_CD LIKE '11108%'
                   AND DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                 UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS AMT, 0 AS TOT, SUM(A.DR_AMT - A.CR_AMT) AS BE_AMT, 0 AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_PRE_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND A.ACC_CD LIKE '11108%'
                 GROUP BY A.ACC_CD, A.ACC_NM
             ) A, GADMIN.BSACC2 B
        WHERE A.ACC_CD = B.ACC_CD;--

--  (재 고  자 산)  1120000  453,032,296
    INSERT INTO SESSION.TEMP
    SELECT  '1120000' AS ACC_CD, '(재 고  자 산)' AS ACC_NM, SUM(CU_AMT) AS CU_AMT, SUM(CU_TOT) AS CU_TOT, SUM(BE_AMT) AS BE_AMT, SUM(BE_TOT) AS BE_TOT
      FROM (
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, SUM(A.DR_AMT - A.CR_AMT) AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND A.ACC_CD LIKE '112%'
                   AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                 UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, SUM(A.DR_AMT - A.CR_AMT) AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND A.ACC_CD LIKE '112%'
                 GROUP BY A.ACC_CD, A.ACC_NM
                UNION ALL
                --전기
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, SUM(A.DR_AMT - A.CR_AMT) AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND A.ACC_CD LIKE '112%'
                   AND DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                 UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, SUM(A.DR_AMT - A.CR_AMT) AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_PRE_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND A.ACC_CD LIKE '112%'
                 GROUP BY A.ACC_CD, A.ACC_NM
             ) A, GADMIN.BSACC2 B
        WHERE A.ACC_CD = B.ACC_CD;--

--  저    장    품  1120100
    INSERT INTO SESSION.TEMP
    SELECT  '1120100' AS ACC_CD, '  '||'저    장    품' AS ACC_NM, SUM(CU_AMT) AS CU_AMT, SUM(CU_TOT) AS CU_TOT, SUM(BE_AMT) AS BE_AMT, SUM(BE_TOT) AS BE_TOT
      FROM (
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, SUM(A.DR_AMT - A.CR_AMT) AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND A.ACC_CD LIKE '11201%'
                   AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                 UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, SUM(A.DR_AMT - A.CR_AMT) AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND A.ACC_CD LIKE '11201%'
                 GROUP BY A.ACC_CD, A.ACC_NM
                UNION ALL
                --전기
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, SUM(A.DR_AMT - A.CR_AMT) AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND A.ACC_CD LIKE '11201%'
                   AND DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                 UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, SUM(A.DR_AMT - A.CR_AMT) AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_PRE_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND A.ACC_CD LIKE '11201%'
                 GROUP BY A.ACC_CD, A.ACC_NM
             ) A, GADMIN.BSACC2 B
        WHERE A.ACC_CD = B.ACC_CD;--


--  (고 정  자 산)  1200000  6,369,617,161
    INSERT INTO SESSION.TEMP
    SELECT  '1200000' AS ACC_CD, '(고 정  자 산)' AS ACC_NM, SUM(CU_AMT) AS CU_AMT, SUM(CU_TOT) AS CU_TOT, SUM(BE_AMT) AS BE_AMT, SUM(BE_TOT) AS BE_TOT
      FROM (
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, SUM(A.DR_AMT - A.CR_AMT) AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND A.ACC_CD LIKE '12%'
                   AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                 UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS AMT, SUM(A.DR_AMT - A.CR_AMT) AS TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND A.ACC_CD LIKE '12%'
                 GROUP BY A.ACC_CD, A.ACC_NM
                UNION ALL
                --전기
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, SUM(A.DR_AMT - A.CR_AMT) AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND A.ACC_CD LIKE '12%'
                   AND DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                 UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS AMT, 0 AS TOT, 0 AS BE_AMT, SUM(A.DR_AMT - A.CR_AMT) AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_PRE_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND A.ACC_CD LIKE '12%'
                 GROUP BY A.ACC_CD, A.ACC_NM
             ) A, GADMIN.BSACC2 B
        WHERE A.ACC_CD = B.ACC_CD;--

--  (투 자  자 산)  1210000  84,453,000
    INSERT INTO SESSION.TEMP
    SELECT  '1210000' AS ACC_CD, '(투 자  자 산)' AS ACC_NM, SUM(CU_AMT) AS CU_AMT, SUM(CU_TOT) AS CU_TOT, SUM(BE_AMT) AS BE_AMT, SUM(BE_TOT) AS BE_TOT
      FROM (
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, SUM(A.DR_AMT - A.CR_AMT) AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND B.CHULRYEOK_CD LIKE '121%'  --ACC_CD와 CHULRYEOK_CD가 달라 ACC_CD를 사용못함(집계도 틀림)
                   AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                 UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, SUM(A.DR_AMT - A.CR_AMT) AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND B.CHULRYEOK_CD LIKE '121%'  --ACC_CD와 CHULRYEOK_CD가 달라 ACC_CD를 사용못함(집계도 틀림)
                 GROUP BY A.ACC_CD, A.ACC_NM
                UNION ALL
                --전기
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT,  SUM(A.DR_AMT - A.CR_AMT) AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND B.CHULRYEOK_CD LIKE '121%'  --ACC_CD와 CHULRYEOK_CD가 달라 ACC_CD를 사용못함(집계도 틀림)
                   AND DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                 UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, SUM(A.DR_AMT - A.CR_AMT) AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_PRE_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND B.CHULRYEOK_CD LIKE '121%'  --ACC_CD와 CHULRYEOK_CD가 달라 ACC_CD를 사용못함(집계도 틀림)
                 GROUP BY A.ACC_CD, A.ACC_NM
             ) A, GADMIN.BSACC2 B
        WHERE A.ACC_CD = B.ACC_CD;--

--    장기 금융 상품  1210100  84,453,000
    INSERT INTO SESSION.TEMP
    SELECT  '1210100' AS ACC_CD, '  '||'장기 금융 상품' AS ACC_NM, SUM(CU_AMT) AS CU_AMT, SUM(CU_TOT) AS CU_TOT, SUM(BE_AMT) AS BE_AMT, SUM(BE_TOT) AS BE_TOT
      FROM (
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, SUM(A.DR_AMT - A.CR_AMT) AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND B.CHULRYEOK_CD LIKE '12101%'  --ACC_CD와 CHULRYEOK_CD가 달라 ACC_CD를 사용못함(집계도 틀림)
                   AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                 UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, SUM(A.DR_AMT - A.CR_AMT) AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND B.CHULRYEOK_CD LIKE '12101%'  --ACC_CD와 CHULRYEOK_CD가 달라 ACC_CD를 사용못함(집계도 틀림)
                 GROUP BY A.ACC_CD, A.ACC_NM
                UNION ALL
                --전기
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT,  SUM(A.DR_AMT - A.CR_AMT) AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND B.CHULRYEOK_CD LIKE '12101%'  --ACC_CD와 CHULRYEOK_CD가 달라 ACC_CD를 사용못함(집계도 틀림)
                   AND DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                 UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, SUM(A.DR_AMT - A.CR_AMT) AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_PRE_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND B.CHULRYEOK_CD LIKE '12101%'  --ACC_CD와 CHULRYEOK_CD가 달라 ACC_CD를 사용못함(집계도 틀림)
                 GROUP BY A.ACC_CD, A.ACC_NM
             ) A, GADMIN.BSACC2 B
        WHERE A.ACC_CD = B.ACC_CD;--


--(유 형  자 산)  1200000  5,735,164,161
    INSERT INTO SESSION.TEMP
    SELECT  '1220000' AS ACC_CD, '(무 형  자 산)' AS ACC_NM, SUM(CU_AMT) AS CU_AMT, SUM(CU_TOT) AS CU_TOT, SUM(BE_AMT) AS BE_AMT, SUM(BE_TOT) AS BE_TOT
      FROM (
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, SUM(A.DR_AMT - A.CR_AMT) AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND A.ACC_CD LIKE '122%'
                   AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                 UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, SUM(A.DR_AMT - A.CR_AMT) AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND A.ACC_CD LIKE '122%'
                 GROUP BY A.ACC_CD, A.ACC_NM
                UNION ALL
                --전기
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, SUM(A.DR_AMT - A.CR_AMT) AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND A.ACC_CD LIKE '122%'
                   AND DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                 UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, SUM(A.DR_AMT - A.CR_AMT) AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_PRE_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND A.ACC_CD LIKE '122%'
                 GROUP BY A.ACC_CD, A.ACC_NM
             ) A, GADMIN.BSACC2 B
        WHERE A.ACC_CD = B.ACC_CD;--

--   감가상각충당금(건물)  1220300
    UPDATE SESSION.TEMP
        SET CU_TOT = (SELECT SUM(CU_AMT) FROM SESSION.TEMP WHERE ACC_CD IN ('1220200','1220300') ),
             BE_TOT = (SELECT SUM(BE_AMT) FROM SESSION.TEMP WHERE ACC_CD IN ('1220200','1220300') )
      WHERE ACC_CD = '1220300';--

-- 감가상각충당금(구축)  1220500
    UPDATE SESSION.TEMP
        SET CU_TOT = (SELECT SUM(CU_AMT) FROM SESSION.TEMP WHERE ACC_CD IN ('1220400','1220500') ),
             BE_TOT = (SELECT SUM(BE_AMT) FROM SESSION.TEMP WHERE ACC_CD IN ('1220400','1220500') )
      WHERE ACC_CD = '1220500';--

-- 감가상각충당금(기공)  1220700
    UPDATE SESSION.TEMP
        SET CU_TOT = (SELECT SUM(CU_AMT) FROM SESSION.TEMP WHERE ACC_CD IN ('1220600','1220700') ),
             BE_TOT = (SELECT SUM(BE_AMT) FROM SESSION.TEMP WHERE ACC_CD IN ('1220600','1220700') )
      WHERE ACC_CD = '1220700';--

-- 감가상각충당금(비품)  1220900
    UPDATE SESSION.TEMP
        SET CU_TOT = (SELECT SUM(CU_AMT) FROM SESSION.TEMP WHERE ACC_CD IN ('1220800','1220900') ),
             BE_TOT = (SELECT SUM(BE_AMT) FROM SESSION.TEMP WHERE ACC_CD IN ('1220800','1220900') )
      WHERE ACC_CD = '1220900';--

-- 감가상각충당금(자가)  1221100
    UPDATE SESSION.TEMP
        SET CU_TOT = (SELECT SUM(CU_AMT) FROM SESSION.TEMP WHERE ACC_CD IN ('1221000','1221100') ),
             BE_TOT = (SELECT SUM(BE_AMT) FROM SESSION.TEMP WHERE ACC_CD IN ('1221000','1221100') )
      WHERE ACC_CD = '1221100';--

-- 감가상각충당금(영업)  1221300
    UPDATE SESSION.TEMP
        SET CU_TOT = (SELECT SUM(CU_AMT) FROM SESSION.TEMP WHERE ACC_CD IN ('1221200','1221300') ),
             BE_TOT = (SELECT SUM(BE_AMT) FROM SESSION.TEMP WHERE ACC_CD IN ('1221200','1221300') )
      WHERE ACC_CD = '1221300';                               --

--(무 형  자 산)  1200000  550,000,000
    INSERT INTO SESSION.TEMP
    SELECT  '1230000' AS ACC_CD, '(무 형  자 산)' AS ACC_NM, SUM(CU_AMT) AS CU_AMT, SUM(CU_TOT) AS CU_TOT, SUM(BE_AMT) AS BE_AMT, SUM(BE_TOT) AS BE_TOT
      FROM (
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, SUM(A.DR_AMT - A.CR_AMT) AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND B.CHULRYEOK_CD LIKE '123%'
                   AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                 UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, SUM(A.DR_AMT - A.CR_AMT) AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND B.CHULRYEOK_CD LIKE '123%'
                 GROUP BY A.ACC_CD, A.ACC_NM
                UNION ALL
                --전기
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, SUM(A.DR_AMT - A.CR_AMT) AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND B.CHULRYEOK_CD LIKE '123%'
                   AND DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                 UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, SUM(A.DR_AMT - A.CR_AMT) AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_PRE_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자산'
                   AND B.CHULRYEOK_CD LIKE '123%'
                 GROUP BY A.ACC_CD, A.ACC_NM
             ) A, GADMIN.BSACC2 B
        WHERE A.ACC_CD = B.ACC_CD;--


--((자 산 총 계))   8,022,813,907
    INSERT INTO SESSION.TEMP
    SELECT  '1999999' AS ACC_CD, '((자 산 총 계))' AS ACC_NM, SUM(CU_TOT) AS CU_AMT, SUM(CU_AMT) AS CU_TOT, SUM(BE_TOT) AS BE_AMT, SUM(BE_AMT) AS BE_TOT
      FROM SESSION.TEMP
     WHERE ACC_CD = '1000000';--


    INSERT INTO SESSION.TEMP
    SELECT A.ACC_CD, A.ACC_NM, SUM(CU_AMT) AS CU_AMT, SUM(CU_TOT) AS CU_TOT, SUM(BE_AMT) AS BE_AMT, SUM(BE_TOT) AS BE_TOT
      FROM (
                SELECT A.ACC_CD, A.ACC_NM, SUM(A.CR_AMT - A.DR_AMT) AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '부채'
                   AND A.ACC_CD LIKE '2%'
                   AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                  UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, SUM(A.CR_AMT - A.DR_AMT) AS AMT, 0 AS TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '부채'
                   AND A.ACC_CD LIKE '2%'
                 GROUP BY A.ACC_CD, A.ACC_NM
                UNION ALL
                --전기
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, SUM(A.CR_AMT - A.DR_AMT) AS BE_AMT, 0 AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '부채'
                   AND A.ACC_CD LIKE '2%'
                   AND DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                  UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS AMT, 0 AS TOT, SUM(A.CR_AMT - A.DR_AMT) AS BE_AMT, 0 AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_PRE_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '부채'
                   AND A.ACC_CD LIKE '2%'
                 GROUP BY A.ACC_CD, A.ACC_NM
             ) A, GADMIN.BSACC2 B
        WHERE A.ACC_CD = B.ACC_CD
     GROUP BY A.ACC_CD, A.ACC_NM, B.CHULRYEOK_CD
     ORDER BY B.CHULRYEOK_CD;--

    --유동부채
    INSERT INTO SESSION.TEMP
    SELECT '2100000' AS ACC_CD, '(유 동  부 채)' AS ACC_NM, SUM(CU_AMT) AS CU_AMT, SUM(CU_TOT) AS CU_TOT, SUM(BE_AMT) AS BE_AMT, SUM(BE_TOT) AS BE_TOT
      FROM (
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, SUM(A.CR_AMT - A.DR_AMT) AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '부채'
                   AND A.ACC_CD LIKE '21%'
                   AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                  UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS AMT, SUM(A.CR_AMT - A.DR_AMT) AS TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '부채'
                   AND A.ACC_CD LIKE '21%'
                 GROUP BY A.ACC_CD, A.ACC_NM
                UNION ALL
                --전기
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, SUM(A.CR_AMT - A.DR_AMT) AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '부채'
                   AND A.ACC_CD LIKE '21%'
                   AND DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                  UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS AMT, 0 AS TOT, 0 AS BE_AMT, SUM(A.CR_AMT - A.DR_AMT) AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_PRE_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '부채'
                   AND A.ACC_CD LIKE '21%'
                 GROUP BY A.ACC_CD, A.ACC_NM
             ) A, GADMIN.BSACC2 B
        WHERE A.ACC_CD = B.ACC_CD;--

    --  미  지  급  금
    INSERT INTO SESSION.TEMP
    SELECT '2100400' AS ACC_CD, '미  지  급  금' AS ACC_NM, SUM(CU_AMT) AS CU_AMT, SUM(CU_TOT) AS CU_TOT, SUM(BE_AMT) AS BE_AMT, SUM(BE_TOT) AS BE_TOT
      FROM (
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, SUM(A.CR_AMT - A.DR_AMT) AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '부채'
                   AND A.ACC_CD LIKE '21004%'
                   AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                  UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS AMT, SUM(A.CR_AMT - A.DR_AMT) AS TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '부채'
                   AND A.ACC_CD LIKE '21004%'
                 GROUP BY A.ACC_CD, A.ACC_NM
                UNION ALL
                --전기
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, SUM(A.CR_AMT - A.DR_AMT) AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '부채'
                   AND A.ACC_CD LIKE '21004%'
                   AND DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                  UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS AMT, 0 AS TOT, 0 AS BE_AMT, SUM(A.CR_AMT - A.DR_AMT) AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_PRE_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '부채'
                   AND A.ACC_CD LIKE '21004%'
                 GROUP BY A.ACC_CD, A.ACC_NM
             ) A, GADMIN.BSACC2 B
        WHERE A.ACC_CD = B.ACC_CD;--

    --고정부채
    INSERT INTO SESSION.TEMP
    SELECT '2200000' AS ACC_CD, '(고 정  부 채)' AS ACC_NM, SUM(CU_AMT) AS CU_AMT, SUM(CU_TOT) AS CU_TOT, SUM(BE_AMT) AS BE_AMT, SUM(BE_TOT) AS BE_TOT
      FROM (
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, SUM(A.CR_AMT - A.DR_AMT) AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '부채'
                   AND A.ACC_CD LIKE '22%'
                   AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                  UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, SUM(A.CR_AMT - A.DR_AMT) AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '부채'
                   AND A.ACC_CD LIKE '22%'
                 GROUP BY A.ACC_CD, A.ACC_NM
                UNION ALL
                --전기
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, SUM(A.CR_AMT - A.DR_AMT) AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '부채'
                   AND A.ACC_CD LIKE '22%'
                   AND DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                  UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS AMT, 0 AS TOT, 0 AS BE_AMT, SUM(A.CR_AMT - A.DR_AMT) AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_PRE_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '부채'
                   AND A.ACC_CD LIKE '22%'
                 GROUP BY A.ACC_CD, A.ACC_NM
             ) A, GADMIN.BSACC2 B
        WHERE A.ACC_CD = B.ACC_CD;--

    --(부 채  총 계)
    INSERT INTO SESSION.TEMP
    SELECT '2999900' AS ACC_CD, '(부 채  총 계)' AS ACC_NM, SUM(CU_AMT) AS CU_AMT, SUM(CU_TOT) AS CU_TOT, SUM(BE_AMT) AS BE_AMT, SUM(BE_TOT) AS BE_TOT
      FROM (
                SELECT A.ACC_CD, A.ACC_NM, SUM(A.CR_AMT - A.DR_AMT) AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '부채'
                   AND A.ACC_CD LIKE '2%'
                   AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                  UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, SUM(A.CR_AMT - A.DR_AMT) AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '부채'
                   AND A.ACC_CD LIKE '2%'
                 GROUP BY A.ACC_CD, A.ACC_NM
                UNION ALL
                --전기
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, SUM(A.CR_AMT - A.DR_AMT) AS BE_AMT, 0 AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '부채'
                   AND A.ACC_CD LIKE '2%'
                   AND DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                  UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS AMT, 0 AS TOT, SUM(A.CR_AMT - A.DR_AMT) AS BE_AMT, 0 AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_PRE_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '부채'
                   AND A.ACC_CD LIKE '2%'
                 GROUP BY A.ACC_CD, A.ACC_NM
             ) A, GADMIN.BSACC2 B
        WHERE A.ACC_CD = B.ACC_CD;       --


    INSERT INTO SESSION.TEMP
    SELECT A.ACC_CD, A.ACC_NM, SUM(CU_AMT) AS CU_AMT, SUM(CU_TOT) AS CU_TOT, SUM(BE_AMT) AS BE_AMT, SUM(BE_TOT) AS BE_TOT
      FROM (
                SELECT A.ACC_CD, A.ACC_NM, SUM(A.CR_AMT - A.DR_AMT) AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자본'
                   AND A.ACC_CD LIKE '3%'
                   AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                  UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, SUM(A.CR_AMT - A.DR_AMT) AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자본'
                   AND A.ACC_CD LIKE '3%'
                 GROUP BY A.ACC_CD, A.ACC_NM
                UNION ALL
                --전기
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, SUM(A.CR_AMT - A.DR_AMT) AS BE_AMT, 0 AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자본'
                   AND A.ACC_CD LIKE '3%'
                   AND DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                  UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, SUM(A.CR_AMT - A.DR_AMT) AS BE_AMT, 0 AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_PRE_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자본'
                   AND A.ACC_CD LIKE '3%'
                 GROUP BY A.ACC_CD, A.ACC_NM
             ) A, GADMIN.BSACC2 B
        WHERE A.ACC_CD = B.ACC_CD
       GROUP BY A.ACC_CD, A.ACC_NM, B.CHULRYEOK_CD
       ORDER BY B.CHULRYEOK_CD;--

    --(자   본   금)
    INSERT INTO SESSION.TEMP
    SELECT '3100000' AS ACC_CD, '(자   본   금)' AS ACC_NM, SUM(CU_AMT) AS CU_AMT, SUM(CU_TOT) AS CU_TOT, SUM(BE_AMT) AS BE_AMT, SUM(BE_TOT) AS BE_TOT
      FROM (
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, SUM(A.CR_AMT - A.DR_AMT) AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자본'
                   AND A.ACC_CD LIKE '31%'
                   AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                  UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS AMT, SUM(A.CR_AMT - A.DR_AMT) AS TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자본'
                   AND A.ACC_CD LIKE '31%'
                 GROUP BY A.ACC_CD, A.ACC_NM
                UNION ALL
                --전기
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, SUM(A.CR_AMT - A.DR_AMT) AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자본'
                   AND A.ACC_CD LIKE '31%'
                   AND DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                  UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS AMT, 0 AS TOT, 0 AS BE_AMT, SUM(A.CR_AMT - A.DR_AMT) AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_PRE_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자본'
                   AND A.ACC_CD LIKE '31%'
                 GROUP BY A.ACC_CD, A.ACC_NM
             ) A, GADMIN.BSACC2 B
        WHERE A.ACC_CD = B.ACC_CD;--


    --(자 본 잉여금)
    INSERT INTO SESSION.TEMP
    SELECT '3200000' AS ACC_CD, '(자 본 잉여금)' AS ACC_NM, SUM(CU_AMT) AS CU_AMT, SUM(CU_TOT) AS CU_TOT, SUM(BE_AMT) AS BE_AMT, SUM(BE_TOT) AS BE_TOT
      FROM (
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, SUM(A.CR_AMT - A.DR_AMT) AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자본'
                   AND A.ACC_CD LIKE '32%'
                   AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                  UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS AMT, SUM(A.CR_AMT - A.DR_AMT) AS TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자본'
                   AND A.ACC_CD LIKE '32%'
                 GROUP BY A.ACC_CD, A.ACC_NM
                UNION ALL
                --전기
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, SUM(A.CR_AMT - A.DR_AMT) AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자본'
                   AND A.ACC_CD LIKE '32%'
                   AND DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                  UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS AMT, 0 AS TOT, 0 AS BE_AMT, SUM(A.CR_AMT - A.DR_AMT) AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_PRE_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자본'
                   AND A.ACC_CD LIKE '32%'
                 GROUP BY A.ACC_CD, A.ACC_NM
             ) A, GADMIN.BSACC2 B
        WHERE A.ACC_CD = B.ACC_CD;--

     --(이 익 잉여금)
    INSERT INTO SESSION.TEMP
    SELECT '3300000' AS ACC_CD, '(이 익 잉여금)' AS ACC_NM, SUM(CU_AMT) AS CU_AMT, SUM(CU_TOT) AS CU_TOT, SUM(BE_AMT) AS BE_AMT, SUM(BE_TOT) AS BE_TOT
      FROM (
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, SUM(A.CR_AMT - A.DR_AMT) AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자본'
                   AND A.ACC_CD LIKE '33%'
                   AND A.ACC_CD != '3300909'
                   AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                 UNION ALL
                SELECT '3300909' AS ACC_CD, A.ACC_NM, 0 AS CU_AMT, A.CU_TOT  AS CU_TOT , 0 AS BE_AMT, 0 AS BE_TOT   --당기순이익 포함 시킴
                  FROM GADMIN.EBUS_FIN_INCOME A
                 WHERE A.ACC_CD = '7300909'
                  UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, SUM(A.CR_AMT - A.DR_AMT) AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자본'
                   AND A.ACC_CD LIKE '33%'
                   AND A.ACC_CD != '3300909'
                 GROUP BY A.ACC_CD, A.ACC_NM
                UNION ALL
                --전기
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, SUM(A.CR_AMT - A.DR_AMT) AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자본'
                   AND A.ACC_CD LIKE '33%'
                   AND A.ACC_CD != '3300909'
                   AND DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                 UNION ALL
                SELECT '3300909' AS ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0  AS CU_TOT , 0 AS BE_AMT, A.BE_TOT AS BE_TOT   --당기순이익 포함 시킴
                  FROM GADMIN.EBUS_FIN_INCOME A
                 WHERE A.ACC_CD = '7300909'
                  UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, SUM(A.CR_AMT - A.DR_AMT) AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_PRE_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자본'
                   AND A.ACC_CD LIKE '33%'
                   AND A.ACC_CD != '3300909'
                 GROUP BY A.ACC_CD, A.ACC_NM
             ) A, GADMIN.BSACC2 B
        WHERE A.ACC_CD = B.ACC_CD;--

     --  전기오류수정손익
    INSERT INTO SESSION.TEMP
    SELECT '3300200' AS ACC_CD, '전기오류수정손익' AS ACC_NM, SUM(CU_AMT)  AS CU_AMT, SUM(CU_TOT) AS CU_TOT, SUM(BE_AMT) AS BE_AMT, SUM(BE_TOT) AS BE_TOT
      FROM (
                SELECT A.ACC_CD, A.ACC_NM, SUM(A.CR_AMT - A.DR_AMT) AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자본'
                   AND A.ACC_CD LIKE '33002%'
                   AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                  UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, SUM(A.CR_AMT - A.DR_AMT) AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자본'
                   AND A.ACC_CD LIKE '33002%'
                 GROUP BY A.ACC_CD, A.ACC_NM
                UNION ALL
                --전기
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, SUM(A.CR_AMT - A.DR_AMT) AS BE_AMT, 0 AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자본'
                   AND A.ACC_CD LIKE '33002%'
                   AND DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                  UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, SUM(A.CR_AMT - A.DR_AMT) AS BE_AMT, 0 AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_PRE_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자본'
                   AND A.ACC_CD LIKE '33002%'
                 GROUP BY A.ACC_CD, A.ACC_NM
             ) A, GADMIN.BSACC2 B
        WHERE A.ACC_CD = B.ACC_CD;--

     --  당기말미처분이익잉여금
    INSERT INTO SESSION.TEMP
    SELECT '3300900' AS ACC_CD, '당기말미처분이익잉여금' AS ACC_NM, SUM(CU_AMT)  AS CU_AMT, SUM(CU_TOT) AS CU_TOT, SUM(BE_AMT) AS BE_AMT, SUM(BE_TOT) AS BE_TOT
      FROM (
                SELECT A.ACC_CD, A.ACC_NM, SUM(A.CR_AMT - A.DR_AMT) AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자본'
                   AND A.ACC_CD LIKE '33009%'
                   AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                 UNION ALL
                SELECT '3300909' AS ACC_CD, A.ACC_NM, A.CU_TOT AS CU_AMT, 0  AS CU_TOT , 0 AS BE_AMT, 0 AS BE_TOT   --당기순이익 포함 시킴
                  FROM GADMIN.EBUS_FIN_INCOME A
                 WHERE A.ACC_CD = '7300909'
                  UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, SUM(A.CR_AMT - A.DR_AMT) AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자본'
                   AND A.ACC_CD LIKE '33009%'
                 GROUP BY A.ACC_CD, A.ACC_NM
                UNION ALL
                --전기
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, SUM(A.CR_AMT - A.DR_AMT) AS BE_AMT, 0 AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자본'
                   AND A.ACC_CD LIKE '33009%'
                   AND DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                 UNION ALL
                SELECT '3300909' AS ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0  AS CU_TOT , A.BE_TOT AS BE_AMT, 0 AS BE_TOT   --당기순이익 포함 시킴
                  FROM GADMIN.EBUS_FIN_INCOME A
                 WHERE A.ACC_CD = '7300909'
                  UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, SUM(A.CR_AMT - A.DR_AMT) AS BE_AMT, 0 AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_PRE_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자본'
                   AND A.ACC_CD LIKE '33009%'
                 GROUP BY A.ACC_CD, A.ACC_NM
             ) A, GADMIN.BSACC2 B
        WHERE A.ACC_CD = B.ACC_CD;--

    INSERT INTO SESSION.TEMP
    SELECT '3999900' AS ACC_CD, '(자 본 총 계)' AS ACC_NM, SUM(CU_AMT)  AS CU_AMT, SUM(CU_TOT) AS CU_TOT, SUM(BE_AMT) AS BE_AMT, SUM(BE_TOT) AS BE_TOT
      FROM (
                SELECT A.ACC_CD, A.ACC_NM, SUM(A.CR_AMT - A.DR_AMT) AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자본'
                   AND A.ACC_CD LIKE '3%'
                   AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                 UNION ALL
                SELECT '3300909' AS ACC_CD, A.ACC_NM, A.CU_TOT AS CU_AMT, 0  AS CU_TOT , 0 AS BE_AMT, 0 AS BE_TOT   --당기순이익
                  FROM GADMIN.EBUS_FIN_INCOME A
                 WHERE A.ACC_CD = '7300909'
                  UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, SUM(A.CR_AMT - A.DR_AMT) AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자본'
                   AND A.ACC_CD LIKE '3%'
                 GROUP BY A.ACC_CD, A.ACC_NM
                UNION ALL
                --전기
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, SUM(A.CR_AMT - A.DR_AMT) AS BE_AMT, 0 AS BE_TOT
                  FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자본'
                   AND A.ACC_CD LIKE '3%'
                   AND DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                 GROUP BY A.ACC_CD, A.ACC_NM
                 UNION ALL
                SELECT '3300909' AS ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0  AS CU_TOT , A.BE_TOT AS BE_AMT, 0 AS BE_TOT   --당기순이익
                  FROM GADMIN.EBUS_FIN_INCOME A
                 WHERE A.ACC_CD = '7300909'
                  UNION ALL
                SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, SUM(A.CR_AMT - A.DR_AMT) AS BE_AMT, 0 AS BE_TOT
                  FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_PRE_FROMDATE)) A, GADMIN.BSACC2 B
                 WHERE 1 = 1
                   AND A.ACC_CD = B.ACC_CD
                   AND B.ACC_GB = '자본'
                   AND A.ACC_CD LIKE '3%'
                 GROUP BY A.ACC_CD, A.ACC_NM
             ) A, GADMIN.BSACC2 B
        WHERE A.ACC_CD = B.ACC_CD;--

    INSERT INTO SESSION.TEMP
    SELECT '3999999' AS ACC_CD, '(부채자본총계)' AS ACC_NM, SUM(CU_AMT)  AS CU_AMT, SUM(CU_TOT) AS CU_TOT, SUM(BE_AMT) AS BE_AMT, SUM(BE_TOT) AS BE_TOT
      FROM (
                SELECT ACC_CD, ACC_NM, CU_AMT, CU_TOT, BE_AMT, BE_TOT FROM SESSION.TEMP WHERE ACC_CD = '2999900' --총부채
                UNION ALL
                SELECT ACC_CD, ACC_NM, CU_AMT, CU_TOT, BE_AMT, BE_TOT FROM SESSION.TEMP WHERE ACC_CD = '3999900' --총자본
            ) ;       --
END P1;--

P2: BEGIN

    DECLARE CURSOR_TEMP CURSOR WITH RETURN FOR
    SELECT ACC_CD, ACC_NM, CU_AMT, CU_TOT, BE_AMT, BE_TOT,
            (CU_AMT + CU_TOT) - (BE_AMT + BE_TOT) AS UPDOWN_AMT,
            TRUNC( CASE BE_AMT + BE_TOT WHEN 0 THEN NULL
                                 ELSE ((CU_AMT + CU_TOT) - (BE_AMT + BE_TOT)) / (BE_AMT + BE_TOT) * 100
            END, 2) AS UPDOWN_RATE
      FROM (
                        SELECT A.*, B.CHULRYEOK_CD
                          FROM SESSION.TEMP A, GADMIN.BSACC2 B
                        WHERE 1 = 1
                          AND A.ACC_CD = B.ACC_CD
                          AND B.DAECHA_CHECK != 'N'

                     )
    WHERE NOT (CU_AMT = 0 AND CU_TOT = 0 AND BE_AMT = 0 AND BE_TOT = 0)
    ORDER BY CHULRYEOK_CD
    ;--

    OPEN CURSOR_TEMP;--
END P2;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN1101_TAB04_SELECT"
(IN IN_FROMDATE VARCHAR(10), IN IN_TODATE VARCHAR(10), IN IN_PRE_FROMDATE VARCHAR(10), IN IN_PRE_TODATE VARCHAR(10), IN IN_USER_ID VARCHAR(25))
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE   SQLSTATE          CHAR(5) DEFAULT '00000';--

    DECLARE GLOBAL TEMPORARY TABLE SESSION.TEMP
    (
        ACC_CD          VARCHAR(20)   DEFAULT '',
        ACC_NM          VARCHAR(60)   DEFAULT '',
        CU_AMT		    DECIMAL(20,5) DEFAULT 0,
        CU_TOT          DECIMAL(20,5) DEFAULT 0,
        BE_AMT          DECIMAL(20,5) DEFAULT 0,
        BE_TOT          DECIMAL(20,5) DEFAULT 0
    )  ON COMMIT PRESERVE ROWS
  WITH REPLACE
  NOT LOGGED;--

P1: BEGIN

    INSERT INTO SESSION.TEMP
            WITH WON_ACC AS (
                SELECT B.DRCR_GB, CASE B.DRCR_GB WHEN '차변'THEN A.DR_AMT - A.CR_AMT ELSE 0 END AS DR_JAN_AMT, A.DR_AMT, B.ACC_CD, B.ACC_NM,  A.CR_AMT, (CASE B.DRCR_GB WHEN '대변'THEN A.CR_AMT - A.DR_AMT ELSE 0 END) AS CR_JAN_AMT, (case when CHAGAM_GB = '차감' then -1 else 1 end) as sign, b.levelup_cd as levelup_cd
                   FROM (
                                    SELECT A.ACC_CD, MAX(A.ACC_NM) ACC_NM, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT   --일반계정 집계
                                      FROM (
                                                 SELECT ACC_CD, ACC_NM, DR_AMT, CR_AMT
                                                   FROM GADMIN.ACCOU1
                                                  WHERE DATE BETWEEN IN_FROMDATE AND IN_TODATE
                                                 UNION ALL
                                                 SELECT '1110101' AS ACC_CD, '현          금 ' AS ACC_NM, SUM(CR_AMT) AS DR_AMT, SUM(DR_AMT) AS CR_AMT   --현금계정 집계
                                                   FROM GADMIN.ACCOU1
                                                  WHERE DRCR_GB IN ('입금','출금')
                                                    AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
                                                 UNION ALL
                                                 SELECT ACC_CD, ACC_NM, DR_AMT, CR_AMT                  --전기이월 포함
                                                   FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_FROMDATE))
                                            ) A, GADMIN.BSACC2 B
                             WHERE 1 = 1
                               AND A.ACC_CD = B.ACC_CD
                            GROUP BY A.ACC_CD
                        ) A RIGHT OUTER JOIN GADMIN.BSACC2 B ON A.ACC_CD = B.ACC_CD

            ),
            WON_ACC2 AS (
                        SELECT B.DRCR_GB, CASE B.DRCR_GB WHEN '차변'THEN A.DR_AMT - A.CR_AMT ELSE 0 END AS DR_JAN_AMT, A.DR_AMT, B.ACC_CD, B.ACC_NM,  A.CR_AMT, (CASE B.DRCR_GB WHEN '대변'THEN A.CR_AMT - A.DR_AMT ELSE 0 END) AS CR_JAN_AMT, (case when CHAGAM_GB = '차감' then -1 else 1 end) as sign, b.levelup_cd as levelup_cd
                           FROM (
                                            SELECT A.ACC_CD, MAX(A.ACC_NM) AS ACC_NM, SUM(DR_AMT) AS DR_AMT, SUM(CR_AMT) AS CR_AMT   --일반계정 집계
                                              FROM (
                                                         SELECT ACC_CD, ACC_NM, DR_AMT, CR_AMT
                                                           FROM GADMIN.ACCOU1
                                                          WHERE DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                                                         UNION ALL
                                                         SELECT '1110101' AS ACC_CD, '현          금 ' AS ACC_NM, SUM(CR_AMT) AS DR_AMT, SUM(DR_AMT) AS CR_AMT   --현금계정 집계
                                                           FROM GADMIN.ACCOU1
                                                          WHERE DRCR_GB IN ('입금','출금')
                                                            AND DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
                                                         UNION ALL
                                                         SELECT ACC_CD, ACC_NM, DR_AMT, CR_AMT                  --전기이월 포함
                                                           FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_PRE_FROMDATE))
                                                    ) A, GADMIN.BSACC2 B
                                     WHERE 1 = 1
                                       AND A.ACC_CD = B.ACC_CD
                                    GROUP BY A.ACC_CD
                                ) A RIGHT OUTER JOIN GADMIN.BSACC2 B ON A.ACC_CD = B.ACC_CD

                    )
            SELECT *
              FROM (
                        SELECT A.ACC_CD, MAX(A.ACC_NM) AS ACC_NM
                               , coalesce(CASE WHEN DRIVE_WONGA = 'L' THEN coalesce(SUM(CU_AMT),0) END, 0) AS CU_AMT
                               , coalesce(CASE WHEN DRIVE_WONGA = 'R' THEN coalesce(SUM(CU_AMT),0) END, 0) AS CU_TOT
                               , coalesce(CASE WHEN DRIVE_WONGA = 'L' THEN coalesce(SUM(BE_AMT),0) END, 0) AS BE_AMT
                               , coalesce(CASE WHEN DRIVE_WONGA = 'R' THEN coalesce(SUM(BE_AMT),0) END, 0) AS BE_TOT
                          FROM (
                                SELECT ACC_CD, ACC_NM,
                                       CASE WHEN DRCR_GB IN ('차변','출금') THEN
                                             (SELECT coalesce(SUM(sign * DR_AMT),0)
                                                  FROM WON_ACC
                                                 START WITH acc_cd = main.acc_cd
                                               CONNECT BY PRIOR acc_cd = LEVELUP_CD
                                               ) -
                                            (SELECT coalesce(SUM(sign * CR_AMT),0)
                                                  FROM WON_ACC
                                                 START WITH acc_cd = main.acc_cd
                                               CONNECT BY PRIOR acc_cd = LEVELUP_CD
                                               )
                                        ELSE
                                            (SELECT coalesce(SUM(sign * CR_AMT),0)
                                                  FROM WON_ACC
                                                 START WITH acc_cd = main.acc_cd
                                               CONNECT BY PRIOR acc_cd = LEVELUP_CD
                                               ) -
                                             (SELECT coalesce(SUM(sign * DR_AMT),0)
                                                  FROM WON_ACC
                                                 START WITH acc_cd = main.acc_cd
                                               CONNECT BY PRIOR acc_cd = LEVELUP_CD
                                               )
                                        END AS CU_AMT , 0 AS BE_AMT
                                  FROM WON_ACC main
                                 START WITH coalesce(LEVELUP_CD,'')='6300000'
                                CONNECT BY PRIOR acc_cd = LEVELUP_CD
                                UNION ALL
                                SELECT ACC_CD, ACC_NM, 0 AS CU_AMT,
                                       CASE WHEN DRCR_GB IN ('차변','출금') THEN
                                             (SELECT coalesce(SUM(sign * DR_AMT),0)
                                                  FROM WON_ACC2
                                                 START WITH acc_cd = main2.acc_cd
                                               CONNECT BY PRIOR acc_cd = LEVELUP_CD
                                               ) -
                                            (SELECT coalesce(SUM(sign * CR_AMT),0)
                                                  FROM WON_ACC2
                                                 START WITH acc_cd = main2.acc_cd
                                               CONNECT BY PRIOR acc_cd = LEVELUP_CD
                                               )
                                        ELSE
                                            (SELECT coalesce(SUM(sign * CR_AMT),0)
                                                  FROM WON_ACC2
                                                 START WITH acc_cd = main2.acc_cd
                                               CONNECT BY PRIOR acc_cd = LEVELUP_CD
                                               ) -
                                             (SELECT coalesce(SUM(sign * DR_AMT),0)
                                                  FROM WON_ACC2
                                                 START WITH acc_cd = main2.acc_cd
                                               CONNECT BY PRIOR acc_cd = LEVELUP_CD
                                               )
                                        END AS BE_AMT
                                  FROM WON_ACC2 main2
                                 START WITH coalesce(LEVELUP_CD,'')='6300000'
                                CONNECT BY PRIOR acc_cd = LEVELUP_CD
                                ) A LEFT OUTER JOIN GADMIN.BSACC2 B ON (A.ACC_CD = B.ACC_CD)
                 WHERE 1 = 1
                   AND B.ACC_GB = '원가'
                GROUP BY A.ACC_CD, B.DRIVE_WONGA )
        WHERE 1 = 1
          AND CU_AMT + CU_TOT + BE_AMT + BE_TOT != 0
    ;--

END P1;--

P2: BEGIN

    DECLARE CURSOR_TEMP CURSOR WITH RETURN FOR
    SELECT ACC_CD, CHULRYEOK_GWAMOK AS ACC_NM, CU_AMT, CU_TOT, BE_AMT, BE_TOT,
            (CU_AMT + CU_TOT) - (BE_AMT + BE_TOT) AS UPDOWN_AMT,
            TRUNC( CASE BE_AMT + BE_TOT WHEN 0 THEN NULL
                                 ELSE ((CU_AMT + CU_TOT) - (BE_AMT + BE_TOT)) / (BE_AMT + BE_TOT) * 100
            END, 2) AS UPDOWN_RATE
      FROM (
                        SELECT A.*, B.CHULRYEOK_CD, CHULRYEOK_GWAMOK
                          FROM SESSION.TEMP A, GADMIN.BSACC2 B
                        WHERE 1 = 1
                          AND A.ACC_CD = B.ACC_CD
                          AND B.DRIVE_WONGA != 'N'
                     )
     WHERE 1 = 1
       AND NOT(CU_AMT = 0 AND CU_TOT = 0 AND BE_AMT = 0 AND BE_TOT = 0)  -- 결과가 다 "0"인것 제외 시킴
    ORDER BY CHULRYEOK_CD
    ;    --
    OPEN CURSOR_TEMP;--
END P2;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN1101_TAB04_SELECT_OLD"
(IN IN_FROMDATE VARCHAR(10), IN IN_TODATE VARCHAR(10), IN IN_PRE_FROMDATE VARCHAR(10), IN IN_PRE_TODATE VARCHAR(10), IN IN_USER_ID VARCHAR(25))
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE   SQLSTATE          CHAR(5) DEFAULT '00000';--

    DECLARE GLOBAL TEMPORARY TABLE SESSION.TEMP
    (
        ACC_CD          VARCHAR(20)   DEFAULT '',
        ACC_NM          VARCHAR(60)   DEFAULT '',
        CU_AMT		    DECIMAL(20,5) DEFAULT 0,
        CU_TOT          DECIMAL(20,5) DEFAULT 0,
        BE_AMT          DECIMAL(20,5) DEFAULT 0,
        BE_TOT          DECIMAL(20,5) DEFAULT 0
    )  ON COMMIT PRESERVE ROWS
  WITH REPLACE
  NOT LOGGED;--

P1: BEGIN

    INSERT INTO SESSION.TEMP
    SELECT A.ACC_CD, '      '||A.ACC_NM AS ACC_NM, COALESCE(SUM(CU_AMT),0) AS CU_AMT, COALESCE(SUM(CU_TOT),0) AS CU_TOT, COALESCE(SUM(BE_AMT),0) AS BE_AMT, COALESCE(SUM(BE_TOT),0) AS BE_TOT
      FROM (
            --당기
            SELECT A.ACC_CD, A.ACC_NM, COALESCE(SUM(A.DR_AMT - A.CR_AMT),0) AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
              FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
             WHERE 1 = 1
               AND A.ACC_CD = B.ACC_CD
               AND B.ACC_GB = '원가'
               AND A.ACC_CD LIKE '6%'
               AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
             GROUP BY A.ACC_CD, A.ACC_NM
              UNION ALL
            SELECT A.ACC_CD, A.ACC_NM, COALESCE(SUM(A.DR_AMT - A.CR_AMT),0) AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT
              FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_FROMDATE)) A, GADMIN.BSACC2 B
             WHERE 1 = 1
               AND A.ACC_CD = B.ACC_CD
               AND B.ACC_GB = '원가'
               AND A.ACC_CD LIKE '6%'
             GROUP BY A.ACC_CD, A.ACC_NM
             UNION ALL
             --전기
            SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, COALESCE(SUM(A.DR_AMT - A.CR_AMT),0) AS BE_AMT, 0 AS BE_TOT
              FROM GADMIN.ACCOU1 A, GADMIN.BSACC2 B
             WHERE 1 = 1
               AND A.ACC_CD = B.ACC_CD
               AND B.ACC_GB = '원가'
               AND A.ACC_CD LIKE '6%'
               AND DATE BETWEEN IN_PRE_FROMDATE AND IN_PRE_TODATE
             GROUP BY A.ACC_CD, A.ACC_NM
              UNION ALL
            SELECT A.ACC_CD, A.ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, COALESCE(SUM(A.DR_AMT - A.CR_AMT),0) AS BE_AMT, 0 AS BE_TOT
              FROM TABLE(GADMIN.SF_FIN_PRE_CARR_SELECT(IN_PRE_FROMDATE)) A, GADMIN.BSACC2 B
             WHERE 1 = 1
               AND A.ACC_CD = B.ACC_CD
               AND B.ACC_GB = '원가'
               AND A.ACC_CD LIKE '6%'
             GROUP BY A.ACC_CD, A.ACC_NM
             ) A, GADMIN.BSACC2 B
        WHERE A.ACC_CD = B.ACC_CD
          AND NOT (CU_AMT = 0 AND CU_TOT = 0 AND BE_AMT = 0 AND BE_TOT = 0)
    GROUP BY A.ACC_CD, A.ACC_NM;         --

    --  (운송원가및주택분양원가)
    INSERT INTO SESSION.TEMP
    SELECT '6200000' AS ACC_CD, '(운송원가및주택분양원가)' AS ACC_NM, 0 AS CU_AMT, COALESCE(SUM(CU_AMT),0) AS CU_TOT, 0 AS BE_AMT, COALESCE(SUM(BE_AMT),0) AS BE_TOT
      FROM SESSION.TEMP;--

    --    (운   송   비)
    INSERT INTO SESSION.TEMP
    SELECT '6220000' AS ACC_CD, '  (운   송   비)' AS ACC_NM, 0 AS CU_AMT, COALESCE(SUM(CU_AMT),0) AS CU_TOT, 0 AS BE_AMT, COALESCE(SUM(BE_AMT),0) AS BE_TOT
      FROM SESSION.TEMP
     WHERE 1 = 1
       AND ACC_CD LIKE '622%';--

    --        급    여(운전)
    INSERT INTO SESSION.TEMP
    SELECT '6220100' AS ACC_CD, '    급    여(운전)' AS ACC_NM, 0 AS CU_AMT, COALESCE(SUM(CU_AMT),0) AS CU_TOT, 0 AS BE_AMT, COALESCE(SUM(BE_AMT),0) AS BE_TOT
      FROM SESSION.TEMP
     WHERE 1 = 1
       AND ACC_CD LIKE '62201%';       --

    --    복리후생비(원)
    INSERT INTO SESSION.TEMP
    SELECT '6220600' AS ACC_CD, '    복리후생비(원)' AS ACC_NM, 0 AS CU_AMT, COALESCE(SUM(CU_AMT),0) AS CU_TOT, 0 AS BE_AMT, COALESCE(SUM(BE_AMT),0) AS BE_TOT
      FROM SESSION.TEMP
     WHERE 1 = 1
       AND ACC_CD LIKE '62206%';       --

    --  (유   지   비)
    INSERT INTO SESSION.TEMP
    SELECT '6230000' AS ACC_CD, '  (유   지   비)' AS ACC_NM, 0 AS CU_AMT, COALESCE(SUM(CU_AMT),0) AS CU_TOT, 0 AS BE_AMT, COALESCE(SUM(BE_AMT),0) AS BE_TOT
      FROM SESSION.TEMP
     WHERE 1 = 1
       AND ACC_CD LIKE '623%';   --

    --    급    여(유지)
    INSERT INTO SESSION.TEMP
    SELECT '6230100' AS ACC_CD, '    급    여(유지)' AS ACC_NM, 0 AS CU_AMT, COALESCE(SUM(CU_AMT),0) AS CU_TOT, 0 AS BE_AMT, COALESCE(SUM(BE_AMT),0) AS BE_TOT
      FROM SESSION.TEMP
     WHERE 1 = 1
       AND ACC_CD LIKE '62301%';         --

    --    복리후생비(유)
    INSERT INTO SESSION.TEMP
    SELECT '6230400' AS ACC_CD, '    복리후생비(유)' AS ACC_NM, 0 AS CU_AMT, COALESCE(SUM(CU_AMT),0) AS CU_TOT, 0 AS BE_AMT, COALESCE(SUM(BE_AMT),0) AS BE_TOT
      FROM SESSION.TEMP
     WHERE 1 = 1
       AND ACC_CD LIKE '62304%';        --

    --(매출  총이익)
    INSERT INTO SESSION.TEMP
    SELECT ACC_CD, ACC_NM, CU_AMT, CU_TOT, BE_AMT, BE_TOT
      FROM GADMIN.EBUS_FIN_INCOME
     WHERE 1 = 1
       AND ACC_CD = '6300000';             --

END P1;--

P2: BEGIN

    DECLARE CURSOR_TEMP CURSOR WITH RETURN FOR
    SELECT ACC_CD, CHULRYEOK_GWAMOK AS ACC_NM, CU_AMT, CU_TOT, BE_AMT, BE_TOT,
            (CU_AMT + CU_TOT) - (BE_AMT + BE_TOT) AS UPDOWN_AMT,
            TRUNC( CASE BE_AMT + BE_TOT WHEN 0 THEN NULL
                                 ELSE ((CU_AMT + CU_TOT) - (BE_AMT + BE_TOT)) / (BE_AMT + BE_TOT) * 100
            END, 2) AS UPDOWN_RATE
      FROM (
                        SELECT A.*, B.CHULRYEOK_CD, CHULRYEOK_GWAMOK
                          FROM SESSION.TEMP A, GADMIN.BSACC2 B
                        WHERE 1 = 1
                          AND A.ACC_CD = B.ACC_CD
                          AND B.DRIVE_WONGA != 'N'
                     )
     WHERE 1 = 1
       AND NOT(CU_AMT = 0 AND CU_TOT = 0 AND BE_AMT = 0 AND BE_TOT = 0)  -- 결과가 다 "0"인것 제외 시킴
    ORDER BY CHULRYEOK_CD
    ;    --
    OPEN CURSOR_TEMP;--
END P2;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN1301_TAB01_SELECT_OLD"
(IN IN_FROMMONTH VARCHAR(10),IN
IN_TOMONTH VARCHAR(10), IN IN_USER_ID VARCHAR(25))
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE   SQLSTATE          CHAR(5) DEFAULT '00000';--
    DECLARE   V_01_FROMMONTH      VARCHAR(7) DEFAULT '';--
    DECLARE   V_02_FROMMONTH      VARCHAR(7) DEFAULT '';--
    DECLARE   V_03_FROMMONTH      VARCHAR(7) DEFAULT '';--
    DECLARE   V_04_FROMMONTH      VARCHAR(7) DEFAULT '';--
    DECLARE   V_05_FROMMONTH      VARCHAR(7) DEFAULT '';--
    DECLARE   V_06_FROMMONTH      VARCHAR(7) DEFAULT '';--
    DECLARE   V_07_FROMMONTH      VARCHAR(7) DEFAULT '';--
    DECLARE   V_08_FROMMONTH      VARCHAR(7) DEFAULT '';--
    DECLARE   V_09_FROMMONTH      VARCHAR(7) DEFAULT '';--
    DECLARE   V_10_FROMMONTH      VARCHAR(7) DEFAULT '';--
    DECLARE   V_11_FROMMONTH      VARCHAR(7) DEFAULT '';--
    DECLARE   V_12_FROMMONTH      VARCHAR(7) DEFAULT '';--
    DECLARE   V_01_TOMONTH        VARCHAR(7) DEFAULT '';--
    DECLARE   V_02_TOMONTH        VARCHAR(7) DEFAULT '';--
    DECLARE   V_03_TOMONTH        VARCHAR(7) DEFAULT '';--
    DECLARE   V_04_TOMONTH        VARCHAR(7) DEFAULT '';--
    DECLARE   V_05_TOMONTH        VARCHAR(7) DEFAULT '';--
    DECLARE   V_06_TOMONTH        VARCHAR(7) DEFAULT '';--
    DECLARE   V_07_TOMONTH        VARCHAR(7) DEFAULT '';--
    DECLARE   V_08_TOMONTH        VARCHAR(7) DEFAULT '';--
    DECLARE   V_09_TOMONTH        VARCHAR(7) DEFAULT '';--
    DECLARE   V_10_TOMONTH        VARCHAR(7) DEFAULT '';--
    DECLARE   V_11_TOMONTH        VARCHAR(7) DEFAULT '';--
    DECLARE   V_12_TOMONTH        VARCHAR(7) DEFAULT '';--

    DECLARE GLOBAL TEMPORARY TABLE SESSION.TEMP
    (
        ACC_NM          VARCHAR(60)   DEFAULT '',
        TOTAL		    DECIMAL(20,5) DEFAULT 0,
        MONTH_01        DECIMAL(20,5) DEFAULT 0,
        MONTH_02        DECIMAL(20,5) DEFAULT 0,
        MONTH_03        DECIMAL(20,5) DEFAULT 0,
        Q1_TOT          DECIMAL(20,5) DEFAULT 0,
        MONTH_04        DECIMAL(20,5) DEFAULT 0,
        MONTH_05        DECIMAL(20,5) DEFAULT 0,
        MONTH_06        DECIMAL(20,5) DEFAULT 0,
        Q2_TOT          DECIMAL(20,5) DEFAULT 0,
        MONTH_07        DECIMAL(20,5) DEFAULT 0,
        MONTH_08        DECIMAL(20,5) DEFAULT 0,
        MONTH_09        DECIMAL(20,5) DEFAULT 0,
        Q3_TOT          DECIMAL(20,5) DEFAULT 0,
        MONTH_10        DECIMAL(20,5) DEFAULT 0,
        MONTH_11        DECIMAL(20,5) DEFAULT 0,
        MONTH_12        DECIMAL(20,5) DEFAULT 0,
        Q4_TOT          DECIMAL(20,5) DEFAULT 0,
        ACC_CD          VARCHAR(10)   DEFAULT ''
    )  ON COMMIT PRESERVE ROWS
  WITH REPLACE
  NOT LOGGED;--


P1: BEGIN

    SET IN_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,7);--
    SET IN_TOMONTH = SUBSTRING(IN_TOMONTH,1,7);--

    --월뼐 파라몌트 썰정
    IF SUBSTRING(IN_FROMMONTH,6,2) = '01' THEN
        SET V_01_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'01';--
    ELSE
        SET V_01_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'00';    --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '02' AND SUBSTRING(IN_TOMONTH,6,2) >= '02' THEN
        SET V_02_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'02';--
    ELSE
        SET V_02_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'00';    --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '03' AND SUBSTRING(IN_TOMONTH,6,2) >= '03' THEN
        SET V_03_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'03';--
    ELSE
        SET V_03_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'00';            --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '04' AND SUBSTRING(IN_TOMONTH,6,2) >= '04' THEN
        SET V_04_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'04';--
    ELSE
        SET V_04_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'00';            --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '05' AND SUBSTRING(IN_TOMONTH,6,2) >= '05' THEN
        SET V_05_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'05';--
    ELSE
        SET V_05_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'00';            --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '06' AND SUBSTRING(IN_TOMONTH,6,2) >= '06' THEN
        SET V_06_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'06';--
    ELSE
        SET V_06_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'00';            --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '07' AND SUBSTRING(IN_TOMONTH,6,2) >= '07' THEN
        SET V_07_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'07';--
    ELSE
        SET V_07_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'00';            --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '08'  AND SUBSTRING(IN_TOMONTH,6,2) >= '08' THEN
        SET V_08_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'08';--
    ELSE
        SET V_08_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'00';            --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '09'  AND SUBSTRING(IN_TOMONTH,6,2) >= '09' THEN
        SET V_09_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'09';--
    ELSE
        SET V_09_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'00';            --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '10'  AND SUBSTRING(IN_TOMONTH,6,2) >= '10' THEN
        SET V_10_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'10';--
    ELSE
        SET V_10_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'00';            --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '11'  AND SUBSTRING(IN_TOMONTH,6,2) >= '11' THEN
        SET V_11_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'11';--
    ELSE
        SET V_11_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'00';            --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '12'  AND SUBSTRING(IN_TOMONTH,6,2) <= '12' THEN
        SET V_12_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'12';--
    ELSE
        SET V_12_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'00';            --
    END IF;--

    IF SUBSTRING(IN_FROMMONTH,6,2) = '01' AND SUBSTRING(IN_TOMONTH,6,2) >= '01' THEN
        SET V_01_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'01';--
    ELSE
        SET V_01_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'00';    --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '02' AND SUBSTRING(IN_TOMONTH,6,2) >= '02' THEN
        SET V_02_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'02';--
    ELSE
        SET V_02_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'00';    --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '03' AND SUBSTRING(IN_TOMONTH,6,2) >= '03' THEN
        SET V_03_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'03';--
    ELSE
        SET V_03_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'00';    --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '04' AND SUBSTRING(IN_TOMONTH,6,2) >= '04' THEN
        SET V_04_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'04';--
    ELSE
        SET V_04_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'00';    --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '05' AND SUBSTRING(IN_TOMONTH,6,2) >= '05' THEN
        SET V_05_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'05';--
    ELSE
        SET V_05_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'00';    --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '06' AND SUBSTRING(IN_TOMONTH,6,2) >= '06' THEN
        SET V_06_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'06';--
    ELSE
        SET V_06_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'00';    --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '07' AND SUBSTRING(IN_TOMONTH,6,2) >= '07' THEN
        SET V_07_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'07';--
    ELSE
        SET V_07_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'00';    --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '08' AND SUBSTRING(IN_TOMONTH,6,2) >= '08' THEN
        SET V_08_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'08';--
    ELSE
        SET V_08_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'00';    --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '09' AND SUBSTRING(IN_TOMONTH,6,2) >= '09' THEN
        SET V_09_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'09';--
    ELSE
        SET V_09_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'00';    --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '10' AND SUBSTRING(IN_TOMONTH,6,2) >= '10' THEN
        SET V_10_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'10';--
    ELSE
        SET V_10_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'00';    --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '11' AND SUBSTRING(IN_TOMONTH,6,2) >= '11' THEN
        SET V_11_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'11';--
    ELSE
        SET V_11_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'00';    --
    END IF;--
    IF SUBSTRING(IN_TOMONTH,6,2) >= '12' THEN
        SET V_12_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'12';--
    ELSE
        SET V_12_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'00';    --
    END IF;--

    INSERT INTO SESSION.TEMP
    SELECT TOT.ACC_NM, TOT.AMT
            , COALESCE(MON01.AMT,0) AS MON01
            , COALESCE(MON02.AMT,0) AS MON02
            , COALESCE(MON03.AMT,0) AS MON03
            , (COALESCE(MON01.AMT,0) + COALESCE(MON02.AMT,0) + COALESCE(MON03.AMT,0)) AS Q1_TOT
            , COALESCE(MON04.AMT,0) AS MON04
            , COALESCE(MON05.AMT,0) AS MON05
            , COALESCE(MON06.AMT,0) AS MON06
            , (COALESCE(MON04.AMT,0) + COALESCE(MON05.AMT,0) + COALESCE(MON06.AMT,0)) AS Q2_TOT
            , COALESCE(MON07.AMT,0) AS MON07
            , COALESCE(MON08.AMT,0) AS MON08
            , COALESCE(MON09.AMT,0) AS MON09
            , (COALESCE(MON07.AMT,0) + COALESCE(MON08.AMT,0) + COALESCE(MON09.AMT,0)) AS Q3_TOT
            , COALESCE(MON10.AMT,0) AS MON10
            , COALESCE(MON11.AMT,0) AS MON11
            , COALESCE(MON12.AMT,0) AS MON12
            , (COALESCE(MON10.AMT,0) + COALESCE(MON11.AMT,0) + COALESCE(MON12.AMT,0)) AS Q4_TOT
            ,TOT.ACC_CD
      FROM (
                (SELECT ACC_CD, ACC_NM, COALESCE(AMT,0) AS AMT FROM TABLE(GADMIN.SF_FIN1301_TAB01_SELECT(IN_FROMMONTH,IN_TOMONTH))) TOT

                LEFT OUTER JOIN ( SELECT * FROM TABLE(GADMIN.SF_FIN1301_TAB01_SELECT(V_01_FROMMONTH,V_01_TOMONTH)) ) MON01 ON (TOT.ACC_CD = MON01.ACC_CD)
                LEFT OUTER JOIN ( SELECT * FROM TABLE(GADMIN.SF_FIN1301_TAB01_SELECT(V_02_FROMMONTH,V_02_TOMONTH)) ) MON02 ON (TOT.ACC_CD = MON02.ACC_CD)
                LEFT OUTER JOIN ( SELECT * FROM TABLE(GADMIN.SF_FIN1301_TAB01_SELECT(V_03_FROMMONTH,V_03_TOMONTH)) ) MON03 ON (TOT.ACC_CD = MON03.ACC_CD)

                LEFT OUTER JOIN ( SELECT * FROM TABLE(GADMIN.SF_FIN1301_TAB01_SELECT(V_04_FROMMONTH,V_04_TOMONTH)) ) MON04 ON (TOT.ACC_CD = MON04.ACC_CD)
                LEFT OUTER JOIN ( SELECT * FROM TABLE(GADMIN.SF_FIN1301_TAB01_SELECT(V_05_FROMMONTH,V_05_TOMONTH)) ) MON05 ON (TOT.ACC_CD = MON05.ACC_CD)
                LEFT OUTER JOIN ( SELECT * FROM TABLE(GADMIN.SF_FIN1301_TAB01_SELECT(V_06_FROMMONTH,V_06_TOMONTH)) ) MON06 ON (TOT.ACC_CD = MON06.ACC_CD)

                LEFT OUTER JOIN ( SELECT * FROM TABLE(GADMIN.SF_FIN1301_TAB01_SELECT(V_07_FROMMONTH,V_07_TOMONTH)) ) MON07 ON (TOT.ACC_CD = MON07.ACC_CD)
                LEFT OUTER JOIN ( SELECT * FROM TABLE(GADMIN.SF_FIN1301_TAB01_SELECT(V_08_FROMMONTH,V_08_TOMONTH)) ) MON08 ON (TOT.ACC_CD = MON08.ACC_CD)
                LEFT OUTER JOIN ( SELECT * FROM TABLE(GADMIN.SF_FIN1301_TAB01_SELECT(V_09_FROMMONTH,V_09_TOMONTH)) ) MON09 ON (TOT.ACC_CD = MON09.ACC_CD)

                LEFT OUTER JOIN ( SELECT * FROM TABLE(GADMIN.SF_FIN1301_TAB01_SELECT(V_10_FROMMONTH,V_10_TOMONTH)) ) MON10 ON (TOT.ACC_CD = MON10.ACC_CD)
                LEFT OUTER JOIN ( SELECT * FROM TABLE(GADMIN.SF_FIN1301_TAB01_SELECT(V_11_FROMMONTH,V_11_TOMONTH)) ) MON11 ON (TOT.ACC_CD = MON11.ACC_CD)
                LEFT OUTER JOIN ( SELECT * FROM TABLE(GADMIN.SF_FIN1301_TAB01_SELECT(V_12_FROMMONTH,V_12_TOMONTH)) ) MON12 ON (TOT.ACC_CD = MON12.ACC_CD)
      );--

    -- 추가부분 4/27
     --운송원가
    UPDATE SESSION.TEMP
       SET TOTAL = (SELECT SUM(TOTAL) FROM SESSION.TEMP WHERE ACC_CD LIKE '62%' )
          , MONTH_01 = (SELECT SUM(MONTH_01) FROM SESSION.TEMP WHERE ACC_CD LIKE '62%' )
          , MONTH_02 = (SELECT SUM(MONTH_02) FROM SESSION.TEMP WHERE ACC_CD LIKE '62%' )
          , MONTH_03 = (SELECT SUM(MONTH_03) FROM SESSION.TEMP WHERE ACC_CD LIKE '62%' )
          , MONTH_04 = (SELECT SUM(MONTH_04) FROM SESSION.TEMP WHERE ACC_CD LIKE '62%' )
          , MONTH_05 = (SELECT SUM(MONTH_05) FROM SESSION.TEMP WHERE ACC_CD LIKE '62%' )
          , MONTH_06 = (SELECT SUM(MONTH_06) FROM SESSION.TEMP WHERE ACC_CD LIKE '62%' )
          , MONTH_07 = (SELECT SUM(MONTH_07) FROM SESSION.TEMP WHERE ACC_CD LIKE '62%')
          , MONTH_08 = (SELECT SUM(MONTH_08) FROM SESSION.TEMP WHERE ACC_CD LIKE '62%')
          , MONTH_09 = (SELECT SUM(MONTH_09) FROM SESSION.TEMP WHERE ACC_CD LIKE '62%')
          , MONTH_10 = (SELECT SUM(MONTH_10) FROM SESSION.TEMP WHERE ACC_CD LIKE '62%')
          , MONTH_11 = (SELECT SUM(MONTH_11) FROM SESSION.TEMP WHERE ACC_CD LIKE '62%')
          , MONTH_12 = (SELECT SUM(MONTH_12) FROM SESSION.TEMP WHERE ACC_CD LIKE '62%')
          , Q1_TOT = (SELECT SUM(Q1_TOT) FROM SESSION.TEMP WHERE ACC_CD LIKE '62%' )
          , Q2_TOT = (SELECT SUM(Q2_TOT) FROM SESSION.TEMP WHERE ACC_CD LIKE '62%' )
          , Q3_TOT = (SELECT SUM(Q3_TOT) FROM SESSION.TEMP WHERE ACC_CD LIKE '62%' )
          , Q4_TOT = (SELECT SUM(Q4_TOT) FROM SESSION.TEMP WHERE ACC_CD LIKE '62%' )
     WHERE ACC_CD = '6200000';--

     --매출액 합계
    UPDATE SESSION.TEMP
       SET TOTAL = (SELECT SUM(TOTAL) FROM SESSION.TEMP WHERE ACC_CD LIKE '61%' )
          , MONTH_01 = (SELECT SUM(MONTH_01) FROM SESSION.TEMP WHERE ACC_CD LIKE '61%' )
          , MONTH_02 = (SELECT SUM(MONTH_02) FROM SESSION.TEMP WHERE ACC_CD LIKE '61%' )
          , MONTH_03 = (SELECT SUM(MONTH_03) FROM SESSION.TEMP WHERE ACC_CD LIKE '61%' )
          , MONTH_04 = (SELECT SUM(MONTH_04) FROM SESSION.TEMP WHERE ACC_CD LIKE '61%' )
          , MONTH_05 = (SELECT SUM(MONTH_05) FROM SESSION.TEMP WHERE ACC_CD LIKE '61%' )
          , MONTH_06 = (SELECT SUM(MONTH_06) FROM SESSION.TEMP WHERE ACC_CD LIKE '61%' )
          , MONTH_07 = (SELECT SUM(MONTH_07) FROM SESSION.TEMP WHERE ACC_CD LIKE '61%')
          , MONTH_08 = (SELECT SUM(MONTH_08) FROM SESSION.TEMP WHERE ACC_CD LIKE '61%')
          , MONTH_09 = (SELECT SUM(MONTH_09) FROM SESSION.TEMP WHERE ACC_CD LIKE '61%')
          , MONTH_10 = (SELECT SUM(MONTH_10) FROM SESSION.TEMP WHERE ACC_CD LIKE '61%')
          , MONTH_11 = (SELECT SUM(MONTH_11) FROM SESSION.TEMP WHERE ACC_CD LIKE '61%')
          , MONTH_12 = (SELECT SUM(MONTH_12) FROM SESSION.TEMP WHERE ACC_CD LIKE '61%')
          , Q1_TOT = (SELECT SUM(Q1_TOT) FROM SESSION.TEMP WHERE ACC_CD LIKE '61%' )
          , Q2_TOT = (SELECT SUM(Q2_TOT) FROM SESSION.TEMP WHERE ACC_CD LIKE '61%' )
          , Q3_TOT = (SELECT SUM(Q3_TOT) FROM SESSION.TEMP WHERE ACC_CD LIKE '61%' )
          , Q4_TOT = (SELECT SUM(Q4_TOT) FROM SESSION.TEMP WHERE ACC_CD LIKE '61%' )
     WHERE ACC_CD = '6100000';--

    -- 추가부분 끝 4/27

    --매출 총이익 = 매출액 - 운송원가및주택분양원가
    UPDATE SESSION.TEMP
       SET TOTAL = (SELECT TOTAL FROM SESSION.TEMP WHERE ACC_CD = '6100000') - (SELECT TOTAL FROM SESSION.TEMP WHERE ACC_CD = '6200000')
          , MONTH_01 = (SELECT MONTH_01 FROM SESSION.TEMP WHERE ACC_CD = '6100000') - (SELECT MONTH_01 FROM SESSION.TEMP WHERE ACC_CD = '6200000')
          , MONTH_02 = (SELECT MONTH_02 FROM SESSION.TEMP WHERE ACC_CD = '6100000') - (SELECT MONTH_02 FROM SESSION.TEMP WHERE ACC_CD = '6200000')
          , MONTH_03 = (SELECT MONTH_03 FROM SESSION.TEMP WHERE ACC_CD = '6100000') - (SELECT MONTH_03 FROM SESSION.TEMP WHERE ACC_CD = '6200000')
          , MONTH_04 = (SELECT MONTH_04 FROM SESSION.TEMP WHERE ACC_CD = '6100000') - (SELECT MONTH_04 FROM SESSION.TEMP WHERE ACC_CD = '6200000')
          , MONTH_05 = (SELECT MONTH_05 FROM SESSION.TEMP WHERE ACC_CD = '6100000') - (SELECT MONTH_05 FROM SESSION.TEMP WHERE ACC_CD = '6200000')
          , MONTH_06 = (SELECT MONTH_06 FROM SESSION.TEMP WHERE ACC_CD = '6100000') - (SELECT MONTH_06 FROM SESSION.TEMP WHERE ACC_CD = '6200000')
          , MONTH_07 = (SELECT MONTH_07 FROM SESSION.TEMP WHERE ACC_CD = '6100000') - (SELECT MONTH_07 FROM SESSION.TEMP WHERE ACC_CD = '6200000')
          , MONTH_08 = (SELECT MONTH_08 FROM SESSION.TEMP WHERE ACC_CD = '6100000') - (SELECT MONTH_08 FROM SESSION.TEMP WHERE ACC_CD = '6200000')
          , MONTH_09 = (SELECT MONTH_09 FROM SESSION.TEMP WHERE ACC_CD = '6100000') - (SELECT MONTH_09 FROM SESSION.TEMP WHERE ACC_CD = '6200000')
          , MONTH_10 = (SELECT MONTH_10 FROM SESSION.TEMP WHERE ACC_CD = '6100000') - (SELECT MONTH_10 FROM SESSION.TEMP WHERE ACC_CD = '6200000')
          , MONTH_11 = (SELECT MONTH_11 FROM SESSION.TEMP WHERE ACC_CD = '6100000') - (SELECT MONTH_11 FROM SESSION.TEMP WHERE ACC_CD = '6200000')
          , MONTH_12 = (SELECT MONTH_12 FROM SESSION.TEMP WHERE ACC_CD = '6100000') - (SELECT MONTH_12 FROM SESSION.TEMP WHERE ACC_CD = '6200000')
          , Q1_TOT = (SELECT Q1_TOT FROM SESSION.TEMP WHERE ACC_CD = '6100000') - (SELECT Q1_TOT FROM SESSION.TEMP WHERE ACC_CD = '6200000')
          , Q2_TOT = (SELECT Q2_TOT FROM SESSION.TEMP WHERE ACC_CD = '6100000') - (SELECT Q2_TOT FROM SESSION.TEMP WHERE ACC_CD = '6200000')
          , Q3_TOT = (SELECT Q3_TOT FROM SESSION.TEMP WHERE ACC_CD = '6100000') - (SELECT Q3_TOT FROM SESSION.TEMP WHERE ACC_CD = '6200000')
          , Q4_TOT = (SELECT Q4_TOT FROM SESSION.TEMP WHERE ACC_CD = '6100000') - (SELECT Q4_TOT FROM SESSION.TEMP WHERE ACC_CD = '6200000')
     WHERE ACC_CD = '6300000';--

    --Ⅳ.판매비와관리비
    UPDATE SESSION.TEMP
       SET TOTAL = (SELECT SUM(TOTAL) FROM SESSION.TEMP WHERE ACC_CD LIKE '64%' )
          , MONTH_01 = (SELECT SUM(MONTH_01) FROM SESSION.TEMP WHERE ACC_CD LIKE '64%' )
          , MONTH_02 = (SELECT SUM(MONTH_02) FROM SESSION.TEMP WHERE ACC_CD LIKE '64%' )
          , MONTH_03 = (SELECT SUM(MONTH_03) FROM SESSION.TEMP WHERE ACC_CD LIKE '64%' )
          , MONTH_04 = (SELECT SUM(MONTH_04) FROM SESSION.TEMP WHERE ACC_CD LIKE '64%' )
          , MONTH_05 = (SELECT SUM(MONTH_05) FROM SESSION.TEMP WHERE ACC_CD LIKE '64%' )
          , MONTH_06 = (SELECT SUM(MONTH_06) FROM SESSION.TEMP WHERE ACC_CD LIKE '64%' )
          , MONTH_07 = (SELECT SUM(MONTH_07) FROM SESSION.TEMP WHERE ACC_CD LIKE '64%')
          , MONTH_08 = (SELECT SUM(MONTH_08) FROM SESSION.TEMP WHERE ACC_CD LIKE '64%')
          , MONTH_09 = (SELECT SUM(MONTH_09) FROM SESSION.TEMP WHERE ACC_CD LIKE '64%')
          , MONTH_10 = (SELECT SUM(MONTH_10) FROM SESSION.TEMP WHERE ACC_CD LIKE '64%')
          , MONTH_11 = (SELECT SUM(MONTH_11) FROM SESSION.TEMP WHERE ACC_CD LIKE '64%')
          , MONTH_12 = (SELECT SUM(MONTH_12) FROM SESSION.TEMP WHERE ACC_CD LIKE '64%')
          , Q1_TOT = (SELECT SUM(Q1_TOT) FROM SESSION.TEMP WHERE ACC_CD LIKE '64%' )
          , Q2_TOT = (SELECT SUM(Q2_TOT) FROM SESSION.TEMP WHERE ACC_CD LIKE '64%' )
          , Q3_TOT = (SELECT SUM(Q3_TOT) FROM SESSION.TEMP WHERE ACC_CD LIKE '64%' )
          , Q4_TOT = (SELECT SUM(Q4_TOT) FROM SESSION.TEMP WHERE ACC_CD LIKE '64%' )
     WHERE ACC_CD = '6400000';--

    --영업이익 = 매출액 - 운송원가및주택분양원가
    UPDATE SESSION.TEMP
       SET TOTAL = (SELECT TOTAL FROM SESSION.TEMP WHERE ACC_CD = '6300000') - (SELECT TOTAL FROM SESSION.TEMP WHERE ACC_CD = '6400000')
          , MONTH_01 = (SELECT MONTH_01 FROM SESSION.TEMP WHERE ACC_CD = '6300000') - (SELECT MONTH_01 FROM SESSION.TEMP WHERE ACC_CD = '6400000')
          , MONTH_02 = (SELECT MONTH_02 FROM SESSION.TEMP WHERE ACC_CD = '6300000') - (SELECT MONTH_02 FROM SESSION.TEMP WHERE ACC_CD = '6400000')
          , MONTH_03 = (SELECT MONTH_03 FROM SESSION.TEMP WHERE ACC_CD = '6300000') - (SELECT MONTH_03 FROM SESSION.TEMP WHERE ACC_CD = '6400000')
          , MONTH_04 = (SELECT MONTH_04 FROM SESSION.TEMP WHERE ACC_CD = '6300000') - (SELECT MONTH_04 FROM SESSION.TEMP WHERE ACC_CD = '6400000')
          , MONTH_05 = (SELECT MONTH_05 FROM SESSION.TEMP WHERE ACC_CD = '6300000') - (SELECT MONTH_05 FROM SESSION.TEMP WHERE ACC_CD = '6400000')
          , MONTH_06 = (SELECT MONTH_06 FROM SESSION.TEMP WHERE ACC_CD = '6300000') - (SELECT MONTH_06 FROM SESSION.TEMP WHERE ACC_CD = '6400000')
          , MONTH_07 = (SELECT MONTH_07 FROM SESSION.TEMP WHERE ACC_CD = '6300000') - (SELECT MONTH_07 FROM SESSION.TEMP WHERE ACC_CD = '6400000')
          , MONTH_08 = (SELECT MONTH_08 FROM SESSION.TEMP WHERE ACC_CD = '6300000') - (SELECT MONTH_08 FROM SESSION.TEMP WHERE ACC_CD = '6400000')
          , MONTH_09 = (SELECT MONTH_09 FROM SESSION.TEMP WHERE ACC_CD = '6300000') - (SELECT MONTH_09 FROM SESSION.TEMP WHERE ACC_CD = '6400000')
          , MONTH_10 = (SELECT MONTH_10 FROM SESSION.TEMP WHERE ACC_CD = '6300000') - (SELECT MONTH_10 FROM SESSION.TEMP WHERE ACC_CD = '6400000')
          , MONTH_11 = (SELECT MONTH_11 FROM SESSION.TEMP WHERE ACC_CD = '6300000') - (SELECT MONTH_11 FROM SESSION.TEMP WHERE ACC_CD = '6400000')
          , MONTH_12 = (SELECT MONTH_12 FROM SESSION.TEMP WHERE ACC_CD = '6300000') - (SELECT MONTH_12 FROM SESSION.TEMP WHERE ACC_CD = '6400000')
          , Q1_TOT = (SELECT Q1_TOT FROM SESSION.TEMP WHERE ACC_CD = '6300000') - (SELECT Q1_TOT FROM SESSION.TEMP WHERE ACC_CD = '6400000')
          , Q2_TOT = (SELECT Q2_TOT FROM SESSION.TEMP WHERE ACC_CD = '6300000') - (SELECT Q2_TOT FROM SESSION.TEMP WHERE ACC_CD = '6400000')
          , Q3_TOT = (SELECT Q3_TOT FROM SESSION.TEMP WHERE ACC_CD = '6300000') - (SELECT Q3_TOT FROM SESSION.TEMP WHERE ACC_CD = '6400000')
          , Q4_TOT = (SELECT Q4_TOT FROM SESSION.TEMP WHERE ACC_CD = '6300000') - (SELECT Q4_TOT FROM SESSION.TEMP WHERE ACC_CD = '6400000')
     WHERE ACC_CD = '6500000';--

     --영업외 수익
    UPDATE SESSION.TEMP
       SET TOTAL = (SELECT SUM(TOTAL) FROM SESSION.TEMP WHERE ACC_CD LIKE '66%' )
          , MONTH_01 = (SELECT SUM(MONTH_01) FROM SESSION.TEMP WHERE ACC_CD LIKE '66%' )
          , MONTH_02 = (SELECT SUM(MONTH_02) FROM SESSION.TEMP WHERE ACC_CD LIKE '66%' )
          , MONTH_03 = (SELECT SUM(MONTH_03) FROM SESSION.TEMP WHERE ACC_CD LIKE '66%' )
          , MONTH_04 = (SELECT SUM(MONTH_04) FROM SESSION.TEMP WHERE ACC_CD LIKE '66%' )
          , MONTH_05 = (SELECT SUM(MONTH_05) FROM SESSION.TEMP WHERE ACC_CD LIKE '66%' )
          , MONTH_06 = (SELECT SUM(MONTH_06) FROM SESSION.TEMP WHERE ACC_CD LIKE '66%' )
          , MONTH_07 = (SELECT SUM(MONTH_07) FROM SESSION.TEMP WHERE ACC_CD LIKE '66%')
          , MONTH_08 = (SELECT SUM(MONTH_08) FROM SESSION.TEMP WHERE ACC_CD LIKE '66%')
          , MONTH_09 = (SELECT SUM(MONTH_09) FROM SESSION.TEMP WHERE ACC_CD LIKE '66%')
          , MONTH_10 = (SELECT SUM(MONTH_10) FROM SESSION.TEMP WHERE ACC_CD LIKE '66%')
          , MONTH_11 = (SELECT SUM(MONTH_11) FROM SESSION.TEMP WHERE ACC_CD LIKE '66%')
          , MONTH_12 = (SELECT SUM(MONTH_12) FROM SESSION.TEMP WHERE ACC_CD LIKE '66%')
          , Q1_TOT = (SELECT SUM(Q1_TOT) FROM SESSION.TEMP WHERE ACC_CD LIKE '66%' )
          , Q2_TOT = (SELECT SUM(Q2_TOT) FROM SESSION.TEMP WHERE ACC_CD LIKE '66%' )
          , Q3_TOT = (SELECT SUM(Q3_TOT) FROM SESSION.TEMP WHERE ACC_CD LIKE '66%' )
          , Q4_TOT = (SELECT SUM(Q4_TOT) FROM SESSION.TEMP WHERE ACC_CD LIKE '66%' )
     WHERE ACC_CD = '6600000';--


     --영업외 비용
    UPDATE SESSION.TEMP
       SET TOTAL = (SELECT SUM(TOTAL) FROM SESSION.TEMP WHERE ACC_CD LIKE '67%' )
          , MONTH_01 = (SELECT SUM(MONTH_01) FROM SESSION.TEMP WHERE ACC_CD LIKE '67%' )
          , MONTH_02 = (SELECT SUM(MONTH_02) FROM SESSION.TEMP WHERE ACC_CD LIKE '67%' )
          , MONTH_03 = (SELECT SUM(MONTH_03) FROM SESSION.TEMP WHERE ACC_CD LIKE '67%' )
          , MONTH_04 = (SELECT SUM(MONTH_04) FROM SESSION.TEMP WHERE ACC_CD LIKE '67%' )
          , MONTH_05 = (SELECT SUM(MONTH_05) FROM SESSION.TEMP WHERE ACC_CD LIKE '67%' )
          , MONTH_06 = (SELECT SUM(MONTH_06) FROM SESSION.TEMP WHERE ACC_CD LIKE '67%' )
          , MONTH_07 = (SELECT SUM(MONTH_07) FROM SESSION.TEMP WHERE ACC_CD LIKE '67%')
          , MONTH_08 = (SELECT SUM(MONTH_08) FROM SESSION.TEMP WHERE ACC_CD LIKE '67%')
          , MONTH_09 = (SELECT SUM(MONTH_09) FROM SESSION.TEMP WHERE ACC_CD LIKE '67%')
          , MONTH_10 = (SELECT SUM(MONTH_10) FROM SESSION.TEMP WHERE ACC_CD LIKE '67%')
          , MONTH_11 = (SELECT SUM(MONTH_11) FROM SESSION.TEMP WHERE ACC_CD LIKE '67%')
          , MONTH_12 = (SELECT SUM(MONTH_12) FROM SESSION.TEMP WHERE ACC_CD LIKE '67%')
          , Q1_TOT = (SELECT SUM(Q1_TOT) FROM SESSION.TEMP WHERE ACC_CD LIKE '67%' )
          , Q2_TOT = (SELECT SUM(Q2_TOT) FROM SESSION.TEMP WHERE ACC_CD LIKE '67%' )
          , Q3_TOT = (SELECT SUM(Q3_TOT) FROM SESSION.TEMP WHERE ACC_CD LIKE '67%' )
          , Q4_TOT = (SELECT SUM(Q4_TOT) FROM SESSION.TEMP WHERE ACC_CD LIKE '67%' )
     WHERE ACC_CD = '6700000';--


    --경상이익 = 영업이익 + 영업외 수익 - 영업외 비용
    UPDATE SESSION.TEMP
       SET TOTAL = (SELECT TOTAL FROM SESSION.TEMP WHERE ACC_CD = '6500000') + (SELECT TOTAL FROM SESSION.TEMP WHERE ACC_CD = '6600000') - (SELECT TOTAL FROM SESSION.TEMP WHERE ACC_CD = '6700000')
          , MONTH_01 = (SELECT MONTH_01 FROM SESSION.TEMP WHERE ACC_CD = '6500000') + (SELECT MONTH_01 FROM SESSION.TEMP WHERE ACC_CD = '6600000')  - (SELECT MONTH_01 FROM SESSION.TEMP WHERE ACC_CD = '6700000')
          , MONTH_02 = (SELECT MONTH_02 FROM SESSION.TEMP WHERE ACC_CD = '6500000') + (SELECT MONTH_02 FROM SESSION.TEMP WHERE ACC_CD = '6600000')  - (SELECT MONTH_02 FROM SESSION.TEMP WHERE ACC_CD = '6700000')
          , MONTH_03 = (SELECT MONTH_03 FROM SESSION.TEMP WHERE ACC_CD = '6500000') + (SELECT MONTH_03 FROM SESSION.TEMP WHERE ACC_CD = '6600000')  - (SELECT MONTH_03 FROM SESSION.TEMP WHERE ACC_CD = '6700000')
          , MONTH_04 = (SELECT MONTH_04 FROM SESSION.TEMP WHERE ACC_CD = '6500000') + (SELECT MONTH_04 FROM SESSION.TEMP WHERE ACC_CD = '6600000')  - (SELECT MONTH_04 FROM SESSION.TEMP WHERE ACC_CD = '6700000')
          , MONTH_05 = (SELECT MONTH_05 FROM SESSION.TEMP WHERE ACC_CD = '6500000') + (SELECT MONTH_05 FROM SESSION.TEMP WHERE ACC_CD = '6600000')  - (SELECT MONTH_05 FROM SESSION.TEMP WHERE ACC_CD = '6700000')
          , MONTH_06 = (SELECT MONTH_06 FROM SESSION.TEMP WHERE ACC_CD = '6500000') + (SELECT MONTH_06 FROM SESSION.TEMP WHERE ACC_CD = '6600000')  - (SELECT MONTH_06 FROM SESSION.TEMP WHERE ACC_CD = '6700000')
          , MONTH_07 = (SELECT MONTH_07 FROM SESSION.TEMP WHERE ACC_CD = '6500000') + (SELECT MONTH_02 FROM SESSION.TEMP WHERE ACC_CD = '6600000')  - (SELECT MONTH_07 FROM SESSION.TEMP WHERE ACC_CD = '6700000')
          , MONTH_08 = (SELECT MONTH_08 FROM SESSION.TEMP WHERE ACC_CD = '6500000') + (SELECT MONTH_08 FROM SESSION.TEMP WHERE ACC_CD = '6600000')  - (SELECT MONTH_08 FROM SESSION.TEMP WHERE ACC_CD = '6700000')
          , MONTH_09 = (SELECT MONTH_09 FROM SESSION.TEMP WHERE ACC_CD = '6500000') + (SELECT MONTH_09 FROM SESSION.TEMP WHERE ACC_CD = '6600000')  - (SELECT MONTH_09 FROM SESSION.TEMP WHERE ACC_CD = '6700000')
          , MONTH_10 = (SELECT MONTH_10 FROM SESSION.TEMP WHERE ACC_CD = '6500000') + (SELECT MONTH_10 FROM SESSION.TEMP WHERE ACC_CD = '6600000')  - (SELECT MONTH_10 FROM SESSION.TEMP WHERE ACC_CD = '6700000')
          , MONTH_11 = (SELECT MONTH_11 FROM SESSION.TEMP WHERE ACC_CD = '6500000') + (SELECT MONTH_11 FROM SESSION.TEMP WHERE ACC_CD = '6600000')  - (SELECT MONTH_11 FROM SESSION.TEMP WHERE ACC_CD = '6700000')
          , MONTH_12 = (SELECT MONTH_12 FROM SESSION.TEMP WHERE ACC_CD = '6500000') + (SELECT MONTH_12 FROM SESSION.TEMP WHERE ACC_CD = '6600000')  - (SELECT MONTH_12 FROM SESSION.TEMP WHERE ACC_CD = '6700000')
          , Q1_TOT = (SELECT Q1_TOT FROM SESSION.TEMP WHERE ACC_CD = '6500000') + (SELECT Q1_TOT FROM SESSION.TEMP WHERE ACC_CD = '6600000')  - (SELECT Q1_TOT FROM SESSION.TEMP WHERE ACC_CD = '6700000')
          , Q2_TOT = (SELECT Q2_TOT FROM SESSION.TEMP WHERE ACC_CD = '6500000') + (SELECT Q2_TOT FROM SESSION.TEMP WHERE ACC_CD = '6600000')  - (SELECT Q2_TOT FROM SESSION.TEMP WHERE ACC_CD = '6700000')
          , Q3_TOT = (SELECT Q3_TOT FROM SESSION.TEMP WHERE ACC_CD = '6500000') + (SELECT Q3_TOT FROM SESSION.TEMP WHERE ACC_CD = '6600000')  - (SELECT Q3_TOT FROM SESSION.TEMP WHERE ACC_CD = '6700000')
          , Q4_TOT = (SELECT Q4_TOT FROM SESSION.TEMP WHERE ACC_CD = '6500000') + (SELECT Q4_TOT FROM SESSION.TEMP WHERE ACC_CD = '6600000')  - (SELECT Q4_TOT FROM SESSION.TEMP WHERE ACC_CD = '6700000')
     WHERE ACC_CD = '6800000';--

     --특별이익
    UPDATE SESSION.TEMP
       SET TOTAL = (SELECT SUM(TOTAL) FROM SESSION.TEMP WHERE ACC_CD LIKE '69%' )
          , MONTH_01 = (SELECT SUM(MONTH_01) FROM SESSION.TEMP WHERE ACC_CD LIKE '69%' )
          , MONTH_02 = (SELECT SUM(MONTH_02) FROM SESSION.TEMP WHERE ACC_CD LIKE '69%' )
          , MONTH_03 = (SELECT SUM(MONTH_03) FROM SESSION.TEMP WHERE ACC_CD LIKE '69%' )
          , MONTH_04 = (SELECT SUM(MONTH_04) FROM SESSION.TEMP WHERE ACC_CD LIKE '69%' )
          , MONTH_05 = (SELECT SUM(MONTH_05) FROM SESSION.TEMP WHERE ACC_CD LIKE '69%' )
          , MONTH_06 = (SELECT SUM(MONTH_06) FROM SESSION.TEMP WHERE ACC_CD LIKE '69%' )
          , MONTH_07 = (SELECT SUM(MONTH_07) FROM SESSION.TEMP WHERE ACC_CD LIKE '69%')
          , MONTH_08 = (SELECT SUM(MONTH_08) FROM SESSION.TEMP WHERE ACC_CD LIKE '69%')
          , MONTH_09 = (SELECT SUM(MONTH_09) FROM SESSION.TEMP WHERE ACC_CD LIKE '69%')
          , MONTH_10 = (SELECT SUM(MONTH_10) FROM SESSION.TEMP WHERE ACC_CD LIKE '69%')
          , MONTH_11 = (SELECT SUM(MONTH_11) FROM SESSION.TEMP WHERE ACC_CD LIKE '69%')
          , MONTH_12 = (SELECT SUM(MONTH_12) FROM SESSION.TEMP WHERE ACC_CD LIKE '69%')
          , Q1_TOT = (SELECT SUM(Q1_TOT) FROM SESSION.TEMP WHERE ACC_CD LIKE '69%' )
          , Q2_TOT = (SELECT SUM(Q2_TOT) FROM SESSION.TEMP WHERE ACC_CD LIKE '69%' )
          , Q3_TOT = (SELECT SUM(Q3_TOT) FROM SESSION.TEMP WHERE ACC_CD LIKE '69%' )
          , Q4_TOT = (SELECT SUM(Q4_TOT) FROM SESSION.TEMP WHERE ACC_CD LIKE '69%' )
     WHERE ACC_CD = '6900000';--

    --특별손실
    UPDATE SESSION.TEMP
       SET TOTAL = (SELECT SUM(TOTAL) FROM SESSION.TEMP WHERE ACC_CD LIKE '70%' )
          , MONTH_01 = (SELECT SUM(MONTH_01) FROM SESSION.TEMP WHERE ACC_CD LIKE '70%' )
          , MONTH_02 = (SELECT SUM(MONTH_02) FROM SESSION.TEMP WHERE ACC_CD LIKE '70%' )
          , MONTH_03 = (SELECT SUM(MONTH_03) FROM SESSION.TEMP WHERE ACC_CD LIKE '70%' )
          , MONTH_04 = (SELECT SUM(MONTH_04) FROM SESSION.TEMP WHERE ACC_CD LIKE '70%' )
          , MONTH_05 = (SELECT SUM(MONTH_05) FROM SESSION.TEMP WHERE ACC_CD LIKE '70%' )
          , MONTH_06 = (SELECT SUM(MONTH_06) FROM SESSION.TEMP WHERE ACC_CD LIKE '70%' )
          , MONTH_07 = (SELECT SUM(MONTH_07) FROM SESSION.TEMP WHERE ACC_CD LIKE '70%')
          , MONTH_08 = (SELECT SUM(MONTH_08) FROM SESSION.TEMP WHERE ACC_CD LIKE '70%')
          , MONTH_09 = (SELECT SUM(MONTH_09) FROM SESSION.TEMP WHERE ACC_CD LIKE '70%')
          , MONTH_10 = (SELECT SUM(MONTH_10) FROM SESSION.TEMP WHERE ACC_CD LIKE '70%')
          , MONTH_11 = (SELECT SUM(MONTH_11) FROM SESSION.TEMP WHERE ACC_CD LIKE '70%')
          , MONTH_12 = (SELECT SUM(MONTH_12) FROM SESSION.TEMP WHERE ACC_CD LIKE '70%')
          , Q1_TOT = (SELECT SUM(Q1_TOT) FROM SESSION.TEMP WHERE ACC_CD LIKE '70%' )
          , Q2_TOT = (SELECT SUM(Q2_TOT) FROM SESSION.TEMP WHERE ACC_CD LIKE '70%' )
          , Q3_TOT = (SELECT SUM(Q3_TOT) FROM SESSION.TEMP WHERE ACC_CD LIKE '70%' )
          , Q4_TOT = (SELECT SUM(Q4_TOT) FROM SESSION.TEMP WHERE ACC_CD LIKE '70%' )
     WHERE ACC_CD = '7000000';--

    -- 법인세차감전 순이익 = 경상이익 + 특별이익 - 특별손실
    UPDATE SESSION.TEMP
       SET TOTAL = (SELECT TOTAL FROM SESSION.TEMP WHERE ACC_CD = '6800000') + (SELECT TOTAL FROM SESSION.TEMP WHERE ACC_CD = '6900000') - (SELECT TOTAL FROM SESSION.TEMP WHERE ACC_CD = '7000000')
          , MONTH_01 = (SELECT MONTH_01 FROM SESSION.TEMP WHERE ACC_CD = '6800000') + (SELECT MONTH_01 FROM SESSION.TEMP WHERE ACC_CD = '6900000')  - (SELECT MONTH_01 FROM SESSION.TEMP WHERE ACC_CD = '7000000')
          , MONTH_02 = (SELECT MONTH_02 FROM SESSION.TEMP WHERE ACC_CD = '6800000') + (SELECT MONTH_02 FROM SESSION.TEMP WHERE ACC_CD = '6900000')  - (SELECT MONTH_02 FROM SESSION.TEMP WHERE ACC_CD = '7000000')
          , MONTH_03 = (SELECT MONTH_03 FROM SESSION.TEMP WHERE ACC_CD = '6800000') + (SELECT MONTH_03 FROM SESSION.TEMP WHERE ACC_CD = '6900000')  - (SELECT MONTH_03 FROM SESSION.TEMP WHERE ACC_CD = '7000000')
          , MONTH_04 = (SELECT MONTH_04 FROM SESSION.TEMP WHERE ACC_CD = '6800000') + (SELECT MONTH_04 FROM SESSION.TEMP WHERE ACC_CD = '6900000')  - (SELECT MONTH_04 FROM SESSION.TEMP WHERE ACC_CD = '7000000')
          , MONTH_05 = (SELECT MONTH_05 FROM SESSION.TEMP WHERE ACC_CD = '6800000') + (SELECT MONTH_05 FROM SESSION.TEMP WHERE ACC_CD = '6900000')  - (SELECT MONTH_05 FROM SESSION.TEMP WHERE ACC_CD = '7000000')
          , MONTH_06 = (SELECT MONTH_06 FROM SESSION.TEMP WHERE ACC_CD = '6800000') + (SELECT MONTH_06 FROM SESSION.TEMP WHERE ACC_CD = '6900000')  - (SELECT MONTH_06 FROM SESSION.TEMP WHERE ACC_CD = '7000000')
          , MONTH_07 = (SELECT MONTH_07 FROM SESSION.TEMP WHERE ACC_CD = '6800000') + (SELECT MONTH_07 FROM SESSION.TEMP WHERE ACC_CD = '6900000')  - (SELECT MONTH_07 FROM SESSION.TEMP WHERE ACC_CD = '7000000')
          , MONTH_08 = (SELECT MONTH_08 FROM SESSION.TEMP WHERE ACC_CD = '6800000') + (SELECT MONTH_08 FROM SESSION.TEMP WHERE ACC_CD = '6900000')  - (SELECT MONTH_08 FROM SESSION.TEMP WHERE ACC_CD = '7000000')
          , MONTH_09 = (SELECT MONTH_09 FROM SESSION.TEMP WHERE ACC_CD = '6800000') + (SELECT MONTH_09 FROM SESSION.TEMP WHERE ACC_CD = '6900000')  - (SELECT MONTH_09 FROM SESSION.TEMP WHERE ACC_CD = '7000000')
          , MONTH_10 = (SELECT MONTH_10 FROM SESSION.TEMP WHERE ACC_CD = '6800000') + (SELECT MONTH_10 FROM SESSION.TEMP WHERE ACC_CD = '6900000')  - (SELECT MONTH_10 FROM SESSION.TEMP WHERE ACC_CD = '7000000')
          , MONTH_11 = (SELECT MONTH_11 FROM SESSION.TEMP WHERE ACC_CD = '6800000') + (SELECT MONTH_11 FROM SESSION.TEMP WHERE ACC_CD = '6900000')  - (SELECT MONTH_11 FROM SESSION.TEMP WHERE ACC_CD = '7000000')
          , MONTH_12 = (SELECT MONTH_12 FROM SESSION.TEMP WHERE ACC_CD = '6800000') + (SELECT MONTH_12 FROM SESSION.TEMP WHERE ACC_CD = '6900000')  - (SELECT MONTH_12 FROM SESSION.TEMP WHERE ACC_CD = '7000000')
          , Q1_TOT = (SELECT Q1_TOT FROM SESSION.TEMP WHERE ACC_CD = '6800000') + (SELECT Q1_TOT FROM SESSION.TEMP WHERE ACC_CD = '6900000')  - (SELECT Q1_TOT FROM SESSION.TEMP WHERE ACC_CD = '7000000')
          , Q2_TOT = (SELECT Q2_TOT FROM SESSION.TEMP WHERE ACC_CD = '6800000') + (SELECT Q2_TOT FROM SESSION.TEMP WHERE ACC_CD = '6900000')  - (SELECT Q2_TOT FROM SESSION.TEMP WHERE ACC_CD = '7000000')
          , Q3_TOT = (SELECT Q3_TOT FROM SESSION.TEMP WHERE ACC_CD = '6800000') + (SELECT Q3_TOT FROM SESSION.TEMP WHERE ACC_CD = '6900000')  - (SELECT Q3_TOT FROM SESSION.TEMP WHERE ACC_CD = '7000000')
          , Q4_TOT = (SELECT Q4_TOT FROM SESSION.TEMP WHERE ACC_CD = '6800000') + (SELECT Q4_TOT FROM SESSION.TEMP WHERE ACC_CD = '6900000')  - (SELECT Q4_TOT FROM SESSION.TEMP WHERE ACC_CD = '7000000')
     WHERE ACC_CD = '7100000';--

     --법인세
    UPDATE SESSION.TEMP
       SET TOTAL = (SELECT SUM(TOTAL) FROM SESSION.TEMP WHERE ACC_CD LIKE '72%' )
          , MONTH_01 = (SELECT SUM(MONTH_01) FROM SESSION.TEMP WHERE ACC_CD LIKE '72%' )
          , MONTH_02 = (SELECT SUM(MONTH_02) FROM SESSION.TEMP WHERE ACC_CD LIKE '72%' )
          , MONTH_03 = (SELECT SUM(MONTH_03) FROM SESSION.TEMP WHERE ACC_CD LIKE '72%' )
          , MONTH_04 = (SELECT SUM(MONTH_04) FROM SESSION.TEMP WHERE ACC_CD LIKE '72%' )
          , MONTH_05 = (SELECT SUM(MONTH_05) FROM SESSION.TEMP WHERE ACC_CD LIKE '72%' )
          , MONTH_06 = (SELECT SUM(MONTH_06) FROM SESSION.TEMP WHERE ACC_CD LIKE '72%' )
          , MONTH_07 = (SELECT SUM(MONTH_07) FROM SESSION.TEMP WHERE ACC_CD LIKE '72%')
          , MONTH_08 = (SELECT SUM(MONTH_08) FROM SESSION.TEMP WHERE ACC_CD LIKE '72%')
          , MONTH_09 = (SELECT SUM(MONTH_09) FROM SESSION.TEMP WHERE ACC_CD LIKE '72%')
          , MONTH_10 = (SELECT SUM(MONTH_10) FROM SESSION.TEMP WHERE ACC_CD LIKE '72%')
          , MONTH_11 = (SELECT SUM(MONTH_11) FROM SESSION.TEMP WHERE ACC_CD LIKE '72%')
          , MONTH_12 = (SELECT SUM(MONTH_12) FROM SESSION.TEMP WHERE ACC_CD LIKE '72%')
          , Q1_TOT = (SELECT SUM(Q1_TOT) FROM SESSION.TEMP WHERE ACC_CD LIKE '72%' )
          , Q2_TOT = (SELECT SUM(Q2_TOT) FROM SESSION.TEMP WHERE ACC_CD LIKE '72%' )
          , Q3_TOT = (SELECT SUM(Q3_TOT) FROM SESSION.TEMP WHERE ACC_CD LIKE '72%' )
          , Q4_TOT = (SELECT SUM(Q4_TOT) FROM SESSION.TEMP WHERE ACC_CD LIKE '72%' )
     WHERE ACC_CD = '7200000';--

    --당기순이익 = 차감전 순이익 - 법인세
    UPDATE SESSION.TEMP
       SET TOTAL = (SELECT TOTAL FROM SESSION.TEMP WHERE ACC_CD = '7100000') - (SELECT TOTAL FROM SESSION.TEMP WHERE ACC_CD = '7200000')
          , MONTH_01 = (SELECT MONTH_01 FROM SESSION.TEMP WHERE ACC_CD = '7100000') - (SELECT MONTH_01 FROM SESSION.TEMP WHERE ACC_CD = '7200000')
          , MONTH_02 = (SELECT MONTH_02 FROM SESSION.TEMP WHERE ACC_CD = '7100000') - (SELECT MONTH_02 FROM SESSION.TEMP WHERE ACC_CD = '7200000')
          , MONTH_03 = (SELECT MONTH_03 FROM SESSION.TEMP WHERE ACC_CD = '7100000') - (SELECT MONTH_03 FROM SESSION.TEMP WHERE ACC_CD = '7200000')
          , MONTH_04 = (SELECT MONTH_04 FROM SESSION.TEMP WHERE ACC_CD = '7100000') - (SELECT MONTH_04 FROM SESSION.TEMP WHERE ACC_CD = '7200000')
          , MONTH_05 = (SELECT MONTH_05 FROM SESSION.TEMP WHERE ACC_CD = '7100000') - (SELECT MONTH_05 FROM SESSION.TEMP WHERE ACC_CD = '7200000')
          , MONTH_06 = (SELECT MONTH_06 FROM SESSION.TEMP WHERE ACC_CD = '7100000') - (SELECT MONTH_06 FROM SESSION.TEMP WHERE ACC_CD = '7200000')
          , MONTH_07 = (SELECT MONTH_07 FROM SESSION.TEMP WHERE ACC_CD = '7100000') - (SELECT MONTH_07 FROM SESSION.TEMP WHERE ACC_CD = '7200000')
          , MONTH_08 = (SELECT MONTH_08 FROM SESSION.TEMP WHERE ACC_CD = '7100000') - (SELECT MONTH_08 FROM SESSION.TEMP WHERE ACC_CD = '7200000')
          , MONTH_09 = (SELECT MONTH_09 FROM SESSION.TEMP WHERE ACC_CD = '7100000') - (SELECT MONTH_09 FROM SESSION.TEMP WHERE ACC_CD = '7200000')
          , MONTH_10 = (SELECT MONTH_10 FROM SESSION.TEMP WHERE ACC_CD = '7100000') - (SELECT MONTH_10 FROM SESSION.TEMP WHERE ACC_CD = '7200000')
          , MONTH_11 = (SELECT MONTH_11 FROM SESSION.TEMP WHERE ACC_CD = '7100000') - (SELECT MONTH_11 FROM SESSION.TEMP WHERE ACC_CD = '7200000')
          , MONTH_12 = (SELECT MONTH_12 FROM SESSION.TEMP WHERE ACC_CD = '7100000') - (SELECT MONTH_12 FROM SESSION.TEMP WHERE ACC_CD = '7200000')
          , Q1_TOT = (SELECT Q1_TOT FROM SESSION.TEMP WHERE ACC_CD = '7100000') - (SELECT Q1_TOT FROM SESSION.TEMP WHERE ACC_CD = '7200000')
          , Q2_TOT = (SELECT Q2_TOT FROM SESSION.TEMP WHERE ACC_CD = '7100000') - (SELECT Q2_TOT FROM SESSION.TEMP WHERE ACC_CD = '7200000')
          , Q3_TOT = (SELECT Q3_TOT FROM SESSION.TEMP WHERE ACC_CD = '7100000') - (SELECT Q3_TOT FROM SESSION.TEMP WHERE ACC_CD = '7200000')
          , Q4_TOT = (SELECT Q4_TOT FROM SESSION.TEMP WHERE ACC_CD = '7100000') - (SELECT Q4_TOT FROM SESSION.TEMP WHERE ACC_CD = '7200000')
     WHERE ACC_CD = '7300909';--

END P1;--

P2: BEGIN

    DECLARE CURSOR_TEMP CURSOR WITH RETURN FOR
    SELECT ACC_CD, ACC_NM, TOTAL, MONTH_01, MONTH_02, MONTH_03, Q1_TOT, MONTH_04, MONTH_05, MONTH_06, Q2_TOT, MONTH_07, MONTH_08, MONTH_09, Q3_TOT, MONTH_10, MONTH_11, MONTH_12, Q4_TOT
      FROM SESSION.TEMP
    WHERE 1 = 1;--

    OPEN CURSOR_TEMP;--
END P2;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN1301_TAB02_SELECT"
(IN IN_FROMMONTH VARCHAR(10),IN IN_TOMONTH VARCHAR(10), IN IN_USER_ID VARCHAR(25))
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE   SQLSTATE          CHAR(5) DEFAULT '00000';--
    DECLARE   V_01_FROMMONTH      VARCHAR(7) DEFAULT '';--
    DECLARE   V_02_FROMMONTH      VARCHAR(7) DEFAULT '';--
    DECLARE   V_03_FROMMONTH      VARCHAR(7) DEFAULT '';--
    DECLARE   V_04_FROMMONTH      VARCHAR(7) DEFAULT '';--
    DECLARE   V_05_FROMMONTH      VARCHAR(7) DEFAULT '';--
    DECLARE   V_06_FROMMONTH      VARCHAR(7) DEFAULT '';--
    DECLARE   V_07_FROMMONTH      VARCHAR(7) DEFAULT '';--
    DECLARE   V_08_FROMMONTH      VARCHAR(7) DEFAULT '';--
    DECLARE   V_09_FROMMONTH      VARCHAR(7) DEFAULT '';--
    DECLARE   V_10_FROMMONTH      VARCHAR(7) DEFAULT '';--
    DECLARE   V_11_FROMMONTH      VARCHAR(7) DEFAULT '';--
    DECLARE   V_12_FROMMONTH      VARCHAR(7) DEFAULT '';--
    DECLARE   V_01_TOMONTH        VARCHAR(7) DEFAULT '';--
    DECLARE   V_02_TOMONTH        VARCHAR(7) DEFAULT '';--
    DECLARE   V_03_TOMONTH        VARCHAR(7) DEFAULT '';--
    DECLARE   V_04_TOMONTH        VARCHAR(7) DEFAULT '';--
    DECLARE   V_05_TOMONTH        VARCHAR(7) DEFAULT '';--
    DECLARE   V_06_TOMONTH        VARCHAR(7) DEFAULT '';--
    DECLARE   V_07_TOMONTH        VARCHAR(7) DEFAULT '';--
    DECLARE   V_08_TOMONTH        VARCHAR(7) DEFAULT '';--
    DECLARE   V_09_TOMONTH        VARCHAR(7) DEFAULT '';--
    DECLARE   V_10_TOMONTH        VARCHAR(7) DEFAULT '';--
    DECLARE   V_11_TOMONTH        VARCHAR(7) DEFAULT '';--
    DECLARE   V_12_TOMONTH        VARCHAR(7) DEFAULT '';--

    DECLARE GLOBAL TEMPORARY TABLE SESSION.TEMP
    (
        ACC_CD          VARCHAR(10)   DEFAULT '',
        ACC_NM          VARCHAR(60)   DEFAULT '',
        TOTAL		    DECIMAL(20,0) DEFAULT 0,
        MONTH_01        DECIMAL(20,0) DEFAULT 0,
        MONTH_02        DECIMAL(20,0) DEFAULT 0,
        MONTH_03        DECIMAL(20,0) DEFAULT 0,
        Q1_TOT          DECIMAL(20,0) DEFAULT 0,
        MONTH_04        DECIMAL(20,0) DEFAULT 0,
        MONTH_05        DECIMAL(20,0) DEFAULT 0,
        MONTH_06        DECIMAL(20,0) DEFAULT 0,
        Q2_TOT          DECIMAL(20,0) DEFAULT 0,
        MONTH_07        DECIMAL(20,0) DEFAULT 0,
        MONTH_08        DECIMAL(20,0) DEFAULT 0,
        MONTH_09        DECIMAL(20,0) DEFAULT 0,
        Q3_TOT          DECIMAL(20,0) DEFAULT 0,
        MONTH_10        DECIMAL(20,0) DEFAULT 0,
        MONTH_11        DECIMAL(20,0) DEFAULT 0,
        MONTH_12        DECIMAL(20,0) DEFAULT 0,
        Q4_TOT          DECIMAL(20,0) DEFAULT 0
    )  ON COMMIT PRESERVE ROWS
  WITH REPLACE
  NOT LOGGED;--


P1: BEGIN

    --월뼐 파라몌트 썰정
    IF SUBSTRING(IN_FROMMONTH,6,2) = '01' THEN
        SET V_01_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'01';--
    ELSE
        SET V_01_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'00';    --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '02' AND SUBSTRING(IN_TOMONTH,6,2) >= '02' THEN
        SET V_02_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'02';--
    ELSE
        SET V_02_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'00';    --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '03' AND SUBSTRING(IN_TOMONTH,6,2) >= '03' THEN
        SET V_03_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'03';--
    ELSE
        SET V_03_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'00';            --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '04' AND SUBSTRING(IN_TOMONTH,6,2) >= '04' THEN
        SET V_04_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'04';--
    ELSE
        SET V_04_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'00';            --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '05' AND SUBSTRING(IN_TOMONTH,6,2) >= '05' THEN
        SET V_05_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'05';--
    ELSE
        SET V_05_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'00';            --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '06' AND SUBSTRING(IN_TOMONTH,6,2) >= '06' THEN
        SET V_06_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'06';--
    ELSE
        SET V_06_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'00';            --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '07' AND SUBSTRING(IN_TOMONTH,6,2) >= '07' THEN
        SET V_07_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'07';--
    ELSE
        SET V_07_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'00';            --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '08'  AND SUBSTRING(IN_TOMONTH,6,2) >= '08' THEN
        SET V_08_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'08';--
    ELSE
        SET V_08_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'00';            --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '09'  AND SUBSTRING(IN_TOMONTH,6,2) >= '09' THEN
        SET V_09_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'09';--
    ELSE
        SET V_09_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'00';            --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '10'  AND SUBSTRING(IN_TOMONTH,6,2) >= '10' THEN
        SET V_10_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'10';--
    ELSE
        SET V_10_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'00';            --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '11'  AND SUBSTRING(IN_TOMONTH,6,2) >= '11' THEN
        SET V_11_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'11';--
    ELSE
        SET V_11_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'00';            --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '12'  AND SUBSTRING(IN_TOMONTH,6,2) <= '12' THEN
        SET V_12_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'12';--
    ELSE
        SET V_12_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'00';            --
    END IF;--

    IF SUBSTRING(IN_FROMMONTH,6,2) = '01' AND SUBSTRING(IN_TOMONTH,6,2) >= '01' THEN
        SET V_01_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'01';--
    ELSE
        SET V_01_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'00';    --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '02' AND SUBSTRING(IN_TOMONTH,6,2) >= '01' THEN
        SET V_02_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'02';--
    ELSE
        SET V_02_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'00';    --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '03' AND SUBSTRING(IN_TOMONTH,6,2) >= '03' THEN
        SET V_03_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'03';--
    ELSE
        SET V_03_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'00';    --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '04' AND SUBSTRING(IN_TOMONTH,6,2) >= '04' THEN
        SET V_04_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'04';--
    ELSE
        SET V_04_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'00';    --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '05' AND SUBSTRING(IN_TOMONTH,6,2) >= '05' THEN
        SET V_05_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'05';--
    ELSE
        SET V_05_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'00';    --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '06' AND SUBSTRING(IN_TOMONTH,6,2) >= '06' THEN
        SET V_06_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'06';--
    ELSE
        SET V_06_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'00';    --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '07' AND SUBSTRING(IN_TOMONTH,6,2) >= '07' THEN
        SET V_07_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'07';--
    ELSE
        SET V_07_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'00';    --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '08' AND SUBSTRING(IN_TOMONTH,6,2) >= '08' THEN
        SET V_08_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'08';--
    ELSE
        SET V_08_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'00';    --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '09' AND SUBSTRING(IN_TOMONTH,6,2) >= '09' THEN
        SET V_09_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'09';--
    ELSE
        SET V_09_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'00';    --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '10' AND SUBSTRING(IN_TOMONTH,6,2) >= '10' THEN
        SET V_10_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'10';--
    ELSE
        SET V_10_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'00';    --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '11' AND SUBSTRING(IN_TOMONTH,6,2) >= '11' THEN
        SET V_11_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'11';--
    ELSE
        SET V_11_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'00';    --
    END IF;--
    IF SUBSTRING(IN_TOMONTH,6,2) >= '12' THEN
        SET V_12_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'12';--
    ELSE
        SET V_12_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'00';    --
    END IF;--

    INSERT INTO SESSION.TEMP
    SELECT   TOT.ACC_CD
            , TOT.ACC_NM
            , TOT.AMT
            , COALESCE(MON01.AMT,0) AS MON01
            , COALESCE(MON02.AMT,0) AS MON02
            , COALESCE(MON03.AMT,0) AS MON03
            , (COALESCE(MON01.AMT,0) + COALESCE(MON02.AMT,0) + COALESCE(MON03.AMT,0)) AS Q1_TOT
            , COALESCE(MON04.AMT,0) AS MON04
            , COALESCE(MON05.AMT,0) AS MON05
            , COALESCE(MON06.AMT,0) AS MON06
            , (COALESCE(MON04.AMT,0) + COALESCE(MON05.AMT,0) + COALESCE(MON06.AMT,0)) AS Q2_TOT
            , COALESCE(MON07.AMT,0) AS MON07
            , COALESCE(MON08.AMT,0) AS MON08
            , COALESCE(MON09.AMT,0) AS MON09
            , (COALESCE(MON07.AMT,0) + COALESCE(MON08.AMT,0) + COALESCE(MON09.AMT,0)) AS Q3_TOT
            , COALESCE(MON10.AMT,0) AS MON10
            , COALESCE(MON11.AMT,0) AS MON11
            , COALESCE(MON12.AMT,0) AS MON12
            , (COALESCE(MON10.AMT,0) + COALESCE(MON11.AMT,0) + COALESCE(MON12.AMT,0)) AS Q4_TOT
      FROM (
                (SELECT ACC_CD, ACC_NM, COALESCE(AMT,0) AS AMT FROM TABLE(GADMIN.SF_FIN1301_TAB02_SELECT(IN_FROMMONTH,IN_TOMONTH))) TOT

                LEFT OUTER JOIN ( SELECT * FROM TABLE(GADMIN.SF_FIN1301_TAB02_SELECT(V_01_FROMMONTH,V_01_TOMONTH)) ) MON01 ON (TOT.ACC_CD = MON01.ACC_CD)
                LEFT OUTER JOIN ( SELECT * FROM TABLE(GADMIN.SF_FIN1301_TAB02_SELECT(V_02_FROMMONTH,V_02_TOMONTH)) ) MON02 ON (TOT.ACC_CD = MON02.ACC_CD)
                LEFT OUTER JOIN ( SELECT * FROM TABLE(GADMIN.SF_FIN1301_TAB02_SELECT(V_03_FROMMONTH,V_03_TOMONTH)) ) MON03 ON (TOT.ACC_CD = MON03.ACC_CD)

                LEFT OUTER JOIN ( SELECT * FROM TABLE(GADMIN.SF_FIN1301_TAB02_SELECT(V_04_FROMMONTH,V_04_TOMONTH)) ) MON04 ON (TOT.ACC_CD = MON04.ACC_CD)
                LEFT OUTER JOIN ( SELECT * FROM TABLE(GADMIN.SF_FIN1301_TAB02_SELECT(V_05_FROMMONTH,V_05_TOMONTH)) ) MON05 ON (TOT.ACC_CD = MON05.ACC_CD)
                LEFT OUTER JOIN ( SELECT * FROM TABLE(GADMIN.SF_FIN1301_TAB02_SELECT(V_06_FROMMONTH,V_06_TOMONTH)) ) MON06 ON (TOT.ACC_CD = MON06.ACC_CD)

                LEFT OUTER JOIN ( SELECT * FROM TABLE(GADMIN.SF_FIN1301_TAB02_SELECT(V_07_FROMMONTH,V_07_TOMONTH)) ) MON07 ON (TOT.ACC_CD = MON07.ACC_CD)
                LEFT OUTER JOIN ( SELECT * FROM TABLE(GADMIN.SF_FIN1301_TAB02_SELECT(V_08_FROMMONTH,V_08_TOMONTH)) ) MON08 ON (TOT.ACC_CD = MON08.ACC_CD)
                LEFT OUTER JOIN ( SELECT * FROM TABLE(GADMIN.SF_FIN1301_TAB02_SELECT(V_09_FROMMONTH,V_09_TOMONTH)) ) MON09 ON (TOT.ACC_CD = MON09.ACC_CD)

                LEFT OUTER JOIN ( SELECT * FROM TABLE(GADMIN.SF_FIN1301_TAB02_SELECT(V_10_FROMMONTH,V_10_TOMONTH)) ) MON10 ON (TOT.ACC_CD = MON10.ACC_CD)
                LEFT OUTER JOIN ( SELECT * FROM TABLE(GADMIN.SF_FIN1301_TAB02_SELECT(V_11_FROMMONTH,V_11_TOMONTH)) ) MON11 ON (TOT.ACC_CD = MON11.ACC_CD)
                LEFT OUTER JOIN ( SELECT * FROM TABLE(GADMIN.SF_FIN1301_TAB02_SELECT(V_12_FROMMONTH,V_12_TOMONTH)) ) MON12 ON (TOT.ACC_CD = MON12.ACC_CD)
      );--

END P1;--

P2: BEGIN

    DECLARE CURSOR_TEMP CURSOR WITH RETURN FOR
    SELECT A.ACC_CD, B.CHULRYEOK_GWAMOK ACC_NM, A.TOTAL, A.MONTH_01, A.MONTH_02, A.MONTH_03, A.Q1_TOT, A.MONTH_04, A.MONTH_05, A.MONTH_06, A.Q2_TOT, A.MONTH_07, A.MONTH_08, A.MONTH_09, A.Q3_TOT, A.MONTH_10, A.MONTH_11, A.MONTH_12, A.Q4_TOT
      FROM SESSION.TEMP A
            LEFT OUTER JOIN GADMIN.BSACC2 B ON ( A.ACC_CD = B.ACC_CD )
    WHERE 1 = 1
      AND B.DRIVE_WONGA != 'N'
    ORDER BY A.ACC_CD, B.CHULRYEOK_GWAMOK;--

    OPEN CURSOR_TEMP;--
END P2;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN1301_TAB02_SELECT_OLD"
(IN IN_FROMMONTH VARCHAR(10),
IN IN_TOMONTH VARCHAR(10), IN IN_USER_ID VARCHAR(25))
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE   SQLSTATE          CHAR(5) DEFAULT '00000';--
    DECLARE   V_01_FROMMONTH      VARCHAR(7) DEFAULT '';--
    DECLARE   V_02_FROMMONTH      VARCHAR(7) DEFAULT '';--
    DECLARE   V_03_FROMMONTH      VARCHAR(7) DEFAULT '';--
    DECLARE   V_04_FROMMONTH      VARCHAR(7) DEFAULT '';--
    DECLARE   V_05_FROMMONTH      VARCHAR(7) DEFAULT '';--
    DECLARE   V_06_FROMMONTH      VARCHAR(7) DEFAULT '';--
    DECLARE   V_07_FROMMONTH      VARCHAR(7) DEFAULT '';--
    DECLARE   V_08_FROMMONTH      VARCHAR(7) DEFAULT '';--
    DECLARE   V_09_FROMMONTH      VARCHAR(7) DEFAULT '';--
    DECLARE   V_10_FROMMONTH      VARCHAR(7) DEFAULT '';--
    DECLARE   V_11_FROMMONTH      VARCHAR(7) DEFAULT '';--
    DECLARE   V_12_FROMMONTH      VARCHAR(7) DEFAULT '';--
    DECLARE   V_01_TOMONTH        VARCHAR(7) DEFAULT '';--
    DECLARE   V_02_TOMONTH        VARCHAR(7) DEFAULT '';--
    DECLARE   V_03_TOMONTH        VARCHAR(7) DEFAULT '';--
    DECLARE   V_04_TOMONTH        VARCHAR(7) DEFAULT '';--
    DECLARE   V_05_TOMONTH        VARCHAR(7) DEFAULT '';--
    DECLARE   V_06_TOMONTH        VARCHAR(7) DEFAULT '';--
    DECLARE   V_07_TOMONTH        VARCHAR(7) DEFAULT '';--
    DECLARE   V_08_TOMONTH        VARCHAR(7) DEFAULT '';--
    DECLARE   V_09_TOMONTH        VARCHAR(7) DEFAULT '';--
    DECLARE   V_10_TOMONTH        VARCHAR(7) DEFAULT '';--
    DECLARE   V_11_TOMONTH        VARCHAR(7) DEFAULT '';--
    DECLARE   V_12_TOMONTH        VARCHAR(7) DEFAULT '';--

    DECLARE GLOBAL TEMPORARY TABLE SESSION.TEMP
    (
        ACC_CD          VARCHAR(10)   DEFAULT '',
        ACC_NM          VARCHAR(60)   DEFAULT '',
        TOTAL		    DECIMAL(20,0) DEFAULT 0,
        MONTH_01        DECIMAL(20,0) DEFAULT 0,
        MONTH_02        DECIMAL(20,0) DEFAULT 0,
        MONTH_03        DECIMAL(20,0) DEFAULT 0,
        Q1_TOT          DECIMAL(20,0) DEFAULT 0,
        MONTH_04        DECIMAL(20,0) DEFAULT 0,
        MONTH_05        DECIMAL(20,0) DEFAULT 0,
        MONTH_06        DECIMAL(20,0) DEFAULT 0,
        Q2_TOT          DECIMAL(20,0) DEFAULT 0,
        MONTH_07        DECIMAL(20,0) DEFAULT 0,
        MONTH_08        DECIMAL(20,0) DEFAULT 0,
        MONTH_09        DECIMAL(20,0) DEFAULT 0,
        Q3_TOT          DECIMAL(20,0) DEFAULT 0,
        MONTH_10        DECIMAL(20,0) DEFAULT 0,
        MONTH_11        DECIMAL(20,0) DEFAULT 0,
        MONTH_12        DECIMAL(20,0) DEFAULT 0,
        Q4_TOT          DECIMAL(20,0) DEFAULT 0
    )  ON COMMIT PRESERVE ROWS
  WITH REPLACE
  NOT LOGGED;--


P1: BEGIN

    --월뼐 파라몌트 썰정
    IF SUBSTRING(IN_FROMMONTH,6,2) = '01' THEN
        SET V_01_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'01';--
    ELSE
        SET V_01_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'00';    --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '02' AND SUBSTRING(IN_TOMONTH,6,2) >= '02' THEN
        SET V_02_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'02';--
    ELSE
        SET V_02_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'00';    --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '03' AND SUBSTRING(IN_TOMONTH,6,2) >= '03' THEN
        SET V_03_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'03';--
    ELSE
        SET V_03_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'00';            --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '04' AND SUBSTRING(IN_TOMONTH,6,2) >= '04' THEN
        SET V_04_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'04';--
    ELSE
        SET V_04_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'00';            --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '05' AND SUBSTRING(IN_TOMONTH,6,2) >= '05' THEN
        SET V_05_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'05';--
    ELSE
        SET V_05_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'00';            --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '06' AND SUBSTRING(IN_TOMONTH,6,2) >= '06' THEN
        SET V_06_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'06';--
    ELSE
        SET V_06_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'00';            --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '07' AND SUBSTRING(IN_TOMONTH,6,2) >= '07' THEN
        SET V_07_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'07';--
    ELSE
        SET V_07_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'00';            --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '08'  AND SUBSTRING(IN_TOMONTH,6,2) >= '08' THEN
        SET V_08_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'08';--
    ELSE
        SET V_08_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'00';            --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '09'  AND SUBSTRING(IN_TOMONTH,6,2) >= '09' THEN
        SET V_09_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'09';--
    ELSE
        SET V_09_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'00';            --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '10'  AND SUBSTRING(IN_TOMONTH,6,2) >= '10' THEN
        SET V_10_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'10';--
    ELSE
        SET V_10_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'00';            --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '11'  AND SUBSTRING(IN_TOMONTH,6,2) >= '11' THEN
        SET V_11_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'11';--
    ELSE
        SET V_11_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'00';            --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '12'  AND SUBSTRING(IN_TOMONTH,6,2) <= '12' THEN
        SET V_12_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'12';--
    ELSE
        SET V_12_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,5)||'00';            --
    END IF;--

    IF SUBSTRING(IN_FROMMONTH,6,2) = '01' AND SUBSTRING(IN_TOMONTH,6,2) >= '01' THEN
        SET V_01_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'01';--
    ELSE
        SET V_01_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'00';    --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '02' AND SUBSTRING(IN_TOMONTH,6,2) >= '01' THEN
        SET V_02_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'02';--
    ELSE
        SET V_02_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'00';    --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '03' AND SUBSTRING(IN_TOMONTH,6,2) >= '03' THEN
        SET V_03_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'03';--
    ELSE
        SET V_03_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'00';    --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '04' AND SUBSTRING(IN_TOMONTH,6,2) >= '04' THEN
        SET V_04_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'04';--
    ELSE
        SET V_04_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'00';    --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '05' AND SUBSTRING(IN_TOMONTH,6,2) >= '05' THEN
        SET V_05_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'05';--
    ELSE
        SET V_05_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'00';    --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '06' AND SUBSTRING(IN_TOMONTH,6,2) >= '06' THEN
        SET V_06_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'06';--
    ELSE
        SET V_06_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'00';    --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '07' AND SUBSTRING(IN_TOMONTH,6,2) >= '07' THEN
        SET V_07_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'07';--
    ELSE
        SET V_07_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'00';    --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '08' AND SUBSTRING(IN_TOMONTH,6,2) >= '08' THEN
        SET V_08_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'08';--
    ELSE
        SET V_08_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'00';    --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '09' AND SUBSTRING(IN_TOMONTH,6,2) >= '09' THEN
        SET V_09_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'09';--
    ELSE
        SET V_09_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'00';    --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '10' AND SUBSTRING(IN_TOMONTH,6,2) >= '10' THEN
        SET V_10_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'10';--
    ELSE
        SET V_10_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'00';    --
    END IF;--
    IF SUBSTRING(IN_FROMMONTH,6,2) <= '11' AND SUBSTRING(IN_TOMONTH,6,2) >= '11' THEN
        SET V_11_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'11';--
    ELSE
        SET V_11_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'00';    --
    END IF;--
    IF SUBSTRING(IN_TOMONTH,6,2) >= '12' THEN
        SET V_12_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'12';--
    ELSE
        SET V_12_TOMONTH = SUBSTRING(IN_TOMONTH,1,5)||'00';    --
    END IF;--

    INSERT INTO SESSION.TEMP
    SELECT   TOT.ACC_CD
            , TOT.ACC_NM
            , TOT.AMT
            , COALESCE(MON01.AMT,0) AS MON01
            , COALESCE(MON02.AMT,0) AS MON02
            , COALESCE(MON03.AMT,0) AS MON03
            , (COALESCE(MON01.AMT,0) + COALESCE(MON02.AMT,0) + COALESCE(MON03.AMT,0)) AS Q1_TOT
            , COALESCE(MON04.AMT,0) AS MON04
            , COALESCE(MON05.AMT,0) AS MON05
            , COALESCE(MON06.AMT,0) AS MON06
            , (COALESCE(MON04.AMT,0) + COALESCE(MON05.AMT,0) + COALESCE(MON06.AMT,0)) AS Q2_TOT
            , COALESCE(MON07.AMT,0) AS MON07
            , COALESCE(MON08.AMT,0) AS MON08
            , COALESCE(MON09.AMT,0) AS MON09
            , (COALESCE(MON07.AMT,0) + COALESCE(MON08.AMT,0) + COALESCE(MON09.AMT,0)) AS Q3_TOT
            , COALESCE(MON10.AMT,0) AS MON10
            , COALESCE(MON11.AMT,0) AS MON11
            , COALESCE(MON12.AMT,0) AS MON12
            , (COALESCE(MON10.AMT,0) + COALESCE(MON11.AMT,0) + COALESCE(MON12.AMT,0)) AS Q4_TOT
      FROM (
                (SELECT ACC_CD, ACC_NM, COALESCE(AMT,0) AS AMT FROM TABLE(GADMIN.SF_FIN1301_TAB02_SELECT(IN_FROMMONTH,IN_TOMONTH))) TOT

                LEFT OUTER JOIN ( SELECT * FROM TABLE(GADMIN.SF_FIN1301_TAB02_SELECT(V_01_FROMMONTH,V_01_TOMONTH)) ) MON01 ON (TOT.ACC_CD = MON01.ACC_CD)
                LEFT OUTER JOIN ( SELECT * FROM TABLE(GADMIN.SF_FIN1301_TAB02_SELECT(V_02_FROMMONTH,V_02_TOMONTH)) ) MON02 ON (TOT.ACC_CD = MON02.ACC_CD)
                LEFT OUTER JOIN ( SELECT * FROM TABLE(GADMIN.SF_FIN1301_TAB02_SELECT(V_03_FROMMONTH,V_03_TOMONTH)) ) MON03 ON (TOT.ACC_CD = MON03.ACC_CD)

                LEFT OUTER JOIN ( SELECT * FROM TABLE(GADMIN.SF_FIN1301_TAB02_SELECT(V_04_FROMMONTH,V_04_TOMONTH)) ) MON04 ON (TOT.ACC_CD = MON04.ACC_CD)
                LEFT OUTER JOIN ( SELECT * FROM TABLE(GADMIN.SF_FIN1301_TAB02_SELECT(V_05_FROMMONTH,V_05_TOMONTH)) ) MON05 ON (TOT.ACC_CD = MON05.ACC_CD)
                LEFT OUTER JOIN ( SELECT * FROM TABLE(GADMIN.SF_FIN1301_TAB02_SELECT(V_06_FROMMONTH,V_06_TOMONTH)) ) MON06 ON (TOT.ACC_CD = MON06.ACC_CD)

                LEFT OUTER JOIN ( SELECT * FROM TABLE(GADMIN.SF_FIN1301_TAB02_SELECT(V_07_FROMMONTH,V_07_TOMONTH)) ) MON07 ON (TOT.ACC_CD = MON07.ACC_CD)
                LEFT OUTER JOIN ( SELECT * FROM TABLE(GADMIN.SF_FIN1301_TAB02_SELECT(V_08_FROMMONTH,V_08_TOMONTH)) ) MON08 ON (TOT.ACC_CD = MON08.ACC_CD)
                LEFT OUTER JOIN ( SELECT * FROM TABLE(GADMIN.SF_FIN1301_TAB02_SELECT(V_09_FROMMONTH,V_09_TOMONTH)) ) MON09 ON (TOT.ACC_CD = MON09.ACC_CD)

                LEFT OUTER JOIN ( SELECT * FROM TABLE(GADMIN.SF_FIN1301_TAB02_SELECT(V_10_FROMMONTH,V_10_TOMONTH)) ) MON10 ON (TOT.ACC_CD = MON10.ACC_CD)
                LEFT OUTER JOIN ( SELECT * FROM TABLE(GADMIN.SF_FIN1301_TAB02_SELECT(V_11_FROMMONTH,V_11_TOMONTH)) ) MON11 ON (TOT.ACC_CD = MON11.ACC_CD)
                LEFT OUTER JOIN ( SELECT * FROM TABLE(GADMIN.SF_FIN1301_TAB02_SELECT(V_12_FROMMONTH,V_12_TOMONTH)) ) MON12 ON (TOT.ACC_CD = MON12.ACC_CD)
      );--

END P1;--

P2: BEGIN

    DECLARE CURSOR_TEMP CURSOR WITH RETURN FOR
    SELECT A.ACC_CD, B.CHULRYEOK_GWAMOK ACC_NM, A.TOTAL, A.MONTH_01, A.MONTH_02, A.MONTH_03, A.Q1_TOT, A.MONTH_04, A.MONTH_05, A.MONTH_06, A.Q2_TOT, A.MONTH_07, A.MONTH_08, A.MONTH_09, A.Q3_TOT, A.MONTH_10, A.MONTH_11, A.MONTH_12, A.Q4_TOT
      FROM SESSION.TEMP A
            LEFT OUTER JOIN GADMIN.BSACC2 B ON ( A.ACC_CD = B.ACC_CD )
    WHERE 1 = 1
      AND B.DRIVE_WONGA != 'N'
    ORDER BY A.ACC_CD, B.CHULRYEOK_GWAMOK;--

    OPEN CURSOR_TEMP;--
END P2;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN1401_TAB01_SELECT_OLD"
(IN IN_FROMMONTH VARCHAR(10), IN IN_TOMONTH VARCHAR(10), IN IN_USER_ID VARCHAR(25))
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE   SQLSTATE          CHAR(5) DEFAULT '00000';--
    DECLARE   V_BE_FROMDATE       VARCHAR(10) DEFAULT '';--
    DECLARE   V_BE_TODATE         VARCHAR(10) DEFAULT '';--

    DECLARE GLOBAL TEMPORARY TABLE SESSION.TEMP
    (
        ACC_CD          VARCHAR(10)   DEFAULT '',
        ACC_NM          VARCHAR(60)   DEFAULT '',
        CU_AMT          DECIMAL(20,5) DEFAULT 0,
        CU_TOT          DECIMAL(20,5) DEFAULT 0,
        BE_AMT          DECIMAL(20,5) DEFAULT 0,
        BE_TOT          DECIMAL(20,5) DEFAULT 0
    )  ON COMMIT PRESERVE ROWS
  WITH REPLACE
  NOT LOGGED;--


P1: BEGIN

    SET IN_FROMMONTH = SUBSTRING(IN_FROMMONTH,1,7);--
    SET IN_TOMONTH = SUBSTRING(IN_TOMONTH,1,7);--

    SELECT SUBSTRING(VARCHAR_FORMAT(TO_TIMESTAMP(IN_FROMMONTH,'YYYYMM') - 1 YEAR,'YYYY-MM'),1,7) INTO V_BE_FROMDATE FROM SYSIBM.SYSDUMMY1;  --전기날짜 계산 (1년 이전 : 전기)
    SELECT SUBSTRING(VARCHAR_FORMAT(TO_TIMESTAMP(IN_TOMONTH,'YYYYMM') - 1 YEAR,'YYYY-MM'),1,7) INTO V_BE_TODATE FROM SYSIBM.SYSDUMMY1;  --전기날짜 계산 (1년 이전 : 전기)

    INSERT INTO SESSION.TEMP
    SELECT ACC_CD, ACC_NM, CU_AMT, CU_TOT, BE_AMT, BE_TOT
      FROM (
                SELECT ACC_CD, ACC_NM, SUM(CU_AMT) AS CU_AMT, SUM(CU_TOT) AS CU_TOT, SUM(BE_AMT) AS BE_AMT, SUM(BE_TOT) AS BE_TOT
                  FROM (
                            SELECT ACC_CD, ACC_NM, COALESCE(AMT,0) AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT FROM TABLE(GADMIN.SF_FIN1301_TAB01_SELECT(IN_FROMMONTH,IN_TOMONTH))
                            UNION ALL
                            SELECT ACC_CD, ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, COALESCE(AMT,0) AS BE_AMT, 0 AS BE_TOT FROM TABLE(GADMIN.SF_FIN1301_TAB01_SELECT(V_BE_FROMDATE,V_BE_TODATE))
                        )
                 GROUP BY ACC_CD, ACC_NM
            );--

/*
    UPDATE SESSION.TEMP
       SET CU_AMT = 0, CU_TOT = CU_AMT, BE_AMT = 0 , BE_TOT = BE_AMT
     WHERE ACC_CD IN (  '6100000'   --(매   출   액)
                        , '6100100'  --운  수  수  입
                        , '6200000'  --(운송원가및주택분양원가)
                        , '6300000'
                        , '6400000'
                        , '6500000'
                        , '6600000'
                        , '6700000'
                        , '6800000'
                        , '6900000'
                        , '7000000'
                        , '7100000'
                        , '7200000'
                        , '7300909'
                       );--
*/
     --운송원가
    UPDATE SESSION.TEMP
       SET CU_AMT = 0
          , CU_TOT = (SELECT SUM(CU_AMT) FROM SESSION.TEMP WHERE ACC_CD LIKE '62%' )
          , BE_AMT = 0
          , BE_TOT = (SELECT SUM(BE_AMT) FROM SESSION.TEMP WHERE ACC_CD LIKE '62%' )
     WHERE ACC_CD = '6200000';--

     --매출액 합계
    UPDATE SESSION.TEMP
       SET CU_AMT = 0
          , CU_TOT = (SELECT SUM(CU_AMT) FROM SESSION.TEMP WHERE ACC_CD LIKE '61%' )
          , BE_AMT = 0
          , BE_TOT = (SELECT SUM(BE_AMT) FROM SESSION.TEMP WHERE ACC_CD LIKE '61%' )
     WHERE ACC_CD = '6100000';--

    --매출 총이익 = 매출액 - 운송원가및주택분양원가
    UPDATE SESSION.TEMP
       SET CU_TOT = (SELECT CU_TOT FROM SESSION.TEMP WHERE ACC_CD = '6100000') - (SELECT CU_TOT FROM SESSION.TEMP WHERE ACC_CD = '6200000')
          , BE_TOT = (SELECT BE_TOT FROM SESSION.TEMP WHERE ACC_CD = '6100000') - (SELECT BE_TOT FROM SESSION.TEMP WHERE ACC_CD = '6200000')
     WHERE ACC_CD = '6300000';--

     --매출액 합계
    UPDATE SESSION.TEMP
       SET CU_AMT = 0
          , CU_TOT = (SELECT SUM(CU_AMT) FROM SESSION.TEMP WHERE ACC_CD LIKE '64%' )
          , BE_AMT = 0
          , BE_TOT = (SELECT SUM(BE_AMT) FROM SESSION.TEMP WHERE ACC_CD LIKE '64%' )
     WHERE ACC_CD = '6400000';--

    --영업이익 = 매출액 - 운송원가및주택분양원가
    UPDATE SESSION.TEMP
       SET CU_TOT = (SELECT CU_TOT FROM SESSION.TEMP WHERE ACC_CD = '6300000') - (SELECT CU_TOT FROM SESSION.TEMP WHERE ACC_CD = '6400000')
          , BE_TOT = (SELECT BE_TOT FROM SESSION.TEMP WHERE ACC_CD = '6300000') - (SELECT BE_TOT FROM SESSION.TEMP WHERE ACC_CD = '6400000')
     WHERE ACC_CD = '6500000';--

     --영업외수익
    UPDATE SESSION.TEMP
       SET CU_AMT = 0
          , CU_TOT = (SELECT SUM(CU_AMT) FROM SESSION.TEMP WHERE ACC_CD LIKE '66%' )
          , BE_AMT = 0
          , BE_TOT = (SELECT SUM(BE_AMT) FROM SESSION.TEMP WHERE ACC_CD LIKE '66%' )
     WHERE ACC_CD = '6600000';--

     --영업외수익
    UPDATE SESSION.TEMP
       SET CU_AMT = 0
          , CU_TOT = (SELECT SUM(CU_AMT) FROM SESSION.TEMP WHERE ACC_CD LIKE '67%' )
          , BE_AMT = 0
          , BE_TOT = (SELECT SUM(BE_AMT) FROM SESSION.TEMP WHERE ACC_CD LIKE '67%' )
     WHERE ACC_CD = '6700000';--

    --경상이익 = 영업이익 + 영업외 수익 - 영업외 비용
    UPDATE SESSION.TEMP
       SET CU_TOT = (SELECT CU_TOT FROM SESSION.TEMP WHERE ACC_CD = '6500000') + (SELECT CU_TOT FROM SESSION.TEMP WHERE ACC_CD = '6600000') - (SELECT CU_TOT FROM SESSION.TEMP WHERE ACC_CD = '6700000')
          , BE_TOT = (SELECT BE_TOT FROM SESSION.TEMP WHERE ACC_CD = '6500000') + (SELECT BE_TOT FROM SESSION.TEMP WHERE ACC_CD = '6600000')  - (SELECT BE_TOT FROM SESSION.TEMP WHERE ACC_CD = '6700000')
     WHERE ACC_CD = '6800000';--

     --특별이익
    UPDATE SESSION.TEMP
       SET CU_AMT = 0
          , CU_TOT = (SELECT SUM(CU_AMT) FROM SESSION.TEMP WHERE ACC_CD LIKE '69%' )
          , BE_AMT = 0
          , BE_TOT = (SELECT SUM(BE_AMT) FROM SESSION.TEMP WHERE ACC_CD LIKE '69%' )
     WHERE ACC_CD = '6900000';--

    --당기순이익 = 차감전 순이익 - 법인세
    UPDATE SESSION.TEMP
       SET CU_TOT = (SELECT CU_TOT FROM SESSION.TEMP WHERE ACC_CD = '6800000') + (SELECT CU_TOT FROM SESSION.TEMP WHERE ACC_CD = '6900000') - (SELECT CU_TOT FROM SESSION.TEMP WHERE ACC_CD = '7000000')
          , BE_TOT = (SELECT BE_TOT FROM SESSION.TEMP WHERE ACC_CD = '6800000') + (SELECT BE_TOT FROM SESSION.TEMP WHERE ACC_CD = '6900000')  - (SELECT BE_TOT FROM SESSION.TEMP WHERE ACC_CD = '7000000')
     WHERE ACC_CD = '7100000';--

     --특별이익
    UPDATE SESSION.TEMP
       SET CU_AMT = 0
          , CU_TOT = (SELECT SUM(CU_AMT) FROM SESSION.TEMP WHERE ACC_CD LIKE '72%' )
          , BE_AMT = 0
          , BE_TOT = (SELECT SUM(BE_AMT) FROM SESSION.TEMP WHERE ACC_CD LIKE '72%' )
     WHERE ACC_CD = '7200000';--

    --당기순이익 = 차감전 순이익 - 법인세
    UPDATE SESSION.TEMP
       SET CU_TOT = (SELECT CU_TOT FROM SESSION.TEMP WHERE ACC_CD = '7100000') - (SELECT CU_TOT FROM SESSION.TEMP WHERE ACC_CD = '7200000')
          , BE_TOT = (SELECT BE_TOT FROM SESSION.TEMP WHERE ACC_CD = '7100000') - (SELECT BE_TOT FROM SESSION.TEMP WHERE ACC_CD = '7200000')
     WHERE ACC_CD = '7300909';--

END P1;--

P2: BEGIN

    DECLARE CURSOR_TEMP CURSOR WITH RETURN FOR
    SELECT *
      FROM SESSION.TEMP
    WHERE 1 = 1;--

    OPEN CURSOR_TEMP;--
END P2;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN1401_TAB02_SELECT_OLD"
(IN IN_FROMMONTH VARCHAR(7), IN IN_TOMONTH VARCHAR(7), IN IN_USER_ID VARCHAR(25))
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE   SQLSTATE          CHAR(5) DEFAULT '00000';--
    DECLARE   V_BE_FROMDATE       VARCHAR(10) DEFAULT '';--
    DECLARE   V_BE_TODATE         VARCHAR(10) DEFAULT '';--

    DECLARE GLOBAL TEMPORARY TABLE SESSION.TEMP
    (
        ACC_CD          VARCHAR(10)   DEFAULT '',
        ACC_NM          VARCHAR(60)   DEFAULT '',
        CU_AMT          DECIMAL(20,5) DEFAULT 0,
        CU_TOT          DECIMAL(20,5) DEFAULT 0,
        BE_AMT          DECIMAL(20,5) DEFAULT 0,
        BE_TOT          DECIMAL(20,5) DEFAULT 0
    )  ON COMMIT PRESERVE ROWS
  WITH REPLACE
  NOT LOGGED;--


P1: BEGIN

    SELECT SUBSTRING(VARCHAR_FORMAT(TO_TIMESTAMP(IN_FROMMONTH,'YYYYMM') - 1 YEAR,'YYYY-MM'),1,7) INTO V_BE_FROMDATE FROM SYSIBM.SYSDUMMY1;  --전기날짜 계산 (1년 이전 : 전기)
    SELECT SUBSTRING(VARCHAR_FORMAT(TO_TIMESTAMP(IN_TOMONTH,'YYYYMM') - 1 YEAR,'YYYY-MM'),1,7) INTO V_BE_TODATE FROM SYSIBM.SYSDUMMY1;  --전기날짜 계산 (1년 이전 : 전기)

    INSERT INTO SESSION.TEMP
    SELECT ACC_CD, ACC_NM, CU_AMT, CU_TOT, BE_AMT, BE_TOT
      FROM (
                SELECT ACC_CD, ACC_NM, SUM(CU_AMT) AS CU_AMT, SUM(CU_TOT) AS CU_TOT, SUM(BE_AMT) AS BE_AMT, SUM(BE_TOT) AS BE_TOT
                  FROM (
                            SELECT ACC_CD, ACC_NM, COALESCE(AMT,0) AS CU_AMT, 0 AS CU_TOT, 0 AS BE_AMT, 0 AS BE_TOT FROM TABLE(GADMIN.SF_FIN1301_TAB02_SELECT(IN_FROMMONTH,IN_TOMONTH))
                            UNION ALL
                            SELECT ACC_CD, ACC_NM, 0 AS CU_AMT, 0 AS CU_TOT, COALESCE(AMT,0) AS BE_AMT, 0 AS BE_TOT FROM TABLE(GADMIN.SF_FIN1301_TAB02_SELECT(V_BE_FROMDATE,V_BE_TODATE))
                        )
                 GROUP BY ACC_CD, ACC_NM
            );--

    -- 합계칸으로 위치 변경
    UPDATE SESSION.TEMP
       SET CU_AMT = 0, CU_TOT = CU_AMT, BE_AMT = 0 , BE_TOT = BE_AMT
     WHERE ACC_CD IN (  '6200000'   --(운송원가및주택분양원가)
                        , '6220000'  --운  수  수  입
                        , '6220100'  --(운송원가및주택분양원가)
                        , '6220600'
                        , '6230000'
                        , '6230100'
                       );--

END P1;--

P2: BEGIN

    DECLARE CURSOR_TEMP CURSOR WITH RETURN FOR
    SELECT A.ACC_CD, B.CHULRYEOK_GWAMOK ACC_NM, A.CU_AMT, A.CU_TOT, A.BE_AMT, A.BE_TOT
      FROM SESSION.TEMP A
            LEFT OUTER JOIN GADMIN.BSACC2 B ON ( A.ACC_CD = B.ACC_CD )
    WHERE 1 = 1
      AND B.DRIVE_WONGA != 'N'
    ORDER BY A.ACC_CD, B.CHULRYEOK_GWAMOK;--

    OPEN CURSOR_TEMP;--
END P2;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN1501_TAB01_SELECT"
(
    IN IN_GISU VARCHAR(3),
    IN IN_USER_ID VARCHAR(25)
)
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE SQLSTATE CHAR(5) DEFAULT '00000';--
    P1: BEGIN

		DECLARE CURSOR_HAPJAN CURSOR WITH RETURN FOR
		SELECT *
          FROM GADMIN.HAPJAN
         WHERE YEAR = IN_GISU
         ORDER BY ACC_CD;--
	OPEN CURSOR_HAPJAN;--
   END P1;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN1501_TAB02_SELECT"
(
    IN IN_GISU VARCHAR(3),
    IN IN_USER_ID VARCHAR(25)
)
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE SQLSTATE CHAR(5) DEFAULT '00000';--
    P1: BEGIN

		DECLARE CURSOR_TRADEKYE CURSOR WITH RETURN FOR
		SELECT *
          FROM GADMIN.TRADEKYE
         WHERE YEAR = IN_GISU
         ORDER BY ACC_CD;--
	OPEN CURSOR_TRADEKYE;--
   END P1;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN1501_UPDATE" (IN IN_FROMDATE
VARCHAR(10), IN IN_TODATE VARCHAR(10), IN_GISU VARCHAR(3), IN IN_USER_ID
VARCHAR(25))
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE   SQLSTATE          CHAR(5) DEFAULT '00000';--
    DECLARE   V_GISU              VARCHAR(10) DEFAULT '';--
    DECLARE   V_CNT               INT DEFAULT 0;--

    DECLARE GLOBAL TEMPORARY TABLE SESSION.TEMP
    (
        YEAR           VARCHAR(3)    DEFAULT '',
        ACC_CD          VARCHAR(10)   DEFAULT '',
        ACC_NM          VARCHAR(60)   DEFAULT '',
        DRCR_GB         VARCHAR(6)    DEFAULT '',
        MANAGE_ITEM     VARCHAR(6)    DEFAULT '',
        DR_00           DECIMAL(15,0) DEFAULT 0,
        CR_00           DECIMAL(15,0) DEFAULT 0,
        DR_01           DECIMAL(15,0) DEFAULT 0,
        CR_01           DECIMAL(15,0) DEFAULT 0,
        DR_02           DECIMAL(15,0) DEFAULT 0,
        CR_02           DECIMAL(15,0) DEFAULT 0,
        DR_03           DECIMAL(15,0) DEFAULT 0,
        CR_03           DECIMAL(15,0) DEFAULT 0,
        DR_04           DECIMAL(15,0) DEFAULT 0,
        CR_04           DECIMAL(15,0) DEFAULT 0,
        DR_05           DECIMAL(15,0) DEFAULT 0,
        CR_05           DECIMAL(15,0) DEFAULT 0,
        DR_06           DECIMAL(15,0) DEFAULT 0,
        CR_06           DECIMAL(15,0) DEFAULT 0,
        DR_07           DECIMAL(15,0) DEFAULT 0,
        CR_07           DECIMAL(15,0) DEFAULT 0,
        DR_08           DECIMAL(15,0) DEFAULT 0,
        CR_08           DECIMAL(15,0) DEFAULT 0,
        DR_09           DECIMAL(15,0) DEFAULT 0,
        CR_09           DECIMAL(15,0) DEFAULT 0,
        DR_10           DECIMAL(15,0) DEFAULT 0,
        CR_10           DECIMAL(15,0) DEFAULT 0,
        DR_11           DECIMAL(15,0) DEFAULT 0,
        CR_11           DECIMAL(15,0) DEFAULT 0,
        DR_12           DECIMAL(15,0) DEFAULT 0,
        CR_12           DECIMAL(15,0) DEFAULT 0,
        DR_JANAEK       DECIMAL(15,0) DEFAULT 0,
        CR_JANAEK       DECIMAL(15,0) DEFAULT 0
    )  ON COMMIT PRESERVE ROWS
  WITH REPLACE
  NOT LOGGED;--

    DECLARE GLOBAL TEMPORARY TABLE SESSION.TRADEKEY_TEMP
    (
        YEAR           VARCHAR(3)    DEFAULT '',
        ACC_CD          VARCHAR(10)   DEFAULT '',
        ACC_NM          VARCHAR(60)   DEFAULT '',
        MANAGE_1        VARCHAR(6)    DEFAULT '',
        ITEM_1          VARCHAR(75)   DEFAULT '',
        MANAGE_2        VARCHAR(9)    DEFAULT '',
        ITEM_2          VARCHAR(90)   DEFAULT '',
        DRCR_GB         VARCHAR(6)    DEFAULT '',
        DR_00           DECIMAL(15,0) DEFAULT 0,
        CR_00           DECIMAL(15,0) DEFAULT 0,
        DR_01           DECIMAL(15,0) DEFAULT 0,
        CR_01           DECIMAL(15,0) DEFAULT 0,
        DR_02           DECIMAL(15,0) DEFAULT 0,
        CR_02           DECIMAL(15,0) DEFAULT 0,
        DR_03           DECIMAL(15,0) DEFAULT 0,
        CR_03           DECIMAL(15,0) DEFAULT 0,
        DR_04           DECIMAL(15,0) DEFAULT 0,
        CR_04           DECIMAL(15,0) DEFAULT 0,
        DR_05           DECIMAL(15,0) DEFAULT 0,
        CR_05           DECIMAL(15,0) DEFAULT 0,
        DR_06           DECIMAL(15,0) DEFAULT 0,
        CR_06           DECIMAL(15,0) DEFAULT 0,
        DR_07           DECIMAL(15,0) DEFAULT 0,
        CR_07           DECIMAL(15,0) DEFAULT 0,
        DR_08           DECIMAL(15,0) DEFAULT 0,
        CR_08           DECIMAL(15,0) DEFAULT 0,
        DR_09           DECIMAL(15,0) DEFAULT 0,
        CR_09           DECIMAL(15,0) DEFAULT 0,
        DR_10           DECIMAL(15,0) DEFAULT 0,
        CR_10           DECIMAL(15,0) DEFAULT 0,
        DR_11           DECIMAL(15,0) DEFAULT 0,
        CR_11           DECIMAL(15,0) DEFAULT 0,
        DR_12           DECIMAL(15,0) DEFAULT 0,
        CR_12           DECIMAL(15,0) DEFAULT 0,
        DR_JANAEK       DECIMAL(15,0) DEFAULT 0,
        CR_JANAEK       DECIMAL(15,0) DEFAULT 0
    )  ON COMMIT PRESERVE ROWS
  WITH REPLACE
  NOT LOGGED;--

P1: BEGIN

    SELECT COUNT(*) INTO V_CNT
      FROM GADMIN.HAPJAN
     WHERE YEAR = IN_GISU;--

    IF V_CNT > 0 THEN
        --기존 합잔 데이터 백업 : 전기이월 데이터 활용을 위해 저장함
        INSERT INTO SESSION.TEMP
               ( YEAR, ACC_CD, ACC_NM, DRCR_GB, MANAGE_ITEM,DR_00,CR_00,DR_01,CR_01,DR_02,CR_02,DR_03,CR_03,DR_04,CR_04,DR_05,CR_05,DR_06,CR_06,DR_07,CR_07,DR_08,CR_08,DR_09,CR_09,DR_10,CR_10,DR_11,CR_11,DR_12,CR_12,DR_JANAEK,CR_JANAEK )
        SELECT          YEAR,ACC_CD,ACC_NM,DRCR_GB,MANAGE_ITEM,DR_00,CR_00,DR_01,CR_01,DR_02,CR_02,DR_03,CR_03,DR_04,CR_04,DR_05,CR_05,DR_06,CR_06,DR_07,CR_07,DR_08,CR_08,DR_09,CR_09,DR_10,CR_10,DR_11,CR_11,DR_12,CR_12,DR_JANAEK,CR_JANAEK
          FROM GADMIN.HAPJAN
         WHERE YEAR = IN_GISU;--

         DELETE GADMIN.HAPJAN
         WHERE YEAR = IN_GISU;--
    END IF;--

    --합잔 재계산
    INSERT INTO GADMIN.HAPJAN (YEAR, ACC_CD, ACC_NM, DRCR_GB, MANAGE_ITEM, DR_00, CR_00, DR_01, CR_01, DR_02, CR_02, DR_03, CR_03, DR_04, CR_04, DR_05, CR_05, DR_06, CR_06, DR_07, CR_07, DR_08, CR_08, DR_09, CR_09, DR_10, CR_10, DR_11, CR_11, DR_12, CR_12, DR_JANAEK, CR_JANAEK)
    SELECT IN_GISU, A.ACC_CD, A.ACC_NM, B.DRCR_GB, ''
            , 0 AS DR_00, 0 AS CR_00
            , SUM(DR_01) AS DR_01, SUM(CR_01) AS CR_01
            , SUM(DR_02) AS DR_02, SUM(CR_02) AS CR_02
            , SUM(DR_03) AS DR_03, SUM(CR_03) AS CR_03
            , SUM(DR_04) AS DR_04, SUM(CR_04) AS CR_04
            , SUM(DR_05) AS DR_05, SUM(CR_05) AS CR_05
            , SUM(DR_06) AS DR_06, SUM(CR_06) AS CR_06
            , SUM(DR_07) AS DR_07, SUM(CR_07) AS CR_07
            , SUM(DR_08) AS DR_08, SUM(CR_08) AS CR_08
            , SUM(DR_09) AS DR_09, SUM(CR_09) AS CR_09
            , SUM(DR_10) AS DR_10, SUM(CR_10) AS CR_10
            , SUM(DR_11) AS DR_11, SUM(CR_11) AS CR_11
            , SUM(DR_12) AS DR_12, SUM(CR_12) AS CR_12
            ,0,0
       FROM (
                SELECT A.ACC_CD
                      , A.ACC_NM
                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '01' THEN SUM(COALESCE(DR_AMT,0)) END,0) DR_01
                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '01' THEN SUM(COALESCE(CR_AMT,0)) END,0) CR_01

                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '02' THEN SUM(COALESCE(DR_AMT,0)) END,0) DR_02
                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '02' THEN SUM(COALESCE(CR_AMT,0)) END,0) CR_02

                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '03' THEN SUM(COALESCE(DR_AMT,0)) END,0) DR_03
                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '03' THEN SUM(COALESCE(CR_AMT,0)) END,0) CR_03

                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '04' THEN SUM(COALESCE(DR_AMT,0)) END,0) DR_04
                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '04' THEN SUM(COALESCE(CR_AMT,0)) END,0) CR_04

                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '05' THEN SUM(COALESCE(DR_AMT,0)) END,0) DR_05
                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '05' THEN SUM(COALESCE(CR_AMT,0)) END,0) CR_05

                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '06' THEN SUM(COALESCE(DR_AMT,0)) END,0) DR_06
                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '06' THEN SUM(COALESCE(CR_AMT,0)) END,0) CR_06

                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '07' THEN SUM(COALESCE(DR_AMT,0)) END,0) DR_07
                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '07' THEN SUM(COALESCE(CR_AMT,0)) END,0) CR_07

                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '08' THEN SUM(COALESCE(DR_AMT,0)) END,0) DR_08
                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '08' THEN SUM(COALESCE(CR_AMT,0)) END,0) CR_08

                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '09' THEN SUM(COALESCE(DR_AMT,0)) END,0) DR_09
                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '09' THEN SUM(COALESCE(CR_AMT,0)) END,0) CR_09

                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '10' THEN SUM(COALESCE(DR_AMT,0)) END,0) DR_10
                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '10' THEN SUM(COALESCE(CR_AMT,0)) END,0) CR_10

                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '11' THEN SUM(COALESCE(DR_AMT,0)) END,0) DR_11
                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '11' THEN SUM(COALESCE(CR_AMT,0)) END,0) CR_11

                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '12' THEN SUM(COALESCE(DR_AMT,0)) END,0) DR_12
                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '12' THEN SUM(COALESCE(CR_AMT,0)) END,0) CR_12

                  FROM GADMIN.BSACC2 A
                        LEFT OUTER JOIN (SELECT * FROM GADMIN.ACCOU1 WHERE DATE BETWEEN IN_FROMDATE AND IN_TODATE) B ON (A.ACC_CD = B.ACC_CD)
                 WHERE 1 = 1
                GROUP BY A.ACC_CD, A.ACC_NM, SUBSTRING(DATE,6,2)
                UNION ALL
                SELECT '1110101' AS ACC_CD, '현          금' AS ACC_NM
                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '01' THEN SUM(COALESCE(CR_AMT,0)) END,0) DR_01
                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '01' THEN SUM(COALESCE(DR_AMT,0)) END,0) CR_01

                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '02' THEN SUM(COALESCE(CR_AMT,0)) END,0) DR_02
                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '02' THEN SUM(COALESCE(DR_AMT,0)) END,0) CR_02

                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '03' THEN SUM(COALESCE(CR_AMT,0)) END,0) DR_03
                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '03' THEN SUM(COALESCE(DR_AMT,0)) END,0) CR_03

                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '04' THEN SUM(COALESCE(CR_AMT,0)) END,0) DR_04
                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '04' THEN SUM(COALESCE(DR_AMT,0)) END,0) CR_04

                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '05' THEN SUM(COALESCE(CR_AMT,0)) END,0) DR_05
                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '05' THEN SUM(COALESCE(DR_AMT,0)) END,0) CR_05

                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '06' THEN SUM(COALESCE(CR_AMT,0)) END,0) DR_06
                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '06' THEN SUM(COALESCE(DR_AMT,0)) END,0) CR_06

                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '07' THEN SUM(COALESCE(CR_AMT,0)) END,0) DR_07
                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '07' THEN SUM(COALESCE(DR_AMT,0)) END,0) CR_07

                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '08' THEN SUM(COALESCE(CR_AMT,0)) END,0) DR_08
                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '08' THEN SUM(COALESCE(DR_AMT,0)) END,0) CR_08

                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '09' THEN SUM(COALESCE(CR_AMT,0)) END,0) DR_09
                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '09' THEN SUM(COALESCE(DR_AMT,0)) END,0) CR_09

                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '10' THEN SUM(COALESCE(CR_AMT,0)) END,0) DR_10
                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '10' THEN SUM(COALESCE(DR_AMT,0)) END,0) CR_10

                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '11' THEN SUM(COALESCE(CR_AMT,0)) END,0) DR_11
                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '11' THEN SUM(COALESCE(DR_AMT,0)) END,0) CR_11

                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '12' THEN SUM(COALESCE(CR_AMT,0)) END,0) DR_12
                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '12' THEN SUM(COALESCE(DR_AMT,0)) END,0) CR_12
                  FROM GADMIN.ACCOU1 A
                 WHERE 1 = 1
                    AND DRCR_GB IN ('입금','출금')
                    AND DATE BETWEEN IN_FROMDATE AND IN_TODATE
               GROUP BY SUBSTRING(DATE,6,2)
              ) A LEFT OUTER JOIN GADMIN.BSACC2 B ON ( A.ACC_CD = B.ACC_CD )
    GROUP BY A.ACC_CD, A.ACC_NM, B.DRCR_GB;--

--이월정보 넣기
    IF V_CNT > 0 THEN
        --전기 이월 금액 넣기
        UPDATE GADMIN.HAPJAN A
           SET A.DR_00 = B.DR_00,
               A.CR_00 = B.CR_00
          FROM SESSION.TEMP B
         WHERE 1 = 1
           AND A.ACC_CD = B.ACC_CD
           AND A.YEAR = B.YEAR;--

     END IF;--

-- 계정 마감 작업
    SELECT COUNT(*) INTO V_CNT
      FROM GADMIN.TRADEKYE
     WHERE YEAR = IN_GISU;--

    IF V_CNT > 0 THEN
        --TRADEKYE 백업 : 전기 이월 데이터 백업
        INSERT INTO SESSION.TRADEKEY_TEMP (YEAR, ACC_CD, ACC_NM, MANAGE_1, ITEM_1, MANAGE_2, ITEM_2, DRCR_GB, DR_00, CR_00, DR_01, CR_01, DR_02, CR_02, DR_03, CR_03, DR_04, CR_04, DR_05, CR_05, DR_06, CR_06, DR_07, CR_07
                        , DR_08, CR_08, DR_09, CR_09, DR_10, CR_10, DR_11, CR_11, DR_12, CR_12, DR_JANAEK, CR_JANAEK)
        SELECT YEAR, ACC_CD, ACC_NM, MANAGE_1, ITEM_1, MANAGE_2, ITEM_2, DRCR_GB, DR_00, CR_00, DR_01, CR_01, DR_02, CR_02, DR_03, CR_03, DR_04, CR_04, DR_05, CR_05, DR_06, CR_06, DR_07, CR_07
                        , DR_08, CR_08, DR_09, CR_09, DR_10, CR_10, DR_11, CR_11, DR_12, CR_12, DR_JANAEK, CR_JANAEK
          FROM GADMIN.TRADEKYE
         WHERE YEAR = IN_GISU;--

         DELETE GADMIN.TRADEKYE
         WHERE YEAR = IN_GISU;--
    END IF;--

    INSERT INTO GADMIN.TRADEKYE(YEAR, ACC_CD, ACC_NM, MANAGE_1, ITEM_1, MANAGE_2, ITEM_2, DRCR_GB, DR_00, CR_00, DR_01, CR_01, DR_02, CR_02, DR_03, CR_03, DR_04, CR_04, DR_05, CR_05, DR_06, CR_06, DR_07, CR_07
                        , DR_08, CR_08, DR_09, CR_09, DR_10, CR_10, DR_11, CR_11, DR_12, CR_12, DR_JANAEK, CR_JANAEK)
    SELECT IN_GISU, A.ACC_CD, A.ACC_NM, A.MANAGE_CD_1, A.MANAGE_ITEM_1, A.MANAGE_CD_2, A.MANAGE_ITEM_2, B.DRCR_GB
                          , DR_00, CR_00
                          , DR_01, CR_01
                          , DR_02, CR_02
                          , DR_03, CR_03
                          , DR_04, CR_04
                          , DR_05, CR_05
                          , DR_06, CR_06
                          , DR_07, CR_07
                          , DR_08, CR_08
                          , DR_09, CR_09
                          , DR_10, CR_10
                          , DR_11, CR_11
                          , DR_12, CR_12
                          , 0 , 0
      FROM (
        SELECT A.ACC_CD, A.ACC_NM, A.MANAGE_CD_1, C.MANAGE_ITEM_1,  A.MANAGE_CD_2, C.MANAGE_ITEM_2
                , SUM(DR_00) AS DR_00, SUM(CR_00) AS CR_00
                , SUM(DR_01) AS DR_01, SUM(CR_01) AS CR_01
                , SUM(DR_02) AS DR_02, SUM(CR_02) AS CR_02
                , SUM(DR_03) AS DR_03, SUM(CR_03) AS CR_03
                , SUM(DR_04) AS DR_04, SUM(CR_04) AS CR_04
                , SUM(DR_05) AS DR_05, SUM(CR_05) AS CR_05
                , SUM(DR_06) AS DR_06, SUM(CR_06) AS CR_06
                , SUM(DR_07) AS DR_07, SUM(CR_07) AS CR_07
                , SUM(DR_08) AS DR_08, SUM(CR_08) AS CR_08
                , SUM(DR_09) AS DR_09, SUM(CR_09) AS CR_09
                , SUM(DR_10) AS DR_10, SUM(CR_10) AS CR_10
                , SUM(DR_11) AS DR_11, SUM(CR_11) AS CR_11
                , SUM(DR_12) AS DR_12, SUM(CR_12) AS CR_12
           FROM (
                    SELECT ACC_CD, ACC_NM, MANAGE_1 AS MANAGE_CD_1, ITEM_1 AS MANAGE_ITEM_1, MANAGE_2 AS MANAGE_CD_2, ITEM_2 AS MANAGE_ITEM_2
                          , DR_00, CR_00
                          , 0 AS DR_01, 0 AS CR_01
                          , 0 AS DR_02, 0 AS CR_02
                          , 0 AS DR_03, 0 AS CR_03
                          , 0 AS DR_04, 0 AS CR_04
                          , 0 AS DR_05, 0 AS CR_05
                          , 0 AS DR_06, 0 AS CR_06
                          , 0 AS DR_07, 0 AS CR_07
                          , 0 AS DR_08, 0 AS CR_08
                          , 0 AS DR_09, 0 AS CR_09
                          , 0 AS DR_10, 0 AS CR_10
                          , 0 AS DR_11, 0 AS CR_11
                          , 0 AS DR_12, 0 AS CR_12
                      FROM GADMIN.TRADEKYE
                     WHERE 1 = 1
                       AND YEAR = IN_GISU
                    UNION ALL
                    SELECT ACC_CD, ACC_NM, MANAGE_CD_1, MANAGE_ITEM_1,  MANAGE_CD_2, MANAGE_ITEM_2
                          , DR_00, CR_00
                          , DR_01, CR_01
                          , DR_02, CR_02
                          , DR_03, CR_03
                          , DR_04, CR_04
                          , DR_05, CR_05
                          , DR_06, CR_06
                          , DR_07, CR_07
                          , DR_08, CR_08
                          , DR_09, CR_09
                          , DR_10, CR_10
                          , DR_11, CR_11
                          , DR_12, CR_12
                      FROM (
                                SELECT ACC_CD, ACC_NM, MANAGE_CD_1, MANAGE_ITEM_1,  MANAGE_CD_2, MANAGE_ITEM_2
                                      , 0 AS DR_00, 0 AS CR_00
                                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '01' THEN SUM(COALESCE(DR_AMT,0)) END,0) DR_01
                                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '01' THEN SUM(COALESCE(CR_AMT,0)) END,0) CR_01

                                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '02' THEN SUM(COALESCE(DR_AMT,0)) END,0) DR_02
                                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '02' THEN SUM(COALESCE(CR_AMT,0)) END,0) CR_02

                                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '03' THEN SUM(COALESCE(DR_AMT,0)) END,0) DR_03
                                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '03' THEN SUM(COALESCE(CR_AMT,0)) END,0) CR_03

                                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '04' THEN SUM(COALESCE(DR_AMT,0)) END,0) DR_04
                                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '04' THEN SUM(COALESCE(CR_AMT,0)) END,0) CR_04

                                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '05' THEN SUM(COALESCE(DR_AMT,0)) END,0) DR_05
                                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '05' THEN SUM(COALESCE(CR_AMT,0)) END,0) CR_05

                                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '06' THEN SUM(COALESCE(DR_AMT,0)) END,0) DR_06
                                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '06' THEN SUM(COALESCE(CR_AMT,0)) END,0) CR_06

                                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '07' THEN SUM(COALESCE(DR_AMT,0)) END,0) DR_07
                                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '07' THEN SUM(COALESCE(CR_AMT,0)) END,0) CR_07

                                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '08' THEN SUM(COALESCE(DR_AMT,0)) END,0) DR_08
                                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '08' THEN SUM(COALESCE(CR_AMT,0)) END,0) CR_08

                                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '09' THEN SUM(COALESCE(DR_AMT,0)) END,0) DR_09
                                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '09' THEN SUM(COALESCE(CR_AMT,0)) END,0) CR_09

                                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '10' THEN SUM(COALESCE(DR_AMT,0)) END,0) DR_10
                                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '10' THEN SUM(COALESCE(CR_AMT,0)) END,0) CR_10

                                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '11' THEN SUM(COALESCE(DR_AMT,0)) END,0) DR_11
                                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '11' THEN SUM(COALESCE(CR_AMT,0)) END,0) CR_11

                                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '12' THEN SUM(COALESCE(DR_AMT,0)) END,0) DR_12
                                      , COALESCE(CASE SUBSTRING(DATE,6,2) WHEN '12' THEN SUM(COALESCE(CR_AMT,0)) END,0) CR_12

                                  FROM GADMIN.ACCOU1 A
                                 WHERE 1 = 1
                                   AND A.DATE BETWEEN IN_FROMDATE AND IN_TODATE
                                GROUP BY ACC_CD, ACC_NM, MANAGE_CD_1, MANAGE_ITEM_1,  MANAGE_CD_2, MANAGE_ITEM_2, SUBSTRING(DATE,6,2)
                                UNION ALL
                                SELECT ACC_CD, ACC_NM, MANAGE_1 AS MANAGE_CD_1, ITEM_1 AS MANAGE_ITEM_1,  MANAGE_2 AS MANAGE_CD_2, ITEM_2 AS MANAGE_ITEM_2,
                                        DR_00,
                                        CR_00,
                                        0 AS DR_01,
                                        0 AS CR_01,
                                        0 AS DR_02,
                                        0 AS CR_02,
                                        0 AS DR_03,
                                        0 AS CR_03,
                                        0 AS DR_04,
                                        0 AS CR_04,
                                        0 AS DR_05,
                                        0 AS CR_05,
                                        0 AS DR_06,
                                        0 AS CR_06,
                                        0 AS DR_07,
                                        0 AS CR_07,
                                        0 AS DR_08,
                                        0 AS CR_08,
                                        0 AS DR_09,
                                        0 AS CR_09,
                                        0 AS DR_10,
                                        0 AS CR_10,
                                        0 AS DR_11,
                                        0 AS CR_11,
                                        0 AS DR_12,
                                        0 AS CR_12
                                FROM SESSION.TRADEKEY_TEMP
                                WHERE 1 =1
                                  AND NOT ( DR_00 = 0 AND CR_00 = 0)
                              ) A
                          WHERE 1 = 1
                            AND COALESCE(A.MANAGE_CD_1,'') != ''
                            AND COALESCE(A.MANAGE_CD_2,'') != ''
                     ) A,
                       (
                            SELECT MANAGE_CD AS MANAGE_CD_1, MANAGE_ITEM AS MANAGE_ITEM_1, DETAIL_CD AS MANAGE_CD_2, DETAIL_ITEM AS MANAGE_ITEM_2 FROM GADMIN.BSACC8
                            UNION ALL
                            SELECT '300' AS MANAGE_CD_1, '매입처' AS MANAGE_ITEM_1, SANGHO_CD AS MANAGE_CD_2, SANGHO AS MANAGE_ITEM_2 FROM GADMIN.BSTRADE
                            UNION ALL
                            SELECT '400' AS MANAGE_CD_1, '매출처' AS MANAGE_ITEM_1, SANGHO_CD AS MANAGE_CD_2, SANGHO AS MANAGE_ITEM_2 FROM GADMIN.BSTRADE
                       ) C
                   WHERE 1 = 1
                     AND A.MANAGE_CD_1 = C.MANAGE_CD_1
                     AND A.MANAGE_CD_2 = C.MANAGE_CD_2
                     AND A.ACC_CD < '4000000'
                    GROUP BY A.ACC_CD, A.ACC_NM, A.MANAGE_CD_1, C.MANAGE_ITEM_1,  A.MANAGE_CD_2, C.MANAGE_ITEM_2
        ) A   LEFT OUTER JOIN GADMIN.BSACC2 B ON (A.ACC_CD = B.ACC_CD)
        ORDER BY A.ACC_CD;--

--이월정보 넣기
    /*
    IF V_CNT > 0 THEN


        -- 전기이월 넣기
        UPDATE GADMIN.TRADEKYE A
            SET A.DR_00 = B.DR_00, A.CR_00 = B.CR_00
          FROM  SESSION.TRADEKEY_TEMP B
         WHERE 1 = 1
            AND A.ACC_CD = B.ACC_CD
            AND A.ACC_NM = B.ACC_NM
            AND A.MANAGE_1 = B.MANAGE_1
            --AND A.ITEM_1 = B.ITEM_1
            AND A.MANAGE_2 = B.MANAGE_2
            --AND A.ITEM_2 = B.ITEM_2
            AND A.YEAR = B.YEAR;--

     END IF;--
     */

END P1;--

P2: BEGIN

    DECLARE CURSOR_TEMP CURSOR WITH RETURN FOR
    SELECT *
      FROM GADMIN.HAPJAN
    WHERE 1 = 1
      AND YEAR = IN_GISU
    ORDER BY ACC_CD;--

    OPEN CURSOR_TEMP;--

--    DECLARE CURSOR_TEMP1 CURSOR WITH RETURN FOR
--    SELECT *
--      FROM TRADEKYE
--    WHERE 1 = 1
--      AND YEAR = IN_GISU
--    ORDER BY ACC_CD;--
--
--    OPEN CURSOR_TEMP1;--

END P2;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN1501_UPDATE_2"
(IN IN_GISU VARCHAR(3), IN_NEXT_GISU VARCHAR(3), IN IN_USER_ID VARCHAR(25))
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE   SQLSTATE          CHAR(5) DEFAULT '00000';--
    DECLARE   V_CNT              INTEGER DEFAULT 0;--
    DECLARE   V_DANGGI           DECIMAL(20,5) DEFAULT 0;--
    DECLARE   V_FROMDATE         VARCHAR(10) DEFAULT '';--
    DECLARE   V_TODATE           VARCHAR(10) DEFAULT '';--
    DECLARE   V_PRE_FROMDATE     VARCHAR(10) DEFAULT '';--
    DECLARE   V_PRE_TODATE       VARCHAR(10) DEFAULT '';--

P1: BEGIN
    SELECT COUNT(*) INTO V_CNT
      FROM GADMIN.HAPJAN
     WHERE YEAR = IN_NEXT_GISU;--

    IF V_CNT > 0 THEN
        --UPDATE GADMIN.HAPJAN
        --   SET DR_00 = 0, CR_00 = 0
        -- WHERE YEAR = IN_NEXT_GISU;--
        DELETE GADMIN.HAPJAN
        WHERE YEAR = IN_NEXT_GISU;--
    END IF;--

     --당기기간 구하기
    SELECT START, TERMINATION INTO V_FROMDATE, V_TODATE
      FROM GADMIN.BSACC9
     WHERE GISU = IN_GISU;--

    --전기기간 구하기
    SELECT START, TERMINATION INTO V_PRE_FROMDATE, V_PRE_TODATE
      FROM GADMIN.BSACC9
     WHERE GISU = LPAD(INTEGER(IN_GISU) - 1,3,'0');--

    --당기순이익 구하기 (손익계산서 실행)
    CALL "GADMIN"."SP_FIN1101_TAB02_SELECT"(V_FROMDATE, V_TODATE, V_PRE_FROMDATE, V_PRE_TODATE, '');--

    SELECT S.CU_TOT INTO V_DANGGI
      FROM GADMIN.EBUS_FIN_INCOME S
     WHERE S.ACC_CD = '7300909';--

    INSERT INTO GADMIN.HAPJAN
           (YEAR, ACC_CD, ACC_NM, DRCR_GB, MANAGE_ITEM, DR_00, CR_00, DR_01, CR_01, DR_02, CR_02, DR_03, CR_03, DR_04, CR_04, DR_05, CR_05, DR_06, CR_06, DR_07, CR_07, DR_08, CR_08, DR_09, CR_09, DR_10, CR_10, DR_11, CR_11, DR_12, CR_12, DR_JANAEK, CR_JANAEK )
    SELECT IN_NEXT_GISU, A.ACC_CD, A.ACC_NM, A.DRCR_GB, MANAGE_ITEM,
             CASE B.DRCR_GB WHEN '차변' THEN (DR_00+DR_01+DR_02+DR_03+DR_04+DR_05+DR_06+DR_07+DR_08+DR_09+DR_10+DR_11+DR_12) - (CR_00+CR_01+CR_02+CR_03+CR_04+CR_05+CR_06+CR_07+CR_08+CR_09+CR_10+CR_11+CR_12) ELSE 0 END AS DR_00 ,
             CASE B.DRCR_GB WHEN '대변' THEN (CR_00+CR_01+CR_02+CR_03+CR_04+CR_05+CR_06+CR_07+CR_08+CR_09+CR_10+CR_11+CR_12) - (DR_00+DR_01+DR_02+DR_03+DR_04+DR_05+DR_06+DR_07+DR_08+DR_09+DR_10+DR_11+DR_12) ELSE 0 END AS CR_00,
            0 AS DR_01, 0 AS DR_02, 0 AS DR_03, 0 AS DR_04, 0 AS DR_05, 0 AS DR_06, 0 AS DR_07, 0 AS DR_08, 0 AS DR_09, 0 AS DR_10, 0 AS DR_11, 0 AS DR_12, 0 AS DR_JANAEK,
            0 AS CR_01, 0 AS CR_02, 0 AS CR_03, 0 AS CR_04, 0 AS CR_05, 0 AS CR_06, 0 AS CR_07, 0 AS CR_08, 0 AS CR_09, 0 AS CR_10, 0 AS CR_11, 0 AS CR_12, 0 AS CR_JANAEK
       FROM GADMIN.HAPJAN A, GADMIN.BSACC2 B
      WHERE 1 = 1
         AND A.ACC_CD = B.ACC_CD
         AND YEAR = IN_GISU ;--

    --이월이익잉여금 합산(당기순이익)
    UPDATE GADMIN.HAPJAN
       SET CR_00 = CR_00 + V_DANGGI
     WHERE YEAR = IN_NEXT_GISU
       AND ACC_CD = '3300901';--

    SELECT COUNT(*) INTO V_CNT
      FROM GADMIN.TRADEKYE
     WHERE YEAR = IN_NEXT_GISU;--

    IF V_CNT > 0 THEN

        DELETE GADMIN.TRADEKYE
        WHERE YEAR = IN_NEXT_GISU;--

    END IF;--

    INSERT INTO GADMIN.TRADEKYE
           ( YEAR, ACC_CD, ACC_NM, MANAGE_1, ITEM_1, MANAGE_2, ITEM_2, DRCR_GB, DR_00, CR_00, DR_01, CR_01, DR_02, CR_02, DR_03, CR_03, DR_04, CR_04, DR_05, CR_05, DR_06, CR_06, DR_07, CR_07, DR_08, CR_08, DR_09, CR_09, DR_10, CR_10, DR_11, CR_11, DR_12, CR_12, DR_JANAEK, CR_JANAEK )
    SELECT IN_NEXT_GISU, A.ACC_CD, A.ACC_NM, MANAGE_1, ITEM_1, MANAGE_2, ITEM_2, A.DRCR_GB,
             CASE B.DRCR_GB WHEN '차변' THEN (DR_00+DR_01+DR_02+DR_03+DR_04+DR_05+DR_06+DR_07+DR_08+DR_09+DR_10+DR_11+DR_12) - (CR_00+CR_01+CR_02+CR_03+CR_04+CR_05+CR_06+CR_07+CR_08+CR_09+CR_10+CR_11+CR_12) ELSE 0 END AS DR_00 ,
             CASE B.DRCR_GB WHEN '대변' THEN (CR_00+CR_01+CR_02+CR_03+CR_04+CR_05+CR_06+CR_07+CR_08+CR_09+CR_10+CR_11+CR_12) - (DR_00+DR_01+DR_02+DR_03+DR_04+DR_05+DR_06+DR_07+DR_08+DR_09+DR_10+DR_11+DR_12) ELSE 0 END AS CR_00,
            0 AS DR_01, 0 AS DR_02, 0 AS DR_03, 0 AS DR_04, 0 AS DR_05, 0 AS DR_06, 0 AS DR_07, 0 AS DR_08, 0 AS DR_09, 0 AS DR_10, 0 AS DR_11, 0 AS DR_12, 0 AS DR_JANAEK,
            0 AS CR_01, 0 AS CR_02, 0 AS CR_03, 0 AS CR_04, 0 AS CR_05, 0 AS CR_06, 0 AS CR_07, 0 AS CR_08, 0 AS CR_09, 0 AS CR_10, 0 AS CR_11, 0 AS CR_12, 0 AS CR_JANAEK
       FROM GADMIN.TRADEKYE A, GADMIN.BSACC2 B
      WHERE 1 = 1
         AND A.ACC_CD = B.ACC_CD
         AND YEAR = IN_GISU ;--

END P1;--

P2: BEGIN

    DECLARE CURSOR_TEMP CURSOR WITH RETURN FOR
    SELECT *
      FROM GADMIN.HAPJAN
    WHERE 1 = 1
      AND YEAR = IN_NEXT_GISU
    ORDER BY ACC_CD;--

    OPEN CURSOR_TEMP;--
END P2;--
END MAIN@
CREATE OR REPLACE PROCEDURE "GADMIN"."GADMIN.SP_FIN1601_TAB01_PRINT"
(
    IN IN_USER_ID VARCHAR(25)
)
  DYNAMIC RESULT SETS 1
  LANGUAGE SQL

MAIN: BEGIN

    DECLARE SQLSTATE CHAR(5) DEFAULT '00000';--
    P1: BEGIN

		DECLARE CURSOR_ACC CURSOR WITH RETURN FOR
		SELECT *
          FROM GADMIN.BSACC2
         ORDER BY ACC_CD;--
	OPEN CURSOR_ACC;--
   END P1;--
END MAIN@