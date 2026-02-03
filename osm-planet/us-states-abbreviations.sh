#!/bin/zsh

osm_file=$1

if [[ "$(uname)" == "Darwin" ]]; then
    SED_CMD=(sed -i '')
else
    SED_CMD=(sed -i)
fi

declare -A abbr
abbr[Vermont]="Verm."
abbr[California]="Cal."
abbr[Georgia]="Geo."
abbr[Hawaii]="Haw."
abbr[Idaho]="Ida."
abbr[Iowa]="Ioa."
abbr[Kansas]="Kans."
abbr[Maryland]="Mary."
abbr[New\ Jersey]="N. Jersey"
abbr[New\ Mexico]="New Mex."
abbr[New\ York]="N. York"
abbr[North\ Carolina]="N. Car."
abbr[Oregon]="Oreg."
abbr[Pennsylvania]="Penn."
abbr[South\ Carolina]="S. Car."
abbr[South\ Dakota]="S. Dak."
abbr[Virginia]="Virg."
abbr[West\ Virginia]="W. Virg."
abbr[Wisconsin]="Wisc."
abbr[District\ of\ Columbia]="Dis. Col."
abbr[Kentucky]="Ken."

for name abbreviation in "${(@kv)abbr}"; do
    "${SED_CMD[@]}" "/<tag k=\"name\" v=\"$name\"\/>/a\\
    <tag k=\"short_name:en\" v=\"$abbreviation\"\/>"$'\n' "$osm_file"
done

declare -A alt
alt[Maryland]="Mar."
alt[Pennsylvania]="Penna."
alt[New\ Jersey]="New Jer."
alt[New\ Mexico]="New M."
alt[New\ York]="New Y."
alt[Oregon]="Or."
alt[South\ Carolina]="South Car."
alt[South\ Dakota]="SoDak"
alt[West\ Virginia]="West Virg."
alt[Kentucky]="Kent."

for name alternative in "${(@kv)alt}"; do
    "${SED_CMD[@]}" "/<tag k=\"name\" v=\"$name\"\/>/a\\
    <tag k=\"alt_name\" v=\"$alternative\"\/>"$'\n' "$osm_file"
done