#!powershell
# This file is part of Ansible
#
# Copyright 2015, Hans-Joachim Kliemeck <git@kliemeck.de>
#
# Ansible is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ansible is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ansible.  If not, see <http://www.gnu.org/licenses/>.

# WANT_JSON
# POWERSHELL_COMMON

$params = Parse-Args $args;

$result = New-Object PSObject;
Set-Attr $result "changed" $false;

$name = Get-Attr $params "name" -failifempty $true
$state = Get-Attr $params "state" "present"
$path = Get-Attr $params "path" ""

$user = Get-Attr $params "user" ""
$password = Get-Attr $params "password" ""

$startMode = Get-Attr $params "start_mode" "auto"

$displayName = Get-Attr $params "display_name" $name
$description = Get-Attr $params "description" $null

If ($state) {
    $state = $state.ToString().ToLower()
    If (($state -ne 'present') -and ($state -ne 'absent')) {
        Fail-Json $result "state is '$state'; must be 'present' or 'absent'"
    }
}

Try {
    $svc = Get-WmiObject -Class Win32_Service -Filter "Name='$name'"
    If ($state -eq "absent") {
        If ($svc) {
            $svc.delete()
            Set-Attr $result "changed" $true;
        }
    }
    Else {
        If ($path -eq "") {
            Fail-Json $result "state is present, path must be informed"
        }
        If ($startMode) {
            $startMode = $startMode.ToString().ToLower()
            If (($startMode -ne 'auto') -and ($startMode -ne 'manual') -and ($startMode -ne 'disabled')) {
                Fail-Json $result "start mode is '$startMode'; must be 'auto', 'manual', or 'disabled'"
            }
        }

        If (-not $svc) {
            New-Service -Name $name -BinaryPathName $path

            # refresh variable
            $svc = Get-WmiObject -Class Win32_Service -Filter "Name='$name'"
            Set-Attr $result "changed" $true;
        }

        If ($svc.PathName -ne $path) {
            # remove and create service, since its not possible to change path name
            $svc.delete()

            New-Service -Name $name -BinaryPathName $path

            $svc = Get-WmiObject -Class Win32_Service -Filter "Name='$name'"
            Set-Attr $result "changed" $true;
        }
        If (($user -ne "") -And ($password -ne "")) {
            # remove and create service, since its not possible to change credentials
            $svc.delete()

            $fullUser = $user
            if ($user.Split("\").count -eq 1) {
                $fullUser = $env:COMPUTERNAME + "\" + $user
            }

            $encryptedPassword = ConvertTo-SecureString $password -AsPlainText -Force
            $credentials = New-Object System.Management.Automation.PSCredential ($fullUser, $encryptedPassword)

            New-Service -Name $name -BinaryPathName $path -Credential $credentials

            $svc = Get-WmiObject -Class Win32_Service -Filter "Name='$name'"
            Set-Attr $result "changed" $true;
        }
        If ($svc.StartMode.ToLower() -ne $startMode) {
            Set-Service -Name $name -StartupType $startMode
            Set-Attr $result "changed" $true;
        }
        If ($svc.DisplayName -ne $displayName) {
            Set-Service -Name $name -DisplayName $displayName
            Set-Attr $result "changed" $true;
        }
        If ($svc.Description -ne $description) {
            Set-Service -Name $name -Description $description
            Set-Attr $result "changed" $true;
        }
    }
}
Catch {
    Fail-Json $result "an error occured when attempting to $state $name service"
}

Exit-Json $result
