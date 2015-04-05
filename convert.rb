#!/usr/bin/env ruby

require 'shellwords'
require 'pathname'

templatename = Pathname.new(__FILE__).parent

filename = Pathname.new(ARGV[0])
base = filename.basename(filename.extname)
outdir = filename.parent.join('build', base)
outdir.mkpath

template_path = [templatename.to_s].inspect
command = "ipython nbconvert --to latex --template note --TemplateExporter.template_path=#{template_path.shellescape} --stdout #{filename.to_s.shellescape}"
result = `#{command}`
result.gsub!('\begin{longtable}', '\begin{center}\begin{supertabular}')
result.gsub!('\endhead', '')
result.gsub!('\end{longtable}', '\end{supertabular}\end{center}')

exit $?.to_i unless $? == 0
outtex = outdir.join("#{base}.tex")
File.write(outtex, result)

system "xelatex -halt-on-error -output-directory=#{outdir.to_s.shellescape} #{outtex.to_s.shellescape}"
