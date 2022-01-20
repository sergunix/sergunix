@echo on
REM []-------------------------------------------------------------------------
REM    �������� 䠩� ���:
REM    ����窨 䠩��� ���������� �� � �ணࠬ� �� ���� ��⠫��� MIKS;
REM    ����稢����� 䠩�� �� ��⠫���� ⨯� MICSYYYY\MM-DD*, ���ਬ��
REM    MICS2008\06-03-13, � ���� ���\�����-����-��   
REM    �஢��塞 ��⠫�� zarplata � ����稢��� 䠩�� ���������� �ணࠬ� 
REM    �� ��⠫���� � ⥪�騬 ���� �����-����-���
REM    �뤥����� ���� ����砭���  䠩��� �� ��⮪���;
REM    �������� ���쬠 �� ���஭��� ����� ��� ���ନ஢����;
REM    � �ந��������� ����㧪� 䠩��� ९����権.
REM
REM     (C) ���客᪮� ����� 䨫��� ��� "����஬ �࠭ᣠ� �����-������"
REM                               2002-2010
REM ---------------------------------------------------------------------------

REM =============================================
REM ����稩 ��� �ணࠬ��
set YEAR=2013

REM FTP ��ࢥ�
set FTP_SERVER=ftp://volhov:wohv9hxz@corp-ftp.corp.it.ltg.gazprom.ru
set FTP_PATH=/software/MIKS/MIKS

REM ��� 䠩�� ��⮪��� ����窨
set LOGFILE=log_mics.txt

REM ���� SMTP �ࢥ� ���஭��� �����
set SMTP=vhv-dc-01.corp.it.ltg.gazprom.ru

REM �����⥫� ���� � ����㧪� 䠩���
set MAIL_TO=sysadmin@vhv.ltg.gazprom.ru

REM ��ࠢ�⥫� ����
set MAIL_FROM=mics@vhv.ltg.gazprom.ru

REM ���� ᮮ�饭��
set THEME=����� ���������� �� � �ணࠬ�

REM ��� 䠩�� �����஢��
set LOCKFILE=D:\ARM_UPDATES\WGETMICS_LCK.TXT

REM ����饭�� � ����୮� ����᪥ ⮣� �� ��⭨��
set BODYSENDLOCK="��������! �� �����訫�� ���� ����� wgetmics.cmd, ��������, ����窠 ᫨誮� ���񬭠�!"
REM =============================================

REM ���室�� � ࠡ�稩 ��⠫��
D:
cd \ARM_UPDATES\MICS%YEAR%

REM ��ନ�㥬 �� ������� Date ��६���� ��� � �����
set DAY=%date:~0,2%
set MONTH=%date:~3,2%
rem date  /T > ../%LOGFILE%
rem for /f "tokens=1 delims=." %%i in (../%LOGFILE%) do set DAY=%%i
rem for /f "tokens=2 delims=." %%i in (../%LOGFILE%) do set MONTH=%%i
REM =============================================


REM ������� 䠩� �����஢�� ����୮�� ����᪠
if exist %LOCKFILE% goto LOCK
echo. > %LOCKFILE%
echo File %LOCKFILE% locked!  >> %LOCKFILE%
date /t >>  %LOCKFILE%
time /t >> %LOCKFILE%


REM =============================================
REM   ����稢��� 䠩�� ���������� �� � �ணࠬ� �� ���� ��⠫��� MIKS
REM   � �� ��⠫���� � ⥪�騬 ���� �����-����-���
wget %FTP_SERVER%%FTP_PATH%%YEAR%/ -o../%LOGFILE% -P. -c -N -r -nH --cut-dirs=3 -I%FTP_PATH%%YEAR%/%MONTH%-%DAY%* 
REM �࠭� � 03.04.2013 ⠪ ��� ����� ���-�� �⠫ 50���� --limit-rate=131072

REM ============================================= 
REM  �஢��塞 ��⠫�� zarplata � ����稢��� 䠩�� ���������� �ணࠬ� 
REM  �� ��⠫���� � ⥪�騬 ���� �����-����-���
REM  � %LOGFILE% ������塞 log � ������� ���� -a
wget %FTP_SERVER%%FTP_PATH%%YEAR%/zarplata/ -a../%LOGFILE% -P. -c -N -r -nH --cut-dirs=3 -I%FTP_PATH%%YEAR%/zarplata/%MONTH%-%DAY%*,%FTP_PATH%%YEAR%/zarplata/DOC* 
REM �࠭� � 03.04.2013 ⠪ ��� ����� ���-�� �⠫ 50���� --limit-rate=131072

REM ����� �����஢�� ����᪠ �⮣� ���������� 䠩��
del /F /Q %LOCKFILE%

REM ���室�� � ࠡ�稩 ��⠫�� ���-䠩���
cd ..

REM =============================================
REM   �뤥���� �� ��⮪��� ����� � ������砭��� 䠩��� (�訡�� ����㯠)
GREP "No such file" %LOGFILE% > SAVE%LOGFILE%
GREP "No such directory" %LOGFILE% >> SAVE%LOGFILE%

REM   �뤥���� �� ��⮪��� ����� � ����砭��� 䠩���
GREP saved %LOGFILE% | GREP -v .listing >> SAVE%LOGFILE%

if errorlevel 2 goto ERR2
if errorlevel 1 goto ERR1
if errorlevel 0 goto ERR0
goto END

:ERR2
REM ���� �� ������ ��� ������� GREP 
goto END

:ERR1
REM �� 㤠���� ��祣� ���� �� ������� GREP
goto END

:ERR0
REM =============================================
REM ��᫠�� ���䠩� � �ந��������� ����窥 �� ����������� ��
REM sendmail.exe %SMTP% %MAIL_TO%=%MAIL_FROM% SAVE%LOGFILE%
zerat smtphost:%SMTP% from:"%0 %MAIL_FROM%" to:"%MAIL_TO%" subject:"%THEME%" charset:windows-1251 type:multipart/mixed $boun "Content-type: text/plain; charset=Windows-1251" %%PUT="SAVE%LOGFILE%" $incl "%LOGFILE%"

REM ������ ����� "echo 0x007" (�⠭��p�� ���)
REM echo 
goto END

:LOCK
REM =============================================
REM ��᫠�� ᮮ�饭�� � �����襩 ����窥 �� ����������� ��
echo LOCK

REM ���室�� � ࠡ�稩 ��⠫�� ���-䠩���
cd ..

zerat smtphost:%SMTP% from:"%0 %MAIL_FROM%" to:"%MAIL_TO%" subject:"%THEME%" charset:windows-1251 type:multipart/mixed $boun "Content-type: text/plain; charset=windows-1251" %BODYSENDLOCK% %%PUT="%LOCKFILE%"


:END