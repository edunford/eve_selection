# SELECTION

# GOAL: Look at recruitment. See who is applying to a corp, and how corps advertise.


library(RODBC)
require(dplyr)



conn <- odbcDriverConnect('DRIVER={SQL Server};SERVER=researchdb;DATABASE=ebs_RESEARCH;Trusted Connection=true;Integrated Security=true;')



mail = sqlQuery(conn,"select top 2000 *
FROM ebs_RESEARCH.mail.messages m
WHERE title LIKE '%recruit%'
order BY m.messageID desc")

head(mail)

mail$sentDate


txt = mail %>% select(body) %>% sample_n(10) %>% as.data.frame(.)
txt[1,]
gsub("<.*?>", " ", txt)
