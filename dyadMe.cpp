#include <RcppArmadillo.h>
//[[Rcpp::depends(RcppArmadillo)]]
using namespace Rcpp;
//[[Rcpp::export]]
arma::mat dyadMe(
    arma::mat data
){
  int len = data.size()/3;
  arma::mat temp = arma::zeros(1,2);
  arma::mat col_i = arma::zeros(1,2);
  for( int i = 0; i < len; ++i){
    for( int j = 0; j < len; ++j){
      if((data(i,0) == data(j,0)) && (data(i,1) == data(j,1)) && (i != j) && ( i<j) && (data(i,2) != data(j,2))){
        col_i(0,0) = i+1;
        col_i(0,1) = j+1;
        temp = join_cols(temp,col_i);
      }
    }
  }
  return temp;
}



