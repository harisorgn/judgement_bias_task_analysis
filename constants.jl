
train_header_v = ["Batch_ID", "Session", "HH_RT", "LL_RT", "HL_RT", "LH_RT",
				"HH", "LL", "HL", "LH", "Om_H", "Om_L", "Prem"] ;

probe_header_v = ["Batch_ID", "HH_RT", "LL_RT", "HL_RT", "LH_RT",
					"MH_RT", "ML_RT", "HH", "LL", "HL", "LH",
					"MH", "ML", "CBI",
					"Om_H", "Om_L", "Om_M", "Prem", "M_RT"] ;

pattern_vec = [:hard, :hard, :easy, :easy, :easy, :hard, :hard, :easy, 
				   :easy, :easy, :hard, :hard, :easy, :easy, :hard, :hard] ;

exclude_v = ["CH1_1", "CH1_4", "CH1_6", "CH1_9", "CH1_15", "CH5_10"] ;

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