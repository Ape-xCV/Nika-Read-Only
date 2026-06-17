#!/usr/bin/env bash


if [[ "$1" == "" ]]; then
  echo "usage: $0 edidfile.bin"
  exit 0
fi

get_random_serial() { head /dev/urandom | tr -dc 'A-Z0-9' | head -c "$1"; }
get_random_hex()    { head /dev/urandom | tr -dc '0-9A-F' | head -c "$1"; }

get_edid_data() {
  file="$1"
#  local data=$(hexdump -v -e '1 1 "%02X"' $file)
  data=$(hexdump -v -e '1 1 "%02X"' $file)
  size="${#data}"
  echo "$1 $(( size/2 )) bytes"
  manufacturer="${data:16:4}"
  product="${data:20:4}"
  serial="${data:24:8}"
  slot_1="${data:118:26}"
  slot_2="${data:154:26}"
  slot_3="${data:190:26}"
  slot_4="${data:226:26}"
}

spoof_edid_slot() {
  slot_n="$1"
  output=""
  string=$(get_random_serial 13)
  for i in {8..22..2}; do
    if [[ "${slot_n:i:2}" != "00" ]] && [[ "${slot_n:i+2:2}" == "0A" ]]; then
      for j in {0..24..2}; do
        if [[ "$j" -le "$i" ]]; then
          output=${output}$(  printf "%X" "'${string:j/2:1}"  )
        else
          output=${output}${slot_n:j:2}
        fi
      done
      break
    fi
  done
}

print_edid() {
  printf "    id:"
  dec=$((16#$manufacturer))
  bin=""
  for ((i=14; i>=10; i--)); do
    bin+=$(( (dec >> i) & 1 ))
  done
  oct=$(  printf '%o\n' $((2#$bin))  )
  printf "\\$(  printf '%o\n' $(( $((2#$bin))+64 ))  )"
  bin=""
  for ((i=9; i>=5; i--)); do
    bin+=$(( (dec >> i) & 1 ))
  done
  oct=$(  printf '%o\n' $((2#$bin))  )
  printf "\\$(  printf '%o\n' $(( $((2#$bin))+64 ))  )"
  bin=""
  for ((i=4; i>=0; i--)); do
    bin+=$(( (dec >> i) & 1 ))
  done
  oct=$(  printf '%o\n' $((2#$bin))  )
  printf "\\$(  printf '%o\n' $(( $((2#$bin))+64 ))  )"
  echo ${product:2:2}${product:0:2}

  echo "serial:$((16#$serial))"
  serial=$(get_random_hex 8)
  echo "serial:$((16#$serial))"

  printf "\nslot_1:$slot_1 "
  for i in {0..24..2}; do
    printf "\\$(  printf '%o\n' $((16#${slot_1:i:2}))  )"
  done

  printf "\nslot_2:$slot_2 "
  for i in {0..24..2}; do
    printf "\\$(  printf '%o\n' $((16#${slot_2:i:2}))  )"
  done
  spoof_edid_slot "$slot_2"
  if [[ "$output" != "" ]]; then
    slot_2="$output"
    printf "\nslot_2:$slot_2 "
    for i in {0..24..2}; do
      printf "\\$(  printf '%o\n' $((16#${slot_2:i:2}))  )"
    done
  fi

  printf "\nslot_3:$slot_3 "
  for i in {0..24..2}; do
    printf "\\$(  printf '%o\n' $((16#${slot_3:i:2}))  )"
  done
  spoof_edid_slot "$slot_3"
  if [[ "$output" != "" ]]; then
    slot_3="$output"
    printf "\nslot_3:$slot_3 "
    for i in {0..24..2}; do
      printf "\\$(  printf '%o\n' $((16#${slot_3:i:2}))  )"
    done
  fi

  printf "\nslot_4:$slot_4 "
  for i in {0..24..2}; do
    printf "\\$(  printf '%o\n' $((16#${slot_4:i:2}))  )"
  done
  printf "\n"
}

get_edid_data "$1"
print_edid

data="${data:0:24}$serial${data:32:$((size-32))}"
data="${data:0:154}$slot_2${data:180:$((size-180))}"
data="${data:0:190}$slot_3${data:216:$((size-216))}"

printf "$(  printf '\\x%s' ${data:0:2}  )" > output.bin
for i in {2..510..2}; do
  printf "$(  printf '\\x%s' ${data:i:2}  )" >> output.bin
done
echo "output.bin $(( size/2 )) bytes"

