require "rinruby"
require "rserve"

R.eval "library(mlegp); library(lhs);"
R.eval("library('Rserve');")
R.eval("Rserve(args='--vanilla');")

RBridge = Rserve::Connection.new
RBridge.eval("library(mlegp);")
