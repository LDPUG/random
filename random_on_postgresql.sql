-- Create table
CREATE TABLE public.users
(
  username character varying(50),
  status character varying(50)
)

-- Loading dummy users data
INSERT INTO public.users (username) VALUES ('User 1');
INSERT INTO public.users (username) VALUES ('User 2');
INSERT INTO public.users (username) VALUES ('User 3');
INSERT INTO public.users (username) VALUES ('User 4');
INSERT INTO public.users (username) VALUES ('User 5');

-- Select a winner
WITH cte_random_winner AS (
	SELECT username, random() as random
	FROM public.users
	WHERE status IS NULL
	ORDER BY random
	LIMIT 1
), 
cte_update_status AS (
	UPDATE public.users AS u
	SET status = 'winner'
	FROM cte_random_winner w 
	WHERE w.username = u.username
	RETURNING u.username
	)
SELECT username
FROM cte_update_status

-- Check results
SELECT * 
FROM public.users;

-- Reset statuses
UPDATE public.users
SET status = NULL