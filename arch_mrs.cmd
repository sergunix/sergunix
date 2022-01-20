@echo off
REM --------------------------------------------------------------------------
REM   Командный файл для:
REM
REM   Архивирования принятых НСИ файлов (mrs) с сервера MICS 
REM
REM   (С) филиал ООО "Газпром трансгаз Санкт-Петербург" - Волховское ЛПУМГ
REM                               2009-2011
REM --------------------------------------------------------------------------

REM Устанавливаем локальный набор переменных
setlocal

REM Адрес сервера электронной почты
set SMTP=vhv-dc-01.corp.it.ltg.gazprom.ru

REM Получатель отчёта о записи файлов
set MAIL_TO=sysadmin@vhv.ltg.gazprom.ru

REM Отправитель отчёта
set MAIL_FROM=arch_mrs.cmd mics@vhv.ltg.gazprom.ru

REM Тема сообщения
set THEME=ArchiveMRS: архивация принятых MRS-файлов на сервере МИКС

REM Имя файла aрхива 
set ARCHDOG=_MrsDog
set ARCHNAKL=_MrsNkl
set ARCHMRS=_MrsNSI
set ARCHSYNC=_MrsSync

REM Имя лог-файла
set ARCHLOG=..\log%ARCHMRS%.txt

REM []-----------------------------------------------------------------
REM     Переходим в рабочий каталог
if not exist .\_Replication goto NOWORKPATH
cd _Replication

REM []--- Формируем из команды Date переменные дня и месяца
set MONTH=%date:~3,2%

REM []--- Удалить прошлогодние файлы месячного архива
del /Q /F %ARCHMRS%%MONTH%
del /Q /F .\MRS_Dogovor\%ARCHDOG%%MONTH%
del /Q /F .\MRS_NAKL\%ARCHNAKL%%MONTH%
del /Q /F .\MRS_SYNC_ORACLE\%ARCHSYNC%%MONTH%

REM []--- Архивирование MRS в папке _Replication
rar m0 -y %ARCHMRS%%MONTH% *.mrs *.old *.yes

REM []--- Архивирование MRS в папке _Replication\MRS_Dogovor
rar m -y .\MRS_Dogovor\%ARCHDOG%%MONTH% .\MRS_Dogovor\*.mrs .\MRS_Dogovor\*.yes .\MRS_Dogovor\*.old

REM []--- Архивирование MRS в папке _Replication\MRS_NAKL
rar m -y .\MRS_NAKL\%ARCHNAKL%%MONTH% .\MRS_NAKL\*.mrs .\MRS_NAKL\*.yes .\MRS_NAKL\*.old 

REM []--- Архивирование пакетов синхронизации MRSSYNC в папке _Replication\MRS_SYNC_ORACLE
rar m -y .\MRS_SYNC_ORACLE\%ARCHSYNC%%MONTH% .\MRS_SYNC_ORACLE\*.mrs .\MRS_SYNC_ORACLE\*.yes .\MRS_SYNC_ORACLE\*.old 

REM []--- Выделение информации о файлах архивах MRS
chcp 1251
echo. > ..\log%ARCHMRS%.txt
dir               | find /I ".rar" >>  ..\log%ARCHMRS%.txt
dir .\MRS_Dogovor | find /I ".rar" >> ..\log%ARCHMRS%.txt
dir .\MRS_NAKL    | find /I ".rar" >> ..\log%ARCHMRS%.txt
dir .\MRS_SYNC_ORACLE    | find /I ".rar" >> ..\log%ARCHMRS%.txt
chcp 866

REM []--- Отправка сообщения о копировании файлов
zerat smtphost:%SMTP% from:"%MAIL_FROM%" to:"%MAIL_TO%" subject:"%THEME%" charset:windows-1251 type:multipart/mixed $boun "Content-type: text/plain; charset=Windows-1251" Проверь состояние приема\передачи МРС после архивации по ссылке http://nsi/MRS_report.aspx %%PUT="..\log%ARCHMRS%.txt"
goto END

:NOWORKPATH
REM []--- Отправка сообщения об отсутствии в текущем каталоге каталога _Replication
zerat smtphost:%SMTP% from:"%MAIL_FROM%" to:"%MAIL_TO%" subject:"%THEME%" charset:windows-1251 type:multipart/mixed $boun "Content-type: text/plain; charset=windows-1251" Внимание! Рабочий каталог _Replication недоступен, архивирование принятых НСИ файлов (mrs) не было выполнено.
goto END

:END