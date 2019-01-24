using CSV, DataStreams, XLSX, DataFrames

function date_sort(fv :: Array{String})

	date_m = Array{Any,2}(undef, length(fv), 4) ;

	i = 1 ;
	for date in fv
		date_m[i,1] = tryparse(Int64, date[1:2]) ;

		if occursin("Jan", date)
			date_m[i,2] = 1 ;
		elseif occursin("Feb", date)
			date_m[i,2] = 2 ;
		elseif occursin("Mar", date)
			date_m[i,2] = 3 ;
		elseif occursin("Apr", date)
			date_m[i,2] = 4 ;
		elseif occursin("May", date)
			date_m[i,2] = 5 ;
		elseif occursin("Jun", date)
			date_m[i,2] = 6 ;
		elseif occursin("Jul", date)
			date_m[i,2] = 7 ;
		elseif occursin("Aug", date)
			date_m[i,2] = 8 ;
		elseif occursin("Sep", date)
			date_m[i,2] = 9 ;
		elseif occursin("Oct", date)
			date_m[i,2] = 10 ;
		elseif occursin("Nov", date)
			date_m[i,2] = 11 ;
		elseif occursin("Dec", date)
			date_m[i,2] = 12 ;
		else
			println("Invalid date")
		end

		date_m[i,3] = tryparse(Int64, date[8:11]) ;
		date_m[i,4] = date ;
		i += 1 ;
	end

	#date_m = sortrows(date_m, by = x->(x[3],x[2],x[1],x[4]))
	#sort!(date_m, by = x->(x[3],x[2],x[1],x[4]))
	sort!(date_m, dims = 1, by = x->x[3])
	sorted_fv = Array{String, 1}(undef, length(fv)) ;

	for i = 1 : length(fv)
		sorted_fv[i] = date_m[i,4] ;
	end
	return sorted_fv
end

path = "./exp/" ;

if isempty(path)
	file_vec = date_sort(filter(x->occursin(".csv", x), readdir())) ;
else
	file_vec = date_sort(filter(x->occursin(".csv", x), readdir(path))) ;
end

file = CSV.File(file_vec[1])

println(file)