


select top 100* from corporation.applications where status = 8

select count(*) from corporation.applications -- 5,549,594 applications
select count(*) from corporation.applications where status = 8 -- 246,534 (4%) of those are invitations (if the status feature is correct)
select count(*) from corporation.applications where status != 8 -- 159,883 (96%) of those are applications
select min(applicationDateTime) as minDate, max(applicationDateTime) as maxDate from corporation.applications -- timeseries covers the expanse of the game.

select distinct status as types from corporation.applications -- typs of application status 0, 2, 3, 4, 6, 7, 8


select top 100* from alliance.applications -- alliance applications


-- recruitment related information
select * from corporation.recruitmentTypes
select * from corporation.recruitmentTypesTx
select top 100* from corporation.recruitmentAdRecruiters	
select top 10* from corporation.recruitmentAds -- provides the general information on hiring.
select * from corporation.recruitmentGroupsTx -- appears to be a table ID general selection criteria that corps can set.
select top 10* from corporation.recruitmentGroups
select top 10* from corporation.recruitmentGroupsEx
select * from corporation.recruitmentTypesEx -- articulates language and general goals of the group

select top 10* from corporation.memberAutoKicks

select * from corporation.activitiesEx

select top 10* from corporation.recruitmentTypes
select top 10* from vmsApplications order by created desc -- some form of internal application for volunteers/moderators in EVE


-- activity log potentially contains all information on applications
select * from ebs_WAREHOUSE.owner.dimActivityType where activityGroup = 'Corporation' -- key for the event log
select top 100* from ebs_RESEARCH.zevent.ownerEventsEx 
select distinct eventTypeName from ebs_RESEARCH.zevent.ownerEventsEx 
select top 100* from ebs_RESEARCH.zevent.ownerEventsEx  where eventTypeName = 'Join Corporation'
select top 100* from ebs_RESEARCH.zevent.ownerEventsEx  where eventTypeID = 13 -- remove corp (exiting a corp)
select top 100* from ebs_RESEARCH.zevent.ownerEventsEx  where eventTypeID = 383 -- not all pieces of the record are there...


select top 100* from corporation.applications

select count(*) from corporation.applications where applicationDateTime BETWEEN '2017-04-11' and '2017-04-12'