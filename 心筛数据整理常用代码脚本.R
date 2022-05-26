############################
##原始数据整理基本代码脚本##
############################


#清空遗留全局变量
rm(list = ls())
#设置工作空间
setwd("G:/ShareCache/慢病数据库/04_数据中台/代码脚本/心筛干预项目")
#设置原始数据来源
path_db <- "G:/ShareCache/慢病数据库/03_原始数据/心血管病高危人群早期筛查与综合干预项目/data_2022/35_Fujian/"
#设置结果输出目录
outcome_path <- "G:/ShareCache/慢病数据库/04_数据中台/整理后数据/心筛干预项目/"


#载入需要的R包
library('naniar')
library('ggplot2')
library('tableone')
library('tidymodels')
library('tidyverse')



#读取原始文件

#读取初筛表
db_screen <- read.csv(paste(path_db, '1_基本信息和初筛调查表_20220406.csv', sep=""))
db_screen <- db_screen[-1,] #删除第一行标题中文名
#读取初筛码和高危码
pid_to_pidgw <- read.csv(paste(path_db, '2_初筛码和高危码对应表_20220406.csv', sep=""))
pid_to_pidgw <- pid_to_pidgw[-1,] #删除第一行标题中文名
#读取短随和长随问卷
db_follow <- read.csv(paste(path_db, '4_短期和长期随访调查表_20220406.csv', sep=""))
db_follow <- db_follow[-1,]#删除第一行标题中文名

#区分短随和长随
follow_short <- db_follow[which(db_follow$mark=='ShortFU'),]
follow_long <- db_follow[which(db_follow$mark=='LongFU'),]

#读取长随实验室结果
follow_lab <- read.csv(paste(path_db, '13_随访问卷实验室检查结果_20220406.csv', sep=""))
follow_lab <- follow_lab[-1,] #删除第一行标题中文名

#合并随访问卷和随访实验室结果
long_lab <- merge(follow_long, follow_lab, by.x='PIDGW', by.y='PIDGW', all.x=T, all.y=F)

#字符转日期格式
long_lab$fu_date <- as.Date(long_lab$fu_date)
long_lab$lab_FINISH_TIME <- as.Date(long_lab$lab_FINISH_TIME)

#选出实验室结果和随访问卷相差不超过90天的记录
long_lab_ <- long_lab[which(abs(long_lab$lab_FINISH_TIME - long_lab$fu_date)<90),]
#填补随访问卷中实验室指标缺失
long_lab_$FU_TC <-long_lab_$lab_TC_num
long_lab_$FU_TG <- long_lab_$lab_TG_num
long_lab_$FU_HDL <- long_lab_$lab_HDL_num
long_lab_$FU_ldl <- long_lab_$lab_LDL_num

#字符转数字格式
long_lab_$FU_TC <- as.numeric(long_lab_$FU_TC)
follow_long$FU_TC <- as.numeric(follow_long$FU_TC)

#拼合填补前后数据框
long_lab_fillna <- rbind(long_lab, long_lab_)

#字符串转数字
long_lab_fillna$FU_TC <- as.numeric(long_lab_fillna$FU_TC)
long_lab_fillna$FU_TG <- as.numeric(long_lab_fillna$FU_TG)
long_lab_fillna$FU_HDL <- as.numeric(long_lab_fillna$FU_HDL)
long_lab_fillna$FU_ldl <- as.numeric(long_lab_fillna$FU_ldl)

#去重，删除原旧数据
long_lab_fillna <- long_lab_fillna[!duplicated(long_lab_fillna[,c('PIDGW', 'fu_date')], fromLast=T),]

#导出处理后表格
write.csv(long_lab_fillna, file = paste(outcome_path, 'clean.csv', sep = ''))

