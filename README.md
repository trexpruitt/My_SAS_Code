# My_SAS_Code
Having Fun With SAS!

I developed this using the free version of SAS University Edition (UE).  
It can be downloaded here (follow their instructinos for install/config): 
https://www.sas.com/en_us/software/university-edition/download-software.html

Of course, you will need to install and configure the Claymore's CryptoNote CPU Miner from GitHub here:
https://github.com/nanopool/Claymore-XMR-CPU-Miner
Again, follow the instructions for install/config and begin mining a coin (e.g., ETN)

Once log files begin getting created, they will need to be accessed by the SAS UE application.
Since SAS UE does not allow Operating System (OS) commands to be executed within the application, you will need to copy the log files to the relevant accessible library.

I used this script in a BAT file scheduled hourly to copy the files automatically for use in SAS UE with windows scheduler hourly:

BEGIN BAT file script...
-
copy "C:\Users\Rex\Documents\Crypto\Claymore CryptoNote CPU Miner\Claymore CryptoNote CPU Miner v3.9 - POOL\*log.txt" /Y "C:\Users\Rex\Documents\SASUniversityEdition\myfolders\My SAS Data\"

copy "C:\Users\Rex\Documents\Crypto\Claymore CryptoNote CPU Miner\Claymore CryptoNote CPU Miner v4.0 - POOL\*log.txt" /Y "C:\Users\Rex\Documents\SASUniversityEdition\myfolders\My SAS Data\"

dir "C:\Users\Rex\Documents\SASUniversityEdition\myfolders\My SAS Data\*log.txt"  /B >"C:\Users\Rex\Documents\SASUniversityEdition\myfolders\My SAS Data\Claymore_FindAllFiles.txt"

END BAT file script;
-

Once the above applications and tasks are running, then I just execute the SAS code on demand when I wish to see my latest mining shares submitted.  Since most miners are based on luck (seems to be subjective), I back in to an estimated value per share based on my actual payments received.  Not the best, but I can at least see an estimated value of my mining and monitor timeline trends.

There may be a time when I replicate the process for monitoring other events that get posted to the log.

If you get this to work and want to send me some coin/token (I see a lot of GitHub contributors doing this :-).

ETN: etnk9nRS9qUGp3NnnAXH4pM6mk4J4Bq1DHpDeWN3G2KuPPhn8jxcaEoB3yK3vzeK1sPL6M6WXEQfMgQKqHpSSKEf5vypGvmyYX

BTC: 3BiW1Cx3kYD5niy1otkhQywYoGG17nFEgH

ETH: 0xF68325c0A340d1d53Dd5881E06309Bb284Bc3AdB

LTC: MTHDSRCuKWXLkADGWWX7EY593xrFQPt7A7


Have Fun!!!
-
