CREATE OR REPLACE FUNCTION
products_suplies_and_sales(start_time TIMESTAMP, stop_time TIMESTAMP) RETURNS TABLE
(
	naming VARCHAR(50), 
	title_or_full_name VARCHAR(153), 
	purchase_or_suply_time TIMESTAMP,
	amount INTEGER, 
	cost NUMERIC
)
AS $$ 
BEGIN
RETURN QUERY SELECT 
	p.naming, 
	t.title_or_full_name,
	t.purchase_or_suply_time,
	t.amount,
	t.amount * p.price AS cost
FROM 
	(
		SELECT 
            purchases.product_id, 
            CAST(p.last_name || ' ' || p.first_name || ' ' || coalesce(p.surname, '') AS VARCHAR(153)) AS title_or_full_name,
            purchases.purchase_time AS purchase_or_suply_time, 
            purchases.amount 
        FROM purchases
		JOIN purchasers p ON p.id = purchaser_id
		UNION
		SELECT 
        s.product_id, 
        CAST(pv.title AS VARCHAR(153)), 
        s.supply_time, 
        -s.amount 
        FROM supplies s
		JOIN providers pv ON pv.id = s.provider_id
	) t
JOIN products p ON p.id = t.product_id
WHERE 
	t.purchase_or_suply_time >= start_time
	AND 
	t.purchase_or_suply_time <= stop_time;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION
products_rating(start_time TIMESTAMP, stop_time TIMESTAMP) RETURNS TABLE
(
	naming VARCHAR(50), 
	amount BIGINT, 
	num_of_purchasers BIGINT,
	rating BIGINT
)
AS $$ 
BEGIN
RETURN QUERY SELECT  
    p.naming, 
    sum(ps.amount) amount, 
    count(distinct ps.purchaser_id) num_of_purchasers,
    count(*) rating
FROM purchases ps
JOIN products p ON p.id = ps.product_id
WHERE 
	purchase_time >= start_time 
	AND 
	purchase_time <= stop_time
GROUP BY p.naming
ORDER BY rating desc;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION
products_turnover(start_time TIMESTAMP, stop_time TIMESTAMP) RETURNS TABLE
(
	naming VARCHAR(50), 
	amount_of_supplies BIGINT, 
	providers_list TEXT,
	sales_amount BIGINT,
	purchasers_list TEXT,
	profit NUMERIC
)
AS $$ 
BEGIN
RETURN QUERY SELECT  
    t.naming, 
    SUM(t.amount_of_supplies) amount_of_supplies, 
    STRING_AGG(t.title, ', ') providers_list, 
    SUM(t.sales_amount) sales_amount, 
    STRING_AGG(t.full_name, ', ') purchasers_list,
	SUM(t.profit) profit
FROM (
SELECT 
    p.naming, 
    NULL title, 
	pr.last_name || ' ' || pr.first_name || ' ' || coalesce(pr.surname, '') full_name, 
    0 amount_of_supplies, 
    ps.amount sales_amount,
    ps.amount * p.price profit,
	ps.purchase_time ps_time
FROM purchases ps
JOIN products p ON p.id = ps.product_id
JOIN purchasers pr ON pr.id = ps.purchaser_id
UNION
SELECT 
    p.naming, 
    pv.title, 
    NULL,  
    -s.amount, 
    0,
    -(s.amount * p.price),
	supply_time
FROM supplies s
JOIN products p ON p.id = s.product_id
JOIN providers pv ON pv.id = s.provider_id
) t
WHERE 
	t.ps_time >= start_time
	AND 
	t.ps_time <= stop_time
GROUP BY t.naming;
END;
$$ LANGUAGE plpgsql;