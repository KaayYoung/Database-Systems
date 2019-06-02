-- create or replace view try(Code, Name, Address, Zip, Sector) as
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

select a1."Date", a1.code, a1.Volume, LAG(a1.Price, 1) over (partition by a1."Date") as PrevPrice, a1.Price from 
            (
            select a2."Date", a2.code, a2.Volume, a2.Price
                from ASX a2
                group by a2.code, a2."Date"
                order by a2.code, a2."Date"
            ) a1;
        group by a1.code
        order by a1.code, a1."Date"