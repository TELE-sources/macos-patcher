<img src="https://github.com/rmc-team/macos-patcher/raw/master-3.0/MacBook.png" width="256">

# macOS Patcher
macOS Patcher is a command line tool for running macOS on unsupported Macs

# Contributers
I'd like to the thank the following people, and many others, for their research, help, and inspiration.
- [dosdude1](https://forums.macrumors.com/members/669685/)
- [parrotgeek1](https://forums.macrumors.com/members/1033441/)
- [ASentientBot](https://forums.macrumors.com/members/1135186/)
- [SpiraMira](https://github.com/SpiraMira)
- [tiehfood](https://github.com/tiehfood)
- [jackluke](https://forums.macrumors.com/members/1133911/)
- [Larsvonhier](https://forums.macrumors.com/members/1041077/)
- [Czo](https://forums.macrumors.com/members/263182/)
- [Syncretic](https://forums.macrumors.com/members/1173816/)

# Links
- [RMC GitHub](https://github.com/rmc-team)
- [RMC Website](https://www.rmc-team.ch/)
- [RMC Twitter](https://twitter.com/_rmcteam)
- [More Documentation](https://www.rmc-team.ch/patcher)

# Supported Macs
## iMacs
-   iMac7,1
-   iMac8,1
-   iMac9,1
-   iMac10,1
-   iMac10,2
-   iMac11,1
-   iMac11,2
-   iMac11,3
-   iMac12,1
-   iMac12,2
## MacBooks
-   MacBook4,1
-   MacBook5,1
-   MacBook5,2
-   MacBook6,1
-   MacBook7,1
## MacBook Airs
-   MacBookAir2,1
-   MacBookAir3,1
-   MacBookAir3,2
-   MacBookAir4,1
-   MacBookAir4,2
## MacBook Pros
-   MacBookPro4,1
-   MacBookPro5,1
-   MacBookPro5,2
-   MacBookPro5,3
-   MacBookPro5,4
-   MacBookPro5,5
-   MacBookPro6,1
-   MacBookPro6,2
-   MacBookPro7,1
-   MacBookPro8,1
-   MacBookPro8,2
-   MacBookPro8,3
## Mac minis
-   Macmini3,1
-   Macmini4,1
-   Macmini5,1
-   Macmini5,2
-   Macmini5,3
## Mac Pros
-   MacPro3,1
-   MacPro4,1
## Xserves
-   Xserve2,1
-   Xserve3,1

# Usage
chmod +x ./macOS\ Patcher.sh —> makes the script runnable  
sudo ./macOS\ Patcher.sh —> runs the script with root permissions  

# Brightness Slider and NoSleep
If you have a MacBook4,1, you might notice two little applications have been installed along with macOS Patcher's other patches. They help solve specific issues on the MacBook4,1 and should be opened and configured after patching. NoSleep is open source and can be found [here](https://github.com/integralpro/nosleep). Brightness Slider is made by ACT Productions and can be found on the [Mac App Store](http://itunes.apple.com/us/app/brightness-control/id456624497?ls=1&mt=12).

# Graphics acceleration
If you have a MacBook4,1, your Mac won't support graphics acceleration with this patcher. This means brightness control and sleep won't work (see above) and applications that rely on your graphics card will perform slower or will simply not work.