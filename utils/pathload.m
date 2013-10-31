function out = pathload(in,n)

in = regexprep(in,'\\','\\\');
out = load(sprintf(in,n));