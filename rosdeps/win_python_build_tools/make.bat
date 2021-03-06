@ECHO OFF

set PWD=%~dp0
set COMMAND=%1
if X%COMMAND%==X set COMMAND=all
if X%COMMAND%==Xhelp goto Help
if X%COMMAND%==Xclean goto Clean
if X%COMMAND%==Xall goto Download
if X%COMMAND%==Xdownload goto Download
if X%COMMAND%==Xdistro goto Distro
if X%COMMAND%==Xupload goto Upload
goto Help

:Help
echo.
echo "Invalid usage: call with args from ['clean', 'all', 'download', 'distro', 'upload']"
echo "Make sure you bump the version in setup.py if necessary."
goto End

:Download
IF NOT EXIST %cd%\scripts\win-rosinstall.py (
  echo.
  echo "Downloading sources and patching"
  echo.
  rem vcstools 0.1.26 rosinstall 0.6.22 wstool 0.0.2, rospkg 1.0.17, catkin_pkg 0.1.8
  call git clone https://github.com/ros/rospkg.git
  cd rospkg & call git checkout 85310f77b412bb52a3190bcbadf3c0677be9ced4 & cd ..
  call git clone https://github.com/vcstools/vcstools.git
  cd vcstools & call git checkout c57f0ab7be2eede0ead237a783d2cf2c7dd94cba & cd ..  
  call git clone https://github.com/vcstools/rosinstall.git
  cd rosinstall & call git checkout 73451bff3dac0d45a79a5dc177ea7a8fd743da3e & cd ..
  call git clone https://github.com/vcstools/wstool.git
  cd wstool & call git checkout e2e4c03f915926ef45e142ea7c97df43fe1bf017 & cd ..
  call git clone https://github.com/ros-infrastructure/catkin_pkg.git
  cd catkin_pkg & call git checkout 45f182bbb5e675d4b729e0da19c1e183e6940e8c & cd ..
  move %cd%\vcstools\src\vcstools %cd%\src\vcstools
  move %cd%\rosinstall\src\rosinstall %cd%\src\rosinstall
  move %cd%\wstool\src\wstool %cd%\src\wstool
  move %cd%\wstool\scripts\wstool %cd%\scripts\winros_wstool.py
  move %cd%\rospkg\src\rospkg %cd%\src\rospkg
  move %cd%\rospkg\scripts\rosversion %cd%\scripts\winros_rosversion.py
  move %cd%\catkin_pkg\src\catkin_pkg %cd%\src\catkin_pkg
  move %cd%\catkin_pkg\bin\catkin_create_pkg %cd%\scripts\winros_catkin_create_pkg.py
  rem put patching here if we want it
  rem copy /Y %cd%\patches\common.py %cd%\src\rosinstall
  rem copy /Y %cd%\patches\multiproject_cli.py %cd%\src\rosinstall
  rem copy /Y %cd%\patches\config_elements.py %cd%\src\rosinstall
  rd /S /Q vcstools
  rd /S /Q rosinstall
  rd /S /Q wstool
  rd /S /Q rospkg
  rd /S /Q catkin_pkg
) ELSE (
  echo.
  echo "Already prepped"
)
if X%COMMAND%==Xall (
  goto Distro
) else (
  goto End
)

:Distro
echo.
echo "Building msi installer."
echo.
# Always build, it's easier this way.
python setup.py bdist_msi
rem IF NOT EXIST %cd%\dist (
rem  python setup.py bdist_msi
rem ) ELSE (
rem  echo.
rem  echo "Msi installer already built"
rem )
if X%COMMAND%==Xall (
  goto Upload
) else (
  goto End
)

:Upload
echo.
echo "Uploading to file server."
echo.
cd dist
scp *.msi files@files.yujinrobot.com:pub/repositories/windows/python/2.7/
goto End

:Clean
rd /S /Q %cd%\build
rd /S /Q %cd%\dist
rd /S /Q %cd%\src\vcstools
rd /S /Q %cd%\src\rosinstall
rd /S /Q %cd%\src\wstool
rd /S /Q %cd%\src\rospkg
rd /S /Q %cd%\src\catkin_pkg
rm -f %cd%\scripts\winros_wstool.py
rm -f %cd%\scripts\winros_rosversion.py
rm -f %cd%\scripts\winros_catkin_create_pkg.py
goto End

:End
cd %PWD%