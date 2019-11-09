/*
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
*/

-- Select a winner
WITH 
event AS
(
    SELECT max(d.event_id) AS event_id 
    FROM public.pg_day d
),
chans AS
(
    SELECT 
        max(d.uname), 
        d.email,
        SUM
        (    
            CASE 
                WHEN d.present IS NULL THEN -1
                WHEN d.present IS NOT NULL AND d.winner IS NOT NULL THEN 0
                WHEN d.present IS NOT NULL AND d.winner IS NULL THEN 1
                ELSE 0
            END
        ) coeff 
    FROM public.pg_day d
    GROUP BY d.email     
  ORDER BY 3 DESC 
),
winner AS 
(
    SELECT d.event_id, d.email
    FROM public.pg_day d
        INNER JOIN event e ON e.event_id = d.event_id
        INNER JOIN chans c ON upper(c.email) = upper(d.email) AND c.coeff > 0
        CROSS JOIN LATERAL generate_series(1, c.coeff, 1)
    WHERE NOT EXISTS
        (
            SELECT 1
            FROM public.pg_day dd
            WHERE upper(dd.email) = upper(d.email)
                AND dd.event_id = e.event_id
                AND dd.winner IS NOT NULL
        )    
    ORDER BY random()    
    LIMIT 1
),
winner_upd AS
(
    UPDATE public.pg_day d
    SET winner = 1
    FROM winner w 
    WHERE w.event_id = d.event_id
        AND upper(w.email) = upper(d.email)
    RETURNING d.uname, d.email    
)
SELECT w.uname
FROM winner_upd w