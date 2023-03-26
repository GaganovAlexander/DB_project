-- Процедура совершения покупки
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

    -- Помимо привычной вставки, тут так же проводится изменение таблиц покупателей и продуктов
	cost := (SELECT price FROM products WHERE products.id = product_id) * amount;
	UPDATE purchasers 
		SET current_deposit = current_deposit - cost
		WHERE purchasers.id = purchaser_id;
	UPDATE products
		SET quantity = quantity - amount
		WHERE products.id = product_id;
	INSERT INTO purchases VALUES(id, product_id, provider_id, purchaser_id, amount, purchase_time);
	RAISE INFO 'Покупатель, %, совершил покупку % % в количестве %шт, время покупки: %. Общая соимость: %$, текущий баланс покупателя: %, продукта осталось на складе: %',
	(SELECT last_name || ' ' ||  first_name || ', с id: ' || CAST(purchasers.id AS VARCHAR(10)) FROM purchasers WHERE purchasers.id = purchaser_id), 
	(SELECT title FROM providers WHERE providers.id = provider_id), (SELECT naming FROM products WHERE products.id = product_id), amount, purchase_time,
	cost, (SELECT current_deposit FROM purchasers WHERE purchasers.id = purchaser_id), (SELECT quantity FROM products WHERE products.id = product_id);
END
$$ LANGUAGE plpgsql;		

-- Процедура пополнения счёта покупателя
CREATE OR REPLACE PROCEDURE
top_up_deposit(purchaser_id INTEGER, amount NUMERIC(7, 2))
AS $$
BEGIN
    IF (NOT purchaser_id IN (SELECT id from purchasers)) THEN
        RAISE EXCEPTION 'Пользователя с id % не существует', purchaser_id;
    END IF;
    IF amount < 0 THEN
        RAISE EXCEPTION 'Сумма пополнения не может быть меньше 0';
    END IF;

    UPDATE purchasers
        SET current_deposit = current_deposit + amount
        WHERE purchasers.id = purchaser_id;
    RAISE INFO 'Пользователю %, начислено %, текущий баланс: %',
    (SELECT last_name || '' || first_name || ', с id ' || CAST(id AS VARCHAR(10)) FROM purchasers WHERE purchasers.id = purchaser_id), 
    amount, (SELECT current_deposit FROM purchasers WHERE purchasers.id = purchaser_id);
END
$$ LANGUAGE plpgsql;

-- Процедура поставок товаров
CREATE OR REPLACE PROCEDURE
top_up_quantity(product_id INTEGER, provider_id INTEGER, amount INTEGER, supply_time TIMESTAMP DEFAULT NULL)
AS $$
DECLARE
    id INTEGER;
BEGIN
    IF ((SELECT MAX(supplies.id) from supplies) > 0) THEN
		id := (SELECT MAX(supplies.id) from supplies) + 1;
	ELSE
		id := 1;
	END IF;

    IF amount < 0 THEN
        RAISE EXCEPTION 'Количество поставок не может быть меньше 0';
    END IF;
    IF supply_time IS NULL THEN
        supply_time := current_timestamp;
    END IF;
    IF (supply_time > current_timestamp) THEN
        RAISE EXCEPTION 'Время поставки не может быть больше текущего';
    END IF;

    INSERT INTO supplies VALUES(id, provider_id, product_id, amount, supply_time);
    RAISE INFO 'Создан объект поставки с атрибутами: id: %, поставщик: %, количество: %, время поставки: %',
    id, (SELECT title FROM providers WHERE providers.id = provider_id), amount, supply_time;
    UPDATE products
        SET quantity = quantity + amount
        WHERE products.id = product_id;
    RAISE INFO 'Поставка товара %, текущее количество на складе: %',
    (SELECT naming FROM products WHERE products.id = product_id), 
    (SELECT quantity FROM products WHERE products.id = product_id);
END
$$ LANGUAGE plpgsql;

-- Процедура симуляции выполнения работы
CREATE OR REPLACE PROCEDURE
makejob()
AS $$
BEGIN
    CALL do_purchase(3, 2, 5, 1);
    CALL top_up_deposit(5, 1000);
    CALL top_up_quantity(3, 2, 35);
    CALL do_purchase(5, 5, 5, 2);
    CALL do_purchase(9, 6, 7, 2);
    CALL top_up_deposit(2, 3500);
    CALL do_purchase(1, 1, 2, 2);
    CALL do_purchase(5, 3, 2, 1);
    CALL do_purchase(8, 3, 9, 2);
    CALL top_up_quantity(2, 2, 10);
    CALL top_up_quantity(1, 1, 53);
    CALL top_up_deposit(1, 100);
    CALL top_up_quantity(5, 3, 32);
    CALL do_purchase(7, 3, 1, 10);
    CALL do_purchase(11, 6, 1, 3);
END
$$ LANGUAGE plpgsql;