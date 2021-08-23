/^#@$/ { showbody = 1 }
{ if (showbody) { if (showbody>1) print; showbody++ } }
