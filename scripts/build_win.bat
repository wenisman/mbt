SET MBT=%cd%
SET GIT2GO_PATH=%MBT%\vendor\github.com\libgit2\git2go
SET LIBGIT2_PATH=%MBT%\vendor\libgit2
SET OS=windows
SET ARCH=x86
set OUT="mbt.exe"

go version

cd %LIBGIT2_PATH%
mkdir install
mkdir "install/lib"
mkdir build
cd build
cmake -DTHREADSAFE=ON -DBUILD_CLAR=OFF -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=../install -DUSE_SSH=OFF -DCURL=OFF ..

cmake --build .
cmake --build . --target install

SET PKG_CONFIG_PATH=%LIBGIT2_PATH%/build
for /f %%i in ('pkg-config --libs %LIBGIT2_PATH%\build\libgit2.pc') do set CGO_LDFLAGS=%%i

cd %MBT%

rd /s /q build
mkdir build

go get -t
go get github.com/stretchr/testify

copy %LIBGIT2_PATH%\install\bin\git2.dll lib\git2.dll

go test -v ./... -mod=vendor

go build -o "build/%OUT%" -mod=vendor
copy %LIBGIT2_PATH%\install\bin\git2.dll build\git2.dll

powershell -Command "Compress-Archive -Path build\* -DestinationPath build\mbt_windows_x86.zip"

dir build
