#! /usr/bin/bash

file=$(sort --random-sort www.txt)
url=$(head -n 1 <<< "$file")
url2=$(head -n 2 <<< "$file" | tail -n 1)
echo $url
echo $url2
title=$(wget -qO- $url | perl -l -0777 -ne 'print $1 if /<title.*?>\s*(.*?)\s*<\/title/si')
title=${title//&???;}
title=${title//&????;}
title=${title//&?????;}
title=${title//&??????;}
title2=$(wget -qO- $url2 | perl -l -0777 -ne 'print $1 if /<title.*?>\s*(.*?)\s*<\/title/si')
title2=${title2//&???;}
title2=${title2//&????;}
title2=${title2//&?????;}
title2=${title2//&??????;}
echo -e '\033]2;'${title//-}'\007'

me=$(basename "$0")
target="${me%.sh}"

/root/$target "${title2//-}"
