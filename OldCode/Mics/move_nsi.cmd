@echo off
REM []-------------------------------------------------------------------------
REM    ��������� ���� ���:
REM    �������� �������������� ������� ��� �� FTP-������ ����
REM
REM     (C) ������ ��� "������� �������� �����-���������" - ���������� �����
REM                               2002-2013
REM ---------------------------------------------------------------------------



REM ������������� ��������� ����� ����������
setlocal

REM ��� ��� �� ������������� ����
set LPU=13

REM ����� SMTP ������� ����������� �����
set SMTP=vhv-dc-01.corp.it.ltg.gazprom.ru

REM ���������� ������ � �������� ������
set MAIL_TO=sysadmin@vhv.ltg.gazprom.ru

REM ����������� ������
set MAIL_FROM=move_nsi.cmd mics@vhv.ltg.gazprom.ru

REM ���� ���������
set THEME=������� �������������� ������� ��� �� FTP-������ ����

REM ���� ���������
set BODY=������c ������ ����� �������� �� ������� ������������� ��������� �� FTP-�������! ������� ���� V: ������� vhv-mrs-00!!!

REM ���� ���������
set BODYSEND="������ ������ ���������� move_nsi.cmd �� FTP-������ ����"

REM ��������� � ��������� ������� ���� �� �������
set BODYSENDLOCK="��������! �� ���������� ������� ������ move_nsi.cmd,��������, ������� �����! "

REM ��� ����� ����������
set LOCKFILE=D:\ARM_UPDATES\MOVE_NSI_LCK.TXT

REM ��� ����� ��������� �������������� ������ ��� ��������
set LOGFILE=D:\ARM_UPDATES\log_makensi.txt

REM ���� � �������� �������� � ��������
set NSIDISK=D:
set NSIPATH=\ARM_UPDATES\_Replication
set NSIFONDPATH=Y:\#Volhov\ARM_UPDATES\_Replication\MRS_SF

REM ������ ��� ���������� �� ���-����� ������ ����������
set NSISTRING=_Replication

REM ����������� ���� ftp �������
set VDISK=V:

REM =============================================
REM ������� ���� ���������� ���������� �������
if exist %LOCKFILE% goto LOCK
echo. > %LOCKFILE%
echo File %LOCKFILE% locked!  >> %LOCKFILE%
date /t >>  %LOCKFILE%
time /t >> %LOCKFILE%

REM ���������� ���� ������������ FTP-�������
FTPUSE %VDISK% mics.ltg.gazprom.ru 2fwy5jpy /USER:miks 
%VDISK%
cd \Mrs\ORACLE
if not exist %VDISK%\Mrs\ORACLE goto NOFTP

REM =============================================
REM ��������� � ������� �������
%NSIDISK%
cd %NSIPATH%

REM ��������� MRS-����� �� ���� ������������ FTP-�������
REM ��������� ������ ��������� ������ mrs (��� ��� 1251 ��� ������� DIR)
chcp 1251
del /q %LOGFILE%
@echo : >  %LOGFILE%
@echo. >>  %LOGFILE%

ECHO ��������� ��� ��� ������������� ��������
REM =============================================
ECHO ��������� ���, �������.SQL, �������.Oracle � .\ORACLE 
dir     .\ORACLE\*.* | grep.exe -i ora >> %LOGFILE%
move /Y .\ORACLE\*.*    %VDISK%\Mrs\ORACLE
dir %VDISK%\Mrs\ORACLE\*$ORA%LPU%(*.*      | grep.exe -i ora  >> %LOGFILE%
ECHO.

ECHO ��������� ASBU � ASBU - �����. ����. ���������� �����
dir     .\ASBU\*ASBU99$*ORA%LPU%*.* | grep.exe -i ASBU >> %LOGFILE%
move /Y .\ASBU\*ASBU99$*ORA%LPU%*.*    %VDISK%\Mrs\ASBU
dir %VDISK%\Mrs\ASBU\*ASBU99$*ORA%LPU%*.*  | grep.exe -i ASBU >> %LOGFILE%
ECHO.

ECHO ��������� ��� - �������� � MRS_Dogovor
dir     .\MRS_Dogovor\DGD*(%LPU%)*.* | grep.exe -i mrs >> %LOGFILE%
move /Y .\MRS_Dogovor\DGD*(%LPU%)*.*   %VDISK%\Mrs\MRS_Dogovor
dir %VDISK%\Mrs\MRS_Dogovor\DGD*(%LPU%)*.* | grep.exe -i mrs  >> %LOGFILE%
ECHO.

ECHO ��������� ��������� ��� ������ �������� � ������������� � MRS_NAKL
dir     .\MRS_NAKL\BNZ*(%LPU%)*	.* | grep.exe -i mrs >> %LOGFILE%
move /Y .\MRS_NAKL\BNZ*(%LPU%)*.*   %VDISK%\Mrs\MRS_NAKL
dir %VDISK%\Mrs\MRS_NAKL\BNZ*(%LPU%)*.*    | grep.exe -i mrs  >> %LOGFILE%
ECHO.

ECHO ��������� ����� ������� � ������ � MRS_SF (��� ��������� ��������� �� ������ �����-�������)
if not exist %NSIFONDPATH% goto NOFOND
dir %NSIFONDPATH%\SFB99(%LPU%)*.* | grep.exe -i mrs >> %LOGFILE%
move /Y %NSIFONDPATH%\SFB99(%LPU%)*.*  %VDISK%\Mrs\MRS_SF
dir %VDISK%\Mrs\MRS_SF\SFB99(%LPU%)*.*     | grep.exe -i mrs  >> %LOGFILE%
ECHO.

ECHO ��������� ��������� ��� �� (�������� � ��������. �����)
REM ����������� 01.06.2011, ��� ��� �� �������� � 28.10.2010 � ���. ����� � 22.10.2011
rem dir     .\XI\*.* | grep.exe -i xi >> %LOGFILE%
rem move /Y .\XI\*.*    %VDISK%\Mrs\XI
REM dir %VDISK%\Mrs\XI\*MS%LPU%*.*             | grep.exe -i xi   >> %LOGFILE%
rem ECHO.

chcp 866                                 
REM ����� ���������� ������� ����� ���������� �����
del /F /Q %LOCKFILE%

goto DONE

:NOFOND   
chcp 866                      
REM ����� ���������� ������� ����� ���������� �����
del /F /Q %LOCKFILE%
set BODY=������c ������ ����� �������� �� ������� ������������� �������� %NSIFONDPATH% ������� ����������� � ����� ������� vhv-fs-01!!!

:NOFTP
REM =============================================
REM ������� ������� ���������� ftp
REM ��������� � ������� �������
%NSIDISK%
cd %NSIPATH%
cd ..
zerat smtphost:%SMTP% from:"%MAIL_FROM%" to:"%MAIL_TO%" subject:"Not Executed! %THEME%" charset:windows-1251 type:multipart/mixed $boun "Content-type: text/plain; charset=Windows-1251" %BODY%

echo %BODY%

goto END


:LOCK
REM =============================================
REM ������� ��������� � �������� ������� �� �������������� ����
REM ��������� � ������� �������
%NSIDISK%
cd %NSIPATH%
@echo. >>  %LOCKFILE%
REM =============================================
ECHO ��������� ������ ��� ��������������, �� �� ���������� ��-�� ���������� ������
chcp 1251
dir     .\ORACLE\*.* | grep.exe -i ora >> %LOCKFILE%
dir     .\ASBU\*ASBU99$*ORA%LPU%*.* | grep.exe -i ASBU >> %LOCKFILE%
dir     .\MRS_Dogovor\DGD*(%LPU%)*.* | grep.exe -i mrs >> %LOCKFILE%
dir     .\MRS_NAKL\BNZ*(%LPU%)*	.* | grep.exe -i mrs >> %LOCKFILE%
dir %NSIFONDPATH%\SFB99(%LPU%)*.* | grep.exe -i mrs >> %LOCKFILE%
chcp 866                                 
cd ..
echo LOCKED!
zerat smtphost:%SMTP% from:"%MAIL_FROM%" to:"%MAIL_TO%" subject:"WARNING! %THEME%" charset:windows-1251 type:multipart/mixed $boun "Content-type: text/plain; charset=windows-1251" %BODYSENDLOCK% %%PUT="%LOCKFILE%"
rem charset=CP-866

REM ������ ����� "echo 0x007" (������p���� ����)
REM echo 

goto END

:DONE

REM =============================================
REM ������� ������� � ������������ ������
%NSIDISK%
cd %NSIPATH%
cd ..
zerat smtphost:%SMTP% from:"%MAIL_FROM%" to:"%MAIL_TO%" subject:"%THEME%" charset:windows-1251 type:multipart/mixed $boun "Content-type: text/plain; charset=windows-1251" %BODYSEND% %%PUT="%LOGFILE%"


:END
REM ��������� ���� ������������ FTP-�������
FTPUSE %VDISK% /delete 

