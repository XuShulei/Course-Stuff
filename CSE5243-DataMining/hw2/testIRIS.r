#==============================
#  Author: Ching-Hsiang Chu
#  Email: chu.368@osu.edu
#==============================

normalize = function(x) {
  num = x - min(x)
  denom = max(x) - min(x)
  return (num/denom)
}

start.time <- Sys.time()

iris_training_raw = read.csv(file="./Iris.csv", header = TRUE, sep = ",")
iris_testing_raw = read.csv(file="./Iris_Test.csv", header = TRUE, sep = ",")
#summary(iris_training)
iris_training = data.matrix(iris_training_raw)
iris_testing = data.matrix(iris_testing_raw)
length_traning = nrow(iris_training)
length_testing = nrow(iris_testing)

df_l1 = matrix(, nrow = length_testing, ncol = length_traning)
df_l2 = matrix(, nrow = length_testing, ncol = length_traning)

for(i in 1:length_traning) {
  for(j in 1:length_testing) {
    df_l1[j,i] = sum(abs(iris_training[i, 1:4] - iris_testing[j, 1:4]))
    df_l2[j,i] = sqrt(sum((iris_training[i, 1:4] - iris_testing[j, 1:4])^2)) 
  }
}

end.time <- Sys.time()
time_calc_dist = (end.time - start.time)

max_k=nrow(iris_training)
exe_time = matrix(nrow = length(seq(3, max_k, 2)), ncol = 1, dimnames = list(seq(3, max_k, 2), "Exec. Time"))
error_rate_l1 = matrix(nrow = length(seq(3, max_k, 2)), ncol = 1, dimnames = list(seq(3, max_k, 2), "Accurary"))
error_rate_l2 = matrix(nrow = length(seq(3, max_k, 2)), ncol = 1, dimnames = list(seq(3, max_k, 2), "Accurary"))
TPR = matrix(nrow = length(seq(3, max_k, 2)), ncol = 1, dimnames = list(seq(3, max_k, 2), "TPR"))
FPR = matrix(nrow = length(seq(3, max_k, 2)), ncol = 1, dimnames = list(seq(3, max_k, 2), "FPR"))
for (k in seq(3, max_k, 2)) {
  start.time <- Sys.time()
  colLabel = c()
  for (kk in 1:k) {
    colLabel[kk] = switch(paste(kk), "1" = "1st", "2" = "2nd", "3" = "3rd", paste(kk,"th",sep=""))
  }
  
  dist_rank_l1 = matrix(nrow = length_testing, ncol = k, dimnames = list(NULL, colLabel))
  dist_rank_l2 = matrix(nrow = length_testing, ncol = k, dimnames = list(NULL, colLabel))
  
  for(i in 1:length_testing) {
    # Sort the distances and find the top k closest samples from traning set
    sortedRow = sort.list(df_l1[i,1:length_traning])
    sortedRow2 = sort.list(df_l2[i,1:length_traning])
    for (kk in 1:k) {
      dist_rank_l1[i, kk] = sortedRow[kk]
      dist_rank_l2[i, kk] = sortedRow2[kk]
    }
  }
  
  class_level = unique(iris_training_raw$class)
  n_class = length(class_level)
  prob_matrix_l1 = matrix(nrow=length_testing, ncol=n_class, dimnames = list(NULL, class_level))
  prob_matrix_l2 = matrix(nrow=length_testing, ncol=n_class, dimnames = list(NULL, class_level))
  
  for (i in 1:length_testing) {
    for (c in class_level) {
      prob_matrix_l1[i, c] = length(which(iris_training_raw[unlist(dist_rank_l1[i,]), 5] == c)) / k
      prob_matrix_l2[i, c] = length(which(iris_training_raw[unlist(dist_rank_l2[i,]), 5] == c)) / k
    }
  }
  
  iris_classfication_l1 = matrix(,nrow = length_testing, ncol = n_class, dimnames = list(NULL, c("Actual Class", "Predicted Class", "Posterior Probability")))
  iris_classfication_l2 = matrix(,nrow = length_testing, ncol = n_class, dimnames = list(NULL, c("Actual Class", "Predicted Class", "Posterior Probability")))
  
  error_l1 = matrix(,nrow = length_testing, ncol = 1, dimnames = list(NULL,c("Correctness")))
  error_l2 = matrix(,nrow = length_testing, ncol = 1, dimnames = list(NULL,c("Correctness")))
  
  iris_classfication_l1[, "Actual Class"] = as.character(iris_testing_raw$class)
  iris_classfication_l2[, "Actual Class"] = as.character(iris_testing_raw$class)
  
  for (i in 1:length_testing) {
    # Based on L1 distance
    iris_classfication_l1[i, "Predicted Class"] = as.character(class_level[which.max(prob_matrix_l1[i,])])
    iris_classfication_l1[i, "Posterior Probability"] = max(prob_matrix_l1[i,])
    error_l1[i,1] = (iris_classfication_l1[i, "Actual Class"] == iris_classfication_l1[i, "Predicted Class"] )
    # Based on L2 distance
    iris_classfication_l2[i, "Predicted Class"] = as.character(class_level[which.max(prob_matrix_l2[i,])])
    iris_classfication_l2[i, "Posterior Probability"] = max(prob_matrix_l2[i,])
    error_l2[i,1] = (iris_classfication_l2[i, "Actual Class"] == iris_classfication_l2[i, "Predicted Class"] )
  }
  confusion_matrix_l1 = matrix(nrow = n_class, ncol = n_class, dimnames = list(class_level, class_level))
  confusion_matrix_l2 = matrix(nrow = n_class, ncol = n_class, dimnames = list(class_level, class_level))
  for (i in class_level) {
    for (j in class_level) {
      confusion_matrix_l1[i,j] = length(which((iris_classfication_l1[, "Actual Class"]==i)
                                              & (iris_classfication_l1[, "Predicted Class"]==j)))
      confusion_matrix_l2[i,j] = length(which((iris_classfication_l2[, "Actual Class"]==i)
                                              & (iris_classfication_l2[, "Predicted Class"]==j)))
    }
  }
  TPR[as.character(k),1] = confusion_matrix_l1[1,1] / (confusion_matrix_l1[1,1] + confusion_matrix_l1[1,2])
  FPR[as.character(k),1] = confusion_matrix_l1[2,1] / (confusion_matrix_l1[2,1] + confusion_matrix_l1[2,2])
  error_rate_l1[as.character(k),1] = 1 - (length(which(error_l1 == TRUE)) / length_testing)
  error_rate_l2[as.character(k),1] = 1- (length(which(error_l2 == TRUE)) / length_testing)
  end.time <- Sys.time()
  exe_time[as.character(k),1] = time_calc_dist+(end.time - start.time)
}

#min(error_rate_l1)
#min(error_rate_l2)
#which.min(error_rate_l2)
#plot(row.names(error_rate_l1), error_rate_l1, xlab = "k", ylab = "Error Rate")
#plot(row.names(error_rate_l2), error_rate_l2, xlab = "k", ylab = "Error Rate")
#plot(FPR, TPR, type = "o", xlab = "FPR", ylab = "TPR", xlim=c(0, 1), ylim=c(0, 1))

write.csv(iris_classfication_l1,file="./iris_classification_l1.csv")
write.csv(iris_classfication_l2,file="./iris_classification_l2.csv")