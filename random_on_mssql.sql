-- Create table
CREATE TABLE dbo.users
(
  username nvarchar(50),
  status nvarchar(50)
)

-- Loading dummy users data
INSERT INTO dbo.users (username) VALUES ('User 1');
INSERT INTO dbo.users (username) VALUES ('User 2');
INSERT INTO dbo.users (username) VALUES ('User 3');
INSERT INTO dbo.users (username) VALUES ('User 4');
INSERT INTO dbo.users (username) VALUES ('User 5');

-- Select a winner
WITH cte_random_winner AS (
    SELECT TOP 1 u.username
    FROM dbo.users u
    WHERE status IS NULL
    ORDER BY newid()
)
UPDATE dbo.users
SET status = 'winner'
OUTPUT INSERTED.username
FROM dbo.users w
INNER JOIN cte_random_winner u
    ON w.username = u.username

/*
SELECT *
FROM dbo.users

TRUNCATE TABLE dbo.users;

UPDATE dbo.users
SET status = NULL
*/
