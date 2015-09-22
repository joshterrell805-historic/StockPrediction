function parseFannFileForExampleCount {
  local firstLine=$(head -n 1 "data/$i.train.$2.fann")
  local numbers=
  IFS=' ' read -ra numbers <<< "$firstLine"
  local lines=${numbers[0]}
  #echo "$1:$firstLine\.......$lines"
  >&2 echo "$lines"
  echo $lines
}
function parseFannFileForFeatureCount {
  local firstLine=$(head -n 1 "data/$i.train.pos.fann")
  local numbers=
  IFS=' ' read -ra numbers <<< "$firstLine"
  local featureCount=${numbers[1]}
  echo $featureCount
}
function readFannFileExamples {
  echo -n "$(tail -n +2 "data/$i.train.$2.fann")"
}

IFS=' ' read -ra symbols <<< "$1"
sum=0
output=''
for i in "${symbols[@]}"; do
  sum=$(($sum + `parseFannFileForExampleCount $i 'pos'`));
  sum=$(($sum + `parseFannFileForExampleCount $i 'neg'`));

  examples=`readFannFileExamples $i 'pos'`
  output="$output
$examples"
  examples=`readFannFileExamples $i 'neg'`
  output="$output
$examples"
done

featureCount=`parseFannFileForFeatureCount $1`
output="$sum $featureCount 1
$output"

filename=$(echo "$1" | sed "s/ /_/g")
echo -n "$output" > "data/$filename.train.fann"
