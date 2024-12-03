@echo off
setlocal enabledelayedexpansion

REM WSL��vhdx�t�@�C���T�C�Y�m�F�X�N���v�g
echo WSL���z�f�B�X�N(vhdx)�t�@�C���̃T�C�Y�m�F
echo ========================================
echo.

REM ���[�U�[�����擾
set "USER_NAME=%USERNAME%"

REM �����p�X�ݒ�i�����̃p�^�[�����m�F�j
set "SEARCH_PATH_1=%LOCALAPPDATA%\Packages"
set "SEARCH_PATH_2=%LOCALAPPDATA%\Docker\wsl"
set "SEARCH_PATH_3=C:\wsl_images"
set "FOUND_FILES=0"

echo �����p�X:
echo 1. %SEARCH_PATH_1%
echo 2. %SEARCH_PATH_2%
echo 3. %SEARCH_PATH_3%
echo.

REM �T�C�Y���v�p�ϐ�
set TOTAL_SIZE=0

REM 1�ڂ̃p�^�[��: LocalAppData\Packages����WSL�֘A�t�@�C��
echo WSL�p�b�P�[�W�̌�����...
for /f "delims=" %%F in ('dir /s /b "%SEARCH_PATH_1%\*WSL*\LocalState\*.vhdx" 2^>nul') do (
    call :PROCESS_FILE "%%F"
)

REM 2�ڂ̃p�^�[��: Docker�t�H���_����WSL�t�@�C��
echo Docker�̉��z�f�B�X�N������...
for /f "delims=" %%F in ('dir /s /b "%SEARCH_PATH_2%\*.vhdx" 2^>nul') do (
    call :PROCESS_FILE "%%F"
)

REM 3�ڂ̃p�^�[��: �J�X�^��WSL�C���[�W�t�H���_
echo �J�X�^��WSL�C���[�W�̌�����...
for /f "delims=" %%F in ('dir /s /b "%SEARCH_PATH_3%\*.vhdx" 2^>nul') do (
    call :PROCESS_FILE "%%F"
)

if !FOUND_FILES! EQU 0 (
    echo.
    echo �x��: vhdx�t�@�C����������܂���B
    echo �l�����錴��:
    echo - WSL���C���X�g�[������Ă��Ȃ�
    echo - �ʂ̏ꏊ�Ƀt�@�C�������݂���
    echo - �A�N�Z�X�����̖��
    echo.
    echo �f�o�b�O���:
    echo Current User: %USERNAME%
    echo LocalAppData: %LOCALAPPDATA%
    wsl --list -v
)

REM ���v�T�C�Y��\��
echo.
set /a "TOTAL_GB=!TOTAL_SIZE! / 1024 / 1024 / 1024"
set /a "TOTAL_MB=(!TOTAL_SIZE! / 1024 / 1024) %% 1024"
echo ���v�T�C�Y: !TOTAL_GB!.!TOTAL_MB! GB
echo ���������t�@�C����: !FOUND_FILES!
echo.

echo ����:
echo - vhdx�t�@�C���̃T�C�Y�͎��ۂ̎g�p�ʂ��傫���ꍇ������܂�
echo - ���g�p�̈���������ɂ� 'wsl --shutdown' �����s��A
echo   PowerShell�� 'optimize-vhd' �R�}���h�����s���Ă�������

goto :END

:PROCESS_FILE
set /a "FOUND_FILES+=1"
echo.
echo �t�@�C�� !FOUND_FILES!:
echo �p�X: %~1

REM �t�@�C���T�C�Y���o�C�g�P�ʂŎ擾
for %%S in (%~1) do set "FILE_SIZE=%%~zS"

REM �T�C�Y��P�ʕϊ����ĕ\���iGB�j
set /a "SIZE_GB=!FILE_SIZE! / 1024 / 1024 / 1024"
set /a "SIZE_MB=(!FILE_SIZE! / 1024 / 1024) %% 1024"
echo �T�C�Y: !SIZE_GB!.!SIZE_MB! GB

REM ���v�ɉ��Z
set /a "TOTAL_SIZE+=!FILE_SIZE!"

REM �t�@�C�������琄�������f�B�X�g���r���[�V��������\��
for %%D in (%~dp1.) do (
    echo �֘A�p�b�P�[�W: %%~nxD
)
exit /b

:END
endlocal
pause