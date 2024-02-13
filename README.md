# prometheus-scripts
## Description
Bash scripts to extract values from a Prometheus database

For usage, execute the following command :-

(PATH=bin:$PATH ; source prometheus-lib.sh ; prometheus-lib-help)

After copying the scripts to a directory in the current **PATH**, there will
be **no** need to set the PATH when source'ing prometheus-lib.sh

## Requirements:

### Prometheus ###
A Prometheus databaase instance running, note that all the examples
assume there is one running on the local server at port 9090, see 
this line in prometheus-lib.sh 

export PROMETHEUS_API="${PROMETHEUS_API:-http://localhost:9090/api/v1}"

and it can be overridden on the command line line e.g.

export **PROMETHEUS_API**="http://somewhere-else:9090/api/vi" ; source prometheus-lib.sh ; prometheus-lib-get-latest-value node_thermal_zone_temp 1m

### Mailer ###
ssmtp is the mail client version :-

    sSMTP 2.64 (Not sendmail at all)


## Hardware Platform Tested On ###

    Raspbery Pi 4B 

## Operating System Tested On ##

    PRETTY_NAME="Debian GNU/Linux 11 (bullseye)"
    NAME="Debian GNU/Linux"
    VERSION_ID="11"
    VERSION="11 (bullseye)"
    VERSION_CODENAME=bullseye
    ID=debian
    HOME_URL="https://www.debian.org/"
    SUPPORT_URL="https://www.debian.org/support"
    BUG_REPORT_URL="https://bugs.debian.org/"
