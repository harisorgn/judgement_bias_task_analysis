function triple_joint_entropy(d1::Array{Int64,1}, d2::Array{Int64,1}, d3::Array{Int64,1})

	d_tuple = Array{Tuple{Int64, Int64, Int64},1}() ;
	n_data = length(d1) ;

	for i = 1 : n_data
		push!(d_tuple, (d1[i], d2[i], d3[i])) ;
	end

	cm = countmap(d_tuple) ;
	keys_v = collect(keys(cm)) ;
	e = 0 ;
	for key in collect(keys(cm)) #i = 1 : length(keys_v)
		e += - (cm[key]/n_data) * log((cm[key]/n_data)) ;
	end

	return e
end

function klimb_read(path::String, session_to_analyse::Symbol)

	if isempty(path)
		file_v = date_sort(filter(x->occursin(".csv", x), readdir())) ;
	else
		file_v = date_sort(filter(x->occursin(".csv", x), readdir(path))) ;
	end

	curr_press_totv = Array{Int64,1}() ;
	past_press_totv = Array{Int64,1}() ;
	past_reward_totv = Array{Int64,1}() ;
	
	for file_name in file_v
		file = CSV.File(string(path, file_name)) ;

		session = :not_interesting ;
		dt_row_len = 0 ;
		first_time = true ;

		while !CSV.eof(file.io)
			 
			subject_id = 0 ;

			rf = CSV.readsplitline(file.io) ;

			if occursin("AC Comment", rf[1])

				if occursin("Sequence", rf[3]) && occursin("probe", rf[3])
					session = :probe ;
					dt_row_len = 20 ;

				elseif occursin("Sequence", rf[3]) && occursin("training", rf[3])
					session = :seq ;
					dt_row_len = 20 ;

				elseif occursin("seq", rf[3])
					session = :seq ;
					dt_row_len = 18 ;

				elseif occursin("Pure", rf[3])
					session = :t4v1 ;
					dt_row_len = 18 ;

				elseif occursin("Discrimination", rf[3])
					session = :t1v1 ;
					dt_row_len = 18 ;

				elseif occursin("Probe", rf[3]) && occursin("midpoint", rf[3])
					session = :probe ;
					dt_row_len = 20 ;

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

				if session == :probe && session_to_analyse == :probe && subject_id <= 16
					tp = trial_pairing(subject_dt, subject_id)
					if first_time
						println(file.name)
						first_time = false ;
					end

					append!(curr_press_totv, tp[:,1]) ;
					append!(past_press_totv, tp[:,2]) ;
					append!(past_reward_totv, tp[:,3]) ;

				elseif session != :probe && session != :not_interesting && session_to_analyse == :train
					if first_time
						println(file.name)
						first_time = false ;
					end
				end
			end
		end
	end
	#println(mutual_information(curr_press_totv, past_reward_totv;normalize = true))
	#println(mutual_information(curr_press_totv, past_press_totv;normalize = true))

	e_cp = estimate_entropy(curr_press_totv) ;
	e_pp = estimate_entropy(past_press_totv) ;
	e_pr = estimate_entropy(past_reward_totv) ;
	e_cp_pp = estimate_joint_entropy(curr_press_totv, past_press_totv) ;
	e_pr_pp = estimate_joint_entropy(past_reward_totv, past_press_totv) ;
	e_cp_pr_pp = triple_joint_entropy(curr_press_totv, past_press_totv, past_reward_totv) ;

	println(e_cp_pp + e_pr_pp - e_cp_pr_pp - e_pp)
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

function trial_pairing(subject_dt::Array{Int64,2}, subject_id::Int64)

	curr_press_v = Array{Int64,1}() ;
	past_press_v = Array{Int64,1}() ;
	past_reward_v = Array{Int64,1}() ;

	for i = 2 : size(subject_dt,1)
		curr_press = 0 ;
		if (subject_dt[i,3] == 2 && subject_dt[i,2] == 0) ||
			(subject_dt[i,3] == 3 && subject_dt[i,2] == 3)
			# cue 1 lever pressed
			if mod(subject_id,2) == 0 
				curr_press = 1 ;
			else
				curr_press = 4 ;
			end
		elseif (subject_dt[i,3] == 3 && subject_dt[i,2] == 0) ||
			(subject_dt[i,3] == 2 && subject_dt[i,2] == 1)
			# cue 2 lever pressed
			if mod(subject_id,2) == 0 
				curr_press = 4 ;
			else
				curr_press = 1 ;
			end
		end
		
		past_trial = i-1 ;
		past_press = 0 ;
		past_reward = 0 ;
		found_past_trial = false ;

		if subject_dt[i,3] == 2 || subject_dt[i,3] == 3
			while past_trial >= 1 && !found_past_trial
				if subject_dt[past_trial,3] == 2 && subject_dt[past_trial,2] == 0
					# cue 1 lever pressed correctly
					if mod(subject_id,2) == 0 
						past_press = 1 ;
						past_reward = 1 ;
					else
						past_press = 4 ;
						past_reward = 4 ;
					end
					found_past_trial = true ;

				elseif subject_dt[past_trial,3] == 3 && subject_dt[past_trial,2] == 3
					# cue 1 lever pressed incorrectly 
					if mod(subject_id,2) == 0 
						past_press = 1 ;
						past_reward = 0 ;
					else
						past_press = 4 ;
						past_reward = 0 ;
					end
					found_past_trial = true ;

				elseif subject_dt[past_trial,3] == 3 && subject_dt[past_trial,2] == 0
					# cue 2 lever pressed correctly
					if mod(subject_id,2) == 0 
						past_press = 4 ;
						past_reward = 4 ;
					else
						past_press = 1 ;
						past_reward = 1 ;
					end
					found_past_trial = true ;

				elseif subject_dt[past_trial,3] == 2 && subject_dt[past_trial,2] == 1
					# cue 2 lever pressed incorrectly
					if mod(subject_id,2) == 0 
						past_press = 4 ;
						past_reward = 0 ;
					else
						past_press = 1 ;
						past_reward = 0 ;
					end
					found_past_trial = true ;

				end
				past_trial -= 1 ;
			end
		end

		if past_press != 0
			push!(curr_press_v, curr_press) ;
			push!(past_press_v, past_press) ;
			push!(past_reward_v, past_reward) ;
		end
	end

	return [curr_press_v past_press_v past_reward_v]
end
#=

function write_xlsx(subject_vec::Array{Any,1}, session::Symbol, in_file::String, in_path::String)


	#xlsx_file = string("./naltrexone/","Res_", in_file[1:6],".xlsx") ;
	xlsx_file = string(in_path, in_file[1:11],".xlsx") ;

	first_cell = XLSX.CellRef("", 2, 1) ;
	last_cell = XLSX.CellRef("", 17, length(header_vec)) ;

	XLSX.openxlsx(xlsx_file) do xf

	sheets = XLSX.sheetnames(xf) ;

	found_row_to_write = false ;
	end_of_file = false ;

	df_total_dt = DataFrame(col_type_vec, [parse(i) for i in header_vec], 0) ;

	while ~found_row_to_write || ~end_of_file

		cell_range = XLSX.CellRange(first_cell, last_cell) ;
		curr_dt = XLSX.readdata(xlsx_file, sheets[1], cell_range) ;

		if ismissing(curr_dt[subject_vec[1], 1]) && ~found_row_to_write
			curr_dt[subject_vec[1], :] = subject_vec ;
			found_row_to_write = true ;
		end

		df_curr_dt = DataFrame(curr_dt, [parse(i) for i in header_vec]) ;
		append!(df_total_dt, df_curr_dt) ;

		if all([ismissing(j) for j in curr_dt[:,1]])
			end_of_file = true ;
		end

		first_cell = XLSX.CellRef("", first_cell.row_number + 16, first_cell.column_number) ;
		last_cell = XLSX.CellRef("", last_cell.row_number + 16, last_cell.column_number) ;
	end

	XLSX.writetable(xlsx_file, DataFrames.columns(df_total_dt), DataFrames.names(df_total_dt), overwrite = true) ;
	close(xf)
	end
end

function train_write(subject_dt::Array{Int64,2}, subject_id::Int64, session::String, in_file::String, in_path::String)

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

	subject_vec = Array{Any,1}(length(train_header_vec)) ;
	subject_vec[1] = subject_id ;
	subject_vec[2] = session ;

	if mod(subject_id,2) == 0

		subject_vec[3:end] = [mean(corr_II_RT)/100.0, mean(corr_I_RT)/100.0, mean(incorr_II_RT)/100.0, mean(incorr_I_RT)/100.0,
							100.0*corr_II/n_II, 100.0*corr_I/n_I, 100.0*incorr_II/n_II, 100.0*incorr_I/n_I,
							100.0*miss_II/n_II, 100.0*miss_I/n_I, prem] ;

	else

		subject_vec[3:end] = [mean(corr_I_RT)/100.0, mean(corr_II_RT)/100.0, mean(incorr_I_RT)/100.0, mean(incorr_II_RT)/100.0,
						100.0*corr_I/n_I, 100.0*corr_II/n_II, 100.0*incorr_I/n_I, 100.0*incorr_II/n_II,
						100.0*miss_I/n_I, 100.0*miss_II/n_II, prem] ;

	end

	write_xlsx(subject_vec, :train, in_file, in_path)
	return
end

function probe_write(subject_dt::Array{Int64,2}, subject_id::Int64, in_file::String, in_path::String)

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

			if subject_dt[i,13] != 0

				corr_I += 1 ;
				push!(corr_I_RT, subject_dt[i,14] - subject_dt[i,13]) ;
				n_I += 1 ;

			elseif subject_dt[i,15] != 0

				corr_II += 1 ;
				push!(corr_II_RT, subject_dt[i,16] - subject_dt[i,15]) ;
				n_II += 1 ;

			elseif subject_dt[i,17] != 0

				n_amb_I += 1 ;
				push!(amb_I_RT, subject_dt[i,18] - subject_dt[i,17]) ;
				n_amb += 1 ;

			elseif subject_dt[i,19] != 0

				n_amb_II += 1 ;
				push!(amb_II_RT, subject_dt[i,20] - subject_dt[i,19]) ;
				n_amb += 1 ;

			end

		elseif subject_dt[i,2] == 1

			if subject_dt[i,17] != 0

				n_amb_II += 1 ;
				push!(amb_II_RT, subject_dt[i,18] - subject_dt[i,17]) ;
				n_amb += 1 ;

			else

				incorr_I += 1 ;
				push!(incorr_I_RT, subject_dt[i,14] - subject_dt[i,13]) ;
				n_I += 1 ;
			end

		elseif subject_dt[i,2] == 3

			if subject_dt[i,19] != 0

				n_amb_I += 1 ;
				push!(amb_I_RT, subject_dt[i,20] - subject_dt[i,19]) ;
				n_amb += 1 ;

			else

				incorr_II += 1 ;
				push!(incorr_II_RT, subject_dt[i,16] - subject_dt[i,15]) ;
				n_II += 1 ;
			end

		elseif subject_dt[i,2] == 2

			if subject_dt[i,13] != 0

				miss_I += 1 ;
				n_I += 1 ;

			elseif subject_dt[i,15] != 0

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

	subject_vec = Array{Any,1}(length(probe_header_vec)) ;
	subject_vec[1] = subject_id ;

	if mod(subject_id,2) == 0
		# High reward is II
		subject_vec[2:end] = [mean(corr_II_RT)/100.0, mean(corr_I_RT)/100.0, mean(incorr_II_RT)/100.0, mean(incorr_I_RT)/100.0,
							mean(amb_II_RT)/100.0, mean(amb_I_RT)/100.0, 100.0*corr_II/n_II, 100.0*corr_I/n_I, 100.0*incorr_II/n_II, 100.0*incorr_I/n_I,
							100.0*n_amb_II/n_amb, 100.0*n_amb_I/n_amb, (n_amb_II - n_amb_I) / n_amb,
							100.0*miss_II/n_II, 100.0*miss_I/n_I, 100.0*miss_amb/n_amb, prem, mean([amb_I_RT ; amb_II_RT])/100.0] ;

	else
		# High reward is I
		subject_vec[2:end] = [mean(corr_I_RT)/100.0, mean(corr_II_RT)/100.0, mean(incorr_I_RT)/100.0, mean(incorr_II_RT)/100.0,
							mean(amb_I_RT)/100.0, mean(amb_II_RT)/100.0, 100.0*corr_I/n_I, 100.0*corr_II/n_II, 100.0*incorr_I/n_I, 100.0*incorr_II/n_II,
							100.0*n_amb_I/n_amb, 100.0*n_amb_II/n_amb, (n_amb_I - n_amb_II) / n_amb,
							100.0*miss_I/n_I, 100.0*miss_II/n_II, 100.0*miss_amb/n_amb, prem, mean([amb_I_RT ; amb_II_RT])/100.0] ;

	end

	write_xlsx(subject_vec, :probe, in_file, in_path)
	return

end

function prev_trial_probe(subject_dt::Array{Int64,2}, subject_id::Int64, in_file::String)

	n_same_I = 0 ;
	n_same_II = 0 ;

	n_I = 0 ;
	n_II = 0 ;

	for i = 2 : size(subject_dt,1)

		#=
		if ((subject_dt[i,17] != 0 && subject_dt[i,2] == 0) || (subject_dt[i,19] != 0 && subject_dt[i,2] == 3))
			# lever I press
			prev_trial = i-1 ;
			while subject_dt[prev_trial,2] != 0 && prev_trial > 1 #subject_dt[prev_trial,2] == 2 && subject_dt[prev_trial,2] == 4
				prev_trial -= 1 ;
			end
			if ((subject_dt[prev_trial,13] != 0 && subject_dt[prev_trial,2] == 0) || (subject_dt[prev_trial,15] != 0 && subject_dt[i,2] == 3))
				n_same_I += 1 ;
			end
			n_I += 1 ;
		end

		if ((subject_dt[i,19] != 0 && subject_dt[i,2] == 0) || (subject_dt[i,17] != 0 && subject_dt[i,2] == 1))
			# lever II n_amb_II_presses
			prev_trial = i-1 ;
			while subject_dt[prev_trial,2] != 0 && prev_trial > 1 #subject_dt[prev_trial,2] == 2 && subject_dt[prev_trial,2] == 4
				prev_trial -= 1 ;
			end
			if ((subject_dt[prev_trial,15] != 0 && subject_dt[prev_trial,2] == 0) || (subject_dt[prev_trial,13] != 0 && subject_dt[i,2] == 1))
				n_same_II += 1 ;
			end
			n_II += 1 ;
		end
		=#

		if ((subject_dt[i,17] != 0 && subject_dt[i,2] == 0) || (subject_dt[i,19] != 0 && subject_dt[i,2] == 3))
			# lever I press
			prev_trial = i-1 ;
			while (subject_dt[prev_trial,2] != 1 || subject_dt[prev_trial,2] != 3) && prev_trial > 1 #subject_dt[prev_trial,2] == 2 && subject_dt[prev_trial,2] == 4
				prev_trial -= 1 ;
			end
			if ((subject_dt[prev_trial,13] != 0 && subject_dt[prev_trial,2] == 0) || (subject_dt[prev_trial,15] != 0 && subject_dt[i,2] == 3))
				n_same_I += 1 ;
			end
			n_I += 1 ;
		end

		if ((subject_dt[i,19] != 0 && subject_dt[i,2] == 0) || (subject_dt[i,17] != 0 && subject_dt[i,2] == 1))
			# lever II n_amb_II_presses
			prev_trial = i-1 ;
			while (subject_dt[prev_trial,2] != 1 || subject_dt[prev_trial,2] != 3) && prev_trial > 1 #subject_dt[prev_trial,2] == 2 && subject_dt[prev_trial,2] == 4
				prev_trial -= 1 ;
			end
			if ((subject_dt[prev_trial,15] != 0 && subject_dt[prev_trial,2] == 0) || (subject_dt[prev_trial,13] != 0 && subject_dt[i,2] == 1))
				n_same_II += 1 ;
			end
			n_II += 1 ;
		end

	end

	println(subject_id, " : ", 100.0*n_same_I/n_I, "  ", 100.0*n_same_II/n_II)
end

function easy_probe_write(subject_dt::Array{Int64,2}, subject_id::Int64, in_file::String)

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

	corr_amb_I = 0 ;
	corr_amb_II = 0 ;
	incorr_amb_I = 0 ;
	incorr_amb_II = 0 ;
	miss_amb_I = 0 ;
	miss_amb_II = 0 ;
	corr_RT_amb_I = Array{Float64,1}() ;
	corr_RT_amb_II = Array{Float64,1}() ;
	incorr_RT_amb_I = Array{Float64,1}() ;
	incorr_RT_amb_II = Array{Float64,1}() ;

	n_I = 0 ;
	n_II = 0 ;
	n_amb_I = 0 ;
	n_amb_II = 0 ;
	n_amb_I_presses = 0 ;
	n_amb_II_presses = 0 ;
	RT_amb_I = Array{Float64,1}() ;
	RT_amb_II = Array{Float64,1}() ;

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

			else # subject_dt[i,19] != 0

				if subject_dt[i,3] == 2
					if subject_dt[i,21] != 0
						corr_amb_II += 1 ;
						push!(corr_RT_amb_II, subject_dt[i,20] - subject_dt[i,19]) ;
						push!(RT_amb_II, subject_dt[i,20] - subject_dt[i,19]) ;
						n_amb_II_presses += 1 ;
					else
						incorr_amb_II += 1 ;
						push!(incorr_RT_amb_II, subject_dt[i,20] - subject_dt[i,19]) ;
						push!(RT_amb_I, subject_dt[i,20] - subject_dt[i,19]) ;
						n_amb_I_presses += 1 ;
					end
					n_amb_II += 1 ;

				elseif subject_dt[i,3] == 4
					if subject_dt[i,22] != 0
						corr_amb_I += 1 ;
						push!(corr_RT_amb_I, subject_dt[i,20] - subject_dt[i,19]) ;
						push!(RT_amb_I, subject_dt[i,20] - subject_dt[i,19]) ;
						n_amb_I_presses += 1 ;
					else
						incorr_amb_I += 1 ;
						push!(incorr_RT_amb_I, subject_dt[i,20] - subject_dt[i,19]) ;
						push!(RT_amb_II, subject_dt[i,20] - subject_dt[i,19]) ;
						n_amb_II_presses += 1 ;
					end
					n_amb_I += 1 ;
				end
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

			else # subject_dt[i,19] != 0

				if subject_dt[i,3] == 2

					miss_amb_II += 1 ;
					#n_amb_II += 1 ;

				elseif subject_dt[i,3] == 4

					miss_amb_I += 1 ;
					#n_amb_I += 1 ;

				end

			end

		elseif subject_dt[i,2] == 4
			prem += 1 ;
		end


	end

	subject_vec = Array{Any,1}(length(probe_header_vec)) ;
	subject_vec[1] = subject_id ;

	if mod(subject_id,2) == 0

		subject_vec[2:end] = [mean(corr_II_RT)/100.0, mean(corr_I_RT)/100.0, mean(corr_RT_amb_II)/100.0, mean(corr_RT_amb_I)/100.0,
							mean(incorr_II_RT)/100.0, mean(incorr_I_RT)/100.0, mean(incorr_RT_amb_II)/100.0, mean(incorr_RT_amb_I)/100.0,
							100.0*corr_II/n_II, 100.0*corr_I/n_I, 100.0*corr_amb_II/n_amb_II, 100.0*corr_amb_I/n_amb_I,
							100.0*incorr_amb_II/n_amb_II, 100.0*incorr_amb_I/n_amb_I,
							mean(RT_amb_II)/100.0, mean(RT_amb_I)/100.0, 100.0*n_amb_II_presses/(n_amb_I + n_amb_II),
							100.0*n_amb_I_presses/(n_amb_I + n_amb_II)] ;

	else

		subject_vec[2:end] = [mean(corr_I_RT)/100.0, mean(corr_II_RT)/100.0, mean(corr_RT_amb_I)/100.0, mean(corr_RT_amb_II)/100.0,
						mean(incorr_I_RT)/100.0, mean(incorr_II_RT)/100.0, mean(incorr_RT_amb_I)/100.0, mean(incorr_RT_amb_II)/100.0,
						100.0*corr_I/n_I, 100.0*corr_II/n_II, 100.0*corr_amb_I/n_amb_I, 100.0*corr_amb_II/n_amb_II,
						100.0*incorr_amb_I/n_amb_I, 100.0*incorr_amb_II/n_amb_II,
						mean(RT_amb_I)/100.0, mean(RT_amb_II)/100.0, 100.0*n_amb_I_presses/(n_amb_I + n_amb_II),
						100.0*n_amb_II_presses/(n_amb_I + n_amb_II)] ;

	end

	write_xlsx(subject_vec, :probe, in_file)
	return
end

function hard_probe_write(subject_dt::Array{Int64,2}, subject_id::Int64, in_file::String)

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

	corr_amb_I = 0 ;
	corr_amb_II = 0 ;
	incorr_amb_I = 0 ;
	incorr_amb_II = 0 ;
	miss_amb_I = 0 ;
	miss_amb_II = 0 ;
	corr_RT_amb_I = Array{Float64,1}() ;
	corr_RT_amb_II = Array{Float64,1}() ;
	incorr_RT_amb_I = Array{Float64,1}() ;
	incorr_RT_amb_II = Array{Float64,1}() ;

	n_I = 0 ;
	n_II = 0 ;
	n_amb_I = 0 ;
	n_amb_II = 0 ;
	n_amb_I_presses = 0 ;
	n_amb_II_presses = 0 ;
	RT_amb_I = Array{Float64,1}() ;
	RT_amb_II = Array{Float64,1}() ;

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
			else # subject_dt[i,19] != 0

				if subject_dt[i,3] == 2
					if subject_dt[i,21] != 0
						corr_amb_II += 1 ;
						push!(corr_RT_amb_II, subject_dt[i,20] - subject_dt[i,19]) ;
						push!(RT_amb_II, subject_dt[i,20] - subject_dt[i,19]) ;
						n_amb_II_presses += 1 ;
					else
						incorr_amb_II += 1 ;
						push!(incorr_RT_amb_II, subject_dt[i,20] - subject_dt[i,19]) ;
						push!(RT_amb_I, subject_dt[i,20] - subject_dt[i,19]) ;
						n_amb_I_presses += 1 ;
					end
					n_amb_II += 1 ;

				elseif subject_dt[i,3] == 6
					if subject_dt[i,22] != 0
						corr_amb_I += 1 ;
						push!(corr_RT_amb_I, subject_dt[i,20] - subject_dt[i,19]) ;
						push!(RT_amb_I, subject_dt[i,20] - subject_dt[i,19]) ;
						n_amb_I_presses += 1 ;
					else
						incorr_amb_I += 1 ;
						push!(incorr_RT_amb_I, subject_dt[i,20] - subject_dt[i,19]) ;
						push!(RT_amb_II, subject_dt[i,20] - subject_dt[i,19]) ;
						n_amb_II_presses += 1 ;
					end
					n_amb_I += 1 ;
				end
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

			else # subject_dt[i,19] != 0

				if subject_dt[i,3] == 2

					miss_amb_II += 1 ;
					#n_amb_II += 1 ;

				elseif subject_dt[i,3] == 6

					miss_amb_I += 1 ;
					#n_amb_I += 1 ;

				end

			end

		elseif subject_dt[i,2] == 4
			prem += 1 ;
		end


	end

	subject_vec = Array{Any,1}(length(probe_header_vec)) ;
	subject_vec[1] = subject_id ;

	if mod(subject_id,2) == 0

		subject_vec[2:end] = [mean(corr_II_RT)/100.0, mean(corr_I_RT)/100.0, mean(corr_RT_amb_II)/100.0, mean(corr_RT_amb_I)/100.0,
							mean(incorr_II_RT)/100.0, mean(incorr_I_RT)/100.0, mean(incorr_RT_amb_II)/100.0, mean(incorr_RT_amb_I)/100.0,
							100.0*corr_II/n_II, 100.0*corr_I/n_I, 100.0*corr_amb_II/n_amb_II, 100.0*corr_amb_I/n_amb_I,
							100.0*incorr_amb_II/n_amb_II, 100.0*incorr_amb_I/n_amb_I,
							mean(RT_amb_II)/100.0, mean(RT_amb_I)/100.0, 100.0*n_amb_II_presses/(n_amb_I + n_amb_II),
							100.0*n_amb_I_presses/(n_amb_I + n_amb_II)] ;

	else

		subject_vec[2:end] = [mean(corr_I_RT)/100.0, mean(corr_II_RT)/100.0, mean(corr_RT_amb_I)/100.0, mean(corr_RT_amb_II)/100.0,
						mean(incorr_I_RT)/100.0, mean(incorr_II_RT)/100.0, mean(incorr_RT_amb_I)/100.0, mean(incorr_RT_amb_II)/100.0,
						100.0*corr_I/n_I, 100.0*corr_II/n_II, 100.0*corr_amb_I/n_amb_I, 100.0*corr_amb_II/n_amb_II,
						100.0*incorr_amb_I/n_amb_I, 100.0*incorr_amb_II/n_amb_II,
						mean(RT_amb_I)/100.0, mean(RT_amb_II)/100.0, 100.0*n_amb_I_presses/(n_amb_I + n_amb_II),
						100.0*n_amb_II_presses/(n_amb_I + n_amb_II)] ;

	end

	write_xlsx(subject_vec, :probe, in_file)
	return
end
=#