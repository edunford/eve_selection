


select top 10* from ebs_RESEARCH.ebs_RESEARCH.corporation.applications

select count(*) from ebs_RESEARCH.corporation.applications -- 5,549,594 applications
select count(*) from ebs_RESEARCH.corporation.applications where status = 8 -- 246,534 (4%) of those are invitations (if the status feature is correct)
select count(*) from ebs_RESEARCH.corporation.applications where status != 8 -- 159,883 (96%) of those are applications
select distinct status as status, count(*) as N from ebs_RESEARCH.corporation.applications group by status -- counts by status
select min(applicationDateTime) as minDate, max(applicationDateTime) as maxDate from ebs_RESEARCH.corporation.applications -- timeseries covers the expanse of the game.
select distinct deleted as deleted, count(*) as N from ebs_RESEARCH.corporation.applications group by deleted -- only a small proportion are deleted
select sum(iif(applicationText='',1,0)) as isText, sum(iif(applicationText='',0,1)) as isNoText from ebs_RESEARCH.corporation.applications -- roughly half the applications have text

select top 10* from ebs_RESEARCH.corporation.activitiesEx



select top 100* from ebs_RESEARCH.alliance.applications -- alliance applications


-- recruitment related information
select * from ebs_RESEARCH.corporation.recruitmentTypes
select * from ebs_RESEARCH.corporation.recruitmentTypesTx
select top 100* from ebs_RESEARCH.corporation.recruitmentAdRecruiters	
select top 10* from ebs_RESEARCH.corporation.recruitmentAds -- provides the general information on hiring.
select * from ebs_RESEARCH.corporation.recruitmentGroupsTx -- appears to be a table ID general selection criteria that corps can set.
select top 10* from ebs_RESEARCH.corporation.recruitmentGroups
select top 10* from ebs_RESEARCH.corporation.recruitmentGroupsEx
select * from ebs_RESEARCH.corporation.recruitmentTypesEx -- articulates language and general goals of the group
-- the question is in which log is this information contained?

select top 10* from ebs_RESEARCH.corporation.memberAutoKicks


select top 10* from ebs_RESEARCH.corporation.recruitmentTypes
select top 10* from vmsApplications order by created desc -- some form of internal application for volunteers/moderators in EVE


-- activity log potentially contains information on applications
select * from ebs_WAREHOUSE.owner.dimActivityType where activityGroup = 'Corporation' -- key for the event log
select top 100* from ebs_RESEARCH.zevent.ownerEventsEx 
select distinct eventTypeName, eventTypeID from ebs_RESEARCH.zevent.ownerEventsEx 
select top 100* from ebs_RESEARCH.zevent.ownerEventsEx  where eventTypeName = 'Join Corporation'
select top 100* from ebs_RESEARCH.zevent.ownerEventsEx  where eventTypeID = 13 -- remove corp (exiting a corp)
select top 100* from ebs_RESEARCH.zevent.ownerEventsEx  where eventTypeID = 383 -- not all pieces of the record are there...

select top 100* from ebs_RESEARCH.zevent.groups
select top 100* FROM corporation.npcCorporationsEx

select top 100* from ebs_RESEARCH.corporation.applications

select count(*) from ebs_RESEARCH.corporation.applications where applicationDateTime BETWEEN '2017-04-11' and '2017-04-12'