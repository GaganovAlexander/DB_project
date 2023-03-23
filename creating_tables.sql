DROP TABLE purchases
DROP TABLE purchasers
DROP TABLE products
DROP TABLE providers

CREATE TABLE IF NOT EXISTS providers(
	id INTEGER PRIMARY KEY,
	title VARCHAR(100) NOT NULL,
	city VARCHAR(50) NOT NULL
);
CREATE TABLE IF NOT EXISTS purchasers(
	id INTEGER PRIMARY KEY,
	last_name VARCHAR(50) NOT NULL,
	first_name VARCHAR(50) NOT NULL,
	surname VARCHAR(50),
	current_deposit NUMERIC(7, 2) NOT NULL
);
CREATE TABLE IF NOT EXISTS products(
	id INTEGER PRIMARY KEY,
	naming VARCHAR(50) NOT NULL,
	quantity INTEGER NOT NULL,
	price NUMERIC(7, 2) NOT NULL
);
CREATE TABLE IF NOT EXISTS purchases(
	id INTEGER PRIMARY KEY,
	product_id INTEGER NOT NULL,
	provider_id INTEGER NOT NULL,
	purchaser_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	purchase_time TIMESTAMP,
	
	CONSTRAINT fk_product
      FOREIGN KEY(product_id) 
	  REFERENCES products(id),
	CONSTRAINT fk_procider
      FOREIGN KEY(provider_id) 
	  REFERENCES providers(id),
	CONSTRAINT fk_purchaser
      FOREIGN KEY(purchaser_id) 
	  REFERENCES purchasers(id)
)
