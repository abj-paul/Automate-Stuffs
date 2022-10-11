

# import module
import os
from PIL import Image
from pdf2image import convert_from_path


pages = convert_from_path('crc.pdf')
filename_prefix = 'crc_card_'

for i in range(len(pages)):

	pages[i].save(filename_prefix+ str(i) +'.jpg', 'JPEG')

