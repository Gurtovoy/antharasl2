class FileListAPI extends UIEventManager
	native;

native static function array<FileNameInfo> GetFileInfoList(string filePath, array<string> arrFileExt);
native static function array<DriveInfo> GetDriveInfoList();
native static function bool ShowFlash(string filePath);
defaultproperties
{
}
