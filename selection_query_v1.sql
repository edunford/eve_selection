-- Corporate History
SELECT TOP 100 * FROM ebs_FACTORY.eve.corporationHistory

-- NEED to grab information specific to recruitment 

SELECT TOP 100 * FROM ebs_RESEARCH.zuser.ipAddresses

-- Logs of recruitment applications user --> corp
SELECT TOP 100 * FROM hadoop.samples.eventLogs_corpRecruitment__ApplyToJoin

SELECT TOP 100 * FROM hadoop.samples.eventLogs_corpRecruitment__JoinRecruitingChannel
SELECT TOP 100 * FROM hadoop.samples.eventLogs_corpRecruitment__SearchAdverts2
SELECT TOP 100 * FROM hadoop.samples.eventLogs_corpRecruitment__TalkToRecruiter -- communication with recruiter

DROP TABLE #reprocessed
CREATE table #reprocessed (dt date, stationID int, stationOwnerID INT, typeID int, amount float)
 
INSERT into #reprocessed(dt, stationID, stationOwnerID, typeID, amount)
EXEC hadoop.hive.query 'SELECT dt, locationID, stationOwnerID, typeID, SUM(amountRefined)
                          FROM eventLogs_reprocess__ReprocessItem
                          WHERE dt BETWEEN @date1 AND @date2
                          GROUP by dt, locationID, stationOwnerID, typeID', '2017-04-01', '2017-04-02'

-- Query suggestions from Eddi.

select top 100 *
FROM ebs_RESEARCH.mail.messages m
order BY m.messageID desc

select top 100 *
FROM ebs_RESEARCH.mail.messages m
WHERE title LIKE '%recruit%'
order BY m.messageID desc
 
SELECT top 100 *
from ebs_RESEARCH.dbo.crpEmploymentRecords 



-- Query suggestions from Karjtan

SELECT * FROM hadoop.samples.eventLogs_mail__DoSendMail
SELECT * FROM hadoop.samples.eventLogs_corpRecruitment__TalkToRecruiter
SELECT * FROM hadoop.samples.eventLogs_corpRecruitment__JoinRecruitingChannel
SELECT * FROM hadoop.samples.eventLogs_corpRecruitment__SearchAdverts2
SELECT * FROM hadoop.samples.eventLogs_corpRecruitment__ApplyToJoin
SELECT * FROM hadoop.samples.eventLogs_corporation__InsertApplication
SELECT * FROM hadoop.samples.eventLogs_corporation__UpdateApplicationOffer
SELECT * FROM hadoop.samples.eventLogs_chat__JoinLeaveChannel
SELECT * FROM hadoop.samples.eventLogs_chat__InviteAccepted
SELECT * FROM hadoop.samples.eventLogs_chat__SetChannelName
SELECT TOP 100 * FROM ebs_RESEARCH.dbo.lscChannels WHERE displayName LIKE '%ecruit%'
SELECT TOP 5 * FROM ebs_RESEARCH.dbo.lscMyChannels
SELECT TOP 5 * FROM ebs_RESEARCH.dbo.nwsWebChannels
SELECT TOP 5 * FROM ebs_RESEARCH.lsc.messageSenders

select top 5 * from ebs_RESEARCH.dbo.lscChannels


select top 10* from ebs_RESEARCH.character.



-- piecing together the story from existing members: who joined and can we trace his/her activity leading up to recruitment

SELECT * FROM ebs_RESEARCH.dbo.crpMembersEx WHERE corporationID = 98188328
-- consider the membership roster of the wifi express. (was looking at Space Machanics [98188326] but they're a Russian speaking team
-- which complicated the message review.  


-- attach unique customer IDs to characters to each character in the corporation 
IF OBJECT_ID('tempdb..#corpRec') IS NOT NULL DROP TABLE #corpRec
SELECT 
CU.customerID,
CU.userID,
CP.creatorID,
CM.*,
CP.createDate,
crpAgeJoined = datediff(day, CP.createDate,CM.startDateTime),
timein = datediff(day, CM.startDateTime,getdate())
into #corpRec
FROM ebs_FACTORY.customer.customers CU
INNER JOIN ebs_FACTORY.eve.characters CH ON CU.userID = CH.userID
INNER JOIN ebs_RESEARCH.dbo.crpMembersEx CM ON CM.characterID = CH.characterID
inner Join ebs_RESEARCH.dbo.crpCorporations CP ON CP.corporationID = CM.corporationID 
where CM.corporationID = 98188328



select count(distinct(customerID)) from #corpRec -- unique players
select count(distinct(characterID)) from #corpRec -- unique characters


select 
customerID,
max(timein) as maxtimein,
min(crpAgeJoined) as crpAgeEntered
from #corpRec
group by customerID
order by crpAgeEntered -- cohorts of new entering players

select * from #corpRec where crpAgeJoined <= 7 -- initial members

-- founder is not in this list FYI



-- Let's look into some of members who were courted into the corp after it had been around for a bit (2.5 years)

select * from #corpRec where crpAgeJoined in (921,932,934,945)

select 
CR.characterName,
M.*
from ebs_RESEARCH.mail.messages M
inner join #corpRec CR on M.senderID = CR.characterID
where (M.title LIKE '%application%' or M.title LIKE '%ecruit%') and
(M.toCharacterIDs LIKE '%95891917%') and (M.sentDate < '2015-10-01')
order by M.sentDate 


--There doesn't appear to be evidence of messages sent to the following 
-- members (645933070,671295002,95891917,95925448) prior to their recruitment. 
-- this could be an artifact of the group or this could be a dead end.


select * from #corpRec where characterID = 219987026










