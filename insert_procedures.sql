CREATE OR REPLACE PROCEDURE 
providers_insert(title VARCHAR(100), city VARCHAR(50))
AS $$
DECLARE
	id INTEGER;
BEGIN
	IF ((SELECT MAX(providers.id) from providers) > 0) THEN
		id := (SELECT MAX(providers.id) from providers) + 1;
	ELSE
		id := 1;
	END IF;

	INSERT INTO providers VALUES(id, title, city);
	RAISE INFO 'Создан объект поставщика с атрибутами: id: %, название: %, город: %.',
	id, title, city;
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE 
purchasers_insert(last_name VARCHAR(50), first_name VARCHAR(50), current_deposit NUMERIC(7, 2), surname VARCHAR(50) DEFAULT NULL)
AS $$
DECLARE
	id INTEGER;
BEGIN
	IF ((SELECT MAX(purchasers.id) from purchasers) > 0) THEN
		id := (SELECT MAX(purchasers.id) from purchasers) + 1;
	ELSE
		id := 1;
	END IF;

	IF current_deposit >= 0 THEN
		INSERT INTO purchasers VALUES(id, last_name, first_name, surname, current_deposit);
		RAISE INFO 'Был создан объект покупателя с атрибутами: id: %, ФИО: % % %, текущий счёт: %.',
		id, last_name, first_name, surname, current_deposit;
	ELSE
		RAISE EXCEPTION 'Депозит покупателя не может быть меньше 0';
	END IF;
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE 
products_insert(naming VARCHAR(50), quantity INTEGER, price NUMERIC(7, 2))
AS $$
DECLARE
    id INTEGER;
BEGIN
    IF ((SELECT MAX(products.id) from products) > 0) THEN
		id := (SELECT MAX(products.id) from products) + 1;
	ELSE
		id := 1;
	END IF;

    IF quantity < 0 THEN
		RAISE EXCEPTION 'Количество не может быть меньше 0';
	END IF;
	IF price < 0 THEN
		RAISE EXCEPTION 'Цена не может быть меньше 0';
	END IF;

	INSERT INTO products VALUES(id, naming, quantity, price);
	RAISE INFO 'Был создан объект продукта с артибутами: id: %, название: %, количество: %, цена: %',
	id, naming, quantity, price;
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE 
do_purchase(product_id INTEGER, provider_id INTEGER, purchaser_id INTEGER, amount INTEGER, purchase_time TIMESTAMP DEFAULT NULL)
AS $$
DECLARE
	cost INTEGER;
	id INTEGER;
BEGIN
	IF ((SELECT MAX(purchases.id) from purchases) > 0) THEN
		id := (SELECT MAX(purchases.id) from purchases) + 1;
	ELSE
		id := 1;
	END IF;

	IF (amount <= 0) THEN
		RAISE EXCEPTION 'Количество купленого товара должно быть больше 0';
	END IF;
	IF (SELECT current_deposit FROM purchasers WHERE purchasers.id = purchaser_id) < cost THEN
		RAISE EXCEPTION 'У покупателя недостаточно денег';
	END IF;
	IF (SELECT quantity FROM products WHERE products.id = product_id) < amount THEN
		RAISE EXCEPTION 'На складе недостаточно товара';
	END IF;
	IF purchase_time IS NULL THEN
		purchase_time := current_timestamp;
	END IF;
	IF purchase_time > current_timestamp THEN
		RAISE EXCEPTION 'Время покупки не может превышать текущее';
	END IF;

	cost := (SELECT price FROM products WHERE products.id = product_id) * amount;
	UPDATE purchasers 
		SET current_deposit = current_deposit - cost
		WHERE purchasers.id = purchaser_id;
	UPDATE products
		SET quantity = quantity - amount
		WHERE products.id = product_id;
	INSERT INTO purchases VALUES(id, product_id, provider_id, purchaser_id, amount, purchase_time);
	RAISE INFO 'Покупатель, %, совершил покупку % % в количестве %шт, %. Общая соимость: %$, текущий баланс покупателя: %, продукта осталось на складе: %',
	(SELECT last_name || ' ' ||  first_name || ', с id: ' || CAST(purchasers.id AS VARCHAR(10)) FROM purchasers WHERE purchasers.id = purchaser_id), 
	(SELECT title FROM providers WHERE providers.id = provider_id), (SELECT naming FROM products WHERE products.id = product_id), amount, purchase_time,
	cost, (SELECT current_deposit FROM purchasers WHERE purchasers.id = purchaser_id), (SELECT quantity FROM products WHERE products.id = product_id);
END
$$ LANGUAGE plpgsql;		
