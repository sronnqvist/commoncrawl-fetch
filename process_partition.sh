BATCH_NAME=$1
WORK_DIR=$2
OUTPUT_DIR=$3

mkdir -v output/$OUTPUT_DIR

zcat $WORK_DIR/urls.gz|while read URL;
do echo "$URL" >> $WORK_DIR/dl.log
wget -nv -P $WORK_DIR https://commoncrawl.s3.amazonaws.com/$URL
FILE=$(echo $URL |cut -d"/" -f6-)
python warc2corpora.py $WORK_DIR/$FILE output/$OUTPUT_DIR
rm -v $WORK_DIR/$FILE
sleep 5
done

