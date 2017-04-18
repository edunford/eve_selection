#include <RcppArmadillo.h>
//[[Rcpp::depends(RcppArmadillo)]]
using namespace Rcpp;
using namespace arma;

//[[Rcpp::export]]
mat hashdyadLT(NumericMatrix data, NumericVector hash, int pos) {
  //subset input numeric mat by hash
  mat Xmat(data.begin(), data.nrow(), data.ncol(), false);
  colvec tIdx(hash.begin(), hash.size(), false); 
  mat sub = Xmat.rows(find(tIdx == 1)); 
  int len = sub.size()/5; // determine len of rel iter
  int q = len*(len-1)/2; // draw the precise length of the output matrix
  int p = 0; // set counter 
  arma::mat temp = arma::zeros(q,2); // generate matrix of zeros
  for( int i = 0; i < (len-1); ++i){
    for(int j = (i+1); j < len; ++j){ // iterate only over the lower portion of the matrix
      if((sub(i,2) != sub(j,2))){
        temp(p,0) = (pos+i);
        temp(p,1) = (pos+j);
        p += 1; // counter
      }
    }
  }
  return temp;
}



/*** R

*/
