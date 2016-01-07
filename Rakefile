import 'libelli/Rakefile'

def gly_pdf(gly_path)
  gly_path.sub(/\.gly/i, '.pdf')
end

part_sheets = Dir['*/**/*.gly'].collect do |gf|
  target = gly_pdf(gf)
  file target => [gf] do
    dirname = File.dirname gf
    fname = File.basename gf
    Dir.chdir(dirname) do
      sh 'gly', 'preview', fname
    end
  end

  target
end

desc 'individual part sheets (pdf, scores only)'
task :part_sheets => part_sheets

desc 'build all available targets'
task :default => :part_sheets
