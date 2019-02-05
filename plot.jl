using XLSX, DataFrames, PyPlot , CSV, HypothesisTests

struct probe_data
	cbi::Array{Float64,2}
	om_H::Array{Float64,2}
	om_M::Array{Float64,2}
	om_L::Array{Float64,2}
	prem::Array{Float64,2}
	HH::Array{Float64,2}
	MH::Array{Float64,2}
	LH::Array{Float64,2}
	MH_RT::Array{Float64,2}
	ML_RT::Array{Float64,2}
end

function read_probe_data(file_vec::Array{String}, path::String, is_drug_study::Bool, cb_sym::Symbol)

	i = 1 ;
	if is_drug_study && length(file_vec) == 4
		cbi = zeros(16, 1) ;
		om_H = zeros(16, 1) ;
		om_M = zeros(16, 1) ;
		om_L = zeros(16, 1) ;
		prem = zeros(16, 1) ;
		HH = zeros(16, 1) ;
		MH = zeros(16, 1) ;
		LH = zeros(16, 1) ;
		MH_RT = zeros(16, 1) ;
		ML_RT = zeros(16, 1) ;

		for file in file_vec
			XLSX.openxlsx(string(path,file)) do xf

				sheets = XLSX.sheetnames(xf) ;
				df = DataFrame(XLSX.readtable(string(path,file), sheets[end])...) ;

				cb_idx = find(x -> x == cb_sym, CB_4[:,i]) ;

				cbi[cb_idx] = df[:CBI][cb_idx] ;
				om_H[cb_idx] = df[:Om_H][cb_idx] ;
				om_M[cb_idx] = df[:Om_M][cb_idx] ;
				om_L[cb_idx] = df[:Om_L][cb_idx] ;
				prem[cb_idx] = df[:Prem][cb_idx] ;
				HH[cb_idx] = df[:HH_p][cb_idx] ;
				MH[cb_idx] = df[:MH_p][cb_idx] ;
				LH[cb_idx] = df[:LH_p][cb_idx] ;
				MH_RT[cb_idx] = df[:MH_RT][cb_idx] ;
				ML_RT[cb_idx] = df[:ML_RT][cb_idx] ;
			end

			i += 1 ;
		end

	elseif is_drug_study && length(file_vec) == 2
		cbi = zeros(16, 1) ;
		om_H = zeros(16, 1) ;
		om_M = zeros(16, 1) ;
		om_L = zeros(16, 1) ;
		prem = zeros(16, 1) ;
		HH = zeros(16, 1) ;
		MH = zeros(16, 1) ;
		LH = zeros(16, 1) ;
		MH_RT = zeros(16, 1) ;
		ML_RT = zeros(16, 1) ;

		for file in file_vec
			XLSX.openxlsx(string(path,file)) do xf

				sheets = XLSX.sheetnames(xf) ;
				df = DataFrame(XLSX.readtable(string(path,file), sheets[end])...) ;

				cb_idx = find(x -> x == cb_sym, CB_2[:,i]) ;

				cbi[cb_idx] = df[:CBI][cb_idx] ;
				om_H[cb_idx] = df[:Om_H][cb_idx] ;
				om_M[cb_idx] = df[:Om_M][cb_idx] ;
				om_L[cb_idx] = df[:Om_L][cb_idx] ;
				prem[cb_idx] = df[:Prem][cb_idx] ;
				HH[cb_idx] = df[:HH_p][cb_idx] ;
				MH[cb_idx] = df[:MH_p][cb_idx] ;
				LH[cb_idx] = df[:LH_p][cb_idx] ;
				MH_RT[cb_idx] = df[:MH_RT][cb_idx] ;
				ML_RT[cb_idx] = df[:ML_RT][cb_idx] ;

			end

			i += 1 ;
		end

	elseif is_drug_study 
		println("Invalid number of files for drug study \n")

	elseif	~is_drug_study

		cbi = zeros(16, length(file_vec)) ;
		om_H = zeros(16, length(file_vec)) ;
		om_M = zeros(16, length(file_vec)) ;
		om_L = zeros(16, length(file_vec)) ;
		prem = zeros(16, length(file_vec)) ;
		HH = zeros(16, length(file_vec)) ;
		MH = zeros(16, length(file_vec)) ;
		LH = zeros(16, length(file_vec)) ;
		MH_RT = zeros(16, length(file_vec)) ;
		ML_RT = zeros(16, length(file_vec)) ;

		for file in file_vec
			XLSX.openxlsx(string(path,file)) do xf

				sheets = XLSX.sheetnames(xf) ;
				df = DataFrame(XLSX.readtable(string(path,file), sheets[end])...) ;

				cbi[:,i] = df[:CBI][:] ;
				om_H[:,i] = df[:Om_H][:] ;
				om_M[:,i] = df[:Om_M][:] ;
				om_L[:,i] = df[:Om_L][:] ;
				prem[:,i] = df[:Prem][:] ;
				HH[:,i] = df[:HH_p][:] ;
				MH[:,i] = df[:MH_p][:] ;
				LH[:,i] = df[:LH_p][:] ;
				MH_RT[:,i] = df[:MH_RT][:] ;
				ML_RT[:,i] = df[:ML_RT][:] ;
			end

			i += 1 ;
		end
	end

	return probe_data(cbi, om_H, om_M, om_L, prem, HH, MH, LH, MH_RT, ML_RT)
end

function plot_seq_amb(df::DataFrame, red_rgb::Array{Float64,2}, blue_rgb::Array{Float64,2}, n_subject_dt::Float64)

	x_ticks = 2:2:16 ;
	point_sz = 100 ; 

	figure()
	subplot(211)
	j = 1 ;
	for i = [1, 2, 6, 7, 11, 12, 15, 16]

		x_amb_I = fill(x_ticks[j] - 0.1, Int64(n_subject_dt)) ;
		x_amb_II = fill(x_ticks[j] + 0.1, Int64(n_subject_dt)) ;

		if i == 16
			scatter(x_amb_I, df[:Cor_Amb_4_RT][end:-16:i], c = red_rgb[end:-1:1,:], label = "High reward", s = point_sz)
			scatter(x_amb_II, df[:Cor_Amb_1_RT][end:-16:i], c = blue_rgb[end:-1:1,:], label = "Low reward", s = point_sz)
		else
			scatter(x_amb_I, df[:Cor_Amb_4_RT][i:16:end], c = red_rgb, s = point_sz)
			scatter(x_amb_II, df[:Cor_Amb_1_RT][i:16:end], c = blue_rgb, s = point_sz)
		end

		j += 1 ;
	end
	legend()
	xticks(x_ticks, [string(i) for i in [1, 2, 6, 7, 11, 12, 15, 16]])
	xlabel("Subject ID", fontsize = 14)
	ylabel("Correct response RΤ [sec]", fontsize = 14)
	title("Hard pattern", fontsize = 14)


	subplot(212)
	j = 1 ;
	for i = [3, 4, 5, 8, 9, 10, 13, 14]

		x_amb_I = fill(x_ticks[j] - 0.1, Int64(n_subject_dt)) ;
		x_amb_II = fill(x_ticks[j] + 0.1, Int64(n_subject_dt)) ;

		if i == 14
			scatter(x_amb_I, df[:Cor_Amb_4_RT][end:-16:i], c = red_rgb[end:-1:1,:], label = "High reward", s = point_sz)
			scatter(x_amb_II, df[:Cor_Amb_1_RT][end:-16:i], c = blue_rgb[end:-1:1,:], label = "Low reward", s = point_sz)
		else
			scatter(x_amb_I, df[:Cor_Amb_4_RT][i:16:end], c = red_rgb, s = point_sz)
			scatter(x_amb_II, df[:Cor_Amb_1_RT][i:16:end], c = blue_rgb, s = point_sz)
		end

		j += 1 ;
	end
	legend()
	xticks(x_ticks, [string(i) for i in [3, 4, 5, 8, 9, 10, 13, 14]])
	xlabel("Subject ID", fontsize = 14)
	ylabel("Correct response RT [sec]", fontsize = 14)
	title("Easy pattern", fontsize = 14)

	figure()
	subplot(211)
	j = 1 ;
	for i = [1, 2, 6, 7, 11, 12, 15, 16]

		x_amb_I = fill(x_ticks[j] - 0.1, Int64(n_subject_dt)) ;
		x_amb_II = fill(x_ticks[j] + 0.1, Int64(n_subject_dt)) ;

		if i == 16
			scatter(x_amb_I, df[:Incor_Amb_4_RT][end:-16:i], c = red_rgb[end:-1:1,:], label = "High reward", s = point_sz)
			scatter(x_amb_II, df[:Incor_Amb_1_RT][end:-16:i], c = blue_rgb[end:-1:1,:], label = "Low reward", s = point_sz)
		else
			scatter(x_amb_I, df[:Incor_Amb_4_RT][i:16:end], c = red_rgb, s = point_sz)
			scatter(x_amb_II, df[:Incor_Amb_1_RT][i:16:end], c = blue_rgb, s = point_sz)
		end

		j += 1 ;
	end
	legend()
	xticks(x_ticks, [string(i) for i in [1, 2, 6, 7, 11, 12, 15, 16]])
	xlabel("Subject ID", fontsize = 14)
	ylabel("Incorrect response RΤ [sec]", fontsize = 14)
	title("Hard pattern", fontsize = 14)


	subplot(212)
	j = 1 ;
	for i = [3, 4, 5, 8, 9, 10, 13, 14]

		x_amb_I = fill(x_ticks[j] - 0.1, Int64(n_subject_dt)) ;
		x_amb_II = fill(x_ticks[j] + 0.1, Int64(n_subject_dt)) ;

		if i == 14
			scatter(x_amb_I, df[:Incor_Amb_4_RT][end:-16:i], c = red_rgb[end:-1:1,:], label = "High reward", s = point_sz)
			scatter(x_amb_II, df[:Incor_Amb_1_RT][end:-16:i], c = blue_rgb[end:-1:1,:], label = "Low reward", s = point_sz)
		else
			scatter(x_amb_I, df[:Incor_Amb_4_RT][i:16:end], c = red_rgb, s = point_sz)
			scatter(x_amb_II, df[:Incor_Amb_1_RT][i:16:end], c = blue_rgb, s = point_sz)
		end

		j += 1 ;
	end
	legend()
	xticks(x_ticks, [string(i) for i in [3, 4, 5, 8, 9, 10, 13, 14]])
	xlabel("Subject ID", fontsize = 14)
	ylabel("Incorrect response RT [sec]", fontsize = 14)
	title("Easy pattern", fontsize = 14)


	figure()
	subplot(211)
	j = 1 ;
	for i = [1, 2, 6, 7, 11, 12, 15, 16]

		x_amb_I = fill(x_ticks[j] - 0.1, Int64(n_subject_dt)) ;
		x_amb_II = fill(x_ticks[j] + 0.1, Int64(n_subject_dt)) ;

		if i == 16
			scatter(x_amb_I, df[:Cor_Amb_4][end:-16:i], c = red_rgb[end:-1:1,:], label = "High reward", s = point_sz)
			scatter(x_amb_II, df[:Cor_Amb_1][end:-16:i], c = blue_rgb[end:-1:1,:], label = "Low reward", s = point_sz)
		else
			scatter(x_amb_I, df[:Cor_Amb_4][i:16:end], c = red_rgb, s = point_sz)
			scatter(x_amb_II, df[:Cor_Amb_1][i:16:end], c = blue_rgb, s = point_sz)
		end

		j += 1 ;
	end
	legend()
	xticks(x_ticks, [string(i) for i in [1, 2, 6, 7, 11, 12, 15, 16]])
	xlabel("Subject ID", fontsize = 14)
	ylabel("Correct responses [%]", fontsize = 14)
	title("Hard pattern", fontsize = 14)

	subplot(212)
	j = 1 ;
	for i = [3, 4, 5, 8, 9, 10, 13, 14]

		x_amb_I = fill(x_ticks[j] - 0.1, Int64(n_subject_dt)) ;
		x_amb_II = fill(x_ticks[j] + 0.1, Int64(n_subject_dt)) ;

		if i == 14
			scatter(x_amb_I, df[:Cor_Amb_4][end:-16:i], c = red_rgb[end:-1:1,:], label = "High reward", s = point_sz)
			scatter(x_amb_II, df[:Cor_Amb_1][end:-16:i], c = blue_rgb[end:-1:1,:], label = "Low reward", s = point_sz)
		else
			scatter(x_amb_I, df[:Cor_Amb_4][i:16:end], c = red_rgb, s = point_sz)
			scatter(x_amb_II, df[:Cor_Amb_1][i:16:end], c = blue_rgb, s = point_sz)
		end

		j += 1 ;
	end
	legend()
	xticks(x_ticks, [string(i) for i in [3, 4, 5, 8, 9, 10, 13, 14]])
	xlabel("Subject ID", fontsize = 14)
	ylabel("Correct responses [%]", fontsize = 14)
	title("Easy pattern", fontsize = 14)

	figure()
	subplot(211)
	j = 1 ;
	for i = [1, 2, 6, 7, 11, 12, 15, 16]

		x_amb_I = fill(x_ticks[j] - 0.1, Int64(n_subject_dt)) ;
		x_amb_II = fill(x_ticks[j] + 0.1, Int64(n_subject_dt)) ;

		if i == 16
			scatter(x_amb_I, df[:Incor_Amb_4][end:-16:i], c = red_rgb[end:-1:1,:], label = "High reward", s = point_sz)
			scatter(x_amb_II, df[:Incor_Amb_1][end:-16:i], c = blue_rgb[end:-1:1,:], label = "Low reward", s = point_sz)
		else
			scatter(x_amb_I, df[:Incor_Amb_4][i:16:end], c = red_rgb, s = point_sz)
			scatter(x_amb_II, df[:Incor_Amb_1][i:16:end], c = blue_rgb, s = point_sz)
		end

		j += 1 ;
	end
	legend()
	xticks(x_ticks, [string(i) for i in [1, 2, 6, 7, 11, 12, 15, 16]])
	xlabel("Subject ID", fontsize = 14)
	ylabel("Incorrect responses [%]", fontsize = 14)
	title("Hard pattern", fontsize = 14)

	subplot(212)
	j = 1 ;
	for i = [3, 4, 5, 8, 9, 10, 13, 14]

		x_amb_I = fill(x_ticks[j] - 0.1, Int64(n_subject_dt)) ;
		x_amb_II = fill(x_ticks[j] + 0.1, Int64(n_subject_dt)) ;

		if i == 14
			scatter(x_amb_I, df[:Incor_Amb_4][end:-16:i], c = red_rgb[end:-1:1,:], label = "High reward", s = point_sz)
			scatter(x_amb_II, df[:Incor_Amb_1][end:-16:i], c = blue_rgb[end:-1:1,:], label = "Low reward", s = point_sz)
		else
			scatter(x_amb_I, df[:Incor_Amb_4][i:16:end], c = red_rgb, s = point_sz)
			scatter(x_amb_II, df[:Incor_Amb_1][i:16:end], c = blue_rgb, s = point_sz)
		end
		j += 1 ;
	end
	legend()
	xticks(x_ticks, [string(i) for i in [3, 4, 5, 8, 9, 10, 13, 14]])
	xlabel("Subject ID", fontsize = 14)
	ylabel("Incorrect responses [%]", fontsize = 14)
	title("Easy pattern", fontsize = 14)

	show()
end

function plot_seq_timeline(dt_type::Symbol)

	n_t1v1 = 11 ;
	n_t4v1 = 8 ;
	n_seq = 20 ;

	t1v1_files = Array{String,2}(16, n_t1v1) ;
	t4v1_files = Array{String,2}(16, n_t4v1) ;
	seq_files = Array{String,2}(16, n_seq) ;
	last_4_t4v1_files = fill("", 16, 4) ;

	t1v1_cor4_dt = Array{Float64,2}(16, n_t1v1) ;
	t4v1_cor4_dt = Array{Float64,2}(16, n_t4v1) ;
	seq_cor4_dt = Array{Float64,2}(16, n_seq) ;
	last_4_t4v1_cor4_dt = fill(0.0, 16, 4) ;

	t1v1_cor1_dt = Array{Float64,2}(16, n_t1v1) ;
	t4v1_cor1_dt = Array{Float64,2}(16, n_t4v1) ;
	seq_cor1_dt = Array{Float64,2}(16, n_seq) ;
	last_4_t4v1_cor1_dt = fill(0.0, 16, 4) ;

	t1v1_idx = ones(Int64,16) ;
	t4v1_idx = ones(Int64,16) ;
	seq_idx = ones(Int64,16) ;

	path = "./results/"
	file_vec = date_sort(filter(x->contains(x,".xlsx"), readdir(path))) ;

	header_vec = train_header_vec ;
	col_type_vec = fill(Any, length(header_vec)) ;

	#df = DataFrame(col_type_vec, [parse(i) for i in header_vec], 0) ;

	if dt_type == :acc
		dt_sym_4 = :Cor_4 ;
		dt_sym_1 = :Cor_1 ;
	elseif dt_type == :RT
		dt_sym_4 = :Cor_4_RT ;
		dt_sym_1 = :Cor_1_RT ;
	elseif dt_type == :RT_incor
		dt_sym_4 = :Incor_4_RT ;
		dt_sym_1 = :Incor_1_RT ;
	else
		println("Invalid data type to plot")
	end

	for file in file_vec

		XLSX.openxlsx(string(path,file)) do xf

			sheets = XLSX.sheetnames(xf) ;
			df = DataFrame(XLSX.readtable(string(path,file), sheets[1])...) ;
			#append!(df, DataFrame(XLSX.readtable(string(path,file), sheets[1])...)) ;
			sessions = df[:Session] ;

			for i = 1 : length(sessions)

				mod(i,16) == 0 ? idx = 16 : idx = mod(i,16)

				if sessions[i] == "t1v1" && t1v1_idx[idx] <= n_t1v1
					t1v1_files[idx, t1v1_idx[idx]] = file ;
					t1v1_cor4_dt[idx, t1v1_idx[idx]] = df[dt_sym_4][i] ;
					t1v1_cor1_dt[idx, t1v1_idx[idx]] = df[dt_sym_1][i] ;
					t1v1_idx[idx] += 1 ;

				elseif sessions[i] == "t4v1" && t4v1_idx[idx] <= n_t4v1
					t4v1_files[idx, t4v1_idx[idx]] = file ;
					t4v1_cor4_dt[idx, t4v1_idx[idx]] = df[dt_sym_4][i] ;
					t4v1_cor1_dt[idx, t4v1_idx[idx]] = df[dt_sym_1][i] ;
					t4v1_idx[idx] += 1 ;

					last_4_t4v1_files[idx,:] = circshift(last_4_t4v1_files[idx,:], -1) ;
					last_4_t4v1_files[idx, 4] = file ;

					last_4_t4v1_cor4_dt[idx,:] = circshift(last_4_t4v1_cor4_dt[idx,:], -1) ;
					last_4_t4v1_cor4_dt[idx, 4] = df[dt_sym_4][i] ;

					last_4_t4v1_cor1_dt[idx,:] = circshift(last_4_t4v1_cor1_dt[idx,:], -1) ;
					last_4_t4v1_cor1_dt[idx, 4] = df[dt_sym_1][i] ;
				elseif sessions[i] == "seq" && seq_idx[idx] <= n_seq
					seq_files[idx, seq_idx[idx]] = file ;
					seq_cor4_dt[idx, seq_idx[idx]] = df[dt_sym_4][i] ;
					seq_cor1_dt[idx, seq_idx[idx]] = df[dt_sym_1][i] ;
					seq_idx[idx] += 1 ;
				end
			end
		end
	end

	t4v1_files[:,5:8] = last_4_t4v1_files ;
	t4v1_cor4_dt[:,5:8] = last_4_t4v1_cor4_dt ;
	t4v1_cor1_dt[:,5:8] = last_4_t4v1_cor1_dt ;

	easy_cor4_dt = Array{Any}(n_t1v1 + n_t4v1 + n_seq) ;
	hard_cor4_dt = Array{Any}(n_t1v1 + n_t4v1 + n_seq) ;

	easy_cor1_dt = Array{Any}(n_t1v1 + n_t4v1 + n_seq) ;
	hard_cor1_dt = Array{Any}(n_t1v1 + n_t4v1 + n_seq) ;

	easy_idx = [3,4,5,8,9,10,13,14] ;
	hard_idx = [1,2,6,7,11,12,15,16] ;

	easy_cor4_dt[1:n_t1v1] = [t1v1_cor4_dt[easy_idx,i] for i = 1 : n_t1v1] ;
	easy_cor4_dt[n_t1v1 + 1 : n_t1v1 + n_t4v1] = [t4v1_cor4_dt[easy_idx,i] for i = 1 : n_t4v1] ;
	easy_cor4_dt[n_t1v1 + n_t4v1 + 1 : n_t1v1 + n_t4v1 + n_seq] = [seq_cor4_dt[easy_idx,i] for i = 1 : n_seq] ;

	hard_cor4_dt[1:n_t1v1] = [t1v1_cor4_dt[hard_idx,i] for i = 1 : n_t1v1] ;
	hard_cor4_dt[n_t1v1 + 1 : n_t1v1 + n_t4v1] = [t4v1_cor4_dt[hard_idx,i] for i = 1 : n_t4v1] ;
	hard_cor4_dt[n_t1v1 + n_t4v1 + 1 : n_t1v1 + n_t4v1 + n_seq] = [seq_cor4_dt[hard_idx,i] for i = 1 : n_seq] ;

	easy_cor1_dt[1:n_t1v1] = [t1v1_cor1_dt[easy_idx,i] for i = 1 : n_t1v1] ;
	easy_cor1_dt[n_t1v1 + 1 : n_t1v1 + n_t4v1] = [t4v1_cor1_dt[easy_idx,i] for i = 1 : n_t4v1] ;
	easy_cor1_dt[n_t1v1 + n_t4v1 + 1 : n_t1v1 + n_t4v1 + n_seq] = [seq_cor1_dt[easy_idx,i] for i = 1 : n_seq] ;

	hard_cor1_dt[1:n_t1v1] = [t1v1_cor1_dt[hard_idx,i] for i = 1 : n_t1v1] ;
	hard_cor1_dt[n_t1v1 + 1 : n_t1v1 + n_t4v1] = [t4v1_cor1_dt[hard_idx,i] for i = 1 : n_t4v1] ;
	hard_cor1_dt[n_t1v1 + n_t4v1 + 1 : n_t1v1 + n_t4v1 + n_seq] = [seq_cor1_dt[hard_idx,i] for i = 1 : n_seq] ;

	easy_cor4_means = [mean(easy_cor4_dt[i]) for i = 1 : length(easy_cor4_dt)] ;
	hard_cor4_means = [mean(hard_cor4_dt[i]) for i = 1 : length(hard_cor4_dt)] ;
	easy_cor1_means = [mean(easy_cor1_dt[i]) for i = 1 : length(easy_cor1_dt)] ;
	hard_cor1_means = [mean(hard_cor1_dt[i]) for i = 1 : length(hard_cor1_dt)] ;

	figure()
	ax = axes()

	errorbar(1:length(easy_cor4_dt), easy_cor4_means, fmt = "C0D", markersize = 10,
		yerr = [std(easy_cor4_dt[i]) for i = 1 : length(easy_cor4_dt)], label = "EP - HR")
	errorbar(1:length(hard_cor4_dt), hard_cor4_means, fmt = "C1D", markersize = 10,
		yerr = [std(hard_cor4_dt[i]) for i = 1 : length(hard_cor4_dt)], label = "HP - HR")
	errorbar(1:length(easy_cor1_dt), easy_cor1_means, fmt = "C2D", markersize = 10,
		yerr = [std(easy_cor1_dt[i]) for i = 1 : length(easy_cor1_dt)], label = "EP - LR")
	errorbar(1:length(hard_cor1_dt), hard_cor1_means, fmt = "C3D", markersize = 10,
		yerr = [std(hard_cor1_dt[i]) for i = 1 : length(hard_cor1_dt)], label = "HP - LR")

	xtick_s = Array{String}(n_t1v1 + n_t4v1 + n_seq) ;
	xtick_s[1:n_t1v1] = [string(i) for i = 1:n_t1v1] ;
	xtick_s[n_t1v1 + 1 : n_t1v1 + n_t4v1] = [string(i) for i = 1:n_t4v1] ;
	xtick_s[n_t1v1 + n_t4v1 + 1 : end] = [string(i) for i = 1:n_seq] ;

	ax[:set_xticks](1:length(easy_cor4_dt), minor = true)
	ax[:set_xticks]([Int64(floor(n_t1v1/2)), Int64(floor(n_t1v1 + n_t4v1/2)), Int64(floor(n_t1v1 + n_t4v1 + n_seq/2))]);
	ax[:set_xticklabels](xtick_s, minor = true)
	ax[:set_xticklabels](["\n 1 vs 1", "\n 4 vs 1", "\n Sequence"])

	ax[:tick_params]("x", which = "major", labelsize = 22)

	legend()
	xlabel("Training sessions", fontsize = 22)
	ylabel("Response time [sec]", fontsize = 22)
	title("Timeline of response times over training stages", fontsize =22)

	y_lim = ax[:get_ylim]() ;
	plot([n_t1v1, n_t1v1], y_lim, "k--")
	plot([n_t1v1 + n_t4v1, n_t1v1 + n_t4v1], y_lim, "k--")
	#bp = boxplot(easy_cor4_dt,0,"", whis = [5, 95], showbox = false, patch_artist = true, whiskerprops = Dict("color" => "C0"))
	#bp = boxplot(hard_cor4_dt,0,"", showbox = false, patch_artist = true, whiskerprops = Dict("color" => "C1"))
	#bp = boxplot(easy_cor1_dt,0,"", showbox = false, patch_artist = true, whiskerprops = Dict("color" => "C2"))
	#bp = boxplot(hard_cor1_dt,0,"", showbox = false, patch_artist = true, whiskerprops = Dict("color" => "C3"))

	figure()
	for i = 1 : 8
		#
		plot(1:length(easy_cor4_dt), )

	end

	show()
end

function plot_drug_cb2()

	path = "./ket/" ;

	file_vec = date_sort(filter(x->contains(x,".xlsx"), readdir(path))) ;

	veh_cbi = zeros(16) ;
	veh_om_H = zeros(16) ;
	veh_om_M = zeros(16) ;
	veh_om_L = zeros(16) ;
	veh_prem = zeros(16) ;
	veh_HH_RT = zeros(16) ;
	veh_LL_RT = zeros(16) ;
	veh_M_RT = zeros(16) ; 

	ket_cbi = zeros(16, size(CB_2,2) - 1) ;
	ket_om_H = zeros(16, size(CB_2,2) - 1) ; 
	ket_om_M = zeros(16, size(CB_2,2) - 1) ; 
	ket_om_L = zeros(16, size(CB_2,2) - 1) ; 
	ket_prem = zeros(16, size(CB_2,2) - 1) ; 
	ket_HH_RT = zeros(16, size(CB_2,2) - 1) ;
	ket_LL_RT = zeros(16, size(CB_2,2) - 1) ;
	ket_M_RT = zeros(16, size(CB_2,2) - 1) ;

	i = 1 ;
	for file in file_vec

		XLSX.openxlsx(string(path,file)) do xf

			sheets = XLSX.sheetnames(xf) ;
			df = DataFrame(XLSX.readtable(string(path,file), sheets[end])...) ;

			A_idx = find(x -> x == :A, CB_2[:,i]) ;
			B_idx = find(x -> x == :B, CB_2[:,i]) ;

			veh_cbi[A_idx] = df[:CBI][A_idx] ;
			ket_cbi[B_idx] = df[:CBI][B_idx] ;

			veh_om_H[A_idx] = df[:Om_H][A_idx] ;
			ket_om_H[B_idx,1] = df[:Om_H][B_idx] ;

			veh_om_M[A_idx] = df[:Om_M][A_idx] ;
			ket_om_M[B_idx,1] = df[:Om_M][B_idx] ;

			veh_om_L[A_idx] = df[:Om_L][A_idx] ;
			ket_om_L[B_idx,1] = df[:Om_L][B_idx] ;

			veh_prem[A_idx] = df[:Prem][A_idx] ;
			ket_prem[B_idx,1] = df[:Prem][B_idx] ;

			veh_HH_RT[A_idx] = df[:HH_RT][A_idx] ;
			ket_HH_RT[B_idx] = df[:HH_RT][B_idx] ;

			veh_M_RT[A_idx] = df[:M_RT][A_idx] ;
			ket_M_RT[B_idx] = df[:M_RT][B_idx] ;

			veh_LL_RT[A_idx] = df[:LL_RT][A_idx] ;
			ket_LL_RT[B_idx] = df[:LL_RT][B_idx] ;
		end

		i += 1 ;
	end

	excl_idx = [1,2,3,4,5,6,7,8,9,11,12,13,15,16] ;

	figure()
	ax = axes()

	bar(1.0, mean(veh_cbi[excl_idx]), width = 0.35, yerr = std(veh_cbi[excl_idx]), capsize = 10)

	bar(2.0, mean(ket_cbi[excl_idx]), width = 0.35, yerr = std(ket_cbi[excl_idx]), capsize = 10)

	axhline(linewidth=1, c = "k")

	ax[:set_xticks]([1.0, 2.0])
	ax[:set_xticklabels]([ "Vehicle" ,"Ketamine"])
	ax[:tick_params](labelsize = 14)

	ylabel("CBI", fontsize = 14)

	figure()
	ax = axes()

	b1 = bar(0.9, mean(veh_HH_RT[excl_idx]), width = 0.2, yerr = std(veh_HH_RT[excl_idx]), capsize = 10, color = "r")
	b2 = bar(1.1, mean(veh_M_RT[excl_idx]), width = 0.2, yerr = std(veh_M_RT[excl_idx]), capsize = 10, color = "g")
	b3 = bar(1.3, mean(veh_LL_RT[excl_idx]), width = 0.2, yerr = std(veh_LL_RT[excl_idx]), capsize = 10, color = "b")

	bar(1.9, mean(ket_HH_RT[excl_idx]), width = 0.2, yerr = std(ket_HH_RT[excl_idx]), capsize = 10, color = "r")
	bar(2.1, mean(ket_M_RT[excl_idx]), width = 0.2, yerr = std(ket_M_RT[excl_idx]), capsize = 10, color = "g")
	bar(2.3, mean(ket_LL_RT[excl_idx]), width = 0.2, yerr = std(ket_LL_RT[excl_idx]), capsize = 10, color = "b")

	axhline(linewidth=1, c = "k")

	ax[:set_xticks]([1.1, 2.1])
	ax[:set_xticklabels]([ "Vehicle" ,"Ketamine"])
	ax[:tick_params](labelsize = 14)

	ylabel("Response time [sec]", fontsize = 14)
	legend([b1, b2, b3], ["High correct", "Mid", "Low correct"], fontsize = 14)

	figure()
	ax = axes()

	b1 = bar(0.9, mean(veh_om_H[excl_idx]), width = 0.2, yerr = std(veh_om_H[excl_idx]), capsize = 10, color = "r")
	b2 = bar(1.1, mean(veh_om_M[excl_idx]), width = 0.2, yerr = std(veh_om_M[excl_idx]), capsize = 10, color = "g")
	b3 = bar(1.3, mean(veh_om_L[excl_idx]), width = 0.2, yerr = std(veh_om_L[excl_idx]), capsize = 10, color = "b")

	bar(1.9, mean(ket_om_H[excl_idx]), width = 0.2, yerr = std(ket_om_H[excl_idx]), capsize = 10, color = "r")
	bar(2.1, mean(ket_om_M[excl_idx]), width = 0.2, yerr = std(ket_om_M[excl_idx]), capsize = 10, color = "g")
	bar(2.3, mean(ket_om_L[excl_idx]), width = 0.2, yerr = std(ket_om_L[excl_idx]), capsize = 10, color = "b")

	axhline(linewidth=1, c = "k")

	ax[:set_xticks]([1.1, 2.1])
	ax[:set_xticklabels]([ "Vehicle" ,"Ketamine"])
	ax[:tick_params](labelsize = 14)

	ylabel("Omissions [%]", fontsize = 14)
	legend([b1, b2, b3], ["High", "Mid", "Low"], fontsize = 14)

	figure()
	ax = axes()

	bar(1.0, mean(veh_prem[excl_idx]), width = 0.35, yerr = std(veh_prem[excl_idx]), capsize = 10)

	bar(2.0, mean(ket_prem[excl_idx]), width = 0.35, yerr = std(ket_prem[excl_idx]), capsize = 10)

	axhline(linewidth=1, c = "k")

	ax[:set_xticks]([1.0, 2.0])
	ax[:set_xticklabels]([ "Vehicle" ,"Ketamine"])
	ax[:tick_params](labelsize = 14)

	ylabel("Prematures", fontsize = 14)

	show()
end

function plot_drug_cb4()

	path = "./naltrexone/" ;

	file_vec = date_sort(filter(x->contains(x,".xlsx"), readdir(path))) ;

	x_offset = 0.25 ;

	x_high = fill(1.0, 16) ;
	x_mid = fill(3.0, 16) ;
	x_low = fill(5.0, 16) ;

	x_ticks = [fill(i,16) for i = 1 : size(CB_4,2)] ;

	veh_cbi = zeros(16) ;
	veh_om_H = zeros(16) ;
	veh_om_M = zeros(16) ;
	veh_om_L = zeros(16) ;
	veh_prem = zeros(16) ;
	veh_HH_RT = zeros(16) ;
	veh_M_RT = zeros(16) ;
	veh_LL_RT = zeros(16) ;

	drug_cbi = zeros(16, size(CB_4,2) - 1) ;
	drug_om_H = zeros(16, size(CB_4,2) - 1) ; 
	drug_om_M = zeros(16, size(CB_4,2) - 1) ; 
	drug_om_L = zeros(16, size(CB_4,2) - 1) ; 
	drug_prem = zeros(16, size(CB_4,2) - 1) ; 
	drug_HH_RT = zeros(16, size(CB_4,2) - 1) ;
	drug_M_RT = zeros(16, size(CB_4,2) - 1) ;
	drug_LL_RT = zeros(16, size(CB_4,2) - 1) ;

	i = 1 ;
	for file in file_vec

		XLSX.openxlsx(string(path,file)) do xf

			sheets = XLSX.sheetnames(xf) ;
			df = DataFrame(XLSX.readtable(string(path,file), sheets[end])...) ;

			A_idx = find(x -> x == :A, CB_4[:,i]) ;
			B_idx = find(x -> x == :B, CB_4[:,i]) ;
			C_idx = find(x -> x == :C, CB_4[:,i]) ;
			D_idx = find(x -> x == :D, CB_4[:,i]) ;

			veh_cbi[D_idx] = df[:CBI][D_idx] ;
			drug_cbi[A_idx,1] = df[:CBI][A_idx] ;
			drug_cbi[B_idx,2] = df[:CBI][B_idx] ;
			drug_cbi[C_idx,3] = df[:CBI][C_idx] ;

			veh_om_H[D_idx] = df[:Om_H][D_idx] ;
			drug_om_H[A_idx,1] = df[:Om_H][A_idx] ;
			drug_om_H[B_idx,2] = df[:Om_H][B_idx] ;
			drug_om_H[C_idx,3] = df[:Om_H][C_idx] ;

			veh_om_M[D_idx] = df[:Om_M][D_idx] ;
			drug_om_M[A_idx,1] = df[:Om_M][A_idx] ;
			drug_om_M[B_idx,2] = df[:Om_M][B_idx] ;
			drug_om_M[C_idx,3] = df[:Om_M][C_idx] ;

			veh_om_L[D_idx] = df[:Om_L][D_idx] ;
			drug_om_L[A_idx,1] = df[:Om_L][A_idx] ;
			drug_om_L[B_idx,2] = df[:Om_L][B_idx] ;
			drug_om_L[C_idx,3] = df[:Om_L][C_idx] ;

			veh_prem[D_idx] = df[:Prem][D_idx] ;
			drug_prem[A_idx,1] = df[:Prem][A_idx] ;
			drug_prem[B_idx,2] = df[:Prem][B_idx] ;
			drug_prem[C_idx,3] = df[:Prem][C_idx] ;

			veh_HH_RT[D_idx] = df[:HH_RT][D_idx] ;
			drug_HH_RT[A_idx,1] = df[:HH_RT][A_idx] ;
			drug_HH_RT[B_idx,2] = df[:HH_RT][B_idx] ;
			drug_HH_RT[C_idx,3] = df[:HH_RT][C_idx] ;

			veh_M_RT[D_idx] = df[:M_RT][D_idx] ;
			drug_M_RT[A_idx,1] = df[:M_RT][A_idx] ;
			drug_M_RT[B_idx,2] = df[:M_RT][B_idx] ;
			drug_M_RT[C_idx,3] = df[:M_RT][C_idx] ;

			veh_LL_RT[D_idx] = df[:LL_RT][D_idx] ;
			drug_LL_RT[A_idx,1] = df[:LL_RT][A_idx] ;
			drug_LL_RT[B_idx,2] = df[:LL_RT][B_idx] ;
			drug_LL_RT[C_idx,3] = df[:LL_RT][C_idx] ;
		end

		i = i + 1 ;
	end
	
	excl_idx = [1,2,3,4,5,6,7,8,9,11,12,13,15,16] ;

	figure()
	ax = axes()

	bar(1.0, mean(veh_cbi[excl_idx]), width = 0.35, yerr = std(veh_cbi[excl_idx]), capsize = 10)

	bar(2.0, mean(drug_cbi[excl_idx,1]), width = 0.35, yerr = std(drug_cbi[excl_idx,1]), capsize = 10)
	bar(3.0, mean(drug_cbi[excl_idx,2]), width = 0.35, yerr = std(drug_cbi[excl_idx,2]), capsize = 10)
	bar(4.0, mean(drug_cbi[excl_idx,3]), width = 0.35, yerr = std(drug_cbi[excl_idx,3]), capsize = 10)

	axhline(linewidth=1, c = "k")

	ax[:set_xticks]([1.0, 2.0, 3.0, 4.0])
	ax[:set_xticklabels]([ "Vehicle" ,"1.0 mg/kg", "3.0 mg/kg", "10.0 mg/kg"])
	ax[:tick_params](labelsize = 14)

	ylabel("CBI", fontsize = 14)

	figure()
	ax = axes()

	b1 = bar(0.9, mean(veh_HH_RT[excl_idx]), width = 0.2, yerr = std(veh_HH_RT[excl_idx]), capsize = 10, color = "r")
	b2 = bar(1.1, mean(veh_M_RT[excl_idx]), width = 0.2, yerr = std(veh_M_RT[excl_idx]), capsize = 10, color = "g")
	b3 = bar(1.3, mean(veh_LL_RT[excl_idx]), width = 0.2, yerr = std(veh_LL_RT[excl_idx]), capsize = 10, color = "b")

	bar(1.9, mean(drug_HH_RT[excl_idx,1]), width = 0.2, yerr = std(drug_HH_RT[excl_idx,1]), capsize = 10, color = "r")
	bar(2.1, mean(drug_M_RT[excl_idx,1]), width = 0.2, yerr = std(drug_M_RT[excl_idx,1]), capsize = 10, color = "g")
	bar(2.3, mean(drug_LL_RT[excl_idx,1]), width = 0.2, yerr = std(drug_LL_RT[excl_idx,1]), capsize = 10, color = "b")

	bar(2.9, mean(drug_HH_RT[excl_idx,2]), width = 0.2, yerr = std(drug_HH_RT[excl_idx,2]), capsize = 10, color = "r")
	bar(3.1, mean(drug_M_RT[excl_idx,2]), width = 0.2, yerr = std(drug_M_RT[excl_idx,2]), capsize = 10, color = "g")
	bar(3.3, mean(drug_LL_RT[excl_idx,2]), width = 0.2, yerr = std(drug_LL_RT[excl_idx,2]), capsize = 10, color = "b")

	bar(3.9, mean(drug_HH_RT[excl_idx,3]), width = 0.2, yerr = std(drug_HH_RT[excl_idx,3]), capsize = 10, color = "r")
	bar(4.1, mean(drug_M_RT[excl_idx,3]), width = 0.2, yerr = std(drug_M_RT[excl_idx,3]), capsize = 10, color = "g")
	bar(4.3, mean(drug_LL_RT[excl_idx,3]), width = 0.2, yerr = std(drug_LL_RT[excl_idx,3]), capsize = 10, color = "b")

	axhline(linewidth=1, c = "k")

	ax[:set_xticks]([1.1, 2.1, 3.1, 4.1])
	ax[:set_xticklabels]([ "Vehicle", "1.0 mg/kg", "3.0 mg/kg", "10.0 mg/kg"])
	ax[:tick_params](labelsize = 14)

	ylabel("Response time [sec]", fontsize = 14)
	legend([b1, b2, b3], ["High correct", "Mid", "Low correct"], fontsize = 14)
	
	figure()
	ax = axes()

	b1 = bar(0.9, mean(veh_om_H[excl_idx]), width = 0.2, yerr = std(veh_om_H[excl_idx]), capsize = 10, color = "r")
	b2 = bar(1.1, mean(veh_om_M[excl_idx]), width = 0.2, yerr = std(veh_om_M[excl_idx]), capsize = 10, color = "g")
	b3 = bar(1.3, mean(veh_om_L[excl_idx]), width = 0.2, yerr = std(veh_om_L[excl_idx]), capsize = 10, color = "b")

	bar(1.9, mean(drug_om_H[excl_idx,1]), width = 0.2, yerr = std(drug_om_H[excl_idx,1]), capsize = 10, color = "r")
	bar(2.1, mean(drug_om_M[excl_idx,1]), width = 0.2, yerr = std(drug_om_M[excl_idx,1]), capsize = 10, color = "g")
	bar(2.3, mean(drug_om_L[excl_idx,1]), width = 0.2, yerr = std(drug_om_L[excl_idx,1]), capsize = 10, color = "b")

	bar(2.9, mean(drug_om_H[excl_idx,2]), width = 0.2, yerr = std(drug_om_H[excl_idx,2]), capsize = 10, color = "r")
	bar(3.1, mean(drug_om_M[excl_idx,2]), width = 0.2, yerr = std(drug_om_M[excl_idx,2]), capsize = 10, color = "g")
	bar(3.3, mean(drug_om_L[excl_idx,2]), width = 0.2, yerr = std(drug_om_L[excl_idx,2]), capsize = 10, color = "b")

	bar(3.9, mean(drug_om_H[excl_idx,3]), width = 0.2, yerr = std(drug_om_H[excl_idx,3]), capsize = 10, color = "r")
	bar(4.1, mean(drug_om_M[excl_idx,3]), width = 0.2, yerr = std(drug_om_M[excl_idx,3]), capsize = 10, color = "g")
	bar(4.3, mean(drug_om_L[excl_idx,3]), width = 0.2, yerr = std(drug_om_L[excl_idx,3]), capsize = 10, color = "b")

	axhline(linewidth=1, c = "k")

	ax[:set_xticks]([1.1, 2.1, 3.1, 4.1])
	ax[:set_xticklabels]([ "Vehicle", "1.0 mg/kg", "3.0 mg/kg", "10.0 mg/kg"])
	ax[:tick_params](labelsize = 14)

	ylabel("Omissions [%]", fontsize = 14)
	legend([b1, b2, b3], ["High", "Mid", "Low"], fontsize = 14)

	figure()
	ax = axes()

	bar(1.0, mean(veh_prem[excl_idx]), width = 0.35, yerr = std(veh_prem[excl_idx]), capsize = 10)

	bar(2.0, mean(drug_prem[excl_idx,1]), width = 0.35, yerr = std(drug_prem[excl_idx,1]), capsize = 10)
	bar(3.0, mean(drug_prem[excl_idx,2]), width = 0.35, yerr = std(drug_prem[excl_idx,2]), capsize = 10)
	bar(4.0, mean(drug_prem[excl_idx,3]), width = 0.35, yerr = std(drug_prem[excl_idx,3]), capsize = 10)

	axhline(linewidth=1, c = "k")

	ax[:set_xticks]([1.0, 2.0, 3.0, 4.0])
	ax[:set_xticklabels]([ "Vehicle" ,"1.0 mg/kg", "3.0 mg/kg", "10.0 mg/kg"])
	ax[:tick_params](labelsize = 14)

	ylabel("Prematures", fontsize = 14)
	
	show()
end

function plot_nalket()

	path = "./nalket/" ;

	file_vec = date_sort(filter(x->contains(x,".xlsx"), readdir(path))) ;

	veh_cbi = zeros(16) ;
	veh_om_H = zeros(16) ;
	veh_om_M = zeros(16) ;
	veh_om_L = zeros(16) ;
	veh_prem = zeros(16) ;
	veh_HH_RT = zeros(16) ;
	veh_M_RT = zeros(16) ;
	veh_LL_RT = zeros(16) ;

	drug_cbi = zeros(16, size(CB_4,2) - 1) ;
	drug_om_H = zeros(16, size(CB_4,2) - 1) ; 
	drug_om_M = zeros(16, size(CB_4,2) - 1) ; 
	drug_om_L = zeros(16, size(CB_4,2) - 1) ; 
	drug_prem = zeros(16, size(CB_4,2) - 1) ; 
	drug_HH_RT = zeros(16, size(CB_4,2) - 1) ;
	drug_M_RT = zeros(16, size(CB_4,2) - 1) ;
	drug_LL_RT = zeros(16, size(CB_4,2) - 1) ;

	i = 1 ;
	for file in file_vec

		XLSX.openxlsx(string(path,file)) do xf

			sheets = XLSX.sheetnames(xf) ;
			df = DataFrame(XLSX.readtable(string(path,file), sheets[end])...) ;

			A_idx = find(x -> x == :A, CB_4[:,i]) ;
			B_idx = find(x -> x == :B, CB_4[:,i]) ;
			C_idx = find(x -> x == :C, CB_4[:,i]) ;
			D_idx = find(x -> x == :D, CB_4[:,i]) ;

			veh_cbi[D_idx] = df[:CBI][D_idx] ;
			drug_cbi[A_idx,1] = df[:CBI][A_idx] ;
			drug_cbi[B_idx,2] = df[:CBI][B_idx] ;
			drug_cbi[C_idx,3] = df[:CBI][C_idx] ;

			veh_om_H[D_idx] = df[:Om_H][D_idx] ;
			drug_om_H[A_idx,1] = df[:Om_H][A_idx] ;
			drug_om_H[B_idx,2] = df[:Om_H][B_idx] ;
			drug_om_H[C_idx,3] = df[:Om_H][C_idx] ;

			veh_om_M[D_idx] = df[:Om_M][D_idx] ;
			drug_om_M[A_idx,1] = df[:Om_M][A_idx] ;
			drug_om_M[B_idx,2] = df[:Om_M][B_idx] ;
			drug_om_M[C_idx,3] = df[:Om_M][C_idx] ;

			veh_om_L[D_idx] = df[:Om_L][D_idx] ;
			drug_om_L[A_idx,1] = df[:Om_L][A_idx] ;
			drug_om_L[B_idx,2] = df[:Om_L][B_idx] ;
			drug_om_L[C_idx,3] = df[:Om_L][C_idx] ;

			veh_prem[D_idx] = df[:Prem][D_idx] ;
			drug_prem[A_idx,1] = df[:Prem][A_idx] ;
			drug_prem[B_idx,2] = df[:Prem][B_idx] ;
			drug_prem[C_idx,3] = df[:Prem][C_idx] ;

			veh_HH_RT[D_idx] = df[:HH_RT][D_idx] ;
			drug_HH_RT[A_idx,1] = df[:HH_RT][A_idx] ;
			drug_HH_RT[B_idx,2] = df[:HH_RT][B_idx] ;
			drug_HH_RT[C_idx,3] = df[:HH_RT][C_idx] ;

			veh_M_RT[D_idx] = df[:M_RT][D_idx] ;
			drug_M_RT[A_idx,1] = df[:M_RT][A_idx] ;
			drug_M_RT[B_idx,2] = df[:M_RT][B_idx] ;
			drug_M_RT[C_idx,3] = df[:M_RT][C_idx] ;

			veh_LL_RT[D_idx] = df[:LL_RT][D_idx] ;
			drug_LL_RT[A_idx,1] = df[:LL_RT][A_idx] ;
			drug_LL_RT[B_idx,2] = df[:LL_RT][B_idx] ;
			drug_LL_RT[C_idx,3] = df[:LL_RT][C_idx] ;
		end

		i = i + 1 ;
	end
	
	excl_idx = [1,2,3,4,5,6,7,8,9,11,12,13,15,16] ;

	figure()
	ax = axes()

	bar(1.0, mean(veh_cbi[excl_idx]), width = 0.35, yerr = std(veh_cbi[excl_idx]), capsize = 10)

	bar(2.0, mean(drug_cbi[excl_idx,1]), width = 0.35, yerr = std(drug_cbi[excl_idx,1]), capsize = 10)
	bar(3.0, mean(drug_cbi[excl_idx,3]), width = 0.35, yerr = std(drug_cbi[excl_idx,3]), capsize = 10)
	bar(4.0, mean(drug_cbi[excl_idx,2]), width = 0.35, yerr = std(drug_cbi[excl_idx,2]), capsize = 10)

	axhline(linewidth=1, c = "k")

	ax[:set_xticks]([1.0, 2.0, 3.0, 4.0])
	ax[:set_xticklabels]([ "Vehicle" ,"Vehicle - Ketamine", "Naltrexone - Vehicle", "Naltrexone - Ketamine"])
	ax[:tick_params](labelsize = 14)

	ylabel("CBI", fontsize = 14)

	figure()
	ax = axes()

	b1 = bar(0.9, mean(veh_HH_RT[excl_idx]), width = 0.2, yerr = std(veh_HH_RT[excl_idx]), capsize = 10, color = "r")
	b2 = bar(1.1, mean(veh_M_RT[excl_idx]), width = 0.2, yerr = std(veh_M_RT[excl_idx]), capsize = 10, color = "g")
	b3 = bar(1.3, mean(veh_LL_RT[excl_idx]), width = 0.2, yerr = std(veh_LL_RT[excl_idx]), capsize = 10, color = "b")

	bar(1.9, mean(drug_HH_RT[excl_idx,1]), width = 0.2, yerr = std(drug_HH_RT[excl_idx,1]), capsize = 10, color = "r")
	bar(2.1, mean(drug_M_RT[excl_idx,1]), width = 0.2, yerr = std(drug_M_RT[excl_idx,1]), capsize = 10, color = "g")
	bar(2.3, mean(drug_LL_RT[excl_idx,1]), width = 0.2, yerr = std(drug_LL_RT[excl_idx,1]), capsize = 10, color = "b")

	bar(2.9, mean(drug_HH_RT[excl_idx,3]), width = 0.2, yerr = std(drug_HH_RT[excl_idx,3]), capsize = 10, color = "r")
	bar(3.1, mean(drug_M_RT[excl_idx,3]), width = 0.2, yerr = std(drug_M_RT[excl_idx,3]), capsize = 10, color = "g")
	bar(3.3, mean(drug_LL_RT[excl_idx,3]), width = 0.2, yerr = std(drug_LL_RT[excl_idx,3]), capsize = 10, color = "b")

	bar(3.9, mean(drug_HH_RT[excl_idx,2]), width = 0.2, yerr = std(drug_HH_RT[excl_idx,2]), capsize = 10, color = "r")
	bar(4.1, mean(drug_M_RT[excl_idx,2]), width = 0.2, yerr = std(drug_M_RT[excl_idx,2]), capsize = 10, color = "g")
	bar(4.3, mean(drug_LL_RT[excl_idx,2]), width = 0.2, yerr = std(drug_LL_RT[excl_idx,2]), capsize = 10, color = "b")

	axhline(linewidth=1, c = "k")

	ax[:set_xticks]([1.1, 2.1, 3.1, 4.1])
	ax[:set_xticklabels]([ "Vehicle" ,"Vehicle - Ketamine", "Naltrexone - Vehicle", "Naltrexone - Ketamine"])
	ax[:tick_params](labelsize = 14)

	ylabel("Response time [sec]", fontsize = 14)
	legend([b1, b2, b3], ["High correct", "Mid", "Low correct"], fontsize = 14)
	
	figure()
	ax = axes()

	b1 = bar(0.9, mean(veh_om_H[excl_idx]), width = 0.2, yerr = std(veh_om_H[excl_idx]), capsize = 10, color = "r")
	b2 = bar(1.1, mean(veh_om_M[excl_idx]), width = 0.2, yerr = std(veh_om_M[excl_idx]), capsize = 10, color = "g")
	b3 = bar(1.3, mean(veh_om_L[excl_idx]), width = 0.2, yerr = std(veh_om_L[excl_idx]), capsize = 10, color = "b")

	bar(1.9, mean(drug_om_H[excl_idx,1]), width = 0.2, yerr = std(drug_om_H[excl_idx,1]), capsize = 10, color = "r")
	bar(2.1, mean(drug_om_M[excl_idx,1]), width = 0.2, yerr = std(drug_om_M[excl_idx,1]), capsize = 10, color = "g")
	bar(2.3, mean(drug_om_L[excl_idx,1]), width = 0.2, yerr = std(drug_om_L[excl_idx,1]), capsize = 10, color = "b")

	bar(2.9, mean(drug_om_H[excl_idx,3]), width = 0.2, yerr = std(drug_om_H[excl_idx,3]), capsize = 10, color = "r")
	bar(3.1, mean(drug_om_M[excl_idx,3]), width = 0.2, yerr = std(drug_om_M[excl_idx,3]), capsize = 10, color = "g")
	bar(3.3, mean(drug_om_L[excl_idx,3]), width = 0.2, yerr = std(drug_om_L[excl_idx,3]), capsize = 10, color = "b")

	bar(3.9, mean(drug_om_H[excl_idx,2]), width = 0.2, yerr = std(drug_om_H[excl_idx,2]), capsize = 10, color = "r")
	bar(4.1, mean(drug_om_M[excl_idx,2]), width = 0.2, yerr = std(drug_om_M[excl_idx,2]), capsize = 10, color = "g")
	bar(4.3, mean(drug_om_L[excl_idx,2]), width = 0.2, yerr = std(drug_om_L[excl_idx,2]), capsize = 10, color = "b")

	axhline(linewidth=1, c = "k")

	ax[:set_xticks]([1.1, 2.1, 3.1, 4.1])
	ax[:set_xticklabels]([ "Vehicle" ,"Vehicle - Ketamine", "Naltrexone - Vehicle", "Naltrexone - Ketamine"])
	ax[:tick_params](labelsize = 14)

	ylabel("Omissions [%]", fontsize = 14)
	legend([b1, b2, b3], ["High", "Mid", "Low"], fontsize = 14)

	figure()
	ax = axes()

	bar(1.0, mean(veh_prem[excl_idx]), width = 0.35, yerr = std(veh_prem[excl_idx]), capsize = 10)

	bar(2.0, mean(drug_prem[excl_idx,1]), width = 0.35, yerr = std(drug_prem[excl_idx,1]), capsize = 10)
	bar(3.0, mean(drug_prem[excl_idx,3]), width = 0.35, yerr = std(drug_prem[excl_idx,3]), capsize = 10)
	bar(4.0, mean(drug_prem[excl_idx,2]), width = 0.35, yerr = std(drug_prem[excl_idx,2]), capsize = 10)

	axhline(linewidth=1, c = "k")

	ax[:set_xticks]([1.0, 2.0, 3.0, 4.0])
	ax[:set_xticklabels]([ "Vehicle" ,"Vehicle - Ketamine", "Naltrexone - Vehicle", "Naltrexone - Ketamine"])
	ax[:tick_params](labelsize = 14)

	ylabel("Prematures", fontsize = 14)
	
	show()
end

function plot_drug_timeline()

	file_vec = date_sort(filter(x->contains(x,".xlsx"), readdir())) ;
	path = "" ;

	probe = read_probe_data(file_vec[1:3], path, false, :nothing) ;
	ket = read_probe_data(file_vec[4:5], path, true, :A) ;
	nal = read_probe_data(file_vec[6:9], path, true, :D) ;
	nalket = read_probe_data(file_vec[10:13], path, true, :D) ;

	hard_idx = [1, 2, 6, 7, 11, 12, 15, 16] ;
	#easy_idx = [3, 4, 5, 8, 9, 10, 13, 14] ;
	easy_idx = [3, 4, 5, 8, 9, 13] ;

	figure()
	ax = axes()

	errorbar([1 2 3], mean(probe.cbi[hard_idx],1), fmt = "C0D", markersize = 10,
		yerr = std(probe.cbi[hard_idx],1), capsize = 10)

	errorbar(4, mean(ket.cbi[hard_idx],1), fmt = "C0D", markersize = 10,
		yerr = std(ket.cbi[hard_idx],1), capsize = 10)

	errorbar(5, mean(nal.cbi[hard_idx],1), fmt = "C0D", markersize = 10,
		yerr = std(nal.cbi[hard_idx],1), capsize = 10)

	errorbar(6, mean(nalket.cbi[hard_idx],1), fmt = "C0D", markersize = 10,
		yerr = std(nalket.cbi[hard_idx],1), label = "Hard", capsize = 10)


	errorbar([1 2 3], mean(probe.cbi[easy_idx],1), fmt = "C3D", markersize = 10,
		yerr = std(probe.cbi[easy_idx],1), capsize = 10)

	errorbar(4, mean(ket.cbi[easy_idx],1), fmt = "C3D", markersize = 10,
		yerr = std(ket.cbi[easy_idx],1), capsize = 10)

	errorbar(5, mean(nal.cbi[easy_idx],1), fmt = "C3D", markersize = 10,
		yerr = std(nal.cbi[easy_idx],1), capsize = 10)

	errorbar(6, mean(nalket.cbi[easy_idx],1), fmt = "C3D", markersize = 10,
		yerr = std(nalket.cbi[easy_idx],1), label = "Easy", capsize = 10)

	ax[:set_xticks]([2.0, 4.0, 5.0, 6.0])
	ax[:set_xticklabels](["Probe sessions \n no drugs", "Ketamine", "Naltrexone", "Naltrexone & \n Ketamine"])
	ax[:tick_params](labelsize = 14)

	ylabel("CBI", fontsize = 14)
	legend(fontsize = 14)

	figure()
	ax = axes()

	errorbar([1 2 3], mean(probe.prem[hard_idx],1), fmt = "C0D", markersize = 10,
		yerr = std(probe.prem[hard_idx],1), capsize = 10)

	errorbar(4, mean(ket.prem[hard_idx],1), fmt = "C0D", markersize = 10,
		yerr = std(ket.prem[hard_idx],1), capsize = 10)

	errorbar(5, mean(nal.prem[hard_idx],1), fmt = "C0D", markersize = 10,
		yerr = std(nal.prem[hard_idx],1), capsize = 10)

	errorbar(6, mean(nalket.prem[hard_idx],1), fmt = "C0D", markersize = 10,
		yerr = std(nalket.prem[hard_idx],1), label = "Hard", capsize = 10)


	errorbar([1 2 3], mean(probe.prem[easy_idx],1), fmt = "C3D", markersize = 10,
		yerr = std(probe.prem[easy_idx],1), capsize = 10)

	errorbar(4, mean(ket.prem[easy_idx],1), fmt = "C3D", markersize = 10,
		yerr = std(ket.prem[easy_idx],1), capsize = 10)

	errorbar(5, mean(nal.prem[easy_idx],1), fmt = "C3D", markersize = 10,
		yerr = std(nal.prem[easy_idx],1), capsize = 10)

	errorbar(6, mean(nalket.prem[easy_idx],1), fmt = "C3D", markersize = 10,
		yerr = std(nalket.prem[easy_idx],1), label = "Easy", capsize = 10)

	ax[:set_xticks]([2.0, 4.0, 5.0, 6.0])
	ax[:set_xticklabels](["Probe sessions \n no drugs", "Ketamine", "Naltrexone", "Naltrexone & \n Ketamine"])
	ax[:tick_params](labelsize = 14)

	ylabel("Prematures", fontsize = 14)
	legend(fontsize = 14)

	figure()
	ax = axes()

	errorbar([1 2 3], mean(probe.om_M[hard_idx],1), fmt = "C0D", markersize = 10,
		yerr = std(probe.om_M[hard_idx],1), capsize = 10)

	errorbar(4, mean(ket.om_M[hard_idx],1), fmt = "C0D", markersize = 10,
		yerr = std(ket.om_M[hard_idx],1), capsize = 10)

	errorbar(5, mean(nal.om_M[hard_idx],1), fmt = "C0D", markersize = 10,
		yerr = std(nal.om_M[hard_idx],1), capsize = 10)

	errorbar(6, mean(nalket.om_M[hard_idx],1), fmt = "C0D", markersize = 10,
		yerr = std(nalket.om_M[hard_idx],1), label = "Hard", capsize = 10)


	errorbar([1 2 3], mean(probe.om_M[easy_idx],1), fmt = "C3D", markersize = 10,
		yerr = std(probe.om_M[easy_idx],1), capsize = 10)

	errorbar(4, mean(ket.om_M[easy_idx],1), fmt = "C3D", markersize = 10,
		yerr = std(ket.om_M[easy_idx],1), capsize = 10)

	errorbar(5, mean(nal.om_M[easy_idx],1), fmt = "C3D", markersize = 10,
		yerr = std(nal.om_M[easy_idx],1), capsize = 10)

	errorbar(6, mean(nalket.om_M[easy_idx],1), fmt = "C3D", markersize = 10,
		yerr = std(nalket.om_M[easy_idx],1), label = "Easy", capsize = 10)

	ax[:set_xticks]([2.0, 4.0, 5.0, 6.0])
	ax[:set_xticklabels](["Probe sessions \n no drugs", "Ketamine", "Naltrexone", "Naltrexone & \n Ketamine"])
	ax[:tick_params](labelsize = 14)

	ylabel("Omissions [%]", fontsize = 14)
	legend(fontsize = 14)

	figure()
	ax = axes()

	errorbar([1 2 3], mean(probe.MH_RT[hard_idx],1), fmt = "C0D", markersize = 10,
		yerr = std(probe.MH_RT[hard_idx],1), capsize = 10)

	errorbar(4, mean(ket.MH_RT[hard_idx],1), fmt = "C0D", markersize = 10,
		yerr = std(ket.MH_RT[hard_idx],1), capsize = 10)

	errorbar(5, mean(nal.MH_RT[hard_idx],1), fmt = "C0D", markersize = 10,
		yerr = std(nal.MH_RT[hard_idx],1), capsize = 10)

	errorbar(6, mean(nalket.MH_RT[hard_idx],1), fmt = "C0D", markersize = 10,
		yerr = std(nalket.MH_RT[hard_idx],1), label = "Hard", capsize = 10)


	errorbar([1 2 3], mean(probe.MH_RT[easy_idx],1), fmt = "C3D", markersize = 10,
		yerr = std(probe.MH_RT[easy_idx],1), capsize = 10)

	errorbar(4, mean(ket.MH_RT[easy_idx],1), fmt = "C3D", markersize = 10,
		yerr = std(ket.MH_RT[easy_idx],1), capsize = 10)

	errorbar(5, mean(nal.MH_RT[easy_idx],1), fmt = "C3D", markersize = 10,
		yerr = std(nal.MH_RT[easy_idx],1), capsize = 10)

	errorbar(6, mean(nalket.MH_RT[easy_idx],1), fmt = "C3D", markersize = 10,
		yerr = std(nalket.MH_RT[easy_idx],1), label = "Easy", capsize = 10)

	ax[:set_xticks]([2.0, 4.0, 5.0, 6.0])
	ax[:set_xticklabels](["Probe sessions \n no drugs", "Ketamine", "Naltrexone", "Naltrexone & \n Ketamine"])
	ax[:tick_params](labelsize = 14)

	ylabel("Response time [sec]", fontsize = 14)
	legend(fontsize = 14)
	title("Midpoint - high reward lever response time", fontsize = 14)

	figure()
	ax = axes()

	errorbar([1 2 3], mean(probe.ML_RT[hard_idx],1), fmt = "C0D", markersize = 10,
		yerr = std(probe.ML_RT[hard_idx],1), capsize = 10)

	errorbar(4, mean(ket.ML_RT[hard_idx],1), fmt = "C0D", markersize = 10,
		yerr = std(ket.ML_RT[hard_idx],1), capsize = 10)

	errorbar(5, mean(nal.ML_RT[hard_idx],1), fmt = "C0D", markersize = 10,
		yerr = std(nal.ML_RT[hard_idx],1), capsize = 10)

	errorbar(6, mean(nalket.ML_RT[hard_idx],1), fmt = "C0D", markersize = 10,
		yerr = std(nalket.ML_RT[hard_idx],1), label = "Hard", capsize = 10)


	errorbar([1 2 3], mean(probe.ML_RT[easy_idx],1), fmt = "C3D", markersize = 10,
		yerr = std(probe.ML_RT[easy_idx],1), capsize = 10)

	errorbar(4, mean(ket.ML_RT[easy_idx],1), fmt = "C3D", markersize = 10,
		yerr = std(ket.ML_RT[easy_idx],1), capsize = 10)

	errorbar(5, mean(nal.ML_RT[easy_idx],1), fmt = "C3D", markersize = 10,
		yerr = std(nal.ML_RT[easy_idx],1), capsize = 10)

	errorbar(6, mean(nalket.ML_RT[easy_idx],1), fmt = "C3D", markersize = 10,
		yerr = std(nalket.ML_RT[easy_idx],1), label = "Easy", capsize = 10)

	ax[:set_xticks]([2.0, 4.0, 5.0, 6.0])
	ax[:set_xticklabels](["Probe sessions \n no drugs", "Ketamine", "Naltrexone", "Naltrexone & \n Ketamine"])
	ax[:tick_params](labelsize = 14)

	ylabel("Response time [sec]", fontsize = 14)
	legend(fontsize = 14)
	title("Midpoint - low reward lever response time", fontsize = 14)
	
	show()

end

function plot_ket_comp()

	path = "./ket/" ;

	file_vec = date_sort(filter(x->contains(x,".xlsx"), readdir(path))) ;

	veh_ks_cbi = zeros(16, 1) ;
	veh_ks_om_H = zeros(16, 1) ;
	veh_ks_om_M = zeros(16, 1) ;
	veh_ks_om_L = zeros(16, 1) ;
	veh_ks_prem = zeros(16, 1) ;
	veh_ks_HH_RT = zeros(16, 1) ;
	veh_ks_LL_RT = zeros(16, 1) ;
	veh_ks_M_RT = zeros(16, 1) ; 

	ket_cbi = zeros(16, size(CB_2,2) - 1) ;
	ket_om_H = zeros(16, size(CB_2,2) - 1) ; 
	ket_om_M = zeros(16, size(CB_2,2) - 1) ; 
	ket_om_L = zeros(16, size(CB_2,2) - 1) ; 
	ket_prem = zeros(16, size(CB_2,2) - 1) ; 
	ket_HH_RT = zeros(16, size(CB_2,2) - 1) ;
	ket_LL_RT = zeros(16, size(CB_2,2) - 1) ;
	ket_M_RT = zeros(16, size(CB_2,2) - 1) ;

	excl_idx = [1,2,3,4,5,6,7,8,9,11,12,13,15,16] ;
	hard_idx = [1, 2, 6, 7, 11, 12, 15, 16] ;
	#easy_idx = [3, 4, 5, 8, 9, 10, 13, 14] ;
	easy_idx = [3, 4, 5, 8, 9, 13] ;

	i = 1 ;
	for file in file_vec

		XLSX.openxlsx(string(path,file)) do xf

			sheets = XLSX.sheetnames(xf) ;
			df = DataFrame(XLSX.readtable(string(path,file), sheets[end])...) ;

			A_idx = find(x -> x == :A, CB_2[:,i]) ;
			B_idx = find(x -> x == :B, CB_2[:,i]) ;

			veh_ks_cbi[A_idx] = df[:CBI][A_idx] ;
			ket_cbi[B_idx] = df[:CBI][B_idx] ;

			veh_ks_om_H[A_idx] = df[:Om_H][A_idx] ;
			ket_om_H[B_idx,1] = df[:Om_H][B_idx] ;

			veh_ks_om_M[A_idx] = df[:Om_M][A_idx] ;
			ket_om_M[B_idx,1] = df[:Om_M][B_idx] ;

			veh_ks_om_L[A_idx] = df[:Om_L][A_idx] ;
			ket_om_L[B_idx,1] = df[:Om_L][B_idx] ;

			veh_ks_prem[A_idx] = df[:Prem][A_idx] ;
			ket_prem[B_idx,1] = df[:Prem][B_idx] ;

			veh_ks_HH_RT[A_idx] = df[:HH_RT][A_idx] ;
			ket_HH_RT[B_idx,1] = df[:HH_RT][B_idx] ;

			veh_ks_M_RT[A_idx] = df[:M_RT][A_idx] ;
			ket_M_RT[B_idx,1] = df[:M_RT][B_idx] ;

			veh_ks_LL_RT[A_idx] = df[:LL_RT][A_idx] ;
			ket_LL_RT[B_idx,1] = df[:LL_RT][B_idx] ;
		end

		i += 1 ;
	end

	path = "./nalket/" ;

	file_vec = date_sort(filter(x->contains(x,".xlsx"), readdir(path))) ;

	veh_cbi = zeros(16, 1) ;
	veh_om_H = zeros(16, 1) ;
	veh_om_M = zeros(16, 1) ;
	veh_om_L = zeros(16, 1) ;
	veh_prem = zeros(16, 1) ;
	veh_HH_RT = zeros(16, 1) ;
	veh_M_RT = zeros(16, 1) ;
	veh_LL_RT = zeros(16, 1) ;

	drug_cbi = zeros(16, size(CB_4,2) - 1) ;
	drug_om_H = zeros(16, size(CB_4,2) - 1) ; 
	drug_om_M = zeros(16, size(CB_4,2) - 1) ; 
	drug_om_L = zeros(16, size(CB_4,2) - 1) ; 
	drug_prem = zeros(16, size(CB_4,2) - 1) ; 
	drug_HH_RT = zeros(16, size(CB_4,2) - 1) ;
	drug_M_RT = zeros(16, size(CB_4,2) - 1) ;
	drug_LL_RT = zeros(16, size(CB_4,2) - 1) ;

	i = 1 ;
	for file in file_vec

		XLSX.openxlsx(string(path,file)) do xf

			sheets = XLSX.sheetnames(xf) ;
			df = DataFrame(XLSX.readtable(string(path,file), sheets[end])...) ;

			A_idx = find(x -> x == :A, CB_4[:,i]) ;
			B_idx = find(x -> x == :B, CB_4[:,i]) ;
			C_idx = find(x -> x == :C, CB_4[:,i]) ;
			D_idx = find(x -> x == :D, CB_4[:,i]) ;

			veh_cbi[D_idx] = df[:CBI][D_idx] ;
			drug_cbi[A_idx,1] = df[:CBI][A_idx] ;
			drug_cbi[B_idx,2] = df[:CBI][B_idx] ;
			drug_cbi[C_idx,3] = df[:CBI][C_idx] ;

			veh_om_H[D_idx] = df[:Om_H][D_idx] ;
			drug_om_H[A_idx,1] = df[:Om_H][A_idx] ;
			drug_om_H[B_idx,2] = df[:Om_H][B_idx] ;
			drug_om_H[C_idx,3] = df[:Om_H][C_idx] ;

			veh_om_M[D_idx] = df[:Om_M][D_idx] ;
			drug_om_M[A_idx,1] = df[:Om_M][A_idx] ;
			drug_om_M[B_idx,2] = df[:Om_M][B_idx] ;
			drug_om_M[C_idx,3] = df[:Om_M][C_idx] ;

			veh_om_L[D_idx] = df[:Om_L][D_idx] ;
			drug_om_L[A_idx,1] = df[:Om_L][A_idx] ;
			drug_om_L[B_idx,2] = df[:Om_L][B_idx] ;
			drug_om_L[C_idx,3] = df[:Om_L][C_idx] ;

			veh_prem[D_idx] = df[:Prem][D_idx] ;
			drug_prem[A_idx,1] = df[:Prem][A_idx] ;
			drug_prem[B_idx,2] = df[:Prem][B_idx] ;
			drug_prem[C_idx,3] = df[:Prem][C_idx] ;

			veh_HH_RT[D_idx] = df[:HH_RT][D_idx] ;
			drug_HH_RT[A_idx,1] = df[:HH_RT][A_idx] ;
			drug_HH_RT[B_idx,2] = df[:HH_RT][B_idx] ;
			drug_HH_RT[C_idx,3] = df[:HH_RT][C_idx] ;

			veh_M_RT[D_idx] = df[:M_RT][D_idx] ;
			drug_M_RT[A_idx,1] = df[:M_RT][A_idx] ;
			drug_M_RT[B_idx,2] = df[:M_RT][B_idx] ;
			drug_M_RT[C_idx,3] = df[:M_RT][C_idx] ;

			veh_LL_RT[D_idx] = df[:LL_RT][D_idx] ;
			drug_LL_RT[A_idx,1] = df[:LL_RT][A_idx] ;
			drug_LL_RT[B_idx,2] = df[:LL_RT][B_idx] ;
			drug_LL_RT[C_idx,3] = df[:LL_RT][C_idx] ;
		end

		i = i + 1 ;
	end

	#println(pvalue(OneSampleTTest(ket_cbi[:][hard_idx] - veh_ks_cbi[:][hard_idx])))
	#println(pvalue(OneSampleTTest(drug_cbi[:,1][:][excl_idx] - veh_cbi[:][excl_idx])))

	figure()
	ax = axes()

	bar(1.0, mean(ket_cbi[excl_idx] - veh_ks_cbi[excl_idx]), width = 0.35, 
		yerr = std(ket_cbi[excl_idx] - veh_ks_cbi[excl_idx]), capsize = 10)

	bar(2.0, mean(drug_cbi[excl_idx,1] - veh_cbi[excl_idx]), width = 0.35, 
		yerr = std(drug_cbi[excl_idx,1] - veh_cbi[excl_idx]), capsize = 10)

	axhline(linewidth=1, c = "k")

	ax[:set_xticks]([1.0, 2.0])
	ax[:set_xticklabels]([ "Ketamine \n in ketamine study" ,"Ketamine \n in naltrexone & ketamine study"])
	ax[:tick_params](labelsize = 14)

	ylabel("Change from baseline CBI", fontsize = 14)

	figure()
	ax = axes()

	bar(1.0, mean(ket_cbi[hard_idx] - veh_ks_cbi[hard_idx]), width = 0.35, 
		yerr = std(ket_cbi[hard_idx] - veh_ks_cbi[hard_idx]), capsize = 10)

	bar(2.0, mean(drug_cbi[hard_idx,1] - veh_cbi[hard_idx]), width = 0.35, 
		yerr = std(drug_cbi[hard_idx,1] - veh_cbi[hard_idx]), capsize = 10)

	axhline(linewidth=1, c = "k")

	ax[:set_xticks]([1.0, 2.0])
	ax[:set_xticklabels]([ "Ketamine \n in ketamine study" ,"Ketamine \n in naltrexone & ketamine study"])
	ax[:tick_params](labelsize = 14)

	ylabel("Change from baseline CBI", fontsize = 14)

	show()

end

function plot_discrimination()

	path = "./HO2/discrimination/"
	file_vec = date_sort(filter(x->contains(x,".xlsx"), readdir(path))) ;

	acc_2 = zeros(16, length(file_vec)) ;
	acc_8 = zeros(16, length(file_vec)) ;
	RT_2 = zeros(16, length(file_vec)) ;
	RT_8 = zeros(16, length(file_vec)) ;
	Om_2 = zeros(16, length(file_vec)) ;
	Om_8 = zeros(16, length(file_vec)) ;
	prem = zeros(16, length(file_vec)) ;

	i = 1 ;
	for file in file_vec
		println(file)
		XLSX.openxlsx(string(path,file)) do xf

			sheets = XLSX.sheetnames(xf) ;
			df = DataFrame(XLSX.readtable(string(path,file), sheets[1])...) ;

			acc_2[:, i] = df[:HH_p] ;
			acc_8[:, i] = df[:LL_p] ;
			RT_2[:, i] = df[:HH_RT] ;
			RT_8[:, i] = df[:LL_RT] ;
			Om_2[:, i] = df[:Om_H] ;
			Om_8[:, i] = df[:Om_L] ;
			prem[:, i] = df[:Prem] ;
		end
		i += 1 ;
	end

	figure()
	ax = axes()

	errorbar([1 2 3 4 5 6 7 8 9 10 11 12 13 14 15], mean(acc_2,1), fmt = "C0D", markersize = 10,
		yerr = std(acc_2,1)./sqrt(size(acc_2,1)), capsize = 10)

	ax[:set_xticks]([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0])
	ax[:set_xticklabels](["Mon \n 10 Dec", "Tue \n 11 Dec", "Wed \n 12 Dec", "Thur \n 13 Dec", "Fri \n 14 Dec",
						"Mon \n 17 Dec", "Tue \n 18 Dec", "Wed \n 19 Dec", "Thur \n 20 Dec", "Fri \n 21 Dec",
						"Tue \n 08 Jan", "Wed \n 09 Jan", "Thur \n 10 Jan", "Fri \n 11 Jan", "Mon \n 14 Dec"])
	ax[:tick_params](labelsize = 14)

	ylabel("Accuracy [%]", fontsize = 14)
	title("2KHz tone")

	figure()
	ax = axes()

	errorbar([1 2 3 4 5 6 7 8 9 10 11 12 13 14 15], mean(acc_8,1), fmt = "C0D", markersize = 10,
		yerr = std(acc_8,1)./sqrt(size(acc_8,1)), capsize = 10)

	ax[:set_xticks]([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0])
	ax[:set_xticklabels](["Mon \n 10 Dec", "Tue \n 11 Dec", "Wed \n 12 Dec", "Thur \n 13 Dec", "Fri \n 14 Dec",
						"Mon \n 17 Dec", "Tue \n 18 Dec", "Wed \n 19 Dec", "Thur \n 20 Dec", "Fri \n 21 Dec",
						"Tue \n 08 Jan", "Wed \n 09 Jan", "Thur \n 10 Jan", "Fri \n 11 Jan", "Mon \n 14 Dec"])
	ax[:tick_params](labelsize = 14)

	ylabel("Accuracy [%]", fontsize = 14)
	title("8KHz tone")

	figure()
	ax = axes()
	
	errorbar([1 2 3 4 5 6 7 8 9 10 11 12 13 14 15], mean(RT_2,1), fmt = "C0D", markersize = 10,
		yerr = std(RT_2,1)./sqrt(size(RT_2,1)), capsize = 10)

	ax[:set_xticks]([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0])
	ax[:set_xticklabels](["Mon \n 10 Dec", "Tue \n 11 Dec", "Wed \n 12 Dec", "Thur \n 13 Dec", "Fri \n 14 Dec",
						"Mon \n 17 Dec", "Tue \n 18 Dec", "Wed \n 19 Dec", "Thur \n 20 Dec", "Fri \n 21 Dec",
						"Tue \n 08 Jan", "Wed \n 09 Jan", "Thur \n 10 Jan", "Fri \n 11 Jan", "Mon \n 14 Dec"])
	ax[:tick_params](labelsize = 14)

	ylabel("Response time [sec]", fontsize = 14)
	title("2KHz tone")

	figure()
	ax = axes()
	
	errorbar([1 2 3 4 5 6 7 8 9 10 11 12 13 14 15], mean(RT_8,1), fmt = "C0D", markersize = 10,
		yerr = std(RT_8,1)./sqrt(size(RT_8,1)), capsize = 10)

	ax[:set_xticks]([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0])
	ax[:set_xticklabels](["Mon \n 10 Dec", "Tue \n 11 Dec", "Wed \n 12 Dec", "Thur \n 13 Dec", "Fri \n 14 Dec",
						"Mon \n 17 Dec", "Tue \n 18 Dec", "Wed \n 19 Dec", "Thur \n 20 Dec", "Fri \n 21 Dec",
						"Tue \n 08 Jan", "Wed \n 09 Jan", "Thur \n 10 Jan", "Fri \n 11 Jan", "Mon \n 14 Dec"])
	ax[:tick_params](labelsize = 14)

	ylabel("Response time [sec]", fontsize = 14)
	title("8KHz tone")

	figure()
	ax = axes()
	
	errorbar([1 2 3 4 5 6 7 8 9 10 11 12 13 14 15], mean(Om_2,1), fmt = "C0D", markersize = 10,
		yerr = std(Om_2,1)./sqrt(size(Om_2,1)), capsize = 10)

	ax[:set_xticks]([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0])
	ax[:set_xticklabels](["Mon \n 10 Dec", "Tue \n 11 Dec", "Wed \n 12 Dec", "Thur \n 13 Dec", "Fri \n 14 Dec",
						"Mon \n 17 Dec", "Tue \n 18 Dec", "Wed \n 19 Dec", "Thur \n 20 Dec", "Fri \n 21 Dec",
						"Tue \n 08 Jan", "Wed \n 09 Jan", "Thur \n 10 Jan", "Fri \n 11 Jan", "Mon \n 14 Dec"])
	ax[:tick_params](labelsize = 14)

	ylabel("Omissions [%]", fontsize = 14)
	title("2KHz tone")

	figure()
	ax = axes()
	
	errorbar([1 2 3 4 5 6 7 8 9 10 11 12 13 14 15], mean(Om_8,1), fmt = "C0D", markersize = 10,
		yerr = std(Om_8,1)./sqrt(size(Om_8,1)), capsize = 10)

	ax[:set_xticks]([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0])
	ax[:set_xticklabels](["Mon \n 10 Dec", "Tue \n 11 Dec", "Wed \n 12 Dec", "Thur \n 13 Dec", "Fri \n 14 Dec",
						"Mon \n 17 Dec", "Tue \n 18 Dec", "Wed \n 19 Dec", "Thur \n 20 Dec", "Fri \n 21 Dec",
						"Tue \n 08 Jan", "Wed \n 09 Jan", "Thur \n 10 Jan", "Fri \n 11 Jan", "Mon \n 14 Dec"])
	ax[:tick_params](labelsize = 14)

	ylabel("Omissions [%]", fontsize = 14)
	title("8KHz tone")

	figure()
	ax = axes()
	
	errorbar([1 2 3 4 5 6 7 8 9 10 11 12 13 14 15], mean(prem,1), fmt = "C0D", markersize = 10,
		yerr = std(prem,1)./sqrt(size(prem,1)), capsize = 10)

	ax[:set_xticks]([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0])
	ax[:set_xticklabels](["Mon \n 10 Dec", "Tue \n 11 Dec", "Wed \n 12 Dec", "Thur \n 13 Dec", "Fri \n 14 Dec",
						"Mon \n 17 Dec", "Tue \n 18 Dec", "Wed \n 19 Dec", "Thur \n 20 Dec", "Fri \n 21 Dec",
						"Tue \n 08 Jan", "Wed \n 09 Jan", "Thur \n 10 Jan", "Fri \n 11 Jan", "Mon \n 14 Dec"])
	ax[:tick_params](labelsize = 14)

	ylabel("Prematures", fontsize = 14)

	show()
end


function plot_mi(mi_pr_v::Array{Float64,1}, mi_pp_v::Array{Float64,1}, mi_prp_v::Array{Float64,1}, 
				mi_ppr_v::Array{Float64,1}, ci_pr_v::Array{Tuple{Float64,Float64},1}, 
				ci_pp_v::Array{Tuple{Float64,Float64},1}, ci_prp_v::Array{Tuple{Float64,Float64},1},
				ci_ppr_v::Array{Tuple{Float64,Float64},1}, n_trials_in_the_past::Int64)

	x_ticks = 1:n_trials_in_the_past

	figure()
	scatter(1:n_trials_in_the_past, mi_pr_v, label = "Actual I")
	scatter((1:n_trials_in_the_past, 1:n_trials_in_the_past), ci_pr_v, label = "Shuffled confidence interval")
	xticks(x_ticks, [string(i) for i in 1:n_trials_in_the_past])
	xlabel("Trials in the past", fontsize = 14)
	ylabel("I", fontsize = 14)
	title("Press ; past reward", fontsize = 14)
	legend()

	figure()
	scatter(1:n_trials_in_the_past, mi_pp_v, label = "Actual I")
	scatter((1:n_trials_in_the_past, 1:n_trials_in_the_past), ci_pp_v, label = "Shuffled confidence interval")
	xticks(x_ticks, [string(i) for i in 1:n_trials_in_the_past])
	xlabel("Trials in the past", fontsize = 14)
	ylabel("I", fontsize = 14)
	title("Press ; past press", fontsize = 14)
	legend()

	figure()
	scatter(1:n_trials_in_the_past, mi_prp_v, label = "Actual I")
	scatter((1:n_trials_in_the_past, 1:n_trials_in_the_past), ci_prp_v, label = "Shuffled confidence interval")
	xticks(x_ticks, [string(i) for i in 1:n_trials_in_the_past])
	xlabel("Trials in the past", fontsize = 14)
	ylabel("I", fontsize = 14)
	title("Press ; past reward | past press", fontsize = 14)
	legend()

	figure()
	scatter(1:n_trials_in_the_past, mi_ppr_v, label = "Actual I")
	scatter((1:n_trials_in_the_past, 1:n_trials_in_the_past), ci_ppr_v, label = "Shuffled confidence interval")
	xticks(x_ticks, [string(i) for i in 1:n_trials_in_the_past])
	xlabel("Trials in the past", fontsize = 14)
	ylabel("I", fontsize = 14)
	title("Press ; past press | past reward", fontsize = 14)
	legend()
	
	show()
end

