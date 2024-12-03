@echo off
setlocal enabledelayedexpansion

REM WSL�f�B�X�g���r���[�V�����̕����X�N���v�g
REM �g�p���@: 
REM   wsl_restore.bat [�o�b�N�A�b�v�t�@�C���p�X] [������f�B�X�g���r���[�V������] [������f�B���N�g��(�ȗ���:Default�l C:\wsl_images\)]
REM ��:
REM   wsl_restore.bat C:\wsl_images\backup.tar Ubuntu-Restore
REM   wsl_restore.bat D:\backups\ubuntu_20231203_1200.tar MyUbuntu D:\wsl

REM �����`�F�b�N
if "%1"=="" (
    echo �G���[: �o�b�N�A�b�v�t�@�C���̃p�X���w�肵�Ă��������B
    echo �g�p���@: wsl_restore.bat [�o�b�N�A�b�v�t�@�C���p�X] [������f�B�X�g���r���[�V������] [������f�B���N�g��(�ȗ���:Default�l C:\wsl_images)]
    echo ��:
    echo wsl_restore.bat C:\wsl_images\backup.tar Ubuntu-Restore
    echo wsl_restore.bat D:\backups\ubuntu_20231203_1200.tar MyUbuntu D:\wsl
    exit /b 1
)

if "%2"=="" (
    echo �G���[: ������̃f�B�X�g���r���[�V���������w�肵�Ă��������B
    echo �g�p���@: wsl_restore.bat [�o�b�N�A�b�v�t�@�C���p�X] [������f�B�X�g���r���[�V������] [������f�B���N�g��(�ȗ���:Default�l C:\wsl_images)]
    exit /b 1
)

REM �p�����[�^�̐ݒ�
set "BACKUP_FILE=%~1"
set "DISTRO_NAME=%2"
set "RESTORE_DIR=%3"

REM ������f�B���N�g�����w�肳��Ă��Ȃ��ꍇ�̃f�t�H���g�ݒ�
if "%RESTORE_DIR%"=="" (
    set "RESTORE_DIR=C:\wsl_images\%DISTRO_NAME%"
)

REM �V�X�e���Ǘ��Ҍ����`�F�b�N
net session >nul 2>&1
if errorlevel 1 (
    echo �G���[: ���̃X�N���v�g�ɂ͊Ǘ��Ҍ������K�v�ł��B
    echo �Ǘ��҂Ƃ��Ď��s���Ă��������B
    exit /b 1
)

REM WSL�̏�Ԋm�F
wsl --status >nul 2>&1
if errorlevel 1 (
    echo �G���[: WSL������ɓ��삵�Ă��܂���B
    echo WSL�̃X�e�[�^�X���m�F���Ă��������B
    exit /b 1
)

REM �o�b�N�A�b�v�t�@�C���̑��݊m�F
if not exist "!BACKUP_FILE!" (
    echo �G���[: �o�b�N�A�b�v�t�@�C����������܂���: !BACKUP_FILE!
    exit /b 1
)

REM �o�b�N�A�b�v�t�@�C���̐������`�F�b�N
echo �o�b�N�A�b�v�t�@�C���̐��������m�F���Ă��܂�...
tar tf "!BACKUP_FILE!" >nul 2>&1
if errorlevel 1 (
    echo �G���[: �o�b�N�A�b�v�t�@�C�����j�����Ă��邩�A�����ȃt�H�[�}�b�g�ł��B
    exit /b 1
)

REM �f�B�X�N�e�ʃ`�F�b�N
for /f "tokens=3" %%a in ('dir /-c "!BACKUP_FILE!" ^| findstr "�o�C�g"') do set "BACKUP_SIZE=%%a"
for /f "tokens=3" %%a in ('dir /-c "!RESTORE_DIR!\.." ^| findstr "�o�C�g�̋�"') do set "FREE_SPACE=%%a"
if !FREE_SPACE! LSS !BACKUP_SIZE! (
    echo �G���[: ������̃f�B�X�N�e�ʂ��s�����Ă��܂��B
    echo �K�v�ȗe��: !BACKUP_SIZE! �o�C�g
    echo ���p�\�ȗe��: !FREE_SPACE! �o�C�g
    exit /b 1
)

REM �����f�B���N�g���̊m�F�ƍ쐬
if not exist "!RESTORE_DIR!" (
    echo �����f�B���N�g�����쐬���܂�: !RESTORE_DIR!
    mkdir "!RESTORE_DIR!"
    if errorlevel 1 (
        echo �G���[: �����f�B���N�g���̍쐬�Ɏ��s���܂����B
        echo �p�X�̌�����󂫗e�ʂ��m�F���Ă��������B
        exit /b 1
    )
)

REM �����̃f�B�X�g���r���[�V�����̊m�F�ƍ폜
wsl --list | findstr /C:"!DISTRO_NAME!" >nul
if not errorlevel 1 (
    echo �x��: �����̃f�B�X�g���r���[�V���� "!DISTRO_NAME!" �����݂��܂��B
    choice /M "�����̃f�B�X�g���r���[�V�������폜���đ��s���܂����H"
    if errorlevel 2 (
        echo �������L�����Z�����܂����B
        exit /b 0
    )
    echo �����̃f�B�X�g���r���[�V�������폜���܂�...
    wsl --unregister "!DISTRO_NAME!"
    if errorlevel 1 (
        echo �G���[: �f�B�X�g���r���[�V�����̍폜�Ɏ��s���܂����B
        exit /b 1
    )
)

echo.
echo �������J�n���܂�...
echo �o�b�N�A�b�v�t�@�C��: !BACKUP_FILE!
echo ������f�B�X�g���r���[�V����: !DISTRO_NAME!
echo ������f�B���N�g��: !RESTORE_DIR!
echo.

REM WSL�f�B�X�g���r���[�V�����̕���
wsl --import "!DISTRO_NAME!" "!RESTORE_DIR!" "!BACKUP_FILE!"
if errorlevel 1 (
    echo �G���[: �f�B�X�g���r���[�V�����̕����Ɏ��s���܂����B
    echo WSL�̃��O���m�F���Ă��������B
    exit /b 1
)

echo.
echo ����������Ɋ������܂����B
echo.
echo �ȉ��̃R�}���h��WSL���N���ł��܂�:
echo   �f�t�H���g���[�U�[�iroot�j�ŋN��:
echo   wsl -d !DISTRO_NAME!
echo.
echo   ����̃��[�U�[�ŋN��:
echo   wsl -d !DISTRO_NAME! -u [���[�U�[��]
echo.
echo ����: �f�t�H���g���[�U�[��ύX����ꍇ�́A/etc/wsl.conf��ݒ肵�Ă��������B

endlocal
exit /b 0