class OlympiadPlayer2Wnd extends OlympiadPlayerWnd;

function OnLoad()
{
	SetPlayerNum(2);
	Super.OnLoad();
}
function UpdateUsersInfo()
{
	if (m_IsPlayer == 1) // 관전자 일때만 띄워줌
		Super.UpdateUsersInfo();
}
defaultproperties
{
}
