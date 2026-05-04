class PropertyControllerHandle extends WindowHandle
	native;

//For PropertyController
native final function SetProperty( EXMLControlType a_Type, WindowHandle a_WindowHandle );
native final function Clear();
native final function ClearValue();
native final function int GetPropertyHeight();
native final function UpdatePropertyGroup( string GroupName );

//For PropertyGroup
native final function EControlPropertyGroupType GetGroupType( string GroupName );
native final function SetGroupCheck( string GroupName, bool value);
native final function bool GetGroupCheck( string GroupName );
native final function DeleteGroup( string GroupName );
native final function string AddGroup();
native final function SetGroupExpandState( string GroupName, bool bExpand );
native final function SetGroupVisible( string GroupName, bool bShow );

//For PropertyItem
native final function EControlPropertyItemType GetItemType( string ItemName );
native final function SetItemBooleanValue( string ItemName, bool Value );
native final function SetItemIntegerValue( string ItemName, int Value );
native final function SetItemStringValue( string ItemName, string Value );
native final function bool GetItemBooleanValue( string ItemName );
native final function int GetItemIntegerValue( string ItemName );
native final function string GetItemStringValue( string ItemName );
defaultproperties
{
}
