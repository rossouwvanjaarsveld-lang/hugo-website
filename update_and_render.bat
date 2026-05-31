@echo off
setlocal

:: ============================================================
:: CONFIGURATION — adjust these paths if anything moves
:: ============================================================
set HUGO_SITE=C:\Users\user pc\Desktop\my-hugo-website
set SCRAPE_SCRIPT=C:\Users\user pc\Desktop\website-code\ee-etf-tracker\scrape_etfs.R
set POST_DIR=%HUGO_SITE%\content\posts\ee-etf-tracker
set STATIC_DIR=%HUGO_SITE%\static\posts\ee-etf-tracker
set QUARTO=C:\Program Files\RStudio\resources\app\bin\quarto\bin\quarto.exe
set RSCRIPT=C:\Program Files\R\R-4.6.0\bin\Rscript.exe

:: ============================================================
:: STEP 1 — Run the R scraping script to refresh ETF data
:: ============================================================
echo.
echo [1/5] Running R scrape script to update ETF data...
set HUGO_FWD=C:/Users/user pc/Desktop/my-hugo-website
set SCRIPT_FWD=C:/Users/user pc/Desktop/website-code/ee-etf-tracker/scrape_etfs.R
set HUGO_FWD=C:/Users/user pc/Desktop/my-hugo-website
set SCRIPT_FWD=C:/Users/user pc/Desktop/website-code/ee-etf-tracker/scrape_etfs.R
"%RSCRIPT%" --vanilla -e "setwd('%HUGO_FWD%/content'); source('%SCRIPT_FWD%')"
if errorlevel 1 (
    echo ERROR: R scrape script failed. Stopping.
    pause
    exit /b 1
)
cd /d "%HUGO_SITE%"
echo Done.

:: ============================================================
:: STEP 2 — Copy updated data files to static folder
:: ============================================================
echo.
echo [2/5] Copying data files to static...
xcopy "%POST_DIR%\data" "%STATIC_DIR%\data" /E /I /Y /Q
echo Done.

:: ============================================================
:: STEP 3 — Render the post with Quarto
:: ============================================================
echo.
echo [3/5] Rendering post with Quarto...
"%QUARTO%" render "%POST_DIR%\index.qmd"
if errorlevel 1 (
    echo ERROR: Quarto render failed. Stopping.
    pause
    exit /b 1
)
echo Done.

:: ============================================================
:: STEP 4 — Copy OJS runtime files to static
:: ============================================================
echo.
echo [4/5] Copying OJS runtime files to static...
xcopy "%POST_DIR%\index_files" "%STATIC_DIR%\index_files" /E /I /Y /Q
echo Done.

:: ============================================================
:: STEP 5 — Copy thumbnail image to static
:: ============================================================
echo.
echo [5/5] Copying thumbnail to static...
for %%f in ("%POST_DIR%\*.JPG" "%POST_DIR%\*.jpg" "%POST_DIR%\*.png" "%POST_DIR%\*.PNG") do (
    copy "%%f" "%STATIC_DIR%\" /Y > nul 2>&1
)
echo Done.

:: ============================================================
:: ALL DONE
:: ============================================================
echo.
echo ============================================================
echo  All steps completed successfully.
echo  Run 'hugo server' to preview, or push to GitHub to deploy.
echo ============================================================
echo.

:: ============================================================
:: PUSH TO GITHUB
:: ============================================================
echo.
echo [6/6] Pushing to GitHub...
cd /d "%HUGO_SITE%"
git add .
git commit -m "update etf data"
git pull origin main --rebase
git push
echo Done.
echo.
pause

