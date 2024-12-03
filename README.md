# wsl_backup_restore
WindowsのWSLのOSイメージのバックアップとリストアを行うバッチファイル

# wsl_backup.bat
WSLディストリビューションのバックアップスクリプト

**使用方法:** 
```cmd
wsl_backup.bat [ディストリビューション名] [バックアップパス(省略可:Default値 C:\wsl_images\)]
```
**例:**
```cmd
wsl_backup.bat Ubuntu-22.04
wsl_backup.bat Ubuntu-22.04 D:\backups
```

# wsl_restore.bat
WSLディストリビューションの復元スクリプト

**使用方法:**
```cmd
wsl_restore.bat [バックアップファイルパス] [復元先ディストリビューション名] [復元先ディレクトリ(省略可:Default値 C:\wsl_images\)]
```
**例:**
```cmd
wsl_restore.bat C:\wsl_images\backup.tar Ubuntu-Restore
wsl_restore.bat D:\backups\ubuntu_20231203_1200.tar MyUbuntu D:\wsl
```

