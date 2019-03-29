-- Create table 
CREATE TABLE public.pg_day
(
    id bigserial
    event_id integer,
    uname varchar,
    email varchar,
    present integer,
    winner integer
)

-- Loading dummy users data
INSERT INTO public.pg_day (event_id, uname, email, present, winner) VALUES (1, 'User 1', 'User 1', 1, NULL);
INSERT INTO public.pg_day (event_id, uname, email, present, winner) VALUES (1, 'User 2', 'User 2', NULL, NULL);
INSERT INTO public.pg_day (event_id, uname, email, present, winner) VALUES (2, 'User 1', 'User 1', 1, NULL);
INSERT INTO public.pg_day (event_id, uname, email, present, winner) VALUES (2, 'User 2', 'User 2', 1, 1);
INSERT INTO public.pg_day (event_id, uname, email, present, winner) VALUES (2, 'User 3', 'User 3', 1, NULL);


-- Select a winner
WITH 
event AS
(
    SELECT max(event_id) AS event_id 
    FROM public.pg_day
),
chans AS
(
    SELECT 
        max(uname), email,
        SUM
        (    
            CASE 
                WHEN present IS NULL THEN -1
                WHEN present IS NOT NULL AND winner IS NOT NULL THEN 0
                WHEN present IS NOT NULL AND winner IS NULL THEN 1
                ELSE 0
            END
        ) coeff 
    FROM public.pg_day
    GROUP BY email    
),
winner AS 
(
    SELECT d.event_id, d.email
    FROM public.pg_day d
        INNER JOIN event e ON e.event_id = d.event_id
        INNER JOIN chans c ON c.email = d.email AND c.coeff > 0
        CROSS JOIN LATERAL generate_series(1, coeff, 1) 
    ORDER BY random()    
    LIMIT 1
),
winner_upd AS
(
    UPDATE public.pg_day d
    SET winner = 1
    FROM winner w 
    WHERE w.event_id = d.event_id
        AND w.email = d.email
    RETURNING d.uname, d.email    
)
SELECT uname
FROM winner_upd
