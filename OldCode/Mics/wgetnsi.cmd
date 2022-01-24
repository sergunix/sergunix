@echo on
REM []-------------------------------------------------------------------------
REM    ��������� ���� ���:
REM    ������� ������ ���������� ��� ��� � ��� ������;
REM    ��������� ���� ����������  ������ �� ���������;
REM    �������� ���������� ������ � FTP-�������;
REM    �������� ������ �� ����������� ����� ��� ��������������;
REM    � ������������� �������� ������ ����������.
REM
REM     (C) ������ ��� "������� �������� �����-���������" - ���������� �����
REM                               2002-2011
REM ---------------------------------------------------------------------------

REM ������������� ��������� ����� ����������
setlocal

REM ��� ��� �� ������������� ����
set LPU=13

REM FTP ������ 
set FTP_SERVER=ftp://miks:2fwy5jpy@mics.ltg.gazprom.ru

REM ������� �������
set WORKDISK=D:
set WORKPATH=\ARM_UPDATES\_Replication

REM ��� ����� ��������� �������
set LOGFILE=log_nsi.txt

REM ����� SMTP ������� ����������� �����
set SMTP=vhv-dc-01.corp.it.ltg.gazprom.ru

REM ���������� ������ � �������� ������
set MAIL_TO=sysadmin@vhv.ltg.gazprom.ru

REM ����������� ������
set MAIL_FROM=mics@vhv.ltg.gazprom.ru

REM ���� ���������
set THEME=����� ���������� ��� ��� ��������

REM ��� �������� %LPU%*.* - �������� ��� ������ ������� �������������
REM OLD set FILES=%LPU%*.*,*ond*.*,bnz%LPU%*.*,dgd%LPU%*.*,ms%LPU%*.*,MS%LPU%*.*,*OND*.*,BNZ%LPU%*.*,DGD%LPU%*.*,M2O00101$ORA%LPU%*.*,m2o00101$ora%LPU%*.*
set FILES=%LPU%*.*,dgd%LPU%*.*,DGD%LPU%*.*,bnz%LPU%*.*,BNZ%LPU%*.*,M2O00101$ORA%LPU%*.*,m2o00101$ora%LPU%*.*
set FILESYES=*.YES,*.ZIPYES,*.RARYES

REM =============================================
REM ��������� � ������� �������
%WORKDISK%
cd %WORKPATH%

REM =============================================
REM ���������� ����� ���������� ��� ��� � ����� LPU (������-13) � ��� ������
wget.exe %FTP_SERVER%/Mrs/ -P./ -o../%LOGFILE% -N -c -nH -r --cut-dirs=1 -R%FILESYES% -A%FILES% -X/Mrs/MRS_AGGR,/Mrs/MRS_BACK,/Mrs/MRS_SF,/Mrs/ORACLE,/Mrs/XI,/Mrs/GKI,/Mrs/OD,/Mrs/ASBU,/Mrs/MRS_FOND 
REM ������ � 03.04.2013 ��� ��� ����� ���-��� ���� 50���� --limit-rate=131072

REM =============================================
REM ��������� � ������� ������� ���-������
cd ..

REM =============================================
REM   �������� �� ��������� ������ � ���������� ������
REM ���� ���������� � ���������� ������ ���, �� ������ ������ �� ������
echo. >  SAVE%LOGFILE%
echo []-------------------------------------------------------------------------- >> SAVE%LOGFILE%
grep.exe saved %LOGFILE% | grep.exe -v .listing  >> SAVE%LOGFILE%

if errorlevel 2 goto ERR2
if errorlevel 1 goto ERR1
if errorlevel 0 goto ERR0
goto END

:ERR2
REM ���� �� ������ ��� ������� grep.exe 
goto END

:ERR1
REM �� ������� ������ ����� �� ������� grep.exe
goto END

:ERR0
REM =============================================
REM ���������� � ���������� ������ ����!
REM =============================================
REM ������� ������� � ������������� ������� �� �������������� ����
REM ���� �������� ����� ��� ������ RAR, ������ ZIP


grep.exe -i rar  	    SAVE%LOGFILE%
goto RAR%errorlevel%
:RAR2
:RAR1

grep.exe -i zip	    SAVE%LOGFILE%
goto ZIP%errorlevel%
:ZIP2
:ZIP1

REM �� ���������� �������, ������ �� �������������, ���� �� ������� ������
goto ZERAT

:RAR0
:ZIP0
REM =============================================
REM ���� ������, ������������� - ��������� � ������� �������
%WORKDISK%
cd %WORKPATH%

unzip -o *.zip
rar e -y *.rar
REM ������� ����� ��� �������������� � YES del /F /Q *.zip *.rar

cd .\MRS_NAKL
unzip -o *.zip
rar e -y *.rar
cd ..

cd .\MRS_Dogovor
unzip -o *.zip
rar e -y *.rar
cd..

:ZERAT
zerat smtphost:%SMTP% from:"%0 %MAIL_FROM%" to:"%MAIL_TO%" subject:"%THEME%" charset:windows-1251 type:multipart/mixed $boun "Content-type: text/plain; charset=Windows-1251" "   ����� ������ � ���������� ��Ȩ�� ������� ���!!!" %%PUT="SAVE%LOGFILE%" $incl "%LOGFILE%"
REM c 24.01.2011 ������ ������ ��� ��������� � ������� �� ������� ��� �������� �������
REM ��� �������� ��������� ������ ��� ����� �� ������� �� ��� �������
ECHO =============================================
ECHO ������������� �������� � ��� ������ ��� � �� ����
ECHO � ��������� ����� LOCK ��� �������������� ���������� �������
ECHO.
REM ���� �� ������� 60 ������, �� �������� � ������������ ������� 
REM c makensiora.cmd, ��� ������ �������� � ������������ �����
REM C:\Apps\Mics\info.key
ECHO --- ������� � ������� 60 ������ ��� ���������� �������� ������������ MRS ---
ECHO.
sleep.exe 60
recvnsi.cmd


:END
REM ������ ����� "echo 0x007" (������p���� ����)
REM echo 
