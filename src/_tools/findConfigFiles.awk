BEGIN {
  FS=".";
  split(ext, extArr, "|");
  for (i in extArr) {
    extIndex[extArr[i]] = i;
  }
}
function basenameWithoutExtension(file) {
  sub(".*/", "", file)
  sub(/\.[^.]+$/, "", file)
  return file
}
{
  if ($NF in extIndex) {
    fileBase=basenameWithoutExtension($0)
    print fileBase "\t" extIndex[$NF] "\t" $0;
  }
}
