struct subj_t
	id::String
	press_v::Array{Int64,1}
	reward_v::Array{Int64,1}
	tone_v::Array{Int64,1}
	rt_v::Array{Float64,1}
end


function klimb_read(path::String, session_to_analyse::Symbol)

	if isempty(path)
		file_v = date_sort(filter(x->occursin(".csv", x), readdir())) ;
	else
		file_v = date_sort(filter(x->occursin(".csv", x), readdir(path))) ;
	end

	subj_t_v = Array{subj_t,1}() ;

	for file_name in file_v

		file = CSV.File(string(path, file_name)) ;
		write_v = Array{Array{Any,1},1}() ;
		session = :not_interesting ;
		dt_row_len = 0 ;
		first_time = true ;
		subj_id = "" ;

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

			if occursin("Id", rf[1])
				subj_id = rf[2] ;
			end

			if occursin("Ref", rf[1]) && occursin("Outcome", rf[2]) && session != :not_interesting
				
				subj_m = Array{Int64,1}() ;
				rf = CSV.readsplitline(file.io) ;

				while !occursin("ENDDATA", rf[1]) && !occursin("-1", rf[1])

					append!(subj_m, map(x->tryparse(Int64,x), rf[1:dt_row_len])) ;
					rf = CSV.readsplitline(file.io) ;

				end

				subj_m = permutedims(reshape(subj_m, dt_row_len, :), (2,1)) ;

				if session == :probe && session_to_analyse == :probe
					if first_time
						println(file.name)
						first_time = false ;
					end

					subj_t , subj_write_v = get_probe_subj(subj_m, subj_id, 0) ;
					push!(subj_t_v, subj_t) ;
					push!(write_v, subj_write_v) ;

				elseif	session == :probe_1vs1 && session_to_analyse == :probe
					if first_time
						#println(file.name)
						first_time = false ;
					end
					
				elseif (session == :t1v1 || session == :t4v1) && session_to_analyse == :train
					if first_time
						println(file.name)
						first_time = false ;
					end

					subj_t , subj_write_v = get_train_subj(subj_m, subj_id, session, 0) ;
					push!(subj_t_v, subj_t) ;
					push!(write_v, subj_write_v) ;

				end
			end
		end
		if !isempty(write_v)
			write_xlsx(write_v, session_to_analyse, file_name, path) ;
		end
	end

	return subj_t_v
end


function get_probe_subj(subj_m::Array{Int64,2}, subj_id::String, col_offset::Int64)

	reward = zeros(Int64, size(subj_m,1)) ;
	press = zeros(Int64, size(subj_m,1)) ;
	tone = zeros(Int64, size(subj_m,1)) ;
	rt = zeros(Float64, size(subj_m,1)) ;

	id_number_idx = findlast(isequal('_'), subj_id) ;
	id_number = tryparse(Int64, subj_id[id_number_idx + 1 : end]) ;

	mask_corr_cue1 = map((x,y) -> x == 0 && y != 0, subj_m[:,2], subj_m[:,13 + col_offset]) ;
	mask_corr_cue2 = map((x,y) -> x == 0 && y != 0, subj_m[:,2], subj_m[:,15 + col_offset]) ;
	mask_incorr_cue1 = map((x,y) -> x == 1 && y != 0, subj_m[:,2], subj_m[:,13 + col_offset]) ;
	mask_incorr_cue2 = map((x,y) -> x == 3 && y != 0, subj_m[:,2], subj_m[:,15 + col_offset]) ;
	mask_corr_amb1 = map((x,y) -> x == 0 && y != 0, subj_m[:,2], subj_m[:,17 + col_offset]) ;
	mask_corr_amb2 = map((x,y) -> x == 0 && y != 0, subj_m[:,2], subj_m[:,19 + col_offset]) ;
	mask_incorr_amb1 = map((x,y) -> x == 1 && y != 0, subj_m[:,2], subj_m[:,17 + col_offset]) ;
	mask_incorr_amb2 = map((x,y) -> x == 3 && y != 0, subj_m[:,2], subj_m[:,19 + col_offset]) ;
	mask_om_cue1 = map((x,y) -> x == 2 && y != 0, subj_m[:,2], subj_m[:, 13 + col_offset]) ;
	mask_om_cue2 = map((x,y) -> x == 2 && y != 0, subj_m[:,2], subj_m[:, 15 + col_offset]) ;
	mask_om_amb1 = map((x,y) -> x == 2 && y != 0, subj_m[:,2], subj_m[:, 17 + col_offset]) ;
	mask_om_amb2 = map((x,y) -> x == 2 && y != 0, subj_m[:,2], subj_m[:, 19 + col_offset]) ;
	mask_prem = map(x -> x == 4,  subj_m[:,2]) ;

	write_v = Array{Any,1}(undef, length(probe_header_v)) ;
	write_v[1] = id_number ;

	tone[map((x,y) -> x != 0 || y != 0, subj_m[:,17+col_offset], subj_m[:,19+col_offset])] .= 5 ;
	rt[map((x,y) -> x == 5 && y != 0, tone, subj_m[:, 17+col_offset])] = (subj_m[map((x,y) -> x == 5 && y != 0, tone, subj_m[:, 17+col_offset]), 18+col_offset] - 
									subj_m[map((x,y) -> x == 5 && y != 0, tone, subj_m[:, 17+col_offset]), 17+col_offset]) / 100.0 ;
	rt[map((x,y) -> x == 5 && y != 0, tone, subj_m[:, 19+col_offset])] = (subj_m[map((x,y) -> x == 5 && y != 0, tone, subj_m[:, 19+col_offset]), 20+col_offset] - 
									subj_m[map((x,y) -> x == 5 && y != 0, tone, subj_m[:, 19+col_offset]), 19+col_offset]) / 100.0 ;

	if mod(id_number, 2) == 0 
		press[mask_corr_cue1 .| mask_corr_amb1 .| mask_incorr_cue2 .| mask_incorr_amb2] .= 1 ;
		press[mask_corr_cue2 .| mask_corr_amb2 .| mask_incorr_cue1 .| mask_incorr_amb1] .= 4 ;
		reward[mask_corr_cue1 .| mask_corr_amb1] .= 1 ;
		reward[mask_corr_cue2 .| mask_corr_amb2] .= 4 ;
		tone[mask_corr_cue1 .| mask_incorr_cue1 .| mask_om_cue1] .= 8 ;
		tone[mask_corr_cue2 .| mask_incorr_cue2 .| mask_om_cue2] .= 2 ;
		rt[map(x -> x == 2, tone)] = (subj_m[map(x -> x == 2, tone), 16] - 
									subj_m[map(x -> x == 2, tone), 15]) / 100.0 ;
		rt[map(x -> x == 8, tone)] = (subj_m[map(x -> x == 8, tone), 14] - 
									subj_m[map(x -> x == 8, tone), 13]) / 100.0 ;

		write_v[2:end] = [mean(rt[mask_corr_cue2]), 
							mean(rt[mask_corr_cue1]), 
							mean(rt[mask_incorr_cue2]), 
							mean(rt[mask_incorr_cue1]),
							mean(rt[mask_corr_amb2 .| mask_incorr_amb1]), 
							mean(rt[mask_corr_amb1 .| mask_incorr_amb2]), 
							100.0*count(x->x==true, mask_corr_cue2)/count(x -> x == true, mask_corr_cue2 .| mask_incorr_cue2), 
							100.0*count(x->x==true, mask_corr_cue1)/count(x -> x == true, mask_corr_cue1 .| mask_incorr_cue1), 
							100.0*count(x->x==true, mask_incorr_cue2)/count(x -> x == true, mask_corr_cue2 .| mask_incorr_cue2), 
							100.0*count(x->x==true, mask_incorr_cue1)/count(x -> x == true, mask_corr_cue1 .| mask_incorr_cue1),
							100.0*count(x -> x == true, mask_corr_amb2 .| mask_incorr_amb1)/count(x -> x == true, mask_corr_amb1 .| mask_incorr_amb1 .| mask_corr_amb2 .| mask_incorr_amb2), 
							100.0*count(x -> x == true, mask_corr_amb1 .| mask_incorr_amb2)/count(x -> x == true, mask_corr_amb1 .| mask_incorr_amb1 .| mask_corr_amb2 .| mask_incorr_amb2), 
							(count(x -> x == true, mask_corr_amb2 .| mask_incorr_amb1) - 
							count(x -> x == true, mask_corr_amb1 .| mask_incorr_amb2))/count(x -> x == true, mask_corr_amb1 .| mask_incorr_amb1 .| mask_corr_amb2 .| mask_incorr_amb2),
							100.0*count(x->x==true, mask_om_cue2)/count(x->x==2, tone), 
							100.0*count(x->x==true, mask_om_cue1)/count(x->x==8, tone), 
							100.0*count(x -> x == true, mask_om_amb1 .| mask_om_amb2)/count(x->x==5,tone), 
							100.0*count(x->x==true, mask_prem)/(subj_m[end,1]+1), 
							mean([rt[mask_corr_amb1 .| mask_incorr_amb1] ; 
								rt[mask_corr_amb2 .| mask_incorr_amb2]])] ;

	else
		press[mask_corr_cue1 .| mask_corr_amb1 .| mask_incorr_cue2 .| mask_incorr_amb2] .= 4 ;
		press[mask_corr_cue2 .| mask_corr_amb2 .| mask_incorr_cue1 .| mask_incorr_amb1] .= 1 ;
		reward[mask_corr_cue1 .| mask_corr_amb1] .= 4 ;
		reward[mask_corr_cue2 .| mask_corr_amb2] .= 1 ;
		tone[mask_corr_cue1 .| mask_incorr_cue1 .| mask_om_cue1] .= 2 ;
		tone[mask_corr_cue2 .| mask_incorr_cue2 .| mask_om_cue2] .= 8 ;
		rt[map(x -> x == 2, tone)] = (subj_m[map(x -> x == 2, tone), 14] - 
									subj_m[map(x -> x == 2, tone), 13]) / 100.0 ;
		rt[map(x -> x == 8, tone)] = (subj_m[map(x -> x == 8, tone), 16] - 
									subj_m[map(x -> x == 8, tone), 15]) / 100.0 ;
		
		write_v[2:end] = [mean(rt[mask_corr_cue1]), 
							mean(rt[mask_corr_cue2]), 
							mean(rt[mask_incorr_cue1]), 
							mean(rt[mask_incorr_cue2]),
							mean(rt[mask_corr_amb1 .| mask_incorr_amb2]), 
							mean(rt[mask_corr_amb2 .| mask_incorr_amb1]),  
							100.0*count(x->x==true, mask_corr_cue1)/count(x -> x == true, mask_corr_cue1 .| mask_incorr_cue1), 
							100.0*count(x->x==true, mask_corr_cue2)/count(x -> x == true, mask_corr_cue2 .| mask_incorr_cue2), 
							100.0*count(x->x==true, mask_incorr_cue1)/count(x -> x == true, mask_corr_cue1 .| mask_incorr_cue1), 
							100.0*count(x->x==true, mask_incorr_cue2)/count(x -> x == true, mask_corr_cue2 .| mask_incorr_cue2),
							100.0*count(x -> x == true, mask_corr_amb1 .| mask_incorr_amb2)/count(x -> x == true, mask_corr_amb1 .| mask_incorr_amb1 .| mask_corr_amb2 .| mask_incorr_amb2), 
							100.0*count(x -> x == true, mask_corr_amb2 .| mask_incorr_amb1)/count(x -> x == true, mask_corr_amb1 .| mask_incorr_amb1 .| mask_corr_amb2 .| mask_incorr_amb2), 
							(count(x -> x == true, mask_corr_amb1 .| mask_incorr_amb2) - 
							count(x -> x == true, mask_corr_amb2 .| mask_incorr_amb1))/count(x -> x == true, mask_corr_amb1 .| mask_incorr_amb1 .| mask_corr_amb2 .| mask_incorr_amb2),
							100.0*count(x->x==true, mask_om_cue1)/count(x->x==2, tone), 
							100.0*count(x->x==true, mask_om_cue2)/count(x->x==8, tone), 
							100.0*count(x -> x == true, mask_om_amb1 .| mask_om_amb2)/count(x->x==5,tone), 
							100.0*count(x->x==true, mask_prem)/(subj_m[end,1]+1), 
							mean([rt[mask_corr_amb1 .| mask_incorr_amb1] ; 
								rt[mask_corr_amb2 .| mask_incorr_amb2]])] ;
	end


	return subj_t(subj_id, press, reward, tone, rt) , write_v
end

function get_train_subj(subj_m::Array{Int64,2}, subj_id::String, session::Symbol, col_offset::Int64)

	reward = zeros(Int64, size(subj_m,1)) ;
	press = zeros(Int64, size(subj_m,1)) ;
	tone = zeros(Int64, size(subj_m,1)) ;
	rt = zeros(Float64, size(subj_m,1)) ;

	id_number_idx = findlast(isequal('_'), subj_id) ;
	id_number = tryparse(Int64, subj_id[id_number_idx + 1 : end]) ;

	mask_corr_cue1 = map((x,y) -> x == 0 && y != 0, subj_m[:,2], subj_m[:,15 + col_offset]) ;
	mask_corr_cue2 = map((x,y) -> x == 0 && y != 0, subj_m[:,2], subj_m[:,17 + col_offset]) ;
	mask_incorr_cue1 = map((x,y) -> x == 1 && y != 0, subj_m[:,2], subj_m[:,15 + col_offset]) ;
	mask_incorr_cue2 = map((x,y) -> x == 3 && y != 0, subj_m[:,2], subj_m[:,17 + col_offset]) ;
	mask_om_cue1 = map((x,y) -> x == 2 && y != 0, subj_m[:,2], subj_m[:, 15 + col_offset]) ;
	mask_om_cue2 = map((x,y) -> x == 2 && y != 0, subj_m[:,2], subj_m[:, 17 + col_offset]) ;
	mask_prem = map(x -> x == 4,  subj_m[:,2]) ;

	write_v = Array{Any,1}(undef, length(train_header_v)) ;
	write_v[1] = id_number ;
	write_v[2] = string(session) ;

	if mod(id_number, 2) == 0 
		press[mask_corr_cue1 .| mask_incorr_cue2] .= 1 ;
		press[mask_corr_cue2 .| mask_incorr_cue1] .= 4 ;
		reward[mask_corr_cue1] .= 1 ;
		reward[mask_corr_cue2] .= 4 ;
		tone[mask_corr_cue1 .| mask_incorr_cue1 .| mask_om_cue1] .= 8 ;
		tone[mask_corr_cue2 .| mask_incorr_cue2 .| mask_om_cue2] .= 2 ;
		rt[map(x -> x == 2, tone)] = (subj_m[map(x -> x == 2, tone), 18] - 
									subj_m[map(x -> x == 2, tone), 17]) / 100.0 ;
		rt[map(x -> x == 8, tone)] = (subj_m[map(x -> x == 8, tone), 16] - 
									subj_m[map(x -> x == 8, tone), 15]) / 100.0 ;

		write_v[3:end] = [mean(rt[mask_corr_cue2]), 
							mean(rt[mask_corr_cue1]), 
							mean(rt[mask_incorr_cue2]), 
							mean(rt[mask_incorr_cue1]), 
							100.0*count(x->x==true, mask_corr_cue2)/count(x -> x == true, mask_corr_cue2 .| mask_incorr_cue2), 
							100.0*count(x->x==true, mask_corr_cue1)/count(x -> x == true, mask_corr_cue1 .| mask_incorr_cue1), 
							100.0*count(x->x==true, mask_incorr_cue2)/count(x -> x == true, mask_corr_cue2 .| mask_incorr_cue2), 
							100.0*count(x->x==true, mask_incorr_cue1)/count(x -> x == true, mask_corr_cue1 .| mask_incorr_cue1),
							100.0*count(x->x==true, mask_om_cue2)/count(x->x==2, tone), 
							100.0*count(x->x==true, mask_om_cue1)/count(x->x==8, tone), 
							100.0*count(x->x==true, mask_prem)/(subj_m[end,1]+1)] ;

	else
		press[mask_corr_cue1 .| mask_incorr_cue2] .= 4 ;
		press[mask_corr_cue2 .| mask_incorr_cue1] .= 1 ;
		reward[mask_corr_cue1] .= 4 ;
		reward[mask_corr_cue2] .= 1 ;
		tone[mask_corr_cue1 .| mask_incorr_cue1 .| mask_om_cue1] .= 2 ;
		tone[mask_corr_cue2 .| mask_incorr_cue2 .| mask_om_cue2] .= 8 ;
		rt[map(x -> x == 2, tone)] = (subj_m[map(x -> x == 2, tone), 16] - 
									subj_m[map(x -> x == 2, tone), 15]) / 100.0 ;
		rt[map(x -> x == 8, tone)] = (subj_m[map(x -> x == 8, tone), 18] - 
									subj_m[map(x -> x == 8, tone), 17]) / 100.0 ;
		
		write_v[3:end] = [mean(rt[mask_corr_cue1]), 
							mean(rt[mask_corr_cue2]), 
							mean(rt[mask_incorr_cue1]), 
							mean(rt[mask_incorr_cue2]),  
							100.0*count(x->x==true, mask_corr_cue1)/count(x -> x == true, mask_corr_cue1 .| mask_incorr_cue1), 
							100.0*count(x->x==true, mask_corr_cue2)/count(x -> x == true, mask_corr_cue2 .| mask_incorr_cue2), 
							100.0*count(x->x==true, mask_incorr_cue1)/count(x -> x == true, mask_corr_cue1 .| mask_incorr_cue1), 
							100.0*count(x->x==true, mask_incorr_cue2)/count(x -> x == true, mask_corr_cue2 .| mask_incorr_cue2),
							100.0*count(x->x==true, mask_om_cue1)/count(x->x==2, tone), 
							100.0*count(x->x==true, mask_om_cue2)/count(x->x==8, tone), 
							100.0*count(x->x==true, mask_prem)/(subj_m[end,1]+1)] ;
	end

	return subj_t(subj_id, press, reward, tone, rt) , write_v
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

function write_xlsx(row_write_v::Array{Array{Any,1},1}, session::Symbol, in_file::String, in_path::String)

	xlsx_file = string(in_path, in_file[1:11],".xlsx") ;

	session == :probe ? header_v = probe_header_v : header_v = train_header_v

	column_write_v = Array{Array{Any,1},1}() ;

	for i = 1 : length(row_write_v[1])
		push!(column_write_v, map(x -> x[i], row_write_v)) ;
	end 

	df = DataFrame(Dict(map((x,y) -> x=>y, header_v, column_write_v))) ;

	XLSX.writetable(xlsx_file, DataFrames.columns(df), DataFrames.names(df), overwrite = true) ;
end
