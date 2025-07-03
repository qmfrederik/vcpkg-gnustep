# Mark the network profile as private, so inbound connections (e.g. SSH) work correctly
Get-NetConnectionProfile -Name Network | Set-NetConnectionProfile -NetworkCategory Private

# Install Chocolatey
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install LLVM
choco install -y llvm

# Install the Visual Studio 2022 build tools, and then add the C++ build tools workload
choco install -y visualstudio2022buildtools
choco install -y visualstudio2022-workload-vctools

# Install git
choco install -y git

# Clone the vcpkg-gnustep vcpkg repositories
New-Item -Path "${env:HOME}\Source\Repos" -Type Directory
cd ${env:HOME}\Source\Repos
& 'C:\Program Files\Git\bin\git.exe' clone https://github.com/qmfrederik/vcpkg-gnustep
cd vcpkg-gnustep
& 'C:\Program Files\Git\bin\git.exe' clone https://github.com/microsoft/vcpkg
cd vcpkg
& 'C:\Program Files\Git\bin\git.exe' checkout 2024.08.23
cd ..
./vcpkg/bootstrap-vcpkg.bat
