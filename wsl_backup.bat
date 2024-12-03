@echo off
setlocal enabledelayedexpansion

REM WSLディストリビューションのバックアップスクリプト
REM 使用方法: 
REM   wsl_backup.bat [ディストリビューション名] [バックアップパス(省略可:Default値 C:\wsl_images\)]
REM 例:
REM   wsl_backup.bat Ubuntu-22.04
REM   wsl_backup.bat Ubuntu-22.04 D:\backups

REM 引数チェック
if "%1"=="" (
    echo エラー: バックアップ対象のディストリビューション名を指定してください。
    echo 使用方法: wsl_backup.bat [ディストリビューション名] [バックアップパス(省略可:Default値 C:\wsl_images)]
    echo 例:
    echo wsl_backup.bat Ubuntu-22.04
    echo wsl_backup.bat Ubuntu-22.04 D:\backups
    echo.
    echo 利用可能なディストリビューション:
    wsl --list -v
    exit /b 1
)

REM システム管理者権限チェック
net session >nul 2>&1
if errorlevel 1 (
    echo エラー: このスクリプトには管理者権限が必要です。
    echo 管理者として実行してください。
    exit /b 1
)

REM WSLの状態確認
wsl --status >nul 2>&1
if errorlevel 1 (
    echo エラー: WSLが正常に動作していません。
    echo WSLのステータスを確認してください。
    exit /b 1
)

REM バックアップパスの設定
set "BACKUP_DIR=%2"
if "%BACKUP_DIR%"=="" (
    set "BACKUP_DIR=C:\wsl_images"
)

REM タイムスタンプの生成
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (
    set "DATE=%%c%%a%%b"
)
for /f "tokens=1-2 delims=: " %%a in ('time /t') do (
    set "TIME=%%a%%b"
)

REM バックアップファイル名の設定
set "BACKUP_FILE=!BACKUP_DIR!\%~1_!DATE!_!TIME!.tar"

REM バックアップディレクトリの確認と作成
if not exist "!BACKUP_DIR!" (
    echo バックアップディレクトリを作成します: !BACKUP_DIR!
    mkdir "!BACKUP_DIR!"
    if errorlevel 1 (
        echo エラー: バックアップディレクトリの作成に失敗しました。
        echo パスの権限や空き容量を確認してください。
        exit /b 1
    )
)

REM ディスク容量チェック
for /f "tokens=3" %%a in ('dir /-c "!BACKUP_DIR!" ^| findstr "バイトの空き"') do set "FREE_SPACE=%%a"
if !FREE_SPACE! LSS 10485760 (
    echo エラー: バックアップディレクトリの空き容量が不足しています。
    echo 最低10GB以上の空き容量が必要です。
    exit /b 1
)

echo.
echo バックアップを開始します...
echo 対象: %~1
echo 出力先: !BACKUP_FILE!
echo.

REM バックアップの実行
wsl --export "%~1" "!BACKUP_FILE!"
if errorlevel 1 (
    echo エラー: バックアップの作成に失敗しました。
    echo.
    echo 利用可能なディストリビューション:
    wsl --list -v
    echo.
    echo 詳細なエラーについてはWSLのログを確認してください。
    exit /b 1
)

REM バックアップファイルの確認
if not exist "!BACKUP_FILE!" (
    echo エラー: バックアップファイルが作成されませんでした。
    exit /b 1
)

echo.
echo バックアップが正常に完了しました。
echo 出力ファイル: !BACKUP_FILE!
echo ファイルサイズ: 
dir "!BACKUP_FILE!" | findstr "!DATE!"

endlocal
exit /b 0
