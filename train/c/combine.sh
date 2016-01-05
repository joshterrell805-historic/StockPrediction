function parseFannFileForExampleCount {
  local firstLine=$(head -n 1 "data/$i.$train_or_test.$2.fann")
  local numbers=
  IFS=' ' read -ra numbers <<< "$firstLine"
  local lines=${numbers[0]}
  #echo "$1:$firstLine\.......$lines"
  >&2 echo "$lines"
  echo $lines
}
function parseFannFileForFeatureCount {
  local firstLine=$(head -n 1 "data/$i.$train_or_test.pos.fann")
  local numbers=
  IFS=' ' read -ra numbers <<< "$firstLine"
  local featureCount=${numbers[1]}
  echo $featureCount
}
function readFannFileExamples {
  echo -n "$(tail -n +2 "data/$i.$train_or_test.$2.fann")"
}

train_or_test='train'
IFS=' ' read -ra symbols <<< "$1"
sumPos=0
sumNeg=0
outputPos=''
outputNeg=''
for i in "${symbols[@]}"; do
  sumPos=$(($sumPos + `parseFannFileForExampleCount $i 'pos'`));
  sumNeg=$(($sumNeg + `parseFannFileForExampleCount $i 'neg'`));

  examples=`readFannFileExamples $i 'pos'`
  outputPos="$outputPos
$examples"
  examples=`readFannFileExamples $i 'neg'`
  outputNeg="$outputNeg
$examples"
done

featureCount=`parseFannFileForFeatureCount $1`
filename=$(echo "$1" | sed "s/ /_/g")

outputPos="$sumPos $featureCount 1 $outputPos"
echo -n "$outputPos" > "data/$filename.$train_or_test.pos.fann"

outputNeg=`echo "$outputNeg" | head -n $(($sumPos*2+1))`
outputNeg="$sumPos $featureCount 1 $outputNeg"
echo -n "$outputNeg" > "data/$filename.$train_or_test.neg.fann"

echo "$((2*sumPos)) $featureCount 1
`tail -n +2 "data/$filename.$train_or_test.neg.fann"`
`tail -n +2 "data/$filename.$train_or_test.pos.fann"`" > "data/$filename.$train_or_test.fann"
