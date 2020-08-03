normalize = function(x) {
  num = x - min(x)
  denom = max(x) - min(x)
  return (num/denom)
}

k=10

iris_ = read.csv(file="./Iris.csv", header = TRUE, sep = ",")
summary(iris_)

iris_ = data.matrix(iris_)
#iris_normalized = (iris_[1:4] - min(iris_[1:4] )) / (max(iris_[1:4]) - min(iris_[1:4]))

df_l1 = matrix(, nrow = 150, ncol = 150)
df_l2 = matrix(, nrow = 150, ncol = 150)

for(i in 1:150) {
  for(j in 1:150) {
    df_l1[i,j] = sum((iris_[i, 1:4] - iris_[j, 1:4]))
    df_l2[i,j] = sqrt(sum((iris_[i, 1:4] - iris_[j, 1:4])^2)) 
  }
}

out_l1 = data.frame()
out_l2 = data.frame()

for(i in 1:150) {
  sortedRow = sort.list(df_l1[i,1:150])
  sortedRow2 = sort.list(df_l2[i,1:150])
  for (kk in 1:k) {
    out_l1[i, 2*kk-1] = sortedRow[kk+1]
    out_l1[i, 2*kk] = df_l1[i, sortedRow[kk+1] ]
    out_l2[i, 2*kk-1] = sortedRow2[kk+1]
    out_l2[i, 2*kk] = df_l1[i, sortedRow2[kk+1] ]
  }
}

colLabel = c()
for (kk in 1:k) {
  colLabel[(2*kk-1)] = switch(paste(kk), "1" = "1st", "2" = "2nd", "3" = "3rd", paste(kk,"th",sep=""))
  colLabel[(2*kk)] = paste(kk, "-dist", sep="")
}

colnames(out_l1) = colLabel
colnames(out_l2) = colLabel

out_l1
out_l2

write.csv(out_l1,file="./iris_out_l1.csv")
write.csv(out_l2,file="./iris_out_l2.csv")
