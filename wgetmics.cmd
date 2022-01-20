@echo on
REM []-------------------------------------------------------------------------
REM    Командный файл для:
REM    Закачки файлов обновлений БД и программ из корня каталога MIKS;
REM    Закачиваются файлы из каталогов типа MICSYYYY\MM-DD*, например
REM    MICS2008\06-03-13, то есть год\месяц-день-час   
REM    Проверяем каталог zarplata и закачиваем файлы обновлений программ 
REM    из каталогов с текущим днем МЕСЯЦ-ДЕНЬ-ЧАС
REM    Выделения имен закачанных  файлов из протокола;
REM    Создания письма на электронную почту для информирования;
REM    о произведенной загрузке файлов репликаций.
REM
REM     (C) Волховское ЛПУМГ филиал ООО "Газпром трансгаз Санкт-Петербург"
REM                               2002-2010
REM ---------------------------------------------------------------------------

REM =============================================
REM Рабочий год программы
set YEAR=2013

REM FTP Сервер
set FTP_SERVER=ftp://volhov:wohv9hxz@corp-ftp.corp.it.ltg.gazprom.ru
set FTP_PATH=/software/MIKS/MIKS

REM Имя файла протокола закачки
set LOGFILE=log_mics.txt

REM Адрес SMTP сервера электронной почты
set SMTP=vhv-dc-01.corp.it.ltg.gazprom.ru

REM Получатель отчета о загрузке файлов
set MAIL_TO=sysadmin@vhv.ltg.gazprom.ru

REM Отправитель отчета
set MAIL_FROM=mics@vhv.ltg.gazprom.ru

REM Тема сообщения
set THEME=Файлы обновлений БД и программ

REM Имя файла блокировки
set LOCKFILE=D:\ARM_UPDATES\WGETMICS_LCK.TXT

REM Сообщение о повторном запуске того же батника
set BODYSENDLOCK="Внимание! Не завершился прошлый запуск wgetmics.cmd, возможно, закачка слишком объёмная!"
REM =============================================

REM Переходим в рабочий каталог
D:
cd \ARM_UPDATES\MICS%YEAR%

REM Формируем из команды Date переменные дня и месяца
set DAY=%date:~0,2%
set MONTH=%date:~3,2%
rem date  /T > ../%LOGFILE%
rem for /f "tokens=1 delims=." %%i in (../%LOGFILE%) do set DAY=%%i
rem for /f "tokens=2 delims=." %%i in (../%LOGFILE%) do set MONTH=%%i
REM =============================================


REM Создать файл блокировки повторного запуска
if exist %LOCKFILE% goto LOCK
echo. > %LOCKFILE%
echo File %LOCKFILE% locked!  >> %LOCKFILE%
date /t >>  %LOCKFILE%
time /t >> %LOCKFILE%


REM =============================================
REM   Закачиваем файлы обновлений БД и программ из корня каталога MIKS
REM   и из каталогов с текущим днем МЕСЯЦ-ДЕНЬ-ЧАС
wget %FTP_SERVER%%FTP_PATH%%YEAR%/ -o../%LOGFILE% -P. -c -N -r -nH --cut-dirs=3 -I%FTP_PATH%%YEAR%/%MONTH%-%DAY%* 
REM убрано с 03.04.2013 так как канал Спб-Вхв стал 50Мбит --limit-rate=131072

REM ============================================= 
REM  Проверяем каталог zarplata и закачиваем файлы обновлений программ 
REM  из каталогов с текущим днем МЕСЯЦ-ДЕНЬ-ЧАС
REM  В %LOGFILE% добавляем log с помощью ключа -a
wget %FTP_SERVER%%FTP_PATH%%YEAR%/zarplata/ -a../%LOGFILE% -P. -c -N -r -nH --cut-dirs=3 -I%FTP_PATH%%YEAR%/zarplata/%MONTH%-%DAY%*,%FTP_PATH%%YEAR%/zarplata/DOC* 
REM убрано с 03.04.2013 так как канал Спб-Вхв стал 50Мбит --limit-rate=131072

REM Снять блокировку запуска этого командного файла
del /F /Q %LOCKFILE%

REM Переходим в рабочий каталог лог-файлов
cd ..

REM =============================================
REM   Выделить из протокола данные о незакачанных файлах (ошибка доступа)
GREP "No such file" %LOGFILE% > SAVE%LOGFILE%
GREP "No such directory" %LOGFILE% >> SAVE%LOGFILE%

REM   Выделить из протокола данные о закачанных файлах
GREP saved %LOGFILE% | GREP -v .listing >> SAVE%LOGFILE%

if errorlevel 2 goto ERR2
if errorlevel 1 goto ERR1
if errorlevel 0 goto ERR0
goto END

:ERR2
REM Файл не найден для команды GREP 
goto END

:ERR1
REM Не удалось ничего найти по команде GREP
goto END

:ERR0
REM =============================================
REM Послать логфайл о произведенной закачке на администратора сети
REM sendmail.exe %SMTP% %MAIL_TO%=%MAIL_FROM% SAVE%LOGFILE%
zerat smtphost:%SMTP% from:"%0 %MAIL_FROM%" to:"%MAIL_TO%" subject:"%THEME%" charset:windows-1251 type:multipart/mixed $boun "Content-type: text/plain; charset=Windows-1251" %%PUT="SAVE%LOGFILE%" $incl "%LOGFILE%"

REM Издать вопль "echo 0x007" (Стандаpтный звук)
REM echo 
goto END

:LOCK
REM =============================================
REM Послать сообщение о зависшей закачке на администратора сети
echo LOCK

REM Переходим в рабочий каталог лог-файлов
cd ..

zerat smtphost:%SMTP% from:"%0 %MAIL_FROM%" to:"%MAIL_TO%" subject:"%THEME%" charset:windows-1251 type:multipart/mixed $boun "Content-type: text/plain; charset=windows-1251" %BODYSENDLOCK% %%PUT="%LOCKFILE%"


:END