@echo off
setlocal

:: Solicita os dados ao usuário
set /p projectNumber="Digite o numero do projeto: "
set /p featureNumber="Digite o numero da feature: "
set /p projectName="Digite o nome do projeto: "
set /p hldLink="Digite a URL do HLD: "

:: Obtém o diretório onde o script está localizado

set "scriptDir=%~dp0"

:: Define o nome da pasta modelo e da nova pasta do projeto

set "modelFolder=%scriptDir%! MODELO"
set "newProjectFolder=%scriptDir%PROJETO X"

:: Copia a pasta modelo para a nova pasta do projeto

xcopy "%modelFolder%" "%newProjectFolder%" /E /I /H

:: Renomeia os arquivos dentro da nova pasta do projeto

ren "%newProjectFolder%\05 - OUTROS DOCUMENTOS\FDC XXX - XXXXXX - ANALISE.txt" "FDC-%projectNumber% - %featureNumber% - ANALISE.txt"
ren "%newProjectFolder%\02 - RFC CHG00\CHGXXX - FDC-XXXX-XXXX - Firewall Rules.xlsx" "Firewall Rules - CHG000XXXXX - FDC-%projectNumber% - %featureNumber% - v01.xlsx"
ren "%newProjectFolder%\02 - RFC CHG00\MOP - CHG000XXXXX - v01.docx" "MOP - CHG000XXXXX - FDC-%projectNumber% - %featureNumber% - v01.docx"
ren "%newProjectFolder%\02 - RFC CHG00\MOP - CHG000XXXXX - v01.xlsx" "MOP - CHG000XXXXX - FDC-%projectNumber% - %featureNumber% - v01.xlsx"
ren "%newProjectFolder%\01 - ESCOPO\FDC XXX - XXXXXX - ESCOPO.xlsx" "FDC-%projectNumber% - %featureNumber% - ESCOPO.xlsx"

:: Renomeia a pasta do projeto

set "finalProjectFolder=%scriptDir%FDC - %projectNumber% (%featureNumber%) - %projectName%"
ren "%newProjectFolder%" "FDC - %projectNumber% (%featureNumber%) - %projectName%"

:: Cria o arquivo .url

set "urlFileName=URL - DevOPs - FDC-%projectNumber% - %featureNumber%.url"
set "urlFilePath=%finalProjectFolder%\05 - OUTROS DOCUMENTOS\%urlFileName%"
echo [InternetShortcut] > "%urlFilePath%"
echo URL=https://vale-devops.visualstudio.com/Global Telecom and Industrial Connectivity/_workitems/edit/%featureNumber% >> "%urlFilePath%"

echo Projeto configurado com sucesso: %finalProjectFolder%
pause