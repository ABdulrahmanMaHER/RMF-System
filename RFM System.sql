SELECT customer_id, Recency, Frequency, Monetary, r_score, fm_score,
    CASE 
        WHEN fm_score=5 and r_score=5 THEN 'champions'
        WHEN fm_score=4 and r_score=5 THEN 'champions'
        WHEN fm_score=5 and r_score=4 THEN 'champions'
        WHEN fm_score=2 and r_score=5 THEN 'potiential loyalists'
        WHEN fm_score=2 and r_score=4 THEN 'potiential loyalists'
        WHEN fm_score=3 and r_score=3 THEN 'potiential loyalists'
        WHEN fm_score=3 and r_score=4 THEN 'potiential loyalists'
        WHEN fm_score=3 and r_score=5 THEN 'loyal customer'
        WHEN fm_score=4 and r_score=4 THEN 'loyal customer'
        WHEN fm_score=2 and r_score=4 THEN 'loyal customer'
        WHEN fm_score=5 and r_score=3 THEN 'loyal customer'
        WHEN fm_score=4 and r_score=3 THEN 'loyal customer'
        WHEN fm_score=1 and r_score=5 THEN 'recent customers'
        WHEN fm_score=1 and r_score=4 THEN 'promising'
        WHEN fm_score=1 and r_score=3 THEN 'promising'
        WHEN fm_score=2 and r_score=3 THEN 'need attention'
        WHEN fm_score=3 and r_score=2 THEN 'need attention'
        WHEN fm_score=2 and r_score=2 THEN 'need attention'
        WHEN fm_score=5 and r_score=2 THEN 'at risk'
        WHEN fm_score=4 and r_score=2 THEN 'at risk'
        WHEN fm_score=3 and r_score=1 THEN 'at risk'
        WHEN fm_score=5 and r_score=1 THEN 'cant lose them'
        WHEN fm_score=4 and r_score=1 THEN 'cant lose them'
        WHEN fm_score=1 and r_score=1 THEN 'lost'
        WHEN fm_score=2 and r_score=1 THEN 'hibernating'
        WHEN fm_score=1 and r_score=2 THEN 'hibernating'
        
    END AS customer_segment
FROM (
    SELECT customer_id, Recency, Frequency, Monetary, r_score, NTILE(5) OVER (ORDER BY fm_score ) AS fm_score
    FROM (
        SELECT customer_id, Recency, Frequency, Monetary, round(avg(Frequency) over (partition by customer_id)+ avg(Monetary) over (partition by customer_id)) as fm_score,
        NTILE(5) OVER (ORDER BY Recency desc) AS r_score
        FROM (
            SELECT DISTINCT customer_id, 
            ROUND((SELECT MAX(TO_DATE(invoicedate, 'mm.dd.yyyy.hh24.mi.ss')) FROM tableretail) - MAX(TO_DATE(invoicedate, 'mm.dd.yyyy.hh24.mi.ss')) OVER (PARTITION BY customer_id)) AS Recency,
            COUNT(*) OVER (PARTITION BY customer_id) AS Frequency,
            SUM(price) OVER (PARTITION BY customer_id) AS Monetary
            FROM tableretail
        ) 
    ) 
) 
ORDER BY customer_id;