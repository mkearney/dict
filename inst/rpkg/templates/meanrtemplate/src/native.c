/* Automatically generated. Do not edit by hand. */

#include <R.h>
#include <Rinternals.h>
#include <R_ext/Rdynload.h>
#include <stdlib.h>

extern SEXP R_get_nthreads();
extern SEXP R_score(SEXP s_, SEXP nthreads_);
extern SEXP R_score_score(SEXP s_, SEXP nthreads_);

static const R_CallMethodDef CallEntries[] = {
  {"R_get_nthreads", (DL_FUNC) &R_get_nthreads, 0},
  {"R_score", (DL_FUNC) &R_score, 2},
  {NULL, NULL, 0},
  {"R_score_score", (DL_FUNC) &R_score_score, 2},
  {NULL, NULL, 0}
};

void R_init(DllInfo *dll)
{
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
}
