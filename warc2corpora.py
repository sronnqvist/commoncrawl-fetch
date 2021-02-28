#from gzipstream import GzipStreamFile
import os
import sys
import gzip
import trafilatura
import warcio as warc
from langdetect import detect, lang_detect_exception
import random
import collections
#from http.server import BaseHTTPRequestHandler
#from io import BytesIO


OUTPUT_DIR = sys.argv[2]
SAMPLING_RATE = 0.1

random.seed(313313)


output_files = {}
filename = sys.argv[1]
#f = warc.WARCFile(fileobj=gzip.open(filename))
from warcio.archiveiterator import ArchiveIterator
f = gzip.open(filename)

if '/' in filename:
    filename = filename.split('/')[-1]

cntr = 0
last_domain = ""
for i, record in enumerate(ArchiveIterator(f)):
    if i % 1000 == 0:
        print("%s:%d, %d pages extracted in %d languages" % (filename, i, cntr, len(output_files)))
    #if last_domain == record.rec_headers.get_header('WARC-Target-URI').split('/')[2]:
    #    continue
    #if random.random() > SAMPLING_RATE:
    #    continue
    #if record['WARC-Type'] != 'response':
    if record.rec_type != 'response':
        continue

    #request = HTTPRequest(record.payload.read())
    #print(request.error_message)
    #response = record.payload.read()
    response = record.content_stream().read()
    if not response:
        continue
    #headers = response[:response.index(b'\r\n\r\n')]
    #print(response)
    #body = response[response.index(b'\r\n\r\n'):].strip()
    body = response
    try:
        text = trafilatura.extract(body)
    except:
        continue
    if text is None:
        continue
    try:
        lang = detect(text)
    except lang_detect_exception.LangDetectException:
        pass

    if lang not in output_files:
        output_files[lang] = gzip.open(os.path.join(OUTPUT_DIR, '%s.txt.gz' % lang), 'at')

    out = output_files[lang]
    print("##SRC: %s" % filename, file=out)
    #print("##ID: %s" % record['WARC-Record-ID'].split(':')[2][:-1], file=out)
    print("##ID: %s" % record.rec_headers.get_header('WARC-Record-ID').split(':')[2][:-1], file=out)
    #print("##URL: %s" % record['WARC-Target-URI'], file=out)
    print("##URL: %s" % record.rec_headers.get_header('WARC-Target-URI'), file=out)
    print(text+'\n', file=out)
    cntr += 1
    #last_domain = record.rec_headers.get_header('WARC-Target-URI').split('/')[2]


for f in output_files.values():
    f.close()


