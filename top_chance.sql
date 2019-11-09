WITH cte
AS 
(
	SELECT id, event_id, uname, email, CASE WHEN event_id = 5/*TODO*/ THEN 1 ELSE  present END AS present, winner	
	FROM public.pg_day
)
SELECT 
	max(d.uname), 
    d.email,
    SUM
    (    
    	CASE 
        	WHEN d.present IS NULL THEN -1
            WHEN d.present IS NOT NULL AND d.winner IS NOT NULL THEN 0
            WHEN d.present IS NOT NULL AND d.winner IS NULL THEN 1
            ELSE 0
		END
	) coeff 
FROM cte d    
GROUP BY d.email     
ORDER BY 3 DESC 
