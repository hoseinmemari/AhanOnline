
--*Creating Sales table
CREATE TABLE Sales
		(SalesID INT,
		OrderID INT,
		Customer NCHAR(5),
		Product NCHAR(5),
		Date INT,
		Quantity INT,
		UnitPrice INT); 



--*inserting data in the Sales table
INSERT INTO dbo.Sales
VALUES
	(1, 1, 'C1', 'P1', 1, 2, 100),
	(2, 1, 'C1', 'P2', 1, 4, 150),
	(3, 2, 'C2', 'P2', 1, 5, 150),
	(4, 3, 'C3', 'P4', 1, 3, 550),
	(5, 4, 'C4', 'P3', 1, 1, 300),
	(6, 4, 'C4', 'P6', 1, 6, 150),
	(7, 4, 'C4', 'P4', 1, 6, 550),
	(8, 5, 'C5', 'P2', 1, 3, 150),
	(9, 5, 'C5', 'P1', 1, 6, 100),
	(10, 6, 'C2', 'P3', 2, 1, 300),
	(11, 6, 'C2', 'P4', 2, 3, 550),
	(12, 6, 'C2', 'P5', 2, 6, 400),
	(13, 6, 'C2', 'P1', 2, 4, 100),
	(14, 7, 'C4', 'P6', 2, 3, 150),
	(15, 8, 'C6', 'P3', 2, 2, 300),
	(16, 8, 'C6', 'P4', 2, 3, 550),
	(17, 9, 'C7', 'P1', 2, 5, 100),
	(18, 9, 'C7', 'P2', 2, 3, 150),
	(19, 9, 'C7', 'P3', 2, 1, 300),
	(20, 10, 'C1', 'P4', 3, 6, 550),
	(21, 11, 'C2', 'P5', 3, 3, 400),
	(22, 12, 'C8', 'P1', 3, 6, 100),
	(23, 12, 'C8', 'P3', 3, 3, 300),
	(24, 12, 'C8', 'P5', 3, 5, 400),
	(25, 13, 'C9', 'P2', 3, 2, 150);

CREATE TABLE ##ProfitRate
		(Product NCHAR(5),
		Rate DECIMAL(4,3));

INSERT INTO ##ProfitRate
VALUES
	('P1', 0.5),
	('P2', 0.25),
	('P3', 0.10),
	('P4', 0.20),
	('P5', 0.10);


--*creating the profit table
SELECT s.Product,s.UnitPrice,ISNULL(Rate,0.10) AS profitrate
INTO Profit
FROM 
##ProfitRate AS pr
FULL JOIN
(SELECT DISTINCT product, UnitPrice FROM dbo.Sales) AS s ON s.Product=pr.Product


--1- corporation's whole sale
SELECT SUM(quantity*unitprice) AS 'Whole Sale' FROM dbo.Sales

--2- number of customers
SELECT COUNT(DISTINCT Customer) AS 'Number of Customers' FROM dbo.Sales

--3- sales per product
SELECT Product,SUM(Quantity) AS 'Sum of Sold Product'
FROM dbo.Sales
GROUP BY Product


--4- customers which has at least 1 order more than 1500 
SELECT 
	Customer,
	SUM(quantity*unitprice) AS 'whole sale',
	COUNT(DISTINCT OrderID) AS 'number of orders',
	SUM(quantity) AS 'Items sold'
FROM dbo.Sales
WHERE Customer IN
	(SELECT Customer
	FROM
		(SELECT DISTINCT o.OrderID, customer, orderprice
		FROM
		dbo.Sales AS s
		INNER JOIN
		(SELECT OrderID, SUM(quantity*unitprice) AS orderprice
		FROM dbo.Sales
		GROUP BY OrderID) AS o ON s.OrderID=o.OrderID) AS ord
		WHERE orderprice>1500)
GROUP BY Customer

--5-the amount and the percentage of the profit
SELECT SUM(unitprice*ProfitRate*quantity) AS 'Profit', (SUM(quantity*ProfitRate)/SUM(quantity)) AS 'ProfitRate'
FROM
(SELECT s.Product, SUM(Quantity) Quantity, AVG(s.UnitPrice) UnitPrice, AVG(profitrate) ProfitRate
FROM 
dbo.Sales AS s
INNER JOIN
dbo.Profit AS p ON s.Product=p.Product
GROUP BY s.Product) AS ProfitPerProduct