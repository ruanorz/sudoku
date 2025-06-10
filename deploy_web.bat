@echo off
SETLOCAL

REM Compilar el proyecto (con 'call' y manejo de errores)
echo 🔨 Compilando proyecto Flutter...
call flutter build web --release --base-href /sudoku/ || (
    echo ❌ Error al compilar. Verifica 'flutter doctor'.
    exit /b 1
)

REM Cambiar a gh-pages (crearla si no existe)
echo 🔄 Cambiando a rama gh-pages...
git checkout gh-pages 2>nul || git checkout --orphan gh-pages

REM Limpiar archivos (excepto build y el script)
echo 🧹 Limpiando archivos antiguos...
for /D %%d in (*) do (
    if /I NOT "%%d"=="build" (
        rmdir /S /Q "%%d"
    )
)
for %%f in (*) do (
    if /I NOT "%%f"=="deploy_web.bat" (
        del /F /Q "%%f"
    )
)

REM Copiar build/web a la raíz
echo 📂 Copiando archivos de build/web...
xcopy /E /I /Y build\web\* . >nul

REM Crear .nojekyll si no existe
echo 📝 Creando .nojekyll...
if not exist .nojekyll echo. > .nojekyll

REM Hacer commit y push
echo 🔄 Subiendo cambios a GitHub...
git add . >nul
git commit -m "Automated deploy: %date% %time%" >nul
git push origin gh-pages --force >nul

REM Volver a main
echo ↩ Volviendo a rama main...
git checkout main >nul 2>&1

echo ================================
echo ✅ Despliegue completado, shur.
echo 🌍 https://ruanorz.github.io/sudoku/
echo ================================
ENDLOCAL