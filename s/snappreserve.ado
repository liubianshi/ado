*! version 0.1.0 04Nov2021
*
*  save data snapshots with specific global name

program define snappreserve, nclass
    version 14
    syntax [namelist(name=name max=1)] [, label(string)]
    if "`name'" == "" local name = "default_snap_name"
    if "`label'" == "" local label = "`name'"

    if "${SNAPSHOT_`name'}" != "" {
        di as error "Snapshot `name' already exists"
        error 899
    }
    quietly snapshot save, label("`label'")
    global SNAPSHOT_`name' = r(snapshot)
end
