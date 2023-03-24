CREATE OR REPLACE FUNCTION
products_turnover() RETURNS TABLE(product_naming VARCHAR(50), f2 text)
AS $$ 
SELECT naming from products
$$
LANGUAGE SQL;
