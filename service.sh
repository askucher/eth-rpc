pm2 start npm --name db -- run db
pm2 start npm --name blocks -- run sync_blocks
pm2 start npm --name tx -- run sync_transactions
pm2 start npm --name follow -- run follow
pm2 start npm --name reverse -- run reverse
pm2 start npm --name 10m -- run 10m
pm2 start npm --name 20m -- run 20m