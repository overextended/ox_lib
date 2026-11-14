export function cfxExport(exportName: string, fn: Function) {
    on(`__cfx_export_ox_lib_${exportName}`, (setCB: Function) => setCB(fn))
}