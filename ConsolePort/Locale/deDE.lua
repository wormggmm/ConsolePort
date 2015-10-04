if not GetLocale() == "deDE" then return end

local _, db = ...
db.TUTORIAL = {
	BIND  = {
		DEFAULT 			= "Click on a button to change its behaviour.",
		COMBO 				= "Click on a combination of %s to change it.",
		STATIC 				= "Select an action from the list to change %s",
		DYNAMIC 			= "Select any interface button with the cursor to change %s\n%s Apply %s Cancel ",
		APPLIED 			= "%s was applied to %s.",
		INVALID 			= "Error: Invalid button. New binding was discarded.",
		COMBAT 				= "Error: In combat! Exit combat to change your settings.",
		IMPORT 				= "Settings imported from %s. Press Okay to apply.",
		RESET 				= "Default settings loaded. Press Okay to apply.",
	},
	SETUP = {
		HEADER 				= "Setup: Assign controller buttons",
		HEADLINE 			= "Your controller bindings are incomplete.\nPress the requested button to map it.",
		OVERRIDE 			= "%s is already bound to %s.\nPress |T%s:20:20:0:0|t again to continue anyway.",
		INVALID 			= "Invalid binding.\nDid you press the correct button?",
		COMBAT 				= "You are in combat!",
		EMPTY 				= "<Empty>",
		SUCCESS 			= "|T%s:16:16:0:0|t was successfully bound to %s.",
		CONTINUE 			= "Press |T%s:20:20:0:0|t again to continue.",
		CONFIRM 			= "Press |T%s:20:20:0:0|t again to confirm.",
		CONTROLLER 			= "Select your preferred button layout by clicking a controller.",
	},
	SLASH = {
		COMBAT 				= "Error: Cannot reset addon in combat!",
		TYPE				= "Change controller type",
		RESET 				= "Full addon reset",
		BINDS 				= "Open binding menu",
	}
}
db.TOOLTIP = {
	CLICK = {
		COMPARE 			=	"Compare",
		QUEST_TRACKER 		=	"Set current quest",
		USE_NOCOMBAT 		=	"Use (out of combat)",
		BUY 				= 	"Buy",
		USE 				= 	"Use",
		EQUIP				= 	"Equip",
		SELL 				= 	"Sell",
		QUEST_DETAILS 		= 	"View quest details",
		PICKUP 				= 	"Pick up",
		CANCEL 				= 	"Cancel",
		STACK_BUY 			= 	"Buy a different amount",
		ADD_TO_EXTRA		= 	"Bind",
	}
}
db.XBOX = {
	CP_L_UP					=	"Up",
	CP_L_DOWN				=	"Down",
	CP_L_LEFT				=	"Left",
	CP_L_RIGHT				=	"Right",
	CP_TR1					=	"RB",
	CP_TR2					=	"RT",
	CP_R_UP					=	"Y",
	CP_X_OPTION				=	"A",
	CP_R_LEFT				=	"X",
	CP_R_RIGHT				=	"B",
	CP_L_OPTION				= 	"Back",
	CP_C_OPTION				=	"Guide",
	CP_R_OPTION				= 	"Start",
	HEADER_CP_LEFT 			= 	"Directional pad",
	HEADER_CP_RIGHT			= 	"Action buttons",
	HEADER_CP_CENTER		= 	"Center buttons",
	HEADER_CP_TRIG			=	"Triggers",
}
db.PS4 = {
	CP_L_UP					=	"Up",
	CP_L_DOWN				=	"Down",
	CP_L_LEFT				=	"Left",
	CP_L_RIGHT				=	"Right",
	CP_TR1					=	"R1",
	CP_TR2					=	"R2",
	CP_R_UP					=	"Triangle",
	CP_X_OPTION				=	"Cross",
	CP_R_LEFT				=	"Square",
	CP_R_RIGHT				=	"Circle",
	CP_L_OPTION				= 	"Share",
	CP_C_OPTION				=	"PS",
	CP_R_OPTION				= 	"Options",
	HEADER_CP_LEFT 			= 	"Directional pad",
	HEADER_CP_RIGHT			= 	"Action buttons",
	HEADER_CP_CENTER		= 	"Center buttons",
	HEADER_CP_TRIG			=	"Triggers",
}