# REQUEST 01:

SELECT DISTINCT
    market
FROM
    dim_customer
WHERE
    customer = 'AtliQ exclusive'
        AND region = 'APAC'
;
---------------------------------------------------------------------------------------------------------------------------------------
# Request 02:

WITH cte1 AS (
SELECT count(DISTINCT product_code) AS unique_product_2020
FROM fact_sales_monthly
WHERE fiscal_year = 2020
), 
cte2 AS (
SELECT count(DISTINCT product_code) AS unique_product_2021
FROM fact_sales_monthly
WHERE fiscal_year = 2021 
)
SELECT 
unique_product_2020,
unique_product_2021,
(unique_product_2021-unique_product_2020)*100/unique_product_2020 AS pct_change
FROM cte1
CROSS JOIN cte2
;
---------------------------------------------------------------------------------------------------------------------------------------
# REQUEST 03:

SELECT 
    segment, COUNT(DISTINCT product_code) AS Product_count
FROM
    dim_product
GROUP BY segment
ORDER BY Product_count DESC
;
---------------------------------------------------------------------------------------------------------------------------------------
# REQUEST 04:

	WITH unique_products AS(
	SELECT
	p.segment, 
	count(DISTINCT(CASE WHEN fiscal_year = 2020 THEN s.product_code END)) AS product_count_2020,
	count(DISTINCT(CASE WHEN fiscal_year = 2021 THEN s.Product_code END)) AS product_count_2021
	FROM fact_sales_monthly s
	JOIN dim_product p
	ON s.product_code = p.product_code
	GROUP BY p.segment
	)
	SELECT 
	*,
	product_count_2021-product_count_2020 AS difference
	FROM unique_products
	ORDER BY difference DESC
	;
---------------------------------------------------------------------------------------------------------------------------------------
# REQUEST 05:

(SELECT 
    p.product_code, p.product, m.manufacturing_cost
FROM
    dim_product p
        JOIN
    fact_manufacturing_cost m ON p.product_code = m.product_code
ORDER BY m.manufacturing_cost DESC
LIMIT 1) UNION (SELECT 
    p.product_code, p.product, m.manufacturing_cost
FROM
    dim_product p
        JOIN
    fact_manufacturing_cost m ON p.product_code = m.product_code
ORDER BY m.manufacturing_cost ASC
LIMIT 1)
;
---------------------------------------------------------------------------------------------------------------------------------------
# REQUEST 06:

SELECT 
    i.customer_code,
    c.customer,
    ROUND(AVG(i.pre_invoice_discount_pct) * 100, 2) AS avg_dis_pct
FROM
    fact_pre_invoice_deductions i
        JOIN
    dim_customer c USING (customer_code)
WHERE
    fiscal_year = 2021
        AND c.market = 'india'
GROUP BY i.customer_code , c.customer
ORDER BY avg_dis_pct DESC
LIMIT 5;
---------------------------------------------------------------------------------------------------------------------------------------
# REQUEST 07:

SELECT 
    MONTHNAME(s.date) AS MONTH,
    s.fiscal_year,
    ROUND(SUM(g.gross_price * sold_quantity), 2) AS gross_sales_amt
FROM
    fact_sales_monthly s
        JOIN
    dim_customer c USING (customer_code)
        JOIN
    fact_gross_price g USING (product_code)
WHERE
    customer = 'atliq exclusive'
GROUP BY MONTHNAME(s.date) , s.fiscal_year
ORDER BY fiscal_year; 
---------------------------------------------------------------------------------------------------------------------------------------
# REQUEST 08:

SELECT 
    CASE
        WHEN MONTH(date) IN (9 , 10, 11) THEN 'Q1'
        WHEN MONTH(date) IN (12 , 01, 02) THEN 'Q2'
        WHEN MONTH(date) IN (03 , 04, 05) THEN 'Q3'
        ELSE 'Q4'
    END AS Quarters,
    SUM(sold_quantity) AS total_sold_qty
FROM
    fact_sales_monthly
WHERE
    fiscal_year = 2020
GROUP BY Quarters
ORDER BY total_sold_qty DESC;
---------------------------------------------------------------------------------------------------------------------------------------
# REQUEST 09:

WITH x AS (SELECT c.channel, 
round(sum(g.gross_price*s.sold_quantity)/100000,2) AS gross_sales_mln 
FROM fact_sales_monthly s  
JOIN dim_customer c  USING(customer_code) 
JOIN fact_gross_price g USING(product_code) 
WHERE s.fiscal_year=2021 
GROUP BY c.channel) 
SELECT CHANNEL, gross_sales_mln, 
round((gross_sales_mln/(SELECT sum(gross_sales_mln) FROM x))*100,2) 
AS pct FROM x  
ORDER BY gross_sales_mln DESC;
---------------------------------------------------------------------------------------------------------------------------------------
# Request 10:

WITH  x AS  
( 
SELECT P.division, S.product_code, P.product, SUM(S.sold_quantity) AS Total_sold_quantity, 
RANK() OVER(PARTITION BY P.division ORDER BY SUM(S.sold_quantity)  DESC) AS 'Rank_Order'  
FROM dim_product P JOIN fact_sales_monthly S 
ON P.product_code = S.product_code 
WHERE S.fiscal_year = 2021  
GROUP BY  P.division, S.product_code,  P.product) 
SELECT *  FROM x  
WHERE  Rank_Order IN (1,2,3) ORDER BY division,  Rank_Order;
