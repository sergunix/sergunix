@echo off
REM []-------------------------------------------------------------------------
REM    Командный файл для:
REM    Переноса сформированных пакетов НСИ на FTP-сервер МиКС
REM
REM     (C) филиал ООО "Газпром трансгаз Санкт-Петербург" - Волховское ЛПУМГ
REM                               2002-2013
REM ---------------------------------------------------------------------------



REM Устанавливаем локальный набор переменных
setlocal

REM Код ЛПУ по классификации МиКС
set LPU=13

REM Адрес SMTP сервера электронной почты
set SMTP=vhv-dc-01.corp.it.ltg.gazprom.ru

REM Получатель отчета о загрузке файлов
set MAIL_TO=sysadmin@vhv.ltg.gazprom.ru

REM Отправитель отчета
set MAIL_FROM=move_nsi.cmd mics@vhv.ltg.gazprom.ru

REM Тема сообщения
set THEME=Перенос сформированных пакетов НСИ на FTP-сервер МиКС

REM Само сообщение
set BODY=Переноc файлов небыл выполнен по причине недоступности каталогов на FTP-сервере! ПРОВЕРЬ диск V: сервера vhv-mrs-00!!!

REM Само сообщение
set BODYSEND="Список файлов переданных move_nsi.cmd на FTP-сервер МиКС"

REM Сообщение о повторном запуске того же батника
set BODYSENDLOCK="Внимание! Не завершился прошлый запуск move_nsi.cmd,возможно, процесс завис! "

REM Имя файла блокировки
set LOCKFILE=D:\ARM_UPDATES\MOVE_NSI_LCK.TXT

REM Имя файла протокола сформированных файлов для передачи
set LOGFILE=D:\ARM_UPDATES\log_makensi.txt

REM Путь к рабочему каталогу с пакетами
set NSIDISK=D:
set NSIPATH=\ARM_UPDATES\_Replication
set NSIFONDPATH=Y:\#Volhov\ARM_UPDATES\_Replication\MRS_SF

REM Строка для исключения из лог-файла лишней информации
set NSISTRING=_Replication

REM виртуальный диск ftp сервера
set VDISK=V:

REM =============================================
REM Создать файл блокировки повторного запуска
if exist %LOCKFILE% goto LOCK
echo. > %LOCKFILE%
echo File %LOCKFILE% locked!  >> %LOCKFILE%
date /t >>  %LOCKFILE%
time /t >> %LOCKFILE%

REM Подключаем диск виртуального FTP-сервера
FTPUSE %VDISK% mics.ltg.gazprom.ru 2fwy5jpy /USER:miks 
%VDISK%
cd \Mrs\ORACLE
if not exist %VDISK%\Mrs\ORACLE goto NOFTP

REM =============================================
REM Переходим в рабочий каталог
%NSIDISK%
cd %NSIPATH%

REM Переносим MRS-файлы на диск виртуального FTP-сервера
REM Формируем список сделанных файлов mrs (код стр 1251 для команды DIR)
chcp 1251
del /q %LOGFILE%
@echo : >  %LOGFILE%
@echo. >>  %LOGFILE%

ECHO Переносим НСИ для Администрации общества
REM =============================================
ECHO Переносим НСИ, Агрегир.SQL, Агрегир.Oracle в .\ORACLE 
dir     .\ORACLE\*.* | grep.exe -i ora >> %LOGFILE%
move /Y .\ORACLE\*.*    %VDISK%\Mrs\ORACLE
dir %VDISK%\Mrs\ORACLE\*$ORA%LPU%(*.*      | grep.exe -i ora  >> %LOGFILE%
ECHO.

ECHO Переносим ASBU в ASBU - Автом. сист. бюджетного учета
dir     .\ASBU\*ASBU99$*ORA%LPU%*.* | grep.exe -i ASBU >> %LOGFILE%
move /Y .\ASBU\*ASBU99$*ORA%LPU%*.*    %VDISK%\Mrs\ASBU
dir %VDISK%\Mrs\ASBU\*ASBU99$*ORA%LPU%*.*  | grep.exe -i ASBU >> %LOGFILE%
ECHO.

ECHO Переносим НСИ - Договоры в MRS_Dogovor
dir     .\MRS_Dogovor\DGD*(%LPU%)*.* | grep.exe -i mrs >> %LOGFILE%
move /Y .\MRS_Dogovor\DGD*(%LPU%)*.*   %VDISK%\Mrs\MRS_Dogovor
dir %VDISK%\Mrs\MRS_Dogovor\DGD*(%LPU%)*.* | grep.exe -i mrs  >> %LOGFILE%
ECHO.

ECHO Переносим Накладные для других филиалов и администрации в MRS_NAKL
dir     .\MRS_NAKL\BNZ*(%LPU%)*	.* | grep.exe -i mrs >> %LOGFILE%
move /Y .\MRS_NAKL\BNZ*(%LPU%)*.*   %VDISK%\Mrs\MRS_NAKL
dir %VDISK%\Mrs\MRS_NAKL\BNZ*(%LPU%)*.*    | grep.exe -i mrs  >> %LOGFILE%
ECHO.

ECHO Переносим Книги покупок и продаж в MRS_SF (Это формирует бухгалтер из модуля Счета-фактуры)
if not exist %NSIFONDPATH% goto NOFOND
dir %NSIFONDPATH%\SFB99(%LPU%)*.* | grep.exe -i mrs >> %LOGFILE%
move /Y %NSIFONDPATH%\SFB99(%LPU%)*.*  %VDISK%\Mrs\MRS_SF
dir %VDISK%\Mrs\MRS_SF\SFB99(%LPU%)*.*     | grep.exe -i mrs  >> %LOGFILE%
ECHO.

ECHO Переносим документы для ЦИ (основной и дополнит. поток)
REM Остановлено 01.06.2011, так как не работает с 28.10.2010 и доп. поток с 22.10.2011
rem dir     .\XI\*.* | grep.exe -i xi >> %LOGFILE%
rem move /Y .\XI\*.*    %VDISK%\Mrs\XI
REM dir %VDISK%\Mrs\XI\*MS%LPU%*.*             | grep.exe -i xi   >> %LOGFILE%
rem ECHO.

chcp 866                                 
REM Снять блокировку запуска этого командного файла
del /F /Q %LOCKFILE%

goto DONE

:NOFOND   
chcp 866                      
REM Снять блокировку запуска этого командного файла
del /F /Q %LOCKFILE%
set BODY=Переноc файлов небыл выполнен по причине недоступности каталога %NSIFONDPATH% ПРОВЕРЬ подключение к диску сервера vhv-fs-01!!!

:NOFTP
REM =============================================
REM Послать логфайл недоступен ftp
REM Переходим в рабочий каталог
%NSIDISK%
cd %NSIPATH%
cd ..
zerat smtphost:%SMTP% from:"%MAIL_FROM%" to:"%MAIL_TO%" subject:"Not Executed! %THEME%" charset:windows-1251 type:multipart/mixed $boun "Content-type: text/plain; charset=Windows-1251" %BODY%

echo %BODY%

goto END


:LOCK
REM =============================================
REM Послать сообщение о зависшей закачке на администратора сети
REM Переходим в рабочий каталог
%NSIDISK%
cd %NSIPATH%
@echo. >>  %LOCKFILE%
REM =============================================
ECHO Формируем список уже сформированных, но не переданных из-за блокировки файлов
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

REM Издать вопль "echo 0x007" (Стандаpтный звук)
REM echo 

goto END

:DONE

REM =============================================
REM Послать логфайл о перемещенных файлах
%NSIDISK%
cd %NSIPATH%
cd ..
zerat smtphost:%SMTP% from:"%MAIL_FROM%" to:"%MAIL_TO%" subject:"%THEME%" charset:windows-1251 type:multipart/mixed $boun "Content-type: text/plain; charset=windows-1251" %BODYSEND% %%PUT="%LOGFILE%"


:END
REM Отключаем диск виртуального FTP-сервера
FTPUSE %VDISK% /delete 

