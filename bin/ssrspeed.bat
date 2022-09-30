@echo off&
set bin=%~dp0
for %%a in ("%bin:~0,-1%") do set SSRSpeed=%%~dpa
set PYTHONPATH=%SSRSpeed%;%PYTHONPATH%
cd %SSRSpeed%
echo.
echo ================== SSRSpeedN ==================
if exist "%SSRSpeed%\venv\Scripts\activate.bat" ( call "%SSRSpeed%\venv\Scripts\activate.bat" )
if defined VIRTUAL_ENV ( echo ��ǰ���� %VIRTUAL_ENV% ) else ( echo ��ǰĿ¼ %SSRSpeed% )
if exist "%SystemRoot%\SysWOW64" path %path%;%windir%\SysNative;%SystemRoot%\SysWOW64;%SSRSpeed%
bcdedit >nul
if '%errorlevel%' NEQ '0' ( echo ��ǰȨ�� ��ͨ�û� ) else ( echo ��ǰȨ�� ����Ա )
if exist "%SSRSpeed%\resources\clients\v2ray-core\v2ray.exe" ( set v1=1 ) else ( set v1=0 )
set /a v3=v1+v2
if %v3%==2 ( echo �Ѿ���װ V2ray-core ) else ( echo ��δ��װ V2ray-core )
:start
echo ===============================================
echo [1] ��ʼ���٣��Զ������ã�
echo [2] �״����а�װ pip �����֧�֣������ԱȨ�ޣ�
echo [3] ��������
echo [4] ��ǰ SSRSpeed �汾
echo [5] Ϊ�������л�ȡ����ԱȨ��
echo ===============================================
echo ��ѡ�� [1-5]: 
choice /c 12345
if %errorlevel%==5 ( goto :uac )
if %errorlevel%==4 ( goto :ver )
if %errorlevel%==3 ( goto :help )
if %errorlevel%==2 ( goto :pip )
if %errorlevel%==1 ( goto :test2 )


:pip
if exist "%SystemRoot%\SysWOW64" path %path%;%windir%\SysNative;%SystemRoot%\SysWOW64;%SSRSpeed%
bcdedit >nul
if '%errorlevel%' NEQ '0' ( echo X ��ǰ�޹���ԱȨ�ޣ��޷���װ�� && echo. && echo * ������ͨ������ 5 ��ȡȨ�ޣ����Ҽ��Թ���ԱȨ�������� && pause && goto :start ) else ( goto :pip2 )
:pip2
python -m pip install --upgrade pip
pip3 install -r "%SSRSpeed%\requirements.txt"
:: pip3 install aiofiles
:: pip3 install aiohttp-socks
:: pip3 install Flask-Cors
:: pip3 install geoip2
:: pip3 install loguru
:: pip3 install pilmoji
:: pip3 install PySocks
:: pip3 install PyYAML
:: pip3 install requests
:: pip3 install selenium
:: pip3 install webdriver-manager
pause
goto :start

:ver
python -m ssrspeed --version
pause
goto :start

:help
echo.
echo [1] ԭ�ģ�en��
echo [2] ���루zh��
choice /c 12
if %errorlevel%==2 ( goto :fy )
if %errorlevel%==1 ( goto :yw )

:yw

echo.
echo usage: ssrspeed [-h] [--version] [-d DIR] [-u URL] [-i IMPORT_FILE] [-c GUICONFIG] [-mc MAX_CONNECTIONS] [-M {default,pingonly,stream,all,wps}]
echo                 [-m {stasync,socket,speedtestnet,fast}] [--reject-same] [--include FILTER [FILTER ...]] [--include-group GROUP [GROUP ...]]
echo                 [--include-remark REMARKS [REMARKS ...]] [--exclude EFILTER [EFILTER ...]] [--exclude-group EGFILTER [EGFILTER ...]]
echo                 [--exclude-remark ERFILTER [ERFILTER ...]] [-g GROUP_OVERRIDE] [-C RESULT_COLOR] [-s {speed,rspeed,ping,rping}]
echo                 [--skip-requirements-check] [-w] [-l LISTEN] [-p PORT] [--download {all,client,database}] [--debug]
echo.
echo optional arguments:
echo  -h, --help            show this help message and exit
echo  --version             show program's version number and exit
echo  -d DIR, --dir DIR     Specify a work directory with clients and data.
echo  -u URL, --url URL     Load ssr config from subscription url.
echo  -i IMPORT_FILE, --import IMPORT_FILE
echo                        Import test result from json file and export it.
echo  -c GUICONFIG, --config GUICONFIG
echo                        Load configurations from file.
echo  -mc MAX_CONNECTIONS, --max-connections MAX_CONNECTIONS
echo                        Set max number of connections.
echo  -M {default,pingonly,stream,all,wps}, --mode {default,pingonly,stream,all,wps}
echo                        Select test mode in [default, pingonly, stream, all, wps].
echo  -m {stasync,socket,speedtestnet,fast}, --method {stasync,socket,speedtestnet,fast}
echo                        Select test method in [speedtestnet, fast, socket, stasync].
echo  --reject-same         Reject nodes that appear later with the same server and port as before.
echo  --include FILTER [FILTER ...]
echo                        Filter nodes by group and remarks using keyword.
echo  --include-group GROUP [GROUP ...]
echo                        Filter nodes by group name using keyword.
echo  --include-remark REMARKS [REMARKS ...]
echo                        Filter nodes by remarks using keyword.
echo  --exclude EFILTER [EFILTER ...]
echo                        Exclude nodes by group and remarks using keyword.
echo  --exclude-group EGFILTER [EGFILTER ...]
echo                        Exclude nodes by group using keyword.
echo  --exclude-remark ERFILTER [ERFILTER ...]
echo                        Exclude nodes by remarks using keyword.
echo  -g GROUP_OVERRIDE     Manually set group.
echo  -C RESULT_COLOR, --color RESULT_COLOR
echo                        Set the colors when exporting images..
echo  -s {speed,rspeed,ping,rping}, --sort {speed,rspeed,ping,rping}
echo                        Select sort method in [speed, rspeed, ping, rping], default not sorted.
echo  --skip-requirements-check
echo                        Skip requirements check.
echo  -w, --web             Start web server.
echo  -l LISTEN, --listen LISTEN
echo                        Set listen address for web server.
echo  -p PORT, --port PORT  Set listen port for web server.
echo  --download {all,client,database}
echo                        Download resources in ['all', 'client', 'database']
echo  --debug               Run program in debug mode.
echo.
echo  Test Modes
echo  Mode                 Remark
echo  DEFAULT               Freely configurable via ssrspeed.json
echo  TCP_PING              Only tcp ping, no speed test
echo  STREAM                Only streaming unlock test
echo  ALL                   Full speed test (exclude web page simulation)
echo  WEB_PAGE_SIMULATION   Web page simulation test
echo.
echo  Test Methods
echo  Methods              Remark
echo  ST_ASYNC              Asynchronous download with single thread
echo  SOCKET                Raw socket with multithreading
echo  SPEED_TEST_NET        Speed Test Net speed test
echo  FAST                  Fast.com speed test
echo.
pause
goto :start

:fy

echo.
echo �÷���ssrspeed [-h] [--version] [-d DIR] [-u URL] [-i IMPORT_FILE] [-c GUICONFIG] [-mc MAX_CONNECTIONS] [-M {default,pingonly,stream,all,wps}]
echo               [-m {stasync,socket,speedtestnet,fast}] [--reject-same] [--include FILTER [FILTER ...]] [--include-group GROUP [GROUP ...]]
echo               [--include-remark REMARKS [REMARKS ...]] [--exclude EFILTER [EFILTER ...]] [--exclude-group EGFILTER [EGFILTER ...]]
echo               [--exclude-remark ERFILTER [ERFILTER ...]] [-g GROUP_OVERRIDE] [-C RESULT_COLOR] [-s {speed,rspeed,ping,rping}]
echo               [--skip-requirements-check] [-w] [-l LISTEN] [-p PORT] [--download {all,client,database}] [--debug]
echo.
echo ��ѡ������
echo.
echo  -h, --help            ���������Ϣ���˳�
echo  --version             ����汾�Ų��˳�
echo  -d DIR, --dir DIR     ָ������ clients �� data ��Ŀ¼��Ĭ��Ϊ��ǰĿ¼.
echo  -u URL, --url URL     ͨ���ڵ㶩�����Ӽ��ؽڵ���Ϣ.
echo  -i IMPORT_FILE, --import IMPORT_FILE
echo                        ���� json �ļ�������Խ��.
echo  -c GUICONFIG, --config GUICONFIG
echo                        ͨ���ڵ������ļ����ؽڵ���Ϣ.
echo  -mc MAX_CONNECTIONS, --max-connections MAX_CONNECTIONS
echo                        ���������������ĳЩ������֧�ֲ������ӣ�������Ϊ 1.
echo  -M {default,pingonly,stream,all,wps}, --mode {default,pingonly,stream,all,wps}
echo                        �� [default, pingonly, stream, all, wps] ��ѡ�����ģʽ.
echo  -m {stasync,socket,speedtestnet,fast}, --method {stasync,socket,speedtestnet,fast}
echo                        �� [stasync, socket, speedtestnet, fast] ��ѡ����Է���.
echo  --reject-same         ֻ������ͬ�������Ͷ˿ڵ�һ�γ��ֵĽڵ�.
echo  --include FILTER [FILTER ...]
echo                        ͨ���ڵ��ʶ������ɸѡ�ڵ�.
echo  --include-group GROUP [GROUP ...]
echo                        ͨ������ɸѡ�ڵ�.
echo  --include-remark REMARKS [REMARKS ...]
echo                        ͨ���ڵ��ʶɸѡ�ڵ�.
echo  --exclude EFILTER [EFILTER ...]
echo                        ͨ���ڵ��ʶ�������ų��ڵ�.
echo  --exclude-group EGFILTER [EGFILTER ...]
echo                        ͨ�������ų��ڵ�.
echo  --exclude-remark ERFILTER [ERFILTER ...]
echo                        ͨ���ڵ��ʶ�ų��ڵ�.
echo  -g GROUP_OVERRIDE     �Զ����������.
echo  -C RESULT_COLOR, --color RESULT_COLOR
echo                        �趨���ٽ��չʾ��ɫ.
echo  -s {speed,rspeed,ping,rping}, --sort {speed,rspeed,ping,rping}
echo                        ѡ��ڵ�����ʽ [���ٶ����� / �ٶȵ��� / ���ӳ����� / �ӳٵ���]��Ĭ�ϲ�����.
echo  --skip-requirements-check
echo                        ����ȷ��.
echo  -w, --web             �������������.
echo  -l LISTEN, --listen LISTEN
echo                        ��������������ļ�����ַ.
echo  -p PORT, --port PORT  ��������������ļ����˿�.
echo  --download {all,client,database}
echo                        �� [all, client, database] ��ѡ��������Դ����.
echo  --debug               ���� debug ģʽ.
echo.
echo  ����ģʽ
echo  ģʽ                 ��ע
echo  DEFAULT               ����ͨ�� ssrspeed.json ��������
echo  TCP_PING              �� tcp ping�����ٶȲ���
echo  STREAM                ����ý���������
echo  ALL                   ȫ�ٲ��ԣ���������ҳģ�⣩
echo  WEB_PAGE_SIMULATION   ��ҳģ�����
echo.
echo  ���Է���
echo  ����                 ��ע
echo  ST_ASYNC              ���߳��첽����
echo  SOCKET                ���ж��̵߳�ԭʼ�׽���
echo  SPEED_TEST_NET        SpeedTest.Net �ٶȲ���
echo  FAST                  Fast.com �ٶȲ���
echo.
pause
goto :start

:test2
echo.
echo * �����Զ���ѡ�����ջس���������
echo.
:test3
set /p a="���������Ķ������ӣ��������գ�: "
if "%a%"=="" (
goto :test3
) else (
goto :jx1
)
:jx1
echo.
echo * ���� 2 �����ͨ���ո�ָ��ؼ���
echo.
set /p e="1. ʹ�ùؼ���ͨ��ע��ɸѡ�ڵ�: "
set /p i="2. ͨ��ʹ�ùؼ��ֵ�ע���ų��ڵ�: "
set /p k="3. �������������: "
set /p m="4. ����ͼ��ʱ������ɫ [origin, poor]��Ĭ�� origin: "
set /p n="5. �� [speed, rspeed, ping, rping] ��ѡ���������򷽷���Ĭ�ϲ�������Ĭ��������: "
echo.
if "%e%"=="" (
set e= && goto :jx1
) else (
set e=--include-remark %e% && goto :jx1
)
:jx1
if "%i%"=="" (
set i= && goto :jx2
) else (
set i=--exclude-remark %i% && goto :jx2
)
:jx2
if "%k%"=="" (
set k= && goto :jx3
) else (
set k=-g %k% && goto :jx3
)
:jx3
set l=-y && goto :jx4
:jx4
if "%m%"=="" (
set m= && goto :jx5
) else (
set m=-C %m% && goto :jx5
)
:jx5
if "%n%"=="" (
set n= && goto :jx6
) else (
set n=-s %n% && goto :jx6
)
:jx6
set o=--skip-requirements-check && goto :jx7
:jx7
echo python -m ssrspeed -u "%a%" %e% %i% %k% %y% %m% %n%  %o%
echo.
python -m ssrspeed -u "%a%" %e% %i% %k% %y% %m% %n%  %o%
pause
set a=
set e=
set i=
set k=
set y=
set m=
set n=
set o=
goto :start

:uac
echo.
if exist "%SystemRoot%\SysWOW64" path %path%;%windir%\SysNative;%SystemRoot%\SysWOW64;%SSRSpeed%
bcdedit >nul
if '%errorlevel%' NEQ '0' ( goto UACPrompt ) else ( goto UACAdmin )
:UACPrompt
echo ��ʾ��ͨ��������װ��Ҫ����ԱȨ�ޣ����� 4��
echo.
echo       ���Ի�ȡ����ԱȨ�ޣ���������
ping -n 3 127.0.0.1>nul && %1 start "" mshta vbscript:createobject("shell.application").shellexecute("""%~0""","::",,"runas",1)(window.close)&exit
exit /B
:UACAdmin
cd /d "%SSRSpeed%"
echo.
echo �ѻ�ȡ����ԱȨ��
echo.
pause
goto :start
