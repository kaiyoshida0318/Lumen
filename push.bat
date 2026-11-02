@echo off
chcp 65001 >nul
setlocal
cd /d "%~dp0"

where git >nul 2>&1
if errorlevel 1 (
  echo [エラー] git が見つかりません。Git for Windows をインストールしてください。
  goto :end
)

git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
  echo [エラー] このフォルダは Git リポジトリではありません。
  goto :end
)

echo === 変更されたファイル ===
git status --short
echo.

git add -A
git diff --cached --quiet
if not errorlevel 1 (
  echo コミットする変更はありません。
  goto :end
)

set "MSG=%*"
if "%MSG%"=="" set /p "MSG=コミットメッセージ（空欄で日時を使用）: "
if "%MSG%"=="" (
  for /f "delims=" %%i in ('powershell -NoProfile -Command "Get-Date -Format 'yyyy-MM-dd HH:mm'"') do set "MSG=update %%i"
)

git commit -m "%MSG%"
if errorlevel 1 (
  echo [エラー] コミットに失敗しました。
  goto :end
)

git push
if errorlevel 1 (
  echo.
  echo [エラー] push に失敗しました。上のメッセージを確認してください。
  echo  - rejected と出た場合: 先に git pull を実行してください
  echo  - 認証エラーの場合: gh auth login か Personal Access Token を設定してください
  goto :end
)

echo.
echo 完了しました: "%MSG%"

:end
endlocal
pause
