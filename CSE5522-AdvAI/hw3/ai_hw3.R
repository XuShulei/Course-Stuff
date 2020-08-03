normalize = function(v) {
  v = v / sum(v)
  return (v)
}

entropy = function(p) {
  return (ifelse(length(which(p == 0)) > 0, 0, sum(-p*log(p))))
}

dec_stump_predict = function(examples, testing) {
  length_testing = nrow(testing)
  length_ex = nrow(examples)
  attr_length = ncol(examples) -1
  class_level = unique(examples[,9])
  n_class = length(class_level)
  best_attr = 1
  max_gain = 0
  for (i in 1:attr_length) {
    attr_level = unique(examples[,i])
    n_attr_level = length(attr_level)
    p = vector(mode = "numeric", n_attr_level)
    for (j in 1:n_attr_level)
      p[j] = length(which(examples[,i] == attr_level[j])) / length_ex
    base_entropy = entropy(p)
    sum_entropy = 0
    for (j in 1:n_attr_level) {
      sum_entropy = sum_entropy + p[j]*entropy(c(length(which( subset(examples, examples[,i] == attr_level[j])[,9] == 1 )) / length(which(examples[,i] == attr_level[j])) 
                                          ,(length(which( subset(examples, examples[,i] == attr_level[j])[,9] == -1 )) / length(which(examples[,i] == attr_level[j])))))
    }
    gain = base_entropy - sum_entropy
    if (gain > max_gain) {
      max_gain = gain
      best_attr = i
    }
  }
  attr_level = unique(examples[,best_attr])
  n_attr_level = length(attr_level)
  out = matrix(nrow = 2, ncol = n_attr_level, dimnames = list(c(1,-1), attr_level))
  for (j in 1:n_attr_level) {
    out["1",as.character(attr_level[j])] = length(which( subset(examples, examples[,best_attr] == attr_level[j])[,9] == 1 )) / length(which(examples[,best_attr] == attr_level[j]))
    out["-1",as.character(attr_level[j])] = length(which( subset(examples, examples[,best_attr] == attr_level[j])[,9] == -1 )) / length(which(examples[,best_attr] == attr_level[j]))
  }
  # Classify testing data
  predicted_class = matrix(nrow = length_testing, ncol = 1)
  avg_prob = 0
  for (i in 1:length_testing) {
    #predicted_class[i] = ifelse ( (runif(1) > out["1", as.character(testing[i,best_attr])]), 1, -1 )
    predicted_class[i] = ifelse ( (out["1", as.character(testing[i,best_attr])] > out["-1", as.character(testing[i,best_attr])]), 1, -1 )
    avg_prob = avg_prob + out[as.character(testing[i,9]), as.character(testing[i,best_attr])]
  }
  avg_prob = avg_prob / length_testing
  accurary = length(which(testing[,9] == predicted_class[,1])) / length_testing
  return (mean(accurary))
}

dec_stump = function(examples) {
  length_ex = nrow(examples)
  attr_length = ncol(examples) -1
  class_level = unique(examples[,9])
  n_class = length(class_level)
  best_attr = 1
  max_gain = 0
  for (i in 1:attr_length) {
    attr_level = unique(examples[,i])
    n_attr_level = length(attr_level)
    p = vector(mode = "numeric", n_attr_level)
    for (j in 1:n_attr_level)
      p[j] = length(which(examples[,i] == attr_level[j])) / length_ex
    base_entropy = entropy(p)
    sum_entropy = 0
    for (j in 1:n_attr_level) {
      sum_entropy = sum_entropy + p[j]*entropy(c(length(which( subset(examples, examples[,i] == attr_level[j])[,9] == 1 )) / length(which(examples[,i] == attr_level[j])) 
                                                 ,(length(which( subset(examples, examples[,i] == attr_level[j])[,9] == -1 )) / length(which(examples[,i] == attr_level[j])))))
    }
    gain = base_entropy - sum_entropy
    if (gain > max_gain) {
      max_gain = gain
      best_attr = i
    }
  }
  attr_level = unique(examples[,best_attr])
  n_attr_level = length(attr_level)
  out = matrix(nrow = 2, ncol = n_attr_level, dimnames = list(c(1,-1), attr_level))
  for (j in 1:n_attr_level) {
    out["1",as.character(attr_level[j])] = length(which( subset(examples, examples[,best_attr] == attr_level[j])[,9] == 1 )) / length(which(examples[,best_attr] == attr_level[j]))
    out["-1",as.character(attr_level[j])] = length(which( subset(examples, examples[,best_attr] == attr_level[j])[,9] == -1 )) / length(which(examples[,best_attr] == attr_level[j]))
  }
  # Classify training data
  predicted_class = matrix(nrow = length_ex, ncol = 1)
  avg_prob = 0
  for (i in 1:length_ex) {
    #predicted_class[i] = ifelse ( (runif(1) > out["1", as.character(testing[i,best_attr])]), 1, -1 )
    predicted_class[i] = ifelse ( (out["1", as.character(examples[i,best_attr])] > out["-1", as.character(examples[i,best_attr])]), 1, -1 )
  }
  return (predicted_class)
}

# Read training and testing sets
training = read.table(file="./game_codedata_train.dat", sep=",")
testing = read.table(file="./game_codedata_test.dat", sep=",")
length_training = nrow(training)
length_testing = nrow(testing)

# Classify testing by using original training set (unweighted)
dec_stump_predict(training, testing)

accurary = vector(mode="numeric", 50)

for (K in 1:50) {
  examples = data.matrix(training)
  example_indices = seq(1,length_training)
  
  # N example weights
  w = vector(mode = "numeric", length_training)
  w[] = 1/length_training
  # K hypotheses
  h = matrix(nrow = K, ncol = length_training)
  # K hypotheses weights
  z = vector(mode = "numeric", K)
  
  for (k in 1:K) {
    h[k,] = dec_stump(examples)
    error = 0
    for (j in 1:length_training) {
      if (h[k, j] != training[example_indices[j],9])
        error = error + w[j]
    }
    for (j in 1:length_training) {
      if (h[k, j] == training[example_indices[j],9])
        w[j] = w[j]*(error/(1-error))
    }
    w = normalize(w)
    z[k] = log(((1-error)/error))
    # Generate new examples based on the weights
    example_indices = sample(1:length_training, length_training, replace = TRUE, w)
    examples = training[example_indices,]
  }
  weighted_majority = matrix(nrow = length_training, ncol = 1)
  for (j in 1:length_training) {
    h1 = sum(z[which(h[,j] == 1)])
    h2 = sum(z[which(h[,j] == -1)])
    weighted_majority[j] = ifelse(h1 > h2, 1, -1)
  }
  new_training = training
  new_training[,9] = weighted_majority
  # Classify testing by using weighted training set
  accurary[K] = dec_stump_predict(new_training, testing)
}
accurary
plot(1:50, accurary, xlab = "k", ylab = "Accuracy")

