@echo off
REM --------------------------------------------------------------------------
REM   ��������� ���� ���:
REM
REM   ������������� �������� ��� ������ (mrs) � ������� MICS 
REM
REM   (�) ������ ��� "������� �������� �����-���������" - ���������� �����
REM                               2009-2011
REM --------------------------------------------------------------------------

REM ������������� ��������� ����� ����������
setlocal

REM ����� ������� ����������� �����
set SMTP=vhv-dc-01.corp.it.ltg.gazprom.ru

REM ���������� ������ � ������ ������
set MAIL_TO=sysadmin@vhv.ltg.gazprom.ru

REM ����������� ������
set MAIL_FROM=arch_mrs.cmd mics@vhv.ltg.gazprom.ru

REM ���� ���������
set THEME=ArchiveMRS: ��������� �������� MRS-������ �� ������� ����

REM ��� ����� a����� 
set ARCHDOG=_MrsDog
set ARCHNAKL=_MrsNkl
set ARCHMRS=_MrsNSI
set ARCHSYNC=_MrsSync

REM ��� ���-�����
set ARCHLOG=..\log%ARCHMRS%.txt

REM []-----------------------------------------------------------------
REM     ��������� � ������� �������
if not exist .\_Replication goto NOWORKPATH
cd _Replication

REM []--- ��������� �� ������� Date ���������� ��� � ������
set MONTH=%date:~3,2%

REM []--- ������� ������������ ����� ��������� ������
del /Q /F %ARCHMRS%%MONTH%
del /Q /F .\MRS_Dogovor\%ARCHDOG%%MONTH%
del /Q /F .\MRS_NAKL\%ARCHNAKL%%MONTH%
del /Q /F .\MRS_SYNC_ORACLE\%ARCHSYNC%%MONTH%

REM []--- ������������� MRS � ����� _Replication
rar m0 -y %ARCHMRS%%MONTH% *.mrs *.old *.yes

REM []--- ������������� MRS � ����� _Replication\MRS_Dogovor
rar m -y .\MRS_Dogovor\%ARCHDOG%%MONTH% .\MRS_Dogovor\*.mrs .\MRS_Dogovor\*.yes .\MRS_Dogovor\*.old

REM []--- ������������� MRS � ����� _Replication\MRS_NAKL
rar m -y .\MRS_NAKL\%ARCHNAKL%%MONTH% .\MRS_NAKL\*.mrs .\MRS_NAKL\*.yes .\MRS_NAKL\*.old 

REM []--- ������������� ������� ������������� MRSSYNC � ����� _Replication\MRS_SYNC_ORACLE
rar m -y .\MRS_SYNC_ORACLE\%ARCHSYNC%%MONTH% .\MRS_SYNC_ORACLE\*.mrs .\MRS_SYNC_ORACLE\*.yes .\MRS_SYNC_ORACLE\*.old 

REM []--- ��������� ���������� � ������ ������� MRS
chcp 1251
echo. > ..\log%ARCHMRS%.txt
dir               | find /I ".rar" >>  ..\log%ARCHMRS%.txt
dir .\MRS_Dogovor | find /I ".rar" >> ..\log%ARCHMRS%.txt
dir .\MRS_NAKL    | find /I ".rar" >> ..\log%ARCHMRS%.txt
dir .\MRS_SYNC_ORACLE    | find /I ".rar" >> ..\log%ARCHMRS%.txt
chcp 866

REM []--- �������� ��������� � ����������� ������
zerat smtphost:%SMTP% from:"%MAIL_FROM%" to:"%MAIL_TO%" subject:"%THEME%" charset:windows-1251 type:multipart/mixed $boun "Content-type: text/plain; charset=Windows-1251" ������� ��������� ������\�������� ��� ����� ��������� �� ������ http://nsi/MRS_report.aspx %%PUT="..\log%ARCHMRS%.txt"
goto END

:NOWORKPATH
REM []--- �������� ��������� �� ���������� � ������� �������� �������� _Replication
zerat smtphost:%SMTP% from:"%MAIL_FROM%" to:"%MAIL_TO%" subject:"%THEME%" charset:windows-1251 type:multipart/mixed $boun "Content-type: text/plain; charset=windows-1251" ��������! ������� ������� _Replication ����������, ������������� �������� ��� ������ (mrs) �� ���� ���������.
goto END

:END