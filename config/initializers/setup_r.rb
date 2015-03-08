require "rinruby"
require "rserve"

R.eval "library(mlegp); library(lhs);"

RBridge = Rserve::Connection.new
RBridge.eval("library(mlegp);")