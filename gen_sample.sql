-- Generating a Sample of corps that (a) contain humans, (b) are not dust corps, (c) operate in low/null sec space, 
-- (d) have at least ten active (unique) players that are active in 30 days

select top 10* from ebs_RESEARCH.zcharacter.charactersVx

select count(*)
--DATEDIFF(day,dateFrom,dateTo) as diff
from ebs_WAREHOUSE.owner.dimCharacterSCD 
where corporationID = 98388312 and DATEDIFF(day,dateFrom,dateTo) <= 0
--order by dateFrom 
35375


select top 10* from ebs_WAREHOUSE.owner.dimCharacterSCD

select * from ebs_WAREHOUSE.owner.dimCorporationEx 
where corporationID = 98388312

select * from ebs_RESEARCH.dbo.crpCorporations
where corporationID = 98388312


-- Corps created after from 2015 onward
-- Dropping Corps started by chars with Dust IDs


SELECT distinct top 10
cp.corporationID,
cp.creatorID,
cp.createDate 
FROM ebs_RESEARCH.dbo.crpCorporations cp
inner join  ebs_RESEARCH.dustCharacter.charactersVx dust on dust.characterID != cp.creatorID
where cp.createDate >= '2015-01-01'


-- Dust Users ...
SELECT top 10 characterID, userID FROM ebs_RESEARCH.dustCharacter.charactersVx



IF OBJECT_ID('tempdb..#corpRec') IS NOT NULL DROP TABLE #corpRec
select 
er.characterID,
er.characterName,
er.startDate,
er.corporationID,
cp.createDate,
users.userID,
users.eMail
into #corpRec
from ebs_RESEARCH.dbo.crpEmploymentRecordsEx er
inner join ebs_WAREHOUSE.owner.dimCharacterVx ch on ch.characterID = er.characterID
inner join ebs_WAREHOUSE.customer.dimUser users on users.userID = ch.userID
inner join ebs_RESEARCH.dbo.crpCorporations cp on cp.corporationID = er.corporationID
inner join  ebs_RESEARCH.dustCharacter.charactersVx dust on dust.characterID != cp.creatorID -- drop dust characters
where cp.createDate >= '2015-01-01' -- subset by creation date 

