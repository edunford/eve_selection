#include <RcppArmadillo.h>
//[[Rcpp::depends(RcppArmadillo)]]
using namespace Rcpp;
using namespace arma;

//[[Rcpp::export]]
mat hashdyad(NumericMatrix data, NumericVector hash, int pos) {
  //subset input numeric mat by hash
  mat Xmat(data.begin(), data.nrow(), data.ncol(), false);
  colvec tIdx(hash.begin(), hash.size(), false); 
  mat sub = Xmat.rows(find(tIdx == 1)); 
  int len = sub.size()/5; // determine len of rel iter
  arma::mat temp = arma::zeros(1,2);
  arma::mat col_i = arma::zeros(1,2);
  for( int i = 0; i < len; ++i){
    for( int j = 0; j < len; ++j){
      if((sub(i,0) == sub(j,0)) && (sub(i,1) == sub(j,1)) && (i != j) && ( i<j) && (sub(i,2) != sub(j,2))){
        col_i(0,0) = (pos+i);
        col_i(0,1) = (pos+j);
        temp = join_cols(temp,col_i);
      }
    }
  }
  return temp;
}



/*** R

*/
