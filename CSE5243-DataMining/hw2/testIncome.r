#==============================
#  Author: Ching-Hsiang Chu
#  Email: chu.368@osu.edu
#==============================
  
normalize = function(x) {
  num = x - min(x, na.rm=TRUE)
  denom = max(x, na.rm=TRUE) - min(x, na.rm=TRUE)
  return (num/denom)
}

transfomation = function(income_raw) {
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
  #income_[,3] = income_training_raw$fnlwgt
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
  #income_[,14] = income_training_raw$class
  
  #income_ = as.numeric(income_)
  #is.na(income_) = (income_ == "-1")
  #income_omit = na.omit(income_)
  #income_norm = matrix(, nrow = nrow(income_omit), ncol = 12)
  return (income_)
}
start.time <- Sys.time()
income_training_raw = read.csv(file="./income_TRAIN_FINAL.csv", header = TRUE, stringsAsFactors = TRUE)
income_testing_raw = read.csv(file="./income_TEST_FINAL.csv", header = TRUE, stringsAsFactors = TRUE)

#income_training_raw = income_training_raw[-sample(1:nrow(income_training_raw), nrow(income_training_raw)*0.75),]
income_traning_norm = transfomation(income_training_raw)
income_testing_norm = transfomation(income_testing_raw)
class(income_traning_norm) = "numeric"
class(income_testing_norm) = "numeric"

# Normalization
for (i in 1:12) {
  tmp = as.numeric(income_traning_norm[,i])
  tmp2 = as.numeric(income_testing_norm[,i])
  if (i < 7 || i > 10 ) {
    income_traning_norm[,i] = normalize(tmp)
    income_testing_norm[,i] = normalize(tmp2)
  } else {
    income_traning_norm[,i] = tmp
    income_testing_norm[,i] = tmp2
  }
}
for (i in 9:10) {
  tmp_full = as.numeric(income_traning_norm[,i])
  tmp = subset(tmp_full, tmp_full > 0 & tmp_full < 99999)
  med = median(tmp, na.rm = TRUE)
  tmp_full[tmp_full < med & tmp_full>0] = normalize(tmp_full[tmp_full < med & tmp_full>0])
  tmp_full[tmp_full >= med] = 1.0
  income_traning_norm[,i] = tmp_full
  # same process for testing data
  tmp_full = as.numeric(income_testing_norm[,i])
  tmp = subset(tmp_full, tmp_full > 0 & tmp_full < 99999)
  med = median(tmp, na.rm = TRUE)
  tmp_full[tmp_full < med & tmp_full>0] = normalize(tmp_full[tmp_full < med & tmp_full>0])
  tmp_full[tmp_full >= med] = 1.0
  income_testing_norm[,i] = tmp_full
}

# Distance matrix
n_row_training = nrow(income_traning_norm)
n_row_testing = nrow(income_testing_norm)
df_l1 = matrix(, nrow = n_row_testing, ncol = n_row_training)
df_l2 = matrix(, nrow = n_row_testing, ncol = n_row_training)

# Calc. distances for each example in testing dataset
for(i in 1:n_row_testing) {
  for(j in 1:n_row_training) {
    # L1, city block distance
    tmp_sum = sum(abs(income_traning_norm[j,1:6] - income_testing_norm[i,1:6]))
    tmp_sum = tmp_sum + ifelse (income_traning_norm[j,7] != income_testing_norm[i,7], 1, 0)
    tmp_sum = tmp_sum + sum(abs(income_traning_norm[j,8:12] - income_testing_norm[i,8:12]))
    df_l1[i,j] = sqrt(tmp_sum)
    # L2, Euclidiean distance
    tmp_sum = sum((income_traning_norm[j,1:6] - income_testing_norm[i,1:6])^2)
    tmp_sum = tmp_sum + ifelse (income_traning_norm[j,7] != income_testing_norm[i,7], 1, 0)
    tmp_sum = tmp_sum + sum((income_traning_norm[j,8:12] - income_testing_norm[i,8:12])^2)
    df_l2[i,j] = sqrt(tmp_sum) 
  }
}

end.time <- Sys.time()
time_calc_dist = (end.time - start.time)

max_k=nrow(income_training_raw)
exe_time = matrix(nrow = length(seq(3, max_k, 2)), ncol = 1, dimnames = list(seq(3, max_k, 2), "Exec. Time"))
error_rate_l1 = matrix(,nrow = length(seq(3, max_k, 2)), ncol = 1, dimnames = list(seq(3, max_k, 2), "Accuracy"))
error_rate_l2 = matrix(,nrow = length(seq(3, max_k, 2)), ncol = 1, dimnames = list(seq(3, max_k, 2), "Accuracy"))
TPR = matrix(nrow = length(seq(3, max_k, 2)), ncol = 1, dimnames = list(seq(3, max_k, 2), "TPR"))
FPR = matrix(nrow = length(seq(3, max_k, 2)), ncol = 1, dimnames = list(seq(3, max_k, 2), "FPR"))
for (k in seq(3, max_k, 2)) {
  start.time <- Sys.time()
  colLabel = c()
  for (kk in 1:k) {
    colLabel[kk] = switch(paste(kk), "1" = "1st", "2" = "2nd", "3" = "3rd", paste(kk,"th",sep=""))
    #colLabel[(2*kk)] = paste(kk, "-dist", sep="")
  }
  
  dist_rank_l1 = matrix(, nrow = n_row_testing, ncol = k, dimnames = list(NULL, colLabel))
  dist_rank_l2 = matrix(, nrow = n_row_testing, ncol = k, dimnames = list(NULL, colLabel))
  
  for(i in 1:n_row_testing) {
    # Sort the distances and find the top k closest samples from traning set
    sortedRow = sort.list(df_l1[i,1:n_row_training])
    sortedRow2 = sort.list(df_l2[i,1:n_row_training])
    for (kk in 1:k) {
      dist_rank_l1[i, kk] = sortedRow[kk]
      dist_rank_l2[i, kk] = sortedRow2[kk]
    }
  }
  
  class_level = unique(income_training_raw$class)
  n_class = length(class_level)
  prob_matrix_l1 = matrix(nrow=n_row_testing, ncol=n_class, dimnames = list(NULL, class_level))
  prob_matrix_l2 = matrix(nrow=n_row_testing, ncol=n_class, dimnames = list(NULL, class_level))
  
  for (i in 1:n_row_testing) {
    for (c in class_level) {
      prob_matrix_l1[i, c] = length(which(income_training_raw[unlist(dist_rank_l1[i,]), 15] == c)) / k
      prob_matrix_l2[i, c] = length(which(income_training_raw[unlist(dist_rank_l2[i,]), 15] == c)) / k
    }
  }
  
  income_classfication_l1 = matrix(nrow = n_row_testing, ncol = 3, dimnames = list(NULL, c("Actual Class", "Predicted Class", "Posterior Probability")))
  income_classfication_l2 = matrix(nrow = n_row_testing, ncol = 3, dimnames = list(NULL, c("Actual Class", "Predicted Class", "Posterior Probability")))
  
  error_l1 = matrix(nrow = n_row_testing, ncol = 1)
  error_l2 = matrix(nrow = n_row_testing, ncol = 1)
  
  for (i in 1:n_row_testing) {
    # Based on L1 distance
    income_classfication_l1[i, "Actual Class"] = as.character(income_testing_raw$class[i])
    income_classfication_l1[i, "Predicted Class"] = as.character(class_level[which.max(prob_matrix_l1[i,])])
    income_classfication_l1[i, "Posterior Probability"] = max(prob_matrix_l1[i,])
    error_l1[i,1] = (income_classfication_l1[i, "Actual Class"] == income_classfication_l1[i, "Predicted Class"] )
    # Based on L2 distance
    income_classfication_l2[i, "Actual Class"] = as.character(income_testing_raw$class[i])
    income_classfication_l2[i, "Predicted Class"] = as.character(class_level[which.max(prob_matrix_l2[i,])])
    income_classfication_l2[i, "Posterior Probability"] = max(prob_matrix_l2[i,])
    error_l2[i,1] = (income_classfication_l2[i, "Actual Class"] == income_classfication_l2[i, "Predicted Class"] )
  }
  confusion_matrix_l1 = matrix(nrow = n_class, ncol = n_class, dimnames = list(class_level, class_level))
  confusion_matrix_l2 = matrix(nrow = n_class, ncol = n_class, dimnames = list(class_level, class_level))
  for (i in class_level) {
    for (j in class_level) {
      confusion_matrix_l1[i,j] = length(which((income_classfication_l1[, "Actual Class"]==i)
                                              & (income_classfication_l1[, "Predicted Class"]==j)))
      confusion_matrix_l2[i,j] = length(which((income_classfication_l2[, "Actual Class"]==i)
                                              & (income_classfication_l2[, "Predicted Class"]==j)))
    }
  }
  TPR[as.character(k),1] = confusion_matrix_l1[1,1] / (confusion_matrix_l1[1,1] + confusion_matrix_l1[1,2])
  FPR[as.character(k),1] = confusion_matrix_l1[2,1] / (confusion_matrix_l1[2,1] + confusion_matrix_l1[2,2])
  error_rate_l1[as.character(k),1] = 1 - (length(which(error_l1 == TRUE)) / n_row_testing)
  error_rate_l2[as.character(k),1] = 1 - (length(which(error_l2 == TRUE)) / n_row_testing)
  end.time <- Sys.time()
  exe_time[as.character(k),1] = time_calc_dist+(end.time - start.time)
}
#min(error_rate_l1)
#min(error_rate_l2)
#which.min(error_rate_l1)
#which.min(error_rate_l2)
#plot(row.names(error_rate_l1), error_rate_l1, xlab = "k", ylab = "Error Rate")
#plot(row.names(error_rate_l2), error_rate_l2, xlab = "k", ylab = "Error Rate")
#plot(FPR, TPR, type = "o", xlab = "FPR", ylab = "TPR", xlim=c(0, 1), ylim=c(0, 1))

write.csv(income_classfication_l1,file="./income_classification_l1.csv")
write.csv(income_classfication_l2,file="./income_classification_l2.csv")
