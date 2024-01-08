/*
-----------
Aggregation
-----------
*/

# Total amount of poster paper ordered
SELECT COUNT(poster_qty) AS poster_ppr_amt
FROM orders;

# Total amount of standard paper ordered
SELECT COUNT(standard_qty) AS standard_ppr_amt
FROM orders;

# Total sales
SELECT SUM(total_amt_usd) as total_sales
FROM orders;

# Total amount spent on standard and gloss paper
SELECT
	standard_amt_usd + gloss_amt_usd AS total_standard_gloss
FROM orders;

# Amount per unit for standard paper
SELECT
	SUM(standard_amt_usd) / SUM(standard_qty) AS standard_unit_amt
FROM orders;

# Earliest order ever placed
SELECT
	MIN(occurred_at) as earliest_order
FROM orders;
-- get same result without using aggregation
SELECT 
	occurred_at
FROM orders
ORDER BY occurred_at
LIMIT 1;

# Most recent order
SELECT
	MAX(occurred_at) as recent_order
FROM orders;

SELECT 
	occurred_at
FROM orders
ORDER BY occurred_at DESC
LIMIT 1;

# AVG order amounts and qtys 
SELECT
	AVG(total_amt_usd) as avg_order,
    AVG(standard_amt_usd) as avg_standard,
    AVG(gloss_amt_usd) as avg_gloss,
    AVG(poster_amt_usd) as avg_poster,
    AVG(standard_qty) as qty_standard,
    AVG(gloss_qty) as qty_gloss,
    AVG(poster_qty) as qty_poster
FROM orders;

# MEDIAN (Likely INTERVIEW QUESTION)
SELECT
	COUNT(total_amt_usd) -- 6912
FROM orders;

SELECT 6912 / 2 as median; -- 3456

WITH cte AS (
SELECT
	ROW_NUMBER() OVER(ORDER BY total_amt_usd) as row_num,
    orders.*
FROM orders
)

SELECT
	total_amt_usd as median_amt
FROM cte
WHERE row_num = 3456 OR row_num = 3457; -- (2482.55 + 2483.16)/2 = the median (since it's an even number for total rows)

# Group By or other SQL functionalities
SELECT 
	a.name as account_name,
    o.occurred_at as date
FROM orders o
	JOIN accounts a
		ON o.account_id = a.id
ORDER BY date; -- Dish Network on 2013-12-04

#Total sales by account 
SELECT 
	a.name as account_name,
    SUM(o.total_amt_usd) as total_rev
FROM orders o
	JOIN accounts a
		ON o.account_id = a.id
GROUP BY a.name
ORDER BY total_rev DESC; 
    
# Account associated with the most recent web_event
SELECT
	a.name,
    w.occurred_at,
    w.channel
FROM accounts a
	JOIN web_events w
		ON a.id = w.account_id
ORDER BY w.occurred_at DESC; -- Molina Healthcare 2017-01-01 | Earliest web event: Dish Network on 2013-12-04 | direct

# Total count of web_events per channel 
SELECT
	channel,
    COUNT(channel) as num_events
FROM web_events 
GROUP BY channel; -- direct: 5298

# POC of earliest web event
SELECT
	a.name,
    w.occurred_at,
    w.channel,
    a.primary_poc
FROM accounts a
	JOIN web_events w
		ON a.id = w.account_id
ORDER BY w.occurred_at
LIMIT 1; -- Leana Hawker
    
# Smallest order placed per account
SELECT 
	a.name as account_name,
    MIN(o.total_amt_usd) as smallest_order
FROM orders o
	JOIN accounts a
		ON o.account_id = a.id
GROUP BY a.name
ORDER BY smallest_order; 

-- # of sales reps in each region
SELECT
	r.name,
    COUNT(*) AS num_reps
FROM region r
	JOIN sales_reps s
		ON r.id = s.region_id
GROUP BY r.name
ORDER BY num_reps;

-- AVG qty of paper types purchased per account
SELECT
	a.name AS account,
    ROUND(AVG(o.standard_qty), 2) AS avg_standard,
    ROUND(AVG(o.gloss_qty), 2) AS avg_gloss,
    ROUND(AVG(o.poster_qty), 2) AS avg_poster
FROM accounts a
	JOIN orders o
		ON a.id = o.account_id
GROUP BY a.name
ORDER BY account;

-- AVG amount spent on each paper type per account
SELECT
	a.name AS account,
    ROUND(AVG(o.standard_amt_usd), 2) AS avg_standard,
    ROUND(AVG(o.gloss_amt_usd), 2) AS avg_gloss,
    ROUND(AVG(o.poster_amt_usd), 2) AS avg_poster
FROM accounts a
	JOIN orders o
		ON a.id = o.account_id
GROUP BY a.name
ORDER BY account;

-- COUNT of channel per sales rep
SELECT
  w.channel AS channel,
  s.name AS sales_rep,
  COUNT(w.channel) AS count_channel
FROM web_events w
  JOIN accounts a
    ON w.account_id = a.id
  JOIN sales_reps
    ON a.sales_rep_id = s.id
GROUP BY w.channel, s.name
ORDER BY channel, sales_rep;

-- # of times channel used per region
SELECT
  r.name AS region,
  w.channel AS channel,
  COUNT(w.channel) AS count_channel
FROM web_events w
  JOIN accounts a
    ON w.account_id = a.id
  JOIN sales_reps s
    ON a.sales_rep_id = s.id
  JOIN region r
    ON s.region_id = r.id
GROUP BY r.name, w.channel
ORDER BY region, channel;

-- DISTINCT
-- Test if there are accounts associated with more than 1 region
SELECT DISTINCT
	a.name,
    r.name
FROM accounts a
    JOIN sales_reps s
		ON a.sales_rep_id = s.id
	JOIN region r
		ON s.region_id = r.id
ORDER BY a.name;

/* 
The below two queries have the same number of resulting rows (351), so we know that every 
account is associated with only one region. If each account was associated with more than 
one region, the first query should have returned more rows than the second query.
*/

-- Sales Reps worked on > 1 account
SELECT 
	s.id, 
    s.name, 
    COUNT(*) num_accounts
FROM accounts a
	JOIN sales_reps s
		ON s.id = a.sales_rep_id
GROUP BY s.id, s.name
ORDER BY num_accounts;

SELECT DISTINCT 
	id, 
    name
FROM sales_reps;

/*
Actually all of the sales reps have worked on more than one account. The fewest number of 
accounts any sales rep works on is 3. There are 50 sales reps, and they all have more than 
one account. Using DISTINCT in the second query assures that all of the sales reps are 
accounted for in the first query.
*/

-- HAVING
-- Sales Rep w/ > 5 accounts
SELECT 
	s.id, 
    s.name, 
    COUNT(*) num_accounts
FROM accounts a
	JOIN sales_reps s
		ON s.id = a.sales_rep_id
GROUP BY s.id, s.name
HAVING COUNT(*) > 5
ORDER BY num_accounts DESC;

-- Accounts w/ > 20 orders
SELECT
	a.name Account,
    COUNT(*) num_orders
FROM accounts a
	JOIN orders o
		ON a.id = o.account_id
GROUP BY a.name
HAVING COUNT(*) > 20
ORDER BY num_orders DESC;

-- Account w/ most orders
SELECT
	a.name Account,
    COUNT(*) num_orders
FROM accounts a
	JOIN orders o
		ON a.id = o.account_id
GROUP BY a.name
HAVING COUNT(*) > 20
ORDER BY num_orders DESC
LIMIT 1; -- Leucadia National: 71

-- Accounts spending > $30,000 in total
SELECT
	a.name account,
    SUM(o.total_amt_usd) total_spent
FROM accounts a
	JOIN orders o
		ON a.id = account_id
GROUP BY a.name
HAVING SUM(o.total_amt_usd) > 30000
ORDER BY total_spent DESC;

-- Accounts spending < $1,000 in total
SELECT
	a.name account,
    SUM(o.total_amt_usd) total_spent
FROM accounts a
	JOIN orders o
		ON a.id = account_id
GROUP BY a.name
HAVING SUM(o.total_amt_usd) < 1000
ORDER BY total_spent DESC;

-- Biggest spender
SELECT
	a.name account,
    SUM(o.total_amt_usd) total_spent
FROM accounts a
	JOIN orders o
		ON a.id = account_id
GROUP BY a.name
ORDER BY total_spent DESC
LIMIT 1; -- EOG Resources: $382,873.30

-- Smallest spender
SELECT
	a.name account,
    SUM(o.total_amt_usd) total_spent
FROM accounts a
	JOIN orders o
		ON a.id = account_id
GROUP BY a.name
ORDER BY total_spent ASC
LIMIT 1; -- Nike: $390.25

-- Accounts using facebook to contact customers > 6x
SELECT
	a.name Account,
    -- w.channel Channel,
    COUNT(*) num_contacts
FROM accounts a 
	JOIN web_events w
		ON a.id = w.account_id
GROUP BY a.name, w.channel
HAVING w.channel = 'facebook' AND COUNT(*) > 6
ORDER BY num_contacts;

-- Account that used FB most
SELECT
	a.name Account,
    w.channel Channel,
    COUNT(*) num_contacts
FROM accounts a 
	JOIN web_events w
		ON a.id = w.account_id
GROUP BY a.name, w.channel
HAVING w.channel = 'facebook' 
ORDER BY num_contacts DESC
LIMIT 1; -- Gilead Sciences: 16x 

-- Most used channel
SELECT 
	channel,
    COUNT(channel) num_events
FROM web_events
GROUP BY channel
ORDER BY num_events DESC; -- direct: 5298

SELECT a.id, a.name, w.channel, COUNT(*) use_of_channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY a.id, a.name, w.channel
ORDER BY use_of_channel DESC
LIMIT 10;


-- DATE Functions

-- Total sales per year DESC. Trends?
SELECT
	YEAR(occurred_at) Year
FROM orders
GROUP BY YEAR(occurred_at);

SELECT 
	YEAR(occurred_at) Year,
    SUM(total_amt_usd) TotalRevenue
FROM orders
GROUP BY Year
ORDER BY TotalRevenue DESC; -- there is only data for 1 month in both 2013 & 2017 which may help explain why the revenue is significantly lower

SELECT
	month(occurred_at) month,
    year(occurred_at) year,
    SUM(total)
FROM orders
GROUP BY month, year
ORDER BY year;

-- Best sales month of all time
SELECT YEAR(occurred_at) year, MONTH(occurred_at) month, DAY(occurred_at) day FROM orders ORDER BY year, month, day;

SELECT 
	monthname(occurred_at) month,
	SUM(total_amt_usd) TotalRevenue
FROM orders
GROUP BY month
ORDER BY TotalRevenue DESC; -- December, in aggregate, is the best month for generating revenue

--Course's answer to the qeustion above:
-- In order for this to be 'fair', we should remove the sales from 2013 and 2017. For the same reasons as discussed above.

SELECT DATE_PART('month', occurred_at) ord_month, SUM(total_amt_usd) total_spent
FROM orders
WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
GROUP BY 1
ORDER BY 2 DESC; 

-- Year of greatest orders placed
SELECT 
	YEAR(occurred_at) Year,
    SUM(total) TotalQty
FROM orders
GROUP BY Year
ORDER BY TotalQty DESC; -- 2016: 2041600

-- Walmart spent the most on gloss paper in...
SELECT
	a.name Account,
    SUM(gloss_amt_usd) TotalGloss,
    MONTHNAME(o.occurred_at) month,
    YEAR(o.occurred_at) year
FROM orders o
	JOIN accounts a
		ON o.account_id = a.id
GROUP BY a.name, month, year
HAVING a.name = 'Walmart'
ORDER BY TotalGloss DESC; -- May 2016: $9,257.64


