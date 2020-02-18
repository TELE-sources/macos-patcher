echo -off
set StartupDelay 1
set -v efishellmode 1.1.2

set macOSBootFile "boot_file"
set macOSBootFile_update "boot_file_update"
set targetUUID "volume_uuid"
set targetUUID_update "volume_uuid_update"

for %i run (0 9)
  if exist fs%i:\EFI\apfs.efi then
    load fs%i:\EFI\apfs.efi
    connect -r
    map -u
  endif
endfor
for %m run (0 9)
  if exist "fs%m:\%targetUUID_update%\%macOSBootFile_update%" then
    echo "Starting macOS..."
    fs%m:\%targetUUID_update%\%macOSBootFile_update%
    exit
endif
endfor
for %l in A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
   if exist "fs%l:\%targetUUID_update%\%macOSBootFile_update%" then
      echo "Starting macOS..."
      fs%l:\%targetUUID_update%\%macOSBootFile_update%
      exit
endif
endfor

for %m run (0 9)
  if exist "fs%m:\%macOSBootFile_update%" then
    echo "Starting macOS..."
    fs%m:\%macOSBootFile_update%
    exit
endif
endfor
for %l in A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
   if exist "fs%l:\%macOSBootFile_update%" then
      echo "Starting macOS..."
      fs%l:\%macOSBootFile_update%
      exit
   else
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
endif
endif
endfor
