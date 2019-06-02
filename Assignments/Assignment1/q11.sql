-- create or replace view Q9(Sector, Industry, Number) as
--     select Sector, Industry, count(*) as Number
--     from Category
--     group by Sector, Industry
--     order by Sector, Industry;


--  create or replace view Q10(Code, Industry) as
--     select ca.code, q.Industry
--     from Category ca
--     inner join Q9 q
--         on ca.Industry = q.Industry
--     where q.number = 1
--     group by ca.code, q.Industry;


-- create or replace view Q11(Sector, AvgRating) as
--     select ca.Sector, Round(avg(ra.Star), 3) as AvgRating
--     from category ca
--     inner join Rating ra
--         on ca.code = ra.code
--     group by Sector
--     order by AvgRating DESC;


-- create or replace view Q12(Name) as
--     select name 
--     from (
--         select e.name, count(*) as number
--         from 
--             (
--             select person as Name from 
--                 Executive
--             ) e
--         group by e.name
--     ) a
--     where a.number > 1;


-- create or replace view q13(Code, Name, Address, Zip, Sector) as
--     select DISTINCT co.Code, co.Name, co.Address, co.Zip, ca.Sector from
--     company co
--     inner join category ca
--     on co.code = ca.code
--     where ca.Sector not in
--     (
--     select ca.Sector from
--         category ca
--         inner join company co
--             on ca.code = co.code
--         where co.country != 'Australia'
--         group by ca.Sector
--     );


-- create or replace view sup_q14(code, BeginPrice, EndPrice) as
--     select a1.code, 
--     (select a3.BeginPrice 
--         from
--         (select a2.Price as BeginPrice
--             from ASX a2
--             where a1.code = a2.code
--             And a2."Date" = (select min(a1."Date") from ASX a1)
--         ) a3 
--     ), 
--     (select a4.EndPrice
--         from 
--         (select a2.Price as EndPrice
--             from ASX a2
--             where a1.code = a2.code
--             And a2."Date" = (select max(a1."Date") from ASX a1)
--         ) a4
--     )
--     from ASX a1;

-- create or replace view Q14(Code, BeginPrice, EndPrice, Change, Gain) as
--     select s.code, s.BeginPrice, s.EndPrice, (s.EndPrice - s.BeginPrice) as change, ((s.EndPrice - s.BeginPrice) / s.BeginPrice) * 100 as Gain
--     from sup_q14 s
--     group by s.code, s.BeginPrice, s.EndPrice
--     order by Gain DESC, s.code ASC
-- ;


-- create or replace view Q15(Code, MinPrice, AvgPrice, MaxPrice, MinDayGain, AvgDayGain, MaxDayGain) as
--     select q7.code, 
--     (select min(a1.Price) from ASX a1 where a1.code = q7.code), 
--     (select avg(a1.Price) from ASX a1 where a1.code = q7.code), 
--     (select max(a1.Price) from ASX a1 where a1.code = q7.code), 
--     a.minGain, a.avgGain, a.maxGain 
--         from q7, (
--             select q7.code, min(q7.Gain) as minGain, avg(q7.Gain) as avgGain, max(q7.Gain) as maxGain
--                 from q7
--             group by q7.code
--             ) a
--          where a.code = q7.code
--     group by q7.code, a.minGain, a.avgGain, a.maxGain;
         