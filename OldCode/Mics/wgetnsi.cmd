@echo on
REM []-------------------------------------------------------------------------
REM    Командный файл для:
REM    Закачки файлов репликаций для ЛПУ и НСИ счетов;
REM    Выделения имен закачанных  файлов из протокола;
REM    Удаления закачанных файлов с FTP-сервера;
REM    Создания письма на электронную почту для информирования;
REM    о произведенной загрузке файлов репликаций.
REM
REM     (C) филиал ООО "Газпром трансгаз Санкт-Петербург" - Волховское ЛПУМГ
REM                               2002-2011
REM ---------------------------------------------------------------------------

REM Устанавливаем локальный набор переменных
setlocal

REM Код ЛПУ по классификации МиКС
set LPU=13

REM FTP Сервер 
set FTP_SERVER=ftp://miks:2fwy5jpy@mics.ltg.gazprom.ru

REM Рабочий каталог
set WORKDISK=D:
set WORKPATH=\ARM_UPDATES\_Replication

REM Имя файла протокола закачки
set LOGFILE=log_nsi.txt

REM Адрес SMTP сервера электронной почты
set SMTP=vhv-dc-01.corp.it.ltg.gazprom.ru

REM Получатель отчета о загрузке файлов
set MAIL_TO=sysadmin@vhv.ltg.gazprom.ru

REM Отправитель отчета
set MAIL_FROM=mics@vhv.ltg.gazprom.ru

REM Тема сообщения
set THEME=Файлы репликаций для ЛПУ закачаны

REM Что закачать %LPU%*.* - оставили для приема пакетов синхронизации
REM OLD set FILES=%LPU%*.*,*ond*.*,bnz%LPU%*.*,dgd%LPU%*.*,ms%LPU%*.*,MS%LPU%*.*,*OND*.*,BNZ%LPU%*.*,DGD%LPU%*.*,M2O00101$ORA%LPU%*.*,m2o00101$ora%LPU%*.*
set FILES=%LPU%*.*,dgd%LPU%*.*,DGD%LPU%*.*,bnz%LPU%*.*,BNZ%LPU%*.*,M2O00101$ORA%LPU%*.*,m2o00101$ora%LPU%*.*
set FILESYES=*.YES,*.ZIPYES,*.RARYES

REM =============================================
REM Переходим в рабочий каталог
%WORKDISK%
cd %WORKPATH%

REM =============================================
REM Закачиваем файлы репликаций для ЛПУ с кодом LPU (Волхов-13) и НСИ счетов
wget.exe %FTP_SERVER%/Mrs/ -P./ -o../%LOGFILE% -N -c -nH -r --cut-dirs=1 -R%FILESYES% -A%FILES% -X/Mrs/MRS_AGGR,/Mrs/MRS_BACK,/Mrs/MRS_SF,/Mrs/ORACLE,/Mrs/XI,/Mrs/GKI,/Mrs/OD,/Mrs/ASBU,/Mrs/MRS_FOND 
REM убрано с 03.04.2013 так как канал Спб-Вхв стал 50Мбит --limit-rate=131072

REM =============================================
REM Переходим в рабочий каталог лог-файлов
cd ..

REM =============================================
REM   Выделить из протокола данные о закачанных файлах
REM Если информации о закачанных файлах нет, то ничего больше не делаем
echo. >  SAVE%LOGFILE%
echo []-------------------------------------------------------------------------- >> SAVE%LOGFILE%
grep.exe saved %LOGFILE% | grep.exe -v .listing  >> SAVE%LOGFILE%

if errorlevel 2 goto ERR2
if errorlevel 1 goto ERR1
if errorlevel 0 goto ERR0
goto END

:ERR2
REM Файл не найден для команды grep.exe 
goto END

:ERR1
REM Не удалось ничего найти по команде grep.exe
goto END

:ERR0
REM =============================================
REM Информация о закачанных файлах есть!
REM =============================================
REM Послать логфайл о произведенной закачке на администратора сети
REM Если принятые файлы это Архивы RAR, Архивы ZIP


grep.exe -i rar  	    SAVE%LOGFILE%
goto RAR%errorlevel%
:RAR2
:RAR1

grep.exe -i zip	    SAVE%LOGFILE%
goto ZIP%errorlevel%
:ZIP2
:ZIP1

REM Не закачанных архивов, ничего не распаковываем, идем на отсылку письма
goto ZERAT

:RAR0
:ZIP0
REM =============================================
REM Есть архивы, распаковываем - Переходим в рабочий каталог
%WORKDISK%
cd %WORKPATH%

unzip -o *.zip
rar e -y *.rar
REM Удалять будем при переименовании в YES del /F /Q *.zip *.rar

cd .\MRS_NAKL
unzip -o *.zip
rar e -y *.rar
cd ..

cd .\MRS_Dogovor
unzip -o *.zip
rar e -y *.rar
cd..

:ZERAT
zerat smtphost:%SMTP% from:"%0 %MAIL_FROM%" to:"%MAIL_TO%" subject:"%THEME%" charset:windows-1251 type:multipart/mixed $boun "Content-type: text/plain; charset=Windows-1251" "   ЖДИТЕ ПИСЬМА О ЗАВЕРШЕНИИ ПРИЁМА ПАКЕТОВ НСИ!!!" %%PUT="SAVE%LOGFILE%" $incl "%LOGFILE%"
REM c 24.01.2011 запуск приема НСИ выполняем в батнике по закачке при успешной закачке
REM для контроля окончания приема МРС после их закачки из ФТП сервера
ECHO =============================================
ECHO Устанавливаем принятые с ФТП пакеты МРС в БД МиКС
ECHO С созданием файла LOCK для предотвращения повторного запуска
ECHO.
REM Если не ожидать 60 секунд, то возможно с пересечением запуска 
REM c makensiora.cmd, что иногда приведет к блокированию файла
REM C:\Apps\Mics\info.key
ECHO --- Ожидаем в течении 60 секунд для завершения процесса формирования MRS ---
ECHO.
sleep.exe 60
recvnsi.cmd


:END
REM Издать вопль "echo 0x007" (Стандаpтный звук)
REM echo 
