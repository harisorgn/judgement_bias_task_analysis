using CSV, DataStreams, XLSX, DataFrames, PyPlot
using Distributions, HypothesisTests, Discreet, StatsBase, Statistics, Random

include("klimb.jl")
include("constants.jl")
include("mi.jl")

path = "./exp/ho2/" ;
session_to_analyse = :probe

klimb_read(path, session_to_analyse)
