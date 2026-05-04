class ColorNickNameWnd extends UICommonAPI;

var WindowHandle 		ME;
var EditBoxHandle		NickNameEditBox;
var ComboBoxHandle		ColorComboBox;
var Array<Color>		ColorTable;
var array<int>          ColorIndexs;
var ButtonHandle		btnOK;
var ButtonHandle		BtnCancel;

var ItemID m_ClickedItemID;

function OnRegisterEvent()
{
	RegisterEvent(EV_ShowChangeNickNameNColor);
}

function OnLoad()
{
	SetClosingOnESC();

	ME = GetWindowHandle("ColorNickNameWnd");
	NickNameEditBox = GetEditBoxHandle("ColorNickNameWnd.Edit_NickName");
	ColorComboBox = GetComboBoxHandle("ColorNickNameWnd.ColorCombo");
	btnOK =	GetButtonHandle("ColorNickNameWnd.BtnOk");
	BtnCancel = GetButtonHandle("ColorNickNameWnd.BtnCancel");
	
	/*
//	0	기본값
	ColorTable[0].A =	255;
	ColorTable[0].R = 	162;
	ColorTable[0].G =	249;
	ColorTable[0].B =	236;
//	0: 	핑크색
	ColorTable[1].A = 	255;
	ColorTable[1].R =	255;
	ColorTable[1].G =	147;
	ColorTable[1].B =	147;
//	1:	로즈핑크
	ColorTable[2].A = 	255;
	ColorTable[2].R =	255;
	ColorTable[2].G =	74;
	ColorTable[2].B =	125;
//	2:	레몬옐로우
	ColorTable[3].A = 	255;
	ColorTable[3].R =	255;
	ColorTable[3].G =	251;
	ColorTable[3].B =	153;
//	3:	라일락
	ColorTable[4].A = 	255;
	ColorTable[4].R =	240;
	ColorTable[4].G =	155;
	ColorTable[4].B =	253;
//	4:	코발트 바이올렛
	ColorTable[5].A = 	255;
	ColorTable[5].R =	147;
	ColorTable[5].G =	93;
	ColorTable[5].B =	255;
//	5:	민트그린
	ColorTable[6].A = 	255;
	ColorTable[6].R =	162;
	ColorTable[6].G =	255;
	ColorTable[6].B =	0;
//	6:	피콕그린
	ColorTable[7].A = 	255;
	ColorTable[7].R =	0;
	ColorTable[7].G =	170;
	ColorTable[7].B =	164;
//	7:	옐로우 오커
	ColorTable[8].A = 	255;
	ColorTable[8].R =	175;
	ColorTable[8].G =	152;
	ColorTable[8].B =	120;
//	8:	쵸콜렛
	ColorTable[9].A = 	255;
	ColorTable[9].R =	158;
	ColorTable[9].G =	103;
	ColorTable[9].B =	75;
//	9: 	실버
	ColorTable[10].A = 	255;
	ColorTable[10].R =	155;
	ColorTable[10].G =	155;
	ColorTable[10].B =	155;
*/
}

function OnChangeEditBox( String strID )
{
	switch( strID )
	{
	case "Edit_NickName":
		BtnOk.EnableWindow();
		break;
	}
}

function OnEvent(int EventID, string Param)
{
	switch (EventID)
	{
		case EV_ShowChangeNickNameNColor:
			OnOpenWnd(param);
		break;		
	}
}

function OnOpenWnd(string param)
{
	local UserInfo UserInfo;
	local color colNickNameColor;
	local string strNickName;
	local int i;
	//local int ColorID;

	local int numOfColorIndex;
	local int colorIndex;
	local int colorSysStringID;
	

	ParseItemID(param, m_ClickedItemID);	
	parseInt ( param, "numOfColorIndex", numOfColorIndex );

	ColorTable.Remove( 0, ColorTable.Length  );
	ColorIndexs.Remove( 0, ColorIndexs.Length  );

	ColorTable.Length = numOfColorIndex + 1;
	ColorIndexs.Length = numOfColorIndex + 1;

//	0	기본값
	ColorTable[0].A =	255;
	ColorTable[0].R = 	162;
	ColorTable[0].G =	249;
	ColorTable[0].B =	236;

	// 기본 값 포함 렌스
	
	//ColorID = 0;
	ColorComboBox.Clear();
	//Debug ("color" @ param ) ;
	for ( i = 1 ; i <= numOfColorIndex ; i ++ ) 
	{
		parseInt ( param, "ColorIndex" $i, colorIndex );	
		ColorTable[i] = GetNicknameColorWithIndex( colorIndex );
		ColorIndexs[i] = colorIndex;

		parseInt ( param, "ColorSysStringID" $i, colorSysStringID );
		ColorComboBox.AddStringWithColor(GetSystemString(colorSysStringID), ColorTable[i]);
		//Debug ( "OnOpenWnd" @  GetSystemString(colorSysStringID) @ ColorTable[i].A @ ColorTable[i].R @ ColorTable[i].G @ ColorTable[i].B @ colorIndex ) ;		
	}	
	
	ME.ShowWindow();
	NickNameEditBox.SetFocus();
	
	if( GetPlayerInfo( userinfo ) )
	{
		strNickName = UserInfo.strNickName;
		colNickNameColor = UserInfo.NicknameColor;
		NickNameEditBox.Clear();
		NickNameEditBox.SetString( strNickName);

		for(i=0; i<numOfColorIndex;i++)
		{
			if (ColorTable[i] == colNickNameColor)
			{
				//ColorID=i-1;
				ColorComboBox.SetSelectedNum(i-1);
				BtnOk.DisableWindow();
				break;
			}
		}
	}	
}

function OnComboboxItemSelected(string ComboboxName, int ID)
{
	local UserInfo UserInfo;
	local color colNickNameColor;
	//~ local string strNickName;
	//~ local int i;	
	
	if( GetPlayerInfo( userinfo ) )
	{
		colNickNameColor = UserInfo.NicknameColor;
		if (ColorTable[ID+1] == colNickNameColor)
		{
			BtnOk.DisableWindow();
		}
		else
		{
			BtnOk.EnableWindow();
		}
	}
}


function OnClickButton(string ButtonName)
{
	local int SelectedNum;
	switch(ButtonName)
	{
	case "BtnOk":
		if (NickNameEditBox.GetString() != "")
		{
			SelectedNum = ColorComboBox.GetSelectedNum();
			SelectedNum = SelectedNum;
			
			RequestChangeNicknameNColor( ColorIndexs[SelectedNum + 1] ,NickNameEditBox.GetString(), m_ClickedItemID);
			ME.HideWindow();
		}
		break;
	case "BtnCancel":
		ME.HideWindow();
		break;
	}
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( "ColorNickNameWnd" ).HideWindow();
}
defaultproperties
{
}
