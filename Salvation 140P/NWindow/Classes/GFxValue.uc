class GFxValue extends Object
	instanced
	native
	noexport;

//var native Ptr pValue;

native final function bool SetMemberFloat(string name, float value);
native final function bool SetMemberInt(string name, int value);
native final function bool SetMemberString(string name, string value);
native final function bool SetMemberValue(string name, out GFxValue value);
native final function bool SetMemberBool(string name, bool value);
native final function SetFloat( float value );
native final function SetInt( int value );
native final function SetBool( bool value );
native final function bool SetElement(int index, out GFxValue value);
native final function string GetString();
native final function bool GetBool();
native final function int GetInt();
native final function float GetFloat();
defaultproperties
{
}
