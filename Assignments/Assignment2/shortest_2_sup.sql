-- create or replace view sup_shortest(level, start_name, end_name, movie_title, movie_year) as 
--     WITH RECURSIVE find_relation as (
--     select 1 as level, y.start, actor.name, m.title, m.year from (select name as start from actor where name ILIKE %s) y, movie m, actor inner join
--       (select a1.actor_id, a1.movie_id
--       from acting a1
--       where 

--       a1.movie_id in 
--       (select movie_id from acting a3 inner join actor on a3.actor_id = actor.id where actor.name ILIKE %s))x on actor.id = x.actor_id
--     where x.movie_id = m.id
--     And lower(actor.name) != lower(%s)

--   UNION

--     select 1+temp.level as level, temp.name, a1.name, m.title, m.year
--     from movie m,  actor a1, find_relation temp, acting a2, actor a3, acting a4
--     where a3.name = temp.name and a2.actor_id = a3.id and m.id = a2.movie_id and a1.id = a4.actor_id and a4.movie_id = m.id
--     And lower(a1.name) != lower(temp.name)
--     And  temp.level < 6
    
-- ) select * from find_relation

create function shortest_sup (IN initial String) 
    RETURNS table (level, start_name, end_name, movie_title, movie_year)
    AS $$
    BEGIN 
        RETURN QUERY with a as (
            WITH RECURSIVE find_relation as (
                select 1 as level, y.start, actor.name, m.title, m.year from (select name as start from actor where name ILIKE %s) y, movie m, actor inner join
                    (select a1.actor_id, a1.movie_id
                    from acting a1
                    where 

                    a1.movie_id in 
                    (select movie_id from acting a3 inner join actor on a3.actor_id = actor.id where actor.name ILIKE %s))x on actor.id = x.actor_id
                    where x.movie_id = m.id
                    And lower(actor.name) != lower(%s)

            UNION

                select 1+temp.level as level, temp.name, a1.name, m.title, m.year
                    from movie m,  actor a1, find_relation temp, acting a2, actor a3, acting a4
                    where a3.name = temp.name and a2.actor_id = a3.id and m.id = a2.movie_id and a1.id = a4.actor_id and a4.movie_id = m.id
                    And lower(a1.name) != lower(temp.name)
                    And  temp.level < 6
        ) select * from find_relation
    END;
    $$ LANGUAGE plpgsql
    
create or replace view level_1 as 
    select * from sup_shortest having min(level) = 1;

create or replace view level_2 as 
    select * from sup_shortest where level = 2;
    
create or replace view level_3 as 
    select * from sup_shortest where level = 3;

create or replace view level_4 as 
    select * from sup_shortest where level = 4;

create or replace view level_5 as 
    select * from sup_shortest where level = 5;

create or replace view level_6 as 
    select * from sup_shortest where level = 6;
