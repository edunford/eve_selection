
df = data.frame(eventDate = c(1,1,1,2,2,3,4),
                dest = c("A","A","A","B","B","B","A"),
                userID = c(11,21,31,21,31,31,41))


m = df %>% group_by(dest,eventDate) %>% tally() %>% summarize(n=max(n)) %>% 
  summarize(max =max(n)) %>% as.data.frame

iter = m[1,] - 1
df2 = df
for (i in seq_along(iter)){
  df %>% group_by(dest,eventDate) %>%
    mutate(ind=paste0('userID', ((row_number()+1) %% 2+1)), 
           ind_row = ceiling(row_number()/2))%>%
    spread(ind, userID) %>% 
    select(-ind_row) 
}




df %>% 
  group_by(dest,eventDate)  %>%
  mutate(ind= paste0('userID', row_number())) %>% 
  spread(ind, userID)

df %>% 
  group_by(dest,eventDate)  %>%
  mutate(ind= row_number(),
         ind = as.numeric(ifelse(ind>2,2,ind))) %>% 
  spread(ind, userID)


df %>% ?gather()





df = data.frame(eventDate = c(1,1,1,2,2,3,4),
                destinationID = c("A","A","A","B","B","B","A"),
                userID = c(11,21,31,21,31,31,41))



meth1 = function(samp){
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
  return(out)
}



df$hash = df %>% group_indices(eventDate,destinationID)
df$pos = 1:nrow(df)

meth2 = function(df){
  out=c()
  hash_set = unique(df$hash)
  for( h in hash_set){
    sub = df[df$hash==h,]
    pos = sub$pos[1]
    for(i in 1:nrow(sub)){
      for(j in 1:nrow(sub)){
        if( i != j & i < j & sub$userID[i] != sub$userID[j]){
          out =rbind(out,c((i+pos)-1,(j+pos)-1))
        }
      }
    }
  }
  return(out)
}


# hash method that only iterates over the submatrix
meth3 = function(df){
  out=c()
  hash_set = unique(df$hash)
  for( h in hash_set){
    sub = df[df$hash==h,]
    pos = sub$pos[1]
    for(i in 1:(nrow(sub)-1)){
      for(j in (i+1):nrow(sub)){
        if(sub$userID[i] != sub$userID[j]){
          out =rbind(out,c((i+pos)-1,(j+pos)-1))
        }
      }
    }
  }
  return(out)
}


meth3(df)




df2 = df %>% group_by(hash) %>% mutate(n=n()) %>% filter(n>1) %>% select(-n)


system.time(meth1(df2))
system.time(meth2(df2))
system.time(meth3(df2))


samp$hash = samp %>% group_indices(eventDate,destinationID)
samp$pos = 1:nrow(samp)
samp2 = samp %>% group_by(hash) %>% mutate(n=n()) %>% filter(n>1) %>% select(-n)
system.time(meth1(samp2))
system.time(meth2(samp2))
system.time(meth3(samp2))


h = meth2(samp)
h2 = meth1(samp)
cbind(samp[h[,1],"userID"],samp[h[,2],"userID"])[41,]
h2[41,]



M = matrix(1,9,9)
loc = c()
for(c in 1:(ncol(M)-1)){
  for(r in (c+1):nrow(M)){
    loc = rbind(loc,c(r,c))
  }
}
M[loc] = 0
M

q = nrow(M)
q*(q-1)/2 # size

sum(M == 0)
