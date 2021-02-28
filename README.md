# commoncrawl-fetch
Build language corpora from Common Crawl

Install:
```
mkdir downloads logs output
python3 -m venv VENV
source VENV/bin/activate
pip install -r requirements.txt
```

Configure: `nano launch_dl.sh`

Run: `sh launch_dl.sh`

The script downloads index file of batch, e.g., CC-MAIN-2020-34, shuffles it, partitions its packages, and launches parallel downloads of each partition. The downloader extracts text content from the crawl packages and separates the output by language.
