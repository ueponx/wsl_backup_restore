@echo off
setlocal enabledelayedexpansion

REM WSLのvhdxファイルサイズ確認スクリプト
echo WSL仮想ディスク(vhdx)ファイルのサイズ確認
echo ========================================
echo.

REM ユーザー名を取得
set "USER_NAME=%USERNAME%"

REM 検索パス設定（複数のパターンを確認）
set "SEARCH_PATH_1=%LOCALAPPDATA%\Packages"
set "SEARCH_PATH_2=%LOCALAPPDATA%\Docker\wsl"
set "SEARCH_PATH_3=C:\wsl_images"
set "FOUND_FILES=0"

echo 検索パス:
echo 1. %SEARCH_PATH_1%
echo 2. %SEARCH_PATH_2%
echo 3. %SEARCH_PATH_3%
echo.

REM サイズ合計用変数
set TOTAL_SIZE=0

REM 1つ目のパターン: LocalAppData\Packages内のWSL関連ファイル
echo WSLパッケージの検索中...
for /f "delims=" %%F in ('dir /s /b "%SEARCH_PATH_1%\*WSL*\LocalState\*.vhdx" 2^>nul') do (
    call :PROCESS_FILE "%%F"
)

REM 2つ目のパターン: Dockerフォルダ内のWSLファイル
echo Dockerの仮想ディスク検索中...
for /f "delims=" %%F in ('dir /s /b "%SEARCH_PATH_2%\*.vhdx" 2^>nul') do (
    call :PROCESS_FILE "%%F"
)

REM 3つ目のパターン: カスタムWSLイメージフォルダ
echo カスタムWSLイメージの検索中...
for /f "delims=" %%F in ('dir /s /b "%SEARCH_PATH_3%\*.vhdx" 2^>nul') do (
    call :PROCESS_FILE "%%F"
)

if !FOUND_FILES! EQU 0 (
    echo.
    echo 警告: vhdxファイルが見つかりません。
    echo 考えられる原因:
    echo - WSLがインストールされていない
    echo - 別の場所にファイルが存在する
    echo - アクセス権限の問題
    echo.
    echo デバッグ情報:
    echo Current User: %USERNAME%
    echo LocalAppData: %LOCALAPPDATA%
    wsl --list -v
)

REM 合計サイズを表示
echo.
set /a "TOTAL_GB=!TOTAL_SIZE! / 1024 / 1024 / 1024"
set /a "TOTAL_MB=(!TOTAL_SIZE! / 1024 / 1024) %% 1024"
echo 合計サイズ: !TOTAL_GB!.!TOTAL_MB! GB
echo 見つかったファイル数: !FOUND_FILES!
echo.

echo 注意:
echo - vhdxファイルのサイズは実際の使用量より大きい場合があります
echo - 未使用領域を回収するには 'wsl --shutdown' を実行後、
echo   PowerShellで 'optimize-vhd' コマンドを実行してください

goto :END

:PROCESS_FILE
set /a "FOUND_FILES+=1"
echo.
echo ファイル !FOUND_FILES!:
echo パス: %~1

REM ファイルサイズをバイト単位で取得
for %%S in (%~1) do set "FILE_SIZE=%%~zS"

REM サイズを単位変換して表示（GB）
set /a "SIZE_GB=!FILE_SIZE! / 1024 / 1024 / 1024"
set /a "SIZE_MB=(!FILE_SIZE! / 1024 / 1024) %% 1024"
echo サイズ: !SIZE_GB!.!SIZE_MB! GB

REM 合計に加算
set /a "TOTAL_SIZE+=!FILE_SIZE!"

REM ファイル名から推測されるディストリビューション名を表示
for %%D in (%~dp1.) do (
    echo 関連パッケージ: %%~nxD
)
exit /b

:END
endlocal
pause