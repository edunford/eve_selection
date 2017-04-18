#include <RcppArmadillo.h>
//[[Rcpp::depends(RcppArmadillo)]]
using namespace Rcpp;
using namespace arma;

//[[Rcpp::export]]
mat hashdyad(NumericMatrix data, NumericVector hash) {
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
        col_i(0,0) = i+1;
        col_i(0,1) = j+1;
        temp = join_cols(temp,col_i);
      }
    }
  }
  return temp;
}

//[[Rcpp::export]]
arma::vec hashiter(
    arma::vec hash,
    int len,
    std::vector<int> x
){
  for( int h = 0; h < len; h++){
    if(hash(h) >= 2){
      x x.insert(x.end(),1)
    }
    if(hash(h) < 2){
      x = x.insert(x.end(),0)
    }
  }
  return x;
  // arma::vec t = data(4)
  //for ( h = 0; h < len; h++){}
}


/*** R

*/
