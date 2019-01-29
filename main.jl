using CSV, DataStreams, XLSX, DataFrames, Discreet, StatsBase

include("klimb.jl")

path = "./exp/" ;
session_to_analyse = :probe

klimb_read(path, session_to_analyse)
