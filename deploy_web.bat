@echo off
SETLOCAL ENABLEEXTENSIONS
SET SCRIPT_NAME=%~nx0

REM 💾 Commit y push en main antes de nada
echo 💾 Guardando cambios en rama main...
git add . >nul
git commit -m "Pre-deploy backup: %date% %time%" >nul
git push origin main >nul || (
    echo ❌ Error al hacer push en main. Deteniendo despliegue.
    exit /b 1
)

REM 🔨 Compilar Flutter
echo 🔨 Compilando proyecto Flutter...
call flutter build web --release --base-href /sudoku/ || (
    echo ❌ Error al compilar. Verifica 'flutter doctor'.
    exit /b 1
)

REM 🗑️ Borrar rama gh-pages si existe
echo 🗑️ Eliminando rama gh-pages local (si existe)...
git branch -D gh-pages >nul 2>&1

REM 🆕 Crear nueva rama huérfana gh-pages
echo 🌱 Creando nueva rama gh-pages desde cero...
git checkout --orphan gh-pages || (
    echo ❌ No se pudo crear la rama gh-pages. Abortando.
    exit /b 1
)

REM 🧹 Limpiar archivos antiguos (excepto el script)
echo 🧽 Limpiando archivos antiguos (excepto %SCRIPT_NAME%)...
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

REM 🧹 Limpiar el índice de Git
echo 🗂️ Limpiando archivos del índice de Git...
git ls-files > .tmp_files.txt
for /F %%i in (.tmp_files.txt) do git rm --cached "%%i" >nul
del .tmp_files.txt

REM 📂 Copiar build/web al raíz
echo 📂 Copiando archivos de build/web...
xcopy /E /I /Y build\web\* . >nul

REM 📝 Crear .nojekyll
echo 📝 Creando .nojekyll...
if not exist .nojekyll echo. > .nojekyll

REM 🔁 Commit y push a gh-pages
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
