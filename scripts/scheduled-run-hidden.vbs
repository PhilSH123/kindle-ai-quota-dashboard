Option Explicit

Dim files, shell, runner, command, result
Set files = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")
runner = files.BuildPath(files.GetParentFolderName(WScript.ScriptFullName), "scheduled-run.ps1")
command = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File """ & runner & """"
result = shell.Run(command, 0, True)
WScript.Quit result
