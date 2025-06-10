GOOGLE_DRIVE_PREVIEWABLE_TYPES = %w[
  application/pdf

  application/msword
  application/vnd.openxmlformats-officedocument.wordprocessingml.document

  application/vnd.ms-excel
  application/vnd.openxmlformats-officedocument.spreadsheetml.sheet

  application/vnd.ms-powerpoint
  application/vnd.openxmlformats-officedocument.presentationml.presentation

  text/plain
  text/csv
  text/html

  image/jpeg
  image/png
  image/gif
  image/bmp
  image/tiff
  image/webp

  audio/mpeg
  audio/mp3
  video/mp4
  video/x-msvideo
  video/quicktime
].freeze

GOOGLE_DRIVE_EDITABLE_TYPES = [
  'application/vnd.google-apps.document',
  'application/vnd.google-apps.spreadsheet',
  'application/vnd.google-apps.presentation',
  'application/msword',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  'application/vnd.ms-excel',
  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  'application/vnd.ms-powerpoint',
  'application/vnd.openxmlformats-officedocument.presentationml.presentation',
  'text/plain',
  'text/csv'
].freeze


GOOGLE_DRIVE_FILE_EXTENSIONS = {
  'application/pdf' => '.pdf',
  'application/msword' => '.doc',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document' => '.docx',
  'application/vnd.ms-excel' => '.xls',
  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' => '.xlsx',
  'application/vnd.ms-powerpoint' => '.ppt',
  'application/vnd.openxmlformats-officedocument.presentationml.presentation' => '.pptx',
  'text/plain' => '.txt',
  'text/csv' => '.csv',
  'image/jpeg' => '.jpg',
  'image/png' => '.png'
}.freeze