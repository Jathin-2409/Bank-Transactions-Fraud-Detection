
-- BANK TRANSACTIONS & FRAUD DETECTION PROJECT

-- 1. Create Tables
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    city VARCHAR(50),
    join_date DATE
);

CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    customer_id INT,
    balance DECIMAL(10,2),
    open_date DATE,
    account_type VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE transactions (
    txn_id INT PRIMARY KEY,
    account_id INT,
    txn_date DATE,
    txn_type VARCHAR(20),
    amount DECIMAL(10,2),
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

-- 2. Insert Sample Data
INSERT INTO customers VALUES
(1, 'Alice Patel', 'Mumbai', '2022-02-10'),
(2, 'Rohit Singh', 'Delhi', '2021-06-25'),
(3, 'Priya Sharma', 'Pune', '2020-08-14'),
(4, 'Arjun Mehta', 'Bangalore', '2023-01-04'),
(5, 'Kavya Iyer', 'Chennai', '2022-09-12');

INSERT INTO accounts VALUES
(101, 1, 54000.00, '2022-02-10', 'Savings'),
(102, 2, 12000.00, '2021-06-25', 'Checking'),
(103, 3, 87000.00, '2020-08-14', 'Savings'),
(104, 4, 15000.00, '2023-01-04', 'Checking'),
(105, 5, 5000.00, '2022-09-12', 'Savings');

INSERT INTO transactions VALUES
(1, 101, '2023-11-01', 'Deposit', 10000),
(2, 101, '2023-11-02', 'Withdrawal', 2000),
(3, 102, '2023-11-01', 'Withdrawal', 3000),
(4, 102, '2023-11-03', 'Deposit', 15000),
(5, 103, '2023-11-01', 'Deposit', 5000),
(6, 103, '2023-11-02', 'Deposit', 12000),
(7, 104, '2023-11-03', 'Withdrawal', 5000),
(8, 104, '2023-11-04', 'Withdrawal', 4000),
(9, 104, '2023-11-04', 'Withdrawal', 3000),
(10, 105, '2023-11-05', 'Deposit', 7000),
(11, 105, '2023-11-05', 'Withdrawal', 8000),
(12, 105, '2023-11-05', 'Withdrawal', 6000);

-- 3. Queries

-- 1. Total deposits and withdrawals per account
SELECT 
  account_id,
  SUM(CASE WHEN txn_type = 'Deposit' THEN amount ELSE 0 END) AS total_deposit,
  SUM(CASE WHEN txn_type = 'Withdrawal' THEN amount ELSE 0 END) AS total_withdrawal
FROM transactions
GROUP BY account_id;

-- 2. Accounts with negative balance after transactions
SELECT 
  a.account_id,
  a.balance - 
  (SUM(CASE WHEN t.txn_type = 'Withdrawal' THEN t.amount ELSE 0 END) -
   SUM(CASE WHEN t.txn_type = 'Deposit' THEN t.amount ELSE 0 END)) AS final_balance
FROM accounts a
JOIN transactions t ON a.account_id = t.account_id
GROUP BY a.account_id, a.balance
HAVING final_balance < 0;

-- 3. Monthly deposits vs withdrawals
SELECT 
  DATE_FORMAT(txn_date, '%Y-%m') AS month,
  SUM(CASE WHEN txn_type = 'Deposit' THEN amount ELSE 0 END) AS total_deposit,
  SUM(CASE WHEN txn_type = 'Withdrawal' THEN amount ELSE 0 END) AS total_withdrawal
FROM transactions
GROUP BY DATE_FORMAT(txn_date, '%Y-%m')
ORDER BY month;

-- 4. High-value transactions (>3 per day)
SELECT 
  t.account_id,
  DATE(t.txn_date) AS txn_day,
  COUNT(*) AS high_value_count
FROM transactions t
WHERE t.amount > 5000
GROUP BY t.account_id, DATE(t.txn_date)
HAVING COUNT(*) > 3;

-- 5. Top 3 customers by total transaction volume
SELECT 
  c.name,
  SUM(t.amount) AS total_volume
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
JOIN transactions t ON a.account_id = t.account_id
GROUP BY c.name
ORDER BY total_volume DESC
LIMIT 3;

-- 6. Average transaction amount by account type
SELECT 
  a.account_type,
  AVG(t.amount) AS avg_txn_amount
FROM accounts a
JOIN transactions t ON a.account_id = t.account_id
GROUP BY a.account_type;

-- 7. Dormant accounts (no transactions in last 90 days)
SELECT 
  a.account_id,
  a.open_date
FROM accounts a
LEFT JOIN transactions t 
  ON a.account_id = t.account_id 
  AND t.txn_date >= CURDATE() - INTERVAL 90 DAY
WHERE t.txn_id IS NULL;

-- 8. Total balance per city
SELECT 
  c.city,
  SUM(a.balance) AS total_balance
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
GROUP BY c.city
ORDER BY total_balance DESC;
