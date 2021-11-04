*! version 0.1.0 04Nov2021
*
* restore data snapshots with specific name

program define snaprestore, nclass
    version 14
    syntax [namelist(name=name max=1)]
    if "`name'" == ""  local name = "default_snap_name"
    if "${SNAPSHOT_`name'}" == "" {
        di as error "no snapshot with name: `name'"
        error 999
    }
    quietly snapshot restore ${SNAPSHOT_`name'}
    macro drop SNAPSHOT_`name'
end
