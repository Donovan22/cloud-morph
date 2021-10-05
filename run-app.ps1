$path = $args[0]
$appfile = $args[1]
$os = $args[7]
# Split-Path $outputPath -leaf

taskkill /FI "ImageName eq $appfile" /F
taskkill /FI "ImageName eq ffmpeg.exe" /F
taskkill /FI "ImageName eq syncinput.exe" /F
$app = Start-Process "winvm/$path/$appfile" -PassThru
sleep 2
$title = ((Get-Process -Id $app.id).mainWindowTitle)
sleep 2

$ffmpegParams = -join @(
    "-f gdigrab -framerate 30 -i title=`"$title`" -pix_fmt yuv420p "
    "-vf `"scale=2*trunc(iw/2):-2`" "
    "-c:v libx264 -tune zerolatency "
    "-f rtp rtp://127.0.0.2:5004"
)

# Start-Process ffmpeg -PassThru -ArgumentList "-f gdigrab -framerate 30 -i title=`"$title`" -pix_fmt yuv420p -vf scale=1280:-2 -c:v libvpx -f rtp rtp://127.0.0.2:5004"
# sleep 2
Start-Process ffmpeg -PassThru -ArgumentList "$ffmpegParams"
lleep 2
x86_64-w64-mingw32-g++ .\winvm\syncinput.cpp -o .\winvm\syncinput.exe -lws2_32 -lpthread -static

Start-Process winvm/syncinput.exe -PassThru -ArgumentList "$title", ".", "$os"
