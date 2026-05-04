class TargetStatusBuff1Wnd extends UICommonAPI;


var WindowHandle Me;

//버프 보여 줄 StatusIconHandle
var StatusIconHandle	StatusIcons;


function OnRegisterEvent()
{
}

function OnLoad()
{
	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();

	if(CREATE_ON_DEMAND==0)
	{
		Initialize();
	}
	else
		InitializeCOD();

	Load();
}

function Initialize()
{
	Me = GetHandle( "TargetStatusBuff1Wnd" );
	StatusIcons = StatusIconHandle( GetHandle( "TargetStatusBuff1Wnd.StatusIcons" ) );
}


function InitializeCOD()
{
	Me = GetWindowHandle( "TargetStatusBuff1Wnd" );
	StatusIcons = GetStatusIconHandle( "TargetStatusBuff1Wnd.StatusIcons" );
}

function Load()
{

}

function showBuff(array<StatusIconInfo> info)
{
	local int i;
	local int j;
	local int line;
	local int length;	
	local int remainder;
	local int linecount;
	
	info = arrayReverse(info);

	linecount = 0;
	length = info.Length;
	line = ( (length - 1) / 6 ) + 1;
	remainder = length % 6;

	//Debug("length>>"$string(length));//12
	//Debug("line>>"$string(line));//2
	//Debug("remainder>>"$string(remainder));//0

	ResetBuffIcon();
	reSizeWindow(length);
	
	if( line < 2)
	{
		StatusIcons.AddRow();

		for( i = 0 ; i < length ; i++ )
		{
			StatusIcons.AddCol( 0, info[i] );
		}
	}
	else
	{	
		if( remainder == 0 )
		{  
			remainder = 6;
		}

		for( j = line - 1 ; j >= 1 ; j-- )
		{
			StatusIcons.AddRow();
			for( i = remainder + ( (j-1) * 6) ; i < remainder + (j*6) ; i++ )
			{
				StatusIcons.AddCol( linecount, info[i] );
			}
			linecount++;
		}

		StatusIcons.AddRow();
		for( i = 0 ; i < remainder ; i++ )
		{			
			StatusIcons.AddCol( linecount, info[i] );
		}
		linecount++;
	}
}

//창 싸이즈 버프의 양에 따라 변경
function reSizeWindow(int count)
{
	local int w;
	local int h;

	if( count > 5 )
	{
		w = 168;
	}
	else
	{
		w = ( 26 * count ) + 12;
	}

	h = 26 * ( ( (count - 1) / 6 ) + 1 ) + 12;

	Me.SetWindowSize( w, h );
}

//스킬 역순으로 배열 Reverse
function array<StatusIconInfo> arrayReverse( array<StatusIconInfo> info )
{
	local int i;
	local array<StatusIconInfo> infoRe;

	for( i = info.Length - 1 ; i >= 0 ; i-- )
	{
		infoRe.Insert( infoRe.Length, 1 );
		infoRe[infoRe.Length -1 ] = info[i];
	}

	return infoRe;
}


//버프 아이콘 All Clear
function ResetBuffIcon()
{
	StatusIcons.Clear();	
}
defaultproperties
{
}
