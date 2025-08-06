.\scripts\windows\build_python_zip.ps1

# Variables
$FunctionName = "lambda-cur-processor-iroco2"
$LocalZipFile = ".\src.zip"

# Mettre à jour le code Lambda depuis un fichier zip local
aws lambda update-function-code --function-name $FunctionName --zip-file fileb://$LocalZipFile

Set-Location ..

Write-Output "Mise à jour de la fonction Lambda $FunctionName terminée."
