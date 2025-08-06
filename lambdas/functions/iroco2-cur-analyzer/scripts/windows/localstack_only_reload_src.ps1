# Variables
$sourceDir = ".\src"
$targetDir = ".\cur_processor\src"

# Vérifier si le dossier cible existe
if (Test-Path -Path $targetDir) {
    # Supprimer le dossier cible
    Remove-Item -Path $targetDir -Recurse -Force
    Write-Output "Dossier cible supprimé : $targetDir"
} else {
    Write-Output "Dossier cible n'existe pas : $targetDir"
}

# Copier le dossier source vers la destination
Copy-Item -Path $sourceDir -Destination $targetDir -Recurse
Write-Output "Dossier source copié vers le dossier cible : $sourceDir -> $targetDir"

Set-Location cur_processor
zip -r src.zip .

# Variables
$FunctionName = "lambda-cur-processor-iroco2"
$LocalZipFile = "src.zip"

# Mettre à jour le code Lambda depuis un fichier zip local
aws lambda update-function-code --function-name $FunctionName --zip-file fileb://$LocalZipFile

Set-Location ..

Write-Output "Mise à jour de la fonction Lambda $FunctionName terminée."
