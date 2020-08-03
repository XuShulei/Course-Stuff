traning = read.table(file="./training.txt", sep="\t")
testing = read.table(file="./testing.txt", sep="\t")

all_k = c(100) #c(2, 5, 6, 8, 10, 12, 15, 20, 50)
nit=10
cl = length(unique(traning$V1))

traning$cluster = row(traning)[,1]
testing$cluster = row(testing)[,1]
testing$predict_class = row(testing)[,1]
err_rate = matrix(, nit, length(all_k), dimnames = list(NULL, all_k))
avg_and_sd = matrix(, length(all_k), 2, dimnames = list(all_k, c("Avg", "SD")) )
exe_time = matrix(, length(all_k), 1, dimnames = list(all_k, c("Time")) )

for (k in all_k) {
  # Declare/Initialize everything we need
  dm = matrix()
  pcv_traning = matrix(, length(unique(traning$V1)), (k+1), dimnames = list(NULL, c("C", paste("V",seq(1,k), sep = ''))))
  pvc_traning = matrix(, k, (length(unique(traning$V1))+1), dimnames = list(NULL, c("V", paste("C", seq(0,(length(unique(traning$V1))-1)), sep=''))))
  pc = matrix(, length(unique(traning$V1)), 2, dimnames = list(NULL, c("C", "PC")))
  pv = matrix(, k, 2, dimnames = list(NULL, c("V", "PV")))
  
  start.time <- Sys.time()
  for (it in 1:nit) {
    plot(traning$V2, traning$V3, col=(traning$V1 + 10))
    converge = FALSE
    x=0
    #Randomly select from the traning dataset 
    kmeans_centroid = traning[sample(1:nrow(traning), k), 2:3] 
    # Stop if it is converged or 100 runs
    while (x<100 && !converge ) {
      old_kmeans_centroid = kmeans_centroid
      for (i in 1:nrow(traning)) {
        # Calculate distance to the centroid of each cluster
        for (kk in 1:k)
          dm[kk] = sqrt( sum((traning[i, 2:3] - kmeans_centroid[kk, 1:2])^2))
        traning[i, "cluster"] = which.min(dm)
      }
      for (kk in 1:k) {
        kmeans_centroid[kk,1] = mean(traning[(traning$cluster == kk), 2])
        kmeans_centroid[kk,2] = mean(traning[(traning$cluster == kk), 3])
      }
      # Converge if the centroids are not changing anymore
      if (identical(old_kmeans_centroid, kmeans_centroid))
        converge = TRUE
      x = x+1
    }
    x
    plot(traning$V2, traning$V3, col=(traning$cluster +10))
    
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
      # Directly calculate P(C|V), just used to confirm the answer 
      pvc_traning[i, 1] = i
      #for (j in 0:(cl-1)) {
      #  pvc_traning[i, (j+2)] = length(which(traning[which(traning$cluster == i), 1] == j)) / length(which(traning$cluster == i))
      #}
    }
    
    # For test set, find the closest k-mean centroid for each sample
    for (i in 1:nrow(testing)) {
      # For testing dataset, Calculate distance to the centroid of each cluster
      for (kk in 1:k)
        dm[kk] = sqrt( sum((testing[i, 2:3] - kmeans_centroid[kk, 1:2])^2))
      testing[i, "cluster"] = which.min(dm)
    }
    
    # Calculate P(C|V) = a P(V|C) P(C)
    pcv_testing = matrix(, length(unique(traning$V1)), (k+1))
    colnames(pcv_testing) = c("C", paste("V",seq(1,k), sep = ''))
    for (i in 0:(cl-1)) {
      pcv_testing[(i+1), 1] = i
      for (j in 1:k) {
        pcv_testing[(i+1), (j+1)] = (pvc_traning[j, (i+2)] * pc[(i+1), 2]) / pv[j, 2]
      }
    }
    # Predict test set
    for (i in 1:nrow(testing)) {
      testing$predict_class[i] = pcv_testing[which.max(pcv_testing[,(testing$cluster[i]+1)]), "C"]
    }
    err_rate[it, as.character(k)] = (1 - length(which(testing$predict_class == testing$V1)) / nrow(testing))
  }
  end.time <- Sys.time()
  exe_time[as.character(k), "Time"] = (end.time - start.time)
  exe_time[as.character(k), "Time"]
  avg_and_sd[as.character(k), "Avg"] = mean(err_rate[, as.character(k)])
  avg_and_sd[as.character(k), "SD"] = sd(err_rate[, as.character(k)])
}
exe_time
