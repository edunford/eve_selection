**Job**: Grab all logs that "warp to" a specific characterID

**Purpose**: An effort to map coordination networks between players (and alliances)

**Period**: 2015-01-01 to 2017-15-05 (roughly present)

Referencing the `warpToMapper.py`.

Establishing set up.

    cd ~/hadoop/RELEASE/hadoop/

    python doob.py --mapper warpToMapper.py --date 2017.04.01-2017.04.15 --output warpToCharLog

  Parse to `.csv`

    sed 's/\t/,/g' corpApplications_se.david.txt > ~/Documents/ETD/selection/data/importsExports/cropApplications.csv
