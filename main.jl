using CSV, DataStreams, XLSX, DataFrames, PyPlot
using Distributions, HypothesisTests, Discreet, StatsBase, Statistics, Random

include("klimb.jl")
include("constants.jl")
include("mi.jl")
include("plot.jl")

path = "./exp/ho2/4vs1 probe/" ;
session_to_analyse = :probe

subj_v = klimb_read(path, session_to_analyse)
#klimb_mi(path, session_to_analyse, 1)