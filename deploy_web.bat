@echo off
SETLOCAL ENABLEEXTENSIONS
SET SCRIPT_NAME=deploy_web.bat

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

REM 🔃 Eliminar rama gh-pages si existe localmente
echo 🗑️ Eliminando rama gh-pages local (si existe)...
git branch -D gh-pages >nul 2>&1

REM 🌱 Crear rama gh-pages desde cero
echo 🆕 Creando nueva rama gh-pages...
git checkout --orphan gh-pages || (
    echo ❌ No se pudo crear la rama gh-pages. Abortando.
    exit /b 1
)

REM 🧽 Limpiar todo (índice y archivos)
git rm -rf . >nul 2>&1

REM 📦 Copiar archivos de build/web
echo 📂 Copiando archivos de build/web...
xcopy /E /I /Y build\web\* . >nul

REM 📝 Crear .nojekyll
echo 📝 Creando .nojekyll...
if not exist .nojekyll echo. > .nojekyll

REM 📤 Commit y push a gh-pages
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
