#==============================
#  Author: Ching-Hsiang Chu
#  Email: chu.368@osu.edu
#==============================

NDim_Gaussian = function(x, m, c, n) {
  c = matrix(c, n, n)
  return ( exp(-( t(t(x - m)) %*% solve(c) %*% t(x - m) ) / 2) / (sqrt( det(c) * ((2*pi)^n)) ) )
}

OneDim_Gassian = function(x, m, c) {
  return (exp(-((x-m)^2)/(2*(c^2))) / (c*sqrt(2*pi)))
}

# Load Training data and testing data
train = read.table(file="./train.txt", header = FALSE, sep = " ")
test = read.table(file="./test.txt", header = FALSE, sep = " ")

lenTrain = nrow(train)
# Levels: ah ao ax ay eh ey ih iy ow uw
#         1  2  3  4  5  6  7  8  9 10
class = unique(train$V3)
train$V3 = as.numeric(train$V3)
#plot(train$V1, train$V2, col = train$V3)

### Part A: create a classifier that uses a single Gaussian per vowel.
cat("###################################\n")
cat("##### Part A: Singel Gaussian #####\n")
cat("###################################\n")
# Build Gaissians model based on training data, for each vowel
mean = matrix(nrow=10, ncol=2)
cov = list(cov(train[which(train$V3 == 1), 1:2]), cov(train[which(train$V3 == 2), 1:2]), cov(train[which(train$V3 == 3), 1:2]), cov(train[which(train$V3 == 4), 1:2]),
           cov(train[which(train$V3 == 5), 1:2]), cov(train[which(train$V3 == 6), 1:2]), cov(train[which(train$V3 == 7), 1:2]), cov(train[which(train$V3 == 8), 1:2]),
           cov(train[which(train$V3 == 9), 1:2]), cov(train[which(train$V3 == 10), 1:2]))
p_class = vector(mode = "numeric", 10)
for (i in 1:10) {
  mean[i,1] = mean(train[which(train$V3 == i), 1])
  mean[i,2] = mean(train[which(train$V3 == i), 2])
  p_class[i] = length(which(train$V3 == i)) / lenTrain
}

testLen = nrow(test)
singleClassify = function(dia) {
  test$predict = ""
  p_f = vector(mode = "numeric", 10)
  n_correct = 0
  for (i in 1:testLen) {
    for (j in 1:10) {
      tmp_cov = do.call(rbind, cov[j])
      if (dia == 1)
        tmp_cov[1,2] = tmp_cov[2,1] = 0
      p_f[j] = NDim_Gaussian(test[i,1:2], mean[j,], tmp_cov, 2) * p_class[j]
      #p_f[j] = OneDim_Gassian(test[i,1], mean[j,1], tmp_cov[j,1]) * OneDim_Gassian(test[i,2], mean[j,2], tmp_cov[j,2]) * p_class[j]
    }
    # Pick up the one has highest probability
    test$predict[i] = as.character(class[which.max(p_f)])
    if (test$predict[i] == test$V3[i])
      n_correct = n_correct + 1
  }
  
  accuracy = n_correct / testLen
  cat("================================================\n")
  cat("=== Part A: Accuracy is ", accuracy*100, " % ===\n")
  cat("================================================\n")
  cat("Vowel\tCorrect\tTotal\tAccuracy\n")
  for (w in class) {
    cat(w, "\t", length(which(test[which(test$V3==w), 4] == w)), "\t", length(which(test$V3==w)), "\t", (length(which(test[which(test$V3==w), 4] == w))/length(which(test$V3==w))), "\n")
  }
}
cat("##### Part A: Diagonal covariance matrix #####\n")
singleClassify(1)
cat("##### Part A: Full covariance matrix #####\n")
singleClassify(0)

### Part B: MoG using EM
cat("################################\n")
cat("##### Part B: MoG using EM #####\n")
cat("################################\n")
classify = function(n) {
  test$predict = ""
  p_f = vector(mode = "numeric", 10)
  n_correct = 0
  for (i in 1:testLen) {
    for (j in 1:10) {
      for (k in 1:n) {
        g = OneDim_Gassian(test[i,1], g_mean[(k-1)*10+j,1], g_sd[(k-1)*10+j,1]) * OneDim_Gassian(test[i,2], g_mean[(k-1)*10+j,2], g_sd[(k-1)*10+j,2])
        p_f[j] = p_f[j] + g*p_hidden_vowel[j,k]  
      }
      #g1 = OneDim_Gassian(test[i,1], g_mean[j,1], g_sd[j,1]) * OneDim_Gassian(test[i,2], g_mean[j,2], g_sd[j,2]) #*EM_p_g[1]
      #g2 = OneDim_Gassian(test[i,1], g_mean[10+j,1], g_sd[10+j,1]) * OneDim_Gassian(test[i,2], g_mean[10+j,2], g_sd[10+j,2]) #*EM_p_g[2]
      p_f[j] = p_f[j] * p_class[j]
    }
    # Pick up the one has highest probability
    test$predict[i] = as.character(class[which.max(p_f)])
    if (test$predict[i] == test$V3[i])
      n_correct = n_correct + 1
  }
  accuracy = n_correct / testLen
  
  cat("Accuracy is ", accuracy*100, " %\n")
  cat("================================================\n")
  cat("Vowel\tCorrect\tTotal\tAccuracy\n")
  for (w in class) {
    cat(w, "\t", length(which(test[which(test$V3==w), 4] == w)), "\t", length(which(test$V3==w)), "\t", (length(which(test[which(test$V3==w), 4] == w))/length(which(test$V3==w))), "\n")
  }
  cat("================================================\n")
}
max_iter = 1000
EM = function(EM_train, c, n) {
  # Initialization
  EM_p_g = vector(mode = "numeric", n)
  #rn = sample(0:100, 1)
  v1_mean = mean(EM_train$V1)
  v2_mean = mean(EM_train$V2)
  v1_sd = sd(EM_train$V1)
  v2_sd = sd(EM_train$V2)
  EM_hidden_mean = matrix(nrow=n, ncol=2)
  EM_hidden_sd = matrix(nrow=n, ncol=2)#list(cov(EM_train), cov(EM_train)) #
  for (i in 1:n) {
    # To simplify, each gaussian has same probability by default
    EM_p_g[i] = 1/n
    EM_hidden_mean[i,] = c(v1_mean+sample(-100:100,1) , v2_mean+sample(-100:100,1))
    EM_hidden_sd[i,] = c(v1_sd+sample(-10:10,1) , v2_sd+sample(-10:10,1))
  }
  iter = 0
  EM_train$g = ""
  lenTrain = nrow(EM_train)
  old_lnlike = -1
  lnlike = 0
  converge = 0
  while (iter < max_iter && !converge) {
    iter = iter + 1
    # MoG: Expectation
    p_v_f = matrix(nrow = lenTrain, ncol = n)
    N = vector(mode = "numeric", n)
    for (i in 1:lenTrain) {
      alpha = 0
      for (j in 1:n) {
        #tmp_cov = do.call(rbind, EM_hidden_sd[j])
        #EM_hidden_sd[1,2] = EM_hidden_sd[2,1] = 0
        #alpha = alpha +NDim_Gaussian(EM_train[i,1], EM_hidden_mean[j,], EM_hidden_sd, 2)
        alpha = alpha + OneDim_Gassian(EM_train[i,1], EM_hidden_mean[j,1], EM_hidden_sd[j,1]) * 
                          OneDim_Gassian(EM_train[i,2], EM_hidden_mean[j,2], EM_hidden_sd[j,2]) * EM_p_g[j]
      }
      for (j in 1:n) {
        p_v_f[i,j] = OneDim_Gassian(EM_train[i,1], EM_hidden_mean[j,1], EM_hidden_sd[j,1]) * 
                        OneDim_Gassian(EM_train[i,2], EM_hidden_mean[j,2], EM_hidden_sd[j,2]) * EM_p_g[j]    
        p_v_f[i,j] = p_v_f[i,j] / alpha
        N[j] = N[j] + p_v_f[i,j]
      }
      EM_train$g[i] = which.max(p_v_f[i,])
    }
    for (i in 1:n) {
      g_mean[(i-1)*10+c,] <<- EM_hidden_mean[i,]
      g_sd[(i-1)*10+c,] <<- EM_hidden_sd[i,]
    }
    #cat("Iter ", iter, ": ", classify(EM_hidden_mean, EM_hidden_sd, p_hidden_vowel, p_class,class,test, EM_train))
    # MoG: Maximization
    EM_p_g = N / lenTrain
    #tmp_EM_train = EM_train
    for (i in 1:n) {
      sum = c(0,0)
      sqrtsum = c(0,0)
      for (j in 1:lenTrain) {
        #tmp_EM_train$V1[j] = p_v_f[j,i]*EM_train$V1[j]
        #tmp_EM_train$V2[j] = p_v_f[j,i]*EM_train$V2[j]
        sum[1] = sum[1] + p_v_f[j,i]*EM_train$V1[j]
        sqrtsum[1] = sqrtsum[1] + p_v_f[j,i]*(EM_train$V1[j]^2)
        sum[2] = sum[2] + p_v_f[j,i]*EM_train$V2[j]
        sqrtsum[2] = sqrtsum[2] + p_v_f[j,i]*(EM_train$V2[j]^2)
      }
      #sum[0] = sum(tmp_EM_train$V1)
      #sum[1] = sum(tmp_EM_train$V2)
      EM_hidden_mean[i,] = sum / N[i]
      #EM_hidden_sd[i] = cov(tmp_EM_train)
      EM_hidden_sd[i,1] = sqrt( ((sqrtsum[1]/N[i]) - ((sum[1]/N[i]))^2 ) )
      EM_hidden_sd[i,2] = sqrt( ((sqrtsum[2]/N[i]) - ((sum[2]/N[i]))^2 ) )
    }
    
    # Calculate log-likelihood
    old_lnlike = lnlike
    lnlike = 0
    for (i in 1:lenTrain) {
      sum_class = 0
      for (j in 1:n) {
        sum_class = sum_class + EM_p_g[j] * OneDim_Gassian(EM_train[i,1], EM_hidden_mean[j,1], EM_hidden_sd[j,1])*OneDim_Gassian(EM_train[i,2], EM_hidden_mean[j,2], EM_hidden_sd[j,2])
      }
      lnlike = lnlike + log(sum_class,2)
    }
    if ( iter > 1 && old_lnlike >= lnlike)
      converge = 1
      #cat("not max in iteration ", iter, ": ", old_lnlike, " vs ", lnlike, "\n")
  } 
  cat("\tClass(vowel) ", c," took ", iter, " iterations to converge\n")
  return (EM_train$g)
}

# Declare Global variables 
for (n in 2:5) {
  cat("================================================\n")
  cat("- Using ", n, " mixtures per vowel\n")
  cat("================================================\n")
  max_iter = 500*n
  g_mean = matrix(nrow=n*10, ncol=2)
  g_sd = matrix(nrow=n*10, ncol=2)
  p_hidden_vowel = matrix(nrow = 10, ncol=n)
  train$g = ""
  for (c in 1:10) {
    train[which(train$V3 == c),4] = EM( train[which(train$V3 == c),], c, n )
  }
  # Calculate P( MV | V ), proabability of cluster/gaussian, given Vowel
  for (i in 1:10) {
    for(j in 1:n) {
      p_hidden_vowel[i,j] = length(which(train[which(train$V3==i),4] == j)) / length(which(train$V3==i))
    }
  }
  classify(n)
}
