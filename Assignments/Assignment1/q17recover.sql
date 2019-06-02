delete from asx where (code ='AQA'and "Date" ='2012-03-31');
delete from asx where (code ='AQP'and "Date" ='2012-03-31');

delete from asx where (code ='AAD'and "Date" ='2012-03-31');
delete from asx where (code ='CCL'and "Date" ='2012-03-31');
delete from asx where (code ='AMC'and "Date" ='2012-03-31');


update rating set star = 3 where code = 'AQA';
update rating set star = 3 where code = 'AQP';

update rating set star = 3 where code = 'AAD';
update rating set star = 3 where code = 'CCL';
update rating set star = 3 where code = 'AMC';