

seq_probe_header_vec = ["Batch_ID", "Cor_4_RT", "Cor_1_RT", "Cor_Amb_4_RT", "Cor_Amb_1_RT", 
				"Incor_4_RT", "Incor_1_RT", "Incor_Amb_4_RT", "Incor_Amb_1_RT",
				"Cor_4", "Cor_1", "Cor_Amb_4", "Cor_Amb_1", "Incor_Amb_4", "Incor_Amb_1",
				"Amb_4_RT", "Amb_1_RT", "Amb_4", "Amb_1"] ;

train_header_vec = ["Batch_ID", "Session", "HH_RT", "LL_RT", "HL_RT", "LH_RT",
				"HH_p", "LL_p", "HL_p", "LH_p", "Om_H", "Om_L", "Prem"] ;

probe_header_vec = ["Batch_ID", "HH_RT", "LL_RT", "HL_RT", "LH_RT",
					"MH_RT", "ML_RT", "HH_p", "LL_p", "HL_p", "LH_p",
					"MH_p", "ML_p", "CBI",
					"Om_H", "Om_L", "Om_M", "Prem", "M_RT"] ;

pattern_vec = [:hard, :hard, :easy, :easy, :easy, :hard, :hard, :easy, 
				   :easy, :easy, :hard, :hard, :easy, :easy, :hard, :hard] ;

CB_4 = [:A :B :D :C ;
	  :B :C :A :D ;
	  :C :D :B :A ;
	  :D :A :C :B ;
	  :B :C :A :D ;
	  :C :D :B :A ;
	  :D :A :C :B ;
	  :A :B :D :C ;
	  :C :D :B :A ;
	  :D :A :C :B ;
	  :A :B :D :C ;
	  :B :C :A :D ;
	  :D :A :C :B ;
	  :A :B :D :C ;
	  :B :C :A :D ;
	  :C :D :B :A ] ;

CB_2 = [:A :B ;
		:A :B ;
		:B :A ;
		:B :A ;
		:A :B ;
		:A :B ;
		:B :A ;
		:B :A ;
		:B :A ;
		:B :A ;
		:A :B ;
		:A :B ;
		:B :A ;
		:B :A ;
		:A :B ;
		:A :B ] ;