@echo off
setlocal EnableDelayedExpansion

:: ================================================================
::  ARIA - AI Writing & General Assistant
::  Powered by Ollama (free, local, no API key)
::  https://ollama.com
:: ================================================================

set "MODEL=mistral"
set "OLLAMA_URL=http://localhost:11434/api/generate"
set "TMPFILE=%TEMP%\aria_resp_%RANDOM%.json"
set "SESSFILE=%TEMP%\aria_session_%RANDOM%.txt"
set "LOGDIR=%~dp0logs"
set "LOGFILE=%LOGDIR%\history_%date:~10,4%-%date:~4,2%-%date:~7,2%.txt"
set "SESSION_START=%date% %time:~0,8%"
set "MSG_COUNT=0"

:: Create logs folder
if not exist "%LOGDIR%" mkdir "%LOGDIR%"

:: ---- Check Ollama is installed --------------------------------
where ollama >nul 2>&1
if errorlevel 1 goto NO_OLLAMA

:: ---- Start Ollama if not running ------------------------------
curl -s --max-time 2 "http://localhost:11434/" >nul 2>&1
if errorlevel 1 (
    echo  [*] Starting Ollama...
    start /b "" ollama serve >nul 2>&1
    timeout /t 3 >nul
)

:: ---- Pull model if missing ------------------------------------
ollama list 2>nul | findstr /i "!MODEL!" >nul 2>&1
if errorlevel 1 (
    cls
    echo.
    echo  +--------------------------------------------------+
    echo  ^|  First-time setup: downloading !MODEL! model...   ^|
    echo  ^|  This is a one-time download of ~4GB.            ^|
    echo  ^|  After this, ARIA runs fully offline.            ^|
    echo  +--------------------------------------------------+
    echo.
    ollama pull !MODEL!
    if errorlevel 1 (
        echo  [!] Download failed. Check your internet connection.
        pause & exit /b
    )
)

:: ================================================================
:HOME
cls
echo.
echo  +==========================================================+
echo  ^|                                                          ^|
echo  ^|        A R I A  --  AI General ^& Writing Assistant      ^|
echo  ^|              Powered by Ollama  ^|  100%% Free            ^|
echo  ^|                                                          ^|
echo  +==========================================================+
echo  ^|  Model : !MODEL!                                         
echo  +==========================================================+
echo  ^|  [1]  New Chat                                          ^|
echo  ^|  [2]  View Session History                              ^|
echo  ^|  [3]  Browse Saved Logs                                 ^|
echo  ^|  [4]  Change Model                                      ^|
echo  ^|  [5]  Exit                                              ^|
echo  +----------------------------------------------------------+
echo.
set /p "CHOICE= > "
if "!CHOICE!"=="1" goto NEW_CHAT
if "!CHOICE!"=="2" goto VIEW_SESSION
if "!CHOICE!"=="3" goto BROWSE_LOGS
if "!CHOICE!"=="4" goto CHANGE_MODEL
if "!CHOICE!"=="5" goto EXIT_APP
goto HOME

:: ================================================================
:NEW_CHAT
cls
set "MSG_COUNT=0"
if exist "%SESSFILE%" del "%SESSFILE%" >nul 2>&1

:: Write session header to log
echo ================================================================>>"%LOGFILE%"
echo  ARIA SESSION  ^|  !SESSION_START!  ^|  Model: !MODEL!>>"%LOGFILE%"
echo ================================================================>>"%LOGFILE%"

echo.
echo  +==========================================================+
echo  ^|  ARIA Chat  ^|  Model: !MODEL!                           
echo  +==========================================================+
echo  ^|  /help    /clear    /save    /history    /quit          ^|
echo  +----------------------------------------------------------+
echo  ^|  Tip: Ask me to write, explain, summarise, or brainstorm^|
echo  +----------------------------------------------------------+
echo.

:CHAT_LOOP
set "INPUT="
set /p "INPUT= You: "
if "!INPUT!"=="" goto CHAT_LOOP

:: ---- Built-in commands ----------------------------------------
if /i "!INPUT!"=="/quit"    goto SAVE_AND_HOME
if /i "!INPUT!"=="/exit"    goto EXIT_APP
if /i "!INPUT!"=="/clear"   goto CLEAR_CHAT
if /i "!INPUT!"=="/history" goto INLINE_HISTORY
if /i "!INPUT!"=="/save"    goto FORCE_SAVE
if /i "!INPUT!"=="/help"    goto SHOW_HELP

:: ---- Build system prompt based on general + writing focus -----
set "SYSPROMPT=You are ARIA, a helpful AI assistant specialised in general knowledge and creative writing. Be clear, thoughtful, and concise. For writing tasks, produce polished, engaging content. For questions, give accurate and well-structured answers. Avoid unnecessary filler phrases."

:: ---- Escape input for JSON ------------------------------------
set "ESC=!INPUT!"
set "ESC=!ESC:\=\\!"
set "ESC=!ESC:"=\"!"

:: ---- Build full prompt with session context -------------------
set "CTX="
if exist "%SESSFILE%" (
    set "CTX="
    for /f "usebackq delims=" %%L in ("%SESSFILE%") do set "CTX=!CTX!%%L \n"
)

set "FULLPROMPT=!SYSPROMPT!\n\nConversation so far:\n!CTX!\nUser: !ESC!\nARIA:"

:: ---- Call Ollama ----------------------------------------------
echo.
echo  ARIA is thinking...
echo.

curl -s -X POST "!OLLAMA_URL!" ^
  -H "Content-Type: application/json" ^
  -d "{\"model\":\"!MODEL!\",\"prompt\":\"!FULLPROMPT!\",\"stream\":false}" ^
  -o "!TMPFILE!" 2>nul

if not exist "!TMPFILE!" (
    echo  [Error] Could not reach Ollama. Try restarting the app.
    echo.
    goto CHAT_LOOP
)

:: ---- Parse response -------------------------------------------
set "REPLY="
for /f "usebackq delims=" %%L in ("!TMPFILE!") do set "RAW=%%L"
set "RAW=!RAW:*\"response\":\"=!"
set "REPLY=!RAW:~0,2500!"

:: Trim at JSON closing
set "REPLY=!REPLY:\"done\"=^|!"
for /f "tokens=1 delims=|" %%A in ("!REPLY!") do set "REPLY=%%A"

:: Clean escape sequences
set "REPLY=!REPLY:\n=  !"
set "REPLY=!REPLY:\t= !"
set "REPLY=!REPLY:\"=`!"

if "!REPLY!"=="" (
    echo  [ARIA] Sorry, I didn't get a response. Please try again.
    echo.
    del "!TMPFILE!" >nul 2>&1
    goto CHAT_LOOP
)

:: ---- Print reply with word-wrap simulation --------------------
echo  +----------------------------------------------------------+
echo  ^| ARIA:
echo  ^|
echo  ^|  !REPLY!
echo  ^|
echo  +----------------------------------------------------------+
echo.

:: ---- Append to session context (last 6 exchanges max) ---------
echo You: !INPUT!>>"%SESSFILE%"
echo ARIA: !REPLY!>>"%SESSFILE%"
set /a "MSG_COUNT+=1"

:: Keep session file trimmed to last 12 lines (6 exchanges)
set "LCOUNT=0"
for /f %%C in ('find /c /v "" "%SESSFILE%" 2^>nul') do set "LCOUNT=%%C"
if !LCOUNT! GTR 14 (
    set "TRIMMED="
    set "LN=0"
    set "SKIP=!LCOUNT!"
    set /a "SKIP-=12"
    for /f "usebackq skip=!SKIP! delims=" %%L in ("%SESSFILE%") do (
        echo %%L>>"!SESSFILE!.tmp"
    )
    if exist "!SESSFILE!.tmp" (
        move /y "!SESSFILE!.tmp" "%SESSFILE%" >nul 2>&1
    )
)

:: ---- Append to log file ---------------------------------------
echo [!time:~0,8!] You: !INPUT!>>"%LOGFILE%"
echo [!time:~0,8!] ARIA: !REPLY!>>"%LOGFILE%"
echo.>>"%LOGFILE%"

del "!TMPFILE!" >nul 2>&1
goto CHAT_LOOP

:: ================================================================
:CLEAR_CHAT
del "%SESSFILE%" >nul 2>&1
set "MSG_COUNT=0"
echo  [Context cleared - starting fresh]
echo.
goto CHAT_LOOP

:: ================================================================
:INLINE_HISTORY
echo.
echo  +--[ This Session ]----------------------------------------+
if exist "%SESSFILE%" (
    type "%SESSFILE%"
) else (
    echo  [No messages yet this session]
)
echo  +----------------------------------------------------------+
echo.
goto CHAT_LOOP

:: ================================================================
:FORCE_SAVE
echo  [Session auto-saves to logs\ after every message]
echo  [Log file: !LOGFILE!]
echo.
goto CHAT_LOOP

:: ================================================================
:SHOW_HELP
echo.
echo  +--[ ARIA Help ]-------------------------------------------+
echo  ^|  Just type naturally to chat with ARIA.                 ^|
echo  ^|                                                          ^|
echo  ^|  Writing prompts to try:                                ^|
echo  ^|    Write a short story about a lighthouse keeper        ^|
echo  ^|    Rewrite this paragraph more formally: [text]         ^|
echo  ^|    Give me 5 headline ideas for [topic]                 ^|
echo  ^|    Summarise this in 3 bullet points: [text]            ^|
echo  ^|                                                          ^|
echo  ^|  Commands:                                              ^|
echo  ^|    /clear    - Reset conversation context               ^|
echo  ^|    /history  - Show this session's messages             ^|
echo  ^|    /save     - Show log file location                   ^|
echo  ^|    /quit     - Return to main menu                      ^|
echo  ^|    /exit     - Close ARIA                               ^|
echo  +----------------------------------------------------------+
echo.
goto CHAT_LOOP

:: ================================================================
:VIEW_SESSION
cls
echo.
echo  +--[ Current Session History ]-----------------------------+
echo.
if exist "%SESSFILE%" (
    type "%SESSFILE%"
) else (
    echo  [No active session. Start a new chat first.]
)
echo.
echo  +----------------------------------------------------------+
echo.
pause
goto HOME

:: ================================================================
:BROWSE_LOGS
cls
echo.
echo  +--[ Saved Log Files ]-------------------------------------+
echo.
if exist "%LOGDIR%\" (
    dir "%LOGDIR%\*.txt" /b 2>nul
    if errorlevel 1 echo  [No logs saved yet]
) else (
    echo  [Logs folder not found]
)
echo.
echo  +----------------------------------------------------------+
set /p "LOGNAME= Enter filename to view (or press Enter to go back): "
if "!LOGNAME!"=="" goto HOME
if exist "%LOGDIR%\!LOGNAME!" (
    cls
    type "%LOGDIR%\!LOGNAME!"
    echo.
    pause
) else (
    echo  [File not found]
    timeout /t 2 >nul
)
goto BROWSE_LOGS

:: ================================================================
:CHANGE_MODEL
cls
echo.
echo  +--[ Change AI Model ]-------------------------------------+
echo  ^|  Current model: !MODEL!
echo  +----------------------------------------------------------+
echo  ^|  Popular free models (download with: ollama pull NAME)  ^|
echo  ^|                                                          ^|
echo  ^|    mistral    ~4GB   Best all-rounder (default)         ^|
echo  ^|    llama3     ~4GB   Meta Llama 3                       ^|
echo  ^|    phi3       ~2GB   Fast, lower-spec PCs               ^|
echo  ^|    gemma2     ~5GB   Google Gemma 2                     ^|
echo  ^|    tinyllama  ~600MB Minimal, very fast                 ^|
echo  +----------------------------------------------------------+
echo.
set /p "NEWMODEL= Model name (Enter to cancel): "
if "!NEWMODEL!"=="" goto HOME
ollama list 2>nul | findstr /i "!NEWMODEL!" >nul 2>&1
if errorlevel 1 (
    echo.
    echo  [*] Downloading !NEWMODEL!... (this may take a while)
    ollama pull !NEWMODEL!
    if errorlevel 1 (
        echo  [!] Failed. Check the model name and your connection.
        timeout /t 3 >nul
        goto CHANGE_MODEL
    )
)
set "MODEL=!NEWMODEL!"
echo  [+] Now using: !MODEL!
timeout /t 2 >nul
goto HOME

:: ================================================================
:SAVE_AND_HOME
echo  [Session saved to: !LOGFILE!]
echo.
timeout /t 2 >nul
goto HOME

:: ================================================================
:EXIT_APP
echo  [Session saved to: !LOGFILE!]
echo.
echo  Goodbye!
timeout /t 2 >nul
del "!TMPFILE!" >nul 2>&1
exit /b

:: ================================================================
:NO_OLLAMA
cls
echo.
echo  +==========================================================+
echo  ^|            OLLAMA NOT INSTALLED                         ^|
echo  +==========================================================+
echo  ^|                                                          ^|
echo  ^|  ARIA needs Ollama to run AI models locally for free.   ^|
echo  ^|                                                          ^|
echo  ^|  INSTALL:                                               ^|
echo  ^|    1. Go to https://ollama.com/download                 ^|
echo  ^|    2. Run the Windows installer                         ^|
echo  ^|    3. Restart ARIA                                      ^|
echo  ^|                                                          ^|
echo  ^|  WHY OLLAMA?                                            ^|
echo  ^|    - 100%% free, no account needed                       ^|
echo  ^|    - Runs entirely on your PC                           ^|
echo  ^|    - Works offline after first model download           ^|
echo  ^|                                                          ^|
echo  ^|  REQUIREMENTS:                                          ^|
echo  ^|    - Windows 10 / 11 (64-bit)                          ^|
echo  ^|    - 8GB+ RAM                                           ^|
echo  ^|    - 5-10GB disk space                                  ^|
echo  ^|                                                          ^|
echo  +==========================================================+
echo.
echo  Opening download page...
pause >nul
start https://ollama.com/download
exit /b
