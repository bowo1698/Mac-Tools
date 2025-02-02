#!/usr/bin/env bash

#####################
# Terminal colors
#####################
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

#####################
# Helper Functions
#####################

# Extract Google Drive file ID from a URL, if present.
function extract_drive_id() {
  local url="$1"
  # Typical GDrive patterns: drive.google.com/file/d/<ID> or docs.google.com/document/d/<ID>, etc.
  local regex='d/([^/]+)'
  if [[ $url =~ $regex ]]; then
    echo "${BASH_REMATCH[1]}"
  else
    echo ""
  fi
}

# Perform the actual download with curl.
function perform_direct_download() {
  local url="$1"
  local output_file="$2"

  echo -e "\n${GREEN}Downloading...${RESET}"
  echo "Source URL: $url"
  echo "Saving as:  $output_file"
  echo "-----------------------------------------"

  # Use -L to follow redirects
  curl -L "$url" -o "$output_file"

  if [[ -f "$output_file" ]]; then
    echo -e "${GREEN}Download complete!${RESET} Saved as: ${YELLOW}$output_file${RESET}"
  else
    echo -e "${RED}Something went wrong. The file was not saved.${RESET}"
  fi
}

# Google Docs -> PDF
function download_gdoc_as_pdf() {
  local file_url="$1"
  local custom_name="$2"
  local file_id
  file_id=$(extract_drive_id "$file_url")

  if [[ -z "$file_id" ]]; then
    echo -e "${YELLOW}Could not extract a Google Drive file ID from the URL. Falling back to direct download...${RESET}"
    perform_direct_download "$file_url" "$custom_name"
  else
    local download_url="https://docs.google.com/document/d/${file_id}/export?format=pdf"
    # Ensure the output name ends with .pdf
    if [[ "$custom_name" != *.pdf ]]; then
      custom_name="${custom_name}.pdf"
    fi
    perform_direct_download "$download_url" "$custom_name"
  fi
}

# Google Docs -> DOCX
function download_gdoc_as_docx() {
  local file_url="$1"
  local custom_name="$2"
  local file_id
  file_id=$(extract_drive_id "$file_url")

  if [[ -z "$file_id" ]]; then
    echo -e "${YELLOW}Could not extract a Google Drive file ID from the URL. Falling back to direct download...${RESET}"
    perform_direct_download "$file_url" "$custom_name"
  else
    local download_url="https://docs.google.com/document/d/${file_id}/export?format=docx"
    if [[ "$custom_name" != *.docx ]]; then
      custom_name="${custom_name}.docx"
    fi
    perform_direct_download "$download_url" "$custom_name"
  fi
}

# Google Sheets -> XLSX
function download_gsheet_as_xlsx() {
  local file_url="$1"
  local custom_name="$2"
  local file_id
  file_id=$(extract_drive_id "$file_url")

  if [[ -z "$file_id" ]]; then
    echo -e "${YELLOW}Could not extract a Google Drive file ID from the URL. Falling back to direct download...${RESET}"
    perform_direct_download "$file_url" "$custom_name"
  else
    local download_url="https://docs.google.com/spreadsheets/d/${file_id}/export?format=xlsx"
    if [[ "$custom_name" != *.xlsx ]]; then
      custom_name="${custom_name}.xlsx"
    fi
    perform_direct_download "$download_url" "$custom_name"
  fi
}

# Google Slides -> PPTX
function download_gslides_as_pptx() {
  local file_url="$1"
  local custom_name="$2"
  local file_id
  file_id=$(extract_drive_id "$file_url")

  if [[ -z "$file_id" ]]; then
    echo -e "${YELLOW}Could not extract a Google Drive file ID from the URL. Falling back to direct download...${RESET}"
    perform_direct_download "$file_url" "$custom_name"
  else
    local download_url="https://docs.google.com/presentation/d/${file_id}/export?format=pptx"
    if [[ "$custom_name" != *.pptx ]]; then
      custom_name="${custom_name}.pptx"
    fi
    perform_direct_download "$download_url" "$custom_name"
  fi
}

# Google Drive -> any other file type (zip, rar, mp4, etc.)
function download_gdrive_other() {
  local file_url="$1"
  local custom_name="$2"
  local file_id
  file_id=$(extract_drive_id "$file_url")

  if [[ -z "$file_id" ]]; then
    echo -e "${YELLOW}Could not extract a Google Drive file ID from the URL. Falling back to direct download...${RESET}"
    perform_direct_download "$file_url" "$custom_name"
  else
    local download_url="https://drive.google.com/uc?export=download&id=${file_id}"
    perform_direct_download "$download_url" "$custom_name"
  fi
}

# Fallback direct download from ANY other URL (Amazon, NCBI, etc.)
function download_from_any_url() {
  local file_url="$1"
  local custom_name="$2"
  perform_direct_download "$file_url" "$custom_name"
}

# Use yt-dlp to download best video or best audio
function download_with_ytdlp() {
  local url="$1"

  # If the user forgot to supply a URL at the beginning, prompt again
  if [ -z "$url" ] || [[ "$url" == "NONE" ]]; then
    echo -e "${RED}No URL specified for yt-dlp downloads. Please provide one now.${RESET}"
    read -rp "Enter the streaming/video URL: " url
    if [ -z "$url" ]; then
      echo -e "${RED}Still no URL. Exiting...${RESET}"
      exit 1
    fi
  fi

  echo -e "\n${GREEN}Select download type for yt-dlp:${RESET}"
  echo "1) Best quality video (with audio)"
  echo "2) Best quality audio only"
  echo -n "${YELLOW}Your choice (1/2): ${RESET}"
  read -r choice

  case $choice in
    1)
      echo -e "\n${GREEN}Downloading best quality video...${RESET}"
      yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio" --merge-output-format mp4 "$url"
      ;;
    2)
      echo -e "\n${GREEN}Downloading best quality audio...${RESET}"
      yt-dlp -x --audio-format mp3 "$url"
      ;;
    *)
      echo -e "${RED}Invalid choice! Exiting.${RESET}"
      exit 1
      ;;
  esac

  echo -e "\n${GREEN}Download complete!${RESET}"
}

#####################
# Main Menu
#####################

clear
echo "============================================================"
echo "           ${GREEN}Ultimate Downloader - All in One${RESET}"
echo "============================================================"
echo "Choose the type of download you want:"
echo "1) Google Doc   -> PDF"
echo "2) Google Doc   -> DOCX"
echo "3) Google Sheet -> XLSX"
echo "4) Google Slide -> PPTX"
echo "5) Google Drive -> any other file (zip, rar, mp4, etc.)"
echo "6) Direct download from any URL (Amazon, NCBI, etc.)"
echo "7) yt-dlp (best video or best audio) - YouTube, etc."
echo "------------------------------------------------------------"
read -rp "Enter your choice [1-7]: " CHOICE

# If the user picks options 1–6, we need a URL to process. Option 7 can prompt within the function itself.
FILE_URL="NONE"
CUSTOM_NAME="NONE"

# Only ask for the URL and filename if the user isn't doing the yt-dlp path
if [[ "$CHOICE" -ge 1 && "$CHOICE" -le 6 ]]; then
  echo ""
  read -rp "Enter the file URL: " FILE_URL
  echo ""
  read -rp "Enter the name to save the file as (include extension if not exporting a Google doc): " CUSTOM_NAME
fi

case "$CHOICE" in
  1)
    download_gdoc_as_pdf "$FILE_URL" "$CUSTOM_NAME"
    ;;
  2)
    download_gdoc_as_docx "$FILE_URL" "$CUSTOM_NAME"
    ;;
  3)
    download_gsheet_as_xlsx "$FILE_URL" "$CUSTOM_NAME"
    ;;
  4)
    download_gslides_as_pptx "$FILE_URL" "$CUSTOM_NAME"
    ;;
  5)
    download_gdrive_other "$FILE_URL" "$CUSTOM_NAME"
    ;;
  6)
    download_from_any_url "$FILE_URL" "$CUSTOM_NAME"
    ;;
  7)
    download_with_ytdlp "$FILE_URL"
    ;;
  *)
    echo -e "${RED}Invalid choice. Exiting.${RESET}"
    exit 1
    ;;
esac
