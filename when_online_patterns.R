require(tidyverse)
require(igraph)
require(ggthemes)
require(revemetrics)
require(lubridate)


# Build framework for looking at log-on, log-off times

corpID = 98472700


logon = "select * from edvald_research.umd.charloggedOn
where corporationID = @{corp_id}" %>% 
  QueryDB(sql.params = list(corp_id = corpID))

head(logon)



d = logon %>% mutate(dt = round_date(ymd_hms(eventDatePrecise),"minutes")) %>% 
  select(dt,corporationID:eventType) %>% arrange(dt) 


span =seq(parse_date_time(min(d$dt),"%Y-%m-%d %H:%M:%S"),
          parse_date_time(max(d$dt),"%Y-%m-%d %H:%M:%S"),by=60) %>% 
  data.frame(dt=.)

M = full_join(d,span,by="dt")

# Want to generate a count that offers a micro picture re: how many people are
# online at a given minute


# There is *always* a compliment
d %>% summarize(logon=sum(eventType == "logon",rm.na=T),
                logoff=sum(eventType == "logoff",rm.na=T))




d %>% 
  group_by(characterID, spell_id = as.numeric(eventType == "logon")) %>% 
  mutate(episodeID = row_number()) %>% 
  select(-spell_id) %>% ungroup(.) %>% 
  arrange(characterID, episodeID)
event_data2

M %>%  arrange(dt)

ymd_hm(d$dt[2])

d %>% ggplot(.) + geom_bar(aes(x=dt,group=characterID))


seq(parse_date_time('2017-01-01 03:40:00',"%Y-%m-%d %H:%M:%S"),
    parse_date_time('2017-01-01 03:45:00',"%Y-%m-%d %H:%M:%S"),by=60)

