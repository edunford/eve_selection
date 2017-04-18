#include <RcppArmadillo.h>
//[[Rcpp::depends(RcppArmadillo)]]
using namespace Rcpp;
using namespace arma;

//[[Rcpp::export]]
mat hashdyad2(NumericMatrix data, arma::vec hash) {// doesn't work
  int hash_len = hash.size();
  arma::mat temp = arma::zeros(1,2);
  for(int h = 1; h < hash_len; ++h){
    arma::vec tmp_bool = hash==h;
    //subset input numeric mat by hash
    mat Xmat(data.begin(), data.nrow(), data.ncol(), false);
    colvec tIdx(tmp_bool.begin(), tmp_bool.size(), false); 
    mat sub = Xmat.rows(find(tIdx == 1)); 
    int len = sub.size()/5; // determine len of rel iter
    arma::mat col_i = arma::zeros(1,2);
    for( int i = 0; i < len; ++i){
      for( int j = 0; j < len; ++j){
        if((sub(i,0) == sub(j,0)) && (sub(i,1) == sub(j,1)) && (i != j) && ( i<j) && (sub(i,2) != sub(j,2))){
          col_i(0,0) = i+1;
          col_i(0,1) = j+1;
          temp = join_cols(temp,col_i);
        }
      }
    }
  }
  return temp;
}



/*** R

*/
