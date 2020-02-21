struct subj_t
	id::String
	response_v::Array{Int64,1}
	reward_v::Array{Int64,1}
	tone_v::Array{Int64,1}
	rt_v::Array{Float64,1}
	cbi::Float64
end

function klimb_read(path::String, session_to_analyse::Symbol, write_flag::Bool)

	if isempty(path)
		file_v = date_sort(filter(x->occursin(".csv", x), readdir())) ;
	else
		file_v = date_sort(filter(x->occursin(".csv", x), readdir(path))) ;
	end

	subj_t_v = Array{subj_t,1}() ;

	for file_name in file_v
		
		df = read_csv_var_cols(string(path, file_name)) ;

		write_v = Array{Array{Any,1},1}() ;
		session = :not_interesting ;
		dt_row_len = 0 ;
		first_time = true ;
		subj_id = "" ;

		probe_tone_1v1 = 0 ;
		row_idx = 0 ;

		while row_idx < DataFrames.nrow(df)

			row_idx += 1 ;

			if occursin("Probablistic", df[row_idx, 2])
				session = :probabilistic ;
				dt_row_len = 28 ;
			end

			if occursin("AC Comment", df[row_idx, 1]) && session != :probabilistic
				if occursin("Pure", df[row_idx, 3])
					session = :t4v1 ;
					dt_row_len = 18 ;
				elseif occursin("Discrimination", df[row_idx, 3]) && occursin("5.5kHz", df[row_idx, 3])
					session = :probe_var_p_1v1 ;
					dt_row_len = 16 ;
					probe_tone_1v1 = 4 ; # 5.5 kHz
				elseif occursin("Discrimination", df[row_idx, 3]) && occursin("5kHz", df[row_idx, 3])
					session = :probe_var_p_1v1 ;
					dt_row_len = 16 ;
					probe_tone_1v1 = 3 ; # 5 kHz
				elseif occursin("Discrimination", df[row_idx, 3]) && occursin("6kHz", df[row_idx, 3])
					session = :probe_var_p_1v1 ;
					dt_row_len = 16 ;
					probe_tone_1v1 = 5 ; # 6 kHz
				elseif occursin("Discrimination", df[row_idx, 3]) && occursin("training", df[row_idx, 3]) 
					session = :t1v1 ;
					dt_row_len = 18 ;
				elseif occursin("Discrimination", df[row_idx, 3])
					session = :t1v1_light_tone ;
					dt_row_len = 42 ;
				elseif occursin("Route", df[row_idx, 3])
					session = :pulses ;
					dt_row_len = 22 ;
				elseif occursin("Probe", df[row_idx, 3]) && occursin("midpoint", df[row_idx, 3])
					session = :probe ;
					dt_row_len = 20 ;
				elseif occursin("Probe", df[row_idx, 3]) && occursin("1 vs 1", df[row_idx, 3])
					session = :probe_1v1 ;
					dt_row_len = 22 ;
				elseif occursin("Probe", df[row_idx, 3]) && occursin("multiple", df[row_idx, 3])
					session = :probe_mult_p ;
					dt_row_len = 30 ;
				elseif occursin("Probe", df[row_idx, 3]) && occursin("tones", df[row_idx, 3])
					session = :probe_mult_p_1v1 ;
					dt_row_len = 13 ;
				elseif occursin("CRF", df[row_idx, 3])
					session = :crf ;
					dt_row_len = 32 ;
				elseif occursin("1vs1", df[row_idx, 3])
					session = :probe_1v1_light_tone ;
					dt_row_len = 32 ;
				end
			end

			if occursin("Id", df[row_idx, 1])
				subj_id = df[row_idx, 2] ;
			end
			
			if occursin("Ref", df[row_idx, 1]) && occursin("Outcome", df[row_idx, 2]) && session != :not_interesting &&
				!any(exclude_v .== subj_id)
				subj_m = Array{Int64,1}() ;
				row_idx += 1 ;

				while !occursin("ENDDATA", df[row_idx, 1]) && !occursin("-1", df[row_idx, 1])
					append!(subj_m, map(x->tryparse(Int64,x), df[row_idx, 1:dt_row_len])) ;
					row_idx += 1 ;
				end

				subj_m = permutedims(reshape(subj_m, dt_row_len, :), (2,1)) ;
				
				if session == :probe && session_to_analyse == :probe
					if first_time
						println(file_name)
						first_time = false ;
					end

					subj_t , subj_write_v = get_probe_subj(subj_m, subj_id, 0) ;

					if subj_write_v[8] >= acc_criterion && subj_write_v[9] >= acc_criterion
						push!(subj_t_v, subj_t) ;
						push!(write_v, subj_write_v) ;
					else
						push!(exclude_v, subj_id) ;
					end
				elseif	session == :probabilistic && session_to_analyse == :probe
					if first_time
						println(file_name)
						first_time = false ;
					end
					
					subj_t , subj_write_v = get_probe_probabilistic_subj(subj_m, subj_id) ;

					if subj_write_v[8] >= acc_criterion && subj_write_v[9] >= acc_criterion
						push!(subj_t_v, subj_t) ;
						push!(write_v, subj_write_v) ;
					end					
				elseif	session == :probe_1v1 && session_to_analyse == :probe
					if first_time
						println(file_name)
						first_time = false ;
					end
					
					subj_t , subj_write_v = get_probe_subj(subj_m, subj_id, 2) ;
					
					if subj_write_v[8] >= acc_criterion && subj_write_v[9] >= acc_criterion
						push!(subj_t_v, subj_t) ;
						push!(write_v, subj_write_v) ;
					end	
				elseif	session == :probe_1v1_light_tone && session_to_analyse == :probe
					if first_time
						println(file_name)
						first_time = false ;
					end
					
					subj_t , subj_write_v = get_probe_1v1_light_tone_subj(subj_m, subj_id) ;

					if subj_write_v[8] >= acc_criterion && subj_write_v[9] >= acc_criterion
						push!(subj_t_v, subj_t) ;
						push!(write_v, subj_write_v) ;
					end					
				elseif session == :probe_mult_p && session_to_analyse == :probe
					if first_time
						println(file_name)
						first_time = false ;
					end

					subj_t , subj_write_v = get_probe_mult_p_subj(subj_m, subj_id, 0) ;

					if subj_write_v[14] >= acc_criterion && subj_write_v[15] >= acc_criterion
						push!(subj_t_v, subj_t) ;
						push!(write_v, subj_write_v) ;
					end		
				elseif session == :probe_mult_p_1v1 && session_to_analyse == :probe
					if first_time
						println(file_name)
						first_time = false ;
					end

					subj_t , subj_write_v = get_probe_mult_p_1v1_subj(subj_m, subj_id) ;

					if subj_write_v[14] >= acc_criterion && subj_write_v[15] >= acc_criterion
						push!(subj_t_v, subj_t) ;
						push!(write_v, subj_write_v) ;
					end	
				elseif session == :probe_var_p_1v1 && session_to_analyse == :probe
					if first_time
						println(file_name)
						first_time = false ;
					end

					subj_t , subj_write_v = get_probe_var_p_1v1_subj(subj_m, subj_id, probe_tone_1v1) ;

					if subj_write_v[8] >= acc_criterion && subj_write_v[9] >= acc_criterion
						push!(subj_t_v, subj_t) ;
						push!(write_v, subj_write_v) ;
					end				
				elseif (session == :t1v1 || session == :t4v1) && session_to_analyse == :train
					if first_time
						println(file_name)
						first_time = false ;
					end

					subj_t , subj_write_v = get_train_subj(subj_m, subj_id, session, 0) ;
					
					push!(subj_t_v, subj_t) ;
					push!(write_v, subj_write_v) ;
				elseif session == :t1v1_light_tone && session_to_analyse == :train
					if first_time
						println(file_name)
						first_time = false ;
					end

					subj_t , subj_write_v = get_train_light_tone_subj(subj_m, subj_id, session) ;
					
					push!(subj_t_v, subj_t) ;
					push!(write_v, subj_write_v) ;
				elseif session == :pulses && session_to_analyse == :train
					if first_time
						println(file_name)
						first_time = false ;
					end

					subj_t , subj_write_v = get_train_pulses_subj(subj_m, subj_id, session, 0) ;
					
					push!(subj_t_v, subj_t) ;
					push!(write_v, subj_write_v) ;
				elseif session == :crf && session_to_analyse == :train
					if first_time
						println(file_name)
						first_time = false ;
					end

					subj_t , subj_write_v = get_crf_subj(subj_m, subj_id) ;
					
					push!(subj_t_v, subj_t) ;
					push!(write_v, subj_write_v) ;
				end
			end
		end
		
		if !isempty(write_v) && write_flag
			write_xlsx(write_v, session, file_name, path) ;
		end
	end

	return subj_t_v
end

function get_probe_mult_p_subj(subj_m::Array{Int64,2}, subj_id::String, col_offset::Int64)

	reward = zeros(Int64, size(subj_m,1)) ;
	response = zeros(Int64, size(subj_m,1)) ;
	tone = zeros(Int64, size(subj_m,1)) ;
	rt = zeros(Float64, size(subj_m,1)) ;

	id_number_idx = findlast(isequal('_'), subj_id) ;
	id_number = tryparse(Int64, subj_id[id_number_idx + 1 : end]) ;

	mask_corr_cue1 = map((x,y) -> x == 0 && y != 0, subj_m[:,2], subj_m[:,13 + col_offset]) ;
	mask_corr_cue2 = map((x,y) -> x == 0 && y != 0, subj_m[:,2], subj_m[:,15 + col_offset]) ;
	mask_incorr_cue1 = map((x,y) -> x == 1 && y != 0, subj_m[:,2], subj_m[:,13 + col_offset]) ;
	mask_incorr_cue2 = map((x,y) -> x == 3 && y != 0, subj_m[:,2], subj_m[:,15 + col_offset]) ;

	# Name coding example :
	# p11 : p1 (4.5 KHz) playing and route 1 (left) was responseed 
	# p12 : p1 (4.5 KHz) playing and route 2 (right) was responseed 
	# second number now represents what was responseed, NOT what was set as correct as in original get_probe_subj

	mask_corr_p11 = map((x,y,z) -> x != 0 && y != 0 && z == 0,
				subj_m[:,19 + col_offset], subj_m[:,25 + col_offset], subj_m[:,29 + col_offset]) ;
	mask_corr_p21 = map((x,y,z) -> x != 0 && y != 0 && z == 0,
				subj_m[:,17 + col_offset], subj_m[:,25 + col_offset], subj_m[:,29 + col_offset]) ;
	mask_corr_p31 = map((x,y,z) -> x != 0 && y != 0 && z == 0,
				subj_m[:,21 + col_offset], subj_m[:,25 + col_offset], subj_m[:,29 + col_offset]) ;
	mask_corr_p41 = map((x,y,z) -> x != 0 && y != 0 && z == 0,
				subj_m[:,23 + col_offset], subj_m[:,25 + col_offset], subj_m[:,29 + col_offset]) ;

	mask_corr_p12 = map((x,y,z) -> x != 0 && y != 0 && z == 0,
				subj_m[:,19 + col_offset], subj_m[:,27 + col_offset], subj_m[:,29 + col_offset]) ;
	mask_corr_p22 = map((x,y,z) -> x != 0 && y != 0 && z == 0,
				subj_m[:,17 + col_offset], subj_m[:,27 + col_offset], subj_m[:,29 + col_offset]) ;
	mask_corr_p32 = map((x,y,z) -> x != 0 && y != 0 && z == 0,
				subj_m[:,21 + col_offset], subj_m[:,27 + col_offset], subj_m[:,29 + col_offset]) ;
	mask_corr_p42 = map((x,y,z) -> x != 0 && y != 0 && z == 0,
				subj_m[:,23 + col_offset], subj_m[:,27 + col_offset], subj_m[:,29 + col_offset]) ;

	mask_incorr_p11 = map((x,y,z) -> x != 0 && y != 0 && z != 0,
				subj_m[:,19 + col_offset], subj_m[:,25 + col_offset], subj_m[:,29 + col_offset]) ;
	mask_incorr_p21 = map((x,y,z) -> x != 0 && y != 0 && z != 0,
				subj_m[:,17 + col_offset], subj_m[:,25 + col_offset], subj_m[:,29 + col_offset]) ;
	mask_incorr_p31 = map((x,y,z) -> x != 0 && y != 0 && z != 0,
				subj_m[:,21 + col_offset], subj_m[:,25 + col_offset], subj_m[:,29 + col_offset]) ;
	mask_incorr_p41 = map((x,y,z) -> x != 0 && y != 0 && z != 0,
				subj_m[:,23 + col_offset], subj_m[:,25 + col_offset], subj_m[:,29 + col_offset]) ;

	mask_incorr_p12 = map((x,y,z) -> x != 0 && y != 0 && z != 0,
				subj_m[:,19 + col_offset], subj_m[:,27 + col_offset], subj_m[:,29 + col_offset]) ;
	mask_incorr_p22 = map((x,y,z) -> x != 0 && y != 0 && z != 0,
				subj_m[:,17 + col_offset], subj_m[:,27 + col_offset], subj_m[:,29 + col_offset]) ;
	mask_incorr_p32 = map((x,y,z) -> x != 0 && y != 0 && z != 0,
				subj_m[:,21 + col_offset], subj_m[:,27 + col_offset], subj_m[:,29 + col_offset]) ;
	mask_incorr_p42 = map((x,y,z) -> x != 0 && y != 0 && z != 0,
				subj_m[:,23 + col_offset], subj_m[:,27 + col_offset], subj_m[:,29 + col_offset]) ;

	mask_om_cue1 = map((x,y) -> x == 2 && y != 0, subj_m[:,2], subj_m[:, 13 + col_offset]) ;
	mask_om_cue2 = map((x,y) -> x == 2 && y != 0, subj_m[:,2], subj_m[:, 15 + col_offset]) ;

	mask_om_p1 = map((x,y,z) -> x != 0 && y == 0 && z == 0,
				subj_m[:,19 + col_offset], subj_m[:,25 + col_offset], subj_m[:,27 + col_offset]) ;
	mask_om_p2 = map((x,y,z) -> x != 0 && y == 0 && z == 0,
				subj_m[:,17 + col_offset], subj_m[:,25 + col_offset], subj_m[:,27 + col_offset]) ;
	mask_om_p3 = map((x,y,z) -> x != 0 && y == 0 && z == 0,
				subj_m[:,21 + col_offset], subj_m[:,25 + col_offset], subj_m[:,27 + col_offset]) ;
	mask_om_p4 = map((x,y,z) -> x != 0 && y == 0 && z == 0,
				subj_m[:,23 + col_offset], subj_m[:,25 + col_offset], subj_m[:,27 + col_offset]) ;

	mask_prem = map((x,y) -> x != 0 || y != 0, subj_m[:, 11 + col_offset], subj_m[:, 12 + col_offset]) ;

	write_v = Array{Any,1}(undef, length(probe_mult_p_header_v)) ;
	write_v[1] = id_number ;

	tone[map((x) -> x != 0 , subj_m[:,17+col_offset])] .= 4 ; # 4.75 KHz, coded tones as Int for simpler logical operations
	tone[map((x) -> x != 0 , subj_m[:,19+col_offset])] .= 3 ; # 4.50 KHz
	tone[map((x) -> x != 0 , subj_m[:,21+col_offset])] .= 6 ; # 5.25 KHz
	tone[map((x) -> x != 0 , subj_m[:,23+col_offset])] .= 7 ; # 5.50 KHz 

	rt[map((x,y) -> x == 4 && y != 0, tone, subj_m[:, 17+col_offset])] = (subj_m[map((x,y) -> x == 4 && y != 0, tone, subj_m[:, 17+col_offset]), 18+col_offset] - 
									subj_m[map((x,y) -> x == 4 && y != 0, tone, subj_m[:, 17+col_offset]), 17+col_offset]) / 100.0 ;
	rt[map((x,y) -> x == 3 && y != 0, tone, subj_m[:, 19+col_offset])] = (subj_m[map((x,y) -> x == 3 && y != 0, tone, subj_m[:, 19+col_offset]), 20+col_offset] - 
									subj_m[map((x,y) -> x == 3 && y != 0, tone, subj_m[:, 19+col_offset]), 19+col_offset]) / 100.0 ;
	rt[map((x,y) -> x == 6 && y != 0, tone, subj_m[:, 21+col_offset])] = (subj_m[map((x,y) -> x == 6 && y != 0, tone, subj_m[:, 21+col_offset]), 22+col_offset] - 
									subj_m[map((x,y) -> x == 6 && y != 0, tone, subj_m[:, 21+col_offset]), 21+col_offset]) / 100.0 ;
	rt[map((x,y) -> x == 7 && y != 0, tone, subj_m[:, 23+col_offset])] = (subj_m[map((x,y) -> x == 7 && y != 0, tone, subj_m[:, 23+col_offset]), 24+col_offset] - 
									subj_m[map((x,y) -> x == 7 && y != 0, tone, subj_m[:, 23+col_offset]), 23+col_offset]) / 100.0 ;

	if mod(id_number, 2) == 0 
		response[mask_corr_cue1 .| mask_corr_p11 .| mask_corr_p21 .| mask_corr_p31 .| mask_corr_p41 .| 
			mask_incorr_cue2 .| mask_incorr_p11 .| mask_incorr_p21 .| mask_incorr_p31 .| mask_corr_p41] .= 8 ;
		response[mask_corr_cue2 .| mask_corr_p12 .| mask_corr_p22 .| mask_corr_p32 .| mask_corr_p42 .| 
			mask_incorr_cue1 .| mask_incorr_p12 .| mask_incorr_p22 .| mask_incorr_p32 .| mask_incorr_p42] .= 2 ;
		reward[mask_corr_cue1 .| mask_corr_p11 .| mask_corr_p21 .| mask_corr_p31 .| mask_corr_p41] .= 1 ;
		reward[mask_corr_cue2 .| mask_corr_p12 .| mask_corr_p22 .| mask_corr_p32 .| mask_corr_p42] .= 4 ;
		tone[mask_corr_cue1 .| mask_incorr_cue1 .| mask_om_cue1] .= 8 ;
		tone[mask_corr_cue2 .| mask_incorr_cue2 .| mask_om_cue2] .= 2 ;
		rt[map(x -> x == 2, tone)] = (subj_m[map(x -> x == 2, tone), 16] - 
									subj_m[map(x -> x == 2, tone), 15]) / 100.0 ;
		rt[map(x -> x == 8, tone)] = (subj_m[map(x -> x == 8, tone), 14] - 
									subj_m[map(x -> x == 8, tone), 13]) / 100.0 ;

		response[map((x,y) -> x == true && y != 0, mask_prem, subj_m[:, 11 + col_offset])] .= 8 ;
		response[map((x,y) -> x == true && y != 0, mask_prem, subj_m[:, 12 + col_offset])] .= 2 ;

		write_v[2:end] = [mean(rt[mask_corr_cue2]), 
							mean(rt[mask_corr_cue1]), 
							mean(rt[mask_incorr_cue2]), 
							mean(rt[mask_incorr_cue1]),
							mean(rt[mask_corr_p12 .| mask_incorr_p12]), 
							mean(rt[mask_corr_p22 .| mask_incorr_p22]),
							mean(rt[mask_corr_p32 .| mask_incorr_p32]),
							mean(rt[mask_corr_p42 .| mask_incorr_p42]),
							mean(rt[mask_corr_p11 .| mask_incorr_p11]), 
							mean(rt[mask_corr_p21 .| mask_incorr_p21]),
							mean(rt[mask_corr_p31 .| mask_incorr_p31]),
							mean(rt[mask_corr_p41 .| mask_incorr_p41]),
							100.0*count(x->x==true, mask_corr_cue2)/count(x -> x == true, mask_corr_cue2 .| mask_incorr_cue2), 
							100.0*count(x->x==true, mask_corr_cue1)/count(x -> x == true, mask_corr_cue1 .| mask_incorr_cue1), 
							100.0*count(x->x==true, mask_incorr_cue2)/count(x -> x == true, mask_corr_cue2 .| mask_incorr_cue2), 
							100.0*count(x->x==true, mask_incorr_cue1)/count(x -> x == true, mask_corr_cue1 .| mask_incorr_cue1),
							100.0*count(x -> x == true, mask_corr_p12 .| mask_incorr_p12)/count(x -> x == true, mask_corr_p11 .| mask_incorr_p11 .| mask_corr_p12 .| mask_incorr_p12), 
							100.0*count(x -> x == true, mask_corr_p22 .| mask_incorr_p22)/count(x -> x == true, mask_corr_p21 .| mask_incorr_p21 .| mask_corr_p22 .| mask_incorr_p22), 
							100.0*count(x -> x == true, mask_corr_p32 .| mask_incorr_p32)/count(x -> x == true, mask_corr_p31 .| mask_incorr_p31 .| mask_corr_p32 .| mask_incorr_p32), 
							100.0*count(x -> x == true, mask_corr_p42 .| mask_incorr_p42)/count(x -> x == true, mask_corr_p41 .| mask_incorr_p41 .| mask_corr_p42 .| mask_incorr_p42), 
							100.0*count(x -> x == true, mask_corr_p11 .| mask_incorr_p11)/count(x -> x == true, mask_corr_p12 .| mask_incorr_p12 .| mask_corr_p11 .| mask_incorr_p11), 
							100.0*count(x -> x == true, mask_corr_p21 .| mask_incorr_p21)/count(x -> x == true, mask_corr_p22 .| mask_incorr_p22 .| mask_corr_p21 .| mask_incorr_p21), 
							100.0*count(x -> x == true, mask_corr_p31 .| mask_incorr_p31)/count(x -> x == true, mask_corr_p32 .| mask_incorr_p32 .| mask_corr_p31 .| mask_incorr_p31), 
							100.0*count(x -> x == true, mask_corr_p41 .| mask_incorr_p41)/count(x -> x == true, mask_corr_p42 .| mask_incorr_p42 .| mask_corr_p41 .| mask_incorr_p41), 
							100.0*count(x->x==true, mask_om_cue2)/count(x->x==2, tone), 
							100.0*count(x->x==true, mask_om_cue1)/count(x->x==8, tone), 
							100.0*count(x -> x == true, mask_om_p1)/count(x->x==3,tone), 
							100.0*count(x -> x == true, mask_om_p2)/count(x->x==4,tone), 
							100.0*count(x -> x == true, mask_om_p3)/count(x->x==6,tone), 
							100.0*count(x -> x == true, mask_om_p4)/count(x->x==7,tone), 
							100.0*count(x->x==true, mask_prem)/(subj_m[end,1]+1) ] ;

	else
		response[mask_corr_cue1 .| mask_corr_p11 .| mask_corr_p21 .| mask_corr_p31 .| mask_corr_p41 .| 
			mask_incorr_cue2 .| mask_incorr_p11 .| mask_incorr_p21 .| mask_incorr_p31 .| mask_corr_p41] .= 2 ;
		response[mask_corr_cue2 .| mask_corr_p12 .| mask_corr_p22 .| mask_corr_p32 .| mask_corr_p42 .| 
			mask_incorr_cue1 .| mask_incorr_p12 .| mask_incorr_p22 .| mask_incorr_p32 .| mask_incorr_p42] .= 8 ;
		reward[mask_corr_cue1 .| mask_corr_p11 .| mask_corr_p21 .| mask_corr_p31 .| mask_corr_p41] .= 4 ;
		reward[mask_corr_cue2 .| mask_corr_p12 .| mask_corr_p22 .| mask_corr_p32 .| mask_corr_p42] .= 1 ;
		tone[mask_corr_cue1 .| mask_incorr_cue1 .| mask_om_cue1] .= 2 ;
		tone[mask_corr_cue2 .| mask_incorr_cue2 .| mask_om_cue2] .= 8 ;
		rt[map(x -> x == 2, tone)] = (subj_m[map(x -> x == 2, tone), 14] - 
									subj_m[map(x -> x == 2, tone), 13]) / 100.0 ;
		rt[map(x -> x == 8, tone)] = (subj_m[map(x -> x == 8, tone), 16] - 
									subj_m[map(x -> x == 8, tone), 15]) / 100.0 ;

		response[map((x,y) -> x == true && y != 0, mask_prem, subj_m[:, 11 + col_offset])] .= 2 ;
		response[map((x,y) -> x == true && y != 0, mask_prem, subj_m[:, 12 + col_offset])] .= 8 ;

		write_v[2:end] = [mean(rt[mask_corr_cue1]), 
							mean(rt[mask_corr_cue2]), 
							mean(rt[mask_incorr_cue1]), 
							mean(rt[mask_incorr_cue2]),
							mean(rt[mask_corr_p11 .| mask_incorr_p11]), 
							mean(rt[mask_corr_p21 .| mask_incorr_p21]),
							mean(rt[mask_corr_p31 .| mask_incorr_p31]),
							mean(rt[mask_corr_p41 .| mask_incorr_p41]),
							mean(rt[mask_corr_p12 .| mask_incorr_p12]), 
							mean(rt[mask_corr_p22 .| mask_incorr_p22]),
							mean(rt[mask_corr_p32 .| mask_incorr_p32]),
							mean(rt[mask_corr_p42 .| mask_incorr_p42]),
							100.0*count(x->x==true, mask_corr_cue1)/count(x -> x == true, mask_corr_cue1 .| mask_incorr_cue1), 
							100.0*count(x->x==true, mask_corr_cue2)/count(x -> x == true, mask_corr_cue2 .| mask_incorr_cue2), 
							100.0*count(x->x==true, mask_incorr_cue1)/count(x -> x == true, mask_corr_cue1 .| mask_incorr_cue1), 
							100.0*count(x->x==true, mask_incorr_cue2)/count(x -> x == true, mask_corr_cue2 .| mask_incorr_cue2),
							100.0*count(x -> x == true, mask_corr_p11 .| mask_incorr_p11)/count(x -> x == true, mask_corr_p11 .| mask_incorr_p11 .| mask_corr_p12 .| mask_incorr_p12), 
							100.0*count(x -> x == true, mask_corr_p21 .| mask_incorr_p21)/count(x -> x == true, mask_corr_p21 .| mask_incorr_p21 .| mask_corr_p22 .| mask_incorr_p22), 
							100.0*count(x -> x == true, mask_corr_p31 .| mask_incorr_p31)/count(x -> x == true, mask_corr_p31 .| mask_incorr_p31 .| mask_corr_p32 .| mask_incorr_p32), 
							100.0*count(x -> x == true, mask_corr_p41 .| mask_incorr_p41)/count(x -> x == true, mask_corr_p41 .| mask_incorr_p41 .| mask_corr_p42 .| mask_incorr_p42), 
							100.0*count(x -> x == true, mask_corr_p12 .| mask_incorr_p12)/count(x -> x == true, mask_corr_p12 .| mask_incorr_p12 .| mask_corr_p11 .| mask_incorr_p11), 
							100.0*count(x -> x == true, mask_corr_p22 .| mask_incorr_p22)/count(x -> x == true, mask_corr_p22 .| mask_incorr_p22 .| mask_corr_p21 .| mask_incorr_p21), 
							100.0*count(x -> x == true, mask_corr_p32 .| mask_incorr_p32)/count(x -> x == true, mask_corr_p32 .| mask_incorr_p32 .| mask_corr_p31 .| mask_incorr_p31), 
							100.0*count(x -> x == true, mask_corr_p42 .| mask_incorr_p42)/count(x -> x == true, mask_corr_p42 .| mask_incorr_p42 .| mask_corr_p41 .| mask_incorr_p41), 
							100.0*count(x->x==true, mask_om_cue1)/count(x->x==2, tone), 
							100.0*count(x->x==true, mask_om_cue2)/count(x->x==8, tone), 
							100.0*count(x -> x == true, mask_om_p1)/count(x->x==3,tone), 
							100.0*count(x -> x == true, mask_om_p2)/count(x->x==4,tone), 
							100.0*count(x -> x == true, mask_om_p3)/count(x->x==6,tone), 
							100.0*count(x -> x == true, mask_om_p4)/count(x->x==7,tone), 
							100.0*count(x->x==true, mask_prem)/(subj_m[end,1]+1) ] ;
	end

	rt[mask_om_cue1 .| mask_om_cue2 .| mask_om_p1 .| mask_om_p2] .= rt_max ;
	mask_rt_crit = map(x -> x > rt_criterion, rt) ;

	return subj_t(subj_id, 
				response[mask_rt_crit], 
				reward[mask_rt_crit], 
				tone[mask_rt_crit], 
				rt[mask_rt_crit], 
				0.0) , write_v
end

function get_probe_subj(subj_m::Array{Int64,2}, subj_id::String, col_offset::Int64)

	reward = zeros(Int64, size(subj_m,1)) ;
	response = zeros(Int64, size(subj_m,1)) ;
	tone = zeros(Int64, size(subj_m,1)) ;
	rt = zeros(Float64, size(subj_m,1)) ;
	rr = zeros(Float64, size(subj_m,1)) ;
	
	id_number_idx = findlast(isequal('_'), subj_id) ;
	id_number = tryparse(Int64, subj_id[id_number_idx + 1 : end]) ;

	# p1 : probe cue playing and route 1 lever (left) was set as correct
	# p2 : probe cue playing and route 2 lever (right) was set as correct

	mask_corr_cue1 = map((x,y) -> x == 0 && y != 0, subj_m[:,2], subj_m[:,13 + col_offset]) ;
	mask_corr_cue2 = map((x,y) -> x == 0 && y != 0, subj_m[:,2], subj_m[:,15 + col_offset]) ;
	mask_incorr_cue1 = map((x,y) -> x == 1 && y != 0, subj_m[:,2], subj_m[:,13 + col_offset]) ;
	mask_incorr_cue2 = map((x,y) -> x == 3 && y != 0, subj_m[:,2], subj_m[:,15 + col_offset]) ;
	mask_corr_p1 = map((x,y) -> x == 0 && y != 0, subj_m[:,2], subj_m[:,17 + col_offset]) ;
	mask_corr_p2 = map((x,y) -> x == 0 && y != 0, subj_m[:,2], subj_m[:,19 + col_offset]) ;
	mask_incorr_p1 = map((x,y) -> x == 1 && y != 0, subj_m[:,2], subj_m[:,17 + col_offset]) ;
	mask_incorr_p2 = map((x,y) -> x == 3 && y != 0, subj_m[:,2], subj_m[:,19 + col_offset]) ;
	mask_om_cue1 = map((x,y) -> x == 2 && y != 0, subj_m[:,2], subj_m[:, 13 + col_offset]) ;
	mask_om_cue2 = map((x,y) -> x == 2 && y != 0, subj_m[:,2], subj_m[:, 15 + col_offset]) ;
	mask_om_p1 = map((x,y) -> x == 2 && y != 0, subj_m[:,2], subj_m[:, 17 + col_offset]) ;
	mask_om_p2 = map((x,y) -> x == 2 && y != 0, subj_m[:,2], subj_m[:, 19 + col_offset]) ;
	mask_prem = map(x -> x == 4,  subj_m[:,2]) ;

	write_v = Array{Any,1}(undef, length(probe_header_v)) ;
	write_v[1] = id_number ;

	tone[map((x,y) -> x != 0 || y != 0, subj_m[:,17+col_offset], subj_m[:,19+col_offset])] .= 5 ;
	rt[map((x,y) -> x == 5 && y != 0, tone, subj_m[:, 17+col_offset])] = (subj_m[map((x,y) -> x == 5 && y != 0, tone, subj_m[:, 17+col_offset]), 18+col_offset] - 
									subj_m[map((x,y) -> x == 5 && y != 0, tone, subj_m[:, 17+col_offset]), 17+col_offset]) / 100.0 ;
	rt[map((x,y) -> x == 5 && y != 0, tone, subj_m[:, 19+col_offset])] = (subj_m[map((x,y) -> x == 5 && y != 0, tone, subj_m[:, 19+col_offset]), 20+col_offset] - 
									subj_m[map((x,y) -> x == 5 && y != 0, tone, subj_m[:, 19+col_offset]), 19+col_offset]) / 100.0 ;

	if mod(id_number, 2) == 0 
		response[mask_corr_cue1 .| mask_corr_p1 .| mask_incorr_cue2 .| mask_incorr_p2] .= 8 ;
		response[mask_corr_cue2 .| mask_corr_p2 .| mask_incorr_cue1 .| mask_incorr_p1] .= 2 ;
		reward[mask_corr_cue1 .| mask_corr_p1] .= 1 ;
		reward[mask_corr_cue2 .| mask_corr_p2] .= 4 ;
		tone[mask_corr_cue1 .| mask_incorr_cue1 .| mask_om_cue1] .= 8 ;
		tone[mask_corr_cue2 .| mask_incorr_cue2 .| mask_om_cue2] .= 2 ;
		rt[map(x -> x == 2, tone)] = (subj_m[map(x -> x == 2, tone), 16 + col_offset] - 
									subj_m[map(x -> x == 2, tone), 15 + col_offset]) / 100.0 ;
		rt[map(x -> x == 8, tone)] = (subj_m[map(x -> x == 8, tone), 14 + col_offset] - 
									subj_m[map(x -> x == 8, tone), 13 + col_offset]) / 100.0 ;

		response[map((x,y) -> x == true && y != 0, mask_prem, subj_m[:, 11 + col_offset])] .= 8 ;
		response[map((x,y) -> x == true && y != 0, mask_prem, subj_m[:, 12 + col_offset])] .= 2 ;

		mask_rt_crit = map((x,y) -> x > rt_criterion || y == true, rt, mask_prem) ;
		rt = rt[mask_rt_crit] ;
		tone = tone[mask_rt_crit] ;
		response = response[mask_rt_crit] ;
		reward = reward[mask_rt_crit] ;
		mask_corr_cue1 = mask_corr_cue1[mask_rt_crit] ;
		mask_corr_cue2 = mask_corr_cue2[mask_rt_crit] ;
		mask_incorr_cue1 = mask_incorr_cue1[mask_rt_crit] ;
		mask_incorr_cue2 = mask_incorr_cue2[mask_rt_crit] ;
		mask_corr_p1 = mask_corr_p1[mask_rt_crit] ;
		mask_corr_p2 = mask_corr_p2[mask_rt_crit] ;
		mask_incorr_p1 = mask_incorr_p1[mask_rt_crit] ;
		mask_incorr_p2 = mask_incorr_p2[mask_rt_crit] ;
		mask_om_cue1 = mask_om_cue1[mask_rt_crit] ;
		mask_om_cue2 = mask_om_cue2[mask_rt_crit] ;
		mask_om_p1 = mask_om_p1[mask_rt_crit] ;
		mask_om_p2 = mask_om_p2[mask_rt_crit] ;
		mask_prem = mask_prem[mask_rt_crit] ;

		write_v[2:end] = [mean(rt[mask_corr_cue2]), 
							mean(rt[mask_corr_cue1]), 
							mean(rt[mask_incorr_cue2]), 
							mean(rt[mask_incorr_cue1]),
							mean(rt[mask_corr_p2 .| mask_incorr_p1]), 
							mean(rt[mask_corr_p1 .| mask_incorr_p2]), 
							100.0*count(x->x==true, mask_corr_cue2)/count(x -> x == true, mask_corr_cue2 .| mask_incorr_cue2), 
							100.0*count(x->x==true, mask_corr_cue1)/count(x -> x == true, mask_corr_cue1 .| mask_incorr_cue1), 
							100.0*count(x->x==true, mask_incorr_cue2)/count(x -> x == true, mask_corr_cue2 .| mask_incorr_cue2), 
							100.0*count(x->x==true, mask_incorr_cue1)/count(x -> x == true, mask_corr_cue1 .| mask_incorr_cue1),
							100.0*count(x -> x == true, mask_corr_p2 .| mask_incorr_p1)/count(x -> x == true, mask_corr_p1 .| mask_incorr_p1 .| mask_corr_p2 .| mask_incorr_p2), 
							100.0*count(x -> x == true, mask_corr_p1 .| mask_incorr_p2)/count(x -> x == true, mask_corr_p1 .| mask_incorr_p1 .| mask_corr_p2 .| mask_incorr_p2), 
							(count(x -> x == true, mask_corr_p2 .| mask_incorr_p1) - 
							count(x -> x == true, mask_corr_p1 .| mask_incorr_p2))/count(x -> x == true, mask_corr_p1 .| mask_incorr_p1 .| mask_corr_p2 .| mask_incorr_p2),
							100.0*count(x->x==true, mask_om_cue2)/count(x->x==2, tone), 
							100.0*count(x->x==true, mask_om_cue1)/count(x->x==8, tone), 
							100.0*count(x -> x == true, mask_om_p1 .| mask_om_p2)/count(x->x==5,tone), 
							100.0*count(x->x==true, mask_prem)/(subj_m[end,1]+1)] ;

	else
		response[mask_corr_cue1 .| mask_corr_p1 .| mask_incorr_cue2 .| mask_incorr_p2] .= 2 ;
		response[mask_corr_cue2 .| mask_corr_p2 .| mask_incorr_cue1 .| mask_incorr_p1] .= 8 ;
		reward[mask_corr_cue1 .| mask_corr_p1] .= 4 ;
		reward[mask_corr_cue2 .| mask_corr_p2] .= 1 ;
		tone[mask_corr_cue1 .| mask_incorr_cue1 .| mask_om_cue1] .= 2 ;
		tone[mask_corr_cue2 .| mask_incorr_cue2 .| mask_om_cue2] .= 8 ;
		rt[map(x -> x == 2, tone)] = (subj_m[map(x -> x == 2, tone), 14 + col_offset] - 
									subj_m[map(x -> x == 2, tone), 13 + col_offset]) / 100.0 ;
		rt[map(x -> x == 8, tone)] = (subj_m[map(x -> x == 8, tone), 16 + col_offset] - 
									subj_m[map(x -> x == 8, tone), 15 + col_offset]) / 100.0 ;
		
		response[map((x,y) -> x == true && y != 0, mask_prem, subj_m[:, 11 + col_offset])] .= 2 ;
		response[map((x,y) -> x == true && y != 0, mask_prem, subj_m[:, 12 + col_offset])] .= 8 ;

		mask_rt_crit = map((x,y) -> x > rt_criterion || y == true, rt, mask_prem) ;
		rt = rt[mask_rt_crit] ;
		tone = tone[mask_rt_crit] ;
		response = response[mask_rt_crit] ;
		reward = reward[mask_rt_crit] ;
		mask_corr_cue1 = mask_corr_cue1[mask_rt_crit] ;
		mask_corr_cue2 = mask_corr_cue2[mask_rt_crit] ;
		mask_incorr_cue1 = mask_incorr_cue1[mask_rt_crit] ;
		mask_incorr_cue2 = mask_incorr_cue2[mask_rt_crit] ;
		mask_corr_p1 = mask_corr_p1[mask_rt_crit] ;
		mask_corr_p2 = mask_corr_p2[mask_rt_crit] ;
		mask_incorr_p1 = mask_incorr_p1[mask_rt_crit] ;
		mask_incorr_p2 = mask_incorr_p2[mask_rt_crit] ;
		mask_om_cue1 = mask_om_cue1[mask_rt_crit] ;
		mask_om_cue2 = mask_om_cue2[mask_rt_crit] ;
		mask_om_p1 = mask_om_p1[mask_rt_crit] ;
		mask_om_p2 = mask_om_p2[mask_rt_crit] ;
		mask_prem = mask_prem[mask_rt_crit] ;

		write_v[2:end] = [mean(rt[mask_corr_cue1]), 
							mean(rt[mask_corr_cue2]), 
							mean(rt[mask_incorr_cue1]), 
							mean(rt[mask_incorr_cue2]),
							mean(rt[mask_corr_p1 .| mask_incorr_p2]), 
							mean(rt[mask_corr_p2 .| mask_incorr_p1]),  
							100.0*count(x->x==true, mask_corr_cue1)/count(x -> x == true, mask_corr_cue1 .| mask_incorr_cue1), 
							100.0*count(x->x==true, mask_corr_cue2)/count(x -> x == true, mask_corr_cue2 .| mask_incorr_cue2), 
							100.0*count(x->x==true, mask_incorr_cue1)/count(x -> x == true, mask_corr_cue1 .| mask_incorr_cue1), 
							100.0*count(x->x==true, mask_incorr_cue2)/count(x -> x == true, mask_corr_cue2 .| mask_incorr_cue2),
							100.0*count(x -> x == true, mask_corr_p1 .| mask_incorr_p2)/count(x -> x == true, mask_corr_p1 .| mask_incorr_p1 .| mask_corr_p2 .| mask_incorr_p2), 
							100.0*count(x -> x == true, mask_corr_p2 .| mask_incorr_p1)/count(x -> x == true, mask_corr_p1 .| mask_incorr_p1 .| mask_corr_p2 .| mask_incorr_p2), 
							(count(x -> x == true, mask_corr_p1 .| mask_incorr_p2) - 
							count(x -> x == true, mask_corr_p2 .| mask_incorr_p1))/count(x -> x == true, mask_corr_p1 .| mask_incorr_p1 .| mask_corr_p2 .| mask_incorr_p2),
							100.0*count(x->x==true, mask_om_cue1)/count(x->x==2, tone), 
							100.0*count(x->x==true, mask_om_cue2)/count(x->x==8, tone), 
							100.0*count(x -> x == true, mask_om_p1 .| mask_om_p2)/count(x->x==5,tone), 
							100.0*count(x->x==true, mask_prem)/(subj_m[end,1]+1)] ;
	end

	rt[mask_om_cue1 .| mask_om_cue2 .| mask_om_p1 .| mask_om_p2] .= rt_max ;
	
	return subj_t(subj_id, 
				response, 
				reward, 
				tone, 
				rt, 
				write_v[14]) , write_v
end

function get_probe_reversed_subj(subj_m::Array{Int64,2}, subj_id::String, col_offset::Int64)

	reward = zeros(Int64, size(subj_m,1)) ;
	response = zeros(Int64, size(subj_m,1)) ;
	tone = zeros(Int64, size(subj_m,1)) ;
	rt = zeros(Float64, size(subj_m,1)) ;
	rr = zeros(Float64, size(subj_m,1)) ;
	
	id_number_idx = findlast(isequal('_'), subj_id) ;
	id_number = tryparse(Int64, subj_id[id_number_idx + 1 : end]) ;

	# p1 : probe cue playing and route 1 lever (left) was set as correct
	# p2 : probe cue playing and route 2 lever (right) was set as correct

	mask_corr_cue1 = map((x,y) -> x == 0 && y != 0, subj_m[:,2], subj_m[:,13 + col_offset]) ;
	mask_corr_cue2 = map((x,y) -> x == 0 && y != 0, subj_m[:,2], subj_m[:,15 + col_offset]) ;
	mask_incorr_cue1 = map((x,y) -> x == 1 && y != 0, subj_m[:,2], subj_m[:,13 + col_offset]) ;
	mask_incorr_cue2 = map((x,y) -> x == 3 && y != 0, subj_m[:,2], subj_m[:,15 + col_offset]) ;
	mask_corr_p1 = map((x,y) -> x == 0 && y != 0, subj_m[:,2], subj_m[:,17 + col_offset]) ;
	mask_corr_p2 = map((x,y) -> x == 0 && y != 0, subj_m[:,2], subj_m[:,19 + col_offset]) ;
	mask_incorr_p1 = map((x,y) -> x == 1 && y != 0, subj_m[:,2], subj_m[:,17 + col_offset]) ;
	mask_incorr_p2 = map((x,y) -> x == 3 && y != 0, subj_m[:,2], subj_m[:,19 + col_offset]) ;
	mask_om_cue1 = map((x,y) -> x == 2 && y != 0, subj_m[:,2], subj_m[:, 13 + col_offset]) ;
	mask_om_cue2 = map((x,y) -> x == 2 && y != 0, subj_m[:,2], subj_m[:, 15 + col_offset]) ;
	mask_om_p1 = map((x,y) -> x == 2 && y != 0, subj_m[:,2], subj_m[:, 17 + col_offset]) ;
	mask_om_p2 = map((x,y) -> x == 2 && y != 0, subj_m[:,2], subj_m[:, 19 + col_offset]) ;
	mask_prem = map(x -> x == 4,  subj_m[:,2]) ;

	write_v = Array{Any,1}(undef, length(probe_header_v)) ;
	write_v[1] = id_number ;

	tone[map((x,y) -> x != 0 || y != 0, subj_m[:,17+col_offset], subj_m[:,19+col_offset])] .= 5 ;
	rt[map((x,y) -> x == 5 && y != 0, tone, subj_m[:, 17+col_offset])] = (subj_m[map((x,y) -> x == 5 && y != 0, tone, subj_m[:, 17+col_offset]), 18+col_offset] - 
									subj_m[map((x,y) -> x == 5 && y != 0, tone, subj_m[:, 17+col_offset]), 17+col_offset]) / 100.0 ;
	rt[map((x,y) -> x == 5 && y != 0, tone, subj_m[:, 19+col_offset])] = (subj_m[map((x,y) -> x == 5 && y != 0, tone, subj_m[:, 19+col_offset]), 20+col_offset] - 
									subj_m[map((x,y) -> x == 5 && y != 0, tone, subj_m[:, 19+col_offset]), 19+col_offset]) / 100.0 ;

	if mod(id_number, 2) != 0 
		response[mask_corr_cue1 .| mask_corr_p1 .| mask_incorr_cue2 .| mask_incorr_p2] .= 8 ;
		response[mask_corr_cue2 .| mask_corr_p2 .| mask_incorr_cue1 .| mask_incorr_p1] .= 2 ;
		reward[mask_corr_cue1 .| mask_corr_p1] .= 1 ;
		reward[mask_corr_cue2 .| mask_corr_p2] .= 4 ;
		tone[mask_corr_cue1 .| mask_incorr_cue1 .| mask_om_cue1] .= 8 ;
		tone[mask_corr_cue2 .| mask_incorr_cue2 .| mask_om_cue2] .= 2 ;
		rt[map(x -> x == 2, tone)] = (subj_m[map(x -> x == 2, tone), 16] - 
									subj_m[map(x -> x == 2, tone), 15]) / 100.0 ;
		rt[map(x -> x == 8, tone)] = (subj_m[map(x -> x == 8, tone), 14] - 
									subj_m[map(x -> x == 8, tone), 13]) / 100.0 ;

		response[map((x,y) -> x == true && y != 0, mask_prem, subj_m[:, 11 + col_offset])] .= 8 ;
		response[map((x,y) -> x == true && y != 0, mask_prem, subj_m[:, 12 + col_offset])] .= 2 ;

		mask_rt_crit = map((x,y) -> x > rt_criterion || y == true, rt, mask_prem) ;
		rt = rt[mask_rt_crit] ;
		tone = tone[mask_rt_crit] ;
		response = response[mask_rt_crit] ;
		reward = reward[mask_rt_crit] ;
		mask_corr_cue1 = mask_corr_cue1[mask_rt_crit] ;
		mask_corr_cue2 = mask_corr_cue2[mask_rt_crit] ;
		mask_incorr_cue1 = mask_incorr_cue1[mask_rt_crit] ;
		mask_incorr_cue2 = mask_incorr_cue2[mask_rt_crit] ;
		mask_corr_p1 = mask_corr_p1[mask_rt_crit] ;
		mask_corr_p2 = mask_corr_p2[mask_rt_crit] ;
		mask_incorr_p1 = mask_incorr_p1[mask_rt_crit] ;
		mask_incorr_p2 = mask_incorr_p2[mask_rt_crit] ;
		mask_om_cue1 = mask_om_cue1[mask_rt_crit] ;
		mask_om_cue2 = mask_om_cue2[mask_rt_crit] ;
		mask_om_p1 = mask_om_p1[mask_rt_crit] ;
		mask_om_p2 = mask_om_p2[mask_rt_crit] ;
		mask_prem = mask_prem[mask_rt_crit] ;

		write_v[2:end] = [mean(rt[mask_corr_cue2]), 
							mean(rt[mask_corr_cue1]), 
							mean(rt[mask_incorr_cue2]), 
							mean(rt[mask_incorr_cue1]),
							mean(rt[mask_corr_p2 .| mask_incorr_p1]), 
							mean(rt[mask_corr_p1 .| mask_incorr_p2]), 
							100.0*count(x->x==true, mask_corr_cue2)/count(x -> x == true, mask_corr_cue2 .| mask_incorr_cue2), 
							100.0*count(x->x==true, mask_corr_cue1)/count(x -> x == true, mask_corr_cue1 .| mask_incorr_cue1), 
							100.0*count(x->x==true, mask_incorr_cue2)/count(x -> x == true, mask_corr_cue2 .| mask_incorr_cue2), 
							100.0*count(x->x==true, mask_incorr_cue1)/count(x -> x == true, mask_corr_cue1 .| mask_incorr_cue1),
							100.0*count(x -> x == true, mask_corr_p2 .| mask_incorr_p1)/count(x -> x == true, mask_corr_p1 .| mask_incorr_p1 .| mask_corr_p2 .| mask_incorr_p2), 
							100.0*count(x -> x == true, mask_corr_p1 .| mask_incorr_p2)/count(x -> x == true, mask_corr_p1 .| mask_incorr_p1 .| mask_corr_p2 .| mask_incorr_p2), 
							(count(x -> x == true, mask_corr_p2 .| mask_incorr_p1) - 
							count(x -> x == true, mask_corr_p1 .| mask_incorr_p2))/count(x -> x == true, mask_corr_p1 .| mask_incorr_p1 .| mask_corr_p2 .| mask_incorr_p2),
							100.0*count(x->x==true, mask_om_cue2)/count(x->x==2, tone), 
							100.0*count(x->x==true, mask_om_cue1)/count(x->x==8, tone), 
							100.0*count(x -> x == true, mask_om_p1 .| mask_om_p2)/count(x->x==5,tone), 
							100.0*count(x->x==true, mask_prem)/(subj_m[end,1]+1), 
							mean([rt[mask_corr_p1 .| mask_incorr_p1] ; 
								rt[mask_corr_p2 .| mask_incorr_p2]])] ;

	else
		response[mask_corr_cue1 .| mask_corr_p1 .| mask_incorr_cue2 .| mask_incorr_p2] .= 2 ;
		response[mask_corr_cue2 .| mask_corr_p2 .| mask_incorr_cue1 .| mask_incorr_p1] .= 8 ;
		reward[mask_corr_cue1 .| mask_corr_p1] .= 4 ;
		reward[mask_corr_cue2 .| mask_corr_p2] .= 1 ;
		tone[mask_corr_cue1 .| mask_incorr_cue1 .| mask_om_cue1] .= 2 ;
		tone[mask_corr_cue2 .| mask_incorr_cue2 .| mask_om_cue2] .= 8 ;
		rt[map(x -> x == 2, tone)] = (subj_m[map(x -> x == 2, tone), 14] - 
									subj_m[map(x -> x == 2, tone), 13]) / 100.0 ;
		rt[map(x -> x == 8, tone)] = (subj_m[map(x -> x == 8, tone), 16] - 
									subj_m[map(x -> x == 8, tone), 15]) / 100.0 ;
		
		response[map((x,y) -> x == true && y != 0, mask_prem, subj_m[:, 11 + col_offset])] .= 2 ;
		response[map((x,y) -> x == true && y != 0, mask_prem, subj_m[:, 12 + col_offset])] .= 8 ;

		mask_rt_crit = map((x,y) -> x > rt_criterion || y == true, rt, mask_prem) ;
		rt = rt[mask_rt_crit] ;
		tone = tone[mask_rt_crit] ;
		response = response[mask_rt_crit] ;
		reward = reward[mask_rt_crit] ;
		mask_corr_cue1 = mask_corr_cue1[mask_rt_crit] ;
		mask_corr_cue2 = mask_corr_cue2[mask_rt_crit] ;
		mask_incorr_cue1 = mask_incorr_cue1[mask_rt_crit] ;
		mask_incorr_cue2 = mask_incorr_cue2[mask_rt_crit] ;
		mask_corr_p1 = mask_corr_p1[mask_rt_crit] ;
		mask_corr_p2 = mask_corr_p2[mask_rt_crit] ;
		mask_incorr_p1 = mask_incorr_p1[mask_rt_crit] ;
		mask_incorr_p2 = mask_incorr_p2[mask_rt_crit] ;
		mask_om_cue1 = mask_om_cue1[mask_rt_crit] ;
		mask_om_cue2 = mask_om_cue2[mask_rt_crit] ;
		mask_om_p1 = mask_om_p1[mask_rt_crit] ;
		mask_om_p2 = mask_om_p2[mask_rt_crit] ;
		mask_prem = mask_prem[mask_rt_crit] ;

		write_v[2:end] = [mean(rt[mask_corr_cue1]), 
							mean(rt[mask_corr_cue2]), 
							mean(rt[mask_incorr_cue1]), 
							mean(rt[mask_incorr_cue2]),
							mean(rt[mask_corr_p1 .| mask_incorr_p2]), 
							mean(rt[mask_corr_p2 .| mask_incorr_p1]),  
							100.0*count(x->x==true, mask_corr_cue1)/count(x -> x == true, mask_corr_cue1 .| mask_incorr_cue1), 
							100.0*count(x->x==true, mask_corr_cue2)/count(x -> x == true, mask_corr_cue2 .| mask_incorr_cue2), 
							100.0*count(x->x==true, mask_incorr_cue1)/count(x -> x == true, mask_corr_cue1 .| mask_incorr_cue1), 
							100.0*count(x->x==true, mask_incorr_cue2)/count(x -> x == true, mask_corr_cue2 .| mask_incorr_cue2),
							100.0*count(x -> x == true, mask_corr_p1 .| mask_incorr_p2)/count(x -> x == true, mask_corr_p1 .| mask_incorr_p1 .| mask_corr_p2 .| mask_incorr_p2), 
							100.0*count(x -> x == true, mask_corr_p2 .| mask_incorr_p1)/count(x -> x == true, mask_corr_p1 .| mask_incorr_p1 .| mask_corr_p2 .| mask_incorr_p2), 
							(count(x -> x == true, mask_corr_p1 .| mask_incorr_p2) - 
							count(x -> x == true, mask_corr_p2 .| mask_incorr_p1))/count(x -> x == true, mask_corr_p1 .| mask_incorr_p1 .| mask_corr_p2 .| mask_incorr_p2),
							100.0*count(x->x==true, mask_om_cue1)/count(x->x==2, tone), 
							100.0*count(x->x==true, mask_om_cue2)/count(x->x==8, tone), 
							100.0*count(x -> x == true, mask_om_p1 .| mask_om_p2)/count(x->x==5,tone), 
							100.0*count(x->x==true, mask_prem)/(subj_m[end,1]+1), 
							mean([rt[mask_corr_p1 .| mask_incorr_p1] ; 
								rt[mask_corr_p2 .| mask_incorr_p2]])] ;
	end

	rt[mask_om_cue1 .| mask_om_cue2 .| mask_om_p1 .| mask_om_p2] .= rt_max ;

	return subj_t(subj_id, 
				response, 
				reward, 
				tone, 
				rt, 
				write_v[14]) , write_v
end

function get_train_reversed_subj(subj_m::Array{Int64,2}, subj_id::String, session::Symbol, col_offset::Int64)

	reward = zeros(Int64, size(subj_m,1)) ;
	response = zeros(Int64, size(subj_m,1)) ;
	tone = zeros(Int64, size(subj_m,1)) ;
	rt = zeros(Float64, size(subj_m,1)) ;
	rr = zeros(Float64, size(subj_m,1)) ;

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

	if mod(id_number, 2) != 0 
		response[mask_corr_cue1 .| mask_incorr_cue2] .= 8 ;
		response[mask_corr_cue2 .| mask_incorr_cue1] .= 2 ;

		if session == :t1v1
			reward[mask_corr_cue1] .= 1 ;
			reward[mask_corr_cue2] .= 1 ;
		else
			reward[mask_corr_cue1] .= 1 ;
			reward[mask_corr_cue2] .= 4 ;
		end

		tone[mask_corr_cue1 .| mask_incorr_cue1 .| mask_om_cue1] .= 8 ;
		tone[mask_corr_cue2 .| mask_incorr_cue2 .| mask_om_cue2] .= 2 ;
		rt[map(x -> x == 2, tone)] = (subj_m[map(x -> x == 2, tone), 18] - 
									subj_m[map(x -> x == 2, tone), 17]) / 100.0 ;
		rt[map(x -> x == 8, tone)] = (subj_m[map(x -> x == 8, tone), 16] - 
									subj_m[map(x -> x == 8, tone), 15]) / 100.0 ;

		mask_rt_crit = map((x,y) -> x > rt_criterion || y == true, rt, mask_prem) ;
		rt = rt[mask_rt_crit] ;
		tone = tone[mask_rt_crit] ;
		response = response[mask_rt_crit] ;
		reward = reward[mask_rt_crit] ;
		mask_corr_cue1 = mask_corr_cue1[mask_rt_crit] ;
		mask_corr_cue2 = mask_corr_cue2[mask_rt_crit] ;
		mask_incorr_cue1 = mask_incorr_cue1[mask_rt_crit] ;
		mask_incorr_cue2 = mask_incorr_cue2[mask_rt_crit] ;
		mask_om_cue1 = mask_om_cue1[mask_rt_crit] ;
		mask_om_cue2 = mask_om_cue2[mask_rt_crit] ;
		mask_prem = mask_prem[mask_rt_crit] ;

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
		response[mask_corr_cue1 .| mask_incorr_cue2] .= 2 ;
		response[mask_corr_cue2 .| mask_incorr_cue1] .= 8 ;
		
		if session == :t1v1
			reward[mask_corr_cue1] .= 1 ;
			reward[mask_corr_cue2] .= 1 ;
		else
			reward[mask_corr_cue1] .= 4 ;
			reward[mask_corr_cue2] .= 1 ;
		end

		tone[mask_corr_cue1 .| mask_incorr_cue1 .| mask_om_cue1] .= 2 ;
		tone[mask_corr_cue2 .| mask_incorr_cue2 .| mask_om_cue2] .= 8 ;
		rt[map(x -> x == 2, tone)] = (subj_m[map(x -> x == 2, tone), 16] - 
									subj_m[map(x -> x == 2, tone), 15]) / 100.0 ;
		rt[map(x -> x == 8, tone)] = (subj_m[map(x -> x == 8, tone), 18] - 
									subj_m[map(x -> x == 8, tone), 17]) / 100.0 ;
		
		mask_rt_crit = map((x,y) -> x > rt_criterion || y == true, rt, mask_prem) ;
		rt = rt[mask_rt_crit] ;
		tone = tone[mask_rt_crit] ;
		response = response[mask_rt_crit] ;
		reward = reward[mask_rt_crit] ;
		mask_corr_cue1 = mask_corr_cue1[mask_rt_crit] ;
		mask_corr_cue2 = mask_corr_cue2[mask_rt_crit] ;
		mask_incorr_cue1 = mask_incorr_cue1[mask_rt_crit] ;
		mask_incorr_cue2 = mask_incorr_cue2[mask_rt_crit] ;
		mask_om_cue1 = mask_om_cue1[mask_rt_crit] ;
		mask_om_cue2 = mask_om_cue2[mask_rt_crit] ;
		mask_prem = mask_prem[mask_rt_crit] ;

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

	rt[mask_om_cue1 .| mask_om_cue2] .= rt_max ;

	return subj_t(subj_id, 
				response, 
				reward, 
				tone, 
				rt, 
				0.0) , write_v
end

function get_train_subj(subj_m::Array{Int64,2}, subj_id::String, session::Symbol, col_offset::Int64)

	reward = zeros(Int64, size(subj_m,1)) ;
	response = zeros(Int64, size(subj_m,1)) ;
	tone = zeros(Int64, size(subj_m,1)) ;
	rt = zeros(Float64, size(subj_m,1)) ;
	rr = zeros(Float64, size(subj_m,1)) ;

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
		response[mask_corr_cue1 .| mask_incorr_cue2] .= 8 ;
		response[mask_corr_cue2 .| mask_incorr_cue1] .= 2 ;

		if session == :t1v1
			reward[mask_corr_cue1] .= 1 ;
			reward[mask_corr_cue2] .= 1 ;
		else
			reward[mask_corr_cue1] .= 1 ;
			reward[mask_corr_cue2] .= 4 ;
		end

		tone[mask_corr_cue1 .| mask_incorr_cue1 .| mask_om_cue1] .= 8 ;
		tone[mask_corr_cue2 .| mask_incorr_cue2 .| mask_om_cue2] .= 2 ;
		rt[map(x -> x == 2, tone)] = (subj_m[map(x -> x == 2, tone), 18] - 
									subj_m[map(x -> x == 2, tone), 17]) / 100.0 ;
		rt[map(x -> x == 8, tone)] = (subj_m[map(x -> x == 8, tone), 16] - 
									subj_m[map(x -> x == 8, tone), 15]) / 100.0 ;

		mask_rt_crit = map((x,y) -> x > rt_criterion || y == true, rt, mask_prem) ;
		rt = rt[mask_rt_crit] ;
		tone = tone[mask_rt_crit] ;
		response = response[mask_rt_crit] ;
		reward = reward[mask_rt_crit] ;
		mask_corr_cue1 = mask_corr_cue1[mask_rt_crit] ;
		mask_corr_cue2 = mask_corr_cue2[mask_rt_crit] ;
		mask_incorr_cue1 = mask_incorr_cue1[mask_rt_crit] ;
		mask_incorr_cue2 = mask_incorr_cue2[mask_rt_crit] ;
		mask_om_cue1 = mask_om_cue1[mask_rt_crit] ;
		mask_om_cue2 = mask_om_cue2[mask_rt_crit] ;
		mask_prem = mask_prem[mask_rt_crit] ;

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
		response[mask_corr_cue1 .| mask_incorr_cue2] .= 2 ;
		response[mask_corr_cue2 .| mask_incorr_cue1] .= 8 ;
		
		if session == :t1v1
			reward[mask_corr_cue1] .= 1 ;
			reward[mask_corr_cue2] .= 1 ;
		else
			reward[mask_corr_cue1] .= 4 ;
			reward[mask_corr_cue2] .= 1 ;
		end

		tone[mask_corr_cue1 .| mask_incorr_cue1 .| mask_om_cue1] .= 2 ;
		tone[mask_corr_cue2 .| mask_incorr_cue2 .| mask_om_cue2] .= 8 ;
		rt[map(x -> x == 2, tone)] = (subj_m[map(x -> x == 2, tone), 16] - 
									subj_m[map(x -> x == 2, tone), 15]) / 100.0 ;
		rt[map(x -> x == 8, tone)] = (subj_m[map(x -> x == 8, tone), 18] - 
									subj_m[map(x -> x == 8, tone), 17]) / 100.0 ;
		
		mask_rt_crit = map((x,y) -> x > rt_criterion || y == true, rt, mask_prem) ;
		rt = rt[mask_rt_crit] ;
		tone = tone[mask_rt_crit] ;
		response = response[mask_rt_crit] ;
		reward = reward[mask_rt_crit] ;
		mask_corr_cue1 = mask_corr_cue1[mask_rt_crit] ;
		mask_corr_cue2 = mask_corr_cue2[mask_rt_crit] ;
		mask_incorr_cue1 = mask_incorr_cue1[mask_rt_crit] ;
		mask_incorr_cue2 = mask_incorr_cue2[mask_rt_crit] ;
		mask_om_cue1 = mask_om_cue1[mask_rt_crit] ;
		mask_om_cue2 = mask_om_cue2[mask_rt_crit] ;
		mask_prem = mask_prem[mask_rt_crit] ;

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

	rt[mask_om_cue1 .| mask_om_cue2] .= rt_max ;

	return subj_t(subj_id, 
				response, 
				reward, 
				tone, 
				rt, 
				0.0) , write_v
end

function get_train_pulses_subj(subj_m::Array{Int64,2}, subj_id::String, session::Symbol, col_offset::Int64)

	reward = zeros(Int64, size(subj_m,1)) ;
	response = Array{Symbol,1}(undef, size(subj_m,1)) ;
	tone = Array{Symbol,1}(undef,size(subj_m,1)) ;
	rt = zeros(Float64, size(subj_m,1)) ;

	fill!(response, :none) ;
	fill!(tone, :none) ;

	id_number_idx = findlast(isequal('_'), subj_id) ;
	id_number = tryparse(Int64, subj_id[id_number_idx + 1 : end]) ;

	mask_corr_cue1 = map((x,y) -> x == 0 && y != 0, subj_m[:,2], subj_m[:,15 + col_offset]) ;
	mask_corr_cue2 = map((x,y) -> x == 0 && y != 0, subj_m[:,2], subj_m[:,19 + col_offset]) ;
	mask_incorr_cue1 = map((x,y) -> x == 1 && y != 0, subj_m[:,2], subj_m[:,15 + col_offset]) ;
	mask_incorr_cue2 = map((x,y) -> x == 3 && y != 0, subj_m[:,2], subj_m[:,19 + col_offset]) ;
	mask_om_cue1 = map((x,y) -> x == 2 && y != 0, subj_m[:,2], subj_m[:, 15 + col_offset]) ;
	mask_om_cue2 = map((x,y) -> x == 2 && y != 0, subj_m[:,2], subj_m[:, 19 + col_offset]) ;
	mask_prem = map(x -> x == 4,  subj_m[:,2]) ;

	write_v = Array{Any,1}(undef, length(train_header_v)) ;
	write_v[1] = id_number ;
	write_v[2] = string(session) ;

	#if mod(id_number, 2) == 0 
	if id_number in (1,4,5,8,12,13,16)
		response[mask_corr_cue1 .| mask_incorr_cue2] .= :fast ;
		response[mask_corr_cue2 .| mask_incorr_cue1] .= :slow ; # old high reward
		reward[mask_corr_cue1] .= 1 ;
		#reward[mask_corr_cue2] .= 1 ; # old high reward
		reward[mask_corr_cue2] .= 2 ;
		tone[mask_corr_cue1 .| mask_incorr_cue1 .| mask_om_cue1] .= :fast ;
		tone[mask_corr_cue2 .| mask_incorr_cue2 .| mask_om_cue2] .= :slow ;
		rt[map(x -> x == :slow, tone)] = (subj_m[map(x -> x == :slow, tone), 20] - 
									subj_m[map(x -> x == :slow, tone), 19]) / 100.0 ;
		rt[map(x -> x == :fast, tone)] = (subj_m[map(x -> x == :fast, tone), 16] - 
									subj_m[map(x -> x == :fast, tone), 15]) / 100.0 ;

		mask_rt_crit = map((x,y) -> x > rt_criterion || y == true, rt, mask_prem) ;
		rt = rt[mask_rt_crit] ;
		tone = tone[mask_rt_crit] ;
		response = response[mask_rt_crit] ;
		reward = reward[mask_rt_crit] ;
		mask_corr_cue1 = mask_corr_cue1[mask_rt_crit] ;
		mask_corr_cue2 = mask_corr_cue2[mask_rt_crit] ;
		mask_incorr_cue1 = mask_incorr_cue1[mask_rt_crit] ;
		mask_incorr_cue2 = mask_incorr_cue2[mask_rt_crit] ;
		mask_om_cue1 = mask_om_cue1[mask_rt_crit] ;
		mask_om_cue2 = mask_om_cue2[mask_rt_crit] ;
		mask_prem = mask_prem[mask_rt_crit] ;

		write_v[3:end] = [mean(rt[mask_corr_cue2]), 
							mean(rt[mask_corr_cue1]), 
							mean(rt[mask_incorr_cue2]), 
							mean(rt[mask_incorr_cue1]), 
							100.0*count(x->x==true, mask_corr_cue2)/count(x -> x == true, mask_corr_cue2 .| mask_incorr_cue2), 
							100.0*count(x->x==true, mask_corr_cue1)/count(x -> x == true, mask_corr_cue1 .| mask_incorr_cue1), 
							100.0*count(x->x==true, mask_incorr_cue2)/count(x -> x == true, mask_corr_cue2 .| mask_incorr_cue2), 
							100.0*count(x->x==true, mask_incorr_cue1)/count(x -> x == true, mask_corr_cue1 .| mask_incorr_cue1),
							100.0*count(x->x==true, mask_om_cue2)/count(x->x==:slow, tone), 
							100.0*count(x->x==true, mask_om_cue1)/count(x->x==:fast, tone), 
							100.0*count(x->x==true, mask_prem)/(subj_m[end,1]+1)] ;

	else
		response[mask_corr_cue1 .| mask_incorr_cue2] .= :slow ; # old high reward
		response[mask_corr_cue2 .| mask_incorr_cue1] .= :fast ;
		#reward[mask_corr_cue1] .= 1 ; # old high reward
		reward[mask_corr_cue1] .= 2 ;
		reward[mask_corr_cue2] .= 1 ;
		tone[mask_corr_cue1 .| mask_incorr_cue1 .| mask_om_cue1] .= :slow ;
		tone[mask_corr_cue2 .| mask_incorr_cue2 .| mask_om_cue2] .= :fast ;
		rt[map(x -> x == :slow, tone)] = (subj_m[map(x -> x == :slow, tone), 16] - 
									subj_m[map(x -> x == :slow, tone), 15]) / 100.0 ;
		rt[map(x -> x == :fast, tone)] = (subj_m[map(x -> x == :fast, tone), 20] - 
									subj_m[map(x -> x == :fast, tone), 19]) / 100.0 ;
		
		mask_rt_crit = map((x,y) -> x > rt_criterion || y == true, rt, mask_prem) ;
		rt = rt[mask_rt_crit] ;
		tone = tone[mask_rt_crit] ;
		response = response[mask_rt_crit] ;
		reward = reward[mask_rt_crit] ;
		mask_corr_cue1 = mask_corr_cue1[mask_rt_crit] ;
		mask_corr_cue2 = mask_corr_cue2[mask_rt_crit] ;
		mask_incorr_cue1 = mask_incorr_cue1[mask_rt_crit] ;
		mask_incorr_cue2 = mask_incorr_cue2[mask_rt_crit] ;
		mask_om_cue1 = mask_om_cue1[mask_rt_crit] ;
		mask_om_cue2 = mask_om_cue2[mask_rt_crit] ;
		mask_prem = mask_prem[mask_rt_crit] ;

		write_v[3:end] = [mean(rt[mask_corr_cue1]), 
							mean(rt[mask_corr_cue2]), 
							mean(rt[mask_incorr_cue1]), 
							mean(rt[mask_incorr_cue2]),  
							100.0*count(x->x==true, mask_corr_cue1)/count(x -> x == true, mask_corr_cue1 .| mask_incorr_cue1), 
							100.0*count(x->x==true, mask_corr_cue2)/count(x -> x == true, mask_corr_cue2 .| mask_incorr_cue2), 
							100.0*count(x->x==true, mask_incorr_cue1)/count(x -> x == true, mask_corr_cue1 .| mask_incorr_cue1), 
							100.0*count(x->x==true, mask_incorr_cue2)/count(x -> x == true, mask_corr_cue2 .| mask_incorr_cue2),
							100.0*count(x->x==true, mask_om_cue1)/count(x->x==:slow, tone), 
							100.0*count(x->x==true, mask_om_cue2)/count(x->x==:fast, tone), 
							100.0*count(x->x==true, mask_prem)/(subj_m[end,1]+1)] ;
	end

	rt[mask_om_cue1 .| mask_om_cue2] .= rt_max ;

	return subj_t(subj_id, 
				response, 
				reward, 
				tone, 
				rt, 
				0.0) , write_v
end

function get_probe_mult_p_1v1_subj(subj_m::Array{Int64,2}, subj_id::String)

	reward = zeros(Int64, size(subj_m,1)) ;
	response = zeros(Int64, size(subj_m,1)) ;
	tone = zeros(Int64, size(subj_m,1)) ;
	rt = zeros(Float64, size(subj_m,1)) ;

	id_number_idx = findlast(isequal('_'), subj_id) ;
	id_number = tryparse(Int64, subj_id[id_number_idx + 1 : end]) ;

	mask_corr_2 = map((x,y) -> x == 0 && y == 1, subj_m[:,2], subj_m[:,3]) ;
	mask_corr_8 = map((x,y) -> x == 0 && y == 0, subj_m[:,2], subj_m[:,3]) ;
	mask_incorr_2 = map((x,y) -> (x == 1 || x == 3) && y == 1, subj_m[:,2], subj_m[:,3]) ;
	mask_incorr_8 = map((x,y) -> (x == 1 || x == 3) && y == 0, subj_m[:,2], subj_m[:,3]) ;

	# Name coding example :
	# p11 : p1 (4 KHz) playing while route 1 (left) was the correct response
	# p12 : p1 (4 KHz) playing while route 2 (right) was the correct response

	mask_corr_p11 = map((x,y,z) -> x == 0 && y == 3 && z != 0, subj_m[:,2], subj_m[:,3], subj_m[:, 10]) ;
	mask_corr_p21 = map((x,y,z) -> x == 0 && (y == 5 || y == 4) && z != 0, 
									subj_m[:,2], subj_m[:,3], subj_m[:, 10]) ;
	mask_corr_p31 = map((x,y,z) -> x == 0 && y == 2 && z != 0, subj_m[:,2], subj_m[:,3], subj_m[:, 10]) ;

	mask_corr_p12 = map((x,y,z) -> x == 0 && y == 3 && z != 0, subj_m[:,2], subj_m[:,3], subj_m[:, 12]) ;
	mask_corr_p22 = map((x,y,z) -> x == 0 && (y == 5 || y == 4) && z != 0, 
									subj_m[:,2], subj_m[:,3], subj_m[:, 12]) ;
	mask_corr_p32 = map((x,y,z) -> x == 0 && y == 2 && z != 0, subj_m[:,2], subj_m[:,3], subj_m[:, 12]) ;

	mask_incorr_p11 = map((x,y,z) -> x == 1 && y == 3 && z != 0, subj_m[:,2], subj_m[:,3], subj_m[:, 10]) ;
	mask_incorr_p21 = map((x,y,z) -> x == 1 && (y == 5 || y == 4) && z != 0, 
									subj_m[:,2], subj_m[:,3], subj_m[:, 10]) ;
	mask_incorr_p31 = map((x,y,z) -> x == 1 && y == 2 && z != 0, subj_m[:,2], subj_m[:,3], subj_m[:, 10]) ;

	mask_incorr_p12 = map((x,y,z) -> x == 3 && y == 3 && z != 0, subj_m[:,2], subj_m[:,3], subj_m[:, 12]) ;
	mask_incorr_p22 = map((x,y,z) -> x == 3 && (y == 5 || y == 4) && z != 0, 
									subj_m[:,2], subj_m[:,3], subj_m[:, 12]) ;
	mask_incorr_p32 = map((x,y,z) -> x == 3 && y == 2 && z != 0, subj_m[:,2], subj_m[:,3], subj_m[:, 12]) ;

	mask_om_2 = map((x,y) -> x == 2 && y == 1, subj_m[:,2], subj_m[:,3]) ;
	mask_om_8 = map((x,y) -> x == 2 && y == 0, subj_m[:,2], subj_m[:,3]) ;

	mask_om_p1 = map((x,y) -> x == 2 && y == 3, subj_m[:,2], subj_m[:,3]) ;
	mask_om_p2 = map((x,y) -> x == 2 && (y == 5 || y == 4), subj_m[:,2], subj_m[:,3]) ;
	mask_om_p3 = map((x,y) -> x == 2 && y == 2, subj_m[:,2], subj_m[:,3]) ;

	mask_prem = map(x -> x == 4, subj_m[:,2]) ;

	tone[mask_corr_2 .| mask_incorr_2 .| mask_om_2] .= 2 ;
	tone[mask_corr_8 .| mask_incorr_8 .| mask_om_8] .= 8 ;

	tone[map((x,y) -> x == 3 && y == false, subj_m[:,3], mask_prem)] .= 4 ; # KHz
	tone[map((x,y) -> (x == 5 || x == 4) && y == false, subj_m[:,3], mask_prem)] .= 5 ; # KHz
	tone[map((x,y) -> x == 2 && y == false, subj_m[:,3], mask_prem)] .= 6 ; # KHz 

	response[mask_corr_2 .| mask_incorr_8] .= 2 ;
	response[mask_corr_8 .| mask_incorr_2] .= 8 ;

	write_v = Array{Any,1}(undef, length(probe_mult_p_1v1_header_v)) ;
	write_v[1] = id_number ;

	if mod(id_number, 2) == 0 

		response[mask_corr_p11 .| mask_corr_p21 .| mask_corr_p31 .|
				mask_incorr_p12 .| mask_incorr_p22 .| mask_incorr_p32] .= 2 ;

		response[mask_corr_p12 .| mask_corr_p22 .| mask_corr_p32 .|
				mask_incorr_p11 .| mask_incorr_p21 .| mask_incorr_p31] .= 8 ;

		response[map((x,y) -> x == true && y != 0, mask_prem, subj_m[:, 8])] .= 2 ;
		response[map((x,y) -> x == true && y != 0, mask_prem, subj_m[:, 9])] .= 8 ;

		rt[map(x -> x == 2, tone)] = (subj_m[map(x -> x == 2, tone), 11] -
									subj_m[map(x -> x == 2, tone), 10]) / 100.0 ;

		rt[map(x -> x == 8, tone)] = (subj_m[map(x -> x == 8, tone), 13] -
									subj_m[map(x -> x == 8, tone), 12]) / 100.0 ;

		rt[map(x -> x == 4, tone)] = (subj_m[map(x -> x == 4, tone), 11] -
									subj_m[map(x -> x == 4, tone), 10]) / 100.0 ;

		rt[map((x) -> x == 5, subj_m[:,3])] = (subj_m[map((x) -> x == 5, subj_m[:,3]), 11] -
									subj_m[map((x) -> x == 5, subj_m[:,3]), 10]) / 100.0 ;
		rt[map((x) -> x == 4, subj_m[:,3])] = (subj_m[map((x) -> x == 4, subj_m[:,3]), 13] -
									subj_m[map((x) -> x == 4, subj_m[:,3]), 12]) / 100.0 ;

		rt[map(x -> x == 6, tone)] = (subj_m[map(x -> x == 6, tone), 13] -
									subj_m[map(x -> x == 6, tone), 12]) / 100.0 ;

		write_v[2:end] = [mean(rt[mask_corr_2]), 
							mean(rt[mask_corr_8]), 
							mean(rt[mask_incorr_2]), 
							mean(rt[mask_incorr_8]),
							mean(rt[mask_corr_p11 .| mask_incorr_p12]), 
							mean(rt[mask_corr_p21 .| mask_incorr_p22]),
							mean(rt[mask_corr_p31 .| mask_incorr_p32]),
							mean(rt[mask_corr_p12 .| mask_incorr_p11]), 
							mean(rt[mask_corr_p22 .| mask_incorr_p21]),
							mean(rt[mask_corr_p32 .| mask_incorr_p31]),
							100.0*count(x->x==true, mask_corr_2)/count(x -> x == true, mask_corr_2 .| mask_incorr_2), 
							100.0*count(x->x==true, mask_corr_8)/count(x -> x == true, mask_corr_8 .| mask_incorr_8), 
							100.0*count(x->x==true, mask_incorr_2)/count(x -> x == true, mask_corr_2 .| mask_incorr_2), 
							100.0*count(x->x==true, mask_incorr_8)/count(x -> x == true, mask_corr_8 .| mask_incorr_8),
							100.0*count(x -> x == true, mask_corr_p11 .| mask_incorr_p12)/count(x -> x == true, mask_corr_p11 .| mask_incorr_p11 .| mask_corr_p12 .| mask_incorr_p12), 
							100.0*count(x -> x == true, mask_corr_p21 .| mask_incorr_p22)/count(x -> x == true, mask_corr_p21 .| mask_incorr_p21 .| mask_corr_p22 .| mask_incorr_p22), 
							100.0*count(x -> x == true, mask_corr_p31 .| mask_incorr_p32)/count(x -> x == true, mask_corr_p31 .| mask_incorr_p31 .| mask_corr_p32 .| mask_incorr_p32), 
							100.0*count(x -> x == true, mask_corr_p12 .| mask_incorr_p11)/count(x -> x == true, mask_corr_p12 .| mask_incorr_p12 .| mask_corr_p11 .| mask_incorr_p11), 
							100.0*count(x -> x == true, mask_corr_p22 .| mask_incorr_p21)/count(x -> x == true, mask_corr_p22 .| mask_incorr_p22 .| mask_corr_p21 .| mask_incorr_p21), 
							100.0*count(x -> x == true, mask_corr_p32 .| mask_incorr_p31)/count(x -> x == true, mask_corr_p32 .| mask_incorr_p32 .| mask_corr_p31 .| mask_incorr_p31), 
							100.0*count(x->x==true, mask_om_2)/count(x->x==2, tone), 
							100.0*count(x->x==true, mask_om_8)/count(x->x==8, tone), 
							100.0*count(x -> x == true, mask_om_p1)/count(x->x==3,tone), 
							100.0*count(x -> x == true, mask_om_p2)/count(x->x==4,tone), 
							100.0*count(x -> x == true, mask_om_p3)/count(x->x==6,tone), 
							100.0*count(x->x==true, mask_prem)/(subj_m[end,1]+1) ] ;

	else
		
		response[mask_corr_p11 .| mask_corr_p21 .| mask_corr_p31 .|
				mask_incorr_p12 .| mask_incorr_p22 .| mask_incorr_p32] .= 8 ;

		response[mask_corr_p12 .| mask_corr_p22 .| mask_corr_p32 .|
				mask_incorr_p11 .| mask_incorr_p21 .| mask_incorr_p31] .= 2 ;

		response[map((x,y) -> x == true && y != 0, mask_prem, subj_m[:, 8])] .= 8 ;
		response[map((x,y) -> x == true && y != 0, mask_prem, subj_m[:, 9])] .= 2 ;

		rt[map(x -> x == 2, tone)] = (subj_m[map(x -> x == 2, tone), 13] -
									subj_m[map(x -> x == 2, tone), 12]) / 100.0 ;

		rt[map(x -> x == 8, tone)] = (subj_m[map(x -> x == 8, tone), 11] -
									subj_m[map(x -> x == 8, tone), 10]) / 100.0 ;

		rt[map(x -> x == 4, tone)] = (subj_m[map(x -> x == 4, tone), 13] -
									subj_m[map(x -> x == 4, tone), 12]) / 100.0 ;

		rt[map((x) -> x == 5, subj_m[:,3])] = (subj_m[map((x) -> x == 5, subj_m[:,3]), 13] -
									subj_m[map((x) -> x == 5, subj_m[:,3]), 12]) / 100.0 ;
		rt[map((x) -> x == 4, subj_m[:,3])] = (subj_m[map((x) -> x == 4, subj_m[:,3]), 11] -
									subj_m[map((x) -> x == 4, subj_m[:,3]), 10]) / 100.0 ;

		rt[map(x -> x == 6, tone)] = (subj_m[map(x -> x == 6, tone), 11] -
									subj_m[map(x -> x == 6, tone), 10]) / 100.0 ;

		write_v[2:end] = [mean(rt[mask_corr_2]), 
							mean(rt[mask_corr_8]), 
							mean(rt[mask_incorr_2]), 
							mean(rt[mask_incorr_8]),
							mean(rt[mask_corr_p12 .| mask_incorr_p11]), 
							mean(rt[mask_corr_p22 .| mask_incorr_p21]),
							mean(rt[mask_corr_p32 .| mask_incorr_p31]),
							mean(rt[mask_corr_p11 .| mask_incorr_p12]), 
							mean(rt[mask_corr_p21 .| mask_incorr_p22]),
							mean(rt[mask_corr_p31 .| mask_incorr_p32]),
							100.0*count(x->x==true, mask_corr_2)/count(x -> x == true, mask_corr_2 .| mask_incorr_2), 
							100.0*count(x->x==true, mask_corr_8)/count(x -> x == true, mask_corr_8 .| mask_incorr_8), 
							100.0*count(x->x==true, mask_incorr_2)/count(x -> x == true, mask_corr_2 .| mask_incorr_2), 
							100.0*count(x->x==true, mask_incorr_8)/count(x -> x == true, mask_corr_8 .| mask_incorr_8),
							100.0*count(x -> x == true, mask_corr_p12 .| mask_incorr_p11)/count(x -> x == true, mask_corr_p11 .| mask_incorr_p11 .| mask_corr_p12 .| mask_incorr_p12), 
							100.0*count(x -> x == true, mask_corr_p22 .| mask_incorr_p21)/count(x -> x == true, mask_corr_p21 .| mask_incorr_p21 .| mask_corr_p22 .| mask_incorr_p22), 
							100.0*count(x -> x == true, mask_corr_p32 .| mask_incorr_p31)/count(x -> x == true, mask_corr_p31 .| mask_incorr_p31 .| mask_corr_p32 .| mask_incorr_p32), 
							100.0*count(x -> x == true, mask_corr_p11 .| mask_incorr_p12)/count(x -> x == true, mask_corr_p12 .| mask_incorr_p12 .| mask_corr_p11 .| mask_incorr_p11), 
							100.0*count(x -> x == true, mask_corr_p21 .| mask_incorr_p22)/count(x -> x == true, mask_corr_p22 .| mask_incorr_p22 .| mask_corr_p21 .| mask_incorr_p21), 
							100.0*count(x -> x == true, mask_corr_p31 .| mask_incorr_p32)/count(x -> x == true, mask_corr_p32 .| mask_incorr_p32 .| mask_corr_p31 .| mask_incorr_p31), 
							100.0*count(x->x==true, mask_om_2)/count(x->x==2, tone), 
							100.0*count(x->x==true, mask_om_8)/count(x->x==8, tone), 
							100.0*count(x -> x == true, mask_om_p1)/count(x->x==3,tone), 
							100.0*count(x -> x == true, mask_om_p2)/count(x->x==4,tone), 
							100.0*count(x -> x == true, mask_om_p3)/count(x->x==6,tone), 
							100.0*count(x->x==true, mask_prem)/(subj_m[end,1]+1) ] ;
	end

	rt[mask_om_2 .| mask_om_8 .| mask_om_p1 .| mask_om_p2 .| mask_om_p3] .= rt_max ;
	mask_rt_crit = map(x -> x > rt_criterion, rt) ;

	return subj_t(subj_id, 
				response[mask_rt_crit], 
				reward[mask_rt_crit], 
				tone[mask_rt_crit], 
				rt[mask_rt_crit], 
				0.0) , write_v
end

function get_probe_var_p_1v1_subj(subj_m::Array{Int64,2}, subj_id::String, p::Int64)

	reward = zeros(Int64, size(subj_m,1)) ;
	response = zeros(Int64, size(subj_m,1)) ;
	tone = zeros(Int64, size(subj_m,1)) ;
	rt = zeros(Float64, size(subj_m,1)) ;

	id_number_idx = findlast(isequal('_'), subj_id) ;
	id_number = tryparse(Int64, subj_id[id_number_idx + 1 : end]) ;

	mask_corr_2 = map((x,y) -> x == 0 && y == 1, subj_m[:,2], subj_m[:,3]) ;
	mask_corr_8 = map((x,y) -> x == 0 && y == 0, subj_m[:,2], subj_m[:,3]) ;
	mask_incorr_2 = map((x,y) -> (x == 1 || x == 3) && y == 1, subj_m[:,2], subj_m[:,3]) ;
	mask_incorr_8 = map((x,y) -> (x == 1 || x == 3) && y == 0, subj_m[:,2], subj_m[:,3]) ;

	# Name coding example :
	# p1 : p (5/5.5/6 KHz) playing while route 1 (left) was the correct response
	# p2 : p (5/5.5/6 KHz) playing while route 2 (right) was the correct response

	mask_corr_p1 = map((x,y,z) -> x == 0 && (y == 2 || y == 3) && z != 0, 
									subj_m[:,2], subj_m[:,3], subj_m[:, 13]) ;

	mask_corr_p2 = map((x,y,z) -> x == 0 && (y == 2 || y == 3) && z != 0, 
									subj_m[:,2], subj_m[:,3], subj_m[:, 15]) ;

	mask_incorr_p1 = map((x,y,z) -> x == 1 && (y == 2 || y == 3) && z != 0, 
									subj_m[:,2], subj_m[:,3], subj_m[:, 13]) ;

	mask_incorr_p2 = map((x,y,z) -> x == 3 && (y == 2 || y == 3) && z != 0, 
									subj_m[:,2], subj_m[:,3], subj_m[:, 15]) ;

	mask_om_2 = map((x,y) -> x == 2 && y == 1, subj_m[:,2], subj_m[:,3]) ;
	mask_om_8 = map((x,y) -> x == 2 && y == 0, subj_m[:,2], subj_m[:,3]) ;

	mask_om_p = map((x,y) -> x == 2 && (y == 2 || y == 3), subj_m[:,2], subj_m[:,3]) ;

	mask_prem = map(x -> x == 4, subj_m[:,2]) ;

	tone[mask_corr_2 .| mask_incorr_2 .| mask_om_2] .= 2 ;
	tone[mask_corr_8 .| mask_incorr_8 .| mask_om_8] .= 8 ;

	tone[map((x,y) -> (x == 2 || x == 3) && y == false, subj_m[:,3], mask_prem)] .= p ; # KHz

	response[mask_corr_2 .| mask_incorr_8] .= 2 ;
	response[mask_corr_8 .| mask_incorr_2] .= 8 ;

	write_v = Array{Any,1}(undef, length(probe_header_v)) ;
	write_v[1] = id_number ;

	if id_number in [1, 2, 7, 8, 9, 10, 15, 16, 17, 18]

		response[mask_corr_p1 .| mask_incorr_p2 ] .= 2 ;

		response[mask_corr_p2 .| mask_incorr_p1] .= 8 ;

		response[map((x,y) -> x == true && y != 0, mask_prem, subj_m[:, 11])] .= 2 ;
		response[map((x,y) -> x == true && y != 0, mask_prem, subj_m[:, 12])] .= 8 ;

		rt[map(x -> x == 2, tone)] = (subj_m[map(x -> x == 2, tone), 14] -
									subj_m[map(x -> x == 2, tone), 13]) / 100.0 ;

		rt[map(x -> x == 8, tone)] = (subj_m[map(x -> x == 8, tone), 16] -
									subj_m[map(x -> x == 8, tone), 15]) / 100.0 ;

		rt[map((x) -> x == 3, subj_m[:,3])] = (subj_m[map((x) -> x == 3, subj_m[:,3]), 14] -
									subj_m[map((x) -> x == 3, subj_m[:,3]), 13]) / 100.0 ;
		rt[map((x) -> x == 2, subj_m[:,3])] = (subj_m[map((x) -> x == 2, subj_m[:,3]), 16] -
									subj_m[map((x) -> x == 2, subj_m[:,3]), 15]) / 100.0 ;

		write_v[2:end] = [mean(rt[mask_corr_2]), 
							mean(rt[mask_corr_8]), 
							mean(rt[mask_incorr_2]), 
							mean(rt[mask_incorr_8]),
							mean(rt[mask_corr_p1 .| mask_incorr_p2]), 
							mean(rt[mask_corr_p2 .| mask_incorr_p1]), 
							100.0*count(x->x==true, mask_corr_2)/count(x -> x == true, mask_corr_2 .| mask_incorr_2), 
							100.0*count(x->x==true, mask_corr_8)/count(x -> x == true, mask_corr_8 .| mask_incorr_8), 
							100.0*count(x->x==true, mask_incorr_2)/count(x -> x == true, mask_corr_2 .| mask_incorr_2), 
							100.0*count(x->x==true, mask_incorr_8)/count(x -> x == true, mask_corr_8 .| mask_incorr_8),
							100.0*count(x -> x == true, mask_corr_p1 .| mask_incorr_p2)/count(x -> x == true, mask_corr_p1 .| mask_incorr_p1 .| mask_corr_p2 .| mask_incorr_p2), 
							100.0*count(x -> x == true, mask_corr_p2 .| mask_incorr_p1)/count(x -> x == true, mask_corr_p2 .| mask_incorr_p2 .| mask_corr_p1 .| mask_incorr_p1), 
							(count(x -> x == true, mask_corr_p1 .| mask_incorr_p2) - 
							count(x -> x == true, mask_corr_p2 .| mask_incorr_p1))/count(x -> x == true, mask_corr_p1 .| mask_incorr_p1 .| mask_corr_p2 .| mask_incorr_p2),
							100.0*count(x->x==true, mask_om_2)/count(x->x==2, tone), 
							100.0*count(x->x==true, mask_om_8)/count(x->x==8, tone), 
							100.0*count(x -> x == true, mask_om_p)/count(x->x==p,tone), 
							100.0*count(x->x==true, mask_prem)/(subj_m[end,1]+1),
							mean([rt[mask_corr_p1 .| mask_incorr_p1] ; 
								rt[mask_corr_p2 .| mask_incorr_p2]]) ] ;

	else
		
		response[mask_corr_p1 .| mask_incorr_p2 ] .= 8 ;

		response[mask_corr_p2 .| mask_incorr_p1] .= 2 ;

		response[map((x,y) -> x == true && y != 0, mask_prem, subj_m[:, 11])] .= 8 ;
		response[map((x,y) -> x == true && y != 0, mask_prem, subj_m[:, 12])] .= 2 ;

		rt[map(x -> x == 2, tone)] = (subj_m[map(x -> x == 2, tone), 16] -
									subj_m[map(x -> x == 2, tone), 15]) / 100.0 ;

		rt[map(x -> x == 8, tone)] = (subj_m[map(x -> x == 8, tone), 14] -
									subj_m[map(x -> x == 8, tone), 13]) / 100.0 ;

		rt[map((x) -> x == 3, subj_m[:,3])] = (subj_m[map((x) -> x == 3, subj_m[:,3]), 16] -
									subj_m[map((x) -> x == 3, subj_m[:,3]), 15]) / 100.0 ;
		rt[map((x) -> x == 2, subj_m[:,3])] = (subj_m[map((x) -> x == 2, subj_m[:,3]), 14] -
									subj_m[map((x) -> x == 2, subj_m[:,3]), 13]) / 100.0 ;

		write_v[2:end] = [mean(rt[mask_corr_2]), 
							mean(rt[mask_corr_8]), 
							mean(rt[mask_incorr_2]), 
							mean(rt[mask_incorr_8]),
							mean(rt[mask_corr_p2 .| mask_incorr_p1]), 
							mean(rt[mask_corr_p1 .| mask_incorr_p2]), 
							100.0*count(x->x==true, mask_corr_2)/count(x -> x == true, mask_corr_2 .| mask_incorr_2), 
							100.0*count(x->x==true, mask_corr_8)/count(x -> x == true, mask_corr_8 .| mask_incorr_8), 
							100.0*count(x->x==true, mask_incorr_2)/count(x -> x == true, mask_corr_2 .| mask_incorr_2), 
							100.0*count(x->x==true, mask_incorr_8)/count(x -> x == true, mask_corr_8 .| mask_incorr_8),
							100.0*count(x -> x == true, mask_corr_p2 .| mask_incorr_p1)/count(x -> x == true, mask_corr_p1 .| mask_incorr_p1 .| mask_corr_p2 .| mask_incorr_p2), 
							100.0*count(x -> x == true, mask_corr_p1 .| mask_incorr_p2)/count(x -> x == true, mask_corr_p2 .| mask_incorr_p2 .| mask_corr_p1 .| mask_incorr_p1),
							(count(x -> x == true, mask_corr_p2 .| mask_incorr_p1) - 
							count(x -> x == true, mask_corr_p1 .| mask_incorr_p2))/count(x -> x == true, mask_corr_p1 .| mask_incorr_p1 .| mask_corr_p2 .| mask_incorr_p2), 
							100.0*count(x->x==true, mask_om_2)/count(x->x==2, tone), 
							100.0*count(x->x==true, mask_om_8)/count(x->x==8, tone), 
							100.0*count(x -> x == true, mask_om_p)/count(x->x==p,tone), 
							100.0*count(x->x==true, mask_prem)/(subj_m[end,1]+1),
							mean([rt[mask_corr_p1 .| mask_incorr_p1] ; 
								rt[mask_corr_p2 .| mask_incorr_p2]]) ] ;
	end

	rt[mask_om_2 .| mask_om_8 .| mask_om_p] .= rt_max ;
	mask_rt_crit = map(x -> x > rt_criterion, rt) ;

	return subj_t(subj_id, 
				response[mask_rt_crit], 
				reward[mask_rt_crit], 
				tone[mask_rt_crit], 
				rt[mask_rt_crit], 
				0.0) , write_v
end

function get_probe_probabilistic_subj(subj_m::Array{Int64,2}, subj_id::String)

	reward = zeros(Int64, size(subj_m,1)) ;
	response = zeros(Int64, size(subj_m,1)) ;
	tone = zeros(Int64, size(subj_m,1)) ;
	rt = zeros(Float64, size(subj_m,1)) ;
	
	id_number_idx = findlast(isequal('_'), subj_id) ;
	id_number = tryparse(Int64, subj_id[id_number_idx + 1 : end]) ;

	# p1 : probe cue playing and response made on route 1 lever (left)
	# p2 : probe cue playing and response made on route 2 lever (right)

	mask_corr_cue1 = map((x,y) -> x == 0 && y != 0, subj_m[:,2], subj_m[:,13]) ;
	mask_corr_cue2 = map((x,y) -> x == 0 && y != 0, subj_m[:,2], subj_m[:,15]) ;
	mask_incorr_cue1 = map((x,y) -> x == 1 && y != 0, subj_m[:,2], subj_m[:,13]) ;
	mask_incorr_cue2 = map((x,y) -> x == 1 && y != 0, subj_m[:,2], subj_m[:,15]) ;
	mask_response_p1 = map(x -> x != 0, subj_m[:,25]) ;
	mask_response_p2 = map(x -> x != 0, subj_m[:,27]) ;
	mask_om_cue1 = map((x,y) -> x == 2 && y != 0, subj_m[:,2], subj_m[:, 13]) ;
	mask_om_cue2 = map((x,y) -> x == 2 && y != 0, subj_m[:,2], subj_m[:, 15]) ;
	mask_om_p1 = map((x,y) -> x == 2 && y != 0, subj_m[:,2], subj_m[:, 17]) ;
	mask_om_p2 = map((x,y) -> x == 2 && y != 0, subj_m[:,2], subj_m[:, 19]) ;
	mask_prem = map(x -> x == 4,  subj_m[:,2]) ;

	write_v = Array{Any,1}(undef, length(probe_header_v)) ;
	write_v[1] = id_number ;

	tone[map((x,y) -> x != 0 || y != 0, subj_m[:,17], subj_m[:,19])] .= 5 ;
	rt[map((x,y) -> x == 5 && y != 0, tone, subj_m[:, 17])] = (subj_m[map((x,y) -> x == 5 && y != 0, tone, subj_m[:, 17]), 18] - 
															subj_m[map((x,y) -> x == 5 && y != 0, tone, subj_m[:, 17]), 17]) / 100.0 ;
	rt[map((x,y) -> x == 5 && y != 0, tone, subj_m[:, 19])] = (subj_m[map((x,y) -> x == 5 && y != 0, tone, subj_m[:, 19]), 20] - 
															subj_m[map((x,y) -> x == 5 && y != 0, tone, subj_m[:, 19]), 19]) / 100.0 ;

	if mod(id_number, 2) == 0 
		response[mask_corr_cue1 .| mask_incorr_cue2 .| mask_response_p1] .= 8 ;
		response[mask_corr_cue2 .| mask_incorr_cue1 .| mask_response_p2] .= 2 ;
		reward[mask_corr_cue1 .| mask_response_p1] .= 1 ;
		reward[mask_corr_cue2 .| mask_response_p2] .= 4 ;
		tone[mask_corr_cue1 .| mask_incorr_cue1 .| mask_om_cue1] .= 8 ;
		tone[mask_corr_cue2 .| mask_incorr_cue2 .| mask_om_cue2] .= 2 ;
		rt[map(x -> x == 2, tone)] = (subj_m[map(x -> x == 2, tone), 16] - 
									subj_m[map(x -> x == 2, tone), 15]) / 100.0 ;
		rt[map(x -> x == 8, tone)] = (subj_m[map(x -> x == 8, tone), 14] - 
									subj_m[map(x -> x == 8, tone), 13]) / 100.0 ;

		response[map((x,y) -> x == true && y != 0, mask_prem, subj_m[:, 11])] .= 8 ;
		response[map((x,y) -> x == true && y != 0, mask_prem, subj_m[:, 12])] .= 2 ;

		mask_rt_crit = map((x,y) -> x > rt_criterion || y == true, rt, mask_prem) ;
		rt = rt[mask_rt_crit] ;
		tone = tone[mask_rt_crit] ;
		response = response[mask_rt_crit] ;
		reward = reward[mask_rt_crit] ;
		mask_corr_cue1 = mask_corr_cue1[mask_rt_crit] ;
		mask_corr_cue2 = mask_corr_cue2[mask_rt_crit] ;
		mask_incorr_cue1 = mask_incorr_cue1[mask_rt_crit] ;
		mask_incorr_cue2 = mask_incorr_cue2[mask_rt_crit] ;
		mask_response_p1 = mask_response_p1[mask_rt_crit] ;
		mask_response_p2 = mask_response_p2[mask_rt_crit] ;
		mask_om_cue1 = mask_om_cue1[mask_rt_crit] ;
		mask_om_cue2 = mask_om_cue2[mask_rt_crit] ;
		mask_om_p1 = mask_om_p1[mask_rt_crit] ;
		mask_om_p2 = mask_om_p2[mask_rt_crit] ;
		mask_prem = mask_prem[mask_rt_crit] ;

		write_v[2:end] = [mean(rt[mask_corr_cue2]), 
							mean(rt[mask_corr_cue1]), 
							mean(rt[mask_incorr_cue2]), 
							mean(rt[mask_incorr_cue1]),
							mean(rt[mask_response_p2]), 
							mean(rt[mask_response_p1]), 
							100.0*count(x->x==true, mask_corr_cue2)/count(x -> x == true, mask_corr_cue2 .| mask_incorr_cue2), 
							100.0*count(x->x==true, mask_corr_cue1)/count(x -> x == true, mask_corr_cue1 .| mask_incorr_cue1), 
							100.0*count(x->x==true, mask_incorr_cue2)/count(x -> x == true, mask_corr_cue2 .| mask_incorr_cue2), 
							100.0*count(x->x==true, mask_incorr_cue1)/count(x -> x == true, mask_corr_cue1 .| mask_incorr_cue1),
							100.0*count(x -> x == true, mask_response_p2)/count(x -> x == true, mask_response_p1 .| mask_response_p2), 
							100.0*count(x -> x == true, mask_response_p1)/count(x -> x == true, mask_response_p1 .| mask_response_p2), 
							(count(x -> x == true, mask_response_p2) - count(x -> x == true, mask_response_p1))/
							count(x -> x == true, mask_response_p1 .| mask_response_p2),
							100.0*count(x->x==true, mask_om_cue2)/count(x->x==2, tone), 
							100.0*count(x->x==true, mask_om_cue1)/count(x->x==8, tone), 
							100.0*count(x -> x == true, mask_om_p1 .| mask_om_p2)/count(x->x==5,tone), 
							100.0*count(x->x==true, mask_prem)/(subj_m[end,1]+1)] ;

	else
		response[mask_corr_cue1 .| mask_incorr_cue2 .| mask_response_p1] .= 2 ;
		response[mask_corr_cue2 .| mask_incorr_cue1 .| mask_response_p2] .= 8 ;
		reward[mask_corr_cue1 .| mask_response_p1] .= 4 ;
		reward[mask_corr_cue2 .| mask_response_p2] .= 1 ;
		tone[mask_corr_cue1 .| mask_incorr_cue1 .| mask_om_cue1] .= 2 ;
		tone[mask_corr_cue2 .| mask_incorr_cue2 .| mask_om_cue2] .= 8 ;
		rt[map(x -> x == 2, tone)] = (subj_m[map(x -> x == 2, tone), 14] - 
									subj_m[map(x -> x == 2, tone), 13]) / 100.0 ;
		rt[map(x -> x == 8, tone)] = (subj_m[map(x -> x == 8, tone), 16] - 
									subj_m[map(x -> x == 8, tone), 15]) / 100.0 ;
		
		response[map((x,y) -> x == true && y != 0, mask_prem, subj_m[:, 11])] .= 2 ;
		response[map((x,y) -> x == true && y != 0, mask_prem, subj_m[:, 12])] .= 8 ;

		mask_rt_crit = map((x,y) -> x > rt_criterion || y == true, rt, mask_prem) ;
		rt = rt[mask_rt_crit] ;
		tone = tone[mask_rt_crit] ;
		response = response[mask_rt_crit] ;
		reward = reward[mask_rt_crit] ;
		mask_corr_cue1 = mask_corr_cue1[mask_rt_crit] ;
		mask_corr_cue2 = mask_corr_cue2[mask_rt_crit] ;
		mask_incorr_cue1 = mask_incorr_cue1[mask_rt_crit] ;
		mask_incorr_cue2 = mask_incorr_cue2[mask_rt_crit] ;
		mask_response_p1 = mask_response_p1[mask_rt_crit] ;
		mask_response_p2 = mask_response_p2[mask_rt_crit] ;
		mask_om_cue1 = mask_om_cue1[mask_rt_crit] ;
		mask_om_cue2 = mask_om_cue2[mask_rt_crit] ;
		mask_om_p1 = mask_om_p1[mask_rt_crit] ;
		mask_om_p2 = mask_om_p2[mask_rt_crit] ;
		mask_prem = mask_prem[mask_rt_crit] ;

		write_v[2:end] = [mean(rt[mask_corr_cue1]), 
							mean(rt[mask_corr_cue2]), 
							mean(rt[mask_incorr_cue1]), 
							mean(rt[mask_incorr_cue2]),
							mean(rt[mask_response_p1]), 
							mean(rt[mask_response_p2]),  
							100.0*count(x->x==true, mask_corr_cue1)/count(x -> x == true, mask_corr_cue1 .| mask_incorr_cue1), 
							100.0*count(x->x==true, mask_corr_cue2)/count(x -> x == true, mask_corr_cue2 .| mask_incorr_cue2), 
							100.0*count(x->x==true, mask_incorr_cue1)/count(x -> x == true, mask_corr_cue1 .| mask_incorr_cue1), 
							100.0*count(x->x==true, mask_incorr_cue2)/count(x -> x == true, mask_corr_cue2 .| mask_incorr_cue2),
							100.0*count(x -> x == true, mask_response_p1)/count(x -> x == true, mask_response_p1 .| mask_response_p2), 
							100.0*count(x -> x == true, mask_response_p2)/count(x -> x == true, mask_response_p1 .| mask_response_p2), 
							(count(x -> x == true, mask_response_p1) - count(x -> x == true, mask_response_p2))/
							count(x -> x == true, mask_response_p1 .| mask_response_p2),
							100.0*count(x->x==true, mask_om_cue1)/count(x->x==2, tone), 
							100.0*count(x->x==true, mask_om_cue2)/count(x->x==8, tone), 
							100.0*count(x -> x == true, mask_om_p1 .| mask_om_p2)/count(x->x==5,tone), 
							100.0*count(x->x==true, mask_prem)/(subj_m[end,1]+1)] ;
	end

	rt[mask_om_cue1 .| mask_om_cue2 .| mask_om_p1 .| mask_om_p2] .= rt_max ;
	
	return subj_t(subj_id, 
				response, 
				reward, 
				tone, 
				rt, 
				write_v[14]) , write_v
end

function klimb_mi(path::String, session_to_analyse::Symbol, n_trials_in_the_past::Int64)

	if isempty(path)
		file_v = date_sort(filter(x->occursin(".csv", x), readdir())) ;
	else
		file_v = date_sort(filter(x->occursin(".csv", x), readdir(path))) ;
	end
	
	mi_pr_v = Array{Float64,1}(undef, n_trials_in_the_past) ;
	mi_pp_v = Array{Float64,1}(undef, n_trials_in_the_past) ;
	mi_prp_v = Array{Float64,1}(undef, n_trials_in_the_past) ;
	mi_ppr_v = Array{Float64,1}(undef, n_trials_in_the_past) ;
	ci_pr_v = Array{Tuple{Float64, Float64},1}(undef, n_trials_in_the_past) ;
	ci_pp_v = Array{Tuple{Float64, Float64},1}(undef, n_trials_in_the_past) ;
	ci_prp_v = Array{Tuple{Float64, Float64},1}(undef, n_trials_in_the_past) ;
	ci_ppr_v = Array{Tuple{Float64, Float64},1}(undef, n_trials_in_the_past) ;
	mi_pt_v = Array{Float64,1}(undef, n_trials_in_the_past) ;
	ci_pt_v = Array{Tuple{Float64, Float64},1}(undef, n_trials_in_the_past) ;

	subj_t_v = Array{subj_t,1}() ;

	for i = 1 : n_trials_in_the_past
	for file_name in file_v
		
		df = read_csv_var_cols(string(path, file_name)) ;

		write_v = Array{Array{Any,1},1}() ;
		session = :not_interesting ;
		dt_row_len = 0 ;
		subj_id = "" ;

		row_idx = 0 ;

		while row_idx < DataFrames.nrow(df)

			row_idx += 1 ;

			if occursin("AC Comment", df[row_idx, 1])
				if occursin("Pure", df[row_idx, 3])
					session = :t4v1 ;
					dt_row_len = 18 ;
				elseif occursin("Discrimination", df[row_idx, 3])
					session = :t1v1 ;
					dt_row_len = 18 ;
				elseif occursin("Route", df[row_idx, 3])
					session = :pulses ;
					dt_row_len = 22 ;
				elseif occursin("Probe", df[row_idx, 3]) && occursin("midpoint", df[row_idx, 3])
					session = :probe ;
					dt_row_len = 20 ;
				elseif occursin("Probe", df[row_idx, 3]) && occursin("1 vs 1", df[row_idx, 3])
					session = :probe_1v1 ;
					dt_row_len = 22 ;
				elseif occursin("Probe", df[row_idx, 3]) && occursin("multiple", df[row_idx, 3])
					session = :probe_mult_p ;
					dt_row_len = 30 ;
				elseif occursin("Probe", df[row_idx, 3]) && occursin("tones", df[row_idx, 3])
					session = :probe_mult_p_1v1 ;
					dt_row_len = 13 ;
				end
			end

			if occursin("Id", df[row_idx, 1])
				subj_id = df[row_idx, 2] ;
			end

			if occursin("Ref", df[row_idx, 1]) && occursin("Outcome", df[row_idx, 2]) && session != :not_interesting
				
				subj_m = Array{Int64,1}() ;
				row_idx += 1 ;

				while !occursin("ENDDATA", df[row_idx, 1]) && !occursin("-1", df[row_idx, 1])

					append!(subj_m, map(x->tryparse(Int64,x), df[row_idx, 1:dt_row_len])) ;
					row_idx += 1 ;
				end

				subj_m = permutedims(reshape(subj_m, dt_row_len, :), (2,1)) ;

				if session == :probe && session_to_analyse == :probe

					subj_t , subj_write_v = get_probe_subj(subj_m, subj_id, 0) ;

					if subj_write_v[8] >= acc_criterion && subj_write_v[9] >= acc_criterion
						push!(subj_t_v, subj_t) ;
					end
				elseif	session == :probe_1v1 && session_to_analyse == :probe
					
					subj_t , subj_write_v = get_probe_subj(subj_m, subj_id, 2) ;

					if subj_write_v[8] >= acc_criterion && subj_write_v[9] >= acc_criterion
						push!(subj_t_v, subj_t) ;
					end
				elseif (session == :t1v1 || session == :t4v1) && session_to_analyse == :train

					subj_t , subj_write_v = get_train_subj(subj_m, subj_id, session, 0) ;
					push!(subj_t_v, subj_t) ;
				end
			end
		end
	end

	mi_v = mutual_info(subj_t_v, i) ;
	mi_pr_v[i] = mi_v[1] ;
	mi_pp_v[i] = mi_v[2] ;
	mi_prp_v[i] = mi_v[3] ;
	mi_ppr_v[i] = mi_v[4] ;
	ci_pr_v[i] = mi_v[5] ;
	ci_pp_v[i] = mi_v[6] ;
	ci_prp_v[i] = mi_v[7] ;
	ci_ppr_v[i] = mi_v[8] ;
	mi_pt_v[i] = mi_v[9] ;
	ci_pt_v[i] = mi_v[10] ;
	
	end
	plot_mi(mi_pr_v, mi_pp_v, mi_prp_v, mi_ppr_v, ci_pr_v, ci_pp_v, ci_prp_v, ci_ppr_v, 
		mi_pt_v, ci_pt_v, n_trials_in_the_past)
end

function old_klimb_read(path::String, session_to_analyse::Symbol, write_flag::Bool)
	# including the old format of CH1 batch
	# used read ket/veh past data that includes CH1
	
	if isempty(path)
		file_v = date_sort(filter(x->occursin(".csv", x), readdir())) ;
	else
		file_v = date_sort(filter(x->occursin(".csv", x), readdir(path))) ;
	end

	subj_t_v = Array{subj_t,1}() ;

	for file_name in file_v
		
		df = read_csv_var_cols(string(path, file_name)) ;

		write_v = Array{Array{Any,1},1}() ;
		session = :not_interesting ;
		dt_row_len = 0 ;
		first_time = true ;
		subj_id = "" ;

		probe_tone_1v1 = 0 ;
		row_idx = 0 ;

		while row_idx < DataFrames.nrow(df)

			row_idx += 1 ;

			if occursin("AC Comment", df[row_idx, 1])
				if occursin("Pure", df[row_idx, 3])
					session = :t4v1 ;
					dt_row_len = 18 ;
				elseif occursin("Discrimination", df[row_idx, 3]) && occursin("5.5kHz", df[row_idx, 3])
					session = :probe_var_p_1v1 ;
					dt_row_len = 16 ;
					probe_tone_1v1 = 4 ; # 5.5 kHz
				elseif occursin("Discrimination", df[row_idx, 3]) && occursin("5kHz", df[row_idx, 3])
					session = :probe_var_p_1v1 ;
					dt_row_len = 16 ;
					probe_tone_1v1 = 3 ; # 5 kHz
				elseif occursin("Discrimination", df[row_idx, 3]) && occursin("6kHz", df[row_idx, 3])
					session = :probe_var_p_1v1 ;
					dt_row_len = 16 ;
					probe_tone_1v1 = 5 ; # 6 kHz
				elseif occursin("Discrimination", df[row_idx, 3])
					session = :t1v1 ;
					dt_row_len = 18 ;
				elseif occursin("Route", df[row_idx, 3])
					session = :pulses ;
					dt_row_len = 22 ;
				elseif occursin("Probe", df[row_idx, 3]) && occursin("midpoint", df[row_idx, 3])
					session = :probe ;
					if occursin("2014", file_name) # CH1 batch file
						dt_row_len = 16 ;
					else
						dt_row_len = 20 ;
					end
				elseif occursin("Probe", df[row_idx, 3]) && occursin("1 vs 1", df[row_idx, 3])
					session = :probe_1v1 ;
					dt_row_len = 22 ;
				elseif occursin("Probe", df[row_idx, 3]) && occursin("multiple", df[row_idx, 3])
					session = :probe_mult_p ;
					dt_row_len = 30 ;
				elseif occursin("Probe", df[row_idx, 3]) && occursin("tones", df[row_idx, 3])
					session = :probe_mult_p_1v1 ;
					dt_row_len = 13 ;
				end
			end

			if occursin("Id", df[row_idx, 1])
				subj_id = df[row_idx, 2] ;
			end
			
			if occursin("Ref", df[row_idx, 1]) && occursin("Outcome", df[row_idx, 2]) && session != :not_interesting &&
				!any(exclude_v .== subj_id)
				
				subj_m = Array{Int64,1}() ;
				row_idx += 1 ;

				while !occursin("ENDDATA", df[row_idx, 1]) && !occursin("-1", df[row_idx, 1])

					append!(subj_m, map(x->tryparse(Int64,x), df[row_idx, 1:dt_row_len])) ;
					row_idx += 1 ;
				end

				subj_m = permutedims(reshape(subj_m, dt_row_len, :), (2,1)) ;

				if session == :probe && session_to_analyse == :probe
					if first_time
						println(file_name)
						first_time = false ;
					end

					if occursin("2014", file_name) # CH1 batch file
						subj_t , subj_write_v = get_old_probe_subj(subj_m, subj_id, 0) ;
					else
						subj_t , subj_write_v = get_probe_subj(subj_m, subj_id, 0) ;
					end

					if subj_write_v[8] >= acc_criterion && subj_write_v[9] >= acc_criterion
						push!(subj_t_v, subj_t) ;
						push!(write_v, subj_write_v) ;
					else
						push!(exclude_v, subj_id) ;
					end					
				elseif	session == :probe_1v1 && session_to_analyse == :probe
					if first_time
						println(file_name)
						first_time = false ;
					end
					
					subj_t , subj_write_v = get_probe_subj(subj_m, subj_id, 2) ;

					if subj_write_v[8] >= acc_criterion && subj_write_v[9] >= acc_criterion
						push!(subj_t_v, subj_t) ;
						push!(write_v, subj_write_v) ;
					end					
				elseif session == :probe_mult_p && session_to_analyse == :probe
					if first_time
						println(file_name)
						first_time = false ;
					end

					subj_t , subj_write_v = get_probe_mult_p_subj(subj_m, subj_id, 0) ;

					if subj_write_v[14] >= acc_criterion && subj_write_v[15] >= acc_criterion
						push!(subj_t_v, subj_t) ;
						push!(write_v, subj_write_v) ;
					end		
				elseif session == :probe_mult_p_1v1 && session_to_analyse == :probe
					if first_time
						println(file_name)
						first_time = false ;
					end

					subj_t , subj_write_v = get_probe_mult_p_1v1_subj(subj_m, subj_id) ;

					if subj_write_v[14] >= acc_criterion && subj_write_v[15] >= acc_criterion
						push!(subj_t_v, subj_t) ;
						push!(write_v, subj_write_v) ;
					end	
				elseif session == :probe_var_p_1v1 && session_to_analyse == :probe
					if first_time
						println(file_name)
						first_time = false ;
					end

					subj_t , subj_write_v = get_probe_var_p_1v1_subj(subj_m, subj_id, probe_tone_1v1) ;

					if subj_write_v[8] >= acc_criterion && subj_write_v[9] >= acc_criterion
						push!(subj_t_v, subj_t) ;
						push!(write_v, subj_write_v) ;
					end				
				elseif (session == :t1v1 || session == :t4v1) && session_to_analyse == :train
					if first_time
						println(file_name)
						first_time = false ;
					end

					subj_t , subj_write_v = get_train_subj(subj_m, subj_id, session, 0) ;
					
					if subj_write_v[7] >= acc_criterion && subj_write_v[8] >= acc_criterion
						push!(subj_t_v, subj_t) ;
						push!(write_v, subj_write_v) ;
					end
				elseif session == :pulses && session_to_analyse == :train
					if first_time
						println(file_name)
						first_time = false ;
					end

					subj_t , subj_write_v = get_train_pulses_subj(subj_m, subj_id, session, 0) ;
					
					if subj_write_v[7] >= acc_criterion && subj_write_v[8] >= acc_criterion
						push!(subj_t_v, subj_t) ;
						push!(write_v, subj_write_v) ;
					end
				end
			end
		end
		if !isempty(write_v) && write_flag
			write_xlsx(write_v, session, file_name, path) ;
		end
	end

	return subj_t_v
end

function get_old_probe_subj(subj_m::Array{Int64,2}, subj_id::String, col_offset::Int64)
	# get probe data for Ch1 batch

	reward = zeros(Int64, size(subj_m,1)) ;
	response = zeros(Int64, size(subj_m,1)) ;
	tone = zeros(Int64, size(subj_m,1)) ;
	rt = zeros(Float64, size(subj_m,1)) ;

	id_number_idx = findlast(isequal('_'), subj_id) ;
	id_number = tryparse(Int64, subj_id[id_number_idx + 1 : end]) ;

	
	mask_prem = map(x -> x == 4,  subj_m[:,2]) ;

	write_v = Array{Any,1}(undef, length(probe_header_v)) ;
	write_v[1] = id_number ;

	tone[map((x,y) -> (x == 2 || x == 3) && y != 4, subj_m[:,3], subj_m[:,2])] .= 5 ;
	rt[map((x,y) -> x == 5 && y != 0, tone, subj_m[:,13])] = (subj_m[map((x,y) -> x == 5 && y != 0, tone, subj_m[:,13]), 14] - 
									subj_m[map((x,y) -> x == 5 && y != 0, tone, subj_m[:,13]), 13]) / 100.0 ;
	rt[map((x,y) -> x == 5 && y != 0, tone, subj_m[:,15])] = (subj_m[map((x,y) -> x == 5 && y != 0, tone, subj_m[:,15]), 16] - 
									subj_m[map((x,y) -> x == 5 && y != 0, tone, subj_m[:,15]), 15]) / 100.0 ;

	if id_number in [1,2,7,8,9,10,15,16,17,18] 

		mask_corr_cue1 = map((x,y,z) -> x == 0 && y != 0 && z == 1, subj_m[:,2], subj_m[:,13], subj_m[:,3]) ;
		mask_corr_cue2 = map((x,y,z) -> x == 0 && y != 0 && z == 0, subj_m[:,2], subj_m[:,15], subj_m[:,3]) ;
		mask_incorr_cue1 = map((x,y,z) -> x == 1 && y != 0 && z == 1, subj_m[:,2], subj_m[:,13], subj_m[:,3]) ;
		mask_incorr_cue2 = map((x,y,z) -> x == 3 && y != 0 && z == 0, subj_m[:,2], subj_m[:,15], subj_m[:,3]) ;
		mask_corr_p1 = map((x,y,z) -> x == 0 && y != 0 && z == 3, subj_m[:,2], subj_m[:,13], subj_m[:,3]) ;
		mask_corr_p2 = map((x,y,z) -> x == 0 && y != 0 && z == 2, subj_m[:,2], subj_m[:,15], subj_m[:,3]) ;
		mask_incorr_p1 = map((x,y,z) -> x == 1 && y != 0 && z == 3, subj_m[:,2], subj_m[:,13], subj_m[:,3]) ;
		mask_incorr_p2 = map((x,y,z) -> x == 3 && y != 0 && z == 2, subj_m[:,2], subj_m[:,15], subj_m[:,3]) ;
		mask_om_cue1 = map((x,y,z) -> x == 2 && y != 0 && z == 1, subj_m[:,2], subj_m[:,13], subj_m[:,3]) ;
		mask_om_cue2 = map((x,y,z) -> x == 2 && y != 0 && z == 0, subj_m[:,2], subj_m[:,15], subj_m[:,3]) ;
		mask_om_p1 = map((x,y,z) -> x == 2 && y != 0 && z == 3, subj_m[:,2], subj_m[:,13], subj_m[:,3]) ;
		mask_om_p2 = map((x,y,z) -> x == 2 && y != 0 && z == 2, subj_m[:,2], subj_m[:,15], subj_m[:,3]) ;

		response[mask_corr_cue1 .| mask_corr_p1 .| mask_incorr_cue2 .| mask_incorr_p2] .= 2 ;
		response[mask_corr_cue2 .| mask_corr_p2 .| mask_incorr_cue1 .| mask_incorr_p1] .= 8 ;
		reward[mask_corr_cue1 .| mask_corr_p1] .= 4 ;
		reward[mask_corr_cue2 .| mask_corr_p2] .= 1 ;
		tone[mask_corr_cue1 .| mask_incorr_cue1 .| mask_om_cue1] .= 2 ;
		tone[mask_corr_cue2 .| mask_incorr_cue2 .| mask_om_cue2] .= 8 ;
		rt[map(x -> x == 2, tone)] = (subj_m[map(x -> x == 2, tone), 14] - 
									subj_m[map(x -> x == 2, tone), 13]) / 100.0 ;
		rt[map(x -> x == 8, tone)] = (subj_m[map(x -> x == 8, tone), 16] - 
									subj_m[map(x -> x == 8, tone), 15]) / 100.0 ;
		
		mask_rt_crit = map(x -> x > rt_criterion, rt) ;
		rt = rt[mask_rt_crit] ;
		tone = tone[mask_rt_crit] ;
		response = response[mask_rt_crit] ;
		reward = reward[mask_rt_crit] ;
		mask_corr_cue1 = mask_corr_cue1[mask_rt_crit] ;
		mask_corr_cue2 = mask_corr_cue2[mask_rt_crit] ;
		mask_incorr_cue1 = mask_incorr_cue1[mask_rt_crit] ;
		mask_incorr_cue2 = mask_incorr_cue2[mask_rt_crit] ;
		mask_corr_p1 = mask_corr_p1[mask_rt_crit] ;
		mask_corr_p2 = mask_corr_p2[mask_rt_crit] ;
		mask_incorr_p1 = mask_incorr_p1[mask_rt_crit] ;
		mask_incorr_p2 = mask_incorr_p2[mask_rt_crit] ;
		mask_om_cue1 = mask_om_cue1[mask_rt_crit] ;
		mask_om_cue2 = mask_om_cue2[mask_rt_crit] ;
		mask_om_p1 = mask_om_p1[mask_rt_crit] ;
		mask_om_p2 = mask_om_p2[mask_rt_crit] ;
		mask_prem = mask_prem[mask_rt_crit] ;

		write_v[2:end] = [mean(rt[mask_corr_cue1]), 
							mean(rt[mask_corr_cue2]), 
							mean(rt[mask_incorr_cue1]), 
							mean(rt[mask_incorr_cue2]),
							mean(rt[mask_corr_p1 .| mask_incorr_p2]), 
							mean(rt[mask_corr_p2 .| mask_incorr_p1]),  
							100.0*count(x->x==true, mask_corr_cue1)/count(x -> x == true, mask_corr_cue1 .| mask_incorr_cue1), 
							100.0*count(x->x==true, mask_corr_cue2)/count(x -> x == true, mask_corr_cue2 .| mask_incorr_cue2), 
							100.0*count(x->x==true, mask_incorr_cue1)/count(x -> x == true, mask_corr_cue1 .| mask_incorr_cue1), 
							100.0*count(x->x==true, mask_incorr_cue2)/count(x -> x == true, mask_corr_cue2 .| mask_incorr_cue2),
							100.0*count(x -> x == true, mask_corr_p1 .| mask_incorr_p2)/count(x -> x == true, mask_corr_p1 .| mask_incorr_p1 .| mask_corr_p2 .| mask_incorr_p2), 
							100.0*count(x -> x == true, mask_corr_p2 .| mask_incorr_p1)/count(x -> x == true, mask_corr_p1 .| mask_incorr_p1 .| mask_corr_p2 .| mask_incorr_p2), 
							(count(x -> x == true, mask_corr_p1 .| mask_incorr_p2) - 
							count(x -> x == true, mask_corr_p2 .| mask_incorr_p1))/count(x -> x == true, mask_corr_p1 .| mask_incorr_p1 .| mask_corr_p2 .| mask_incorr_p2),
							100.0*count(x->x==true, mask_om_cue1)/count(x->x==2, tone), 
							100.0*count(x->x==true, mask_om_cue2)/count(x->x==8, tone), 
							100.0*count(x -> x == true, mask_om_p1 .| mask_om_p2)/count(x->x==5,tone), 
							100.0*count(x->x==true, mask_prem)/(subj_m[end,1]+1), 
							mean([rt[mask_corr_p1 .| mask_incorr_p1] ; 
								rt[mask_corr_p2 .| mask_incorr_p2]])] ;

	else

		mask_corr_cue1 = map((x,y,z) -> x == 0 && y != 0 && z == 0, subj_m[:,2], subj_m[:,13], subj_m[:,3]) ;
		mask_corr_cue2 = map((x,y,z) -> x == 0 && y != 0 && z == 1, subj_m[:,2], subj_m[:,15], subj_m[:,3]) ;
		mask_incorr_cue1 = map((x,y,z) -> x == 1 && y != 0 && z == 0, subj_m[:,2], subj_m[:,13], subj_m[:,3]) ;
		mask_incorr_cue2 = map((x,y,z) -> x == 3 && y != 0 && z == 1, subj_m[:,2], subj_m[:,15], subj_m[:,3]) ;
		mask_corr_p1 = map((x,y,z) -> x == 0 && y != 0 && z == 2, subj_m[:,2], subj_m[:,13], subj_m[:,3]) ;
		mask_corr_p2 = map((x,y,z) -> x == 0 && y != 0 && z == 3, subj_m[:,2], subj_m[:,15], subj_m[:,3]) ;
		mask_incorr_p1 = map((x,y,z) -> x == 1 && y != 0 && z == 2, subj_m[:,2], subj_m[:,13], subj_m[:,3]) ;
		mask_incorr_p2 = map((x,y,z) -> x == 3 && y != 0 && z == 3, subj_m[:,2], subj_m[:,15], subj_m[:,3]) ;
		mask_om_cue1 = map((x,y,z) -> x == 2 && y != 0 && z == 0, subj_m[:,2], subj_m[:,13], subj_m[:,3]) ;
		mask_om_cue2 = map((x,y,z) -> x == 2 && y != 0 && z == 1, subj_m[:,2], subj_m[:,15], subj_m[:,3]) ;
		mask_om_p1 = map((x,y,z) -> x == 2 && y != 0 && z == 2, subj_m[:,2], subj_m[:,13], subj_m[:,3]) ;
		mask_om_p2 = map((x,y,z) -> x == 2 && y != 0 && z == 3, subj_m[:,2], subj_m[:,15], subj_m[:,3]) ;

		response[mask_corr_cue1 .| mask_corr_p1 .| mask_incorr_cue2 .| mask_incorr_p2] .= 8 ;
		response[mask_corr_cue2 .| mask_corr_p2 .| mask_incorr_cue1 .| mask_incorr_p1] .= 2 ;
		reward[mask_corr_cue1 .| mask_corr_p1] .= 1 ;
		reward[mask_corr_cue2 .| mask_corr_p2] .= 4 ;
		tone[mask_corr_cue1 .| mask_incorr_cue1 .| mask_om_cue1] .= 8 ;
		tone[mask_corr_cue2 .| mask_incorr_cue2 .| mask_om_cue2] .= 2 ;
		rt[map(x -> x == 2, tone)] = (subj_m[map(x -> x == 2, tone), 16] - 
									subj_m[map(x -> x == 2, tone), 15]) / 100.0 ;
		rt[map(x -> x == 8, tone)] = (subj_m[map(x -> x == 8, tone), 14] - 
									subj_m[map(x -> x == 8, tone), 13]) / 100.0 ;

		mask_rt_crit = map(x -> x > rt_criterion, rt) ;
		rt = rt[mask_rt_crit] ;
		tone = tone[mask_rt_crit] ;
		response = response[mask_rt_crit] ;
		reward = reward[mask_rt_crit] ;
		mask_corr_cue1 = mask_corr_cue1[mask_rt_crit] ;
		mask_corr_cue2 = mask_corr_cue2[mask_rt_crit] ;
		mask_incorr_cue1 = mask_incorr_cue1[mask_rt_crit] ;
		mask_incorr_cue2 = mask_incorr_cue2[mask_rt_crit] ;
		mask_corr_p1 = mask_corr_p1[mask_rt_crit] ;
		mask_corr_p2 = mask_corr_p2[mask_rt_crit] ;
		mask_incorr_p1 = mask_incorr_p1[mask_rt_crit] ;
		mask_incorr_p2 = mask_incorr_p2[mask_rt_crit] ;
		mask_om_cue1 = mask_om_cue1[mask_rt_crit] ;
		mask_om_cue2 = mask_om_cue2[mask_rt_crit] ;
		mask_om_p1 = mask_om_p1[mask_rt_crit] ;
		mask_om_p2 = mask_om_p2[mask_rt_crit] ;
		mask_prem = mask_prem[mask_rt_crit] ;

		write_v[2:end] = [mean(rt[mask_corr_cue2]), 
							mean(rt[mask_corr_cue1]), 
							mean(rt[mask_incorr_cue2]), 
							mean(rt[mask_incorr_cue1]),
							mean(rt[mask_corr_p2 .| mask_incorr_p1]), 
							mean(rt[mask_corr_p1 .| mask_incorr_p2]), 
							100.0*count(x->x==true, mask_corr_cue2)/count(x -> x == true, mask_corr_cue2 .| mask_incorr_cue2), 
							100.0*count(x->x==true, mask_corr_cue1)/count(x -> x == true, mask_corr_cue1 .| mask_incorr_cue1), 
							100.0*count(x->x==true, mask_incorr_cue2)/count(x -> x == true, mask_corr_cue2 .| mask_incorr_cue2), 
							100.0*count(x->x==true, mask_incorr_cue1)/count(x -> x == true, mask_corr_cue1 .| mask_incorr_cue1),
							100.0*count(x -> x == true, mask_corr_p2 .| mask_incorr_p1)/count(x -> x == true, mask_corr_p1 .| mask_incorr_p1 .| mask_corr_p2 .| mask_incorr_p2), 
							100.0*count(x -> x == true, mask_corr_p1 .| mask_incorr_p2)/count(x -> x == true, mask_corr_p1 .| mask_incorr_p1 .| mask_corr_p2 .| mask_incorr_p2), 
							(count(x -> x == true, mask_corr_p2 .| mask_incorr_p1) - 
							count(x -> x == true, mask_corr_p1 .| mask_incorr_p2))/count(x -> x == true, mask_corr_p1 .| mask_incorr_p1 .| mask_corr_p2 .| mask_incorr_p2),
							100.0*count(x->x==true, mask_om_cue2)/count(x->x==2, tone), 
							100.0*count(x->x==true, mask_om_cue1)/count(x->x==8, tone), 
							100.0*count(x -> x == true, mask_om_p1 .| mask_om_p2)/count(x->x==5,tone), 
							100.0*count(x->x==true, mask_prem)/(subj_m[end,1]+1), 
							mean([rt[mask_corr_p1 .| mask_incorr_p1] ; 
								rt[mask_corr_p2 .| mask_incorr_p2]])] ;

	end

	rt[mask_om_cue1 .| mask_om_cue2 .| mask_om_p1 .| mask_om_p2] .= rt_max ;

	return subj_t(subj_id, 
				response, 
				reward, 
				tone, 
				rt, 
				write_v[14]) , write_v
end

function get_crf_subj(subj_m::Array{Int64,2}, subj_id::String)

	reward = ones(Int64, size(subj_m,1)) ;
	response = ones(Int64, size(subj_m,1)) ;
	tone = zeros(Int64, size(subj_m,1)) ;
	rt = zeros(Float64, size(subj_m,1)) ;
	
	id_number_idx = findlast(isequal('_'), subj_id) ;
	id_number = tryparse(Int64, subj_id[id_number_idx + 1 : end]) ;

	mask_response1 = map((x,y) -> x != 2 && x != 4 && y != 0, subj_m[:,2], subj_m[:,20]) ;
	mask_response2 = map((x,y) -> x != 2 && x != 4 && y != 0, subj_m[:,2], subj_m[:,26]) ;

	mask_om = map(x -> x == 2 , subj_m[:,2]) ;
	mask_prem = map(x -> x == 4,  subj_m[:,2]) ;

	write_v = Array{Any,1}(undef, length(probe_header_v)) ;
	write_v[1] = id_number ;
	write_v[14] = 0.0 ;

	rt[mask_response1] = (subj_m[mask_response1, 20] - subj_m[mask_response1, 19]) / 100.0 ;
	rt[mask_response2] = (subj_m[mask_response2, 26] - subj_m[mask_response2, 25]) / 100.0 ;

	return subj_t(subj_id, 
				response, 
				reward, 
				tone, 
				rt, 
				write_v[14]) , write_v
end

function get_train_light_tone_subj(subj_m::Array{Int64,2}, subj_id::String, session::Symbol)

	reward = zeros(Int64, size(subj_m,1)) ;
	response = zeros(Int64, size(subj_m,1)) ;
	tone = zeros(Int64, size(subj_m,1)) ;
	rt = zeros(Float64, size(subj_m,1)) ;

	id_number_idx = findlast(isequal('_'), subj_id) ;
	id_number = tryparse(Int64, subj_id[id_number_idx + 1 : end]) ;

	mask_corr_cue1 = map((x,y) -> x == 0 && y != 0, subj_m[:,2], subj_m[:,23]) ;
	mask_corr_cue2 = map((x,y) -> x == 0 && y != 0, subj_m[:,2], subj_m[:,29]) ;
	mask_incorr_cue1 = map((x,y) -> (x == 1 || x == 3) && y != 0, subj_m[:,2], subj_m[:,23]) ;
	mask_incorr_cue2 = map((x,y) -> (x == 1 || x == 3) && y != 0, subj_m[:,2], subj_m[:,29]) ;
	mask_om_cue1 = map((x,y) -> x == 2 && y != 0, subj_m[:,2], subj_m[:, 23]) ;
	mask_om_cue2 = map((x,y) -> x == 2 && y != 0, subj_m[:,2], subj_m[:, 29]) ;
	mask_prem = map(x -> x == 4,  subj_m[:,2]) ;

	write_v = Array{Any,1}(undef, length(train_header_v)) ;
	write_v[1] = id_number ;
	write_v[2] = string(session) ;

	#___________________________________________________________________
	#___________________________________________________________________
	#____Reversed lever - reward contingencies than traditional JBT_____
	#___________________________________________________________________
	#___________________________________________________________________

	if mod(id_number, 2) != 0 # traditionally mod(id_number, 2) == 0
		response[mask_corr_cue1 .| mask_incorr_cue2] .= 8 ; 
		response[mask_corr_cue2 .| mask_incorr_cue1] .= 2 ; 

		if session == :t1v1 || session == :t1v1_light_pulse
			reward[mask_corr_cue1] .= 1 ;
			reward[mask_corr_cue2] .= 1 ;
		else
			reward[mask_corr_cue1] .= 1 ;
			reward[mask_corr_cue2] .= 4 ;
		end

		tone[mask_corr_cue1 .| mask_incorr_cue1 .| mask_om_cue1] .= 8 ; 
		tone[mask_corr_cue2 .| mask_incorr_cue2 .| mask_om_cue2] .= 2 ;
		rt[map(x -> x == 2, tone)] = (subj_m[map(x -> x == 2, tone), 30] - 
									subj_m[map(x -> x == 2, tone), 29]) / 100.0 ;
		rt[map(x -> x == 8, tone)] = (subj_m[map(x -> x == 8, tone), 24] - 
									subj_m[map(x -> x == 8, tone), 23]) / 100.0 ;

		mask_rt_crit = map((x,y) -> x > rt_criterion || y == true, rt, mask_prem) ;
		rt = rt[mask_rt_crit] ;
		tone = tone[mask_rt_crit] ;
		response = response[mask_rt_crit] ;
		reward = reward[mask_rt_crit] ;
		mask_corr_cue1 = mask_corr_cue1[mask_rt_crit] ;
		mask_corr_cue2 = mask_corr_cue2[mask_rt_crit] ;
		mask_incorr_cue1 = mask_incorr_cue1[mask_rt_crit] ;
		mask_incorr_cue2 = mask_incorr_cue2[mask_rt_crit] ;
		mask_om_cue1 = mask_om_cue1[mask_rt_crit] ;
		mask_om_cue2 = mask_om_cue2[mask_rt_crit] ;
		mask_prem = mask_prem[mask_rt_crit] ;

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
		response[mask_corr_cue1 .| mask_incorr_cue2] .= 2 ; # fast pulse
		response[mask_corr_cue2 .| mask_incorr_cue1] .= 8 ; # slow pulse
		
		if session == :t1v1 || session == :t1v1_light_pulse
			reward[mask_corr_cue1] .= 1 ;
			reward[mask_corr_cue2] .= 1 ;
		else
			reward[mask_corr_cue1] .= 4 ;
			reward[mask_corr_cue2] .= 1 ;
		end

		tone[mask_corr_cue1 .| mask_incorr_cue1 .| mask_om_cue1] .= 2 ;
		tone[mask_corr_cue2 .| mask_incorr_cue2 .| mask_om_cue2] .= 8 ;
		rt[map(x -> x == 2, tone)] = (subj_m[map(x -> x == 2, tone), 24] - 
									subj_m[map(x -> x == 2, tone), 23]) / 100.0 ;
		rt[map(x -> x == 8, tone)] = (subj_m[map(x -> x == 8, tone), 30] - 
									subj_m[map(x -> x == 8, tone), 29]) / 100.0 ;
		
		mask_rt_crit = map((x,y) -> x > rt_criterion || y == true, rt, mask_prem) ;
		rt = rt[mask_rt_crit] ;
		tone = tone[mask_rt_crit] ;
		response = response[mask_rt_crit] ;
		reward = reward[mask_rt_crit] ;
		mask_corr_cue1 = mask_corr_cue1[mask_rt_crit] ;
		mask_corr_cue2 = mask_corr_cue2[mask_rt_crit] ;
		mask_incorr_cue1 = mask_incorr_cue1[mask_rt_crit] ;
		mask_incorr_cue2 = mask_incorr_cue2[mask_rt_crit] ;
		mask_om_cue1 = mask_om_cue1[mask_rt_crit] ;
		mask_om_cue2 = mask_om_cue2[mask_rt_crit] ;
		mask_prem = mask_prem[mask_rt_crit] ;

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

	rt[mask_om_cue1 .| mask_om_cue2] .= rt_max_new ;

	return subj_t(subj_id, 
				response, 
				reward, 
				tone, 
				rt, 
				0.0) , write_v

end

function get_probe_1v1_light_tone_subj(subj_m::Array{Int64,2}, subj_id::String)

	reward = zeros(Int64, size(subj_m,1)) ;
	response = zeros(Int64, size(subj_m,1)) ;
	tone = zeros(Int64, size(subj_m,1)) ;
	rt = zeros(Float64, size(subj_m,1)) ;

	id_number_idx = findlast(isequal('_'), subj_id) ;
	id_number = tryparse(Int64, subj_id[id_number_idx + 1 : end]) ;

	mask_corr_cue1 = map((x,y) -> x == 0 && y != 0, subj_m[:,2], subj_m[:,17]) ;
	mask_corr_cue2 = map((x,y) -> x == 0 && y != 0, subj_m[:,2], subj_m[:,21]) ;
	mask_incorr_cue1 = map((x,y) -> (x == 1 || x == 3) && y != 0, subj_m[:,2], subj_m[:,17]) ;
	mask_incorr_cue2 = map((x,y) -> (x == 1 || x == 3) && y != 0, subj_m[:,2], subj_m[:,21]) ;
	mask_om_cue1 = map((x,y) -> x == 2 && y != 0, subj_m[:,2], subj_m[:, 17]) ;
	mask_om_cue2 = map((x,y) -> x == 2 && y != 0, subj_m[:,2], subj_m[:, 21]) ;
	mask_prem = map(x -> x == 4,  subj_m[:,2]) ;

	mask_response_p1 = map((x,y) -> x != 0 && y != 0, subj_m[:, 23], subj_m[:, 29]) ;
	mask_response_p2 = map((x,y) -> x != 0 && y != 0, subj_m[:, 23], subj_m[:, 31]) ;
	mask_om_p = map((x,y) -> x == 2 && y != 0, subj_m[:,2], subj_m[:, 23]) ;

	reward[mask_corr_cue1] .= 1 ;
	reward[mask_corr_cue2] .= 1 ;
	reward[map((x,y) -> x != 0 || y != 0, subj_m[:, 30], subj_m[:, 32])] .= 1 ;

	write_v = Array{Any,1}(undef, length(probe_header_v)) ;
	write_v[1] = id_number ;

	#___________________________________________________________________
	#___________________________________________________________________
	#____Reversed lever - reward contingencies than traditional JBT_____
	#___________________________________________________________________
	#___________________________________________________________________

	if mod(id_number, 2) != 0 # traditionally mod(id_number, 2) == 0
		response[mask_corr_cue1 .| mask_incorr_cue2 .| mask_response_p1] .= 8 ; 
		response[mask_corr_cue2 .| mask_incorr_cue1 .| mask_response_p2] .= 2 ; 

		response[map(x -> x != 0, subj_m[:, 13])] .= 8 ;
		response[map(x -> x != 0, subj_m[:, 14])] .= 2 ;

		tone[mask_corr_cue1 .| mask_incorr_cue1 .| mask_om_cue1] .= 8 ; 
		tone[mask_corr_cue2 .| mask_incorr_cue2 .| mask_om_cue2] .= 2 ;
		tone[mask_response_p1 .| mask_response_p2 .| mask_om_p] .= -1 ; 

		rt[map(x -> x == 2, tone)] = (subj_m[map(x -> x == 2, tone), 22] - 
									subj_m[map(x -> x == 2, tone), 21]) / 100.0 ;
		rt[map(x -> x == 8, tone)] = (subj_m[map(x -> x == 8, tone), 18] - 
									subj_m[map(x -> x == 8, tone), 17]) / 100.0 ;
		rt[map(x -> x == -1, tone)] = (subj_m[map(x -> x == -1, tone), 24] - 
									subj_m[map(x -> x == -1, tone), 23]) / 100.0 ;

		mask_rt_crit = map((x,y) -> x > rt_criterion || y == true, rt, mask_prem) ;
		rt = rt[mask_rt_crit] ;
		tone = tone[mask_rt_crit] ;
		response = response[mask_rt_crit] ;
		reward = reward[mask_rt_crit] ;
		mask_corr_cue1 = mask_corr_cue1[mask_rt_crit] ;
		mask_corr_cue2 = mask_corr_cue2[mask_rt_crit] ;
		mask_incorr_cue1 = mask_incorr_cue1[mask_rt_crit] ;
		mask_incorr_cue2 = mask_incorr_cue2[mask_rt_crit] ;
		mask_om_cue1 = mask_om_cue1[mask_rt_crit] ;
		mask_om_cue2 = mask_om_cue2[mask_rt_crit] ;
		mask_prem = mask_prem[mask_rt_crit] ;
		mask_response_p1 = mask_response_p1[mask_rt_crit] ;
		mask_response_p2 = mask_response_p2[mask_rt_crit] ;
		mask_om_p = mask_om_p[mask_rt_crit] ;

		write_v[2:end] = [mean(rt[mask_corr_cue2]), 
							mean(rt[mask_corr_cue1]), 
							mean(rt[mask_incorr_cue2]), 
							mean(rt[mask_incorr_cue1]),
							mean(rt[mask_response_p2]), 
							mean(rt[mask_response_p1]), 
							100.0*count(x->x==true, mask_corr_cue2)/count(x -> x == true, mask_corr_cue2 .| mask_incorr_cue2), 
							100.0*count(x->x==true, mask_corr_cue1)/count(x -> x == true, mask_corr_cue1 .| mask_incorr_cue1), 
							100.0*count(x->x==true, mask_incorr_cue2)/count(x -> x == true, mask_corr_cue2 .| mask_incorr_cue2), 
							100.0*count(x->x==true, mask_incorr_cue1)/count(x -> x == true, mask_corr_cue1 .| mask_incorr_cue1),
							100.0*count(x -> x == true, mask_response_p2)/count(x -> x == true, mask_response_p1 .| mask_response_p2), 
							100.0*count(x -> x == true, mask_response_p1)/count(x -> x == true, mask_response_p1 .| mask_response_p2), 
							(count(x -> x == true, mask_response_p2) - count(x -> x == true, mask_response_p1))/
							count(x -> x == true, mask_response_p1 .| mask_response_p2),
							100.0*count(x->x==true, mask_om_cue2)/count(x->x==2, tone), 
							100.0*count(x->x==true, mask_om_cue1)/count(x->x==8, tone), 
							100.0*count(x -> x == true, mask_om_p)/count(x->x==-1,tone), 
							100.0*count(x->x==true, mask_prem)/(subj_m[end,1]+1)] ;

	else
		response[mask_corr_cue1 .| mask_incorr_cue2 .| mask_response_p1] .= 2 ; 
		response[mask_corr_cue2 .| mask_incorr_cue1 .| mask_response_p2] .= 8 ; 

		response[map(x -> x != 0, subj_m[:, 13])] .= 2 ;
		response[map(x -> x != 0, subj_m[:, 14])] .= 8 ;

		tone[mask_corr_cue1 .| mask_incorr_cue1 .| mask_om_cue1] .= 2 ;
		tone[mask_corr_cue2 .| mask_incorr_cue2 .| mask_om_cue2] .= 8 ;
		tone[mask_response_p1 .| mask_response_p2 .| mask_om_p] .= -1 ; 

		rt[map(x -> x == 2, tone)] = (subj_m[map(x -> x == 2, tone), 18] - 
									subj_m[map(x -> x == 2, tone), 17]) / 100.0 ;
		rt[map(x -> x == 8, tone)] = (subj_m[map(x -> x == 8, tone), 22] - 
									subj_m[map(x -> x == 8, tone), 21]) / 100.0 ;
		rt[map(x -> x == -1, tone)] = (subj_m[map(x -> x == -1, tone), 24] - 
									subj_m[map(x -> x == -1, tone), 23]) / 100.0 ;

		mask_rt_crit = map((x,y) -> x > rt_criterion || y == true, rt, mask_prem) ;
		rt = rt[mask_rt_crit] ;
		tone = tone[mask_rt_crit] ;
		response = response[mask_rt_crit] ;
		reward = reward[mask_rt_crit] ;
		mask_corr_cue1 = mask_corr_cue1[mask_rt_crit] ;
		mask_corr_cue2 = mask_corr_cue2[mask_rt_crit] ;
		mask_incorr_cue1 = mask_incorr_cue1[mask_rt_crit] ;
		mask_incorr_cue2 = mask_incorr_cue2[mask_rt_crit] ;
		mask_om_cue1 = mask_om_cue1[mask_rt_crit] ;
		mask_om_cue2 = mask_om_cue2[mask_rt_crit] ;
		mask_prem = mask_prem[mask_rt_crit] ;
		mask_response_p1 = mask_response_p1[mask_rt_crit] ;
		mask_response_p2 = mask_response_p2[mask_rt_crit] ;
		mask_om_p = mask_om_p[mask_rt_crit] ;

		write_v[2:end] = [mean(rt[mask_corr_cue1]), 
							mean(rt[mask_corr_cue2]), 
							mean(rt[mask_incorr_cue1]), 
							mean(rt[mask_incorr_cue2]),
							mean(rt[mask_response_p1]), 
							mean(rt[mask_response_p2]),  
							100.0*count(x->x==true, mask_corr_cue1)/count(x -> x == true, mask_corr_cue1 .| mask_incorr_cue1), 
							100.0*count(x->x==true, mask_corr_cue2)/count(x -> x == true, mask_corr_cue2 .| mask_incorr_cue2), 
							100.0*count(x->x==true, mask_incorr_cue1)/count(x -> x == true, mask_corr_cue1 .| mask_incorr_cue1), 
							100.0*count(x->x==true, mask_incorr_cue2)/count(x -> x == true, mask_corr_cue2 .| mask_incorr_cue2),
							100.0*count(x -> x == true, mask_response_p1)/count(x -> x == true, mask_response_p1 .| mask_response_p2), 
							100.0*count(x -> x == true, mask_response_p2)/count(x -> x == true, mask_response_p1 .| mask_response_p2), 
							(count(x -> x == true, mask_response_p1) - count(x -> x == true, mask_response_p2))/
							count(x -> x == true, mask_response_p1 .| mask_response_p2),
							100.0*count(x->x==true, mask_om_cue1)/count(x->x==2, tone), 
							100.0*count(x->x==true, mask_om_cue2)/count(x->x==8, tone), 
							100.0*count(x -> x == true, mask_om_p)/count(x->x==-1,tone), 
							100.0*count(x->x==true, mask_prem)/(subj_m[end,1]+1)] ;
	end

	rt[mask_om_cue1 .| mask_om_cue2 .| mask_om_p] .= rt_max_new ;
	
	return subj_t(subj_id, 
				response, 
				reward, 
				tone, 
				rt, 
				write_v[14]) , write_v

end