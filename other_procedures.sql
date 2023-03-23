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


CREATE OR REPLACE PROCEDURE
top_up_quantity(product_id INTEGER, amount NUMERIC(7, 2))
AS $$
BEGIN
    IF (NOT product_id IN (SELECT id FROM products)) THEN
        RAISE EXCEPTION 'Товара с id % не существует', product_id;
    END IF;
    IF amount < 0 THEN
        RAISE EXCEPTION 'Количество поставок не может быть меньше 0';
    END IF;

    UPDATE products
        SET quantity = quantity + amount
        WHERE products.id = product_id;
    RAISE INFO 'Поставка товара %, текущее количество на складе: %',
    (SELECT naming FROM products WHERE products.id = product_id), 
    (SELECT quantity FROM products WHERE products.id = product_id);
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE
makejob()
AS $$
BEGIN
    CALL do_purchase(3, 2, 5, 1);
    CALL top_up_deposit(5, 1000);
    CALL top_up_quantity(3, 35);
    CALL do_purchase(5, 5, 5, 2);
    CALL do_purchase(9, 6, 7, 2);
    CALL top_up_deposit(2, 3500);
    CALL do_purchase(1, 1, 2, 2);
    CALL do_purchase(5, 3, 2, 1);
    CALL do_purchase(8, 3, 9, 2);
    CALL top_up_quantity(2, 10);
    CALL top_up_quantity(1, 53);
    CALL top_up_deposit(1, 100);
    CALL top_up_quantity(5, 32);
    CALL do_purchase(7, 3, 1, 10);
    CALL do_purchase(11, 6, 1, 3);
END
$$ LANGUAGE plpgsql;