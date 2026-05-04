class PartyMatchWndCommon extends UICommonAPI;

const UNION_MAKEROOM_NEW = 1;	//연합방 생성
const UNION_MAKEROOM_EDIT = 2;	//연합방 수정

function String GetAmbiguousLevelString( int a_Level, bool a_HasSpace )
{
	local String AmbiguousLevelString;	

	if( 10 > a_Level )
	{
		if( a_HasSpace )
			AmbiguousLevelString = "1 ~ 9";
		else
			AmbiguousLevelString = "1~9";
	}
	else if( 100 > a_Level )
	{
		if( a_HasSpace )
			AmbiguousLevelString = (a_Level/10) * 10 $ " ~ " $ (a_Level/10) * 10 + 9;
		else
			AmbiguousLevelString = (a_Level/10) * 10 $ "~" $ (a_Level/10) * 10 + 9;
	}
	else if ( 1000 > a_Level )
	{
		if( a_HasSpace )
			AmbiguousLevelString = (a_Level/10) * 10 $ " ~ " $ (a_Level/10) * 10 + 9; //"90 ~ " $ getInstanceUIData().MAXLV;
		else
			AmbiguousLevelString = (a_Level/10) * 10 $ "~" $ (a_Level/10) * 10 + 9;//"90~" $ getInstanceUIData().MAXLV;
	}

	return AmbiguousLevelString;
}
defaultproperties
{
}
