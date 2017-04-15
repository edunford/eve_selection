-- Generating a Sample of corps that (a) contain humans, (b) are not dust corps, (c) operate in low/null sec space, 
-- (d) have at least ten active (unique) players that are active in 30 days


-- piecing together the story
		select top 10* from ebs_RESEARCH.zcharacter.charactersVx

		select count(*)
		from ebs_WAREHOUSE.owner.dimCharacterSCD 
		where corporationID = 98388312 and DATEDIFF(day,dateFrom,dateTo) <= 0


		select top 10* from ebs_WAREHOUSE.owner.dimCharacterSCD

		select * from ebs_WAREHOUSE.owner.dimCorporationEx 
		where corporationID = 98388312

		select * from ebs_RESEARCH.dbo.crpCorporations
		where corporationID = 98388312


		-- Corps created after from 2015 onward
		-- Dropping Corps started by chars with Dust IDs

		-- Dust Users ...
		SELECT top 10 characterID, userID FROM ebs_RESEARCH.dustCharacter.charactersVx



		--IF OBJECT_ID('tempdb..#corpRec') IS NOT NULL DROP TABLE #corpRec
		--select top 10
		--er.characterID,
		--er.characterName as characterName,
		--ch.createDate as characterCreateDate,
		--er.startDate,
		--er.corporationID,
		--cp.createDate,
		--users.userID,
		--users.eMail
		----into #corpRec
		--from ebs_RESEARCH.dbo.crpEmploymentRecordsEx er
		--inner join ebs_WAREHOUSE.owner.dimCharacterVx ch on ch.characterID = er.characterID
		--inner join ebs_WAREHOUSE.customer.dimUser users on users.userID = ch.userID
		--inner join ebs_RESEARCH.dbo.crpCorporations cp on cp.corporationID = er.corporationID
		--left join  ebs_RESEARCH.dustCharacter.charactersVx dust on dust.characterID = cp.creatorID 
		--where dust.characterID is null 
		--		AND cp.createDate >= '2015-01-01' -- subset by creation date 


		select top 10* from ebs_RESEARCH.dbo.crpEmploymentRecordsEx 
		--select top 10* from ebs_WAREHOUSE.owner.dimCharacterVx
		select top 10* from ebs_FACTORY.customer.customers
		select top 10* from ebs_WAREHOUSE.customer.dimUser
		select top 10* from ebs_FACTORY.eve.characters
		select top 10* from  ebs_RESEARCH.dbo.crpCorporations where createDate > '2015-01-01'
		select top 10* from ebs_WAREHOUSE.customer.dimUserSCD
		select top 10* from ebs_RESEARCH.corporation.corporationsLookup


		-- drawing corp sample
		select top 10
		corps.corporationID,
		corps.creatorID as corpCreatorID,
		corps.createDate as cropCreateDate,
		employ.characterID,
		employ.characterName,
		employ.startDate as hireDate
		from ebs_RESEARCH.dbo.crpCorporations corps
		left join  ebs_RESEARCH.dustCharacter.charactersVx dust on dust.characterID = corps.creatorID 
		inner join ebs_RESEARCH.dbo.crpEmploymentRecordsEx employ on employ.corporationID = corps.corporationID
		where dust.characterID is NULL -- drop corps created by dust characters
				and corps.creatorID > 1 
				and corps.createDate >= '2015-01-01'


		-- drawing character info. 
		select top 10
		users.userID,
		chars.characterID,
		chars.characterName,
		users.eMail,
		users.isActive,
		users.dateOfBirth as DOB,
		users.gender,
		users.createDate as userCreateDate,
		users.characterCreateDate
		from ebs_FACTORY.eve.characters chars
		inner join ebs_WAREHOUSE.customer.dimUser users on chars.userID = users.userID




-- COMBINE drawing corp sample and character info
IF OBJECT_ID('tempdb..#corpRec') IS NOT NULL DROP TABLE #corpRec
select
corps.corporationID,
corpName.corporationName,
corps.createDate as corpCreateDate,
corps.creatorID as creatorCharID,
chars2.characterName as creatorCharName,
users2.userID as creatorUserID,
lower(users2.eMail) as creatorEmail,
users2.dateOfBirth as creatorDOB,
users2.gender as creatorGender,
users2.createDate as creatorUserCreateDate,
users2.characterCreateDate as creatorCharCreateDate,
users2.languageName as creatorLanguage,
employ.characterID as employeeCharID,
users.userID as employeeUserID,
employ.characterName employeeCharName,
employ.startDate as hireDate,
lower(users.eMail) as employeeEmail,
users.isActive as isEmployeeActive,
users.dateOfBirth as employeeDOB,
users.gender as employeeGender,
users.createDate as employeeUserCreateDate,
users.characterCreateDate as employeeCharCreateDate,
users.languageName as employeeLanguage
into #corpRec
from ebs_RESEARCH.dbo.crpCorporations corps
left join  ebs_RESEARCH.dustCharacter.charactersVx dust on dust.characterID = corps.creatorID 
inner join ebs_RESEARCH.dbo.crpEmploymentRecordsEx employ on employ.corporationID = corps.corporationID
inner join ebs_FACTORY.eve.characters chars on chars.characterID = employ.characterID
inner join ebs_FACTORY.eve.characters chars2 on chars2.characterID = corps.creatorID
inner join ebs_WAREHOUSE.customer.dimUser users on chars.userID = users.userID
inner join ebs_WAREHOUSE.customer.dimUser users2 on chars2.userID = users2.userID
left join ebs_RESEARCH.corporation.corporationsLookup corpName on corpName.corporationID = corps.corporationID
where dust.characterID is NULL -- drop corps created by dust characters
		and corps.creatorID > 1 -- drop NPC created corps
		and corps.createDate >= '2015-01-01' -- subset by creation date (only consider corps created when the recruitment data overlaps)

			-- check
			select count(*) from #corpRec -- 906,501 entries
			select count(distinct corporationID) from #corpRec -- 128,467 corporations
			select top 1000* from #corpRec


-- ID number of unique players (humans) in each corporation
select 
distinct cr.corporationID,
sum(iif(cr.creatorEmail = cr.employeeEmail, 1, 0))  as numCreatorAsEmployee,
count(distinct cr.employeeEmail) as distinctEmails,
count(distinct cr.employeeCharID) as distinctEmployees
from #corpRec cr
group by cr.corporationID
having count(distinct cr.employeeEmail) >= 5 and sum(iif(cr.creatorEmail = cr.employeeEmail, 1, 0)) !=  count(distinct cr.employeeEmail) 
order by  count(distinct cr.employeeEmail) desc

-- 17,663 corporations contain 5 or more members who are not all the creator that were created from 2015 onward

		--- check
		select * from #corpRec where corporationID = 98388312



-- subset primary sample to generate a list of corps that satisfy conditions
IF OBJECT_ID('tempdb..#corpRec2') IS NOT NULL DROP TABLE #corpRec2;
with corpSample as 
(
	select 
	distinct cr.corporationID as corporationID2,
	count(distinct cr.employeeEmail) as distinctUsers
	from #corpRec cr
	group by cr.corporationID
	having count(distinct cr.employeeEmail) >= 5 and sum(iif(cr.creatorEmail = cr.employeeEmail, 1, 0)) !=  count(distinct cr.employeeEmail) 
)
select * into #corpRec2
from #corpRec c inner join corpSample cc on cc.corporationID2 = c.corporationID 

			-- check
			select count(*) from #corpRec2 --- 623,744 Players
			select count(distinct corporationID) from #corpRec2 --- 17,663 corporations
			select max(distinctUsers) as max, min(distinctUsers) as min from #corpRec2 -- Max No. of members: 24,976 and a Min No. of Members: 5


select top 100* from #corpRec2

