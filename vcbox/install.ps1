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
./vcpkg/bootstrap-vcpkg.bat
