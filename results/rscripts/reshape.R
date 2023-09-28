# stop/again/manner reshape

# set working directory to directory of script
this.dir <- dirname(rstudioapi::getSourceEditorContext()$path)
setwd(this.dir)

source("helpers.r")
library(reshape2)
library(tidyverse)
# load data
d1 = read.csv("../parsed-results1.csv",header = TRUE, stringsAsFactors = FALSE, quote = "\"", sep="\t")
d2 = read.csv("../parsed-results2.csv",header = TRUE, stringsAsFactors = FALSE, quote = "\"", sep="\t")
d3 = read.csv("../parsed-results3.csv",header = TRUE, stringsAsFactors = FALSE, quote = "\"", sep="\t")
d4 = read.csv("../parsed-results4.csv",header = TRUE, stringsAsFactors = FALSE, quote = "\"", sep="\t")
d5 = read.csv("../parsed-results5.csv",header = TRUE, stringsAsFactors = FALSE, quote = "\"", sep="\t")
d6 = read.csv("../parsed-results6.csv",header = TRUE, stringsAsFactors = FALSE, quote = "\"", sep="\t")
d = rbind(d1,d2,d3,d4,d5,d6)
summary(d)
nrow(d) #176 = 98 + 12 + 30 + 15 + 10 + 11 Turkers
names(d)
head(d)

# did any Turkers do the experiment more than once?
length(unique(d$workerid)) #176, so no

# anonymize workerids
d$workerid <- match(d$workerid, unique(sort(d$workerid)))
table(d$workerid)

# comments
table(d$Answer.comments)

# how long did they take?
library(chron)
table(d$assignmentaccepttime)
str(d$assignmentaccepttime)
table(d$assignmentsubmittime)
str(d$assignmentsubmittime)

d$begin <- d$assignmentaccepttime
d$begin <- gsub(" CEST 2018","",d$begin)
d$begin <- gsub("Mon Jun 25 ","",d$begin)
table(d$begin)
d$begin <- chron(times = d$begin, format=c('h:m:s'))
d$begin

d$end <- d$assignmentsubmittime
d$end <- gsub(" CEST 2018","",d$end)
d$end <- gsub("Mon Jun 25 ","",d$end)
table(d$end)
d$end <- chron(times = d$end, format=c('h:m:s'))

d$time <- d$end - d$begin
table(d$time)
min(d$time) # 3:18
mean(d$time) #13:21
median(d$time) #12:05

ggplot(d, aes(x=time)) +
  geom_histogram()

# each of the 40 sounds was 2 seconds = 80 seconds = 1 min 20 sec
# so doing the experiment in 3 minutes is tight but possible...

# reshaping the data

d = reshapeSTOPAGAINMANNER(d)

# save the reshaped data 
write.csv(d, "../data/d.csv", row.names=FALSE)

nrow(d)
names(d)
head(d)

# find the column numbers with the 40 trials in them
sort(names(d))

sort(names(d))[240]
sort(names(d))[279]
sort(names(d))[240:279]

# melt the data based on Trial number position in d 
md = melt(d, id.vars=c("workerid", "assignmentid","Answer.listNumber","time","Answer.age","Answer.gender","Answer.language","Answer.americanenglish"),measure=sort(names(d))[240:279])

summary(md)
head(md)
names(md)
nrow(md) #7040 rows / 40 ratings = 176 Turkers
tail(md)

# melt

md$Trial = gsub("Trial","",md$variable)
md$Trial
md$Trial <- as.numeric(md$Trial)
table(md$Trial)

# List of the item
md$List = sapply(strsplit(as.character(md$value)," ",fixed=T), "[", 1)
md$List = as.factor(as.character(md$List))
table(md$List) #12 lists

# 1  10  11  12   2   3   4   5   6   7   8   9 
# 160 520 200 440 400 480 280 480 240 400 520 280
# 4   13  5   11  10  12  7   12  6   10  13  7
# run more on 1, 11, 4, 6, 9
# i.e., on 0, 10, 3, 5, 8

# 1   10  11  12   2    3     4   5   6   7   8   9 
# 240 520 440 440 400   480   680 480 520 400 520 480
# 6   13  11  11  10    12    17  12  13  10  13  12
# run more on 1, 2 7
# i.e., 0, 1, 6

# 1   10  11  12   2   3   4   5   6   7   8   9 
# 320 520 440 440 600 480 680 480 520 720 520 480 
# 8   13  11  11  15  12  17  12  13  18  13  12
# run 8 more on 1, i.e. 0

# 1   10  11  12   2   3   4   5   6   7   8   9 
# 760 560 440 520 600 560 680 520 560 720 640 480
# 19  14  11  13  15  14  17  13  14  18  16  12

# number of the item (unique)
md$number = sapply(strsplit(as.character(md$value)," ",fixed=T), "[", 2)
md$number = as.factor(as.character(md$number))
table(md$number)

# verb of the item
md$verb = sapply(strsplit(as.character(md$value)," ",fixed=T), "[", 3)
md$verb = as.factor(as.character(md$verb))
table(md$verb) #12 verbs, each received 528 judgments (3 occurrences x 176 Turkers)

# sound of the item
md$sound = sapply(strsplit(as.character(md$value)," ",fixed=T), "[", 4)
md$sound = as.character(md$sound)
table(md$sound)

# question  of the item
md$question = sapply(strsplit(as.character(md$value)," ",fixed=T), "[", 5)
md$question = as.character(md$question)
table(md$question)

# Response of the item (1-5)
md$Response = sapply(strsplit(as.character(md$value)," ",fixed=T), "[", 6)
md$Response = as.numeric(as.character(md$Response))
table(md$Response)

# save the melted data 
write.csv(md, "../data/md.csv", row.names=FALSE)

# create new columns
table(md$sound)

# target expression
md$target <- md$sound
md$target <- ifelse(grepl("-a-",md$sound),"again",ifelse(grepl("-s-",md$sound),"stop",ifelse(grepl("-m-",md$sound),"manner","control")))
table(md$target) #each target expression: 2112 judgments (= 12 occurrences x 176 Turkers)

# content
md$content <- md$sound
md$content <- gsub("-[s|a|m]-[A|S|V|T].wav","", md$content)
table(md$content) #each content has 176 judgments (= once per Turker)

# prosodic condition
md$prosody <- md$sound
md$prosody <- ifelse(grepl("-A.wav",md$sound),"aux",
                     ifelse(grepl("-S.wav",md$sound),"subject",
                            ifelse(grepl("-V.wav",md$sound),"verb",
                                   ifelse(grepl("-T.wav",md$sound),"target",
                                   "control"))))
table(md$prosody) #each prosody has 1584 judgments (= 9 items x 176 Turkers)

# participant
table(md$workerid)

#create a file for the cleaned up data (cd)
cd = md
names(cd)
nrow(cd) #7040

# ages of participants
str(cd$Answer.age)
cd$Answer.age <- gsub("\"", "", cd$Answer.age)
cd$Answer.age <- as.numeric(cd$Answer.age)

table(cd$Answer.gender)

table(cd$Answer.age) #20-76
mean(cd$Answer.age) #36

# exclude data from non-native speakers of American English
table(cd$Answer.language)
cd <- subset(cd, (cd$Answer.language != "\"Chinese\"" & cd$Answer.language != "\"chinese\"" & cd$Answer.language != "\"Canto\""))
cd = droplevels(cd)
nrow(cd) #6920 (= data from 3 Turkers excluded, 173 remaining Turkers)

table(cd$Answer.americanenglish)
# "No" "Yes" 
# 80  6840

cd <- subset(cd, cd$Answer.americanenglish == "\"Yes\"")
cd = droplevels(cd)
nrow(cd) #6840 = 171x40, data from 2 Turkers excluded

# cleaned-up data (only American English speakers)
write.csv(cd, "../data/cd.csv", row.names=FALSE)
