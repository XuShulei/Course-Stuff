normalize = function(x) {
  num = x - min(x)
  denom = max(x) - min(x)
  return (num/denom)
}

k=5

#income_raw_orginal = read.csv(file="/Users/chingking/Documents/income.csv", header = TRUE)
#income_raw_withLevel = read.csv(file="./income_NEW.csv", header = TRUE)
income_raw = read.csv(file="./income_NEW.csv", header = TRUE, stringsAsFactors = FALSE)
summary(income_raw)

income_ = matrix(, nrow = nrow(income_raw), ncol = 12)
colnames(income_) = c("age", "workcalss", "education", "marital_status", "occupation", 
                      "relationship", "race", "gender", "captital_gain", "captial_loss","hour_per_week","native_country")

income_[,1] = income_raw$age
income_[,2] =   gsub(" Private", 3, 
                gsub(" Federal-gov", 2, 
                gsub(" State-gov", 2, 
                gsub(" Local-gov", 2, 
                gsub(" Self-emp-not-inc", 1, 
                gsub(" Self-emp-inc", 1, 
                gsub(" Never-worked", 0, 
                gsub(" Without-pay", 0, 
                gsub(" \\?", -1, income_raw$workclass)))))))))
#income_[,3] = income_raw$fnlwgt
income_[,3] = gsub(" Doctorate", 11,
                    gsub(" Masters", 10,
                    gsub(" Prof-school", 10,
                    gsub(" Bachelors", 9,
                    gsub(" Some-college", 8, 
                    gsub(" HS-grad", 8, 
                    gsub(" Assoc-acdm", 7,
                    gsub(" Assoc-voc", 7,
                    gsub(" 12th", 6, 
                    gsub(" 11th", 5, 
                    gsub(" 10th", 4, 
                    gsub(" 9th", 3, 
                    gsub(" 7th-8th", 2, 
                    gsub(" 5th-6th", 1, 
                    gsub(" 1st-4th", 0, 
                    gsub(" Preschool", 0,
                         income_raw$education))))))))))))))))
income_[,4] = gsub(" Divorced", 1,
              gsub(" Married-AF-spouse", 2,
              gsub(" Married-civ-spouse", 2,
              gsub(" Married-spouse-absent", 1, 
              gsub(" Never-married", 1, 
              gsub(" Separated", 1,
              gsub(" Widowed", 0,
              income_raw$marital_status)))))))
income_[,5] = gsub(" Sales", 14,
                gsub(" Tech-support", 12,
                gsub(" Protective-serv", 12,
                gsub(" Prof-specialty", 11,
                gsub(" Priv-house-serv", 10,
                gsub(" Other-service", 9,
                gsub(" Exec-managerial", 8,
                gsub(" Machine-op-inspct", 7,
                gsub(" Handlers-cleaners", 6,
                gsub(" Transport-moving", 5,
                gsub(" Farming-fishing", 4,
                gsub(" Craft-repair", 3, 
                gsub(" Armed-Forces", 2, 
                gsub(" Adm-clerical", 1,
                gsub(" \\?", -1,
                     income_raw$occupation)))))))))))))))
income_[,6] = gsub(" Wife", 1,
              gsub(" Husband", 1,
              gsub(" Own-child", 1, 
              gsub(" Unmarried", 0,
              gsub(" Not-in-family", 0,
              gsub(" Other-relative", 0,
                income_raw$relationship))))))
income_[,7] = gsub(" Other", 4, 
              gsub(" White", 3,
              gsub(" Black", 2,
              gsub(" Asian-Pac-Islander", 1,
              gsub(" Amer-Indian-Eskimo", 0,
                income_raw$race)))))
income_[,8] = gsub(" Female", 1, 
              gsub(" Male", 0,
                 income_raw$gender))
income_[,9] = income_raw$capital_gain
income_[,10] = income_raw$capital_loss
income_[,11] = income_raw$hour_per_week
income_[,12] = gsub(" Yugoslavia", 0,  #Don't have GDP info
               gsub(" Vietnam", 55, 
               gsub(" Trinadad&Tobago", 101, #Assume this means Trinidad and Tobago
               gsub(" Thailand", 32, 
               gsub(" Taiwan", 26, 
               gsub(" South", 13,      # Assume this means South Korean 
               gsub(" Scotland", 0,    #Don't have GDP info
               gsub(" Puerto-Rico", 75,
               gsub(" Portugal", 46,
               gsub(" Poland", 23,
               gsub(" Philippines", 38,
               gsub(" Peru", 51,
               gsub(" Nicaragua", 132, 
               gsub(" Mexico", 15, 
               gsub(" Laos", 134,
               gsub(" Japan", 3,
               gsub(" Jamaica", 124, 
               gsub(" Italy", 8, 
               gsub(" Ireland", 44, 
               gsub(" Iran", 29, 
               gsub(" India", 9, 
               gsub(" Hong", 37,   #Assume this means Hong Kong 
               gsub(" Honduras", 111,
               gsub(" Haiti", 141,
               gsub(" Guatemala", 77,
               gsub(" Greece", 43,
               gsub(" Germany", 4, 
               gsub(" France", 6, 
               gsub(" England", 5,  #Assume this means UK
               gsub(" El-Salvador", 106,
               gsub(" Ecuador", 62, 
               gsub(" Dominican-Republic", 75, 
               gsub(" Cuba", 67, 
               gsub(" Columbia", 31,  #Should be Colombia I guess 
               gsub(" China", 2, 
               gsub(" Canada", 11, 
               gsub(" Cambodia", 114,
               gsub(" United-States", 1,
               gsub(" \\?", -1,
                income_raw$native_country)))))))))))))))))))))))))))))))))))))))
#income_[,14] = income_raw$class

#income_ = as.numeric(income_)
is.na(income_) = (income_ == "-1")
income_omit = na.omit(income_)
income_norm = matrix(, nrow = nrow(income_omit), ncol = 12)

#Normalization
for (i in 1:12) {
  tmp = as.numeric(income_omit[,i])
  if (i < 7 || i > 10 ) {
    income_norm[,i] = normalize(tmp)
  } else {
    income_norm[,i] = tmp
  }
}
for (i in 9:10) {
  tmp_full = as.numeric(income_omit[,i])
  tmp = subset(tmp_full, tmp_full > 0 & tmp_full < 99999)
  med = median(tmp)
  tmp_full[tmp_full < med & tmp_full>0] = normalize(tmp_full[tmp_full < med & tmp_full>0])
  tmp_full[tmp_full >= med] = 1.0
  income_norm[,i] = tmp_full
}

#Distance matrix
n_exp = nrow(income_norm)
df = matrix(, nrow = n_exp, ncol = n_exp)

for(i in 1:n_exp) {
  for(j in 1:n_exp) {
    #df[i,j] = sqrt(sum((income_normalized[i, 1:4] - income_normalized[j, 1:4])^2))
    tmp_sum = sum((income_norm[i,1:6] - income_norm[j,1:6])^2)
    tmp_sum = tmp_sum + ifelse (income_norm[i,7] != income_norm[j,7], 1, 0)
    tmp_sum = tmp_sum + sum((income_norm[i,8:12] - income_norm[j,8:12])^2)
    df[i,j] = sqrt(tmp_sum) 
  }
}


colname = c()
for (kk in 1:k) {
  colname[(2*kk-1)] = switch(paste(kk), "1" = "1st", "2" = "2nd", "3" = "3rd", paste(kk,"th",sep=""))
  colname[(2*kk)] = paste(kk, "-dist", sep="")
}

out = data.frame()

for(i in 1:n_exp) {
  sortedRow = sort.list(df[i,1:n_exp])
  for (kk in 1:k) {
    out[i, 2*kk-1] = sortedRow[kk+1]
    out[i, 2*kk] = df[i, sortedRow[kk+1] ]
  }
}

colnames(out) = colname

write.csv(out,file="./incom_out_l2.csv")
