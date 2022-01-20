@echo off
REM []-------------------------------------------------------------------------
REM    Командный файл для:
REM    Переименования закачанных файлов с FTP-сервера в *.yes;
REM
REM     (C) филиал ООО "Газпром трансгаз Санкт-Петербург" - Волховское ЛПУМГ
REM                               2002-2013
REM ---------------------------------------------------------------------------

REM Устанавливаем локальный набор переменных
setlocal

REM Код ЛПУ по классификации МиКС
set LPU=13

REM Рабочий каталог
set WORKDISK=D:
set WORKPATH=\ARM_UPDATES\_Replication

REM Адрес SMTP сервера электронной почты
set SMTP=vhv-dc-01.corp.it.ltg.gazprom.ru

REM Получатель отчета о загрузке файлов
set MAIL_TO=sysadmin@vhv.ltg.gazprom.ru

REM Отправитель отчета
set MAIL_FROM=ren_nsi.cmd mics@vhv.ltg.gazprom.ru

REM Тема сообщения
set REN_THEME=Переименование закачанных файлов с FTP-сервера в *.yes

REM Имя файла протокола переименованных файлов в YES для передачи
set REN_LOGFILE=D:\ARM_UPDATES\log_renamensi.txt

REM Само сообщение
set REN_BODY=Переименование не было выполнено в .YES, по причине недоступности \Mrs\MRS_BACK на FTP-сервере!

REM виртуальный диск ftp сервера
set VDISK=V:

REM []--- Формируем из команды Date переменную часа выполнения. 10-11-2010 замена на новую команду 
set HOUR=%time:~0,2%

REM =============================================
REM Получаем все, что не получено, если запустили НЕ в 22 часа!
REM В 22 утра вызов wgetnsi.cmd отменяем с 08.10.2009, 
REM          так как переименование запускаем из getnsi.cmd, 
REM          который сам вызывает wgetnsi.cmd сначала (чтобы не было рекурсии)

echo  Получаем все, что не получено за ночь, если запустили НЕ в 22 утра!
if NOT %HOUR% == 22 call wgetnsi.cmd 

REM Подключаем диск виртуального FTP-сервера
FTPUSE %VDISK% mics.ltg.gazprom.ru 2fwy5jpy /USER:miks 
%VDISK%
cd \Mrs\ORACLE
if not exist %VDISK%\Mrs\ORACLE goto NOFTP

REM Удаляем переименованные ранее файлы
del /Q %VDISK%\Mrs\M2O00101$ORA%LPU%*.*YES
del /Q %VDISK%\Mrs\MRS_NAKL\BNZ%LPU%*.*YES
del /Q %VDISK%\Mrs\MRS_Dogovor\DGD%LPU%*.*YES
del /Q %VDISK%\Mrs\MRS_SYNC_ORACLE\%LPU%*.*YES

REM Переходим в рабочий каталог
%WORKDISK%
cd %WORKPATH%
cd ..

REM Выдать "Информация о переименованных файлах на FTP сервере:"
echo LэЇюЁьрЎш  ю яхЁхшьхэютрээvї Їрщырї эр FTP-ёхЁтхЁх: > %REN_LOGFILE%
echo. >> %REN_LOGFILE%
REM (код стр 1251 для команды DIR)
chcp 1251

REM Переименовываем на диске виртуального FTP-сервера
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

REM Послать информацию о переименованных файлах на ФТП сервере
zerat smtphost:%SMTP% from:"%MAIL_FROM%" to:"%MAIL_TO%" subject:"%REN_THEME%" charset:windows-1251 type:multipart/mixed $boun "Content-type: text/plain; charset=Windows-1251" %%PUT="%REN_LOGFILE%"

REM =============================================
REM Удаляем все принятые ZIP и RAR локальные файлы
REM Переходим в рабочий каталог
%WORKDISK%
cd %WORKPATH%

del /F /Q *%LPU%*.zip *%LPU%*.rar

REM было в MSSQL
REM cd .\MRS_FOND
REM rem rar e -y *.rar
REM !!! Не удалять принятые архивы фондов, так как они долго лежат
REM на ФТП сервере МиКС и будут качаться каждый раз
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
REM Переходим в рабочий каталог
%WORKDISK%
cd %WORKPATH%
cd ..

REM Послать логфайл
zerat smtphost:%SMTP% from:"%MAIL_FROM%" to:"%MAIL_TO%" subject:"%REN_THEME%" charset:windows-1251 type:multipart/mixed $boun "Content-type: text/plain; charset=Windows-1251" %REN_BODY%

echo %REN_BODY% 


:DONE
REM Отключаем диск виртуального FTP-сервера
FTPUSE %VDISK% /delete
