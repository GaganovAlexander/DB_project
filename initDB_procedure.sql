-- Процедура автоматического заполнения таблиц пробными данными
CREATE OR REPLACE PROCEDURE initDB()
AS $$
BEGIN
    -- Перед заполнением таблицы очищаются, начиная с тех, которые имеют внешние ключи
	DELETE FROM supplies;
    DELETE FROM purchases;
	DELETE FROM providers;
    DELETE FROM products;
    DELETE FROM purchasers;
	RAISE INFO 'Таблицы purchases, providers, products, purchasers и supplies были очищены';

	-- Заполняются они, в обратом порядке, сначала те, что без внешних ключей
	CALL providers_insert('Intel', 'Santa Clara');
	CALL providers_insert('AMD', 'Santa Clara');
	CALL providers_insert('MSI', 'Zhonghe');
	CALL providers_insert('GIGABYTE', 'Xindian District');
	CALL providers_insert('Palit', 'Taipei');
	CALL providers_insert('DEEPCOOL', 'Beijing');
	CALL providers_insert('Corsair', 'Milpitas');
	
	CALL products_insert('Core i5-12400F OEM', 341, 187.18);
	CALL products_insert('Ryzen 5 5600x OEM', 256, 188.51);
	CALL products_insert('Ryzen 7 5800X OEM', 137, 286.02);
	CALL products_insert('Core i3-12100F OEM', 96, 110.50);
	CALL products_insert('GeForce RTX 4090', 587, 1975.94);
	CALL products_insert('GeForce RTX 370 Ti', 365, 753.97);
	CALL products_insert('AMD Radeon RX 6600', 53, 337.98);
	CALL products_insert('GeForce GTX 1660 SUPER', 193, 266.48);
	CALL products_insert('DQ750', 134, 107.89);
	CALL products_insert('VX PLUS 500W', 95, 31.85);
	CALL products_insert('B550 AORUS ELITE V2', 152, 168.99);
	
	CALL purchasers_insert('Гаганов', 'Александр', 99999.99, 'Александрович');
	CALL purchasers_insert('Кочетков', 'Максим', 300.00, 'Алексеевич');
	CALL purchasers_insert('Гинда', 'Данила', 76543.21, 'Александрович');
	CALL purchasers_insert('Воронин', 'Артемий', 1.50, 'Андреевич');
	CALL purchasers_insert('Петров', 'Артём', 299.99, 'Георгиевич');
	CALL purchasers_insert('Бердымухамедов', 'Гурбангулы', 777.77);
	CALL purchasers_insert('Ким', 'Чен Ын', 687.09);
	CALL purchasers_insert('Трамп', 'Дональд', 798.67);
	CALL purchasers_insert('Бибер', 'Джастин', 906.89);
END
$$ LANGUAGE plpgsql;