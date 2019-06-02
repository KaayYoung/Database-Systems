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
    INSERT INTO ASXLOG ("Timestamp", "Date", Code, OldVolume, OldPrice) VALUES (new."Timstamp", old."Date", old.Code, old.Volume, old.Price)
end;
$$ language plpgsql

create trigger stockLog
before update on ASX
for each row execute procedure stockLog();
