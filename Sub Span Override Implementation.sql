DROP TABLE IF EXISTS #MAINSPANS
DROP TABLE IF EXISTS #SUBSPANS
CREATE TABLE #MAINSPANS (
	Id INT
	,startdate DATE
	,enddate DATE
	,Descrip varchar(50)
	)

CREATE TABLE #SUBSPANS (
	Id INT
	,MainSpanId INT
	,startdate DATE
	,enddate DATE
	,Descrip varchar(50)
	)

INSERT INTO #MAINSPANS(id,startdate,enddate,Descrip)
VALUES
(1,'2024-01-01','2025-01-01','Main')

INSERT INTO #SUBSPANS(Id,MainSpanId,startdate,enddate,Descrip)
VALUES 
(1,1,'2024-03-01','2024-03-31','SubA')
,(2,1,'2024-06-01','2025-01-01','SubB')

;WITH all_dates AS
(SELECT 'sub' AS src,sub.MainSpanId,sub.Descrip,sub.startdate,sub.enddate,x.date_point,x.type

FROM #SUBSPANS sub
CROSS APPLY
	 (VALUES (startdate,1),(DATEADD(DAY,1,enddate),-1))x(date_point,type)

UNION ALL

SELECT 'main' AS src, t.Id,t.Descrip,t.startdate,t.enddate,x.date_point,x.type
FROM #MAINSPANS t
CROSS APPLY
	 (VALUES (t.startdate,1),(dateadd(day,1,t.enddate),-1))x(date_point,type)
)

SELECT g.MainSpanId, g.Descrip, g.Start_Date,g.end_date
FROM  
(
SELECT  
	MainSpanId,
	TYPE
        ,date_point
		,LAG(date_point) OVER (PARTITION BY MainSpanId ORDER BY date_point) AS Start_Date
		,DATEADD(DAY, -1, date_point) AS end_date
		,Descrip = CASE WHEN
		SUM(type) over (PARTITION BY MainSpanId,src ORDER BY date_point,TYPE 
		 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
		= 0
		THEN Descrip
		ELSE 
		MAX(CASE WHEN src = 'main' THEN Descrip END) OVER (PARTITION BY MainSpanId)
		END
		,t = SUM(type) over (PARTITION BY MainSpanId,src ORDER BY date_point,TYPE 
		 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
		 ,src
    FROM all_dates  
) g
WHERE Start_Date <= g.end_date
ORDER BY g.date_point
