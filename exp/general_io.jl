

function read_csv_var_cols(file_path::String)

	# read a csv file with a variable number of columns across rows
	# missing data elements are filled with ""
	# headers are automatically generated as col1, col2 etc

	max_ncols = 0 ;

	f = open(file_path)
	while !eof(f)
		new_line = split(strip(readline(f)),',') ;
		if length(new_line) > max_ncols
			max_ncols = length(new_line)
		end
	end
	close(f)

	f = open(file_path)
	headers = [string("col",i) for i = 1 : max_ncols]
	ncols = max_ncols ;
	data = [String[] for i=1:ncols]
	while !eof(f)
		new_line = split(strip(readline(f)),',')
		length(new_line)<ncols && append!(new_line,["" for i=1:ncols-length(new_line)])
		for i=1:ncols
		  push!(data[i],new_line[i])
		end
	end

	close(f)
	return DataFrame(;OrderedDict(Symbol(headers[i])=>data[i] for i=1:ncols)...)
end

function write_xlsx(row_write_v::Array{Array{Any,1},1}, session::Symbol, in_file::String, in_path::String)

	xlsx_file = string(in_path, in_file[1:11],".xlsx") ;

	if session == :probe || session == :probe_1v1 || session == :probe_var_p_1v1
		header_v = probe_header_v ;
	elseif session == :probe_mult_p 
		header_v = probe_mult_p_header_v ;
	elseif session == :probe_mult_p_1v1 
		header_v = probe_mult_p_1v1_header_v ;
	else
		header_v = train_header_v ;
	end

	column_write_v = Array{Array{Any,1},1}() ;

	for i = 1 : length(row_write_v[1])
		push!(column_write_v, map(x -> x[i], row_write_v)) ;
	end 

	df = DataFrames.DataFrame(Dict(map((x,y) -> x=>y, header_v, column_write_v))) ;
	
	XLSX.writetable(xlsx_file, DataFrames.eachcol(df), DataFrames.names(df), overwrite = true) ;
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

