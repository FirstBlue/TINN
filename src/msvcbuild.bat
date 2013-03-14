@rem Script to build TINN with MSVC.
@rem
@rem Either open a "Visual Studio .NET Command Prompt"
@rem (Note that the Express Edition does not contain an x64 compiler)
@rem -or-
@rem Open a "Windows SDK Command Shell" and set the compiler environment:
@rem     setenv /release /x86
@rem   -or-
@rem     setenv /release /x64
@rem
@rem Then cd to this directory and run this script.

@if not defined INCLUDE goto :FAIL

@setlocal
@set LJCOMPILE=cl /nologo /c /MD /O2 /W3 /D_CRT_SECURE_NO_DEPRECATE
@set LJLINK=link /nologo
@set LJMT=mt /nologo
@set LJLIB=lib /nologo
@set LUAC=luajit -b
@set LJDLLNAME=lua51.dll
@set LJLIBNAME=lua51.lib
@set ALL_LIB=Collections.lua


@rem The TINN core library
%LUAC% base64.lua base64.obj
%LUAC% BinaryStream.lua BinaryStream.obj
%LUAC% BitBang.lua BitBang.obj
%LUAC% Collections.lua Collections.obj
%LUAC% CoSocketIo.lua CoSocketIo.obj
%LUAC% dkjson.lua dkjson.obj
%LUAC% FileStream.lua FileStream.obj
%LUAC% httpstatus.lua httpstatus.obj
%LUAC% HttpChunkIterator.lua HttpChunkIterator.obj
%LUAC% HttpHeaders.lua HttpHeaders.obj
%LUAC% HttpMessage.lua HttpMessage.obj
%LUAC% HttpRequest.lua HttpRequest.obj
%LUAC% HttpResponse.lua HttpResponse.obj
%LUAC% MemoryStream.lua MemoryStream.obj
%LUAC% mime.lua mime.obj
%LUAC% peg_http.lua peg_http.obj
%LUAC% re.lua re.obj
%LUAC% ResourceMapper.lua ResourceMapper.obj
%LUAC% SimpleFiber.lua SimpleFiber.obj
%LUAC% StaticService.lua StaticService.obj
%LUAC% stream.lua stream.obj
%LUAC% stringzutils.lua stringzutils.obj
%LUAC% url.lua url.obj
%LUAC% utils.lua utils.obj
%LUAC% zlib.lua zlib.obj
@set TINNLIB=base64.obj BinaryStream.obj BitBang.obj Collections.obj CoSocketIo.obj dkjson.obj FileStream.obj httpstatus.obj HttpChunkIterator.obj HttpHeaders.obj HttpMessage.obj HttpRequest.obj HttpResponse.obj MemoryStream.obj mime.obj peg_http.obj re.obj ResourceMapper.obj SimpleFiber.obj StaticService.obj stream.obj stringzutils.obj url.obj utils.obj zlib.obj

@rem Create the Win32 specific stuff
%LUAC% Win32/BCrypt.lua BCrypt.obj
%LUAC% Win32/BCryptUtils.lua BCryptUtils.obj
%LUAC% Win32/EventScheduler.lua EventScheduler.obj
%LUAC% Win32/guiddef.lua guiddef.obj
%LUAC% Win32/NativeSocket.lua NativeSocket.obj
%LUAC% Win32/NetStream.lua NetStream.obj
%LUAC% Win32/Network.lua Network.obj
%LUAC% Win32/SocketIoPool.lua SocketIoPool.obj
%LUAC% Win32/SocketPool.lua SocketPool.obj
%LUAC% Win32/SocketUtils.lua SocketUtils.obj
%LUAC% Win32/StopWatch.lua StopWatch.obj
%LUAC% Win32/WebApp.lua WebApp.obj
%LUAC% Win32/win_error.lua win_error.obj
%LUAC% Win32/win_kernel32.lua win_kernel32.obj
%LUAC% Win32/win_socket.lua win_socket.obj
%LUAC% Win32/WinBase.lua WinBase.obj
%LUAC% Win32/WinCrypt.lua WinCrypt.obj
%LUAC% Win32/WinSock_Utils.lua WinSock_Utils.obj
%LUAC% Win32/WTypes.lua WTypes.obj

@set WIN32LIB=BCrypt.obj BCryptUtils.obj EventScheduler.obj guiddef.obj NativeSocket.obj NetStream.obj Network.obj SocketIoPool.obj SocketPool.obj SocketUtils.obj StopWatch.obj WebApp.obj win_error.obj win_kernel32.obj win_socket.obj WinBase.obj WinCrypt.obj WinSock_Utils.obj WTypes.obj
 


%LJCOMPILE% lpeg.c
@if errorlevel 1 goto :BAD
@set CLIBS=lpeg.obj

%LJCOMPILE% tinn.c
@if errorlevel 1 goto :BAD
%LJLINK% /out:tinn.exe tinn.obj %CLIBS% %TINNLIB% %WIN32LIB% %LJLIBNAME%
@if errorlevel 1 goto :BAD
if exist tinn.exe.manifest^
  %LJMT% -manifest tinn.exe.manifest -outputresource:tinn.exe

@del *.obj *.manifest
@echo.
@echo === Successfully built TINN for Windows/%LJARCH% ===

@goto :END
:BAD
@echo.
@echo *******************************************************
@echo *** Build FAILED -- Please check the error messages ***
@echo *******************************************************
@goto :END
:FAIL
@echo You must open a "Visual Studio .NET Command Prompt" to run this script
:END