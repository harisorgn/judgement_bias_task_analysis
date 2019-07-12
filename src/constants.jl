
#const sigma_tone = 0.3 ;

#const p_x_2 = Normal(log(2.0), sigma_tone) ;
#const p_x_8 = Normal(log(8.0), sigma_tone) ;
#const p_x_amb = Normal(log(5.0), sigma_tone) ;

const dt = 1e-1 ;
const rt_max = 20.0 ;

const r_2 = 4.0 ;
const r_8 = 1.0 ;

const rt_criterion = 0.25 ; 
const acc_criterion = 0.0 ; 
const incorr_timeout = 5.0 ;

const train_header_v = ["Batch_ID", "Session", "HH_RT", "LL_RT", "HL_RT", "LH_RT",
				"HH", "LL", "HL", "LH", "Om_H", "Om_L", "Prem"] ;

const probe_header_v = ["Batch_ID", "HH_RT", "LL_RT", "HL_RT", "LH_RT",
					"MH_RT", "ML_RT", "HH", "LL", "HL", "LH",
					"MH", "ML", "CBI",
					"Om_H", "Om_L", "Om_M", "Prem", "M_RT"] ;
					

