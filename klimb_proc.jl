using CSV

function date_sort(fv :: Array{String})

	date_m = Array{Any,2}(length(fv), 4) ;

	i = 1 ;
	for date in fv
		date_m[i,1] = parse(date[1:2]) ;

		if contains(date, "Jan")
			date_m[i,2] = 1 ;
		elseif contains(date, "Feb")
			date_m[i,2] = 2 ;
		elseif contains(date, "Mar")
			date_m[i,2] = 3 ;
		elseif contains(date, "Apr")
			date_m[i,2] = 4 ;
		elseif contains(date, "May")
			date_m[i,2] = 5 ;
		elseif contains(date, "Jun")
			date_m[i,2] = 6 ;
		elseif contains(date, "Jul")
			date_m[i,2] = 7 ;
		elseif contains(date, "Aug")
			date_m[i,2] = 8 ;
		elseif contains(date, "Sep")
			date_m[i,2] = 9 ;
		elseif contains(date, "Oct")
			date_m[i,2] = 10 ;
		elseif contains(date, "Nov")
			date_m[i,2] = 11 ;
		elseif contains(date, "Dec")
			date_m[i,2] = 12 ;
		else
			println("Invalid date")
		end

		date_m[i,3] = parse(date[8:11]) ;
		date_m[i,4] = date ;
		i += 1 ;
	end

	date_m = sortrows(date_m, by = x->(x[3],x[2],x[1],x[4]))

	sorted_fv = Array{String, 1}(length(fv)) ;

	for i = 1 : length(fv)
		sorted_fv[i] = date_m[i,4] ;
	end
	return sorted_fv
end

function string_iseq(s::String, target_s::String)

	if length(s) >= length(target_s)
		if s[1:length(target_s)] == target_s
			return true
		end
	end
	return false
end

function map_rf_to_num(rf::Array{CSV.RawField}, T)

	s_from_rf = Array{String}(length(rf) - 1) ;

	for i = 1 : length(s_from_rf)
		s_from_rf[i] = rf[i].value ;
	end

	return map(x -> parse(T, x), s_from_rf)
end

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
