
const train_header_v = ["Batch_ID", "Session", "HH_RT", "LL_RT", "HL_RT", "LH_RT",
				"HH", "LL", "HL", "LH", "Om_H", "Om_L", "Prem"] ;

const probe_header_v = ["Batch_ID", "HH_RT", "LL_RT", "HL_RT", "LH_RT",
					"MH_RT", "ML_RT", "HH", "LL", "HL", "LH",
					"MH", "ML", "CBI",
					"Om_H", "Om_L", "Om_M", "Prem", "M_RT"] ;

const probe_mult_p_header_v = ["Batch_ID", "HH_RT", "LL_RT", "HL_RT", "LH_RT",
					"M1H_RT", "M2H_RT", "M3H_RT", "M4H_RT", 
					"M1L_RT", "M2L_RT", "M3L_RT", "M4L_RT",
					"HH", "LL", "HL", "LH",
					"M1H", "M2H", "M3H", "M4H", 
					"M1L", "M2L", "M3L", "M4L",
					"Om_H", "Om_L", "Om_M1", "Om_M2", "Om_M3", "Om_M4",
					"Prem"] ;

const probe_mult_p_1v1_header_v = ["Batch_ID", "HH_RT", "LL_RT", "HL_RT", "LH_RT",
					"M1H_RT", "M2H_RT", "M3H_RT", 
					"M1L_RT", "M2L_RT", "M3L_RT",
					"HH", "LL", "HL", "LH",
					"M1H", "M2H", "M3H", 
					"M1L", "M2L", "M3L", 
					"Om_H", "Om_L", "Om_M1", "Om_M2", "Om_M3", 
					"Prem"] ;

const exclude_v = ["CH1_1", "CH1_4", "CH1_6", "CH1_9", "CH1_15", "CH5_10"] ;

const acc_criterion = 0.0 ;
const rt_criterion = 0.25 ;
const rt_max = 20.0 ;