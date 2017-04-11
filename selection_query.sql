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
                          WHERE dt BETWEEN "2014.06.29" AND "2014.06.30"
                          GROUP by dt, locationID, stationOwnerID, typeID'

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




SELECT top 100 *
From ebs_RESEARCH.api
