#!/bin/bash
#
# report_and_run.sh

rank="$FLUX_TASK_RANK"
node=$(hostname)

binding=$(hwloc-ps --pid $$ --cpuset | awk '{print $2}')

# Binding will be a clean cpuset string.
core_list=$(hwloc-calc --pulist "$binding")
first_core=$(echo "$core_list" | cut -d, -f1)

# Use grep to get only the nodeset line
nodeset_line=$(hwloc-info "pu:$first_core" | grep "^ *nodeset =")

# Extract the hex value and aggressively clean any whitespace.
nodeset_hex=$(echo "$nodeset_line" | awk '{print $3}' | tr -d '[:space:]')

# Use a flexible case statement that checks what the string ENDS WITH.
numa_domain="unknown"
case "$nodeset_hex" in
  *1) numa_domain="0" ;;
  *2) numa_domain="1" ;;
  *4) numa_domain="2" ;;
  *8) numa_domain="3" ;;
  *)  numa_domain="err" ;;
esac

# Print all captured information to standard error.
# The PEWPEWPEW will be used to find the lines in output
echo "                rank  node  binding  numa domain"
echo "PEWPEWPEW $rank $node $binding $numa_domain" >&2
echo

# Execute the real application (if any).
if [ $# -gt 0 ]; then
    exec "$@"
fi