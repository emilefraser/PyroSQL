SELECT DISTINCT name FROM user_source WHERE type = 'PACKAGE' AND name LIKE UPPER('%&&1%');
