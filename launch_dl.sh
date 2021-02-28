### Config ###

# Specify Common Crawl batch
YEAR=2020    #$1
MONTH=08     #$2
NUM=34       #$3

# Partition index for parallelization
STEP=25      # Number of packages (lines) per job
START=10025  # First job starts at line
END=20000    # Last job starts at line
#END=$(zgrep -c "" downloads/$BATCH_NAME/warc.paths.gz) # 60000

### Config end ###

BATCH_NAME="CC-MAIN-$YEAR-$NUM"

# Initalize batch?
if [ ! -d downloads/$BATCH_NAME ]; then
  mkdir -v downloads/$BATCH_NAME
  #rm -rf downloads/$BATCH_NAME/*

  # Get index
  wget -P downloads/$BATCH_NAME/ https://commoncrawl.s3.amazonaws.com/crawl-data/$BATCH_NAME/warc.paths.gz
  # Shuffle
  zcat downloads/$BATCH_NAME/warc.paths.gz |sort -R | gzip -9 > downloads/$BATCH_NAME/warc.paths.shuffled.gz
fi

#rm -rf downloads/$BATCH_NAME/split*

# Starts jobs
for PARTITION_BEG in $(seq $START $STEP $END); do 
  mkdir -v downloads/$BATCH_NAME/split.$PARTITION_BEG
  zcat downloads/$BATCH_NAME/warc.paths.shuffled.gz |head -$PARTITION_BEG |tail -$STEP |gzip -9 >downloads/$BATCH_NAME/split.$PARTITION_BEG/urls.gz
  echo $BATCH_NAME $PARTITION_BEG
  sbatch process_partition.sbatch $BATCH_NAME downloads/$BATCH_NAME/split.$PARTITION_BEG $YEAR.$MONTH.$PARTITION_BEG
done


