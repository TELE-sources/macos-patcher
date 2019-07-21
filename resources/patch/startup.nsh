echo -off
set StartupDelay 1
set -v efishellmode 1.1.2
set macOSBootFile "boot_file"
set targetUUID "volume_uuid"

for %i run (0 9)
  if exist fs%i:\EFI\apfs.efi then
    load fs%i:\EFI\apfs.efi
    connect -r
    map -u
  endif
endfor
for %m run (0 9)
  if exist "fs%m:\%targetUUID%\%macOSBootFile%" then
    echo "Starting macOS..."
    fs%m:\%targetUUID%\%macOSBootFile%
    exit
endif
endfor
for %l in A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
   if exist "fs%l:\%targetUUID%\%macOSBootFile%" then
      echo "Starting macOS..."
      fs%l:\%targetUUID%\%macOSBootFile%
      exit
endif
endfor

for %m run (0 9)
  if exist "fs%m:\%macOSBootFile%" then
    echo "Starting macOS..."
    fs%m:\%macOSBootFile%
    exit
endif
endfor
for %l in A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
   if exist "fs%l:\%macOSBootFile%" then
      echo "Starting macOS..."
      fs%l:\%macOSBootFile%
      exit
   else
    if %l == Z then
       echo "Boot file not found, exiting..."
endif
endif
endfor
