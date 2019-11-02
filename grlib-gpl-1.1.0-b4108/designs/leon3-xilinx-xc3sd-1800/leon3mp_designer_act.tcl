new_design -name "leon3mp" -family "Spartan-3A-DSP" 
set_device -die "XC3SD1800A" -package " " -speed "-4" -voltage "1.5" -iostd "LVTTL" -jtag "yes" -probe "yes" -trst "yes" -temprange "" -voltrange "" 
if {[file exist leon3mp.pdc]} {
import_source -format "edif" -edif_flavor "GENERIC"  -merge_physical "no" -merge_timing "no" {synplify/leon3mp.edf} -format "pdc" -abort_on_error "no" {leon3mp.pdc}
} else {
import_source -format "edif" -edif_flavor "GENERIC"  -merge_physical "no" -merge_timing "no" {synplify/leon3mp.edf}
}
save_design {leon3mp.adb}
