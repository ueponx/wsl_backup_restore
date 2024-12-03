@echo off
setlocal enabledelayedexpansion

REM WSLディストリビューションの復元スクリプト
REM 使用方法: 
REM   wsl_restore.bat [バックアップファイルパス] [復元先ディストリビューション名] [復元先ディレクトリ(省略可:Default値 C:\wsl_images\)]
REM 例:
REM   wsl_restore.bat C:\wsl_images\backup.tar Ubuntu-Restore
REM   wsl_restore.bat D:\backups\ubuntu_20231203_1200.tar MyUbuntu D:\wsl

REM 引数チェック
if "%1"=="" (
    echo エラー: バックアップファイルのパスを指定してください。
    echo 使用方法: wsl_restore.bat [バックアップファイルパス] [復元先ディストリビューション名] [復元先ディレクトリ(省略可:Default値 C:\wsl_images)]
    echo 例:
    echo wsl_restore.bat C:\wsl_images\backup.tar Ubuntu-Restore
    echo wsl_restore.bat D:\backups\ubuntu_20231203_1200.tar MyUbuntu D:\wsl
    exit /b 1
)

if "%2"=="" (
    echo エラー: 復元先のディストリビューション名を指定してください。
    echo 使用方法: wsl_restore.bat [バックアップファイルパス] [復元先ディストリビューション名] [復元先ディレクトリ(省略可:Default値 C:\wsl_images)]
    exit /b 1
)

REM パラメータの設定
set "BACKUP_FILE=%~1"
set "DISTRO_NAME=%2"
set "RESTORE_DIR=%3"

REM 復元先ディレクトリが指定されていない場合のデフォルト設定
if "%RESTORE_DIR%"=="" (
    set "RESTORE_DIR=C:\wsl_images\%DISTRO_NAME%"
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

REM バックアップファイルの存在確認
if not exist "!BACKUP_FILE!" (
    echo エラー: バックアップファイルが見つかりません: !BACKUP_FILE!
    exit /b 1
)

REM バックアップファイルの整合性チェック
echo バックアップファイルの整合性を確認しています...
tar tf "!BACKUP_FILE!" >nul 2>&1
if errorlevel 1 (
    echo エラー: バックアップファイルが破損しているか、無効なフォーマットです。
    exit /b 1
)

REM ディスク容量チェック
for /f "tokens=3" %%a in ('dir /-c "!BACKUP_FILE!" ^| findstr "バイト"') do set "BACKUP_SIZE=%%a"
for /f "tokens=3" %%a in ('dir /-c "!RESTORE_DIR!\.." ^| findstr "バイトの空き"') do set "FREE_SPACE=%%a"
if !FREE_SPACE! LSS !BACKUP_SIZE! (
    echo エラー: 復元先のディスク容量が不足しています。
    echo 必要な容量: !BACKUP_SIZE! バイト
    echo 利用可能な容量: !FREE_SPACE! バイト
    exit /b 1
)

REM 復元ディレクトリの確認と作成
if not exist "!RESTORE_DIR!" (
    echo 復元ディレクトリを作成します: !RESTORE_DIR!
    mkdir "!RESTORE_DIR!"
    if errorlevel 1 (
        echo エラー: 復元ディレクトリの作成に失敗しました。
        echo パスの権限や空き容量を確認してください。
        exit /b 1
    )
)

REM 既存のディストリビューションの確認と削除
wsl --list | findstr /C:"!DISTRO_NAME!" >nul
if not errorlevel 1 (
    echo 警告: 既存のディストリビューション "!DISTRO_NAME!" が存在します。
    choice /M "既存のディストリビューションを削除して続行しますか？"
    if errorlevel 2 (
        echo 復元をキャンセルしました。
        exit /b 0
    )
    echo 既存のディストリビューションを削除します...
    wsl --unregister "!DISTRO_NAME!"
    if errorlevel 1 (
        echo エラー: ディストリビューションの削除に失敗しました。
        exit /b 1
    )
)

echo.
echo 復元を開始します...
echo バックアップファイル: !BACKUP_FILE!
echo 復元先ディストリビューション: !DISTRO_NAME!
echo 復元先ディレクトリ: !RESTORE_DIR!
echo.

REM WSLディストリビューションの復元
wsl --import "!DISTRO_NAME!" "!RESTORE_DIR!" "!BACKUP_FILE!"
if errorlevel 1 (
    echo エラー: ディストリビューションの復元に失敗しました。
    echo WSLのログを確認してください。
    exit /b 1
)

echo.
echo 復元が正常に完了しました。
echo.
echo 以下のコマンドでWSLを起動できます:
echo   デフォルトユーザー（root）で起動:
echo   wsl -d !DISTRO_NAME!
echo.
echo   特定のユーザーで起動:
echo   wsl -d !DISTRO_NAME! -u [ユーザー名]
echo.
echo 注意: デフォルトユーザーを変更する場合は、/etc/wsl.confを設定してください。

endlocal
exit /b 0