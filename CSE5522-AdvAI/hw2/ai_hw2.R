traning = read.table(file="./training.txt", sep="\t")
testing = read.table(file="./testing.txt", sep="\t")

# Possible k to be evaluated, 10 iterations for each
#all_k = c(10, 2, 5, 6, 8, 12, 15, 20, 50)
all_k = c(10, 12) 
nit=10
cat("Will be running KNN clustring with k=(", all_k, "),", nit, "iterations for each\n")
# how many different classes in the dataset
cl = length(unique(traning$V1))

# Add a column to store the cluster number for k-means algorithm
traning$cluster = row(traning)[,1]
testing$cluster = row(testing)[,1]
# Add a column to store the predict class for testing data
testing$predict_class = row(testing)[,1]
# Store error rate, avg, standard deviation for each k
err_rate = matrix(, nit, length(all_k), dimnames = list(NULL, all_k))
avg_and_sd = matrix(, length(all_k), 2, dimnames = list(all_k, c("Avg", "SD")) )
exe_time = matrix(, length(all_k), 1, dimnames = list(all_k, c("Time")) )

cat("Plotting actual training set to 'TraningData_ActualCalss.pdf'\n")
pdf("TraningData_ActualCalss.pdf", width=10, height=10, paper="special", onefile=F)
plot(traning$V2, traning$V3, col=(traning$V1 + 10), pch =(traning$V1 + 10) )
invisible(dev.off())

for (k in all_k) {
  cat("==================================================\n")
  cat("Running kNN clustering, k=",k,"\n")
  cat("==================================================\n")
  filepath = paste("./test_k_",k,sep = "")
  dir.create(file.path(filepath), showWarnings = FALSE)
  # Declare/Initialize everything we need
  dm = matrix()
  pcv_traning = matrix(, length(unique(traning$V1)), (k+1), dimnames = list(NULL, c("C", paste("V",seq(1,k), sep = ''))))
  pvc_traning = matrix(, k, (length(unique(traning$V1))+1), dimnames = list(NULL, c("V", paste("C", seq(0,(length(unique(traning$V1))-1)), sep=''))))
  pc = matrix(, length(unique(traning$V1)), 2, dimnames = list(NULL, c("C", "PC")))
  pv = matrix(, k, 2, dimnames = list(NULL, c("V", "PV")))
  
  start.time <- Sys.time()
  for (it in 1:nit) {
    cat("----------Iteration ", it, " for k = ", k, "----------\n")
    converge = FALSE
    x=0
    # Randomly select from the traning dataset as the initial centroids for k-means algorithm 
    kmeans_centroid = traning[sample(1:nrow(traning), k), 2:3] 
    # Stop if it is converged (centroids are fixed) or 100 runs
    while (x<100 && !converge ) {
      old_kmeans_centroid = kmeans_centroid
      for (i in 1:nrow(traning)) {
        # Calculate distance to the centroid of each cluster
        for (kk in 1:k)
          dm[kk] = sqrt( sum((traning[i, 2:3] - kmeans_centroid[kk, 1:2])^2))
        traning[i, "cluster"] = which.min(dm)
      }
      # Update centroids
      for (kk in 1:k) {
        kmeans_centroid[kk,1] = mean(traning[(traning$cluster == kk), 2])
        kmeans_centroid[kk,2] = mean(traning[(traning$cluster == kk), 3])
      }
      # Converge if the centroids are not changing anymore
      if (identical(old_kmeans_centroid, kmeans_centroid))
        converge = TRUE
      x = x+1
    }
    cat("Plotting prediceted training set to '", filepath ,"/TraningData_PredictedCalss_k_", k,".pdf'\n")
    pdf(paste(filepath, "/TraningData_PredictedCalss_k_", k,".pdf", sep = ""), width=10, height=10, paper="special", onefile=F)
    plot(traning$V2, traning$V3, col=(traning$cluster +10), pch = (traning$cluster +10))
    invisible(dev.off())
    
    # Calculate P(V|C) and P(C)
    for (i in 0:(cl-1)) {
      pcv_traning[(i+1), 1] = i 
      for (j in 1:k) {
        # Probabibity of C, given V = 1, 2,...,k
        pcv_traning[(i+1), (j+1)] = length(which(traning[which(traning$cluster == j), 1] == i)) / length(which(traning$cluster == j))
        # Directly calculate P(C|V), just used to confirm the answer 
        pvc_traning[j, (i+2)] = length(which(traning[which(traning$V1 == i), "cluster"] == j)) / length(which(traning$V1 == i))
      }
      pc[(i+1), 1] = i 
      pc[(i+1), 2] = length(which(traning$V1 == i)) / length(traning$V1)
    }
    # Calculate P(V)
    for (i in 1:k) {
      pv[i, 1] = i 
      pv[i, 2] = length(which(traning$cluster == i)) / length(traning$cluster)
      # Just tagging 
      pvc_traning[i, 1] = i
    }
    cat("P(V|C), Probability of V given a class of five\n")
    print(pvc_traning)
    cat("P(C)\n")
    print(pc)
    # For test set, find the closest k-mean cluster for each sample
    for (i in 1:nrow(testing)) {
      # For testing dataset, Calculate distance to the centroid of each cluster
      for (kk in 1:k)
        dm[kk] = sqrt( sum((testing[i, 2:3] - kmeans_centroid[kk, 1:2])^2))
      testing[i, "cluster"] = which.min(dm)
    }
    
    # Calculate P(C|V) = a P(V|C) P(C)
    pcv_testing = matrix(, length(unique(traning$V1)), (k+1), dimnames = list(NULL, c("C", paste("V",seq(1,k), sep = ''))))
    for (i in 0:(cl-1)) {
      pcv_testing[(i+1), 1] = i
      for (j in 1:k) {
        # P(V|C) P(C) / P(V)
        pcv_testing[(i+1), (j+1)] = (pvc_traning[j, (i+2)] * pc[(i+1), 2]) / pv[j, 2]
      }
    }
    # Predict test set based on P(C|V)
    for (i in 1:nrow(testing)) {
      testing$predict_class[i] = pcv_testing[which.max(pcv_testing[,(testing$cluster[i]+1)]), "C"]
    }
    # Check error rate
    err_rate[it, as.character(k)] = (1 - length(which(testing$predict_class == testing$V1)) / nrow(testing))
  }
  end.time <- Sys.time()
  exe_time[as.character(k), "Time"] = (end.time - start.time) / nit
  exe_time[as.character(k), "Time"]
  avg_and_sd[as.character(k), "Avg"] = mean(err_rate[, as.character(k)])
  avg_and_sd[as.character(k), "SD"] = sd(err_rate[, as.character(k)])
  cat("Average Erro Rate: ", avg_and_sd[as.character(k), "Avg"], "\n")
  cat("Standard deviation of Erro Rate:", avg_and_sd[as.character(k), "SD"], "\n")
  cat("Average Execution Time:", exe_time[as.character(k), "Time"], "\n")
}
cat("============SUMMARY=============\n")
for (k in all_k) {
  cat("k=", k, "\n")
  cat("Average Erro Rate: ", avg_and_sd[as.character(k), "Avg"], "\n")
  cat("Standard deviation of Erro Rate:", avg_and_sd[as.character(k), "SD"], "\n")
  cat("Average Execution Time:", exe_time[as.character(k), "Time"], "\n")
  cat("------------------------------\n")
}

