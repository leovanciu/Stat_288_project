data {
  int<lower=1> N;
  int<lower=1> p;
  matrix[N,p] X;
  int<lower=0> y[N];            
  vector<lower=0>[N] E;          
}

transformed data {
  vector[N] log_E = log(E);
}

parameters {
  real beta0;           
  vector[p] beta;
}

model {
  vector[N] linear_predictor = log_E + beta0 + X * beta;
  // Priors
  beta0 ~ normal(0.0, 10.0);
  beta ~ normal(0.0, 10.0);
  // Model vectorized likelihood
  y ~ poisson_log(linear_predictor); 
}
// 
// generated quantities {
//   vector[N] mu=exp(log_E + beta0 + beta1 * to_vector(x) + X*beta);
//   // vector[N] lik;
//   // vector[N] log_lik;
//   // 
//   // for(i in 1:N){
//   //   lik[i] = exp(poisson_lpmf(y[i] | mu[i] ));
//   //   log_lik[i] = poisson_lpmf(y[i] | mu[i] );
//   // }
// }
