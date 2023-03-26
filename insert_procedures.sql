-- Процедура добавления продавца
CREATE OR REPLACE PROCEDURE 
providers_insert(title VARCHAR(100), city VARCHAR(50))
AS $$
DECLARE
	id INTEGER;
BEGIN
	-- id реализовано в виде простого целого числа, а автоприбавление 
	-- идёт через реализацию процедуры. (Так во всех таблицах)
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

-- Процедура добавления покупателя
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

	-- Так как на считу у покупателя не может быть отрицательный баланс - мы это проверяем
	-- Далее то, на что проверятся данные, можно будет узнать из текста вызова исключения
	IF current_deposit >= 0 THEN
		INSERT INTO purchasers VALUES(id, last_name, first_name, surname, current_deposit);
		RAISE INFO 'Был создан объект покупателя с атрибутами: id: %, ФИО: % % %, текущий счёт: %.',
		id, last_name, first_name, surname, current_deposit;
	-- Если введены неправельные данные - вызывается исключение
	ELSE
		RAISE EXCEPTION 'Депозит покупателя не может быть меньше 0';
	END IF;
END
$$ LANGUAGE plpgsql;

-- Процедура добавления продукта
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

	-- Это блок проверки введённых данных, если они неправельные - то вызывается исключение и процедура завершается
    IF quantity < 0 THEN
		RAISE EXCEPTION 'Количество не может быть меньше 0';
	END IF;
	IF price < 0 THEN
		RAISE EXCEPTION 'Цена не может быть меньше 0';
	END IF;

	-- В случае, если исключений не было - производится вставка
	INSERT INTO products VALUES(id, naming, quantity, price);
	RAISE INFO 'Был создан объект продукта с артибутами: id: %, название: %, количество: %, цена: %',
	id, naming, quantity, price;
END
$$ LANGUAGE plpgsql;
