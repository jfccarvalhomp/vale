@echo off
chcp 65001 >nul
setlocal

set /p projectNumber="Digite o numero da FDC: "
set /p featureNumber="Digite o numero da feature: "
set /p projectName="Digite o nome do projeto: "
set /p hldLink="Digite a URL do HLD: "

set "scriptDir=%~dp0"
set "modelFolder=%scriptDir%! MODELO"
set "newProjectFolder=%scriptDir%PROJETO X"
set "finalProjectFolder=%scriptDir%FDC - %projectNumber% (%featureNumber%) - %projectName%"

if exist "%finalProjectFolder%" (
    echo.
    echo ERRO: A pasta ja existe:
    echo %finalProjectFolder%
    pause
    exit /b
)

xcopy "%modelFolder%" "%newProjectFolder%" /E /I /H

ren "%newProjectFolder%\05 - OUTROS DOCUMENTOS\FDC XXX - XXXXXX - ANALISE.txt" "FDC-%projectNumber% - %featureNumber% - ANALISE.txt"
ren "%newProjectFolder%\02 - RFC CHG00\CHGXXX - FDC-XXXX-XXXX - Firewall Rules.xlsx" "Firewall Rules - CHG000XXXXX - FDC-%projectNumber% - %featureNumber% - v01.xlsx"
ren "%newProjectFolder%\02 - RFC CHG00\MOP - CHG000XXXXX - v01.docx" "MOP - CHG000XXXXX - FDC-%projectNumber% - %featureNumber% - v01.docx"
ren "%newProjectFolder%\02 - RFC CHG00\MOP - CHG000XXXXX - v01.xlsx" "MOP - CHG000XXXXX - FDC-%projectNumber% - %featureNumber% - v01.xlsx"
ren "%newProjectFolder%\01 - ESCOPO\FDC XXX - XXXXXX - ESCOPO.xlsx" "FDC-%projectNumber% - %featureNumber% - ESCOPO.xlsx"

ren "%newProjectFolder%" "FDC - %projectNumber% (%featureNumber%) - %projectName%"

set "urlFileName=URL - DevOPs - FDC-%projectNumber% - %featureNumber%.url"
set "urlFilePath=%finalProjectFolder%\05 - OUTROS DOCUMENTOS\%urlFileName%"

echo [InternetShortcut] > "%urlFilePath%"
echo URL=https://vale-devops.visualstudio.com/Global Telecom and Industrial Connectivity/_workitems/edit/%featureNumber% >> "%urlFilePath%"

set "obsidianFile=%finalProjectFolder%\FDC-%projectNumber% - Engenharia.md"

echo # FDC-%projectNumber% - %projectName% > "%obsidianFile%"
echo. >> "%obsidianFile%"
echo ## 1. Informações Gerais >> "%obsidianFile%"
echo. >> "%obsidianFile%"
echo ^| Campo ^| Informação ^| >> "%obsidianFile%"
echo ^|---^|---^| >> "%obsidianFile%"
echo ^| FDC ^| %projectNumber% ^| >> "%obsidianFile%"
echo ^| Feature / ID ^| %featureNumber% ^| >> "%obsidianFile%"
echo ^| Nome do Projeto ^| %projectName% ^| >> "%obsidianFile%"
echo ^| HLD LeanIX ^| %hldLink% ^| >> "%obsidianFile%"
echo ^| Status ^| 🟡 Em análise ^| >> "%obsidianFile%"
echo. >> "%obsidianFile%"
echo ## 2. Objetivo da Demanda >> "%obsidianFile%"
echo. >> "%obsidianFile%"
echo ## 3. Arquitetura / HLD >> "%obsidianFile%"
echo. >> "%obsidianFile%"
echo Link HLD: %hldLink% >> "%obsidianFile%"
echo. >> "%obsidianFile%"
echo ## 4. Fluxos de Comunicação >> "%obsidianFile%"
echo. >> "%obsidianFile%"
echo ^| Origem ^| Destino ^| Porta ^| Protocolo ^| Sentido ^| Justificativa ^| >> "%obsidianFile%"
echo ^|---^|---^|---^|---^|---^|---^| >> "%obsidianFile%"
echo ^|  ^|  ^|  ^|  ^|  ^|  ^| >> "%obsidianFile%"
echo. >> "%obsidianFile%"
echo ## 5. Checklist Técnico >> "%obsidianFile%"
echo. >> "%obsidianFile%"
echo - [ ] Origem validada >> "%obsidianFile%"
echo - [ ] Destino validado >> "%obsidianFile%"
echo - [ ] Porta validada >> "%obsidianFile%"
echo - [ ] Proxy avaliado >> "%obsidianFile%"
echo - [ ] SSL Inspection avaliado >> "%obsidianFile%"
echo - [ ] NAT avaliado >> "%obsidianFile%"
echo. >> "%obsidianFile%"
echo ## 6. RFC / MOP >> "%obsidianFile%"
echo. >> "%obsidianFile%"
echo - CHG: >> "%obsidianFile%"
echo - MOP criado: [ ] >> "%obsidianFile%"
echo - MOP aprovado: [ ] >> "%obsidianFile%"
echo. >> "%obsidianFile%"
echo ## 7. Testes >> "%obsidianFile%"
echo. >> "%obsidianFile%"
echo ```powershell >> "%obsidianFile%"
echo Test-NetConnection destino -Port porta >> "%obsidianFile%"
echo ``` >> "%obsidianFile%"
echo. >> "%obsidianFile%"
echo ## 8. Evidências >> "%obsidianFile%"
echo. >> "%obsidianFile%"
echo - [ ] HLD anexado >> "%obsidianFile%"
echo - [ ] Aprovação arquiteto >> "%obsidianFile%"
echo - [ ] Testes salvos >> "%obsidianFile%"
echo - [ ] Logs salvos >> "%obsidianFile%"
echo. >> "%obsidianFile%"
echo ## 9. Lições Aprendidas >> "%obsidianFile%"
echo. >> "%obsidianFile%"
echo ## 10. Histórico >> "%obsidianFile%"
echo. >> "%obsidianFile%"
echo ^| Data ^| Alteração ^| Responsável ^| >> "%obsidianFile%"
echo ^|---^|---^|---^| >> "%obsidianFile%"

echo.
echo Projeto configurado com sucesso:
echo %finalProjectFolder%

echo.
echo Status do Git:
git status

:: Cria nota de Engenharia da FDC para o Obsidian

set "obsidianFile=%finalProjectFolder%\FDC-%projectNumber% - Engenharia.md"

echo # FDC-%projectNumber% - %projectName% > "%obsidianFile%"
echo. >> "%obsidianFile%"
echo ## Informações Gerais >> "%obsidianFile%"
echo. >> "%obsidianFile%"
echo ^| Campo ^| Informação ^| >> "%obsidianFile%"
echo ^|---^|---^| >> "%obsidianFile%"
echo ^| FDC ^| %projectNumber% ^| >> "%obsidianFile%"
echo ^| Feature / ID ^| %featureNumber% ^| >> "%obsidianFile%"
echo ^| Projeto ^| %projectName% ^| >> "%obsidianFile%"
echo ^| HLD LeanIX ^| %hldLink% ^| >> "%obsidianFile%"
echo ^| Status ^| Em análise ^| >> "%obsidianFile%"
echo. >> "%obsidianFile%"
echo ## Objetivo da Demanda >> "%obsidianFile%"
echo. >> "%obsidianFile%"
echo ## Arquitetura / HLD >> "%obsidianFile%"
echo Link HLD: %hldLink% >> "%obsidianFile%"
echo. >> "%obsidianFile%"
echo ## Fluxos de Comunicação >> "%obsidianFile%"
echo. >> "%obsidianFile%"
echo ^| Origem ^| Destino ^| Porta ^| Protocolo ^| Sentido ^| Justificativa ^| >> "%obsidianFile%"
echo ^|---^|---^|---^|---^|---^|---^| >> "%obsidianFile%"
echo ^|  ^|  ^|  ^|  ^|  ^|  ^| >> "%obsidianFile%"
echo. >> "%obsidianFile%"
echo ## Checklist Técnico >> "%obsidianFile%"
echo - [ ] Origem validada >> "%obsidianFile%"
echo - [ ] Destino validado >> "%obsidianFile%"
echo - [ ] Porta validada >> "%obsidianFile%"
echo - [ ] Proxy avaliado >> "%obsidianFile%"
echo - [ ] SSL Inspection avaliado >> "%obsidianFile%"
echo - [ ] NAT avaliado >> "%obsidianFile%"
echo. >> "%obsidianFile%"
echo ## RFC / MOP >> "%obsidianFile%"
echo - CHG: >> "%obsidianFile%"
echo - MOP criado: [ ] >> "%obsidianFile%"
echo - MOP aprovado: [ ] >> "%obsidianFile%"
echo. >> "%obsidianFile%"
echo ## Testes >> "%obsidianFile%"
echo Test-NetConnection destino -Port porta >> "%obsidianFile%"
echo. >> "%obsidianFile%"
echo ## Evidências >> "%obsidianFile%"
echo - [ ] HLD anexado >> "%obsidianFile%"
echo - [ ] Aprovação arquiteto >> "%obsidianFile%"
echo - [ ] Testes salvos >> "%obsidianFile%"
echo - [ ] Logs salvos >> "%obsidianFile%"
echo. >> "%obsidianFile%"
echo ## Lições Aprendidas >> "%obsidianFile%"
echo. >> "%obsidianFile%"
echo ## Histórico >> "%obsidianFile%"
echo ^| Data ^| Alteração ^| Responsável ^| >> "%obsidianFile%"
echo ^|---^|---^|---^| >> "%obsidianFile%"
echo ^| %date% ^| Criação da estrutura da FDC ^| Jefferson ^| >> "%obsidianFile%"

echo.
echo Nota Obsidian criada:
echo %obsidianFile%

echo.
echo Status do Git:
git status
pause