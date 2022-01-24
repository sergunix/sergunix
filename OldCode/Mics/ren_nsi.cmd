@echo off
REM []-------------------------------------------------------------------------
REM    ��������� ���� ���:
REM    �������������� ���������� ������ � FTP-������� � *.yes;
REM
REM     (C) ������ ��� "������� �������� �����-���������" - ���������� �����
REM                               2002-2013
REM ---------------------------------------------------------------------------

REM ������������� ��������� ����� ����������
setlocal

REM ��� ��� �� ������������� ����
set LPU=13

REM ������� �������
set WORKDISK=D:
set WORKPATH=\ARM_UPDATES\_Replication

REM ����� SMTP ������� ����������� �����
set SMTP=vhv-dc-01.corp.it.ltg.gazprom.ru

REM ���������� ������ � �������� ������
set MAIL_TO=sysadmin@vhv.ltg.gazprom.ru

REM ����������� ������
set MAIL_FROM=ren_nsi.cmd mics@vhv.ltg.gazprom.ru

REM ���� ���������
set REN_THEME=�������������� ���������� ������ � FTP-������� � *.yes

REM ��� ����� ��������� ��������������� ������ � YES ��� ��������
set REN_LOGFILE=D:\ARM_UPDATES\log_renamensi.txt

REM ���� ���������
set REN_BODY=�������������� �� ���� ��������� � .YES, �� ������� ������������� \Mrs\MRS_BACK �� FTP-�������!

REM ����������� ���� ftp �������
set VDISK=V:

REM []--- ��������� �� ������� Date ���������� ���� ����������. 10-11-2010 ������ �� ����� ������� 
set HOUR=%time:~0,2%

REM =============================================
REM �������� ���, ��� �� ��������, ���� ��������� �� � 22 ����!
REM � 22 ���� ����� wgetnsi.cmd �������� � 08.10.2009, 
REM          ��� ��� �������������� ��������� �� getnsi.cmd, 
REM          ������� ��� �������� wgetnsi.cmd ������� (����� �� ���� ��������)

echo  �������� ���, ��� �� �������� �� ����, ���� ��������� �� � 22 ����!
if NOT %HOUR% == 22 call wgetnsi.cmd 

REM ���������� ���� ������������ FTP-�������
FTPUSE %VDISK% mics.ltg.gazprom.ru 2fwy5jpy /USER:miks 
%VDISK%
cd \Mrs\ORACLE
if not exist %VDISK%\Mrs\ORACLE goto NOFTP

REM ������� ��������������� ����� �����
del /Q %VDISK%\Mrs\M2O00101$ORA%LPU%*.*YES
del /Q %VDISK%\Mrs\MRS_NAKL\BNZ%LPU%*.*YES
del /Q %VDISK%\Mrs\MRS_Dogovor\DGD%LPU%*.*YES
del /Q %VDISK%\Mrs\MRS_SYNC_ORACLE\%LPU%*.*YES

REM ��������� � ������� �������
%WORKDISK%
cd %WORKPATH%
cd ..

REM ������ "���������� � ��������������� ������ �� FTP �������:"
echo L�������� � �������������v� ����� �� FTP-�������: > %REN_LOGFILE%
echo. >> %REN_LOGFILE%
REM (��� ��� 1251 ��� ������� DIR)
chcp 1251

REM ��������������� �� ����� ������������ FTP-�������
rename %VDISK%\Mrs\M2O00101$ORA%LPU%*.mrs   M2O00101$ORA%LPU%*.YES
rename %VDISK%\Mrs\M2O00101$ORA%LPU%*.zip   M2O00101$ORA%LPU%*.ZIPYES
rename %VDISK%\Mrs\M2O00101$ORA%LPU%*.rar   M2O00101$ORA%LPU%*.RARYES
dir    %VDISK%\Mrs\M2O00101$ORA%LPU%*.*YES | grep -i YES >> %REN_LOGFILE%
rename %VDISK%\Mrs\MRS_NAKL\BNZ%LPU%*.mrs   BNZ%LPU%*.YES
rename %VDISK%\Mrs\MRS_NAKL\BNZ%LPU%*.zip   BNZ%LPU%*.ZIPYES
rename %VDISK%\Mrs\MRS_NAKL\BNZ%LPU%*.rar   BNZ%LPU%*.RARYES
dir    %VDISK%\Mrs\MRS_NAKL\BNZ%LPU%*.*YES | grep -i YES >> %REN_LOGFILE%
rename %VDISK%\Mrs\MRS_Dogovor\DGD%LPU%*.mrs DGD%LPU%*.YES
rename %VDISK%\Mrs\MRS_Dogovor\DGD%LPU%*.zip DGD%LPU%*.ZIPYES
rename %VDISK%\Mrs\MRS_Dogovor\DGD%LPU%*.rar DGD%LPU%*.RARYES
dir    %VDISK%\Mrs\MRS_Dogovor\DGD%LPU%*.*YES | grep -i YES >> %REN_LOGFILE%
rename %VDISK%\Mrs\MRS_SYNC_ORACLE\%LPU%*.mrs %LPU%*.YES
rename %VDISK%\Mrs\MRS_SYNC_ORACLE\%LPU%*.zip %LPU%*.ZIPYES
rename %VDISK%\Mrs\MRS_SYNC_ORACLE\%LPU%*.rar %LPU%*.RARYES
dir    %VDISK%\Mrs\MRS_SYNC_ORACLE\%LPU%*.*YES | grep -i YES >> %REN_LOGFILE%

chcp 866

REM ������� ���������� � ��������������� ������ �� ��� �������
zerat smtphost:%SMTP% from:"%MAIL_FROM%" to:"%MAIL_TO%" subject:"%REN_THEME%" charset:windows-1251 type:multipart/mixed $boun "Content-type: text/plain; charset=Windows-1251" %%PUT="%REN_LOGFILE%"

REM =============================================
REM ������� ��� �������� ZIP � RAR ��������� �����
REM ��������� � ������� �������
%WORKDISK%
cd %WORKPATH%

del /F /Q *%LPU%*.zip *%LPU%*.rar

REM ���� � MSSQL
REM cd .\MRS_FOND
REM rem rar e -y *.rar
REM !!! �� ������� �������� ������ ������, ��� ��� ��� ����� �����
REM �� ��� ������� ���� � ����� �������� ������ ���
REM del /F /Q *.rar *.zip
REM cd ..

cd .\MRS_NAKL
del /F /Q *%LPU%*.zip *%LPU%*.rar
cd ..

cd .\MRS_Dogovor
del /F /Q *%LPU%*.zip *%LPU%*.rar
cd ..

goto DONE

:NOFTP
REM =============================================
REM ��������� � ������� �������
%WORKDISK%
cd %WORKPATH%
cd ..

REM ������� �������
zerat smtphost:%SMTP% from:"%MAIL_FROM%" to:"%MAIL_TO%" subject:"%REN_THEME%" charset:windows-1251 type:multipart/mixed $boun "Content-type: text/plain; charset=Windows-1251" %REN_BODY%

echo %REN_BODY% 


:DONE
REM ��������� ���� ������������ FTP-�������
FTPUSE %VDISK% /delete
