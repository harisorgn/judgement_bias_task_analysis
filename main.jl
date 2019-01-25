using CSV, DataStreams, XLSX, DataFrames

include("klimb_proc.jl")

path = "./exp/" ;
session_to_analyse = :probe

klimb_read(path, session_to_analyse)
