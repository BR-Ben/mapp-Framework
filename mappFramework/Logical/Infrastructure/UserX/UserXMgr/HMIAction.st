
ACTION HMIAction: 
	// Check if the file name has already been used
	CASE UserXCheckState OF
		USERX_START:
			IF NOT UserXMgrUIConnect.Import.ShowDialog THEN
				UserXMgrUIConnect.Import.ShowDialog := TRUE;
			ELSE 
				UserXCheckState := USERX_WAIT_FOR_DIALOG;
			END_IF
		USERX_WAIT_FOR_DIALOG:
				UserXMgrUIConnect.Import.ShowDialog := FALSE;
				UserXCheckState := USERX_SET_RESPONSE;
		USERX_SET_RESPONSE:
			IF NOT(UserXMgrUIConnect.Status = mpUSERX_UI_STATUS_IDLE) THEN
				UserXMgrUIConnect.Import.Dialog.Cancel := TRUE;
			ELSE
				UserXMgrUIConnect.Import.Dialog.Cancel := FALSE;
				UserXCheckState := USERX_CONFIRM_RESPONSE;
			END_IF
		USERX_CONFIRM_RESPONSE:
			IF UserXMgrUIConnect.Status = mpUSERX_UI_STATUS_WAIT_DLG THEN
				UserXCheckState := USERX_START;
			ELSE
				UserXCheckState := USERX_FINISH;
			END_IF
		USERX_NEW_EXPORT:
			IF NOT UserXMgrUIConnect.Export.ShowDialog AND UserXMgrUIConnect.Status = mpUSERX_UI_STATUS_IDLE THEN
				UserXCheckState := USERX_START;
			END_IF			
		USERX_FINISH:
			
	END_CASE				
	// If new updates are made via export execute a check
	IF UserXMgrUIConnect.Export.ShowDialog THEN
		UserXCheckState := USERX_NEW_EXPORT;
	END_IF
	
	
	//Duplicate file checks
	HmiUserX.FileDuplicate := FALSE;
	FOR i := 0 TO ((SIZEOF(UserXMgrUIConnect.Import.Dialog.List.FileNames) / SIZEOF(UserXMgrUIConnect.Import.Dialog.List.FileNames[0])) - 1) DO
		temp := UserXMgrUIConnect.Export.Dialog.FileName;
		brsstrcat(ADR(temp),ADR('.usr'));
		IF (temp = UserXMgrUIConnect.Import.Dialog.List.FileNames[i]) AND HmiUserX.Export THEN
			HmiUserX.FileDuplicate := TRUE;
		END_IF
	END_FOR	
	
	IF HmiUserX.FileDuplicate AND (HmiUserX.ConfirmOverwrite) THEN
		UserXMgrUIConnect.Export.Dialog.Confirm := TRUE;
		HmiUserX.Export := FALSE;
		HmiUserX.ConfirmOverwrite := FALSE;
	ELSIF NOT HmiUserX.FileDuplicate AND HmiUserX.Export THEN
		UserXMgrUIConnect.Export.Dialog.Confirm := TRUE;
		HmiUserX.Export := FALSE;
	END_IF
	
	
END_ACTION
