#' Constant Volatility Test for WFP
#' 
#' @export
#' @param ntests Positive integer - number of randomly selected constant-volatility transformations (CVTs) for heteroskedasticity testing
#' @param R Compositional matrix - columns must be species and rows timepoints.
#' @param regress Either "f" or "t" - whether regrssion should be performed on the state of the CVT or on the time.
#' @param formula Formula for regression of the jumps in CVTs vs time or state of cvts. Should be in form "DF ~ f" or "DF ~ tm + I(tm^2)" etc.
#' @param varformla Input argument for \code{bptest}
#' @return vector of p-values from Bruesh-Pagan heteroskedasticity tests.
#' @examples
#' library(plotrix)
#' 
#' set.seed(2)
#' 
#' #this takes ~20-0 seconds
#' wfp <- WFP(nSpecies=15,lambda=25)
#' 
#' t <- wfp[[1]]
#' R <- wfp[[2]]
#' 
#' par(mfrow=c(1,2))
#' stackpoly(R,stack=T,main='Community Dynamics',xlab='time',ylab='Abundance')
#' 
#' #This will take ~10 seconds
#' Pvals <- CVTest(1000,R)
#' 
#' plot(ecdf(Pvals),xlab='P',ylab='#',main='Washburne Test P-value histogram')
#' lines(c(0,1),c(0,1),lwd=4,col='blue')
#' 
#' #Uncorrected KS test
#' ks <- ks.test(Pvals,runif(length(Pvals)))
#' ks$p.value
CVTest <- function(ntests,R,regress='f',formula=NULL,varformula=NULL,...){
  
  if (!(regress %in% c('f','time'))){stop('unknown inputt "regress" - must be either "f" or "time"')}
  if (is.null(formula)){
    if (regress=='f'){
      formula=DF~f+I(f^2)
    } else 
      formula=DF~tm
  }
  if (is.null(varformula)){
    if (regress=='f'){
      varformula=DF~f+I(f^2)
    } else {
      varformula=DF~tm+I(tm^2)
      }
  }
  
  
  
  p <- rep(0,ntests)
  b <- vector('list',ntests)
  for (nn in 1:ntests){
    
    cvt <- drawCVT(R)
    f <- cvt$f
    DF <- cvt$DF

    if (regress=='f'){
      dataset=model.frame(formula,environment())
      model <- lm(formula,dataset)
      # p[nn] <- bptest(model,varformula)$p.value
      p[nn] <- bptest(model,varformula,...)$p.value
      DF <- model$residuals^2
      b[[nn]] <- glm(varformula)$coefficients
    } else {
      tm <- 1:m
      dataset=model.frame(formula,environment())
      model <- lm(formula,dataset)
      # p[nn] <- bptest(model,varformula)$p.value
      p[nn] <- bptest(model,varformula,...)$p.value
      b[[nn]] <- glm(varformula)$coefficients
    }
    
  }
  
  return(p)
}