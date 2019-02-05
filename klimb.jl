
function klimb_read(path::String, session_to_analyse::Symbol)

	if isempty(path)
		file_v = date_sort(filter(x->occursin(".csv", x), readdir())) ;
	else
		file_v = date_sort(filter(x->occursin(".csv", x), readdir(path))) ;
	end
	
	n_trials_in_the_past = 25 ;

	mi_pr_v = Array{Float64,1}(undef, n_trials_in_the_past) ;
	mi_pp_v = Array{Float64,1}(undef, n_trials_in_the_past) ;
	mi_prp_v = Array{Float64,1}(undef, n_trials_in_the_past) ;
	mi_ppr_v = Array{Float64,1}(undef, n_trials_in_the_past) ;
	ci_pr_v = Array{Tuple{Float64, Float64},1}(undef, n_trials_in_the_past) ;
	ci_pp_v = Array{Tuple{Float64, Float64},1}(undef, n_trials_in_the_past) ;
	ci_prp_v = Array{Tuple{Float64, Float64},1}(undef, n_trials_in_the_past) ;
	ci_ppr_v = Array{Tuple{Float64, Float64},1}(undef, n_trials_in_the_past) ;

	for i = 1:n_trials_in_the_past
	curr_press_v = Array{Int64,1}() ;
	past_press_v = Array{Int64,1}() ;
	past_reward_v = Array{Int64,1}() ;
	n_trials_v = Array{Int64,1}() ;
	for file_name in file_v

		file = CSV.File(string(path, file_name)) ;
		dt_v = Array{Array{Any,1},1}() ;
		subject_id = 0 ;
		session = :not_interesting ;
		dt_row_len = 0 ;
		first_time = true ;

		while !CSV.eof(file.io)

			rf = CSV.readsplitline(file.io) ;

			if occursin("AC Comment", rf[1])
				if occursin("Pure", rf[3])
					session = :t4v1 ;
					dt_row_len = 18 ;
				elseif occursin("Discrimination", rf[3])
					session = :t1v1 ;
					dt_row_len = 18 ;
				elseif occursin("Probe", rf[3]) && occursin("midpoint", rf[3])
					session = :probe ;
					dt_row_len = 20 ;
				elseif occursin("Probe", rf[3]) && occursin("1 vs 1", rf[3])
					session = :probe_1vs1 ;
					dt_row_len = 22 ;
				end
			end

			if occursin("Ref", rf[1]) && occursin("Outcome", rf[2]) && session != :not_interesting
				
				subject_dt = Array{Int64,1}() ;
				rf = CSV.readsplitline(file.io) ;

				while !occursin("ENDDATA", rf[1]) && !occursin("-1", rf[1])

					append!(subject_dt, map(x->tryparse(Int64,x), rf[1:dt_row_len])) ;

					rf = CSV.readsplitline(file.io) ;

				end

				subject_dt = permutedims(reshape(subject_dt, dt_row_len, :), (2,1)) ;
				subject_id += 1 ;

				if session == :probe && session_to_analyse == :probe
					if first_time
						#println(file.name)
						first_time = false ;
					end
					
					#push!(dt_v, get_probe_subj(subject_dt, subject_id, file_name, path, 0)) ;

					tp = prev_trial_pairing(subject_dt, subject_id, i)
					#tp = amb_trial_pairing(subject_dt, subject_id)
					append!(curr_press_v, tp[:,1]) ;
					append!(past_press_v, tp[:,2]) ;
					append!(past_reward_v, tp[:,3]) ;
					push!(n_trials_v, length(tp[:,1]))
				elseif	session == :probe_1vs1 && session_to_analyse == :probe
					if first_time
						println(file.name)
						first_time = false ;
					end

					#push!(dt_v, get_probe_subj(subject_dt, subject_id, file_name, path, 2)) ;

					tp = prev_trial_pairing(subject_dt, subject_id, i)
					#tp = amb_trial_pairing(subject_dt, subject_id)
					append!(curr_press_v, tp[:,1]) ;
					append!(past_press_v, tp[:,2]) ;
					append!(past_reward_v, tp[:,3]) ;
				elseif session != :probe && session != :not_interesting && session_to_analyse == :train
					if first_time
						println(file.name)
						first_time = false ;
					end
				end
			end
		end
		if !isempty(dt_v)
			write_xlsx(dt_v, session_to_analyse, file_name, path) ;
		end
	end
	
	mi_v = mutual_info(curr_press_v, past_reward_v, past_press_v, n_trials_v) ;
	mi_pr_v[i] = mi_v[1] ;
	mi_pp_v[i] = mi_v[2] ;
	mi_prp_v[i] = mi_v[3] ;
	mi_ppr_v[i] = mi_v[4] ;
	ci_pr_v[i] = mi_v[5] ;
	ci_pp_v[i] = mi_v[6] ;
	ci_prp_v[i] = mi_v[6] ;
	ci_ppr_v[i] = mi_v[6] ;
	end
	plot_mi(mi_pr_v, mi_pp_v, mi_prp_v, mi_ppr_v, ci_pr_v, ci_pp_v, ci_prp_v, ci_ppr_v, n_trials_in_the_past)
end

function date_sort(fv :: Array{String})

	date_m = Array{Tuple{Int64, Int64, Int64, String},1}(undef, length(fv)) ;

	i = 1 ;
	for date in fv
		day = tryparse(Int64, date[1:2]) ;

		if occursin("Jan", date)
			month = 1 ;
		elseif occursin("Feb", date)
			month = 2 ;
		elseif occursin("Mar", date)
			month = 3 ;
		elseif occursin("Apr", date)
			month = 4 ;
		elseif occursin("May", date)
			month = 5 ;
		elseif occursin("Jun", date)
			month = 6 ;
		elseif occursin("Jul", date)
			month = 7 ;
		elseif occursin("Aug", date)
			month = 8 ;
		elseif occursin("Sep", date)
			month = 9 ;
		elseif occursin("Oct", date)
			month = 10 ;
		elseif occursin("Nov", date)
			month = 11 ;
		elseif occursin("Dec", date)
			month = 12 ;
		else
			println("Invalid date")
		end

		year = tryparse(Int64, date[8:11]) ;
		date_m[i] = (day, month, year, date) ;

		i += 1 ;
	end

	sort!(date_m, by = x->(x[3],x[2],x[1],x[4]))
	sorted_fv = Array{String, 1}(undef, length(fv)) ;

	for i = 1 : length(fv)
		sorted_fv[i] = date_m[i][4] ;
	end
	return sorted_fv
end

function write_xlsx(row_dt_v::Array{Array{Any,1},1}, session::Symbol, in_file::String, in_path::String)

	xlsx_file = string(in_path, in_file[1:11],".xlsx") ;

	session == :probe ? header_vec = probe_header_vec : header_vec = train_header_vec

	column_dt_v = Array{Array{Any,1},1}() ;

	for i = 1 : length(row_dt_v[1])
		push!(column_dt_v, map(x -> x[i], row_dt_v)) ;
	end 

	df_dt = DataFrame(Dict(map((x,y) -> x=>y, header_vec, column_dt_v))) ;

	XLSX.writetable(xlsx_file, DataFrames.columns(df_dt), DataFrames.names(df_dt), overwrite = true) ;
end

function get_train_subj(subject_dt::Array{Int64,2}, subject_id::Int64, session::String, in_file::String, in_path::String)

	corr_I = 0 ;
	corr_II = 0 ;
	incorr_I = 0 ;
	incorr_II = 0 ;
	miss_I = 0 ;
	miss_II = 0 ;
	prem = 0 ;
	corr_I_RT = Array{Float64,1}() ;
	corr_II_RT = Array{Float64,1}() ;
	incorr_I_RT = Array{Float64,1}() ;
	incorr_II_RT = Array{Float64,1}() ;

	n_I = 0 ;
	n_II = 0 ;

	for i = 1 : size(subject_dt,1)

		if subject_dt[i,2] == 0

			if subject_dt[i,15] != 0

				corr_I += 1 ;
				push!(corr_I_RT, subject_dt[i,16] - subject_dt[i,15]) ;
				n_I += 1 ;

			elseif subject_dt[i,17] != 0

				corr_II += 1 ;
				push!(corr_II_RT, subject_dt[i,18] - subject_dt[i,17]) ;
				n_II += 1 ;

			end

		elseif subject_dt[i,2] == 1

			incorr_I += 1 ;
			push!(incorr_I_RT, subject_dt[i,16] - subject_dt[i,15]) ;
			n_I += 1 ;

		elseif subject_dt[i,2] == 3

			incorr_II += 1 ;
			push!(incorr_II_RT, subject_dt[i,18] - subject_dt[i,17]) ;
			n_II += 1 ;

		elseif subject_dt[i,2] == 2

			if subject_dt[i,15] != 0

				miss_I += 1 ;
				n_I += 1 ;

			elseif subject_dt[i,17] != 0

				miss_II += 1 ;
				n_II += 1 ;

			end

		elseif subject_dt[i,2] == 4
			prem += 1 ;
		end


	end

	subject_vec = Array{Any,1}(undef, length(train_header_vec)) ;
	subject_vec[1] = subject_id ;
	subject_vec[2] = session ;

	if mod(subject_id,2) == 0

		subject_vec[3:end] = [mean(corr_II_RT)/100.0, mean(corr_I_RT)/100.0, mean(incorr_II_RT)/100.0, mean(incorr_I_RT)/100.0,
							100.0*corr_II/n_II, 100.0*corr_I/n_I, 100.0*incorr_II/n_II, 100.0*incorr_I/n_I,
							100.0*miss_II/n_II, 100.0*miss_I/n_I, 100.0*prem/(subject_dt[end,1]+1)] ;

	else

		subject_vec[3:end] = [mean(corr_I_RT)/100.0, mean(corr_II_RT)/100.0, mean(incorr_I_RT)/100.0, mean(incorr_II_RT)/100.0,
						100.0*corr_I/n_I, 100.0*corr_II/n_II, 100.0*incorr_I/n_I, 100.0*incorr_II/n_II,
						100.0*miss_I/n_I, 100.0*miss_II/n_II, 100.0*prem/(subject_dt[end,1]+1)] ;

	end

	return subject_vec
end

function get_probe_subj(subject_dt::Array{Int64,2}, subject_id::Int64, in_file::String, in_path::String, col_offset::Int64)

	corr_I = 0 ;
	corr_II = 0 ;
	incorr_I = 0 ;
	incorr_II = 0 ;
	miss_I = 0 ;
	miss_II = 0 ;
	prem = 0 ;
	corr_I_RT = Array{Float64,1}() ;
	corr_II_RT = Array{Float64,1}() ;
	incorr_I_RT = Array{Float64,1}() ;
	incorr_II_RT = Array{Float64,1}() ;

	amb_I = 0 ;
	amb_II = 0 ;
	miss_amb = 0 ;
	amb_I_RT = Array{Float64,1}() ;
	amb_II_RT = Array{Float64,1}() ;

	n_amb = 0 ;
	n_amb_I = 0 ;
	n_amb_II = 0 ;
	n_I = 0 ;
	n_II = 0 ;

	for i = 1 : size(subject_dt,1)

		if subject_dt[i,2] == 0

			if subject_dt[i,13 + col_offset] != 0

				corr_I += 1 ;
				push!(corr_I_RT, subject_dt[i,14 + col_offset] - subject_dt[i,13 + col_offset]) ;
				n_I += 1 ;

			elseif subject_dt[i,15 + col_offset] != 0

				corr_II += 1 ;
				push!(corr_II_RT, subject_dt[i,16 + col_offset] - subject_dt[i,15 + col_offset]) ;
				n_II += 1 ;

			elseif subject_dt[i,17 + col_offset] != 0

				n_amb_I += 1 ;
				push!(amb_I_RT, subject_dt[i,18 + col_offset] - subject_dt[i,17 + col_offset]) ;
				n_amb += 1 ;

			elseif subject_dt[i,19 + col_offset] != 0

				n_amb_II += 1 ;
				push!(amb_II_RT, subject_dt[i,20 + col_offset] - subject_dt[i,19 + col_offset]) ;
				n_amb += 1 ;

			end

		elseif subject_dt[i,2] == 1

			if subject_dt[i,17 + col_offset] != 0

				n_amb_II += 1 ;
				push!(amb_II_RT, subject_dt[i,18 + col_offset] - subject_dt[i,17 + col_offset]) ;
				n_amb += 1 ;

			else

				incorr_I += 1 ;
				push!(incorr_I_RT, subject_dt[i,14 + col_offset] - subject_dt[i,13 + col_offset]) ;
				n_I += 1 ;
			end

		elseif subject_dt[i,2] == 3

			if subject_dt[i,19 + col_offset] != 0

				n_amb_I += 1 ;
				push!(amb_I_RT, subject_dt[i,20 + col_offset] - subject_dt[i,19 + col_offset]) ;
				n_amb += 1 ;

			else

				incorr_II += 1 ;
				push!(incorr_II_RT, subject_dt[i,16 + col_offset] - subject_dt[i,15 + col_offset]) ;
				n_II += 1 ;
			end

		elseif subject_dt[i,2] == 2

			if subject_dt[i,13 + col_offset] != 0

				miss_I += 1 ;
				n_I += 1 ;

			elseif subject_dt[i,15 + col_offset] != 0

				miss_II += 1 ;
				n_II += 1 ;

			else

				miss_amb += 1 ;
				n_amb += 1 ;

			end

		elseif subject_dt[i,2] == 4
			prem += 1 ;
		end
	end

	subject_vec = Array{Any,1}(undef, length(probe_header_vec)) ;
	subject_vec[1] = subject_id ;

	if mod(subject_id,2) == 0
		# High reward is II
		subject_vec[2:end] = [mean(corr_II_RT)/100.0, mean(corr_I_RT)/100.0, mean(incorr_II_RT)/100.0, mean(incorr_I_RT)/100.0,
							mean(amb_II_RT)/100.0, mean(amb_I_RT)/100.0, 100.0*corr_II/n_II, 100.0*corr_I/n_I, 100.0*incorr_II/n_II, 100.0*incorr_I/n_I,
							100.0*n_amb_II/n_amb, 100.0*n_amb_I/n_amb, (n_amb_II - n_amb_I) / n_amb,
							100.0*miss_II/n_II, 100.0*miss_I/n_I, 100.0*miss_amb/n_amb, 100.0*prem/(subject_dt[end,1]+1), mean([amb_I_RT ; amb_II_RT])/100.0] ;

	else
		# High reward is I
		subject_vec[2:end] = [mean(corr_I_RT)/100.0, mean(corr_II_RT)/100.0, mean(incorr_I_RT)/100.0, mean(incorr_II_RT)/100.0,
							mean(amb_I_RT)/100.0, mean(amb_II_RT)/100.0, 100.0*corr_I/n_I, 100.0*corr_II/n_II, 100.0*incorr_I/n_I, 100.0*incorr_II/n_II,
							100.0*n_amb_I/n_amb, 100.0*n_amb_II/n_amb, (n_amb_I - n_amb_II) / n_amb,
							100.0*miss_I/n_I, 100.0*miss_II/n_II, 100.0*miss_amb/n_amb, 100.0*prem/(subject_dt[end,1]+1), mean([amb_I_RT ; amb_II_RT])/100.0] ;

	end

	return subject_vec
end

function amb_trial_pairing(subject_dt::Array{Int64,2}, subject_id::Int64)

	curr_press_v = Array{Int64,1}() ;
	past_press_v = Array{Int64,1}() ;
	past_reward_v = Array{Int64,1}() ;

	for i = 2 : size(subject_dt,1)
		curr_press = 0 ;
		consider_trial = false ;
		if subject_dt[i,2] == 0
			if subject_dt[i,17] != 0 	# cue 1 press
				mod(subject_id,2) == 0 ? curr_press = 1 : curr_press = 4
				consider_trial = true ;
			elseif subject_dt[i,19] != 0	# cue 2 press
				mod(subject_id,2) == 0 ? curr_press = 4 : curr_press = 1
				consider_trial = true ;
			end

		elseif subject_dt[i,2] == 1
			if subject_dt[i,17] != 0	# cue 2 press
				mod(subject_id,2) == 0 ? curr_press = 4 : curr_press = 1
				consider_trial = true ;
			end

		elseif subject_dt[i,2] == 3
			if subject_dt[i,19] != 0	# cue 1 press
				mod(subject_id,2) == 0 ? curr_press = 1 : curr_press = 4
				consider_trial = true ;
			end
		end

		past_trial = i-1 ;
		past_press = 0 ;
		past_reward = 0 ;
		found_past_trial = false ;

		if consider_trial
			while past_trial >= 1 && !found_past_trial
				if subject_dt[past_trial,2] == 0
					if subject_dt[past_trial,17] != 0 # cue 1 press correctly
						if mod(subject_id,2) == 0 
							past_press = 1 ;
							past_reward = 1 ;
						else
							past_press = 4 ;
							past_reward = 4 ;
						end
						found_past_trial = true ;
					elseif subject_dt[past_trial,19] != 0 # cue 2 press correctly
						if mod(subject_id,2) == 0 
							past_press = 4 ;
							past_reward = 4 ;
						else
							past_press = 1 ;
							past_reward = 1 ;
						end
						found_past_trial = true ;
					end

				elseif subject_dt[past_trial,2] == 1 && subject_dt[past_trial,17] != 0 # cue 2 press incorrectly
					if mod(subject_id,2) == 0 
						past_press = 4 ;
						past_reward = 0 ;
					else
						past_press = 1 ;
						past_reward = 0 ;
					end
					found_past_trial = true ;
				elseif subject_dt[past_trial,2] == 3 && subject_dt[past_trial,19] != 0 # cue 1 press incorrectly
					if mod(subject_id,2) == 0 
						past_press = 1 ;
						past_reward = 0 ;
					else
						past_press = 4 ;
						past_reward = 0 ;
					end
					found_past_trial = true ;
				elseif subject_dt[past_trial,2] == 2 && 
					(subject_dt[past_trial,17] != 0 || subject_dt[past_trial,19] != 0)	# omission
					past_press = 0 ;
					past_reward = 0 ;
					found_past_trial = true ;
				end
				past_trial -= 1 ;
			end
			if found_past_trial
				push!(curr_press_v, curr_press) ;
				push!(past_press_v, past_press) ;
				push!(past_reward_v, past_reward) ;
			end
		end
	end

	return [curr_press_v past_press_v past_reward_v]
end

function prev_trial_pairing(subject_dt::Array{Int64,2}, subject_id::Int64, n_trials_in_the_past::Int64)

	curr_press_v = Array{Int64,1}() ;
	past_press_v = Array{Int64,1}() ;
	past_reward_v = Array{Int64,1}() ;

	for i = n_trials_in_the_past + 1 : size(subject_dt,1)

		curr_press = 0 ;
		consider_trial = false ;
		
		if subject_dt[i,2] == 0
			if subject_dt[i,17] != 0 	# cue 1 press
				mod(subject_id,2) == 0 ? curr_press = 1 : curr_press = 4
				consider_trial = true ;
			elseif subject_dt[i,19] != 0	# cue 2 press
				mod(subject_id,2) == 0 ? curr_press = 4 : curr_press = 1
				consider_trial = true ;
			end

		elseif subject_dt[i,2] == 1
			if subject_dt[i,17] != 0	# cue 2 press
				mod(subject_id,2) == 0 ? curr_press = 4 : curr_press = 1
				consider_trial = true ;
			end

		elseif subject_dt[i,2] == 3
			if subject_dt[i,19] != 0	# cue 1 press
				mod(subject_id,2) == 0 ? curr_press = 1 : curr_press = 4
				consider_trial = true ;
			end
		end

		past_trial = i - n_trials_in_the_past ;
		past_press = 0 ;
		past_reward = 0 ;

		if consider_trial
			if subject_dt[past_trial,2] == 0
				if subject_dt[past_trial,13] != 0 || subject_dt[past_trial,17] != 0 # cue 1 press correctly
					if mod(subject_id,2) == 0 
						past_press = 1 ;
						past_reward = 1 ;
					else
						past_press = 4 ;
						past_reward = 4 ;
					end

				elseif subject_dt[past_trial,15] != 0 || subject_dt[past_trial,19] != 0 # cue 2 press correctly
					if mod(subject_id,2) == 0 
						past_press = 4 ;
						past_reward = 4 ;
					else
						past_press = 1 ;
						past_reward = 1 ;
					end
				end

			elseif subject_dt[past_trial,2] == 1	# cue 2 press incorrectly
				if mod(subject_id,2) == 0 
					past_press = 4 ;
					past_reward = 0 ;
				else
					past_press = 1 ;
					past_reward = 0 ;
				end
				
			elseif subject_dt[past_trial,2] == 3	# cue 1 press incorrectly
				if mod(subject_id,2) == 0 
					past_press = 1 ;
					past_reward = 0 ;
				else
					past_press = 4 ;
					past_reward = 0 ;
				end
			
			elseif subject_dt[past_trial,2] == 2	# omission
				past_press = 0 ;
				past_reward = 0 ;
			elseif subject_dt[past_trial,2] == 4	# premature
				past_press = 5 ;	# unknown press
				past_reward = 0 ;
			end
			if past_press == 0 && past_reward == 0 && subject_dt[past_trial,2] != 2
				println(subject_dt[past_trial,2])
			end

			push!(curr_press_v, curr_press) ;
			push!(past_press_v, past_press) ;
			push!(past_reward_v, past_reward) ;
		end
	end

	return [curr_press_v past_press_v past_reward_v]
end