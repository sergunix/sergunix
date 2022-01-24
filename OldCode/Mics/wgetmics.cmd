@echo on
REM []-------------------------------------------------------------------------
REM    ��������� ���� ���:
REM    ������� ������ ���������� �� � �������� �� ����� �������� MIKS;
REM    ������������ ����� �� ��������� ���� MICSYYYY\MM-DD*, ��������
REM    MICS2008\06-03-13, �� ���� ���\�����-����-���   
REM    ��������� ������� zarplata � ���������� ����� ���������� �������� 
REM    �� ��������� � ������� ���� �����-����-���
REM    ��������� ���� ����������  ������ �� ���������;
REM    �������� ������ �� ����������� ����� ��� ��������������;
REM    � ������������� �������� ������ ����������.
REM
REM     (C) ���������� ����� ������ ��� "������� �������� �����-���������"
REM                               2002-2010
REM ---------------------------------------------------------------------------

REM =============================================
REM ������� ��� ���������
set YEAR=2013

REM FTP ������
set FTP_SERVER=ftp://volhov:wohv9hxz@corp-ftp.corp.it.ltg.gazprom.ru
set FTP_PATH=/software/MIKS/MIKS

REM ��� ����� ��������� �������
set LOGFILE=log_mics.txt

REM ����� SMTP ������� ����������� �����
set SMTP=vhv-dc-01.corp.it.ltg.gazprom.ru

REM ���������� ������ � �������� ������
set MAIL_TO=sysadmin@vhv.ltg.gazprom.ru

REM ����������� ������
set MAIL_FROM=mics@vhv.ltg.gazprom.ru

REM ���� ���������
set THEME=����� ���������� �� � ��������

REM ��� ����� ����������
set LOCKFILE=D:\ARM_UPDATES\WGETMICS_LCK.TXT

REM ��������� � ��������� ������� ���� �� �������
set BODYSENDLOCK="��������! �� ���������� ������� ������ wgetmics.cmd, ��������, ������� ������� ��������!"
REM =============================================

REM ��������� � ������� �������
D:
cd \ARM_UPDATES\MICS%YEAR%

REM ��������� �� ������� Date ���������� ��� � ������
set DAY=%date:~0,2%
set MONTH=%date:~3,2%
rem date  /T > ../%LOGFILE%
rem for /f "tokens=1 delims=." %%i in (../%LOGFILE%) do set DAY=%%i
rem for /f "tokens=2 delims=." %%i in (../%LOGFILE%) do set MONTH=%%i
REM =============================================


REM ������� ���� ���������� ���������� �������
if exist %LOCKFILE% goto LOCK
echo. > %LOCKFILE%
echo File %LOCKFILE% locked!  >> %LOCKFILE%
date /t >>  %LOCKFILE%
time /t >> %LOCKFILE%


REM =============================================
REM   ���������� ����� ���������� �� � �������� �� ����� �������� MIKS
REM   � �� ��������� � ������� ���� �����-����-���
wget %FTP_SERVER%%FTP_PATH%%YEAR%/ -o../%LOGFILE% -P. -c -N -r -nH --cut-dirs=3 -I%FTP_PATH%%YEAR%/%MONTH%-%DAY%* 
REM ������ � 03.04.2013 ��� ��� ����� ���-��� ���� 50���� --limit-rate=131072

REM ============================================= 
REM  ��������� ������� zarplata � ���������� ����� ���������� �������� 
REM  �� ��������� � ������� ���� �����-����-���
REM  � %LOGFILE% ��������� log � ������� ����� -a
wget %FTP_SERVER%%FTP_PATH%%YEAR%/zarplata/ -a../%LOGFILE% -P. -c -N -r -nH --cut-dirs=3 -I%FTP_PATH%%YEAR%/zarplata/%MONTH%-%DAY%*,%FTP_PATH%%YEAR%/zarplata/DOC* 
REM ������ � 03.04.2013 ��� ��� ����� ���-��� ���� 50���� --limit-rate=131072

REM ����� ���������� ������� ����� ���������� �����
del /F /Q %LOCKFILE%

REM ��������� � ������� ������� ���-������
cd ..

REM =============================================
REM   �������� �� ��������� ������ � ������������ ������ (������ �������)
GREP "No such file" %LOGFILE% > SAVE%LOGFILE%
GREP "No such directory" %LOGFILE% >> SAVE%LOGFILE%

REM   �������� �� ��������� ������ � ���������� ������
GREP saved %LOGFILE% | GREP -v .listing >> SAVE%LOGFILE%

if errorlevel 2 goto ERR2
if errorlevel 1 goto ERR1
if errorlevel 0 goto ERR0
goto END

:ERR2
REM ���� �� ������ ��� ������� GREP 
goto END

:ERR1
REM �� ������� ������ ����� �� ������� GREP
goto END

:ERR0
REM =============================================
REM ������� ������� � ������������� ������� �� �������������� ����
REM sendmail.exe %SMTP% %MAIL_TO%=%MAIL_FROM% SAVE%LOGFILE%
zerat smtphost:%SMTP% from:"%0 %MAIL_FROM%" to:"%MAIL_TO%" subject:"%THEME%" charset:windows-1251 type:multipart/mixed $boun "Content-type: text/plain; charset=Windows-1251" %%PUT="SAVE%LOGFILE%" $incl "%LOGFILE%"

REM ������ ����� "echo 0x007" (������p���� ����)
REM echo 
goto END

:LOCK
REM =============================================
REM ������� ��������� � �������� ������� �� �������������� ����
echo LOCK

REM ��������� � ������� ������� ���-������
cd ..

zerat smtphost:%SMTP% from:"%0 %MAIL_FROM%" to:"%MAIL_TO%" subject:"%THEME%" charset:windows-1251 type:multipart/mixed $boun "Content-type: text/plain; charset=windows-1251" %BODYSENDLOCK% %%PUT="%LOCKFILE%"


:END