Import-Module ActiveDirectory

# Chargement du CSV
$users = Import-Csv -Path ".\users.csv"

# Mot de passe par défaut pour tous
$password = ConvertTo-SecureString "Azerty_2025!" -AsPlainText -Force

# --- Création des groupes ---
$allGroups = @()

foreach ($u in $users) {
    $allGroups += $u.Groupe1, $u.Groupe2, $u.Groupe3, $u.Groupe4, $u.Groupe5, $u.Groupe6
}

$allGroups = $allGroups | Where-Object { $_ -and $_ -ne "" } | Sort-Object -Unique

foreach ($g in $allGroups) {
    if (-not (Get-ADGroup -Filter "Name -eq '$g'" -ErrorAction SilentlyContinue)) {
        New-ADGroup -Name $g -GroupScope Global -Path "CN=Users,DC=laplateforme,DC=io"
        Write-Host "Groupe créé : $g"
    }
}

# --- Création des utilisateurs + affectation aux groupes ---
foreach ($u in $users) {

    # Création du SamAccountName : 1ère lettre prénom + nom
    $sam = ($u.Prenom.Substring(0,1) + $u.Nom).ToLower()

    # Création de l’utilisateur si inexistant
    if (-not (Get-ADUser -Filter "SamAccountName -eq '$sam'" -ErrorAction SilentlyContinue)) {

        New-ADUser `
            -Name "$($u.Prenom) $($u.Nom)" `
            -GivenName $u.Prenom `
            -Surname $u.Nom `
            -SamAccountName $sam `
            -UserPrincipalName "$sam@laplateforme.io" `
            -AccountPassword $password `
            -Enabled $true `
            -ChangePasswordAtLogon $true `
            -Path "CN=Users,DC=laplateforme,DC=io"

        Write-Host "Utilisateur créé : $sam"
    }

    # Récupération des groupes de l'utilisateur
    $groups = @(
        $u.Groupe1,
        $u.Groupe2,
        $u.Groupe3,
        $u.Groupe4,
        $u.Groupe5,
        $u.Groupe6
    ) | Where-Object { $_ -and $_ -ne "" }

    # Ajout aux groupes
    foreach ($g in $groups) {
        Add-ADGroupMember -Identity $g -Members $sam -ErrorAction SilentlyContinue
        Write-Host "  -> Ajouté au groupe : $g"
    }
}

Write-Host "=== Import terminé ==="