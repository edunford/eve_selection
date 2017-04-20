# Parsing Jump logs for members in relevant corps for one week in April
# (4.01.17 to 4.07.17) -- sample and record generated in SQL.

library(tidyverse)
require(igraph)
require(reshape2)

# Initial organization of data
    # logs <- read.csv("~/ETD/selection/data/april_1_7_rel_jump_logs.csv",header=F,stringsAsFactors = F)
    # head(logs)
    # colnames(logs) = c("corporationID","customerID",
    #            "userID","inAlliance","eventDate",
    #            "characterID","destinationID","high",
    #            "low","null","worm")
    # jump_logs = logs
    # # Convert Columns
    # for(c in 8:11){ jump_logs[,c] = round(as.numeric(jump_logs[,c]),2)}
    # jump_logs[,5] = as.Date(jump_logs[,5])
    # save(jump_logs,file="~/ETD/selection/data/april_1_7_rel_jump_logs.Rdata")

# Load Cleaned data 
load("~/ETD/selection/data/april_1_7_rel_jump_logs.Rdata")


# Summaries ------------------
    jump_logs %>% group_by(corporationID) %>% tally() %>% arrange(desc(n))
    
          # Pandemic Horde (noobie corp) dominates the records with KarmaFleet in 
          # second (which has an externalized application process) and Ascendance in
          # third.
    
    jump_logs %>% group_by(corporationID) %>% tally() %>% 
      ggplot(.) + geom_histogram(aes(log(n)),
                                 fill="dodgerblue3",col="white")
    
    
    jump_logs %>% distinct(corporationID) %>% tally() # 5284 distinct corps in the records. 
    
    jump_logs %>% group_by(corporationID) %>% 
      summarize(N_chars =n_distinct(userID),N=n()) %>%
      arrange(desc(N_chars)) # number of distinct characters and activity

    jump_logs %>% group_by(corporationID) %>% 
      summarize(N_chars =n_distinct(userID),N=n()) %>% filter(N_chars<=500) %>%
      arrange(desc(N_chars))
    
# Building interaction Networks-------------
    
    # Sample from the low end of the distribution but where more than one
    # character is operating
    set.seed(333)
    draw =  jump_logs %>% group_by(corporationID) %>% 
      summarize(N_chars =n_distinct(userID),N=n()) %>%
      filter(N_chars >= 4, N <= 250) %>% sample_n(1) %>% as.data.frame()
    draw
    
    
    samp = jump_logs %>% filter(corporationID==draw[1,1]) %>% 
      arrange(eventDate,destinationID) %>% 
      select(eventDate,userID,destinationID) %>% distinct(.) 
    
    samp %>% group_by(eventDate,userID) %>% summarize(n_distinct(destinationID))
    
   
   # Mapping the Networks 
    
    # A loop: SLOW and LONG way 
    out = c()
    for(r in 1:nrow(samp)){
      for(c in 1:nrow(samp)){
        if( r != c & r < c & samp$userID[r] != samp$userID[c] &
            samp$eventDate[r] == samp$eventDate[c] & 
            samp$destinationID[r] == samp$destinationID[c]){
          tmp = data.frame(sideA=samp$userID[r],
                           sibeB=samp$userID[c],
                           dest=samp$destinationID[r])
          out = rbind(out,tmp)
        }
      }
    }
    
    out
    
    # Generate Network
    EM = as.matrix(out[,1:2]);colnames(EM) = NULL
    actors = unique(c(out$sideA,out$sibeB))
    net <- graph_from_data_frame(EM,actors,directed=F)
    net = simplify(net)
    plot.igraph(net,vertex.color="steelblue",vertex.frame.color="white",
                edge.color="grey",edge.width=1,vertex.size=4,
                vertex.label="")

    
  # A more efficient approacy?
    
    # Dplyr
    dyad = samp %>% group_by(destinationID,eventDate) %>%
      mutate(ind=paste0('userID', ((row_number()+1) %% 2+1)), 
             ind_row = ceiling(row_number()/2)) %>%
      spread(ind, userID) %>% 
      select(-ind_row) %>% filter(!is.na(userID2)) %>% 
      ungroup %>% as.data.frame
    
    dyad
    
    dim(dyad)
    EM = dyad %>% select(userID1,userID2) %>% as.matrix();colnames(EM) = NULL
    actors = unique(c(dyad$userID1,dyad$userID2))
    net <- graph_from_data_frame(EM,actors,directed=F)
    # net = simplify(net)
    plot.igraph(net,vertex.color="steelblue",vertex.frame.color="white",
                edge.color="grey",edge.width=1,vertex.size=4,
                vertex.label="")
    
    # doesn't account for 2+ potential pairs
    
    
    # Cpp functional approach (big 0 n^2)
    source("~/ETD/selection/code/co_occur.R")
    
    out2 = samp %>% select(eventDate,destinationID,userID) %>% co_occur(.)
    EM = out2 %>% select(user1,user2) %>% as.matrix();colnames(EM) = NULL
    actors = unique(c(out2$user1,out2$user2))
    net <- graph_from_data_frame(EM,actors,directed=F)
    net <- simplify(net)
    plot.igraph(net,vertex.color="steelblue",vertex.frame.color="white",
                edge.color="grey",edge.width=1,vertex.size=4,
                vertex.label="")
    
    
  # The above method works, but grows quadratically which means the iterations 
  # becomes impossibly large as the size of the network increases. Let's hash by
  # time ordering the matrix. Here we only need to process small bits of the
  # object as we iterate through each hash. 
    
    
    
    
    
    
    
    
    
# With the method d?efined, let's try it out on a big corp with a lot of
# interactions.
    
    # Pandemic Horde (98388312)
    98473114
    # Time order and reduce redundancies. 
    S = jump_logs %>% filter(corporationID==98388312) %>% 
      select(eventDate,destinationID,userID) %>% 
      arrange(eventDate,destinationID) %>% 
      distinct(.) %>% group_by(eventDate,destinationID) %>% 
      mutate(n=n())  %>% filter(n > 1) %>% ungroup %>% 
      select(-n) %>% as.data.frame
    
    S$hash = S %>% group_indices(eventDate,destinationID)
    S$pos = 1:nrow(S)
    tmp = S
    for(c in 1:ncol(S)){
      if(!is.numeric(S[,c])){
        if(class(S[,c]) %in% c("character","factor")){
          S[,c] = as.numeric(as.factor(S[,c]))
        }
        if(class(S[,c])=="Date"){
          S[,c] = as.numeric(S[,c])
        }
      }
    }
    
    S = as.matrix(S)
    
    gather = c()
    hash = unique(S[,4])
    pb = progress_estimated(length(hash))
    tin = Sys.time()
    for(h in hash){
      pos = S[S[,4]==h,5][1]
      loc = hashdyadLT(S,S[,4]==h,pos)
      hold = data.frame(date=tmp[loc[,1],1],user1=tmp[loc[,1],3],user2=tmp[loc[,2],3],stringsAsFactors = T)
      gather = unique(rbind(gather,hold))
      pb$tick()$print()
    }
    tout = Sys.time() - tin
    
    head(gather)
    EM = gather %>% filter(date=='2017-04-01') %>% select(user1,user2) %>% as.matrix();colnames(EM) = NULL
    actors = unique(c(gather$user1,gather$user2))
    net <- graph_from_data_frame(EM,actors,directed=F)
    net <- simplify(net)
    
    pdf(file="~/ETD/selection/code/figures/pand_horde_net.pdf",height=8,width=8)
    plot.igraph(net,vertex.color="steelblue",vertex.frame.color="white",
                edge.color="grey",edge.width=2,vertex.size=4,
                vertex.label="",main="Pandemic Horde")
    dev.off()
    
    
    # 
    
    
    
    
    
    
    
  # Getting a feel for the algorithm time 
    
    
    # 2.89 min when 691
    # 1.89 min when 624
    # 31.5 secs when 469
    # 2.22 secs when 296
    # .006 secs when 50
    
    plot(y=c(.006,2.22,31.5,113.4,173.4),
         x=c(50,296,469,624,691),xlim=c(0,700),
         ylim=c(0,200),type="b",
         main="Members and Time",ylab="Time (Seconds)",
         xlab="Corp Members")
    
    y=c(.006,2.22,31.5,113.4,173.4)
    x=c(50,296,469,624,691)
    
    model = lm(y~x+I(x^2))
    b = coefficients(model)
    predtime = function(x){(b[[1]]+x*b[[2]]+(x^2)*b[[3]])}
    predtime(200)
    
    pos = S[S[,4]==1135,5][1]
    t = Sys.time()
    test = hashdyadLT(S,S[,4]==1135,pos)[-1,]
    t2 = Sys.time() - t
    t2
    
   
    pos = S[S[,4]==168,5][1]
    t3 = Sys.time()
    test1 = hashdyad(S,S[,4]==168,pos)[-1,]
    t4 = Sys.time() - t3
    t4
    
    pos = S[S[,4]==168,5][1]
    t5 = Sys.time()
    test2 = hashdyadLT(S,S[,4]==168,pos)
    t6 = Sys.time() - t5
    t6
    
    all(test1 == test2)
    
    
    loc[,1]
    
    
    tmp %>% group_by(hash) %>% tally() %>% arrange(desc(n)) # larges potential configuration
    
    tmp %>% group_by(hash) %>% tally() %>% arrange(desc(n)) %>% filter(n<=200)
    
    

    
    