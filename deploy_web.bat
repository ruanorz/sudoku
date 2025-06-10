@echo off
SETLOCAL ENABLEEXTENSIONS
SET SCRIPT_NAME=deploy_web.bat

REM 🔐 Commit y push en main antes de nada
echo 💾 Guardando cambios en rama main...
git add . >nul
git commit -m "Pre-deploy backup: %date% %time%" >nul
git push origin main >nul || (
    echo ❌ Error al hacer push en main. Deteniendo despliegue.
    exit /b 1
)

REM 🧱 Compilar Flutter
echo 🔨 Compilando proyecto Flutter...
call flutter build web --release --base-href /sudoku/ || (
    echo ❌ Error al compilar. Verifica 'flutter doctor'.
    exit /b 1
)

REM 🚥 Cambiar a gh-pages
echo 🔄 Cambiando a rama gh-pages...
git checkout gh-pages 2>nul || (
    echo ❌ No se pudo cambiar a gh-pages. Abortando.
    exit /b 1
)

REM 🧹 Limpiar archivos (excepto build y el script)
echo 🧽 Limpiando archivos antiguos...
for /D %%d in (*) do (
    if /I NOT "%%d"=="build" (
        rmdir /S /Q "%%d"
    )
)
for %%f in (*) do (
    if /I NOT "%%f"=="%SCRIPT_NAME%" (
        del /F /Q "%%f"
    )
)

REM 📂 Copiar build/web a la raíz
echo 📦 Copiando archivos de build/web...
xcopy /E /I /Y build\web\* . >nul

REM 📄 Crear .nojekyll si no existe
echo 📝 Creando .nojekyll...
if not exist .nojekyll echo. > .nojekyll

REM 🔁 Commit y push en gh-pages
echo 📤 Subiendo cambios a GitHub Pages...
git add . >nul
git commit -m "Automated deploy: %date% %time%" >nul
git push origin gh-pages --force >nul

REM ↩ Volver a main
echo ↩ Volviendo a rama main...
git checkout main >nul 2>&1

echo ================================
echo ✅ Despliegue completado, shur.
echo 🌍 https://ruanorz.github.io/sudoku/
echo ================================
ENDLOCAL
