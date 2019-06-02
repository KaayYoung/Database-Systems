create or replace view Q1(Name, Country) as
    select name, Country
    from Company
    where Country <> 'Australia';


create or replace view Q2(Code) as
    select c.code
    from Company c
    inner join Executive e
        on c.code = e.code
    group by c.code
    having count(e.person) > 5;


create or replace view Q3(Name) as 
    select co.Name
    from company co
        inner join category ca
        on co.code = ca.code
    where ca.Sector = 'Technology';


create or replace view Q4(Sector, Number) as
    select Sector, count(DISTINCT industry) as Number
    from category
    group by sector;


create or replace view Q5(Name) as
    select e.person
    from Executive e
    where e.code in (
        select co.code 
        from company co
        where co.Name in 
        (
            select name from q3
        )
    );


create or replace view Q6(Name) as
    select co.name 
    from company co
    where co.code in (
        select ca.code
            from category ca
            where ca.sector = 'Services'
        group by ca.code
        )
    And co.Country = 'Australia'
    And left(co.zip, 1) = '2';


create or replace view Q7("Date", Code, Volume, PrevPrice, Price, Change, Gain) as
    select a3."Date", a3.code, a3.Volume, a3.PrevPrice, a3.Price, (a3.Price - a3.PrevPrice) as change, (a3.Price - a3.PrevPrice) / a3.PrevPrice * 100 as Gain
        from (
            select a1."Date", a1.code, a1.Volume, LAG(a1.Price, 1) over (partition by a1.code) as PrevPrice, a1.Price from
            (
                select a2."Date", a2.code, a2.Volume, a2.Price
                    from ASX a2
                    group by a2.code, a2."Date"
                order by a2.code, a2."Date"
                ) a1
            ) a3
            where a3."Date" > (select min("Date") from ASX a2);


create or replace view Q8("Date", Code, Volume) as
    select d1."Date", d1.code, max(d1.Volume) as Volumn
        from ASX d1
    inner join 
        (select "Date", max(Volume) as V2
            from ASX
            group by "Date"
        ) d2
        on d1."Date" = d2."Date"
        And Volume = V2
    group by d1."Date", d1.code
    order by d1."Date", d1.code;


create or replace view Q9(Sector, Industry, Number) as
    select Sector, Industry, count(Code)
    from Category
    group by Sector, Industry
    order by Sector, Industry;


 create or replace view Q10(Code, Industry) as
    select ca.code, q.Industry
    from Category ca
    inner join Q9 q
        on ca.Industry = q.Industry
    where q.number = 1
    group by ca.code, q.Industry;


create or replace view Q11(Sector, AvgRating) as
    select ca.Sector, Round(avg(ra.Star), 3) as AvgRating
    from category ca
    inner join Rating ra
        on ca.code = ra.code
    group by Sector
    order by AvgRating DESC;


create or replace view Q12(Name) as
    select name 
    from (
        select e.name, count(*) as number
        from 
            (
            select person as Name from 
                Executive
            ) e
        group by e.name
    ) a
    where a.number > 1;


create or replace view q13(Code, Name, Address, Zip, Sector) as
    select DISTINCT co.Code, co.Name, co.Address, co.Zip, ca.Sector from
    company co
    inner join category ca
    on co.code = ca.code
    where ca.Sector not in
    (
    select ca.Sector from
        category ca
        inner join company co
            on ca.code = co.code
        where co.country != 'Australia'
        group by ca.Sector
    );


create or replace view sup_q14(code, BeginPrice, EndPrice) as
    select a1.code, 
    (select a3.BeginPrice 
        from
        (select a2.Price as BeginPrice
            from ASX a2
            where a1.code = a2.code
            And a2."Date" = (select min(a1."Date") from ASX a1)
        ) a3 
    ), 
    (select a4.EndPrice
        from 
        (select a2.Price as EndPrice
            from ASX a2
            where a1.code = a2.code
            And a2."Date" = (select max(a1."Date") from ASX a1)
        ) a4
    )
    from ASX a1;

create or replace view Q14(Code, BeginPrice, EndPrice, Change, Gain) as
    select s.code, s.BeginPrice, s.EndPrice, (s.EndPrice - s.BeginPrice) as change, ((s.EndPrice - s.BeginPrice) / s.BeginPrice) * 100 as Gain
    from sup_q14 s
    group by s.code, s.BeginPrice, s.EndPrice
    order by Gain DESC, s.code ASC
;


create or replace view Q15(Code, MinPrice, AvgPrice, MaxPrice, MinDayGain, AvgDayGain, MaxDayGain) as
    select q7.code, 
    (select min(a1.Price) from ASX a1 where a1.code = q7.code), 
    (select avg(a1.Price) from ASX a1 where a1.code = q7.code), 
    (select max(a1.Price) from ASX a1 where a1.code = q7.code), 
    a.minGain, a.avgGain, a.maxGain 
        from q7, (
            select q7.code, min(q7.Gain) as minGain, avg(q7.Gain) as avgGain, max(q7.Gain) as maxGain
                from q7
            group by q7.code
            ) a
         where a.code = q7.code
    group by q7.code, a.minGain, a.avgGain, a.maxGain;

create or replace function companyExecutives_1() returns trigger
as $$
begin
    if (new.Person in (select person from Executive)) then
        raise exception 'Insert failed. Duplicate person or person in more than one company';
    end if;
    return new;
end;
$$ language plpgsql;

create trigger CompanyExecutives_1
before insert on Executive
for each row execute procedure companyExecutives_1();

create or replace function companyExecutives_2() returns trigger
as $$
begin
    if ((select count(person) from Executive where person = new.Person) >= 2) then
        raise exception 'Update failed. Duplicate person or person in more than one company';
    end if;
    return new;
end;
$$ language plpgsql;

create trigger companyExecutives_2
after update on Executive
for each row execute procedure companyExecutives_2();


create or replace view q17_sup1("Date", Code, Sector, Gain) as
    select s."Date", s.code, s.Sector, g.Gain from  
        (
        select ca.Code,  a."Date", ca.Sector
            from category ca, ASX a
            where ca.code = a.code
            group by ca.code, a."Date"
        order by a."Date", ca.Sector
        ) s
    inner join q7 g on
        s.code = g.code 
    And
        s."Date" = g."Date"
    order by s."Date", s.Sector, g.gain, s.code;
    
create or replace view maxSectorGain("Date", Sector, maxGain) as
    select DISTINCT "Date", Sector, max(gain) over (partition by "Date", sector order by "Date", Sector)
        from q17_sup1
    order by "Date";
create or replace view minSectorGain("Date", Sector, minGain) as
    select DISTINCT "Date", Sector, min(gain) over (partition by "Date", sector order by "Date", Sector)
        from q17_sup1
    order by "Date";

create or replace function stockStar() returns trigger 
as $$
declare
    companyGain numeric (15, 7);
    sectorsmaxGain numeric (15, 7);
    sectorsminGain numeric (15, 7);
begin
    select gain into companyGain from q7 where new.code = q7.code and new."Date" = q7."Date";
    select maxgain into sectorsmaxGain from maxSectorGain maxg where
            maxg.sector = (select sector from category ca where ca.Code = new.Code) 
        And maxg."Date" = new."Date";
    select mingain into sectorsminGain from minSectorGain ming where
            ming.sector = (select sector from category ca where ca.Code = new.Code)
        And ming."Date" = new."Date";
    if (companyGain >= sectorsmaxGain) then
        UPDATE Rating
        SET Star = 5
        where Code = new.Code;
    ELSIF (companyGain <= sectorsminGain) then
        UPDATE Rating
        SET Star = 1
        where Code = new.Code;
    end if;
    return new;
end;
$$ language plpgsql;

create trigger StockStar
after insert on ASX
for each row execute procedure stockStar();


create or replace function stockLog() returns trigger
as $$
begin
    INSERT INTO ASXLOG ("Timestamp", "Date", Code, OldVolume, OldPrice) VALUES (current_timestamp, old."Date", old.Code, old.Volume, old.Price);
    return new;
end;
$$ language plpgsql;

create trigger stockLog
before update on ASX
for each row execute procedure stockLog();
