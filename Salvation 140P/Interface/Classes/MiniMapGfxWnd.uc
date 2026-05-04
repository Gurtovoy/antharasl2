/******************************************
	Дата 11.12.2023 2:02

	Разработчик: BITHACK

	Copyright (c) Ваша компания

	Описание скрипта:....

*******************************************/

class MiniMapGfxWnd extends L2UIGFxScript;

function OnRegisterEvent()
	{

	}

function OnLoad()
	{
	AddState( "GAMINGSTATE" );
	SetContainerWindow(WINDOWTYPE_DECO_NORMAL, 447);

	}

function onCallUCFunction( string functionName, string param )
	{

  switch ( functionName )
	{
   case "ucExecuteCommand" :
   if (param != "")
	{
	ExecuteCommand(param);
	}
     break;

	}
	}
