
# expected information is used in score test for consistency
# http://www.stat.berkeley.edu/~census/mle3.pdf
# The American Statistician vol. 61 (2007) pp. 291–295

LM.test <- function(rdata, edata, omega, par, se, level, b.ci, fig){

  null.mle <- find.null.tsls(rdata, edata)
  ap <- align.parameter(null.mle)
  par.mle <- ap$par
  par.pos <- ap$par.pos

  name.bet.z <- paste0('bet.', edata$vz)

  J0 <- -hessian0(par.mle, rdata, edata, omega, par.pos)
  #J <- -hessian(par.mle, rdata, edata, par.pos)
  sc <- score(par.mle, rdata, edata, par.pos)[name.bet.z]

  id.bet <- which(colnames(J0) == name.bet.z)
  if(is.null(rdata$vx) & is.null(rdata$vy)){
    lm.stat <- sc^2 * solve(J0)[id.bet, id.bet]
    #lm.stat <- sc^2 * solve(J)[id.bet, id.bet]
  }else{
    I0 <- fisher.info0(par.mle, rdata, edata, omega, par.pos)

    v <- cbind(-J0[id.bet,-id.bet] %*% solve(J0[-id.bet, -id.bet]), 1)
    colnames(v)[ncol(v)] <- name.bet.z
    v <- v[, colnames(I0), drop = FALSE]

    lm.stat <- sc^2/(v %*% I0 %*% t(v))
  }
  p.lmt <- pchisq(lm.stat, df = 1, lower.tail = FALSE)

  ci <- LMT.conf.int(rdata, edata, omega, par, se, level, fig)

  in.ci <- check.LMT.ci(rdata, edata, omega, level, b.ci)

  list(p.lmt = p.lmt, ci = ci, in.ci = in.ci, stat = lm.stat)

}
