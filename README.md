# Mac-Tools
iTerm shortcuts for mac

ultimate_downloader.sh
Combines universal Google Drive/doc downloader + direct URL downloader + yt-dlp wrapper.
It offers:
 1) Export Google Docs as PDF
 2) Export Google Docs as DOCX
 3) Export Google Sheets as XLSX
 4) Export Google Slides as PPTX
 5) Download any other file from Google Drive
 6) Download from any direct URL (Amazon, NCBI, etc.)
 7) Use yt-dlp for best quality video or audio

Usage:
```bash
chmod +x ultimate_downloader.sh
./ultimate_downloader.sh
```

 Dependencies:
   - curl
   - yt-dlp (for option 7)

Install yt-dlp: 
```bash
pip3 install yt-dlp```
