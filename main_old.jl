using CSV, DataStreams, XLSX, DataFrames

include("klimb_proc.jl")
include("constants.jl")
#tttttttestttttt

#session_to_analyse = :probe ;
session_to_analyse = :train ;

if session_to_analyse == :probe
	header_vec = probe_header_vec ;
elseif session_to_analyse == :train
	header_vec = train_header_vec ;
end

#path = "./HO2/discrimination/" ;
path = "./exp/" ;

col_type_vec = fill(Any, length(header_vec)) ;

if isempty(path)
	file_vec = date_sort(filter(x->contains(x,".csv"), readdir())) ;
else
	file_vec = date_sort(filter(x->contains(x,".csv"), readdir(path))) ;
end


for file_s in file_vec
	first_time = true ;
	file = open(string(path,file_s)) ;

	source = CSV.Source(file) ;

	total_lines = CSV.countlines(source) ;
	Data.reset!(source)

	rf = Array{CSV.RawField,1}() ;

	line = 1 ;
	subject_id = 0 ;
	while line <= total_lines

		CSV.readsplitline!(rf, source) ;
		if string_iseq(rf[1].value, "AC Comment")

			if contains(rf[3].value, "Sequence") && contains(rf[3].value, "probe")
				session = :probe ;
				if isempty(path)
					dt_row_len = 24 ;
				else
					dt_row_len = 20 ;
				end

			elseif contains(rf[3].value, "Sequence") && contains(rf[3].value, "training")
				session = :seq ;
				if isempty(path)
					dt_row_len = 24 ;
				else
					dt_row_len = 20 ;
				end

			elseif contains(rf[3].value, "seq")
				session = :seq ;
				dt_row_len = 18 ;

			elseif contains(rf[3].value, "Pure")
				session = :t4v1 ;
				dt_row_len = 18 ;

			elseif contains(rf[3].value, "Discrimination")
				session = :t1v1 ;
				dt_row_len = 18 ;
			elseif contains(rf[3].value, "Probe") && contains(rf[3].value, "midpoint")
				session = :probe ;
				dt_row_len = 20 ;

			else
				session = :not_interesting ;
			end
		end

		if string_iseq(rf[1].value, "Ref") && session != :not_interesting

			subject_dt = Array{Int64,1}() ;
			CSV.readsplitline!(rf, source) ;

			subject_line = 1 ;
			while !string_iseq(rf[1].value, "ENDDATA") && !string_iseq(rf[1].value, "-1")

				append!(subject_dt, map_rf_to_num(rf, Int64)) ;

				CSV.readsplitline!(rf, source) ;

				line += 1 ;
				subject_line += 1 ;
			end

			subject_dt = reshape(subject_dt, dt_row_len, Int64(size(subject_dt,1)/dt_row_len))' ;
			subject_id += 1 ;

			if session == :probe && session_to_analyse == :probe && subject_id <= 16
				if first_time
					println(file_s)
					first_time = false ;
				end

				#prev_trial_probe(subject_dt, subject_id, file_s)
				probe_write(subject_dt, subject_id, file_s, path)
				#=
				if pattern_vec[subject_id] == :easy
					easy_probe_write(subject_dt, subject_id, file_s)
				elseif pattern_vec[subject_id] == :hard
					hard_probe_write(subject_dt, subject_id, file_s)
				end
				=#
			elseif session != :probe && session != :not_interesting && session_to_analyse == :train
				if first_time
					println(file_s)
					first_time = false ;
				end

				train_write(subject_dt, subject_id, string(session), file_s, path)
			end

			if subject_id == 16 && session_to_analyse == :train
				subject_id = 0 ;
			end

		end

		line += 1 ;
	end
	close(file)
end
