#' Deprecated functions of plm
#' 
#' `dynformula`, `pht`, `plm.data`, and `pvcovHC` are
#' deprecated functions which could be removed from \pkg{plm} in a near future.
#' 
#' `dynformula` was used to construct a dynamic formula which was the
#' first argument of `pgmm`. `pgmm` uses now multi-part formulas.
#' 
#' `pht` estimates the Hausman-Taylor model, which can now be estimated
#' using the more general `plm` function.
#' 
#' `plm.data` is replaced by `pdata.frame`.
#' 
#' `pvcovHV` is replaced by `vcovHC`.
#'
#' `detect_lin_dep` is replaced by `detect.lindep`.
#' 
#' @name plm-deprecated
#' @param formula a formula,
#' @param lag.form a list containing the lag structure of each variable in the
#' formula,
#' @param diff.form a vector (or a list) of logical values indicating whether
#' variables should be differenced,
#' @param log.form a vector (or a list) of logical values indicating whether
#' variables should be in logarithms.
#' @param object,x an object of class `"plm"`,
#' @param data a `data.frame`,
#' @param \dots further arguments.
#' @param indexes a vector (of length one or two) indicating the (individual
#' and time) indexes (see Details);
#' @param lhs see Formula
#' @param rhs see Formula
#' @param model see plm
#' @param effect see plm
#' @param theta the parameter of transformation for the random effect model
#' @param cstcovar.rm remove the constant columns or not
#' 
NULL

#' @rdname plm-deprecated
pvcovHC <- function(x, ...){
  .Deprecated(new = "pvcovHC", msg = "'pvcovHC' is deprecated, use 'vcovHC' instead for same functionality",
              old = "vcovHC")
  UseMethod("vcovHC")
}


# plm.data() is now deprecated (since February 2017). Need to keep it in package
# for backward compatibility of users' code out there and packages, especially 
# for package 'systemfit'.
#
# While plm.data() was a 'full function' once, it now is now using
# pdata.frame() and re-works the properties of the "plm.dim" objects
# original created by the 'full' plm.data() function.  The 'full'
# plm.data() function is kept non-exported as plm.data_depr_orig due
# to reference and testing (see tests/test_plm.data.R)

#' @rdname plm-deprecated
#' @export
plm.data <- function(x, indexes = NULL) {

  .Deprecated(new = "pdata.frame", msg = "use of 'plm.data' is discouraged, better use 'pdata.frame' instead",
              old = "plm.data")

  # the class "plm.dim" (which plm.data creates) deviates from class "pdata.frame":
  #    * always contains the indexes (in first two columns (id, time))
  #    * does not have fancy rownames
  #    * always coerces strings to factors
  #    * does not have index attribute
  #    * leaves in constant columns (albeit the 'full' implementation printed a msg about dropping those ...)
  #
  #  -> call pdata.frame accordingly and adjust afterwards
  orig_col_order <- colnames(x)
  
  x <- pdata.frame(x, index = indexes,
                      drop.index = FALSE,
                      row.names = FALSE,
                      stringsAsFactors = TRUE,
                      replace.non.finite = TRUE,
                      drop.NA.series = TRUE,
                      drop.const.series = FALSE)

  # determine position and names of index vars in pdata.frame
  pos_indexes <- pos.index(x)
  names_indexes <- names(pos_indexes) # cannot take from arg 'indexes' as it could be only the index for id
  
  # the class "plm.dim" does not have the index attribute -> remove
  attr(x, "index") <- NULL
  # remove class 'pdata.frame' to prevent any dispatching of special methods on object x
  class(x) <- setdiff(class(x), "pdata.frame")
  
  # class "plm.dim" always has indexes in first two columns (id, time)
  # while "pdata.frame" leaves the index variables at it's place (if not dropped at all with drop.index = T)
  x <- x[ , c(names_indexes, setdiff(orig_col_order, names_indexes))]
  
  # set class
  class(x) <- c("plm.dim", "data.frame")
  return(x)
}

### pht

lev2var <- function(x, ...){
  # takes a data.frame and returns a vector of variable names, the
  # names of the vector being the names of the effect
  
  is.fact <- sapply(x, is.factor)
  if (sum(is.fact) > 0){
    not.fact <- names(x)[!is.fact]
    names(not.fact) <- not.fact
    x <- x[is.fact]
    wl <- lapply(x,levels)
    # nl is the number of levels for each factor
    nl <- sapply(wl,length)
    # nf is a vector of length equal to the total number of levels
    # containing the name of the factor
    nf <- rep(names(nl),nl)
    result <- unlist(wl)
    names(result) <- nf
    result <- paste(names(result),result,sep="")
    names(nf) <- result
    c(nf, not.fact)
  }
  else{
    z <- names(x)
    names(z) <- z
    z
  }
}


#' Hausman--Taylor Estimator for Panel Data
#' 
#' The Hausman--Taylor estimator is an instrumental variable estimator without
#' external instruments (function deprecated).
#' 
#' `pht` estimates panels models using the Hausman--Taylor estimator,
#' Amemiya--MaCurdy estimator, or Breusch--Mizon--Schmidt estimator, depending
#' on the argument `model`. The model is specified as a two--part formula,
#' the second part containing the exogenous variables.
#' 
#' @aliases pht
#' @param formula a symbolic description for the model to be
#'     estimated,
#' @param object,x an object of class `"plm"`,
#' @param data a `data.frame`,
#' @param subset see [lm()] for `"plm"`, a character or
#'     numeric vector indicating a subset of the table of coefficient
#'     to be printed for `"print.summary.plm"`,
#' @param na.action see [lm()],
#' @param model one of `"ht"` for Hausman--Taylor, `"am"`
#'     for Amemiya--MaCurdy and `"bms"` for
#'     Breusch--Mizon--Schmidt,
#' @param index the indexes,
#' @param digits digits,
#' @param width the maximum length of the lines in the print output,
#' @param \dots further arguments.
#' @return An object of class `c("pht", "plm", "panelmodel")`.
#' 
#' A `"pht"` object contains the same elements as `plm`
#' object, with a further argument called `varlist` which
#' describes the typology of the variables. It has `summary` and
#' `print.summary` methods.
#' 
#' @note The function `pht` is deprecated. Please use function `plm`
#'     to estimate Taylor--Hausman models like this with a three-part
#'     formula as shown in the example:\cr `plm(<formula>,
#'     random.method = "ht", model = "random", inst.method =
#'     "baltagi")`. The Amemiya--MaCurdy estimator and the
#'     Breusch--Mizon--Schmidt estimator is computed likewise with
#'     `plm`.
#' @export
#' @author Yves Croissant
#' @references
#'
#' \insertCite{AMEM:MACU:86}{plm}
#' 
#' \insertCite{BALT:13}{plm}
#' 
#' \insertCite{BREU:MIZO:SCHM:89}{plm}
#' 
#' \insertCite{HAUS:TAYL:81}{plm}
#' 
#' @keywords regression
#' @examples
#' 
#' ## replicates Baltagi (2005, 2013), table 7.4
#' ## preferred way with plm()
#' data("Wages", package = "plm")
#' ht <- plm(lwage ~ wks + south + smsa + married + exp + I(exp ^ 2) + 
#'               bluecol + ind + union + sex + black + ed |
#'               bluecol + south + smsa + ind + sex + black |
#'               wks + married + union + exp + I(exp ^ 2), 
#'           data = Wages, index = 595,
#'           random.method = "ht", model = "random", inst.method = "baltagi")
#' summary(ht)
#' 
#' am <- plm(lwage ~ wks + south + smsa + married + exp + I(exp ^ 2) + 
#'               bluecol + ind + union + sex + black + ed |
#'               bluecol + south + smsa + ind + sex + black |
#'               wks + married + union + exp + I(exp ^ 2), 
#'           data = Wages, index = 595,
#'           random.method = "ht", model = "random", inst.method = "am")
#' summary(am)
#' 
#' ## deprecated way with pht() for HT
#' #ht <- pht(lwage ~ wks + south + smsa + married + exp + I(exp^2) +
#' #          bluecol + ind + union + sex + black + ed | 
#' #          sex + black + bluecol + south + smsa + ind,
#' #          data = Wages, model = "ht", index = 595)
#' #summary(ht)
#' # deprecated way with pht() for AM
#' #am <- pht(lwage ~ wks + south + smsa + married + exp + I(exp^2) +
#' #          bluecol + ind + union + sex + black + ed | 
#' #          sex + black + bluecol + south + smsa + ind,
#' #          data = Wages, model = "am", index = 595)
#' #summary(am)
#' 
#' 
pht <- function(formula, data, subset, na.action, model = c("ht", "am", "bms"), index = NULL, ...){
  
  .Deprecated(old = "pht",
              msg = "uses of 'pht()' and 'plm(., model = \"ht\"/\"am\"/\"bms\")' are discouraged, better use 'plm(., model =\"random\", random.method = \"ht\", inst.method = \"baltagi\"/\"am\"/\"bms\")'")
  
  cl <- match.call(expand.dots = TRUE)
  mf <- match.call()
  
  if (length(model) == 1 && model == "bmc") {
    # accept "bmc" (a long-standing typo) for Breusch-Mizon-Schmidt due to backward compatibility
    model <- "bms"
    warning("Use of model = \"bmc\" discouraged, set to \"bms\" for Breusch-Mizon-Schmidt instrumental variable transformation")
  }
  model <- match.arg(model)
  # compute the model.frame using plm with model = NA
  mf[[1]] <- as.name("plm")
  mf$model <- NA
  data <- eval(mf, parent.frame())
  # estimate the within model without instrument and extract the fixed
  # effects
  formula <- Formula(formula)
  if (length(formula)[2] == 1) stop("a list of exogenous variables should be provided")
  mf$model = "within"
  mf$formula <- formula(formula, rhs = 1)
  within <- eval(mf, parent.frame())
  fixef <- fixef(within)
  id <- index(data, "id")
  time <- index(data, "time")
  pdim <- pdim(data)
  balanced <- pdim$balanced
  T <- pdim$nT$T
  n <- pdim$nT$n
  N <- pdim$nT$N
  Ti <- pdim$Tint$Ti
  # get the typology of the variables
  X <- model.matrix(data, rhs = 1, model = "within", cstcovar.rm = "all")
  W <- model.matrix(data, rhs = 2, model = "within", cstcovar.rm = "all")
  exo.all <- colnames(W)
  all.all <- colnames(X)
  edo.all <- all.all[!(all.all %in% exo.all)]
  all.cst <- attr(X, "constant")
  exo.cst <- attr(W, "constant")
  if("(Intercept)" %in% all.cst) all.cst <- setdiff(all.cst, "(Intercept)")
  if("(Intercept)" %in% exo.cst) exo.cst <- setdiff(exo.cst, "(Intercept)")
  exo.var <- exo.all[!(exo.all %in% exo.cst)]
  edo.cst <- all.cst[!(all.cst %in% exo.cst)]
  edo.var <- edo.all[!(edo.all %in% edo.cst)]
  
  if (length(edo.cst) > length(exo.var)){
    stop(" The number of endogenous time-invariant variables is greater
           than the number of exogenous time varying variables\n")
  }
  
  X <- model.matrix(data, model = "pooling", rhs = 1, lhs = 1)
  if (length(exo.var) > 0) XV <- X[ , exo.var, drop = FALSE] else XV <- NULL
  if (length(edo.var) > 0) NV <- X[ , edo.var, drop = FALSE] else NV <- NULL
  if (length(exo.cst) > 0) XC <- X[ , exo.cst, drop = FALSE] else XC <- NULL
  if (length(edo.cst) > 0) NC <- X[ , edo.cst, drop = FALSE] else NC <- NULL
  if (length(all.cst) != 0)
    zo <- twosls(fixef[as.character(id)], cbind(XC, NC), cbind(XC, XV), TRUE)
  else zo <- lm(fixef ~ 1)
  
  sigma2 <- list()
  sigma2$one <- 0
  sigma2$idios <- deviance(within)/ (N - n)
  sigma2$one <- deviance(zo) / n
  if(balanced){
    sigma2$id <- (sigma2$one - sigma2$idios)/ T
    theta <- 1 - sqrt(sigma2$idios / sigma2$one)
  }
  else{
    # for unbalanced data, the harmonic mean of the Ti's is used ; why ??
    barT <- n / sum(1 / Ti)
    sigma2$id <- (sigma2$one - sigma2$idios) / barT
    theta <- 1 - sqrt(sigma2$idios / (sigma2$idios + Ti * sigma2$id))
    theta <- theta[as.character(id)]
  }
  estec <- structure(list(sigma2 = sigma2, theta = theta),
                     class = "ercomp",
                     balanced = balanced,
                     effect = "individual")
  y <- pmodel.response(data, model = "random", effect = "individual", theta = theta)
  X <- model.matrix(data, model = "random", effect = "individual", theta = theta)
  within.inst <- model.matrix(data, model = "within")
  
  if (model == "ht"){
    between.inst <- model.matrix(data, model = "Between",
                                 rhs = 2)[, exo.var, drop = FALSE]
    W <- cbind(within.inst, XC, between.inst)
  }
  if (model == "am"){
    Vx <- model.matrix(data, model = "pooling",
                       rhs = 2)[, exo.var, drop = FALSE]
    if (balanced){
      # Plus rapide mais pas robuste au non cylindre
      Vxstar <- Reduce("cbind",
                       lapply(seq_len(ncol(Vx)),
                              function(x)
                                matrix(Vx[, x], ncol = T, byrow = TRUE)[rep(1:n, each = T), ]))
    }
    else{
      Xs <- lapply(seq_len(ncol(Vx)), function(x)
        structure(Vx[, x], index = index(data), class = c("pseries", class(Vx[, x]))))
      Vx2 <- Reduce("cbind", lapply(Xs, as.matrix))
      Vxstar <- Vx2[rep(1:n, times = Ti), ]
      Vxstar[is.na(Vxstar)] <- 0
    }
    W <- cbind(within.inst, XC, Vxstar)
  }
  if (model == "bms"){
    between.inst <- model.matrix(data, model = "Between",
                                 rhs = 2)[, exo.var, drop = FALSE]
    Vx <- within.inst
    if (balanced){
      # Plus rapide mais pas robuste au non cylindre
      Vxstar <- Reduce("cbind",
                       lapply(seq_len(ncol(Vx)),
                              function(x)
                                matrix(Vx[, x], ncol = T, byrow = TRUE)[rep(1:n, each = T), ]))
    }
    else{
      Xs <- lapply(seq_len(ncol(Vx)), function(x)
        structure(Vx[, x], index = index(data), class = c("pseries", class(Vx[, x]))))
      Vx2 <- Reduce("cbind", lapply(Xs, as.matrix))
      Vxstar <- Vx2[rep(1:n, times = Ti), ]
      Vxstar[is.na(Vxstar)] <- 0
    }
    W <- cbind(within.inst, XC, between.inst, Vxstar)
  }
  
  result <- twosls(y, X, W)
  K <- length(data)
  ve <- lev2var(data)
  varlist <- list(xv = unique(ve[exo.var]),
                  nv = unique(ve[edo.var]),
                  xc = unique(ve[exo.cst[exo.cst != "(Intercept)"]]),
                  nc = unique(ve[edo.cst])
  )
  varlist <- lapply(varlist, function(x){ names(x) <- NULL; x})
  result <- list(coefficients = coef(result),
                 vcov         = vcov(result),
                 residuals    = resid(result),
                 df.residual  = df.residual(result),
                 formula      = formula, 
                 model        = data,
                 varlist      = varlist,
                 ercomp       = estec,
                 call         = cl,
                 args         = list(model = "ht", ht.method = model))
    names(result$coefficients) <- colnames(result$vcov) <-
        rownames(result$vcov) <- colnames(X)
    class(result) <- c("pht", "plm", "panelmodel")
    result
}

#' @rdname pht
#' @export
summary.pht <- function(object, ...){
	object$fstatistic <- pwaldtest(object, test = "Chisq")
	# construct the table of coefficients
	std.err <- sqrt(diag(vcov(object)))
	b <- coefficients(object)
	z <- b/std.err
	p <- 2*pnorm(abs(z), lower.tail = FALSE)
	object$coefficients <- cbind("Estimate"   = b,
                                     "Std. Error" = std.err,
                                     "z-value"    = z,
                                     "Pr(>|z|)"   = p)
	class(object) <- c("summary.pht", "pht", "plm", "panelmodel")
	object
}

#' @rdname pht
#' @export
print.summary.pht <- function(x, digits = max(3, getOption("digits") - 2),
                              width = getOption("width"), subset = NULL, ...){
  formula <- formula(x)
  has.instruments <- (length(formula)[2] >= 2)
  effect <- describe(x, "effect")
  model <- describe(x, "model")
  ht.method <- describe(x, "ht.method")
  cat(paste(effect.plm.list[effect]," ",sep=""))
  cat(paste(model.plm.list[model]," Model",sep=""),"\n")
  cat(paste("(", ht.method.list[ht.method],")",sep=""),"\n")
  
  cat("\nCall:\n")
  print(x$call)
  
  #    cat("\nTime-Varying Variables: ")
  names.xv <- paste(x$varlist$xv,collapse=", ")
  names.nv <- paste(x$varlist$nv,collapse=", ")
  names.xc <- paste(x$varlist$xc,collapse=", ")
  names.nc <- paste(x$varlist$nc,collapse=", ")
  cat(paste("\nT.V. exo  : ",names.xv,"\n", sep = ""))
  cat(paste("T.V. endo : ", names.nv,"\n",sep = ""))
  #    cat("Time-Invariant Variables: ")
  cat(paste("T.I. exo  : ", names.xc, "\n", sep= ""))
  cat(paste("T.I. endo : ", names.nc, "\n", sep= ""))
  cat("\n")
  pdim <- pdim(x)
  print(pdim)
  cat("\nEffects:\n")
  print(x$ercomp)
  cat("\nResiduals:\n")
  save.digits <- unlist(options(digits = digits))
  on.exit(options(digits = save.digits))
  print(sumres(x))
  
  cat("\nCoefficients:\n")
  if (is.null(subset)) printCoefmat(coef(x), digits = digits)
  else printCoefmat(coef(x)[subset, , drop = FALSE], digits = digits)
  cat("\n")
  cat(paste("Total Sum of Squares:    ",signif(tss(x),digits),"\n",sep=""))
  cat(paste("Residual Sum of Squares: ",signif(deviance(x),digits),"\n",sep=""))
  #  cat(paste("Multiple R-Squared:      ",signif(x$rsq,digits),"\n",sep=""))
  fstat <- x$fstatistic
  if (names(fstat$statistic) == "F"){
    cat(paste("F-statistic: ",signif(fstat$statistic),
              " on ",fstat$parameter["df1"]," and ",fstat$parameter["df2"],
              " DF, p-value: ",format.pval(fstat$p.value,digits=digits),"\n",sep=""))
  }
  else{
    cat(paste("Chisq: ",signif(fstat$statistic),
              " on ",fstat$parameter,
              " DF, p-value: ",format.pval(fstat$p.value,digits=digits),"\n",sep=""))
    
  }
  invisible(x)
}

## dynformula

sumres <- function(x){
    sr <- summary(unclass(resid(x)))
    srm <- sr["Mean"]
    if (abs(srm)<1e-10){
        sr <- sr[c(1:3,5:6)]
    }
    sr
}


create.list <- function(alist, K, has.int, has.resp, endog, exo, default){
    # if alist is NULL, create a list of 0
    if (is.null(alist)) alist <- rep(list(default), K+has.resp)
    # if alist is not a list, coerce it
    if (!is.list(alist)) alist <- list(alist)

    if (!is.null(names(alist))){
    # case where (at least) some elements are named
        nam <- names(alist) # vector of names of elements
        oalist <- alist  # copy of the alist provided
        notnullname <- nam[nam != ""]
        if (any (nam == "")){
      # case where one element is unnamed, and therefore is the default
            unnamed <- which(nam == "")
            if (length(unnamed) > 1) stop("Only one unnamed element is admitted")
            default <- alist[[unnamed]]
        }
        else{
        # case where there are no unnamed elements, the default is 0
            default <- default
        }
        alist <- rep(list(default), K+has.resp)
        names(alist) <- c(endog, exo)
        alist[notnullname] <- oalist[notnullname]
    }
    else{
    # case where there are no names, in this case the relevant length is
    # whether 1 or K+1
        if (length(alist) == 1) alist <- rep(alist, c(K+has.resp))
        else if (!length(alist) %in% c(K+has.resp)) stop("irrelevant length for alist")
    }
    names(alist) <- c(endog,exo)
    alist
}

write.lags <- function(name,lags,diff){
    lags <- switch(length(lags),
                   "1"=c(0,lags),
                   "2"=sort(lags),
                   stop("lags should be of length 1 or 2\n")
                   )
    lag.string <- ifelse(diff,"diff","lag")
    chlag <- c()
    if (lags[2]!=0){
        lags <- lags[1]:lags[2]
        for (i in lags){
            if (i==0){
                if (diff) chlag <- c(chlag,paste("diff(",name,")")) else chlag <- c(chlag,name)
            }
            else{
                ichar <- paste(i)
                chlag <- c(chlag,paste(lag.string,"(",name,",",i,")",sep=""))
            }
        }
        ret <- paste(chlag,collapse="+")
    }
    else{
        if (diff) chlag <- paste("diff(",name,")") else chlag <- name
        ret <- chlag
    }
    ret
}   



#' @rdname plm-deprecated
#' @export
dynformula <- function(formula, lag.form = NULL, diff.form = NULL, log.form = NULL) {
    
    .Deprecated(msg = "use of 'dynformula' is deprecated, use a multi-part formula instead",
                old = "dynformula")

    # for backward compatibility, accept a list argument and coerce it
    # to a vector
    if (!is.null(diff.form) && !is.list(diff.form)) diff.form <- as.list(diff.form)
    if (!is.null(log.form) && !is.list(log.form)) log.form <- as.list(log.form)

    # exo / endog are the names of the variable
    # has.int has.resp  TRUE if the formula has an intercept and a response
    # K is the number of exogenous variables
    exo <- attr(terms(formula), "term.labels")
    has.int <- attr(terms(formula), "intercept") == 1
    if(length(formula) == 3){
        endog <- deparse(formula[[2]])
        has.resp <- TRUE
    }
    else{
        endog <- NULL
        has.resp <- FALSE
    }
    K <- length(exo)

    # use the create.list function to create the lists with the relevant
    # default values
    lag.form <- create.list(lag.form, K, has.int, has.resp, endog, exo, 0)
    diff.form <- unlist(create.list(diff.form, K, has.int, has.resp, endog, exo, FALSE))
    log.form <- unlist(create.list(log.form, K, has.int, has.resp, endog, exo, FALSE))
    
    structure(formula, class = c("dynformula", "formula"), lag = lag.form,
              diff = diff.form, log = log.form, var = c(endog,exo))
}


formula.dynformula <- function(x, ...){
    log.form <- attr(x, "log")
    lag.form <- attr(x, "lag")
    diff.form <- attr(x, "diff")
    has.resp <- length(x) == 3
    exo <- attr(x, "var")
    if (has.resp){
        endog <- exo[1]
        exo <- exo[-1]
    }
    has.int <- attr(terms(x), "intercept") == 1
    chexo <- c()
    if (has.resp){
        if (log.form[1]) endog <- paste("log(",endog,")",sep="")
        if (diff.form[1]) endog <- paste("diff(",endog,")",sep="")
        if (length(lag.form[[1]]) == 1 && lag.form[[1]]!=0) lag.form[[1]] <- c(1,lag.form[[1]])
        if (!(length(lag.form[[1]]) == 1 && lag.form[[1]]==0))
            chexo <- c(chexo,write.lags(endog,lag.form[[1]],diff.form[1]))
    }
    for (i in exo){
        lag.formi <- lag.form[[i]]
        diff.formi <- diff.form[i]
        if (log.form[[i]]) i <- paste("log(",i,")",sep="")
        chexo <- c(chexo,write.lags(i,lag.formi,diff.formi))
    }
    chexo <- paste(chexo,collapse="+")
    if (has.resp){
        formod <- as.formula(paste(endog,"~",chexo,sep=""))
    }
    else{
        formod <- as.formula(paste("~",chexo,sep=""))
    }
    if (!has.int) formod <- update(formod,.~.-1)
    formod
}

print.dynformula <- function(x,...){
    print(formula(x), ...)
}

#' @rdname plm-deprecated
#' @export
pFormula <- function(object) {
  .Deprecated(msg = "class 'pFormula' is deprecated, simply use class 'Formula'",
              old = "pFormula", new = "Formula")
  stopifnot(inherits(object, "formula"))
  if (!inherits(object, "Formula")){
    object <- Formula(object)
  }
  class(object) <- union("pFormula", class(object))
  object
}

#' @rdname plm-deprecated
#' @export
as.Formula.pFormula <- function(x, ...){
  class(x) <- setdiff(class(x), "pFormula")
  x
}


## pFormula stuff, usefull for cquad

#' @rdname plm-deprecated
#' @export
as.Formula.pFormula <- function(x, ...){
    class(x) <- setdiff(class(x), "pFormula")
    x
}

#' @rdname plm-deprecated
#' @export
model.frame.pFormula <- function(formula, data, ..., lhs = NULL, rhs = NULL){
    if (is.null(rhs)) rhs <- 1:(length(formula)[2])
    if (is.null(lhs)) lhs <- ifelse(length(formula)[1] > 0, 1, 0)
    index <- attr(data, "index")
    mf <- model.frame(as.Formula(formula), as.data.frame(data), ..., rhs = rhs)
    index <- index[as.numeric(rownames(mf)), ]
    index <- droplevels(index)
    class(index) <- c("pindex", "data.frame")
    structure(mf,
              index = index,
              class = c("pdata.frame", class(mf)))
}


#' @rdname plm-deprecated
#' @export
model.matrix.pFormula <- function(object, data,
                                  model = c("pooling", "within", "Between", "Sum",
                                            "between", "mean", "random", "fd"),
                                  effect = c("individual", "time", "twoways", "nested"),
                                  rhs = 1,
                                  theta = NULL,
                                  cstcovar.rm = NULL,
                                  ...){
    model <- match.arg(model)
    effect <- match.arg(effect)
    formula <- object  
    has.intercept <- has.intercept(formula, rhs = rhs)
    # relevant defaults for cstcovar.rm
    if (is.null(cstcovar.rm)) cstcovar.rm <- ifelse(model == "within", "intercept", "none")
    balanced <- is.pbalanced(data)
    # check if inputted data is a model.frame, if not convert it to
    # model.frame (important for NA handling of the original data when
    # model.matrix.pFormula is called directly) As there is no own
    # class for a model.frame, check if the 'terms' attribute is
    # present (this mimics what lm does to detect a model.frame)    
    if (is.null(attr(data, "terms")))
        data <- model.frame.pFormula(pFormula(formula), data)  
    # this goes to Formula::model.matrix.Formula:
    X <- model.matrix(as.Formula(formula), rhs = rhs, data = data, ...)
    # check for infinite or NA values and exit if there are some
    if(any(! is.finite(X))) stop(paste("model matrix or response contains non-finite",
                                       "values (NA/NaN/Inf/-Inf)"))
    X.assi <- attr(X, "assign")
    X.contr <- attr(X, "contrasts")
    X.contr <- X.contr[ ! sapply(X.contr, is.null) ]
    index <- index(data)
    if (anyNA(index[[1]])) stop("NA in the individual index variable")
    attr(X, "index") <- index
    if (effect == "twoways" & model %in% c("between", "fd"))
        stop("twoways effect only relevant for within, random and pooling models")
    if (model == "within") X <- Within(X, effect)
    if (model == "Sum") X <- Sum(X, effect)
    if (model == "Between") X <- Between(X, effect)
    if (model == "between") X <- between(X, effect)
    if (model == "mean") X <- Mean(X)
    if (model == "fd") X <- pdiff(X, effect = "individual",
                                  has.intercept = has.intercept)
    if (model == "random"){
        if (is.null(theta)) stop("a theta argument should be provided")
        if (effect %in% c("time", "individual")) X <- X - theta * Between(X, effect)
        if (effect == "nested") X <- X - theta$id * Between(X, "individual") -
                                    theta$gp * Between(X, "group")
        if (effect == "twoways" & balanced)
            X <- X - theta$id * Between(X, "individual") -
                theta$time * Between(X, "time") + theta$total * Mean(X)
    }

    if (cstcovar.rm == "intercept"){
        posintercept <- match("(Intercept)", colnames(X))
        if (! is.na(posintercept)) X <- X[, - posintercept, drop = FALSE]
    }
    if (cstcovar.rm %in% c("covariates", "all")){
        cols <- apply(X, 2, is.constant)
        cstcol <- names(cols)[cols]
        posintercept <- match("(Intercept)", cstcol)
        cstintercept <- ifelse(is.na(posintercept), FALSE, TRUE)
        zeroint <- ifelse(cstintercept &&
                          max(X[, posintercept]) < sqrt(.Machine$double.eps),
                          TRUE, FALSE)
        if (length(cstcol) > 0){
            if ((cstcovar.rm == "covariates" || !zeroint) && cstintercept) cstcol <- cstcol[- posintercept]
            if (length(cstcol) > 0){
                X <- X[, - match(cstcol, colnames(X)), drop = FALSE]
                attr(X, "constant") <- cstcol
            }
        }
    }
    structure(X, assign = X.assi, contrasts = X.contr, index = index)
}
